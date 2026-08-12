# syntax=docker/dockerfile:1.7

# ---- 构建阶段 ----
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
# --mount=type=cache 复用 npm 缓存，重复构建大幅提速
RUN --mount=type=cache,target=/root/.npm \
    npm ci --no-audit --no-fund
COPY . .
RUN npm run build

# ---- 运行阶段：Nginx 托管静态资源并代理 /api ----
FROM nginx:alpine AS runtime
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
