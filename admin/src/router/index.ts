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
        { path: '', redirect: '/stores' },
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
      ],
    },
  ],
})

router.beforeEach((to) => {
  if (to.path !== '/login' && !auth.loggedIn) return '/login'
  if (to.path === '/login' && auth.loggedIn) return '/'
})

export default router
