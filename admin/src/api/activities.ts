import http from './http'

export interface Activity {
  id: number
  title: string
  date: string
  desc: string
  tag: string
  address: string
  lat?: number | null
  lng?: number | null
  price: number
  memberPrice?: number | null
  bookable: boolean
  membersOnly: boolean
  enabled: boolean
  sort: number
  sessions?: ActivitySession[]
  createdAt: string
  updatedAt: string
}

export interface ActivitySession {
  id: number
  activityId: number
  date: string
  startTime: string
  endTime: string
  capacity: number
  enabled: boolean
}

export interface SaveActivityPayload {
  title: string
  date: string
  desc?: string
  tag?: string
  address?: string
  lat?: number
  lng?: number
  price?: number
  memberPrice?: number
  bookable?: boolean
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
  addSession: (activityId: number, data: Partial<ActivitySession>) =>
    http.post<ActivitySession>(`/admin/activities/${activityId}/sessions`, data),
  removeSession: (sessionId: number) =>
    http.delete(`/admin/activities/sessions/${sessionId}`),
}
