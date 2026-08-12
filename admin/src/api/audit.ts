import http from './http'

export interface AuditLog {
  id: number
  actorId: number | null
  action: string
  targetType: string | null
  targetId: string | null
  detail: Record<string, unknown> | null
  ip: string | null
  userAgent: string | null
  createdAt: string
  actor: { id: number; username: string | null; nickname: string } | null
}

export const auditApi = {
  list(params?: {
    page?: number
    pageSize?: number
    action?: string
    actor?: string
    from?: string
    to?: string
  }) {
    return http.get<[AuditLog[], number]>('/admin/audit', { params }).then((r) => r.data)
  },
  actions() {
    return http.get<string[]>('/admin/audit/actions').then((r) => r.data)
  },
}
