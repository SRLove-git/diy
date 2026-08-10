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
    router.push('/stores')
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
  background: #f7f5f2;
}
.lang-toggle {
  position: fixed;
  top: 18px;
  right: 18px;
  height: 34px;
  padding: 0 14px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  background: #fff;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
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
input {
  height: 44px;
  border: 1px solid #eceae6;
  border-radius: 10px;
  padding: 0 12px;
  font-size: 15px;
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
.error {
  color: #d9453e;
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
