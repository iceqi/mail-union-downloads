#!/bin/sh
set -eu
umask 077
command -v docker >/dev/null 2>&1 || { echo '请先安装并启动 Docker（包含 Docker Compose 插件），然后重新运行。' >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo '请先安装 Docker Compose v2 插件。' >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo '无法连接 Docker，请启动 Docker 并确认当前用户拥有访问权限。' >&2; exit 1; }
install_dir=${MAILU_INSTALL_DIR:-./mailu-server}
mkdir -p "$install_dir"
cd "$install_dir"
base_url=${MAILU_DEPLOY_BASE_URL:-https://raw.githubusercontent.com/iceqi/mail-union-downloads/main/server}
stage=$(mktemp -d './.mailu-deploy.XXXXXX')
trap 'rm -rf "$stage"' EXIT HUP INT TERM
fetch() {
  if command -v curl >/dev/null 2>&1; then curl -fLsS --connect-timeout 15 --max-time 60 "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then wget -q -T 60 -O "$2" "$1"
  else echo '请先安装 curl 或 wget。' >&2; return 1; fi
}
fetch "$base_url/compose.yaml" "$stage/compose.yaml"
if [ ! -f .env ]; then
  admin_password=$(od -An -N24 -tx1 /dev/urandom | tr -d ' \n')
  test ${#admin_password} -eq 48
  printf 'MAILU_BIND=%s\nMAILU_PORT=%s\nMAILU_SERVER_IMAGE=%s\nMAILU_ADMIN_USERNAME=admin\nMAILU_ADMIN_PASSWORD=%s\n' \
    "${MAILU_BIND:-0.0.0.0}" "${MAILU_PORT:-3100}" "${MAILU_SERVER_IMAGE:-ghcr.io/iceqi/mail-union-server:latest}" "$admin_password" > "$stage/env"
  mv "$stage/env" .env
fi
chmod 600 .env
# Compose interpolation reads .env from the install directory even while validating a staged file.
docker compose --project-directory "$PWD" --env-file .env -f "$stage/compose.yaml" config --quiet
if [ -f compose.yaml ]; then cp compose.yaml "$stage/previous-compose.yaml"; fi
cp "$stage/compose.yaml" compose.yaml
if ! docker compose pull; then
  if [ -f "$stage/previous-compose.yaml" ]; then cp "$stage/previous-compose.yaml" compose.yaml; fi
  echo '镜像拉取失败，已保留现有服务和数据。请检查网络及镜像访问权限后重试。' >&2
  exit 1
fi
docker compose up -d
container_id=$(docker compose ps -q server)
[ -n "$container_id" ] || { echo '未找到服务端容器，请执行 docker compose logs --tail=100 server。' >&2; exit 1; }
tries=0
while [ "$tries" -lt 60 ]; do
  state=$(docker inspect --format '{{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{end}}' "$container_id")
  case "$state" in
    'running healthy') break ;;
    exited*|dead*|*unhealthy) echo '服务端启动失败，请执行 docker compose logs --tail=100 server。' >&2; exit 1 ;;
  esac
  tries=$((tries + 1))
  sleep 2
done
[ "$tries" -lt 60 ] || { echo '等待健康检查超时，请执行 docker compose ps 和 docker compose logs --tail=100 server。' >&2; exit 1; }
printf '\nMailU 服务端已启动且健康检查通过。\n部署目录：%s\n' "$PWD"
docker compose port server 3100
printf '使用以上端口访问 http://服务器IP:端口。管理员账号及随机初始密码保存在部署目录的 .env 中，请登录后绑定 2FA。\n更新：再次执行同一条安装命令，或在部署目录运行 docker compose pull && docker compose up -d。\n'
