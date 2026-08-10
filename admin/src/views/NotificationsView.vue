<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { notificationApi, type NotificationTemplate, type Notification } from '../api/notifications'
import { i18n, t } from '../i18n'

const tab = ref<'notifications' | 'templates'>('notifications')

// ─── 通知管理 ───
const notifications = ref<Notification[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const page = ref(1)
const pageSize = 20

const totalPages = computed(() => Math.ceil(total.value / pageSize) || 1)

async function loadNotifications() {
  loading.value = true
  error.value = ''
  try {
    const data = await notificationApi.list({ page: page.value, pageSize })
    notifications.value = data.items
    total.value = data.total
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    loading.value = false
  }
}

async function removeNotification(id: number) {
  if (!confirm(t('确认删除该通知？', 'Delete this notification?'))) return
  try {
    await notificationApi.remove(id)
    await loadNotifications()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
  }
}

function goPage(p: number) {
  if (p < 1 || p > totalPages.value) return
  page.value = p
  loadNotifications()
}

// ─── 发送弹窗 ───
const showSendModal = ref(false)
const sendForm = ref({
  title: '',
  content: '',
  targetType: 'all' as 'all' | 'role' | 'user',
  targetRole: 'user' as 'user' | 'admin',
  targetUserIds: '',
  channels: [] as string[],
})
const sending = ref(false)

function openSendFromTemplate(tpl?: NotificationTemplate) {
  if (tpl) {
    sendForm.value.title = tpl.titleTemplate
    sendForm.value.content = tpl.contentTemplate
  } else {
    sendForm.value.title = ''
    sendForm.value.content = ''
  }
  sendForm.value.targetType = 'all'
  sendForm.value.targetRole = 'user'
  sendForm.value.targetUserIds = ''
  sendForm.value.channels = []
  showSendModal.value = true
}

async function doSend() {
  if (!sendForm.value.title.trim() || !sendForm.value.content.trim()) {
    alert(t('标题和内容不能为空', 'Title and content are required'))
    return
  }
  sending.value = true
  try {
    const body: any = {
      title: sendForm.value.title,
      content: sendForm.value.content,
      targetType: sendForm.value.targetType,
      channels: sendForm.value.channels.join(',') || 'push',
    }
    if (sendForm.value.targetType === 'role') {
      body.targetRole = sendForm.value.targetRole
    }
    if (sendForm.value.targetType === 'user') {
      body.targetUserIds = sendForm.value.targetUserIds
    }
    await notificationApi.send(body)
    showSendModal.value = false
    alert(t('发送成功', 'Sent successfully'))
    await loadNotifications()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('发送失败', 'Send failed'))
  } finally {
    sending.value = false
  }
}

// ─── 模板管理 ───
const templates = ref<NotificationTemplate[]>([])
const tplLoading = ref(true)
const tplError = ref('')

async function loadTemplates() {
  tplLoading.value = true
  tplError.value = ''
  try {
    templates.value = await notificationApi.listTemplates()
  } catch (e: any) {
    tplError.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    tplLoading.value = false
  }
}

const showTplModal = ref(false)
const editingTpl = ref<NotificationTemplate | null>(null)
const tplForm = ref({
  name: '',
  titleTemplate: '',
  contentTemplate: '',
  category: 'system' as 'system' | 'booking' | 'community' | 'activity',
})

function openEditTpl(tpl: NotificationTemplate) {
  editingTpl.value = tpl
  tplForm.value = {
    name: tpl.name,
    titleTemplate: tpl.titleTemplate,
    contentTemplate: tpl.contentTemplate,
    category: tpl.category,
  }
  showTplModal.value = true
}

async function saveTpl() {
  if (!tplForm.value.name.trim()) {
    alert(t('请输入模板名称', 'Please enter the template name'))
    return
  }
  try {
    if (editingTpl.value) {
      await notificationApi.updateTemplate(editingTpl.value.id, tplForm.value)
    } else {
      await notificationApi.createTemplate(tplForm.value)
    }
    showTplModal.value = false
    await loadTemplates()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('保存失败', 'Save failed'))
  }
}

async function removeTpl(id: number) {
  if (!confirm(t('确认删除该模板？', 'Delete this template?'))) return
  try {
    await notificationApi.removeTemplate(id)
    await loadTemplates()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
  }
}

function categoryLabel(cat: string) {
  const zh: Record<string, string> = { system: '系统通知', booking: '预约', community: '社区互动', activity: '活动' }
  const en: Record<string, string> = { system: 'System', booking: 'Booking', community: 'Community', activity: 'Activity' }
  return t(zh[cat] || cat, en[cat] || cat)
}

function formatTime(t: string) {
  try {
    return new Date(t).toLocaleString(i18n.lang === 'en' ? 'en-US' : 'zh-CN')
  } catch {
    return t
  }
}

