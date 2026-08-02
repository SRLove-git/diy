import http from './http'

export type ReportStatus = 'pending' | 'resolved' | 'dismissed'

export interface Report {
  id: number
  reporterId: number
  postId: number
  reason: string
  status: ReportStatus
  createdAt: string
  updatedAt: string
}

export const reportApi = {
  list(params?: { page?: number; status?: string }): Promise<[Report[], number]> {
    return http.get('/admin/reports', { params }).then(r => r.data)
  },
  resolve(id: number): Promise<Report> {
    return http.post(`/admin/reports/${id}/resolve`).then(r => r.data)
  },
  dismiss(id: number): Promise<Report> {
    return http.post(`/admin/reports/${id}/dismiss`).then(r => r.data)
  },
}
