#!/bin/sh
set -eu
cd "$(dirname "$0")"
if [ ! -f .env ]; then cp .env.example .env; fi
docker compose pull
docker compose up -d
printf '\nMailU 已启动。默认访问 http://127.0.0.1:3210，使用服务端地址、AK 和 SK 登录。\n'