function channelLabel(ch: string) {
  const zh: Record<string, string> = { push: '推送', email: '邮件' }
  const en: Record<string, string> = { push: 'Push', email: 'Email' }
  return ch
    .split(',')
    .map((c) => t(zh[c.trim()] || c, en[c.trim()] || c))
    .join(i18n.lang === 'en' ? ', ' : '、')
}

function targetLabel(n: Notification) {
  if (n.targetType === 'all') return t('全体用户', 'All users')
  if (n.targetType === 'role') {
    const role = n.targetRole === 'admin' ? t('管理员', 'Admin') : t('用户', 'Users')
    return `${role}${t('（按角色）', ' (by role)')}`
  }
  return t(
    '指定用户（{n}人）',
    'Specific users ({n})',
    { n: n.targetUserIds?.split(',').length || 0 },
  )
}

onMounted(() => {
  loadNotifications()
  loadTemplates()
})
</script>

<template>
  <div class="notifications">
    <div class="toolbar">
      <h2>{{ $t('通知管理', 'Notifications') }}</h2>
      <div>
        <button class="btn" @click="openSendFromTemplate()">
          + {{ $t('发送通知', 'Send notification') }}
        </button>
      </div>
    </div>

    <!-- Tab 切换 -->
    <div class="tabs">
      <button
        class="tab"
        :class="{ active: tab === 'notifications' }"
        @click="tab = 'notifications'"
      >
        {{ $t('发送记录', 'Sent history') }}
      </button>
      <button
        class="tab"
        :class="{ active: tab === 'templates' }"
        @click="tab = 'templates'"
      >
        {{ $t('消息模板', 'Message templates') }}
      </button>
    </div>

    <!-- 发送记录 -->
    <template v-if="tab === 'notifications'">
      <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
      <div v-else-if="error" class="state error">{{ error }}</div>
      <div v-else-if="notifications.length === 0" class="state">
        {{ $t('暂无发送记录', 'No sent notifications yet') }}
      </div>

      <table v-else class="table">
        <thead>
          <tr>
            <th style="width:60px">ID</th>
            <th>{{ $t('标题', 'Title') }}</th>
            <th style="width:120px">{{ $t('发送目标', 'Target') }}</th>
            <th style="width:100px">{{ $t('渠道', 'Channel') }}</th>
            <th style="width:140px">{{ $t('发送时间', 'Sent at') }}</th>
            <th style="width:80px">{{ $t('操作', 'Actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="n in notifications" :key="n.id">
            <td>{{ n.id }}</td>
            <td>{{ n.title }}</td>
            <td>{{ targetLabel(n) }}</td>
            <td>{{ channelLabel(n.channels) }}</td>
            <td>{{ formatTime(n.createdAt) }}</td>
            <td>
              <button class="btn btn-sm btn-danger" @click="removeNotification(n.id)">
                {{ $t('删除', 'Delete') }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="!loading && notifications.length > 0" class="pagination">
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
    </template>

    <!-- 消息模板 -->
    <template v-if="tab === 'templates'">
      <div v-if="tplLoading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
      <div v-else-if="tplError" class="state error">{{ tplError }}</div>
      <div v-else-if="templates.length === 0" class="state">
        {{ $t('暂无消息模板', 'No templates yet') }}
      </div>

      <table v-else class="table">
        <thead>
          <tr>
            <th>{{ $t('名称', 'Name') }}</th>
            <th>{{ $t('标题模板', 'Title template') }}</th>
            <th style="width:100px">{{ $t('分类', 'Category') }}</th>
            <th style="width:80px">{{ $t('状态', 'Status') }}</th>
            <th style="width:140px">{{ $t('更新时间', 'Updated') }}</th>
            <th style="width:160px">{{ $t('操作', 'Actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="t in templates" :key="t.id">
            <td>{{ t.name }}</td>
            <td>{{ t.titleTemplate }}</td>
            <td>
              <span class="tag">{{ categoryLabel(t.category) }}</span>
            </td>
            <td>
              <span class="tag" :class="t.enabled ? 'tag-normal' : 'tag-banned'">
                {{ t.enabled ? $t('启用', 'Enabled') : $t('停用', 'Disabled') }}
              </span>
            </td>
            <td>{{ formatTime(t.updatedAt) }}</td>
            <td class="actions">
              <button class="btn btn-sm" @click="openSendFromTemplate(t)">
                {{ $t('发送', 'Send') }}
              </button>
              <button class="btn btn-sm" @click="openEditTpl(t)">{{ $t('编辑', 'Edit') }}</button>
              <button class="btn btn-sm btn-danger" @click="removeTpl(t.id)">
                {{ $t('删除', 'Delete') }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </template>

    <!-- 发送弹窗 -->
    <div v-if="showSendModal" class="modal-overlay" @click.self="showSendModal = false">
      <div class="modal modal-wide">
        <h3>{{ $t('发送通知', 'Send notification') }}</h3>
        <div class="form">
          <label>{{ $t('标题', 'Title') }}</label>
          <input v-model="sendForm.title" :placeholder="$t('通知标题', 'Notification title')" />

          <label>{{ $t('内容', 'Content') }}</label>
          <textarea v-model="sendForm.content" :placeholder="$t('通知正文', 'Notification body')" rows="4"></textarea>

          <label>{{ $t('发送目标', 'Target') }}</label>
          <select v-model="sendForm.targetType">
            <option value="all">{{ $t('全体用户', 'All users') }}</option>
            <option value="role">{{ $t('按角色', 'By role') }}</option>
            <option value="user">{{ $t('指定用户', 'Specific users') }}</option>
          </select>

          <template v-if="sendForm.targetType === 'role'">
            <label>{{ $t('目标角色', 'Target role') }}</label>
            <select v-model="sendForm.targetRole">
              <option value="user">{{ $t('普通用户', 'Regular users') }}</option>
              <option value="admin">{{ $t('管理员', 'Admins') }}</option>
            </select>
          </template>

          <template v-if="sendForm.targetType === 'user'">
            <label>{{ $t('用户ID（逗号分隔）', 'User IDs (comma separated)') }}</label>
            <input v-model="sendForm.targetUserIds" placeholder="1,2,3" />
          </template>

          <label>{{ $t('发送渠道', 'Channels') }}</label>
          <div class="channels">
            <label class="cb"><input type="checkbox" value="push" v-model="sendForm.channels" /> {{ $t('推送', 'Push') }}</label>
            <label class="cb"><input type="checkbox" value="email" v-model="sendForm.channels" /> {{ $t('邮件', 'Email') }}</label>
          </div>
        </div>

        <div class="modal-actions">
          <button class="btn btn-sm" @click="showSendModal = false">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm" :disabled="sending" @click="doSend">
            {{ sending ? $t('发送中…', 'Sending…') : $t('确认发送', 'Confirm send') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 模板编辑弹窗 -->
    <div v-if="showTplModal" class="modal-overlay" @click.self="showTplModal = false">
      <div class="modal modal-wide">
        <h3>{{ editingTpl ? $t('编辑模板', 'Edit template') : $t('新建模板', 'New template') }}</h3>
        <div class="form">
          <label>{{ $t('模板名称', 'Template name') }}</label>
          <input v-model="tplForm.name" :placeholder="$t('如：预约成功通知', 'e.g. Booking confirmed')" />

          <label>{{ $t('分类', 'Category') }}</label>
          <select v-model="tplForm.category">
            <option value="system">{{ $t('系统通知', 'System') }}</option>
            <option value="booking">{{ $t('预约相关', 'Booking') }}</option>
            <option value="community">{{ $t('社区互动', 'Community') }}</option>
            <option value="activity">{{ $t('活动通知', 'Activity') }}</option>
          </select>

          <label>{{ $t('标题模板', 'Title template') }}</label>
          <input v-model="tplForm.titleTemplate" :placeholder="$t('支持变量：{nickname} {store}', 'Variables: {nickname} {store}')" />

          <label>{{ $t('正文模板', 'Body template') }}</label>
          <textarea v-model="tplForm.contentTemplate" :placeholder="$t('支持变量：{nickname} {store} {time}', 'Variables: {nickname} {store} {time}')" rows="4"></textarea>
        </div>

        <div class="modal-actions">
          <button class="btn btn-sm" @click="showTplModal = false">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm" @click="saveTpl">
            {{ editingTpl ? $t('保存', 'Save') : $t('创建', 'Create') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.notifications { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 18px; }

.tabs { display: flex; gap: 0; border-bottom: 2px solid #eceae6; }
.tab {
  padding: 10px 20px;
  border: none;
  background: none;
  font-size: 14px;
  cursor: pointer;
  color: #8a8a8a;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
}
.tab.active {
  color: #e8633a;
  border-bottom-color: #e8633a;
  font-weight: 600;
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
  background: #f4f4f5;
  color: #909399;
}
.tag-normal { background: #f0f9eb; color: #2E9E5B; }
.tag-banned { background: #fef0f0; color: #D9453E; }

.actions { white-space: nowrap; }

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
.btn-danger { background: #d9453e; }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 8px 0;
}
.page-info { font-size: 13px; color: #8a8a8a; }

/* 弹窗 */
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
.modal-wide { width: 560px; }
.modal h3 { margin: 0 0 16px; font-size: 16px; }
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}

/* 表单 */
.form { display: flex; flex-direction: column; gap: 8px; }
.form label { font-size: 13px; font-weight: 600; color: #2b2b2b; }
.form input,
.form select,
.form textarea {
  padding: 8px 12px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  font-size: 13px;
  width: 100%;
}
.form textarea { resize: vertical; }
.channels { display: flex; gap: 16px; }
.cb { display: flex; align-items: center; gap: 4px; font-size: 13px; cursor: pointer; }
</style>
