#!/bin/sh
# MySQL + Redis 每日备份脚本（容器内由 cron 调用，启动时也会执行一次）
# 产物：/backups/mysql-<时间戳>.sql.gz、/backups/redis-<时间戳>.rdb.gz
# 成功后更新时间戳 /backups/.last-success，供健康检查判定“备份是否新鲜”
set -eu

BACKUP_DIR="${BACKUP_DIR:-/backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
MYSQL_HOST="${MYSQL_HOST:-mysql}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_DATABASE="${MYSQL_DATABASE:-diy}"
REDIS_HOST="${REDIS_HOST:-redis}"
REDIS_PORT="${REDIS_PORT:-6379}"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"
# 清理上次失败遗留的临时文件
rm -f "$BACKUP_DIR"/.mysql-* "$BACKUP_DIR"/.redis-*

echo "[backup] $(date -Is) 开始：MySQL dump + Redis RDB 快照"

# ---- MySQL：单事务一致性快照，不锁表；含存储过程/触发器/事件 ----
# MariaDB 客户端兼容 mysqldump 参数；用 MYSQL_PWD 避免密码出现在进程列表
DUMP_BIN="$(command -v mysqldump || command -v mariadb-dump)"
TMP_SQL="$BACKUP_DIR/.mysql-$STAMP.sql"
MYSQL_PWD="${MYSQL_PASSWORD:-}" "$DUMP_BIN" \
  -h "$MYSQL_HOST" -u "$MYSQL_USER" \
  --skip-ssl \
  --single-transaction --routines --triggers --events --hex-blob \
  "$MYSQL_DATABASE" > "$TMP_SQL"
gzip "$TMP_SQL"
mv "$TMP_SQL.gz" "$BACKUP_DIR/mysql-$STAMP.sql.gz"

# ---- Redis：--rdb 直接从服务器拉一致性快照（无需挂载 redis 数据卷） ----
TMP_RDB="$BACKUP_DIR/.redis-$STAMP.rdb"
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" --rdb "$TMP_RDB" >/dev/null 2>&1
gzip "$TMP_RDB"
mv "$TMP_RDB.gz" "$BACKUP_DIR/redis-$STAMP.rdb.gz"

# ---- 保留 N 天，自动清理过期备份 ----
find "$BACKUP_DIR" -maxdepth 1 -name 'mysql-*.sql.gz' -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_DIR" -maxdepth 1 -name 'redis-*.rdb.gz' -mtime +"$RETENTION_DAYS" -delete

date +%s > "$BACKUP_DIR/.last-success"
echo "[backup] $(date -Is) 完成：mysql-$STAMP.sql.gz / redis-$STAMP.rdb.gz"
