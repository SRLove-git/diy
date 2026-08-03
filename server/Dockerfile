# ---- 构建阶段 ----
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- 运行阶段 ----
FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist
# 聊天图片上传目录（compose 挂载持久卷 /app/uploads）
RUN mkdir -p /app/uploads
EXPOSE 3000
CMD ["node", "dist/main.js"]
