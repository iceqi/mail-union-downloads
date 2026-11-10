# MailU 服务端更新记录

## v0.1.5（2026-11-10）

- 创建客户端和续期时可选长期有效、1 周、1 个月、1 年或自定义日期时间。已有客户端默认长期有效。
- 到期后服务端停止接受该客户端的请求，并断开在线连接。搭配 MailU 客户端 v0.1.4 可在仪表盘查看到期时间，到期时自动返回登录页。
- 业务端口的 `/docs/` 提供公开 API 文档；管理端的验证码解析规则库设有独立入口和规则详情。

已有部署在原目录执行 `docker compose pull && docker compose up -d`，保留 `.env` 和数据卷。建议先升级服务端，再安装 [MailU 客户端 v0.1.4](https://github.com/iceqi/mail-union-downloads/releases/tag/v0.1.4)。

固定版本镜像：`ghcr.io/iceqi/mail-union-server:v0.1.5`；一键部署默认使用 `latest`。查看 [一键部署验证](https://github.com/iceqi/mail-union-downloads/actions/runs/42804371614)。

## v0.1.4（2026-11-10）

- AI 同次返回验证码、中文规则名称和可复用提取规则，经原邮件校验后按实际发件人保存；规则经两个不同验证码样本确认后自动启用。
- 后续优先使用已确认规则，未匹配再调用 AI；后台智能识别页面增加规则库名称、发件邮箱、样本数、匹配次数及启停。
- AI 提示词下展示不可编辑的固定追加文字，约束规则生成和 JSON 返回结构。增值服务积分与请求幂等方式保持兼容。
- 管理后台与客户端业务拆分端口：业务端口 3100，管理端口 3101；修正管理登录中文文案，支持验证旧密码后修改管理员密码。

### 已有部署升级

在原来的部署目录执行以下命令，保留原 `.env` 和数据卷：

```sh
curl -fsSL https://raw.githubusercontent.com/iceqi/mail-union-downloads/main/server/compose.yaml -o compose.yaml
docker compose pull
docker compose up -d
```

访问管理后台 `http://服务器IP:3101`；客户端与邮件 API 继续使用业务端口 3100。容器需要新增 3101 的端口映射，反向代理的管理入口改为指向 3101，业务入口仍指向 3100。如果原来使用同一域名，应为管理后台增加单独域名或入口。已有账号、两步验证、积分和邮箱数据保留。

固定版本镜像：`ghcr.io/iceqi/mail-union-server:v0.1.4`；默认一键部署使用 `latest`。本次只更新服务端，桌面和 Docker 客户端无需升级。

验证记录：[v0.1.4 一键部署检查](https://github.com/iceqi/mail-union-downloads/actions/runs/42776629396) 已通过，覆盖匿名安装、双端口隔离、管理员登录、规则库和重启更新后的数据保留。
