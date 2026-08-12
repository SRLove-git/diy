import http from './http'

export interface Membership {
  id: number
  userId: number
  userName?: string
  memberNo: string
  levelName: string
  expireAt: string
  updatedAt: string
}

export interface MemberOrder {
  id: number
  userId: number
  userName?: string
  userEmail?: string
  userNickname?: string
  planId: number
  planName: string
  durationDays: number
  amount: string
  status: 'pending' | 'confirmed' | 'cancelled'
  createdAt: string
  confirmedAt: string | null
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

/** 已发放给用户的优惠券（含核销码） */
export interface UserCoupon {
  id: number
  userId: number
  couponId: number
  code: string
  status: 'unused' | 'used' | 'expired'
  usedAt: string | null
  redeemedBy: number | null
  receivedAt: string
  couponTitle: string
  couponAmount: string
  couponThreshold: string
  expireAt: string
  userNickname?: string
  userEmail?: string
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

export interface SaveMembershipPayload {
  userId: number
  levelName?: string
  expireAt: string
}

export interface UpdateMembershipPayload {
  levelName?: string
  expireAt: string
}

export const memberApi = {
  listMembers(page = 1, keyword?: string) {
    return http.get<[Membership[], number]>('/admin/members', {
      params: { page, ...(keyword ? { keyword } : {}) },
    })
  },
  createMembership(data: SaveMembershipPayload) {
    return http.post('/admin/members', data)
  },
  updateMembership(id: number, data: UpdateMembershipPayload) {
    return http.patch(`/admin/members/${id}`, data)
  },
  deleteMembership(id: number) {
    return http.delete(`/admin/members/${id}`)
  },
  listOrders(page = 1, keyword?: string, status?: string) {
    return http.get<[MemberOrder[], number]>('/admin/members/orders', {
      params: { page, ...(keyword ? { keyword } : {}), ...(status ? { status } : {}) },
    })
  },
  confirmOrder(id: number) {
    return http.post(`/admin/members/orders/${id}/confirm`)
  },
  cancelOrder(id: number) {
    return http.post(`/admin/members/orders/${id}/cancel`)
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
  /** 按核销码查询（核销前确认用，公开接口） */
  findCouponByCode(code: string) {
    return http.get<UserCoupon>(`/members/coupons/code/${code}`)
  },
  /** 输码核销（店员代操作） */
  redeemCouponByCode(code: string) {
    return http
      .post<UserCoupon>('/admin/members/coupons/redeem-code', { code })
      .then((r) => r.data)
  },
  /** 按记录 ID 核销（店员代操作） */
  adminRedeemCoupon(id: number) {
    return http
      .post<UserCoupon>(`/admin/members/coupons/${id}/redeem`)
      .then((r) => r.data)
  },
}
