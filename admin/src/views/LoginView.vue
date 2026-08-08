<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import http from '../api/http'
import { auth } from '../stores/auth'

type LoginMode = 'code' | 'password' | 'reset'

const router = useRouter()
const mode = ref<LoginMode>('code')
const phone = ref('')
const code = ref('')
const password = ref('')
const countdown = ref(0)
const sending = ref(false)
const loading = ref(false)
const error = ref('')
const notice = ref('')

let timer: number | undefined

function startCountdown() {
  countdown.value = 60
  timer = window.setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) clearInterval(timer)
  }, 1000)
}

function switchMode(m: LoginMode) {
  mode.value = m
  error.value = ''
  notice.value = ''
  if (m !== 'reset') code.value = ''
  if (m === 'password') password.value = ''
}

async function sendCode() {
  error.value = ''
  notice.value = ''
  sending.value = true
  try {
    await http.post('/auth/sms-code', { phone: phone.value })
    startCountdown()
  } catch (e: any) {
    error.value = e.response?.data?.message || '发送失败'
  } finally {
    sending.value = false
  }
}

async function login() {
  if (!/^1[3-9]\d{9}$/.test(phone.value)) {
    error.value = '请输入正确的手机号'
    return
  }
  if (mode.value === 'password') {
    if (password.value.length < 6) {
      error.value = '密码至少 6 位'
      return
    }
    loading.value = true
    error.value = ''
    try {
      const { data } = await http.post('/auth/password-login', {
        phone: phone.value,
        password: password.value,
      })
      auth.setToken(data.accessToken)
      router.push('/stores')
    } catch (e: any) {
      error.value = e.response?.data?.message || '登录失败'
    } finally {
      loading.value = false
    }
    return
  }
  if (!/^\d{6}$/.test(code.value)) {
    error.value = '请输入 6 位验证码'
    return
  }
  loading.value = true
  error.value = ''
  try {
    const { data } = await http.post('/auth/login', {
      phone: phone.value,
      code: code.value,
    })
    auth.setToken(data.accessToken)
    router.push('/stores')
  } catch (e: any) {
    error.value = e.response?.data?.message || '登录失败'
  } finally {
    loading.value = false
  }
}

async function resetPassword() {
  if (!/^1[3-9]\d{9}$/.test(phone.value)) {
    error.value = '请输入正确的手机号'
    return
  }
  if (!/^\d{6}$/.test(code.value)) {
    error.value = '请输入 6 位验证码'
    return
  }
  if (password.value.length < 6) {
    error.value = '新密码至少 6 位'
    return
  }
  loading.value = true
  error.value = ''
  try {
    await http.post('/auth/set-password', {
      phone: phone.value,
      code: code.value,
      password: password.value,
    })
    // 设置成功切回密码登录
    switchMode('password')
    notice.value = '密码设置成功，请使用新密码登录'
  } catch (e: any) {
    error.value = e.response?.data?.message || '设置失败'
  } finally {
    loading.value = false
  }
}

function onSubmit() {
  if (mode.value === 'reset') {
    resetPassword()
  } else {
    login()
  }
}
</script>

<template>
  <div class="login-wrap">
    <form class="login-card" @submit.prevent="onSubmit">
      <h1>DIY 手作工坊 · 管理后台</h1>
      <div v-if="mode !== 'reset'" class="tabs">
        <button
          type="button"
          class="tab"
          :class="{ active: mode === 'code' }"
          @click="switchMode('code')"
        >
          验证码登录
        </button>
        <button
          type="button"
          class="tab"
          :class="{ active: mode === 'password' }"
          @click="switchMode('password')"
        >
          密码登录
        </button>
      </div>
      <template v-if="mode === 'code'">
        <input v-model="phone" placeholder="管理员手机号" maxlength="11" />
        <div class="code-row">
          <input v-model="code" placeholder="验证码" maxlength="6" />
          <button
            type="button"
            :disabled="countdown > 0 || sending"
            @click="sendCode"
          >
            {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
          </button>
        </div>
      </template>
      <template v-else-if="mode === 'password'">
        <input v-model="phone" placeholder="管理员手机号" maxlength="11" />
        <input v-model="password" type="password" placeholder="密码" maxlength="32" />
        <p class="reset-link">
          <button type="button" class="link" @click="switchMode('reset')">
            忘记密码？
          </button>
        </p>
      </template>
      <template v-else>
        <input v-model="phone" placeholder="管理员手机号" maxlength="11" />
        <div class="code-row">
          <input v-model="code" placeholder="验证码" maxlength="6" />
          <button
            type="button"
            :disabled="countdown > 0 || sending"
            @click="sendCode"
          >
            {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
          </button>
        </div>
        <input v-model="password" type="password" placeholder="新密码（至少 6 位）" maxlength="32" />
        <p class="reset-link">
          <button type="button" class="link" @click="switchMode('password')">
            返回登录
          </button>
        </p>
      </template>
      <p v-if="notice" class="notice">{{ notice }}</p>
      <p v-if="error" class="error">{{ error }}</p>
      <button type="submit" :disabled="loading">
        {{ loading ? '处理中…' : mode === 'reset' ? '确认设置' : '登录' }}
      </button>
      <p class="hint">开发环境管理员：13800000000（验证码见后端日志）</p>
    </form>
  </div>
</template>

<style scoped>
.login-wrap {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f7f5f2;
}
.login-card {
  width: 360px;
  background: #fff;
  border-radius: 12px;
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
}
h1 {
  font-size: 18px;
  text-align: center;
  margin: 0 0 12px;
}
.tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 4px;
}
.tab {
  flex: 1;
  height: 40px;
  border: none;
  border-radius: 10px;
  background: transparent;
  color: #8a8a8a;
  font-size: 14px;
  cursor: pointer;
}
.tab.active {
  background: #fff0e8;
  color: #e8633a;
  font-weight: 600;
}
input {
  height: 44px;
  border: 1px solid #eceae6;
  border-radius: 10px;
  padding: 0 12px;
  font-size: 15px;
}
.code-row {
  display: flex;
  gap: 8px;
}
.code-row input {
  flex: 1;
}
button {
  height: 44px;
  border: none;
  border-radius: 10px;
  background: #e8633a;
  color: #fff;
  font-size: 16px;
  cursor: pointer;
}
button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
.code-row button {
  width: 120px;
  background: #fff0e8;
  color: #e8633a;
  font-size: 14px;
}
.reset-link {
  margin: -4px 0 0;
  text-align: right;
}
.reset-link .link {
  height: auto;
  background: transparent;
  color: #e8633a;
  font-size: 13px;
  padding: 0;
}
.error {
  color: #d9453e;
  font-size: 13px;
  margin: 0;
}
.notice {
  color: #2f9e44;
  font-size: 13px;
  margin: 0;
}
.hint {
  color: #8a8a8a;
  font-size: 12px;
  text-align: center;
  margin: 0;
}
</style>
