#!/bin/sh
set -eu

BACKUP_DIR="${BACKUP_DIR:-/backups}"
CRON_EXPR="${BACKUP_CRON:-0 3 * * *}"
mkdir -p "$BACKUP_DIR"

# busybox crond 从 /etc/crontabs/root 读取任务
echo "$CRON_EXPR /backup.sh" > /etc/crontabs/root

# 启动时先备份一次（compose 的 depends_on 已保证 MySQL/Redis 就绪）；
# 失败不退出容器，交给每日 cron 与健康检查兜底
/backup.sh || echo "[entrypoint] 启动备份失败，容器继续运行，由 cron 重试" >&2

exec crond -f -l 8
