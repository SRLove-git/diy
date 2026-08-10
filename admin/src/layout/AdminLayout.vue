<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
import { auth } from '../stores/auth'
import { i18n } from '../i18n'

const router = useRouter()
const route = useRoute()

function logout() {
  auth.clear()
  router.push('/login')
}
</script>

<template>
  <div class="layout">
    <aside>
      <div class="logo">{{ $t('Think Origin · 后台', 'Think Origin · Admin') }}</div>
      <nav>
        <RouterLink to="/dashboard">{{ $t('数据看板', 'Dashboard') }}</RouterLink>
        <RouterLink to="/stores">{{ $t('门店管理', 'Stores') }}</RouterLink>
        <RouterLink to="/activities">{{ $t('活动管理', 'Activities') }}</RouterLink>
        <RouterLink to="/orders">{{ $t('订单管理', 'Orders') }}</RouterLink>
        <!-- 社区 / Reels 前期暂不开放，管理入口先隐藏 -->
        <!-- <RouterLink to="/posts">{{ $t('社区管理', 'Posts') }}</RouterLink> -->
        <!-- <RouterLink to="/videos">{{ $t('视频管理', 'Videos') }}</RouterLink> -->
        <!-- Reels 前期暂不开放，曲库管理入口先隐藏 -->
        <!-- <RouterLink to="/music">{{ $t('曲库管理', 'Music') }}</RouterLink> -->
        <RouterLink to="/users">{{ $t('用户管理', 'Users') }}</RouterLink>
        <RouterLink to="/members">{{ $t('会员运营', 'Members') }}</RouterLink>
        <RouterLink to="/notifications">{{ $t('通知管理', 'Notifications') }}</RouterLink>
      </nav>
    </aside>
    <main>
      <header>
        <span>
          {{
            $t(
              String(route.meta.title || '后台管理'),
              String(route.meta.titleEn || 'Admin'),
            )
          }}
        </span>
        <div class="header-actions">
          <button class="lang-btn" @click="i18n.toggle()">
            {{ i18n.lang === 'zh' ? '中文' : 'English' }}
          </button>
          <button @click="logout">{{ $t('退出登录', 'Log out') }}</button>
        </div>
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
.header-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}
.lang-btn {
  font-weight: 600;
}
.content {
  padding: 20px;
  flex: 1;
}
</style>
