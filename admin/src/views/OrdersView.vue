<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { appointmentApi, type Appointment } from '../api/appointments'

const orders = ref<Appointment[]>([])
const loading = ref(true)
const error = ref('')
const statusFilter = ref('')
const operatingId = ref<number | null>(null)

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

async function load() {
  loading.value = true
  error.value = ''
  try {
    const params: any = {}
    if (statusFilter.value) params.status = statusFilter.value
    const { data } = await appointmentApi.list(params)
    orders.value = data
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
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

onMounted(load)
</script>

<template>
  <div class="orders">
    <div class="toolbar">
      <h2>预约订单管理</h2>
      <div class="filters">
        <select v-model="statusFilter" @change="load">
          <option v-for="t in statusTabs" :key="t.value" :value="t.value">
            {{ t.label }}
          </option>
        </select>
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
          <th>门店</th>
          <th>桌位</th>
          <th>日期</th>
          <th>时段</th>
          <th>人数</th>
          <th>状态</th>
          <th>核销时间</th>
          <th>上钟</th>
          <th>下钟</th>
          <th>使用时长</th>
          <th>操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="o in orders" :key="o.id">
          <td><code>{{ o.code }}</code></td>
          <td>{{ o.storeName }}</td>
          <td>{{ o.tableName }}</td>
          <td>{{ o.date }}</td>
          <td>{{ o.startTime }} - {{ o.endTime }}</td>
          <td>{{ o.peopleCount }} 人</td>
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
          <td>{{ formatDuration(o.serviceStartTime, o.serviceEndTime) }}</td>
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
            <span v-if="o.status === 'completed' || o.status === 'cancelled'" class="muted">-</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.orders { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 18px; }
.filters { display: flex; gap: 8px; }
.filters select {
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
.tag {
  display: inline-block;
  padding: 2px 8px;
  border: 1px solid;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
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
.btn-sm { padding: 4px 10px; font-size: 12px; }
.btn-success { background: #2e9e5b; }
.btn-danger { background: #d9453e; }
.btn:disabled { opacity: 0.55; cursor: not-allowed; }
.muted { color: #8a8a8a; }
.actions { white-space: nowrap; }
</style>
