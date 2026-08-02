import http from './http'

export interface User {
  id: number
  phone: string
  nickname: string
  avatar: string
  isBanned: boolean
  role: string
  createdAt: string
}

export const userApi = {
  list(params?: { page?: number; search?: string }): Promise<[User[], number]> {
    return http.get('/admin/users', { params }).then(r => r.data)
  },
  setBan(id: number, isBanned: boolean): Promise<User> {
    return http.patch(`/admin/users/${id}/ban`, { isBanned }).then(r => r.data)
  },
}
