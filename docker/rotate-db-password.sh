#!/usr/bin/env bash
#
# 安全轮换 MySQL root 密码（生产）
#
# 用法：
#   ./docker/rotate-db-password.sh               # 自动生成随机密码
#   ./docker/rotate-db-password.sh NewPass123    # 指定新密码（建议字母数字，勿含单引号）
#
# 为什么要这个脚本：MySQL 数据卷初始化后，compose 里的 MYSQL_ROOT_PASSWORD
# 环境变量不再生效。只改 docker/.env 的 DB_PASSWORD 会导致应用连不上库、
# 容器健康检查失败。正确顺序是：先在容器内 ALTER USER 改密，再同步 .env，
# 最后重建 mysql/server 容器让新密码生效。
#
# 注意：备份账号（BACKUP_DB_USER / BACKUP_DB_PASSWORD）是独立低权限账号，不受影响。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
COMPOSE_FILE="$SCRIPT_DIR/compose.prod.yml"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "错误：未找到 $ENV_FILE（请先 cp docker/.env.example docker/.env 并填好 DB_PASSWORD）" >&2
  exit 1
fi

CURRENT="$(grep '^DB_PASSWORD=' "$ENV_FILE" | tail -1 | cut -d= -f2-)"
if [[ -z "$CURRENT" ]]; then
  echo "错误：$ENV_FILE 中未配置 DB_PASSWORD" >&2
  exit 1
fi

NEW="${1:-}"
if [[ -z "$NEW" ]]; then
  NEW="$(openssl rand -hex 16)"
  echo "已自动生成新密码：$NEW"
fi
if [[ "$NEW" == *"'"* ]]; then
  echo "错误：新密码不能包含单引号" >&2
  exit 1
fi

echo "==> 1/3 容器内执行改密（root@% 与 root@localhost）"
docker compose -f "$COMPOSE_FILE" exec -T -e MYSQL_PWD="$CURRENT" mysql \
  mysql -uroot <<SQL
ALTER USER 'root'@'%' IDENTIFIED BY '$NEW';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW';
FLUSH PRIVILEGES;
SQL

echo "==> 2/3 备份并更新 docker/.env"
cp "$ENV_FILE" "$ENV_FILE.bak.$(date +%Y%m%d-%H%M%S)"
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/^DB_PASSWORD=.*/DB_PASSWORD=$NEW/" "$ENV_FILE"
else
  sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$NEW/" "$ENV_FILE"
fi

echo "==> 3/3 重建 mysql/server 容器使新密码生效（数据卷不受影响）"
docker compose -f "$COMPOSE_FILE" up -d --force-recreate mysql server

echo "完成。检查状态："
docker compose -f "$COMPOSE_FILE" ps --format 'table {{.Name}}\t{{.Status}}' mysql server
