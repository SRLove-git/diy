import http from './http'

export interface Video {
  id: number
  userId: number
  title: string
  content: string | null
  cover: string
  videoUrl: string
  photos: string[]
  tags: string[]
  status: 'pending' | 'approved' | 'rejected'
  rejectReason: string
  likeCount: number
  commentCount: number
  shareCount: number
  viewCount: number
  createdAt: string
}

export const videoApi = {
  list(params?: { status?: string; page?: number }) {
    return http.get<[Video[], number]>('/admin/videos', { params })
  },
  updateStatus(id: number, status: 'approved' | 'rejected', rejectReason?: string) {
    return http.patch(`/admin/videos/${id}/status`, { status, rejectReason })
  },
  remove(id: number) {
    return http.patch(`/admin/videos/${id}/remove`)
  },
  hardDelete(id: number) {
    return http.delete(`/admin/videos/${id}`)
  },
}
