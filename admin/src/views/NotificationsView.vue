<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { notificationApi, type NotificationTemplate, type Notification } from '../api/notifications'

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
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
}

async function removeNotification(id: number) {
  if (!confirm('确认删除该通知？')) return
  try {
    await notificationApi.remove(id)
    await loadNotifications()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
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
  channels: 'push',
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
  sendForm.value.channels = 'push'
  showSendModal.value = true
}

async function doSend() {
  if (!sendForm.value.title.trim() || !sendForm.value.content.trim()) {
    alert('标题和内容不能为空')
    return
  }
  sending.value = true
  try {
    const body: any = {
      title: sendForm.value.title,
      content: sendForm.value.content,
      targetType: sendForm.value.targetType,
      channels: sendForm.value.channels,
    }
    if (sendForm.value.targetType === 'role') {
      body.targetRole = sendForm.value.targetRole
    }
    if (sendForm.value.targetType === 'user') {
      body.targetUserIds = sendForm.value.targetUserIds
    }
    await notificationApi.send(body)
    showSendModal.value = false
    alert('发送成功')
    await loadNotifications()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '发送失败')
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
    tplError.value = e?.response?.data?.message ?? '加载失败'
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
  if (!tplForm.value.name.trim()) { alert('请输入模板名称'); return }
  try {
    if (editingTpl.value) {
      await notificationApi.updateTemplate(editingTpl.value.id, tplForm.value)
    } else {
      await notificationApi.createTemplate(tplForm.value)
    }
    showTplModal.value = false
    await loadTemplates()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '保存失败')
  }
}

async function removeTpl(id: number) {
  if (!confirm('确认删除该模板？')) return
  try {
    await notificationApi.removeTemplate(id)
    await loadTemplates()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
  }
}

function categoryLabel(cat: string) {
  const map: Record<string, string> = { system: '系统通知', booking: '预约', community: '社区互动', activity: '活动' }
  return map[cat] || cat
}

function formatTime(t: string) {
  try { return new Date(t).toLocaleString('zh-CN') } catch { return t }
}

function channelLabel(ch: string) {
  const map: Record<string, string> = { push: '推送', sms: '短信', email: '邮件' }
  return ch.split(',').map((c) => map[c.trim()] || c).join('、')
}

function targetLabel(n: Notification) {
  if (n.targetType === 'all') return '全体用户'
  if (n.targetType === 'role') return `${n.targetRole === 'admin' ? '管理员' : '用户'}（按角色）`
  return `指定用户（${n.targetUserIds?.split(',').length || 0}人）`
}

onMounted(() => {
  loadNotifications()
  loadTemplates()
})
</script>

