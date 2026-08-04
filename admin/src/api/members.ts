import http from './http'

export interface Membership {
  id: number
  userId: number
  memberNo: string
  levelName: string
  expireAt: string
  updatedAt: string
}

export interface MemberPlan {
  id: number
  name: string
  durationDays: number
  price: string
  originalPrice: string
  benefits: string[]
  badge: string
  recommended: boolean
  enabled: boolean
}

export interface Coupon {
  id: number
  title: string
  amount: string
  threshold: string
  expireAt: string
  stock: number
  membersOnly: boolean
  enabled: boolean
}

export interface SavePlanPayload {
  name: string
  durationDays: number
  price: number
  originalPrice: number
  benefits: string[]
  badge?: string
  recommended?: boolean
  enabled?: boolean
}

export interface SaveCouponPayload {
  title: string
  amount: string
  threshold: string
  expireAt: string
  stock: number
  membersOnly?: boolean
  enabled?: boolean
}

export const memberApi = {
  listMembers(page = 1) {
    return http.get<[Membership[], number]>('/admin/members', { params: { page } })
  },
  listPlans() {
    return http.get<MemberPlan[]>('/admin/members/plans')
  },
  createPlan(data: SavePlanPayload) {
    return http.post('/admin/members/plans', data)
  },
  updatePlan(id: number, data: SavePlanPayload) {
    return http.patch(`/admin/members/plans/${id}`, data)
  },
  togglePlan(id: number, enabled: boolean) {
    return http.patch(`/admin/members/plans/${id}/enabled`, { enabled })
  },
  listCoupons() {
    return http.get<Coupon[]>('/admin/members/coupons')
  },
  createCoupon(data: SaveCouponPayload) {
    return http.post('/admin/members/coupons', data)
  },
  updateCoupon(id: number, data: SaveCouponPayload) {
    return http.patch(`/admin/members/coupons/${id}`, data)
  },
  toggleCoupon(id: number, enabled: boolean) {
    return http.patch(`/admin/members/coupons/${id}/enabled`, { enabled })
  },
}
