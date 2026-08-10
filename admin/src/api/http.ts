import axios from 'axios'
import { t } from '../i18n'

/** 统一请求：dev 由 Vite 代理 /api → 3000；prod 由 Nginx 反代 */
const http = axios.create({ baseURL: '/api', timeout: 10000 })

http.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

http.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('admin_token')
      window.location.hash = '#/login'
    }
    if (err.response?.status === 403) {
      alert(
        err.response?.data?.message ??
          t('无管理权限，请使用管理员账号登录', 'No admin permission. Please log in with an admin account.'),
      )
      localStorage.removeItem('admin_token')
      window.location.hash = '#/login'
    }
    return Promise.reject(err)
  },
)

export default http
