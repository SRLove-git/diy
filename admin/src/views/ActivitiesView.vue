<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { activityApi, type Activity } from '../api/activities'
import { t } from '../i18n'

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
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
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
    alert(t('标题和活动时间不能为空', 'Title and activity time are required'))
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
    alert(e?.response?.data?.message ?? t('保存失败', 'Save failed'))
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
    alert(
      t(
        '请填写场次日期、开始和结束时间',
        'Please fill in the session date, start and end time',
      ),
    )
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
    alert(e?.response?.data?.message ?? t('添加失败', 'Add failed'))
  }
}

async function removeSession(s: NonNullable<Activity['sessions']>[number]) {
  if (
    !confirm(
      t(
        '确认删除场次 {date} {start}-{end}？',
        'Delete session {date} {start}-{end}?',
        { date: s.date, start: s.startTime, end: s.endTime },
      ),
    )
  )
    return
  try {
    await activityApi.removeSession(s.id)
    sessionList.value = sessionList.value.filter((x) => x.id !== s.id)
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
  }
}

async function toggle(a: Activity) {
  try {
    await activityApi.toggle(a.id, !a.enabled)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

async function removeActivity(a: Activity) {
  if (
    !confirm(
      t(
        '确认删除活动「{title}」？其下所有场次将一并删除。',
        'Delete activity "{title}"? All its sessions will also be deleted.',
        { title: a.title },
      ),
    )
  )
    return
  try {
    await activityApi.remove(a.id)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
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
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

onMounted(load)
</script>

<template>
  <div class="activities">
    <div class="toolbar">
      <h2>{{ $t('活动管理', 'Activities') }}</h2>
      <div class="filters">
        <button class="btn" @click="load">{{ $t('刷新', 'Refresh') }}</button>
        <button class="btn btn-primary" @click="openCreate">
          {{ $t('新增活动', 'New activity') }}
        </button>
      </div>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="activities.length === 0" class="state">
      {{ $t('暂无活动，点击「新增活动」创建', 'No activities yet. Click "New activity" to create one.') }}
    </div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width: 60px">ID</th>
          <th>{{ $t('标题', 'Title') }}</th>
          <th style="width: 130px">{{ $t('活动时间', 'Time') }}</th>
          <th>{{ $t('描述', 'Description') }}</th>
          <th style="width: 90px">{{ $t('标签', 'Tag') }}</th>
          <th style="width: 90px">{{ $t('可预约', 'Bookable') }}</th>
          <th style="width: 110px">{{ $t('价格', 'Price') }}</th>
          <th style="width: 80px">{{ $t('会员专属', 'Members only') }}</th>
          <th style="width: 60px">{{ $t('排序', 'Sort') }}</th>
          <th style="width: 80px">{{ $t('状态', 'Status') }}</th>
          <th style="width: 320px">{{ $t('操作', 'Actions') }}</th>
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
          <td>{{ a.bookable ? $t('是', 'Yes') : $t('否', 'No') }}</td>
          <td>
            <template v-if="a.bookable">
              <span v-if="a.memberPrice != null">
                {{ $t('会员 {m} / {p}', 'Member {m} / {p}', { m: a.memberPrice, p: a.price }) }}
              </span>
              <span v-else>{{ $t('{p} $/人', '{p} $/person', { p: a.price }) }}</span>
            </template>
            <span v-else class="muted">-</span>
          </td>
          <td>{{ a.membersOnly ? $t('是', 'Yes') : $t('否', 'No') }}</td>
          <td>{{ a.sort }}</td>
          <td>
            <span
              class="status-tag"
              :class="a.enabled ? 'tag-on' : 'tag-off'"
            >
              {{ a.enabled ? $t('已上架', 'Listed') : $t('已下架', 'Unlisted') }}
            </span>
          </td>
          <td class="actions">
            <button class="btn btn-sm" @click="move(a, -1)" :disabled="a.sort === 0 && a.id === activities[0].id">
              {{ $t('上移', 'Up') }}
            </button>
            <button class="btn btn-sm" @click="move(a, 1)">{{ $t('下移', 'Down') }}</button>
            <button class="btn btn-sm" @click="openSessionManager(a)">
              {{ $t('场次', 'Sessions') }}
            </button>
            <button class="btn btn-sm" @click="openEdit(a)">{{ $t('编辑', 'Edit') }}</button>
            <button
              class="btn btn-sm"
              :class="a.enabled ? 'btn-danger' : 'btn-success'"
              @click="toggle(a)"
            >
              {{ a.enabled ? $t('下架', 'Unlist') : $t('上架', 'List') }}
            </button>
            <button class="btn btn-sm btn-danger" @click="removeActivity(a)">
              {{ $t('删除', 'Delete') }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 新增/编辑弹窗 -->
    <div v-if="showForm" class="modal-overlay" @click.self="closeForm">
      <div class="modal">
        <h3>{{ editingId ? $t('编辑活动', 'Edit activity') : $t('新增活动', 'New activity') }}</h3>
        <div class="form-grid">
          <label>
            <span>{{ $t('标题', 'Title') }}</span>
            <input v-model="form.title" type="text" :placeholder="$t('如 周末拼豆沙龙', 'e.g. Weekend Bead Salon')" />
          </label>
          <label>
            <span>{{ $t('活动时间', 'Activity time') }}</span>
            <input v-model="form.date" type="text" :placeholder="$t('如 08-16 14:00 / 08-22 起', 'e.g. 08-16 14:00 / from 08-22')" />
          </label>
          <label>
            <span>{{ $t('标签', 'Tag') }}</span>
            <input v-model="form.tag" type="text" :placeholder="$t('如 限会员 / 早鸟 8 折', 'e.g. Members only / Early bird 20% off')" />
          </label>
          <label>
            <span>{{ $t('活动地址（可预约必填）', 'Address (required if bookable)') }}</span>
            <input v-model="form.address" type="text" :placeholder="$t('如 杭州市西湖区文一西路 1 号', 'e.g. 1 Wenyi West Rd, Xihu, Hangzhou')" />
          </label>
          <label>
            <span>{{ $t('纬度', 'Latitude') }}</span>
            <input v-model.number="form.lat" type="number" step="0.000001" />
          </label>
          <label>
            <span>{{ $t('经度', 'Longitude') }}</span>
            <input v-model.number="form.lng" type="number" step="0.000001" />
          </label>
          <label>
            <span>{{ $t('门市价（$/人）', 'Regular price ($/person)') }}</span>
            <input v-model.number="form.price" type="number" min="0" step="0.1" />
          </label>
          <label>
            <span>{{ $t('会员价（$/人，0 = 会员免费）', 'Member price ($/person, 0 = free for members)') }}</span>
            <input v-model.number="form.memberPrice" type="number" min="0" step="0.1" />
          </label>
          <label>
            <span>{{ $t('排序权重', 'Sort weight') }}</span>
            <input v-model.number="form.sort" type="number" min="0" />
          </label>
          <label class="full-row">
            <span>{{ $t('描述', 'Description') }}</span>
            <textarea v-model="form.desc" rows="3" :placeholder="$t('活动详情说明', 'Activity details')"></textarea>
          </label>
        </div>
        <div class="check-row">
          <label><input v-model="form.bookable" type="checkbox" /> {{ $t('可预约（进入预约流程）', 'Bookable (enter booking flow)') }}</label>
          <label><input v-model="form.membersOnly" type="checkbox" /> {{ $t('会员专属', 'Members only') }}</label>
          <label><input v-model="form.enabled" type="checkbox" /> {{ $t('立即上架', 'List now') }}</label>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeForm">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-primary" :disabled="saving" @click="save">
            {{ $t('保存', 'Save') }}
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- 场次管理 -->
  <div v-if="showSessions" class="modal-overlay" @click.self="showSessions = false">
    <div class="modal wide">
      <h3>{{ $t('场次管理 · {title}', 'Sessions · {title}', { title: currentActivity?.title ?? '' }) }}</h3>
      <table class="table">
        <thead>
          <tr>
            <th>{{ $t('日期', 'Date') }}</th>
            <th>{{ $t('开始', 'Start') }}</th>
            <th>{{ $t('结束', 'End') }}</th>
            <th>{{ $t('名额上限', 'Capacity') }}</th>
            <th style="width: 90px">{{ $t('操作', 'Actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="s in sessionList" :key="s.id">
            <td>{{ s.date }}</td>
            <td>{{ s.startTime }}</td>
            <td>{{ s.endTime }}</td>
            <td>{{ s.capacity }}</td>
            <td class="actions">
              <button class="btn btn-sm btn-danger" @click="removeSession(s)">
                {{ $t('删除', 'Delete') }}
              </button>
            </td>
          </tr>
          <tr v-if="sessionList.length === 0">
            <td colspan="5" class="muted">
              {{ $t('暂无场次，请在下方添加', 'No sessions yet. Add one below.') }}
            </td>
          </tr>
        </tbody>
      </table>
      <div class="session-row">
        <input v-model="newSession.date" type="date" />
        <input v-model="newSession.startTime" type="time" />
        <input v-model="newSession.endTime" type="time" />
        <input v-model.number="newSession.capacity" type="number" min="1" :placeholder="$t('名额', 'Capacity')" />
        <button class="btn btn-sm btn-primary" @click="addSession">
          {{ $t('添加场次', 'Add session') }}
        </button>
      </div>
      <div class="modal-actions">
        <button class="btn btn-sm btn-primary" @click="showSessions = false">
          {{ $t('完成', 'Done') }}
        </button>
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
