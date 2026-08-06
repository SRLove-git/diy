<script setup lang="ts">
import { useRouter } from 'vue-router'
import { auth } from '../stores/auth'

const router = useRouter()

function logout() {
  auth.clear()
  router.push('/login')
}
</script>

<template>
  <div class="layout">
    <aside>
      <div class="logo">DIY 手作工坊 · 后台</div>
      <nav>
        <RouterLink to="/dashboard">数据看板</RouterLink>
        <RouterLink to="/stores">门店管理</RouterLink>
        <RouterLink to="/activities">活动管理</RouterLink>
        <RouterLink to="/orders">订单管理</RouterLink>
        <RouterLink to="/posts">社区管理</RouterLink>
        <RouterLink to="/videos">视频管理</RouterLink>
        <RouterLink to="/music">曲库管理</RouterLink>
        <RouterLink to="/users">用户管理</RouterLink>
        <RouterLink to="/members">会员运营</RouterLink>
        <RouterLink to="/notifications">通知管理</RouterLink>
      </nav>
    </aside>
    <main>
      <header>
        <span>{{ $route.meta.title || '后台管理' }}</span>
        <button @click="logout">退出登录</button>
      </header>
      <div class="content">
        <RouterView />
      </div>
    </main>
  </div>
</template>

<style scoped>
.layout {
  display: flex;
  min-height: 100vh;
}
aside {
  width: 200px;
  background: #2b2b2b;
  color: #fff;
  padding: 16px;
}
.logo {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 24px;
}
nav a {
  display: block;
  color: #ddd;
  text-decoration: none;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 14px;
}
nav a.router-link-active {
  background: #e8633a;
  color: #fff;
}
main {
  flex: 1;
  display: flex;
  flex-direction: column;
}
header {
  height: 52px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  background: #fff;
  border-bottom: 1px solid #eceae6;
  font-size: 14px;
}
header button {
  border: 1px solid #eceae6;
  background: #fff;
  border-radius: 8px;
  padding: 6px 14px;
  cursor: pointer;
}
.content {
  padding: 20px;
  flex: 1;
}
</style>
