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
  // 每 5 秒静默刷新一次待处理计数，让角标接近即时同步
  pendingTimer = window.setInterval(refreshPending, 5000)
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
  width: 216px;
  flex-shrink: 0;
  position: sticky;
  top: 0;
  height: 100vh;
  overflow-y: auto;
  background: linear-gradient(180deg, #28221e 0%, #211c18 100%);
  color: #fff;
  padding: 20px 14px;
}
.logo {
  display: flex;
  align-items: center;
  gap: 9px;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.02em;
  margin-bottom: 20px;
  padding: 0 8px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}
.logo::before {
  content: '';
  width: 10px;
  height: 10px;
  border-radius: 3px;
  background: var(--primary);
  box-shadow: 0 0 10px rgba(232, 99, 58, 0.6);
  flex-shrink: 0;
}
nav {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
nav a {
  display: block;
  position: relative;
  color: #b3aaa1;
  text-decoration: none;
  padding: 10px 12px;
  border-radius: 10px;
  font-size: 14px;
  transition:
    background var(--duration) var(--ease),
    color var(--duration) var(--ease);
}
nav a:hover {
  background: rgba(255, 255, 255, 0.07);
  color: #fff;
}
nav a .badge {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  min-width: 19px;
  height: 19px;
  padding: 0 6px;
  border-radius: 999px;
  background: var(--danger);
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  line-height: 19px;
  text-align: center;
  box-sizing: border-box;
  font-variant-numeric: tabular-nums;
}
nav a.router-link-active {
  background: var(--primary);
  color: #fff;
  font-weight: 600;
  box-shadow: 0 4px 14px rgba(232, 99, 58, 0.38);
}
nav a.router-link-active .badge {
  background: rgba(255, 255, 255, 0.24);
}
main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}
header {
  height: 56px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: rgba(255, 255, 255, 0.86);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 0.01em;
}
header button {
  border: 1px solid var(--border);
  background: var(--surface);
  color: var(--text);
  border-radius: 10px;
  padding: 7px 15px;
  font-size: 13px;
  cursor: pointer;
  transition:
    background var(--duration) var(--ease),
    border-color var(--duration) var(--ease),
    color var(--duration) var(--ease);
}
header button:hover {
  background: var(--surface-muted);
  border-color: var(--border-strong);
}
.header-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}
.lang-btn {
  font-weight: 600;
  color: var(--primary);
  background: var(--primary-weak);
  border-color: transparent !important;
}
.lang-btn:hover {
  background: #ffe4d6 !important;
}
.content {
  padding: 24px;
  flex: 1;
}
</style>
