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
          meta: { title: '数据看板' },
        },
        {
          path: 'stores',
          component: () => import('../views/StoresView.vue'),
          meta: { title: '门店管理' },
        },
        {
          path: 'orders',
          component: () => import('../views/OrdersView.vue'),
          meta: { title: '订单管理' },
        },
        {
          path: 'posts',
          component: () => import('../views/PostsView.vue'),
          meta: { title: '作品审核' },
        },
        {
          path: 'users',
          component: () => import('../views/UsersView.vue'),
          meta: { title: '用户管理' },
        },
        {
          path: 'reports',
          component: () => import('../views/ReportsView.vue'),
          meta: { title: '举报处理' },
        },
        {
          path: 'notifications',
          component: () => import('../views/NotificationsView.vue'),
          meta: { title: '通知管理' },
        },
      ],
    },
  ],
})

router.beforeEach((to) => {
  if (to.path !== '/login' && !auth.loggedIn) return '/login'
  if (to.path === '/login' && auth.loggedIn) return '/'
})

export default router
