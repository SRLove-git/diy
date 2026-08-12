import { reactive } from 'vue'
import http from '../api/http'

export type AdminRole = 'super_admin' | 'operator' | 'moderator' | 'auditor'

/** 与后端 common/admin-permissions.ts 一一对应的权限点 */
export const PERMISSIONS = {
  DASHBOARD_VIEW: 'dashboard.view',
  STORES_MANAGE: 'stores.manage',
  ORDERS_MANAGE: 'orders.manage',
  ACTIVITIES_MANAGE: 'activities.manage',
  USERS_MANAGE: 'users.manage',
  MEMBERS_MANAGE: 'members.manage',
  NOTIFICATIONS_MANAGE: 'notifications.manage',
  CONTENT_MODERATION: 'content.moderation',
  AUDIT_VIEW: 'audit.view',
  ADMIN_MANAGE: 'admin.manage',
} as const

const ROLE_PERMISSIONS: Record<AdminRole, readonly string[]> = {
  super_admin: ['*'],
  operator: [
    PERMISSIONS.DASHBOARD_VIEW,
    PERMISSIONS.STORES_MANAGE,
    PERMISSIONS.ORDERS_MANAGE,
    PERMISSIONS.ACTIVITIES_MANAGE,
    PERMISSIONS.USERS_MANAGE,
    PERMISSIONS.MEMBERS_MANAGE,
    PERMISSIONS.NOTIFICATIONS_MANAGE,
  ],
  moderator: [PERMISSIONS.DASHBOARD_VIEW, PERMISSIONS.CONTENT_MODERATION],
  auditor: [PERMISSIONS.DASHBOARD_VIEW, PERMISSIONS.AUDIT_VIEW],
}

export interface AdminMe {
  id: number
  username: string | null
  nickname: string
  role: string
  adminRole: AdminRole | null
}

/** 管理后台登录态（token 存 localStorage）+ 当前管理员信息与角色权限 */
export const auth = reactive({
  token: localStorage.getItem('admin_token') || '',
  me: null as AdminMe | null,
  get loggedIn() {
    return !!this.token
  },
  setToken(token: string) {
    this.token = token
    localStorage.setItem('admin_token', token)
  },
  /** 拉取当前管理员信息（含 adminRole），用于菜单与路由权限 */
  async refreshMe(): Promise<AdminMe> {
    const { data } = await http.get('/auth/me')
    this.me = data
    return data
  },
  hasPermission(permission: string): boolean {
    const role = this.me?.adminRole
    if (!role) return false
    const granted = ROLE_PERMISSIONS[role]
    if (!granted) return false
    return granted.includes('*') || granted.includes(permission)
  },
  clear() {
    this.token = ''
    this.me = null
    localStorage.removeItem('admin_token')
  },
})