<template>
  <div class="notifications">
    <div class="toolbar">
      <h2>通知管理</h2>
      <div>
        <button class="btn" @click="openSendFromTemplate()">+ 发送通知</button>
      </div>
    </div>

    <!-- Tab 切换 -->
    <div class="tabs">
      <button
        class="tab"
        :class="{ active: tab === 'notifications' }"
        @click="tab = 'notifications'"
      >
        发送记录
      </button>
      <button
        class="tab"
        :class="{ active: tab === 'templates' }"
        @click="tab = 'templates'"
      >
        消息模板
      </button>
    </div>

    <!-- 发送记录 -->
    <template v-if="tab === 'notifications'">
      <div v-if="loading" class="state">加载中…</div>
      <div v-else-if="error" class="state error">{{ error }}</div>
      <div v-else-if="notifications.length === 0" class="state">暂无发送记录</div>

      <table v-else class="table">
        <thead>
          <tr>
            <th style="width:60px">ID</th>
            <th>标题</th>
            <th style="width:120px">发送目标</th>
            <th style="width:100px">渠道</th>
            <th style="width:140px">发送时间</th>
            <th style="width:80px">操作</th>
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
              <button class="btn btn-sm btn-danger" @click="removeNotification(n.id)">删除</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="!loading && notifications.length > 0" class="pagination">
        <button class="btn btn-sm" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
        <span class="page-info">{{ page }} / {{ totalPages }}（共 {{ total }} 条）</span>
        <button class="btn btn-sm" :disabled="page >= totalPages" @click="goPage(page + 1)">下一页</button>
      </div>
    </template>

    <!-- 消息模板 -->
    <template v-if="tab === 'templates'">
      <div v-if="tplLoading" class="state">加载中…</div>
      <div v-else-if="tplError" class="state error">{{ tplError }}</div>
      <div v-else-if="templates.length === 0" class="state">暂无消息模板</div>

      <table v-else class="table">
        <thead>
          <tr>
            <th>名称</th>
            <th>标题模板</th>
            <th style="width:100px">分类</th>
            <th style="width:80px">状态</th>
            <th style="width:140px">更新时间</th>
            <th style="width:160px">操作</th>
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
                {{ t.enabled ? '启用' : '停用' }}
              </span>
            </td>
            <td>{{ formatTime(t.updatedAt) }}</td>
            <td class="actions">
              <button class="btn btn-sm" @click="openSendFromTemplate(t)">发送</button>
              <button class="btn btn-sm" @click="openEditTpl(t)">编辑</button>
              <button class="btn btn-sm btn-danger" @click="removeTpl(t.id)">删除</button>
            </td>
          </tr>
        </tbody>
      </table>
    </template>

    <!-- 发送弹窗 -->
    <div v-if="showSendModal" class="modal-overlay" @click.self="showSendModal = false">
      <div class="modal modal-wide">
        <h3>发送通知</h3>
        <div class="form">
          <label>标题</label>
          <input v-model="sendForm.title" placeholder="通知标题" />

          <label>内容</label>
          <textarea v-model="sendForm.content" placeholder="通知正文" rows="4"></textarea>

          <label>发送目标</label>
          <select v-model="sendForm.targetType">
            <option value="all">全体用户</option>
            <option value="role">按角色</option>
            <option value="user">指定用户</option>
          </select>

          <template v-if="sendForm.targetType === 'role'">
            <label>目标角色</label>
            <select v-model="sendForm.targetRole">
              <option value="user">普通用户</option>
              <option value="admin">管理员</option>
            </select>
          </template>

          <template v-if="sendForm.targetType === 'user'">
            <label>用户ID（逗号分隔）</label>
            <input v-model="sendForm.targetUserIds" placeholder="1,2,3" />
          </template>

          <label>发送渠道</label>
          <div class="channels">
            <label class="cb"><input type="checkbox" value="push" v-model="sendForm.channels" /> 推送</label>
            <label class="cb"><input type="checkbox" value="sms" v-model="sendForm.channels" /> 短信</label>
            <label class="cb"><input type="checkbox" value="email" v-model="sendForm.channels" /> 邮件</label>
          </div>
        </div>

        <div class="modal-actions">
          <button class="btn btn-sm" @click="showSendModal = false">取消</button>
          <button class="btn btn-sm" :disabled="sending" @click="doSend">
            {{ sending ? '发送中…' : '确认发送' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 模板编辑弹窗 -->
    <div v-if="showTplModal" class="modal-overlay" @click.self="showTplModal = false">
      <div class="modal modal-wide">
        <h3>{{ editingTpl ? '编辑模板' : '新建模板' }}</h3>
        <div class="form">
          <label>模板名称</label>
          <input v-model="tplForm.name" placeholder="如：预约成功通知" />

          <label>分类</label>
          <select v-model="tplForm.category">
            <option value="system">系统通知</option>
            <option value="booking">预约相关</option>
            <option value="community">社区互动</option>
            <option value="activity">活动通知</option>
          </select>

          <label>标题模板</label>
          <input v-model="tplForm.titleTemplate" placeholder="支持变量：{nickname} {store}" />

          <label>正文模板</label>
          <textarea v-model="tplForm.contentTemplate" placeholder="支持变量：{nickname} {store} {time}" rows="4"></textarea>
        </div>

        <div class="modal-actions">
          <button class="btn btn-sm" @click="showTplModal = false">取消</button>
          <button class="btn btn-sm" @click="saveTpl">{{ editingTpl ? '保存' : '创建' }}</button>
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
