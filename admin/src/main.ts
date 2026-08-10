import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router'
import { t } from './i18n'

const app = createApp(App)
app.config.globalProperties.$t = t
app.use(router)
app.mount('#app')
