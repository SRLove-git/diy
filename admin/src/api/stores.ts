import http from './http'

export interface Store {
  id: number
  name: string
  address: string
  rating: number
  businessHours: string
  phone: string
  price: number
  memberPrice?: number | null
  enabled: boolean
  tables?: StoreTable[]
  slots?: TimeSlot[]
}

export interface StoreTable {
  id: number
  name: string
  capacity: number
  enabled: boolean
}

export interface TimeSlot {
  id: number
  startTime: string
  endTime: string
  enabled: boolean
}

export const storeApi = {
  list: () => http.get<Store[]>('/admin/stores'),
  create: (d: Partial<Store>) => http.post<Store>('/admin/stores', d),
  update: (id: number, d: Partial<Store>) =>
    http.patch<Store>(`/admin/stores/${id}`, d),
  remove: (id: number) => http.delete(`/admin/stores/${id}`),
  addTable: (storeId: number, d: Partial<StoreTable>) =>
    http.post<StoreTable>(`/admin/stores/${storeId}/tables`, d),
  updateTable: (id: number, d: Partial<StoreTable>) =>
    http.patch<StoreTable>(`/admin/stores/tables/${id}`, d),
  removeTable: (id: number) => http.delete(`/admin/stores/tables/${id}`),
  addSlot: (storeId: number, d: Partial<TimeSlot>) =>
    http.post<TimeSlot>(`/admin/stores/${storeId}/slots`, d),
  updateSlot: (id: number, d: Partial<TimeSlot>) =>
    http.patch<TimeSlot>(`/admin/stores/slots/${id}`, d),
  removeSlot: (id: number) => http.delete(`/admin/stores/slots/${id}`),
}
