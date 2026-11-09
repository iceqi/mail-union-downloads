# MailU 服务端一键部署

需要已经安装并启动 Docker 与 Compose v2；脚本会明确提示缺少的依赖，不修改主机的 Docker 安装。

```sh
curl -fsSL https://raw.githubusercontent.com/iceqi/mail-union-downloads/main/server/deploy.sh | sh
```

默认目录 `./mailu-server`，端口 `3100`，直接使用 `ghcr.io/iceqi/mail-union-server:latest` 的 amd64/arm64 成品镜像，无需源码、Node.js 或编译工具。

## 登录

访问 `http://服务器IP:3100`。查看部署目录 `.env` 中的 `MAILU_ADMIN_USERNAME` 和 `MAILU_ADMIN_PASSWORD`；首次部署会生成随机密码，文件权限为600。登录后绑定 Google Authenticator 等兼容 TOTP 的2FA。

管理员在创建容器时初始化，避免对外开放一个未创建管理员的实例。环境变量仅初始化空数据库，修改 `.env` 不会重置已有账号密码。

## 自定义部署

```sh
curl -fsSL https://raw.githubusercontent.com/iceqi/mail-union-downloads/main/server/deploy.sh -o /tmp/mailu-server-deploy.sh
MAILU_INSTALL_DIR=/opt/mailu-server MAILU_BIND=127.0.0.1 MAILU_PORT=3100 sh /tmp/mailu-server-deploy.sh
```

这些变量仅在首次生成 `.env` 时使用；以后编辑 `.env` 后运行 `docker compose up -d`。默认 `MAILU_BIND=0.0.0.0` 便于远程部署；公网建议配置 HTTPS 反向代理或限制3100端口访问。

反向代理要将 `/agent`、`/api/admin/events` 的 WebSocket Upgrade 头传递到服务端，并保留长连接。桌面或 Docker 客户端填写可达的服务端 HTTPS 地址以及管理端签发的 AK / SK。

## 更新与检查

在部署目录执行：

```sh
docker compose pull
docker compose up -d
docker compose ps
docker compose logs --tail=100 server
```

重复执行安装命令也会更新；保留 `.env`、管理员账号和数据卷。脚本等待容器健康检查通过才报告成功。数据库和加密密钥自动写入 `server-data` 卷。

## 备份与迁移

备份必须同时包含数据库和对应 `.key` 文件。推荐停止服务后备份整个数据卷：

```sh
docker compose stop server
docker compose run --rm --no-deps --entrypoint tar server -C /app/data -czf - . > mailu-server-data.tar.gz
docker compose start server
```

迁移时将整个备份恢复到新实例的数据卷，并保留管理员信息。不要用 `docker compose down -v` 更新，它会删除全部数据。`.env` 含初始密码，应妥善保存。
