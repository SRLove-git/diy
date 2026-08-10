<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import http from '../api/http'
import { auth } from '../stores/auth'

const router = useRouter()
const account = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

async function login() {
  if (!account.value.trim()) {
    error.value = '请输入用户名或邮箱'
    return
  }
  if (password.value.length < 6) {
    error.value = '密码至少 6 位'
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
    error.value = e.response?.data?.message || '登录失败'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-wrap">
    <form class="login-card" @submit.prevent="login">
      <h1>Think Origin · 管理后台</h1>
      <input
        v-model="account"
        type="text"
        placeholder="用户名 / 邮箱"
        maxlength="255"
        autocomplete="username"
      />
      <input
        v-model="password"
        type="password"
        placeholder="密码"
        maxlength="32"
        autocomplete="current-password"
      />
      <p v-if="error" class="error">{{ error }}</p>
      <button type="submit" :disabled="loading">
        {{ loading ? '登录中…' : '登录' }}
      </button>
      <p class="hint">开发环境管理员：admin / admin123456</p>
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
