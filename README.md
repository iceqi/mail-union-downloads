# 秒邮 MailU

MailUnion，简称 MailU。这里提供 Windows、macOS 安装包与 Docker 部署文件。

## 安装包下载

进入 [Releases 下载页面](https://github.com/iceqi/mail-union-downloads/releases/latest)，选择对应系统：

| 系统 | 安装包 |
| --- | --- |
| Windows x64 | `MailU_0.1.0_x64-setup.exe`，或 `.msi` |
| Apple Silicon Mac | `MailU_0.1.0_aarch64.dmg` |
| Intel Mac | `MailU_0.1.0_x64.dmg` |

下载后可使用同版本的 `SHA256SUMS.txt` 校验文件。

## Docker 部署

安装 Docker 与 Docker Compose 插件后：

```sh
git clone https://github.com/iceqi/mail-union-downloads.git
cd mail-union-downloads
cp .env.example .env
sh deploy.sh
```

打开 http://127.0.0.1:3210，填写服务端地址、AK（Client Key）与 SK（Client Secret）登录。Docker 与桌面版使用相同界面，关闭网页不会停止后台任务。

镜像：`ghcr.io/iceqi/mail-union-client:latest`，支持 Linux amd64 与 arm64；无需下载源码或本地编译。

- 默认只监听本机；远程访问请配置 HTTPS 反向代理，并将 `MAILU_COOKIE_SECURE` 设为 `true`。
- `MAILU_BIND=0.0.0.0` 可开放网卡监听，需自行限制访问范围。
- 容器内访问宿主机服务或代理，使用 `host.docker.internal`，而非 `127.0.0.1`。
- 邮箱与配置保存在 `client-data` 数据卷；升级时保留该卷。`docker compose down -v` 会删除数据。
- 同一 Client Key 使用一个常驻客户端，避免桌面版和 Docker 版同时连接。

## 升级

```sh
docker compose pull
docker compose up -d
```
