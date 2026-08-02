import http from './http'

export interface Post {
  id: number
  userId: number
  content: string
  images: string[]
  tags: string[]
  status: 'pending' | 'approved' | 'rejected'
  rejectReason: string
  likeCount: number
  collectCount: number
  commentCount: number
  createdAt: string
}

export const postApi = {
  list(params?: { status?: string; page?: number }) {
    return http.get<[Post[], number]>('/admin/posts', { params })
  },
  updateStatus(id: number, status: 'approved' | 'rejected', rejectReason?: string) {
    return http.patch(`/admin/posts/${id}/status`, { status, rejectReason })
  },
  remove(id: number) {
    return http.patch(`/admin/posts/${id}/remove`)
  },
}
