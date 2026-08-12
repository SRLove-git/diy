import { reactive } from 'vue'
import { dashboardApi } from '../api/dashboard'

/** 管理端待处理事项计数：左侧栏角标与通知中心共用 */
export const pending = reactive({
  appointments: 0,
  memberOrders: 0,
  posts: 0,
  videos: 0,
})

/** 拉取最新待处理计数；失败时保留旧值，避免角标闪烁 */
export async function refreshPending() {
  try {
    const data = await dashboardApi.pendingSummary()
    pending.appointments = data.pendingAppointments
    pending.memberOrders = data.pendingMemberOrders
    pending.posts = data.pendingPosts
    pending.videos = data.pendingVideos
  } catch {
    // 忽略：下次轮询或刷新再尝试
  }
}

export function pendingTotal() {
  return pending.appointments + pending.memberOrders + pending.posts + pending.videos
}

/** 角标文案：超过 99 显示 99+，避免撑破圆形 */
export function badgeText(n: number) {
  return n > 99 ? '99+' : String(n)
}
