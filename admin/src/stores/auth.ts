import { reactive } from 'vue'

/** 管理后台登录态（token 存 localStorage） */
export const auth = reactive({
  token: localStorage.getItem('admin_token') || '',
  get loggedIn() {
    return !!this.token
  },
  setToken(token: string) {
    this.token = token
    localStorage.setItem('admin_token', token)
  },
  clear() {
    this.token = ''
    localStorage.removeItem('admin_token')
  },
})
