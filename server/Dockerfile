# syntax=docker/dockerfile:1.7

# ---- 生产依赖：独立 stage，运行阶段直接复用，避免第二次 npm ci ----
FROM node:22-alpine AS deps
WORKDIR /app
COPY package*.json ./
# --mount=type=cache 复用本机 npm 缓存，重复构建大幅提速
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev --no-audit --no-fund

# ---- 构建阶段 ----
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --no-audit --no-fund
COPY . .
# 容器内跳过类型检查编译（tsc --noCheck）：小配置服务器全量类型检查极慢（10-30 分钟甚至 OOM）
# 本地开发仍用 npm run build 保留完整类型检查
RUN ./node_modules/.bin/tsc -p tsconfig.build.json --noCheck

# ---- 运行阶段 ----
FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN apk add --no-cache ffmpeg
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
# 曲库配乐与演示短视频资产（混音与演示数据需要）
COPY assets ./assets
# 聊天图片上传目录（compose 挂载持久卷 /app/uploads）
RUN mkdir -p /app/uploads
EXPOSE 3000
CMD ["node", "dist/main.js"]
