import http from './http'

export interface Appointment {
  id: number
  userId: number
  userPhone?: string
  userNickname?: string
  storeId: number
  storeName: string
  tableId: number
  tableName: string
  slotId: number
  date: string
  startTime: string
  endTime: string
  peopleCount: number
  code: string
  status: 'booked' | 'checked_in' | 'in_service' | 'completed' | 'cancelled'
  note: string
  checkInTime: string | null
  serviceStartTime: string | null
  serviceEndTime: string | null
  checkedInBy: number | null
  createdAt: string
  updatedAt: string
}

export interface AppointmentListParams {
  status?: string
  storeId?: number
  date?: string
  page?: number
  limit?: number
}

export const appointmentApi = {
  /** 管理端：所有预约列表（分页） */
  list: (params?: AppointmentListParams): Promise<[Appointment[], number]> =>
    http.get('/admin/appointments', { params }).then((r) => r.data),

  /** 按预约码查询 */
  findByCode: (code: string) =>
    http.get<Appointment>(`/appointments/code/${code}`),

  /** 输码核销（店員代操作） */
  checkIn: (code: string) =>
    http.post<Appointment>('/appointments/checkin', { code }),

  /** 管理端按订单核销 */
  adminCheckIn: (id: number) =>
    http.post<Appointment>(`/admin/appointments/${id}/checkin`),

  /** 管理端取消预约（店员代操作） */
  adminCancel: (id: number) =>
    http.post<Appointment>(`/admin/appointments/${id}/cancel`),

  /** 管理端上钟 */
  clockIn: (id: number) =>
    http.post<Appointment>(`/admin/appointments/${id}/clockin`),

  /** 管理端下钟 */
  clockOut: (id: number) =>
    http.post<Appointment>(`/admin/appointments/${id}/clockout`),
}
