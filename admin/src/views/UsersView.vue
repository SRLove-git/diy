<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { userApi, type User } from '../api/users'

const users = ref<User[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const search = ref('')
const page = ref(1)
const pageSize = 20
const banTarget = ref<User | null>(null)

const totalPages = computed(() => Math.ceil(total.value / pageSize) || 1)

async function load() {
  loading.value = true
  error.value = ''
  try {
    const params: { page: number; search?: string } = { page: page.value }
    if (search.value.trim()) params.search = search.value.trim()
    const data = await userApi.list(params)
    users.value = data[0]
    total.value = data[1]
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
}

function doSearch() {
  page.value = 1
  load()
}

function goPage(p: number) {
  if (p < 1 || p > totalPages.value) return
  page.value = p
  load()
}

function openBan(user: User) {
  banTarget.value = user
}

function cancelBan() {
  banTarget.value = null
}

async function confirmBan() {
  if (!banTarget.value) return
  try {
    await userApi.setBan(banTarget.value.id, !banTarget.value.isBanned)
    banTarget.value = null
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

function formatTime(t: string): string {
  try {
    const d = new Date(t)
    return d.toLocaleString('zh-CN')
  } catch {
    return t
  }
}

onMounted(load)
</script>

<template>
  <div class="users">
    <div class="toolbar">
      <h2>用户管理</h2>
      <div class="filters">
        <input
          v-model="search"
          type="text"
          placeholder="搜索手机号"
          @keyup.enter="doSearch"
        />
        <button class="btn" @click="doSearch">搜索</button>
        <button class="btn" @click="load">刷新</button>
      </div>
    </div>

    <div v-if="loading" class="state">加载中…</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="users.length === 0" class="state">暂无用户数据</div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width:60px">ID</th>
          <th>手机号</th>
          <th>昵称</th>
          <th style="width:80px">角色</th>
          <th style="width:90px">状态</th>
          <th style="width:150px">注册时间</th>
          <th style="width:120px">操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="u in users" :key="u.id">
          <td>{{ u.id }}</td>
          <td>{{ u.phone }}</td>
          <td>{{ u.nickname || '-' }}</td>
          <td>
            <span class="tag" :class="u.role === 'admin' ? 'tag-role-admin' : 'tag-role-user'">
              {{ u.role === 'admin' ? '管理员' : '用户' }}
            </span>
          </td>
          <td>
            <span class="tag" :class="u.isBanned ? 'tag-banned' : 'tag-normal'">
              {{ u.isBanned ? '已封禁' : '正常' }}
            </span>
          </td>
          <td>{{ formatTime(u.createdAt) }}</td>
          <td class="actions">
            <button
              class="btn btn-sm"
              :class="u.isBanned ? 'btn-success' : 'btn-danger'"
              @click="openBan(u)"
            >
              {{ u.isBanned ? '解封' : '封禁' }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 分页 -->
    <div v-if="!loading && users.length > 0" class="pagination">
      <button class="btn btn-sm" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
      <span class="page-info">{{ page }} / {{ totalPages }}（共 {{ total }} 条）</span>
      <button class="btn btn-sm" :disabled="page >= totalPages" @click="goPage(page + 1)">下一页</button>
    </div>

    <!-- 封禁/解封确认弹窗 -->
    <div v-if="banTarget !== null" class="modal-overlay" @click.self="cancelBan">
      <div class="modal">
        <h3>{{ banTarget.isBanned ? '解封用户' : '封禁用户' }}</h3>
        <p class="modal-desc">
          {{ banTarget.isBanned ? '确认解封该用户？解封后该用户可正常使用平台。' : '确认封禁该用户？封禁后该用户将无法使用平台功能。' }}
        </p>
        <p class="modal-user">
          {{ banTarget.nickname || banTarget.phone }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelBan">取消</button>
          <button class="btn btn-sm btn-danger" @click="confirmBan">
            {{ banTarget.isBanned ? '确认解封' : '确认封禁' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.users { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 18px; }
.filters { display: flex; gap: 8px; }
.filters input {
  padding: 6px 12px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  font-size: 13px;
  width: 180px;
}
.state { text-align: center; padding: 40px; color: #8a8a8a; }
.error { color: #d9453e; }
.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.table th, .table td {
  padding: 10px 8px;
  border-bottom: 1px solid #eceae6;
  text-align: left;
  vertical-align: middle;
}
.table th {
  background: #f7f5f2;
  font-weight: 600;
  color: #2b2b2b;
}
.tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}
.tag-role-admin { background: #fdf6ec; color: #E6A23C; border: 1px solid #f5dab1; }
.tag-role-user { background: #f4f4f5; color: #909399; border: 1px solid #d4d4d8; }
.tag-banned { background: #fef0f0; color: #D9453E; border: 1px solid #fbc4c4; }
.tag-normal { background: #f0f9eb; color: #2E9E5B; border: 1px solid #c2e7b0; }
.btn {
  background: #e8633a;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 13px;
  cursor: pointer;
}
.btn-sm { padding: 4px 10px; font-size: 12px; margin-right: 4px; }
.btn-success { background: #2e9e5b; }
.btn-danger { background: #d9453e; }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.muted { color: #8a8a8a; }
.actions { white-space: nowrap; }
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 8px 0;
}
.page-info { font-size: 13px; color: #8a8a8a; }

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}
.modal {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  width: 400px;
  max-width: 90vw;
}
.modal h3 { margin: 0 0 16px; font-size: 16px; }
.modal-desc { font-size: 13px; color: #8a8a8a; margin: 0 0 8px; }
.modal-user { font-size: 14px; font-weight: 600; margin: 0 0 16px; }
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 8px;
}
</style>
