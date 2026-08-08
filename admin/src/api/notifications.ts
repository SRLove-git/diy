import http from './http'

export interface NotificationTemplate {
  id: number
  name: string
  titleTemplate: string
  contentTemplate: string
  category: 'system' | 'booking' | 'community' | 'activity'
  enabled: boolean
  createdAt: string
  updatedAt: string
}

export interface Notification {
  id: number
  title: string
  content: string
  targetType: 'all' | 'role' | 'user'
  targetRole: 'user' | 'admin' | null
  targetUserIds: string
  channels: string
  sent: boolean
  sentAt: string | null
  createdAt: string
}

export const notificationApi = {
  // 通知
  list: (params?: { page?: number; pageSize?: number }) =>
    http.get('/admin/notifications', { params }).then((r) => r.data),

  send: (body: {
    title: string
    content: string
    targetType: 'all' | 'role' | 'user'
    targetRole?: 'user' | 'admin'
    targetUserIds?: string
    channels?: string
  }) => http.post('/admin/notifications', body).then((r) => r.data),

  remove: (id: number) => http.delete(`/admin/notifications/${id}`).then((r) => r.data),

  getTargetUsers: (body: {
    targetType: 'all' | 'role' | 'user'
    targetRole?: string
    targetUserIds?: string
  }) => http.post('/admin/notifications/target-users', body).then((r) => r.data),

  // 模板
  listTemplates: () =>
    http.get('/admin/notifications/templates').then((r) => r.data),

  createTemplate: (body: {
    name: string
    titleTemplate: string
    contentTemplate: string
    category: 'system' | 'booking' | 'community' | 'activity'
  }) => http.post('/admin/notifications/templates', body).then((r) => r.data),

  updateTemplate: (id: number, body: Partial<NotificationTemplate>) =>
    http.patch(`/admin/notifications/templates/${id}`, body).then((r) => r.data),

  removeTemplate: (id: number) =>
    http.delete(`/admin/notifications/templates/${id}`).then((r) => r.data),
}
