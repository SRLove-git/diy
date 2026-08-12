import http from './http'

export interface Appointment {
  id: number
  userId: number
  userEmail?: string
  userNickname?: string
  type?: 'store' | 'activity'
  bookingType?: 'hourly' | 'package' | 'all_day'
  durationHours?: number | null
  packageName?: string
  storeId: number | null
  storeName: string
  tableId: number | null
  tableName: string
  tables?: Array<{ id: number; name: string; capacity: number; people: number }>
  slotId: number | null
  activityId?: number | null
  activitySessionId?: number | null
  activityName?: string
  amount?: number
  originalAmount?: number
  payStatus?: 'unpaid' | 'paid'
  payMethod?: string
  paidAt?: string | null
  date: string
  startTime: string
  endTime: string
  peopleCount: number
  code: string
  status: 'pending' | 'booked' | 'checked_in' | 'in_service' | 'completed' | 'cancelled'
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

export interface WalkInPayload {
  storeId: number
  tableIds: number[]
  peopleCount: number
  bookingType?: 'hourly' | 'all_day'
  durationHours?: number
  note?: string
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

  /** 管理端确认预约（待确认 → 待核销） */
  adminConfirm: (id: number) =>
    http.post<Appointment>(`/admin/appointments/${id}/confirm`),

  /** 管理端输入核销码核销（核销即上钟） */
  checkInByCode: (code: string) =>
    http
      .post<Appointment>('/admin/appointments/checkin-code', { code })
      .then((r) => r.data),

  /** 管理端取消预约（店员代操作） */
  adminCancel: (id: number) =>
    http.post<Appointment>(`/admin/appointments/${id}/cancel`),

  /** 管理端上钟 */
  clockIn: (id: number) =>
    http.post<Appointment>(`/admin/appointments/${id}/clockin`),

  /** 管理端下钟 */
  clockOut: (id: number) =>
    http.post<Appointment>(`/admin/appointments/${id}/clockout`),

  /** 线下散客开台：创建即服务中，直接开始计时 */
  walkIn: (d: WalkInPayload) =>
    http
      .post<Appointment>('/admin/appointments/walkin', d)
      .then((r) => r.data),
}
