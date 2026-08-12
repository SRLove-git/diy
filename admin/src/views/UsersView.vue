<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { userApi, type User } from '../api/users'
import { i18n, t } from '../i18n'

const users = ref<User[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const search = ref('')
const page = ref(1)
const pageSize = 20
const banTarget = ref<User | null>(null)
const deleteTarget = ref<User | null>(null)
const deleting = ref(false)

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
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
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
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

function openDeleteUser(user: User) {
  deleteTarget.value = user
}

function cancelDeleteUser() {
  deleteTarget.value = null
}

async function confirmDeleteUser() {
  if (!deleteTarget.value) return
  deleting.value = true
  try {
    await userApi.remove(deleteTarget.value.id)
    deleteTarget.value = null
    alert(t('用户已删除', 'User deleted'))
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    deleting.value = false
  }
}

function formatTime(t: string): string {
  try {
    const d = new Date(t)
    return d.toLocaleString(i18n.lang === 'en' ? 'en-US' : 'zh-CN')
  } catch {
    return t
  }
}

onMounted(load)
</script>

<template>
  <div class="users">
    <div class="toolbar">
      <h2>{{ $t('用户管理', 'Users') }}</h2>
      <div class="filters">
        <input
          v-model="search"
          type="text"
          :placeholder="$t('搜索用户名 / 邮箱 / 昵称', 'Search username / email / nickname')"
          @keyup.enter="doSearch"
        />
        <button class="btn" @click="doSearch">{{ $t('搜索', 'Search') }}</button>
        <button class="btn" @click="load">{{ $t('刷新', 'Refresh') }}</button>
      </div>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="users.length === 0" class="state">
      {{ $t('暂无用户数据', 'No users yet') }}
    </div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width:60px">ID</th>
          <th style="width:50px">{{ $t('头像', 'Avatar') }}</th>
          <th>{{ $t('用户名', 'Username') }}</th>
          <th>{{ $t('邮箱', 'Email') }}</th>
          <th>{{ $t('昵称', 'Nickname') }}</th>
          <th style="width:80px">{{ $t('角色', 'Role') }}</th>
          <th style="width:90px">{{ $t('状态', 'Status') }}</th>
          <th style="width:150px">{{ $t('注册时间', 'Registered') }}</th>
          <th style="width:120px">{{ $t('操作', 'Actions') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="u in users" :key="u.id">
          <td>{{ u.id }}</td>
          <td>
            <img
              v-if="u.avatar"
              class="avatar"
              :src="u.avatar"
              :alt="$t('头像', 'Avatar')"
              @error="($event.target as HTMLImageElement).style.display = 'none'"
            />
            <span v-else class="muted">-</span>
          </td>
          <td>{{ u.username || '-' }}</td>
          <td>{{ u.email || '-' }}</td>
          <td>{{ u.nickname || '-' }}</td>
          <td>
            <span class="tag" :class="u.role === 'admin' ? 'tag-role-admin' : 'tag-role-user'">
              {{ u.role === 'admin' ? $t('管理员', 'Admin') : $t('用户', 'User') }}
            </span>
          </td>
          <td>
            <span class="tag" :class="u.isBanned ? 'tag-banned' : 'tag-normal'">
              {{ u.isBanned ? $t('已封禁', 'Banned') : $t('正常', 'Normal') }}
            </span>
          </td>
          <td>{{ formatTime(u.createdAt) }}</td>
          <td class="actions">
            <button
              class="btn btn-sm"
              :class="u.isBanned ? 'btn-success' : 'btn-danger'"
              @click="openBan(u)"
            >
              {{ u.isBanned ? $t('解封', 'Unban') : $t('封禁', 'Ban') }}
            </button>
            <button
              class="btn btn-sm btn-danger"
              @click="openDeleteUser(u)"
            >
              {{ $t('删除用户', 'Delete user') }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 分页 -->
    <div v-if="!loading && users.length > 0" class="pagination">
      <button class="btn btn-sm" :disabled="page <= 1" @click="goPage(page - 1)">
        {{ $t('上一页', 'Prev') }}
      </button>
      <span class="page-info">
        {{ $t('第 {p} / {t} 页（共 {n} 条）', 'Page {p} / {t} ({n} total)', { p: page, t: totalPages, n: total }) }}
      </span>
      <button class="btn btn-sm" :disabled="page >= totalPages" @click="goPage(page + 1)">
        {{ $t('下一页', 'Next') }}
      </button>
    </div>

    <!-- 封禁/解封确认弹窗 -->
    <div v-if="banTarget !== null" class="modal-overlay" @click.self="cancelBan">
      <div class="modal">
        <h3>
          {{ banTarget.isBanned ? $t('解封用户', 'Unban user') : $t('封禁用户', 'Ban user') }}
        </h3>
        <p class="modal-desc">
          {{
            banTarget.isBanned
              ? $t('确认解封该用户？解封后该用户可正常使用平台。', 'Unban this user? They can use the platform normally after unbanning.')
              : $t('确认封禁该用户？封禁后该用户将无法使用平台功能。', 'Ban this user? They will not be able to use the platform after being banned.')
          }}
        </p>
        <p class="modal-user">
          {{ banTarget.nickname || banTarget.username || $t('用户 #{id}', 'User #{id}', { id: banTarget.id }) }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelBan">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" @click="confirmBan">
            {{ banTarget.isBanned ? $t('确认解封', 'Confirm unban') : $t('确认封禁', 'Confirm ban') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 删除用户确认弹窗 -->
    <div v-if="deleteTarget !== null" class="modal-overlay" @click.self="cancelDeleteUser">
      <div class="modal">
        <h3>{{ $t('删除用户', 'Delete user') }}</h3>
        <p class="modal-desc">
          {{ $t('确认删除该用户账号？其作品、互动、关注、会员、预约、聊天等全部关联数据将一并删除，且不可恢复。', 'Delete this account? All related data (posts, interactions, follows, membership, bookings, chats) will be deleted permanently.') }}
        </p>
        <p class="modal-user">
          {{ deleteTarget.nickname || deleteTarget.username || $t('用户 #{id}', 'User #{id}', { id: deleteTarget.id }) }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelDeleteUser">{{ $t('取消', 'Cancel') }}</button>
          <button
            class="btn btn-sm btn-danger"
            :disabled="deleting"
            @click="confirmDeleteUser"
          >
            {{ deleting ? $t('删除中…', 'Deleting…') : $t('确认删除', 'Confirm delete') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.users { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 19px; font-weight: 700; letter-spacing: 0.01em; color: var(--text); }
.filters { display: flex; gap: 8px; }
.filters input {
  height: 36px;
  width: 180px;
  padding: 0 12px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 13px;
  background: var(--surface);
  color: var(--text);
  transition:
    border-color var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
.filters input::placeholder { color: var(--text-faint); }
.filters input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(232, 99, 58, 0.14);
}
.state { text-align: center; padding: 40px; color: var(--text-muted); }
.error { color: var(--danger); }
.state.error { background: var(--danger-weak); border-radius: var(--radius-sm); }

/* 表格卡片 */
.table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  font-size: 13px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  font-variant-numeric: tabular-nums;
}
.table th, .table td {
  padding: 10px 8px;
  border-bottom: 1px solid var(--border);
  text-align: left;
  vertical-align: middle;
}
.table th {
  background: var(--surface-muted);
  color: var(--text-muted);
  font-weight: 600;
  font-size: 12px;
  letter-spacing: 0.03em;
  white-space: nowrap;
}
.table tbody tr { transition: background var(--duration) var(--ease); }
.table tbody tr:hover { background: var(--surface-muted); }
.table tbody tr:last-child td { border-bottom: none; }

/* 胶囊标签：浅色底 + 饱和色文字的软风格 */
.tag {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
  border: 1px solid transparent;
}
.tag-role-admin { background: var(--primary-weak); color: var(--primary); }
.tag-role-user { background: var(--surface-muted); color: var(--text-muted); border-color: var(--border); }
.tag-banned { background: var(--danger-weak); color: var(--danger); }
.tag-normal { background: var(--success-weak); color: var(--success); }
.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid var(--border);
  display: block;
}

/* 按钮：默认幽灵风格；危险 / 成功为浅底软风格，hover 转实色 */
.btn {
  background: var(--surface);
  color: var(--text);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 8px 16px;
  font-size: 13px;
  cursor: pointer;
  transition:
    background var(--duration) var(--ease),
    border-color var(--duration) var(--ease),
    color var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease),
    transform var(--duration) var(--ease);
}
.btn:hover:not(:disabled) { background: var(--surface-muted); border-color: var(--border-strong); }
.btn:active:not(:disabled) { background: var(--border); }
.btn-sm { padding: 4px 10px; font-size: 12px; margin-right: 4px; }
.btn-success { background: var(--success-weak); color: var(--success); border-color: transparent; }
.btn-success:hover:not(:disabled) { background: var(--success); color: #fff; box-shadow: 0 4px 12px rgba(46, 158, 91, 0.28); }
.btn-success:active:not(:disabled) { background: var(--success); color: #fff; box-shadow: none; }
.btn-danger { background: var(--danger-weak); color: var(--danger); border-color: transparent; }
.btn-danger:hover:not(:disabled) { background: var(--danger); color: #fff; box-shadow: 0 4px 12px rgba(217, 69, 62, 0.28); }
.btn-danger:active:not(:disabled) { background: var(--danger); color: #fff; box-shadow: none; }
.btn-works { background: var(--surface); color: var(--danger); border-color: var(--danger-weak); }
.btn-works:hover:not(:disabled) { background: var(--danger-weak); }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.muted { color: var(--text-muted); }
.actions { white-space: nowrap; }
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 8px 0;
}
.page-info { font-size: 13px; color: var(--text-muted); font-variant-numeric: tabular-nums; }

/* 弹窗 */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(41, 32, 24, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}
.modal {
  background: var(--surface);
  border-radius: var(--radius-lg);
  padding: 24px;
  width: 400px;
  max-width: 90vw;
  box-shadow: var(--shadow-lg);
}
.modal h3 { margin: 0 0 16px; font-size: 16px; font-weight: 600; color: var(--text); }
.modal-desc { font-size: 13px; color: var(--text-muted); margin: 0 0 8px; }
.modal-user {
  font-size: 14px;
  font-weight: 600;
  margin: 0 0 16px;
  padding: 8px 12px;
  background: var(--surface-muted);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 8px;
}
</style>
