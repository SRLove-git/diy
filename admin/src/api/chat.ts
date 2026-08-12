import http from './http'

export interface ChatGroup {
  id: number
  name: string
  ownerId: number
  owner: { id: number; username: string | null; nickname: string } | null
  memberCount: number
  lastMessagePreview: string | null
  lastMessageAt: string | null
  createdAt: string
}

export interface ChatMessage {
  id: number
  groupId?: number
  conversationId?: number
  senderId: number
  contentType: 'text' | 'image' | 'voice' | 'video'
  content: string
  recalledAt: string | null
  createdAt: string
  sender: { id: number; username: string | null; nickname: string }
}

export const chatAdminApi = {
  listGroups(params?: { keyword?: string; page?: number; pageSize?: number }) {
    return http.get<[ChatGroup[], number]>('/admin/chat/groups', { params }).then((r) => r.data)
  },
  dissolveGroup(id: number) {
    return http.post(`/admin/chat/groups/${id}/dissolve`).then((r) => r.data)
  },
  searchMessages(params?: {
    scope?: 'dm' | 'group'
    keyword?: string
    page?: number
    pageSize?: number
  }) {
    return http.get<[ChatMessage[], number]>('/admin/chat/messages', { params }).then((r) => r.data)
  },
  recallMessage(id: number, scope: 'dm' | 'group') {
    return http
      .post(`/admin/chat/messages/${id}/recall`, null, { params: { scope } })
      .then((r) => r.data)
  },
}
