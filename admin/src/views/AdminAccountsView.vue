<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { adminsApi, type AdminAccount, type AdminRole } from '../api/admins'
import { auth } from '../stores/auth'
import { t } from '../i18n'

const list = ref<AdminAccount[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const keyword = ref('')
const page = ref(1)
const pageSize = 20
const totalPages = computed(() => Math.ceil(total.value / pageSize) || 1)

const ROLE_LABELS: Record<string, { zh: string; en: string }> = {
  super_admin: { zh: '超级管理员', en: 'Super Admin' },
  operator: { zh: '运营', en: 'Operator' },
  moderator: { zh: '审核员', en: 'Moderator' },
  auditor: { zh: '审计员', en: 'Auditor' },
}
const roleLabel = (r: AdminRole | null) =>
  r ? t(ROLE_LABELS[r].zh, ROLE_LABELS[r].en) : t('未设置', 'Unset')

async function load() {
  loading.value = true
  error.value = ''
  try {
    const [rows, count] = await adminsApi.list({ page: page.value, keyword: keyword.value })
    list.value = rows
    total.value = count
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
  page.value = p
  load()
}

// ──── 新增 ────
const createOpen = ref(false)
const creating = ref(false)
const createForm = ref({
  username: '',
  email: '',
  password: '',
  nickname: '',
  adminRole: 'operator' as AdminRole,
})

function openCreate() {
  createForm.value = { username: '', email: '', password: '', nickname: '', adminRole: 'operator' }
  createOpen.value = true
}

async function confirmCreate() {
  const f = createForm.value
  if (!f.username.trim() || !f.email.trim() || f.password.length < 6) {
    alert(t('请填写用户名、邮箱，密码至少 6 位', 'Username, email and a password of at least 6 chars are required.'))
    return
  }
  creating.value = true
  try {
    await adminsApi.create({
      username: f.username.trim(),
      email: f.email.trim(),
      password: f.password,
      nickname: f.nickname.trim() || undefined,
      adminRole: f.adminRole,
    })
    createOpen.value = false
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('创建失败', 'Failed to create'))
  } finally {
    creating.value = false
  }
}

// ──── 编辑 ────
const editTarget = ref<AdminAccount | null>(null)
const editForm = ref({ adminRole: 'operator' as AdminRole, nickname: '', isBanned: false })
const saving = ref(false)

function openEdit(a: AdminAccount) {
  editTarget.value = a
  editForm.value = {
    adminRole: (a.adminRole ?? 'operator') as AdminRole,
    nickname: a.nickname,
    isBanned: a.isBanned,
  }
}

async function confirmEdit() {
  if (!editTarget.value) return
  saving.value = true
  try {
    await adminsApi.update(editTarget.value.id, {
      adminRole: editForm.value.adminRole,
      nickname: editForm.value.nickname.trim(),
      isBanned: editForm.value.isBanned,
    })
    editTarget.value = null
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('保存失败', 'Failed to save'))
  } finally {
    saving.value = false
  }
}

// ──── 重置密码 ────
const resetTarget = ref<AdminAccount | null>(null)
const newPassword = ref('')
const resetting = ref(false)

function openReset(a: AdminAccount) {
  resetTarget.value = a
  newPassword.value = ''
}

async function confirmReset() {
  if (!resetTarget.value) return
  if (newPassword.value.length < 6) {
    alert(t('密码至少 6 位', 'Password must be at least 6 characters.'))
    return
  }
  resetting.value = true
  try {
    await adminsApi.resetPassword(resetTarget.value.id, newPassword.value)
    resetTarget.value = null
    alert(t('密码已重置，该账号需重新登录', 'Password reset. That account must log in again.'))
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('重置失败', 'Failed to reset'))
  } finally {
    resetting.value = false
  }
}

function formatTime(tm: string): string {
  const d = new Date(tm)
  return Number.isNaN(d.getTime()) ? '-' : d.toLocaleString()
}

onMounted(load)
</script>

