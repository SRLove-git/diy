<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { appointmentApi, type Appointment } from '../api/appointments'
import { storeApi, type Store } from '../api/stores'

const orders = ref<Appointment[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const statusFilter = ref('')
const storeFilter = ref('')
const dateFilter = ref('')
const page = ref(1)
const pageSize = 20
const stores = ref<Store[]>([])
const operatingId = ref<number | null>(null)
const cancelTarget = ref<Appointment | null>(null)

const totalPages = computed(() => Math.ceil(total.value / pageSize) || 1)

const statusTabs = [
  { value: '', label: '全部' },
  { value: 'booked', label: '待核销' },
  { value: 'checked_in', label: '已核销' },
  { value: 'in_service', label: '服务中' },
  { value: 'completed', label: '已完成' },
  { value: 'cancelled', label: '已取消' },
]

const statusLabels: Record<string, string> = {
  booked: '待核销',
  checked_in: '已核销',
  in_service: '服务中',
  completed: '已完成',
  cancelled: '已取消',
}

const statusColors: Record<string, string> = {
  booked: '#E8633A',
  checked_in: '#E6A23C',
  in_service: '#2E9E5B',
  completed: '#8A8A8A',
  cancelled: '#D9453E',
}

async function loadStores() {
  try {
    const { data } = await storeApi.list()
    stores.value = data
  } catch {
    stores.value = []
  }
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const params: any = { page: page.value, limit: pageSize }
    if (statusFilter.value) params.status = statusFilter.value
    if (storeFilter.value) params.storeId = storeFilter.value
    if (dateFilter.value) params.date = dateFilter.value
    const data = await appointmentApi.list(params)
    orders.value = data[0]
    total.value = data[1]
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
}

function applyFilters() {
  page.value = 1
  load()
}

function goPage(p: number) {
  if (p < 1 || p > totalPages.value) return
  page.value = p
  load()
}

async function operate(
  order: Appointment,
  action: 'checkin' | 'clockin' | 'clockout',
) {
  const prompts = {
    checkin: `确认核销预约码 ${order.code}？核销后订单将进入已核销状态。`,
    clockin: `确认预约码 ${order.code} 开始上钟？`,
    clockout: `确认预约码 ${order.code} 下钟？`,
  }
  if (!confirm(prompts[action])) return

  operatingId.value = order.id
  try {
    if (action === 'checkin') await appointmentApi.adminCheckIn(order.id)
    if (action === 'clockin') await appointmentApi.clockIn(order.id)
    if (action === 'clockout') await appointmentApi.clockOut(order.id)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  } finally {
    operatingId.value = null
  }
}

function openCancel(order: Appointment) {
  cancelTarget.value = order
}

function cancelCancel() {
  cancelTarget.value = null
}

async function confirmCancel() {
  if (!cancelTarget.value) return
  operatingId.value = cancelTarget.value.id
  try {
    await appointmentApi.adminCancel(cancelTarget.value.id)
    cancelTarget.value = null
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  } finally {
    operatingId.value = null
  }
}

function formatTime(t: string | null): string {
  if (!t) return '-'
  const d = new Date(t)
  const h = d.getHours().toString().padStart(2, '0')
  const m = d.getMinutes().toString().padStart(2, '0')
  const s = d.getSeconds().toString().padStart(2, '0')
  return `${h}:${m}:${s}`
}

function formatDuration(s: string | null, e: string | null): string {
  if (!s || !e) return '-'
  const ms = new Date(e).getTime() - new Date(s).getTime()
  const h = Math.floor(ms / 3600000).toString().padStart(2, '0')
  const m = (Math.floor(ms / 60000) % 60).toString().padStart(2, '0')
  const sec = (Math.floor(ms / 1000) % 60).toString().padStart(2, '0')
  return `${h}:${m}:${sec}`
}

function durationEnd(o: Appointment): string | null {
  // 服务中：显示到当前时刻的已用时长；已完成/已下钟：显示实际下钟时间
  return o.status === 'in_service' ? new Date().toISOString() : o.serviceEndTime
}

function bookingLabel(o: Appointment): string {
  if (o.type === 'activity') return '活动'
  if (o.bookingType === 'all_day') return '全天不限时'
  if (o.bookingType === 'package' && o.packageName) return o.packageName
  if (o.durationHours) return `${o.durationHours} 小时`
  return '按小时'
}

function fmtAmount(v: number | undefined): string {
  const value = Number(v ?? 0)
  return Number.isInteger(value) ? String(value) : value.toFixed(2)
}

onMounted(() => {
  loadStores()
  load()
})
</script>

<template>
  <div class="orders">
    <div class="toolbar">
      <h2>预约订单管理</h2>
      <div class="filters">
        <select v-model="statusFilter" @change="applyFilters">
          <option v-for="t in statusTabs" :key="t.value" :value="t.value">
            {{ t.label }}
          </option>
        </select>
        <select v-model="storeFilter" @change="applyFilters">
          <option value="">全部门店</option>
          <option v-for="s in stores" :key="s.id" :value="s.id">{{ s.name }}</option>
        </select>
        <input v-model="dateFilter" type="date" @change="applyFilters" />
        <button class="btn" @click="applyFilters">查询</button>
        <button class="btn" @click="load">刷新</button>
      </div>
    </div>

    <div v-if="loading" class="state">加载中…</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="orders.length === 0" class="state">暂无订单数据</div>

    <table v-else class="table">
      <thead>
        <tr>
          <th>预约码</th>
          <th>用户</th>
          <th>门店</th>
          <th>类型/桌位</th>
          <th>日期</th>
          <th>时段</th>
          <th>人数</th>
          <th>金额/支付</th>
          <th>备注</th>
          <th>状态</th>
          <th>核销</th>
          <th>上钟</th>
          <th>下钟</th>
          <th>时长</th>
          <th>操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="o in orders" :key="o.id">
          <td><code>{{ o.code }}</code></td>
          <td>
            <div class="user-cell">
              <span class="nickname">{{ o.userNickname || `用户 #${o.userId}` }}</span>
              <span v-if="o.userEmail" class="sub">{{ o.userEmail }}</span>
            </div>
          </td>
          <td>{{ o.storeName }}</td>
          <td>
            <span v-if="o.type === 'activity'" class="tag" style="color: #e8633a; border-color: #f3c6b6">
              活动
            </span>
            <span v-else>{{ o.tableName || '-' }}</span>
          </td>
          <td>{{ o.date }}</td>
          <td>
            {{ o.startTime }} - {{ o.endTime }}
            <span v-if="o.type !== 'activity'" class="muted">（{{ bookingLabel(o) }}）</span>
          </td>
          <td>{{ o.peopleCount }} 人</td>
          <td>
            <span :style="{ color: o.payStatus === 'paid' ? '#2e9e5b' : '#e6a23c' }">
              {{ o.payStatus === 'paid' ? '已支付' : '待支付' }} ¥{{ fmtAmount(o.amount) }}
            </span>
            <span v-if="o.payMethod" class="muted">
              （{{ o.payMethod === 'alipay' ? '支付宝' : '微信' }}）
            </span>
          </td>
          <td class="note-cell">
            <span v-if="o.note" :title="o.note" class="note">{{ o.note }}</span>
            <span v-else class="muted">-</span>
          </td>
          <td>
            <span
              class="tag"
              :style="{ color: statusColors[o.status], borderColor: statusColors[o.status] }"
            >
              {{ statusLabels[o.status] ?? o.status }}
            </span>
          </td>
          <td>{{ formatTime(o.checkInTime) }}</td>
          <td>{{ formatTime(o.serviceStartTime) }}</td>
          <td>{{ formatTime(o.serviceEndTime) }}</td>
          <td>{{ formatDuration(o.serviceStartTime, durationEnd(o)) }}</td>
          <td class="actions">
            <button
              v-if="o.status === 'booked'"
              class="btn btn-sm btn-success"
              :disabled="operatingId !== null"
              @click="operate(o, 'checkin')"
            >
              {{ operatingId === o.id ? '核销中…' : '核销' }}
            </button>
            <button
              v-if="o.status === 'checked_in'"
              class="btn btn-sm"
              :disabled="operatingId !== null"
              @click="operate(o, 'clockin')"
            >
              {{ operatingId === o.id ? '处理中…' : '上钟' }}
            </button>
            <button
              v-if="o.status === 'in_service'"
              class="btn btn-sm btn-danger"
              :disabled="operatingId !== null"
              @click="operate(o, 'clockout')"
            >
              {{ operatingId === o.id ? '处理中…' : '下钟' }}
            </button>
            <button
              v-if="o.status === 'booked' || o.status === 'checked_in'"
              class="btn btn-sm btn-cancel"
              :disabled="operatingId !== null"
              @click="openCancel(o)"
            >
              取消
            </button>
            <span v-if="o.status === 'completed' || o.status === 'cancelled'" class="muted">-</span>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 分页 -->
    <div v-if="!loading && orders.length > 0" class="pagination">
      <button class="btn btn-sm" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
      <span class="page-info">{{ page }} / {{ totalPages }}（共 {{ total }} 条）</span>
      <button class="btn btn-sm" :disabled="page >= totalPages" @click="goPage(page + 1)">下一页</button>
    </div>

    <!-- 取消确认弹窗 -->
    <div v-if="cancelTarget !== null" class="modal-overlay" @click.self="cancelCancel">
      <div class="modal">
        <h3>取消预约</h3>
        <p class="modal-desc">确认取消预约码 {{ cancelTarget.code }}？取消后用户将无法到店核销。</p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelCancel">关闭</button>
          <button class="btn btn-sm btn-danger" :disabled="operatingId !== null" @click="confirmCancel">
            确认取消
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.orders { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap; }
.toolbar h2 { margin: 0; font-size: 18px; }
.filters { display: flex; gap: 8px; flex-wrap: wrap; }
.filters select, .filters input {
  padding: 6px 12px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  font-size: 13px;
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
.table code {
  background: #f7f5f2;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 12px;
}
.user-cell { display: flex; flex-direction: column; }
.nickname { font-weight: 500; }
.sub { font-size: 11px; color: #8a8a8a; }
.note-cell { max-width: 120px; }
.note {
  display: inline-block;
  max-width: 120px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  vertical-align: middle;
}
.tag {
  display: inline-block;
  padding: 2px 8px;
  border: 1px solid;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}
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
.btn-cancel { background: #fff; color: #d9453e; border: 1px solid #f3d0cd; }
.btn:disabled { opacity: 0.55; cursor: not-allowed; }
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
.modal-desc { margin: 0 0 8px; font-size: 13px; color: #555; }
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
</style>
