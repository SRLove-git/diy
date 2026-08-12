import http from './http'

export interface ModerationComment {
  id: number
  targetId: number
  userId: number
  content: string
  likeCount: number
  isHidden: boolean
  createdAt: string
  author: { id: number; username: string | null; nickname: string } | null
}

export const moderationApi = {
  listKeywords() {
    return http.get<string[]>('/admin/moderation/keywords').then((r) => r.data)
  },
  addKeyword(keyword: string) {
    return http
      .post<{ added: boolean; keywords: string[] }>('/admin/moderation/keywords', { keyword })
      .then((r) => r.data)
  },
  removeKeyword(keyword: string) {
    return http
      .delete<{ removed: boolean; keywords: string[] }>(
        `/admin/moderation/keywords/${encodeURIComponent(keyword)}`,
      )
      .then((r) => r.data)
  },
  listComments(params?: {
    scope?: 'post' | 'video'
    page?: number
    pageSize?: number
    keyword?: string
    hidden?: string
  }) {
    return http
      .get<[ModerationComment[], number]>('/admin/moderation/comments', { params })
      .then((r) => r.data)
  },
  hideComment(id: number, scope: 'post' | 'video', hidden: boolean) {
    return http
      .patch(`/admin/moderation/comments/${id}/hide`, { hidden }, { params: { scope } })
      .then((r) => r.data)
  },
}
