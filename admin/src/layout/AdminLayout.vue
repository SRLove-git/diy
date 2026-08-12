<script setup lang="ts">
import { onMounted, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { auth } from '../stores/auth'
import { badgeText, pending, pendingTotal, refreshPending } from '../stores/pending'
import { i18n } from '../i18n'

const router = useRouter()
const route = useRoute()
let pendingTimer: number | undefined

function logout() {
  auth.clear()
  router.push('/login')
}

onMounted(() => {
  refreshPending()
  // 每 30 秒静默刷新一次待处理计数，保持角标与通知中心同步
  pendingTimer = window.setInterval(refreshPending, 30000)
})

onUnmounted(() => {
  if (pendingTimer) clearInterval(pendingTimer)
})

// 切换页面后立即刷新一次（例如在订单页确认后回到其他页）
watch(() => route.path, refreshPending)
</script>

<template>
  <div class="layout">
    <aside>
      <div class="logo">{{ $t('Think Origin · 后台', 'Think Origin · Admin') }}</div>
      <nav>
        <RouterLink to="/dashboard">{{ $t('数据看板', 'Dashboard') }}</RouterLink>
        <RouterLink v-if="auth.hasPermission('admin.manage')" to="/admins">
          {{ $t('管理员账号', 'Admin Accounts') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('stores.manage')" to="/stores">
          {{ $t('门店管理', 'Stores') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('content.moderation')" to="/moderation">
          <span>{{ $t('内容审核', 'Moderation') }}</span>
          <span v-if="pending.posts + pending.videos > 0" class="badge">
            {{ badgeText(pending.posts + pending.videos) }}
          </span>
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('orders.manage')" to="/tables">
          {{ $t('桌位看板', 'Table Board') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('activities.manage')" to="/activities">
          {{ $t('活动管理', 'Activities') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('orders.manage')" to="/orders">
          <span>{{ $t('订单管理', 'Orders') }}</span>
          <span v-if="pending.appointments" class="badge">{{ badgeText(pending.appointments) }}</span>
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('content.moderation')" to="/posts">
          {{ $t('社区管理', 'Posts') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('content.moderation')" to="/videos">
          {{ $t('视频管理', 'Videos') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('content.moderation')" to="/music">
          {{ $t('曲库管理', 'Music') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('users.manage')" to="/users">
          {{ $t('用户管理', 'Users') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('members.manage')" to="/members">
          <span>{{ $t('会员运营', 'Members') }}</span>
          <span v-if="pending.memberOrders" class="badge">{{ badgeText(pending.memberOrders) }}</span>
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('notifications.manage')" to="/alerts" class="alerts-link">
          <span>{{ $t('通知中心', 'Alert Center') }}</span>
          <span v-if="pendingTotal()" class="badge">{{ badgeText(pendingTotal()) }}</span>
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('notifications.manage')" to="/notifications">
          {{ $t('通知管理', 'Notifications') }}
        </RouterLink>
        <RouterLink v-if="auth.hasPermission('audit.view')" to="/audit-logs">
          {{ $t('审计日志', 'Audit Logs') }}
        </RouterLink>
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
  position: relative;
  color: #ddd;
  text-decoration: none;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 14px;
}
nav a .badge {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  min-width: 18px;
  height: 18px;
  padding: 0 5px;
  border-radius: 999px;
  background: #d9453e;
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  line-height: 18px;
  text-align: center;
  box-sizing: border-box;
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
