import { createRouter, createWebHashHistory } from 'vue-router'
import { auth } from '../stores/auth'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    { path: '/login', component: () => import('../views/LoginView.vue') },
    {
      path: '/',
      component: () => import('../layout/AdminLayout.vue'),
      children: [
        { path: '', redirect: '/dashboard' },
        {
          path: 'dashboard',
          component: () => import('../views/DashboardView.vue'),
          meta: { title: '数据看板', titleEn: 'Dashboard' },
        },
        {
          path: 'admins',
          component: () => import('../views/AdminAccountsView.vue'),
          meta: {
            title: '管理员账号',
            titleEn: 'Admin Accounts',
            permission: 'admin.manage',
          },
        },
        {
          path: 'stores',
          component: () => import('../views/StoresView.vue'),
          meta: { title: '门店管理', titleEn: 'Stores' },
        },
        {
          path: 'moderation',
          component: () => import('../views/ModerationView.vue'),
          meta: {
            title: '内容审核',
            titleEn: 'Moderation',
            permission: 'content.moderation',
          },
        },
        {
          path: 'audit-logs',
          component: () => import('../views/AuditLogsView.vue'),
          meta: {
            title: '审计日志',
            titleEn: 'Audit Logs',
            permission: 'audit.view',
          },
        },
        {
          path: 'tables',
          component: () => import('../views/TablesView.vue'),
          meta: { title: '桌位看板', titleEn: 'Table Board' },
        },
        {
          path: 'activities',
          component: () => import('../views/ActivitiesView.vue'),
          meta: { title: '活动管理', titleEn: 'Activities' },
        },
        {
          path: 'orders',
          component: () => import('../views/OrdersView.vue'),
          meta: { title: '订单管理', titleEn: 'Orders' },
        },
        {
          path: 'posts',
          component: () => import('../views/PostsView.vue'),
          meta: {
            title: '社区管理',
            titleEn: 'Posts',
            permission: 'content.moderation',
          },
        },
        {
          path: 'videos',
          component: () => import('../views/VideosView.vue'),
          meta: {
            title: '视频管理',
            titleEn: 'Videos',
            permission: 'content.moderation',
          },
        },
        {
          path: 'music',
          component: () => import('../views/MusicView.vue'),
          meta: {
            title: '曲库管理',
            titleEn: 'Music',
            permission: 'content.moderation',
          },
        },
        {
          path: 'users',
          component: () => import('../views/UsersView.vue'),
          meta: { title: '用户管理', titleEn: 'Users' },
        },
        {
          path: 'alerts',
          component: () => import('../views/AlertsView.vue'),
          meta: { title: '通知中心', titleEn: 'Alert Center' },
        },
        {
          path: 'notifications',
          component: () => import('../views/NotificationsView.vue'),
          meta: { title: '通知管理', titleEn: 'Notifications' },
        },
        {
          path: 'members',
          component: () => import('../views/MembersView.vue'),
          meta: { title: '会员运营', titleEn: 'Members' },
        },
      ],
    },
  ],
})

router.beforeEach(async (to) => {
  if (to.path !== '/login' && !auth.loggedIn) return '/login'
  if (to.path === '/login' && auth.loggedIn) return '/'
  // 有 token 但尚未加载管理员信息时先拉取（含刷新页面场景）
  if (to.path !== '/login' && auth.loggedIn && !auth.me) {
    try {
      await auth.refreshMe()
    } catch {
      return '/login'
    }
  }
  // 角色权限校验：无权限跳回看板（看板对所有管理角色开放）
  const permission = to.meta.permission as string | undefined
  if (permission && !auth.hasPermission(permission)) {
    return '/dashboard'
  }
  return true
})

export default router
