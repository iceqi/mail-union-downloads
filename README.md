# 秒邮 MailU

MailUnion，简称 MailU。这里提供 Windows、macOS 安装包与 Docker 部署文件。

## 安装包下载

进入 [Releases 下载页面](https://github.com/iceqi/mail-union-downloads/releases/latest)，选择对应系统：

| 系统 | 安装包 |
| --- | --- |
| Windows x64 | `MailU_<版本>_x64-setup.exe`，或 `.msi` |
| Apple Silicon Mac | `MailU_<版本>_aarch64.dmg` |
| Intel Mac | `MailU_<版本>_x64.dmg` |

下载后可使用同版本的 `SHA256SUMS*.txt` 校验文件。

## Docker 客户端部署

安装 Docker 与 Docker Compose 插件后：

```sh
git clone https://github.com/iceqi/mail-union-downloads.git
cd mail-union-downloads
cp .env.example .env
sh deploy.sh
```

打开 http://127.0.0.1:3210，填写服务端地址、AK（Client Key）与 SK（Client Secret）登录。Docker 与桌面版使用相同界面。侧栏底部的“退出登录”返回配对页，可重新填写服务端地址、AK 与 SK，已有邮箱数据保留。Docker 关闭或退出网页不会停止后台任务；重新配对成功后，后台切换到新连接。

镜像：`ghcr.io/iceqi/mail-union-client:latest`，支持 Linux amd64 与 arm64；无需下载源码或本地编译。

- 默认只监听本机；远程访问请配置 HTTPS 反向代理，并将 `MAILU_COOKIE_SECURE` 设为 `true`。
- `MAILU_BIND=0.0.0.0` 可开放网卡监听，需自行限制访问范围。
- 容器内访问宿主机服务或代理，使用 `host.docker.internal`，而非 `127.0.0.1`。
- 邮箱与配置保存在 `client-data` 数据卷；升级时保留该卷。`docker compose down -v` 会删除数据。
- 同一 Client Key（AK）只允许一个常驻客户端在线；新端登录会让旧端下线并停止自动重连。Windows、Mac 和 Docker 同样适用；多台客户端同时运行请分别创建不同的 AK。

## 升级

```sh
docker compose pull
docker compose up -d
```

## 服务端一键部署

安装并启动 Docker（含 Compose v2）后执行：

```sh
curl -fsSL https://raw.githubusercontent.com/iceqi/mail-union-downloads/main/server/deploy.sh | sh
```

脚本默认在当前目录创建 `mailu-server/`，拉取成品镜像、生成随机管理员初始密码、启动并等待健康检查。默认业务监听 `0.0.0.0:3100`，管理后台监听 `0.0.0.0:3101`，完成后访问 `http://服务器IP:3101`。管理员用户名与初始密码位于部署目录的 `.env`，登录后绑定 2FA。

指定目录和端口：

```sh
curl -fsSL https://raw.githubusercontent.com/iceqi/mail-union-downloads/main/server/deploy.sh -o /tmp/mailu-server-deploy.sh
MAILU_INSTALL_DIR=/opt/mailu-server MAILU_PORT=3100 sh /tmp/mailu-server-deploy.sh
```

已有 `.env` 会保留；配置修改请编辑该文件。公网使用 HTTPS 反向代理；客户端连接和邮件 API 使用业务端口 3100，管理后台使用独立端口 3101；反向代理分别配置业务域名和管理域名。部署细节、升级和备份见 [服务端部署说明](server/README.md)。
