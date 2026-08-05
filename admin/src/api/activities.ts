import http from './http'

export interface Activity {
  id: number
  title: string
  date: string
  desc: string
  tag: string
  membersOnly: boolean
  enabled: boolean
  sort: number
  createdAt: string
  updatedAt: string
}

export interface SaveActivityPayload {
  title: string
  date: string
  desc?: string
  tag?: string
  membersOnly?: boolean
  enabled?: boolean
  sort?: number
}

export const activityApi = {
  list: () => http.get<Activity[]>('/admin/activities'),
  create: (data: SaveActivityPayload) => http.post<Activity>('/admin/activities', data),
  update: (id: number, data: Partial<SaveActivityPayload>) =>
    http.patch<Activity>(`/admin/activities/${id}`, data),
  toggle: (id: number, enabled: boolean) =>
    http.patch<Activity>(`/admin/activities/${id}/enabled`, { enabled }),
}
