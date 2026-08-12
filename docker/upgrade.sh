#!/usr/bin/env bash
#
# 一键升级部署脚本（服务器源码构建方式）
#
# 流程：本地打包（强制排除 .env）→ 上传解压 → 校验服务器 .env 未被覆盖
#       → 升级前备份 → 服务器 docker compose up -d --build
#       → 健康检查 → 清理旧镜像（默认保留最近 3 个 tag）
#
# 镜像 tag 约定：diy-server:<日期>-<git短sha>（admin/backup 同 tag），
# 同时同步 :latest 保持 compose 默认可用；旧 tag 保留最近 N 个便于回滚。
#
# 用法：
#   ./docker/upgrade.sh root@<服务器IP>
#   KEEP_TAGS=5 ./docker/upgrade.sh root@<服务器IP>    # 保留最近 5 个 tag
#
# 依赖：git / tar / scp / ssh（服务器需可登录，密码或密钥均可）
set -euo pipefail

cd "$(dirname "$0")/.."          # 仓库根目录

SERVER="${1:?用法: ./docker/upgrade.sh root@<服务器IP>}"
KEEP_TAGS="${KEEP_TAGS:-3}"
REMOTE_DIR=/opt/diy
COMPOSE="docker compose -f docker/compose.prod.yml"

SHORT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo local)"
TAG="$(date +%Y%m%d)-${SHORT_SHA}"
PKG="/tmp/diy-update-${TAG}.tar.gz"

log() { printf '\n==> %s\n' "$*"; }

log "1/8 本地打包（TAG=${TAG}）"
tar -czf "$PKG" \
  --exclude='.git' --exclude='node_modules' --exclude='build' --exclude='dist' \
  --exclude='.dart_tool' --exclude='server/uploads' \
  --exclude='docker/backups' --exclude='docker/data' --exclude='.DS_Store' \
  --exclude='**/.env' \
  -C "$(pwd)" .

log "2/8 校验包内无 .env"
if tar -tzf "$PKG" | grep -E '(^|/)\.env$' >/dev/null; then
  echo '!! 包内包含 .env，已中止（防止覆盖服务器生产配置）' >&2
  rm -f "$PKG"
  exit 1
fi

log "3/8 记录服务器 .env 哈希"
OLD_HASH="$(ssh "$SERVER" "md5sum ${REMOTE_DIR}/docker/.env | awk '{print \$1}'")"

log "4/8 上传部署包 ${PKG}"
scp -q "$PKG" "$SERVER:/tmp/"

log "5/8 解压到服务器并删除远端临时包"
ssh "$SERVER" \
  "tar -xzf /tmp/$(basename "$PKG") -C ${REMOTE_DIR} && rm -f /tmp/$(basename "$PKG")"

log "6/8 校验解压后 .env 哈希一致"
NEW_HASH="$(ssh "$SERVER" "md5sum ${REMOTE_DIR}/docker/.env | awk '{print \$1}'")"
if [ "$OLD_HASH" != "$NEW_HASH" ]; then
  echo '!! 服务器 docker/.env 被改动，已中止' >&2
  exit 1
fi

log "7/8 升级前备份 + 构建部署（tag=${TAG}）"
ssh "$SERVER" \
  "cd ${REMOTE_DIR} && ${COMPOSE} exec backup /backup.sh | tail -1 && \
   SERVER_IMAGE=diy-server:${TAG} ADMIN_IMAGE=diy-admin:${TAG} \
   BACKUP_IMAGE=diy-backup:${TAG} ${COMPOSE} up -d --build"

log "同步 :latest 标签（保持 compose 默认可用）"
ssh "$SERVER" \
  "docker tag diy-server:${TAG} diy-server:latest && \
   docker tag diy-admin:${TAG} diy-admin:latest && \
   docker tag diy-backup:${TAG} diy-backup:latest"

log "等待健康检查（最多 150s）"
ssh "$SERVER" \
  "for i in \$(seq 1 30); do
     curl -fsS -m 5 http://127.0.0.1:3000/api/health && break
     sleep 5
   done"

log "8/8 清理旧镜像（保留最近 ${KEEP_TAGS} 个 tag）"
ssh "$SERVER" \
  "for repo in diy-server diy-admin diy-backup; do
     docker images --format '{{.Repository}}:{{.Tag}}|{{.CreatedAt}}' \
       | grep -E \"^\${repo}:\" \
       | grep -v ':latest' \
       | sort -t'|' -k2 \
       | head -n -${KEEP_TAGS} \
       | cut -d'|' -f1 \
       | xargs -r -n1 sh -c 'docker rmi \"\$0\" >/dev/null 2>&1 || true'
   done"

rm -f "$PKG"

log "完成：${TAG} 已上线。当前镜像列表："
ssh "$SERVER" \
  "docker images --format '{{.Repository}}:{{.Tag}} {{.Size}} {{.CreatedAt}}' \
   | grep -E '^(diy-server|diy-admin|diy-backup):' | sort"