<template>
  <div class="admins">
    <div class="toolbar">
      <h2>{{ $t('管理员账号', 'Admin Accounts') }}</h2>
      <div class="filters">
        <input
          v-model="keyword"
          type="text"
          :placeholder="$t('搜索用户名 / 邮箱 / 昵称', 'Search username / email / nickname')"
          @keyup.enter="doSearch"
        />
        <button class="btn" @click="doSearch">{{ $t('搜索', 'Search') }}</button>
        <button class="btn" @click="load">{{ $t('刷新', 'Refresh') }}</button>
        <button class="btn btn-primary" @click="openCreate">{{ $t('新增管理员', 'New admin') }}</button>
      </div>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="list.length === 0" class="state">{{ $t('暂无管理员账号', 'No admin accounts') }}</div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width:60px">ID</th>
          <th>{{ $t('用户名', 'Username') }}</th>
          <th>{{ $t('邮箱', 'Email') }}</th>
          <th>{{ $t('昵称', 'Nickname') }}</th>
          <th style="width:130px">{{ $t('角色', 'Role') }}</th>
          <th style="width:90px">{{ $t('状态', 'Status') }}</th>
          <th style="width:170px">{{ $t('创建时间', 'Created') }}</th>
          <th style="width:170px">{{ $t('操作', 'Actions') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="a in list" :key="a.id">
          <td>{{ a.id }}</td>
          <td>
            {{ a.username || '-' }}
            <span v-if="auth.me && a.id === auth.me.id" class="tag tag-self">
              {{ $t('当前账号', 'You') }}
            </span>
          </td>
          <td>{{ a.email || '-' }}</td>
          <td>{{ a.nickname || '-' }}</td>
          <td>
            <span class="tag" :class="a.adminRole ? 'tag-role-' + a.adminRole : ''">
              {{ roleLabel(a.adminRole) }}
            </span>
          </td>
          <td>
            <span class="tag" :class="a.isBanned ? 'tag-banned' : 'tag-normal'">
              {{ a.isBanned ? $t('已停用', 'Disabled') : $t('正常', 'Active') }}
            </span>
          </td>
          <td>{{ formatTime(a.createdAt) }}</td>
          <td class="actions">
            <button class="btn btn-sm" @click="openEdit(a)">{{ $t('编辑', 'Edit') }}</button>
            <button class="btn btn-sm" @click="openReset(a)">{{ $t('重置密码', 'Reset pwd') }}</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="!loading && list.length > 0" class="pagination">
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

    <!-- 新增管理员 -->
    <div v-if="createOpen" class="modal-overlay" @click.self="createOpen = false">
      <div class="modal">
        <h3>{{ $t('新增管理员', 'New admin') }}</h3>
        <label class="field">
          <span>{{ $t('用户名', 'Username') }} *</span>
          <input v-model="createForm.username" type="text" maxlength="30" />
        </label>
        <label class="field">
          <span>{{ $t('邮箱', 'Email') }} *</span>
          <input v-model="createForm.email" type="email" maxlength="255" />
        </label>
        <label class="field">
          <span>{{ $t('初始密码', 'Initial password') }} *</span>
          <input v-model="createForm.password" type="password" maxlength="32" />
        </label>
        <label class="field">
          <span>{{ $t('昵称', 'Nickname') }}</span>
          <input v-model="createForm.nickname" type="text" maxlength="30" />
        </label>
        <label class="field">
          <span>{{ $t('角色', 'Role') }}</span>
          <select v-model="createForm.adminRole">
            <option value="operator">{{ $t('运营', 'Operator') }}</option>
            <option value="moderator">{{ $t('审核员', 'Moderator') }}</option>
            <option value="auditor">{{ $t('审计员', 'Auditor') }}</option>
            <option value="super_admin">{{ $t('超级管理员', 'Super Admin') }}</option>
          </select>
        </label>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="createOpen = false">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-primary" :disabled="creating" @click="confirmCreate">
            {{ creating ? $t('创建中…', 'Creating…') : $t('创建', 'Create') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 编辑管理员 -->
    <div v-if="editTarget" class="modal-overlay" @click.self="editTarget = null">
      <div class="modal">
        <h3>
          {{ $t('编辑管理员', 'Edit admin') }}：{{ editTarget.username || editTarget.nickname }}
        </h3>
        <label class="field">
          <span>{{ $t('昵称', 'Nickname') }}</span>
          <input v-model="editForm.nickname" type="text" maxlength="30" />
        </label>
        <label class="field">
          <span>{{ $t('角色', 'Role') }}</span>
          <select v-model="editForm.adminRole">
            <option value="operator">{{ $t('运营', 'Operator') }}</option>
            <option value="moderator">{{ $t('审核员', 'Moderator') }}</option>
            <option value="auditor">{{ $t('审计员', 'Auditor') }}</option>
            <option value="super_admin">{{ $t('超级管理员', 'Super Admin') }}</option>
          </select>
        </label>
        <label class="field checkbox">
          <input v-model="editForm.isBanned" type="checkbox" />
          <span>{{ $t('停用该账号（不可登录后台）', 'Disable account (cannot log in)') }}</span>
        </label>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="editTarget = null">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-primary" :disabled="saving" @click="confirmEdit">
            {{ saving ? $t('保存中…', 'Saving…') : $t('保存', 'Save') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 重置密码 -->
    <div v-if="resetTarget" class="modal-overlay" @click.self="resetTarget = null">
      <div class="modal">
        <h3>
          {{ $t('重置密码', 'Reset password') }}：{{ resetTarget.username || resetTarget.nickname }}
        </h3>
        <p class="modal-desc">
          {{ $t('重置后该账号所有会话将立即失效，需要重新登录。', 'All sessions of this account will be invalidated immediately after reset.') }}
        </p>
        <label class="field">
          <span>{{ $t('新密码', 'New password') }}</span>
          <input v-model="newPassword" type="password" maxlength="32" />
        </label>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="resetTarget = null">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-primary" :disabled="resetting" @click="confirmReset">
            {{ resetting ? $t('重置中…', 'Resetting…') : $t('确认重置', 'Confirm reset') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admins { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 18px; }
.filters { display: flex; gap: 8px; flex-wrap: wrap; }
.filters input {
  padding: 6px 12px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  font-size: 13px;
  width: 180px;
}
.state { text-align: center; padding: 40px; color: #8a8a8a; }
.error { color: #d9453e; }
.table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 10px; overflow: hidden; box-shadow: var(--shadow); }
.table th, .table td { padding: 10px 12px; text-align: left; border-bottom: 1px solid #f0ede9; font-size: 13px; }
.table th { background: #faf8f6; color: #6b6b6b; font-weight: 600; white-space: nowrap; }
.actions { display: flex; gap: 6px; flex-wrap: wrap; }
.pagination { display: flex; align-items: center; gap: 12px; justify-content: flex-end; }
.page-info { color: #8a8a8a; font-size: 13px; }
.modal-overlay { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.35); display: flex; align-items: center; justify-content: center; z-index: 100; }
.modal { width: 400px; background: #fff; border-radius: 12px; padding: 24px; display: flex; flex-direction: column; gap: 14px; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18); }
.modal h3 { font-size: 16px; }
.field { display: flex; flex-direction: column; gap: 6px; font-size: 13px; color: #555; }
.field input, .field select { padding: 8px 10px; border: 1px solid #eceae6; border-radius: 8px; font-size: 14px; }
.field.checkbox { flex-direction: row; align-items: center; gap: 8px; }
.modal-desc { color: #8a8a8a; font-size: 13px; }
.modal-actions { display: flex; justify-content: flex-end; gap: 8px; }
.tag { display: inline-block; padding: 2px 8px; border-radius: 999px; font-size: 12px; background: #f0ede9; color: #555; }
.tag-normal { background: #e8f6ec; color: #2e9e5b; }
.tag-banned { background: #fdecec; color: #d9453e; }
.tag-role-super_admin { background: #fdeee8; color: #d95b3a; }
.tag-self { background: #eef1ff; color: #4a5fd9; margin-left: 6px; }
</style>
