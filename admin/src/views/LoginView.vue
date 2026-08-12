<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import http from '../api/http'
import { auth } from '../stores/auth'
import { i18n, t } from '../i18n'

const router = useRouter()
const account = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

async function login() {
  if (!account.value.trim()) {
    error.value = t('请输入用户名或邮箱', 'Enter your username or email')
    return
  }
  if (password.value.length < 6) {
    error.value = t('密码至少 6 位', 'Password must be at least 6 characters')
    return
  }
  loading.value = true
  error.value = ''
  try {
    const { data } = await http.post('/auth/login', {
      account: account.value.trim(),
      password: password.value,
    })
    auth.setToken(data.accessToken)
    const me = await auth.refreshMe()
    if (me.role !== 'admin') {
      auth.clear()
      error.value = t('该账号不是管理员，无法登录后台', 'This account is not an admin.')
      return
    }
    router.push('/dashboard')
  } catch (e: any) {
    error.value =
      e.response?.data?.message || t('登录失败', 'Login failed')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-wrap">
    <button class="lang-toggle" @click="i18n.toggle()">
      {{ i18n.lang === 'zh' ? '中文' : 'English' }}
    </button>
    <form class="login-card" @submit.prevent="login">
      <h1>{{ $t('Think Origin · 管理后台', 'Think Origin · Admin') }}</h1>
      <input
        v-model="account"
        type="text"
        :placeholder="$t('用户名 / 邮箱', 'Username / Email')"
        maxlength="255"
        autocomplete="username"
      />
      <input
        v-model="password"
        type="password"
        :placeholder="$t('密码', 'Password')"
        maxlength="32"
        autocomplete="current-password"
      />
      <p v-if="error" class="error">{{ error }}</p>
      <button type="submit" :disabled="loading">
        {{ loading ? $t('登录中…', 'Logging in…') : $t('登录', 'Log In') }}
      </button>
      <p class="hint">
        {{ $t('开发环境管理员：admin / admin123456', 'Dev admin: admin / admin123456') }}
      </p>
    </form>
  </div>
</template>

<style scoped>
.login-wrap {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background:
    radial-gradient(1000px 500px at 20% -10%, rgba(232, 99, 58, 0.08), transparent 60%),
    radial-gradient(800px 400px at 90% 110%, rgba(232, 99, 58, 0.06), transparent 60%),
    var(--bg);
}
.lang-toggle {
  position: fixed;
  top: 18px;
  right: 18px;
  height: 34px;
  padding: 0 14px;
  border: 1px solid var(--border);
  border-radius: 10px;
  background: var(--surface);
  color: var(--primary);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition:
    background var(--duration) var(--ease),
    border-color var(--duration) var(--ease);
}
.lang-toggle:hover {
  background: var(--primary-weak);
  border-color: transparent;
}
.login-card {
  width: 380px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 20px;
  padding: 36px;
  display: flex;
  flex-direction: column;
  gap: 14px;
  box-shadow: var(--shadow-lg);
}
h1 {
  font-size: 19px;
  font-weight: 700;
  letter-spacing: 0.01em;
  text-align: center;
  margin: 0 0 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}
h1::before {
  content: '';
  width: 12px;
  height: 12px;
  border-radius: 4px;
  background: var(--primary);
  box-shadow: 0 0 12px rgba(232, 99, 58, 0.55);
}
input {
  height: 46px;
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 0 14px;
  font-size: 15px;
  background: var(--surface-muted);
  transition:
    border-color var(--duration) var(--ease),
    background var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
input::placeholder {
  color: var(--text-faint);
}
input:focus {
  outline: none;
  border-color: var(--primary);
  background: var(--surface);
  box-shadow: 0 0 0 3px rgba(232, 99, 58, 0.14);
}
button {
  height: 46px;
  border: none;
  border-radius: 12px;
  background: var(--primary);
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 0.04em;
  cursor: pointer;
  box-shadow: 0 6px 16px rgba(232, 99, 58, 0.32);
  transition:
    background var(--duration) var(--ease),
    transform var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
button:hover:not(:disabled) {
  background: var(--primary-hover);
  transform: translateY(-1px);
  box-shadow: 0 8px 20px rgba(232, 99, 58, 0.38);
}
button:active:not(:disabled) {
  background: var(--primary-active);
  transform: translateY(0);
  box-shadow: 0 3px 10px rgba(232, 99, 58, 0.3);
}
button:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}
.error {
  color: var(--danger);
  background: var(--danger-weak);
  border-radius: var(--radius-sm);
  padding: 8px 12px;
  font-size: 13px;
  margin: 0;
}
.hint {
  color: var(--text-muted);
  font-size: 12px;
  text-align: center;
  margin: 2px 0 0;
}
</style>
