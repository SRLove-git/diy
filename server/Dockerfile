# ---- 构建阶段 ----
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# 容器内跳过类型检查编译（tsc --noCheck）：小配置服务器全量类型检查极慢（10-30 分钟甚至 OOM）
# 本地开发仍用 npm run build 保留完整类型检查
RUN npx tsc -p tsconfig.build.json --noCheck

# ---- 运行阶段 ----
FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN apk add --no-cache ffmpeg
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist
# 曲库配乐与演示短视频资产（混音与演示数据需要）
COPY assets ./assets
# 聊天图片上传目录（compose 挂载持久卷 /app/uploads）
RUN mkdir -p /app/uploads
EXPOSE 3000
CMD ["node", "dist/main.js"]
