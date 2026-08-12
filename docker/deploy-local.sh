#!/usr/bin/env bash
#
# 本地构建镜像 → 打包 → 传输 → 服务器加载运行（服务器不做构建）
#
# 用法：
#   ./docker/deploy-local.sh arm64     # 服务器是 arm64（与本机同架构）
#   ./docker/deploy-local.sh amd64     # 服务器是 x86_64（默认，buildx 交叉构建）
#
# 脚本只负责构建 + 打包，传输与服务器命令会在最后打印出来，复制执行即可。
set -euo pipefail
cd "$(dirname "$0")/.."

SERVER_ARCH="${1:-amd64}"
LOCAL_ARCH="$(uname -m)"
IMAGE_TAG="diy-$(date +%Y%m%d%H%M%S)"

echo "==> 本机构建架构: $LOCAL_ARCH / 目标服务器架构: $SERVER_ARCH / 镜像 tag: $IMAGE_TAG"

if [ "$SERVER_ARCH" = "amd64" ] && [ "$LOCAL_ARCH" = "arm64" ]; then
  # Apple Silicon 交叉构建 linux/amd64（依赖 Docker Desktop 的 buildx + QEMU，构建较慢）
  echo "==> buildx 交叉构建 linux/amd64 ..."
  docker buildx build --platform linux/amd64 --load -t "diy-server:$IMAGE_TAG" server
  docker buildx build --platform linux/amd64 --load -t "diy-admin:$IMAGE_TAG" admin
  docker buildx build --platform linux/amd64 --load -t "diy-backup:$IMAGE_TAG" docker/backup
elif [ "$SERVER_ARCH" = "$LOCAL_ARCH" ]; then
  # 同架构：直接用 compose 构建（image 名由环境变量注入）
  echo "==> docker compose build ..."
  SERVER_IMAGE="diy-server:$IMAGE_TAG" ADMIN_IMAGE="diy-admin:$IMAGE_TAG" \
    BACKUP_IMAGE="diy-backup:$IMAGE_TAG" \
    docker compose -f docker/compose.prod.yml build server admin backup
else
  echo "!! 暂不支持 $LOCAL_ARCH → $SERVER_ARCH 的交叉组合，请改用镜像仓库（registry）推送"
  exit 1
fi

echo "==> docker save + gzip ..."
docker save "diy-server:$IMAGE_TAG" "diy-admin:$IMAGE_TAG" "diy-backup:$IMAGE_TAG" \
  | gzip > "docker/images-$IMAGE_TAG.tar.gz"

echo
echo "已生成: docker/images-$IMAGE_TAG.tar.gz"
echo
echo "================ 接下来在本地执行 ================"
echo "scp docker/images-$IMAGE_TAG.tar.gz <用户>@<服务器IP>:/opt/diy/"
echo
echo "================ 然后在服务器上执行 ================"
echo "cd /opt/diy"
echo "docker load -i images-$IMAGE_TAG.tar.gz"
echo "SERVER_IMAGE=diy-server:$IMAGE_TAG ADMIN_IMAGE=diy-admin:$IMAGE_TAG \\"
echo "  BACKUP_IMAGE=diy-backup:$IMAGE_TAG \\"
echo "  docker compose -f docker/compose.prod.yml up -d --no-build --scale server=3"
echo "===================================================="
