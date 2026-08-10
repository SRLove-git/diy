<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { activityApi, type Activity } from '../api/activities'

const activities = ref<Activity[]>([])
const loading = ref(true)
const error = ref('')

const showForm = ref(false)
const editingId = ref<number | null>(null)
const saving = ref(false)
const form = reactive({
  title: '',
  date: '',
  desc: '',
  tag: '',
  address: '',
  lat: 30.3,
  lng: 120.1,
  price: 0,
  memberPrice: null as number | null,
  bookable: false,
  membersOnly: false,
  enabled: true,
  sort: 0,
})

// 场次管理
const showSessions = ref(false)
const currentActivity = ref<Activity | null>(null)
const sessionList = ref<NonNullable<Activity['sessions']>>([])
const newSession = reactive({
  date: '',
  startTime: '',
  endTime: '',
  capacity: 12,
})

async function load() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await activityApi.list()
    activities.value = data
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
}

function openCreate() {
  editingId.value = null
  form.title = ''
  form.date = ''
  form.desc = ''
  form.tag = ''
  form.address = ''
  form.lat = 30.3
  form.lng = 120.1
  form.price = 0
  form.memberPrice = null
  form.bookable = false
  form.membersOnly = false
  form.enabled = true
  form.sort = 0
  showForm.value = true
}

function openEdit(a: Activity) {
  editingId.value = a.id
  form.title = a.title
  form.date = a.date
  form.desc = a.desc
  form.tag = a.tag
  form.address = a.address ?? ''
  form.lat = a.lat ?? 30.3
  form.lng = a.lng ?? 120.1
  form.price = a.price ?? 0
  form.memberPrice = a.memberPrice ?? null
  form.bookable = a.bookable
  form.membersOnly = a.membersOnly
  form.enabled = a.enabled
  form.sort = a.sort
  showForm.value = true
}

function closeForm() {
  showForm.value = false
}

async function save() {
  if (!form.title.trim() || !form.date.trim()) {
    alert('标题和活动时间不能为空')
    return
  }
  saving.value = true
  try {
    const payload = {
      ...form,
      memberPrice:
        form.memberPrice == null
          ? undefined
          : form.memberPrice,
    }
    if (editingId.value) {
      await activityApi.update(editingId.value, payload)
    } else {
      await activityApi.create(payload)
    }
    showForm.value = false
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '保存失败')
  } finally {
    saving.value = false
  }
}

function openSessionManager(a: Activity) {
  currentActivity.value = a
  sessionList.value = [...(a.sessions ?? [])].sort(
    (x, y) => x.date.localeCompare(y.date) || x.startTime.localeCompare(y.startTime),
  )
  newSession.date = ''
  newSession.startTime = ''
  newSession.endTime = ''
  newSession.capacity = 12
  showSessions.value = true
}

async function addSession() {
  const a = currentActivity.value
  if (!a || !newSession.date || !newSession.startTime || !newSession.endTime) {
    alert('请填写场次日期、开始和结束时间')
    return
  }
  try {
    const { data } = await activityApi.addSession(a.id, {
      ...newSession,
      capacity: Number(newSession.capacity) || 12,
    })
    sessionList.value.push(data)
    newSession.date = ''
    newSession.startTime = ''
    newSession.endTime = ''
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '添加失败')
  }
}

async function removeSession(s: NonNullable<Activity['sessions']>[number]) {
  if (!confirm(`确认删除场次 ${s.date} ${s.startTime}-${s.endTime}？`)) return
  try {
    await activityApi.removeSession(s.id)
    sessionList.value = sessionList.value.filter((x) => x.id !== s.id)
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
  }
}

