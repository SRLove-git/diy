import http from './http'

export interface User {
  id: number
  username?: string | null
  email?: string | null
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
  deleteWorks(id: number): Promise<{ posts: number; videos: number }> {
    return http.delete(`/admin/users/${id}/works`).then(r => r.data)
  },
  /** 删除用户（含作品、互动、关注、会员、预约、聊天等全部关联数据） */
  remove(id: number): Promise<{ posts: number; videos: number }> {
    return http.delete(`/admin/users/${id}`).then(r => r.data)
  },
}
