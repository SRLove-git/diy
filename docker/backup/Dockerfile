# syntax=docker/dockerfile:1.7
# 备份服务：cron 定时导出 MySQL + Redis 快照到 /backups（compose 挂载宿主机目录）
# 仅含数据库客户端与 busybox cron，镜像约 60~80MB
FROM redis:7-alpine

# 可选 apk 镜像源覆盖：国内/慢网络构建时传 --build-arg APK_MIRROR=mirrors.aliyun.com
ARG APK_MIRROR=dl-cdn.alpinelinux.org

# redis-cli 已内置；补 mariadb 客户端（提供 mysqldump/mariadb-dump）与时区数据
RUN if [ "$APK_MIRROR" != "dl-cdn.alpinelinux.org" ]; then \
      sed -i "s#dl-cdn.alpinelinux.org#$APK_MIRROR#g" /etc/apk/repositories; \
    fi && \
    apk add --no-cache mariadb-client tzdata

COPY backup.sh /backup.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /backup.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