async function toggle(a: Activity) {
  try {
    await activityApi.toggle(a.id, !a.enabled)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

async function removeActivity(a: Activity) {
  if (!confirm(`确认删除活动「${a.title}」？其下所有场次将一并删除。`)) return
  try {
    await activityApi.remove(a.id)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
  }
}

async function move(a: Activity, delta: number) {
  const sorted = [...activities.value].sort((x, y) => x.sort - y.sort || x.id - y.id)
  const idx = sorted.findIndex((x) => x.id === a.id)
  const target = sorted[idx + delta]
  if (!target) return
  try {
    await Promise.all([
      activityApi.update(a.id, { sort: target.sort }),
      activityApi.update(target.id, { sort: a.sort }),
    ])
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

onMounted(load)
</script>

<template>
  <div class="activities">
    <div class="toolbar">
      <h2>活动管理</h2>
      <div class="filters">
        <button class="btn" @click="load">刷新</button>
        <button class="btn btn-primary" @click="openCreate">新增活动</button>
      </div>
    </div>

    <div v-if="loading" class="state">加载中…</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="activities.length === 0" class="state">暂无活动，点击「新增活动」创建</div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width: 60px">ID</th>
          <th>标题</th>
          <th style="width: 130px">活动时间</th>
          <th>描述</th>
          <th style="width: 90px">标签</th>
          <th style="width: 90px">可预约</th>
          <th style="width: 110px">价格</th>
          <th style="width: 80px">会员专属</th>
          <th style="width: 60px">排序</th>
          <th style="width: 80px">状态</th>
          <th style="width: 320px">操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="a in activities" :key="a.id">
          <td>{{ a.id }}</td>
          <td class="title-cell">
            <span class="text-ellipsis" :title="a.title">{{ a.title }}</span>
          </td>
          <td>{{ a.date }}</td>
          <td class="desc-cell">
            <span class="text-ellipsis" :title="a.desc || '-'">{{ a.desc || '-' }}</span>
          </td>
          <td>
            <span v-if="a.tag" class="tag">#{{ a.tag }}</span>
            <span v-else class="muted">-</span>
          </td>
          <td>{{ a.bookable ? '是' : '否' }}</td>
          <td>
            <template v-if="a.bookable">
              <span v-if="a.memberPrice != null">会员 {{ a.memberPrice }} / {{ a.price }}</span>
              <span v-else>{{ a.price }} 元/人</span>
            </template>
            <span v-else class="muted">-</span>
          </td>
          <td>{{ a.membersOnly ? '是' : '否' }}</td>
          <td>{{ a.sort }}</td>
          <td>
            <span
              class="status-tag"
              :class="a.enabled ? 'tag-on' : 'tag-off'"
            >
              {{ a.enabled ? '已上架' : '已下架' }}
            </span>
          </td>
          <td class="actions">
            <button class="btn btn-sm" @click="move(a, -1)" :disabled="a.sort === 0 && a.id === activities[0].id">上移</button>
            <button class="btn btn-sm" @click="move(a, 1)">下移</button>
            <button class="btn btn-sm" @click="openSessionManager(a)">场次</button>
            <button class="btn btn-sm" @click="openEdit(a)">编辑</button>
            <button
              class="btn btn-sm"
              :class="a.enabled ? 'btn-danger' : 'btn-success'"
              @click="toggle(a)"
            >
              {{ a.enabled ? '下架' : '上架' }}
            </button>
            <button class="btn btn-sm btn-danger" @click="removeActivity(a)">删除</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 新增/编辑弹窗 -->
    <div v-if="showForm" class="modal-overlay" @click.self="closeForm">
      <div class="modal">
        <h3>{{ editingId ? '编辑活动' : '新增活动' }}</h3>
        <div class="form-grid">
          <label>
            <span>标题</span>
            <input v-model="form.title" type="text" placeholder="如 周末拼豆沙龙" />
          </label>
          <label>
            <span>活动时间</span>
            <input v-model="form.date" type="text" placeholder="如 08-16 14:00 / 08-22 起" />
          </label>
          <label>
            <span>标签</span>
            <input v-model="form.tag" type="text" placeholder="如 限会员 / 早鸟 8 折" />
          </label>
          <label>
            <span>活动地址（可预约必填）</span>
            <input v-model="form.address" type="text" placeholder="如 杭州市西湖区文一西路 1 号" />
          </label>
          <label>
            <span>纬度</span>
            <input v-model.number="form.lat" type="number" step="0.000001" />
          </label>
          <label>
            <span>经度</span>
            <input v-model.number="form.lng" type="number" step="0.000001" />
          </label>
          <label>
            <span>门市价（元/人）</span>
            <input v-model.number="form.price" type="number" min="0" step="0.1" />
          </label>
          <label>
            <span>会员价（元/人，0 = 会员免费）</span>
            <input v-model.number="form.memberPrice" type="number" min="0" step="0.1" />
          </label>
          <label>
            <span>排序权重</span>
            <input v-model.number="form.sort" type="number" min="0" />
          </label>
          <label class="full-row">
            <span>描述</span>
            <textarea v-model="form.desc" rows="3" placeholder="活动详情说明"></textarea>
          </label>
        </div>
        <div class="check-row">
          <label><input v-model="form.bookable" type="checkbox" /> 可预约（进入预约流程）</label>
          <label><input v-model="form.membersOnly" type="checkbox" /> 会员专属</label>
          <label><input v-model="form.enabled" type="checkbox" /> 立即上架</label>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeForm">取消</button>
          <button class="btn btn-sm btn-primary" :disabled="saving" @click="save">保存</button>
        </div>
      </div>
    </div>
  </div>

  <!-- 场次管理 -->
  <div v-if="showSessions" class="modal-overlay" @click.self="showSessions = false">
    <div class="modal wide">
      <h3>场次管理 · {{ currentActivity?.title }}</h3>
      <table class="table">
        <thead>
          <tr><th>日期</th><th>开始</th><th>结束</th><th>名额上限</th><th style="width: 90px">操作</th></tr>
        </thead>
        <tbody>
          <tr v-for="s in sessionList" :key="s.id">
            <td>{{ s.date }}</td>
            <td>{{ s.startTime }}</td>
            <td>{{ s.endTime }}</td>
            <td>{{ s.capacity }}</td>
            <td class="actions">
              <button class="btn btn-sm btn-danger" @click="removeSession(s)">删除</button>
            </td>
          </tr>
          <tr v-if="sessionList.length === 0">
            <td colspan="5" class="muted">暂无场次，请在下方添加</td>
          </tr>
        </tbody>
      </table>
      <div class="session-row">
        <input v-model="newSession.date" type="date" />
        <input v-model="newSession.startTime" type="time" />
        <input v-model="newSession.endTime" type="time" />
        <input v-model.number="newSession.capacity" type="number" min="1" placeholder="名额" />
        <button class="btn btn-sm btn-primary" @click="addSession">添加场次</button>
      </div>
      <div class="modal-actions">
        <button class="btn btn-sm btn-primary" @click="showSessions = false">完成</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.activities { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 18px; }
.filters { display: flex; gap: 8px; }
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
.title-cell, .desc-cell { max-width: 200px; }
.text-ellipsis {
  display: inline-block;
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  vertical-align: middle;
}
.tag {
  display: inline-block;
  font-size: 11px;
  color: #e8633a;
}
.status-tag {
  display: inline-block;
  padding: 2px 8px;
  border: 1px solid;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}
.tag-on { color: #2e9e5b; border-color: #b7e0c8; background: #f0f9eb; }
.tag-off { color: #909399; border-color: #d4d4d8; background: #f4f4f5; }
.btn {
  background: #fff;
  color: #2b2b2b;
  border: 1px solid #eceae6;
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 13px;
  cursor: pointer;
}
.btn-primary { background: #e8633a; color: #fff; border-color: #e8633a; }
.btn-sm { padding: 4px 10px; font-size: 12px; margin-right: 4px; }
.btn-success { background: #2e9e5b; color: #fff; border-color: #2e9e5b; }
.btn-danger { background: #d9453e; color: #fff; border-color: #d9453e; }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.muted { color: #8a8a8a; }
.actions { white-space: nowrap; }

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
  width: 480px;
  max-width: 92vw;
}
.modal.wide { width: 720px; max-width: 96vw; }
.modal h3 { margin: 0 0 16px; font-size: 16px; }
.session-row {
  display: flex;
  gap: 8px;
  margin-top: 14px;
  flex-wrap: wrap;
}
.session-row input {
  flex: 1;
  min-width: 110px;
  padding: 8px 10px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  font-size: 13px;
  box-sizing: border-box;
}
.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.form-grid label {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 13px;
  color: #8a8a8a;
}
.form-grid .full-row { grid-column: 1 / -1; }
.form-grid input, .form-grid textarea {
  padding: 8px 10px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  font-size: 13px;
  box-sizing: border-box;
  width: 100%;
  font-family: inherit;
}
.form-grid textarea { resize: vertical; }
.check-row {
  display: flex;
  gap: 20px;
  margin-top: 14px;
  font-size: 13px;
}
.check-row label { display: flex; align-items: center; gap: 6px; }
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 18px;
}
</style>
