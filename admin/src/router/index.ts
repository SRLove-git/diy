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
          path: 'stores',
          component: () => import('../views/StoresView.vue'),
          meta: { title: '门店管理', titleEn: 'Stores' },
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
        // 社区 / Reels 前期暂不开放，路由先注释（恢复时取消注释）
        // {
        //   path: 'posts',
        //   component: () => import('../views/PostsView.vue'),
        //   meta: { title: '社区管理', titleEn: 'Posts' },
        // },
        // {
        //   path: 'videos',
        //   component: () => import('../views/VideosView.vue'),
        //   meta: { title: '视频管理', titleEn: 'Videos' },
        // },
        // Reels 前期暂不开放，曲库路由先注释（恢复时取消注释）
        // {
        //   path: 'music',
        //   component: () => import('../views/MusicView.vue'),
        //   meta: { title: '曲库管理', titleEn: 'Music' },
        // },
        {
          path: 'users',
          component: () => import('../views/UsersView.vue'),
          meta: { title: '用户管理', titleEn: 'Users' },
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

router.beforeEach((to) => {
  if (to.path !== '/login' && !auth.loggedIn) return '/login'
  if (to.path === '/login' && auth.loggedIn) return '/'
})

export default router
