import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    // 开发期将 /api 代理到后端（NestJS，同端口 3000）
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
      // 开发期封面/媒体预览：uploads 静态资源由后端同源托管
      '/uploads': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
      // 开发期种子曲库音频（/assets/music）由后端托管
      '/assets': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },
})
