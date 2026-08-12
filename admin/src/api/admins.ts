import http from './http'

export type AdminRole = 'super_admin' | 'operator' | 'moderator' | 'auditor'

export interface AdminAccount {
  id: number
  username: string | null
  email: string | null
  nickname: string
  adminRole: AdminRole | null
  isBanned: boolean
  createdAt: string
  updatedAt: string
}

export const adminsApi = {
  list(params?: { page?: number; keyword?: string; pageSize?: number }) {
    return http.get<[AdminAccount[], number]>('/admin/admins', { params }).then((r) => r.data)
  },
  create(dto: {
    username: string
    email: string
    password: string
    adminRole: AdminRole
    nickname?: string
  }) {
    return http.post<AdminAccount>('/admin/admins', dto).then((r) => r.data)
  },
  update(
    id: number,
    dto: { adminRole?: AdminRole; nickname?: string; isBanned?: boolean },
  ) {
    return http.patch<AdminAccount>(`/admin/admins/${id}`, dto).then((r) => r.data)
  },
  resetPassword(id: number, password: string) {
    return http.post(`/admin/admins/${id}/reset-password`, { password }).then((r) => r.data)
  },
}
