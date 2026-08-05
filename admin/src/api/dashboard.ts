import http from './http'

export interface DashboardOverview {
  users: { total: number; today: number }
  appointments: {
    total: number
    today: number
    checkedIn: number
    inService: number
    completed: number
  }
  community: {
    totalPosts: number
    todayPosts: number
    todayLikes: number
    todayComments: number
  }
  videos: { total: number; today: number }
  pending: { posts: number; videos: number; reports: number }
}

export interface TrendItem {
  date: string
  users: number
  appointments: number
  posts: number
  likes: number
  comments: number
  videos: number
}

export const dashboardApi = {
  overview: () =>
    http.get('/admin/dashboard/overview').then((r) => r.data as DashboardOverview),

  trends: () =>
    http.get('/admin/dashboard/trends').then((r) => r.data as TrendItem[]),
}
