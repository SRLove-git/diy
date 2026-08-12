<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { appointmentApi, type Appointment } from '../api/appointments'
import { storeApi, type Store } from '../api/stores'
import { t } from '../i18n'

/** 看板卡片状态：服务中 / 已核销 / 今日有预约（含待确认）/ 空闲 */
type BoardStatus = 'in_service' | 'checked_in' | 'booked' | 'free'

interface BoardTable {
  id: number
  name: string
  capacity: number
  enabled: boolean
  status: BoardStatus
  /** 驱动卡片状态的那张预约单 */
  current: Appointment | null
  /** 当日覆盖该桌的全部有效预约（按开始时间升序） */
  items: Appointment[]
}

const ACTIVE_STATUSES = ['pending', 'booked', 'checked_in', 'in_service']

const statusLabels: Record<string, string> = {
  pending: '待确认',
  booked: '待核销',
  checked_in: '已核销',
  in_service: '服务中',
  completed: '已完成',
  cancelled: '已取消',
}

const statusLabelsEn: Record<string, string> = {
  pending: 'Pending',
  booked: 'To check in',
  checked_in: 'Checked in',
  in_service: 'In service',
  completed: 'Completed',
  cancelled: 'Cancelled',
}

const statusColors: Record<string, string> = {
  pending: '#8B5CF6',
  booked: '#E8633A',
  checked_in: '#E6A23C',
  in_service: '#2E9E5B',
  completed: '#8A8A8A',
  cancelled: '#D9453E',
}

const stores = ref<Store[]>([])
const storeId = ref<number | null>(null)
const date = ref(todayStr())
const orders = ref<Appointment[]>([])
const loading = ref(true)
const error = ref('')
const operatingId = ref<number | null>(null)
const detailTableId = ref<number | null>(null)
// 动态时间：服务中卡片倒计时每秒走动；看板每 30 秒静默自动刷新
const now = ref(Date.now())
let nowTimer: number | undefined
let refreshTimer: number | undefined

const currentStore = computed(
  () => stores.value.find((s) => s.id === storeId.value) ?? null,
)

const boardTables = computed<BoardTable[]>(() => {
  const tables = [...(currentStore.value?.tables ?? [])].sort((a, b) =>
    a.name.localeCompare(b.name, undefined, { numeric: true }),
  )
  return tables.map((tb) => {
    const items = orders.value
      .filter((a) => isActive(a) && coversTable(a, tb.id))
      .sort((a, b) => a.startTime.localeCompare(b.startTime))
    const current = pickCurrent(items)
    return {
      id: tb.id,
      name: tb.name,
      capacity: tb.capacity,
      enabled: tb.enabled,
      status: statusOf(current),
      current,
      items,
    }
  })
})

/** 汇总计数：停用桌位不计入空闲 */
const counts = computed(() => ({
  free: boardTables.value.filter((b) => b.enabled && b.status === 'free').length,
  inService: boardTables.value.filter((b) => b.status === 'in_service').length,
  checkedIn: boardTables.value.filter((b) => b.status === 'checked_in').length,
  booked: boardTables.value.filter((b) => b.status === 'booked').length,
}))

/** 详情弹窗跟随看板数据实时重算（操作后内容自动更新） */
const detailTable = computed(
  () => boardTables.value.find((b) => b.id === detailTableId.value) ?? null,
)

// 线下散客开台（免注册，创建即上钟）
const walkInBusy = ref(false)
const walkInPeople = ref(1)
const walkInHours = ref(2) // 0 = 全天至打烊
const walkInNote = ref('')

/** 仅今天的空闲/预订桌位可开台（开台时刻以服务端当前时间为准） */
const canWalkIn = computed(() => {
  const tb = detailTable.value
  return (
    !!tb &&
    tb.enabled &&
    date.value === todayStr() &&
    (tb.status === 'free' || tb.status === 'booked')
  )
})

/** 门店打烊时间 HH:mm（从 businessHours "10:00-22:00" 解析，失败为空串） */
const businessClose = computed(() => {
  const m = (currentStore.value?.businessHours ?? '').match(
    /(?:[01]\d|2[0-3]):[0-5]\d\s*-\s*((?:[01]\d|2[0-3]):[0-5]\d)/,
  )
  return m?.[1] ?? ''
})

/** 预计结束提示（每次渲染按当前时刻重新计算） */
function walkInEndHint(): string {
  if (walkInHours.value === 0) {
    return businessClose.value
      ? t('预计 {time} 打烊结束', 'Ends at close {time}', {
          time: businessClose.value,
        })
      : t('至打烊结束', 'Until close')
  }
  const end = new Date(Date.now() + walkInHours.value * 3600000)
  const hh = String(end.getHours()).padStart(2, '0')
  const mm = String(end.getMinutes()).padStart(2, '0')
  return t('预计 {time} 结束', 'Ends around {time}', { time: `${hh}:${mm}` })
}

async function submitWalkIn() {
  const tb = detailTable.value
  if (!tb || storeId.value === null) return
  walkInBusy.value = true
  try {
    await appointmentApi.walkIn({
      storeId: storeId.value,
      tableIds: [tb.id],
      peopleCount: walkInPeople.value,
      bookingType: walkInHours.value === 0 ? 'all_day' : 'hourly',
      durationHours: walkInHours.value === 0 ? undefined : walkInHours.value,
      note: walkInNote.value.trim() || undefined,
    })
    walkInNote.value = ''
    await fetchOrders(true)
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('开台失败', 'Failed to start service'))
  } finally {
    walkInBusy.value = false
  }
}

function todayStr(): string {
  const d = new Date()
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function isActive(a: Appointment): boolean {
  return ACTIVE_STATUSES.includes(a.status)
}

/** 桌位归属：兼容一单多桌（tables[]）与旧单桌（tableId） */
function coversTable(a: Appointment, tableId: number): boolean {
  if (a.tables && a.tables.length) return a.tables.some((x) => x.id === tableId)
  return a.tableId === tableId
}

/** 同一桌多张单时，按 服务中 > 已核销 > 最近一场预订 取驱动卡片状态的单 */
function pickCurrent(items: Appointment[]): Appointment | null {
  return (
    items.find((a) => a.status === 'in_service') ??
    items.find((a) => a.status === 'checked_in') ??
    items.find((a) => a.status === 'booked' || a.status === 'pending') ??
    null
  )
}

function statusOf(current: Appointment | null): BoardStatus {
  if (!current) return 'free'
  if (current.status === 'in_service') return 'in_service'
  if (current.status === 'checked_in') return 'checked_in'
  return 'booked'
}

function statusLabel(status: string): string {
  return t(statusLabels[status] ?? status, statusLabelsEn[status] ?? status)
}

/** 预约结束时刻：优先用核销时固化的 serviceEndTime，缺失时回退到预约时段结束 */
function endMs(a: Appointment): number {
  if (a.serviceEndTime) return new Date(a.serviceEndTime).getTime()
  return new Date(`${a.date}T${a.endTime}:00`).getTime()
}

/** 距结束倒计时；overtime=true 表示已超时（等待自动下钟） */
function countdown(a: Appointment): { text: string; overtime: boolean } {
  const diff = endMs(a) - now.value
  const abs = Math.abs(diff)
  const h = Math.floor(abs / 3600000)
  const m = Math.floor(abs / 60000) % 60
  const s = Math.floor(abs / 1000) % 60
  const pad = (n: number) => n.toString().padStart(2, '0')
  return { text: `${pad(h)}:${pad(m)}:${pad(s)}`, overtime: diff < 0 }
}

async function loadStores() {
  try {
    const { data } = await storeApi.list()
    stores.value = data
    if (storeId.value === null && data.length) storeId.value = data[0].id
  } catch {
    stores.value = []
  }
}

async function fetchOrders(silent = false) {
  if (storeId.value === null) {
    orders.value = []
    return
  }
  try {
    const [items] = await appointmentApi.list({
      storeId: storeId.value,
      date: date.value,
      limit: 500,
    })
    orders.value = items
  } catch (e: any) {
    if (!silent) {
      error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
    }
  }
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    await fetchOrders()
  } finally {
    loading.value = false
  }
}

function openDetail(tb: BoardTable) {
  detailTableId.value = tb.id
  // 开台表单默认值：人数按桌容量、时长 2 小时
  walkInPeople.value = Math.min(2, tb.capacity)
  walkInHours.value = 2
  walkInNote.value = ''
}

function closeDetail() {
  detailTableId.value = null
}

async function operate(
  order: Appointment,
  action: 'checkin' | 'clockin' | 'clockout' | 'cancel',
) {
  const prompts = {
    checkin: t(
      '确认核销预约码 {code}？核销即上钟，订单将进入服务中并开始计时。',
      'Check in booking {code}? This starts the service and the timer.',
      { code: order.code },
    ),
    clockin: t('确认预约码 {code} 开始上钟？', 'Start service for booking {code}?', {
      code: order.code,
    }),
    clockout: t('确认预约码 {code} 下钟？', 'End service for booking {code}?', {
      code: order.code,
    }),
    cancel: t(
      '确认取消预约码 {code}？取消后用户将无法到店核销。',
      'Cancel booking {code}? The customer will no longer be able to check in.',
      { code: order.code },
    ),
  }
  if (!confirm(prompts[action])) return

  operatingId.value = order.id
  try {
    if (action === 'checkin') await appointmentApi.adminCheckIn(order.id)
    if (action === 'clockin') await appointmentApi.clockIn(order.id)
    if (action === 'clockout') await appointmentApi.clockOut(order.id)
    if (action === 'cancel') await appointmentApi.adminCancel(order.id)
    await fetchOrders(true)
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    operatingId.value = null
  }
}

onMounted(async () => {
  await loadStores()
  await load()
  // 有服务中桌位时每秒走动一次倒计时
  nowTimer = window.setInterval(() => {
    if (boardTables.value.some((b) => b.status === 'in_service')) {
      now.value = Date.now()
    }
  }, 1000)
  // 每 30 秒静默刷新，状态与倒计时自动校准
  refreshTimer = window.setInterval(() => {
    fetchOrders(true)
  }, 30000)
})

onUnmounted(() => {
  if (nowTimer) clearInterval(nowTimer)
  if (refreshTimer) clearInterval(refreshTimer)
})
</script>

<template>
  <div class="board">
    <div class="toolbar">
      <h2>{{ $t('桌位看板', 'Table Board') }}</h2>
      <div class="filters">
        <select v-model="storeId" @change="load">
          <option v-for="s in stores" :key="s.id" :value="s.id">{{ s.name }}</option>
        </select>
        <input v-model="date" type="date" @change="load" />
        <button class="btn" @click="load">{{ $t('刷新', 'Refresh') }}</button>
        <span class="muted auto-hint">{{ $t('自动刷新 30s', 'Auto-refresh 30s') }}</span>
      </div>
    </div>

    <div v-if="!loading && boardTables.length" class="summary">
      <span class="chip chip-free">{{ $t('空闲', 'Free') }} {{ counts.free }}</span>
      <span class="chip chip-in-service">
        {{ $t('服务中', 'In service') }} {{ counts.inService }}
      </span>
      <span class="chip chip-checked-in">
        {{ $t('已核销', 'Checked in') }} {{ counts.checkedIn }}
      </span>
      <span class="chip chip-booked">{{ $t('预订', 'Booked') }} {{ counts.booked }}</span>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="!currentStore" class="state">
      {{ $t('暂无门店，请先到门店管理添加', 'No stores yet. Add one in Stores first.') }}
    </div>
    <div v-else-if="boardTables.length === 0" class="state">
      {{ $t('该门店暂无桌位，请先到门店管理添加', 'No tables in this store. Add them in Stores first.') }}
    </div>

    <div v-else class="grid">
      <div
        v-for="tb in boardTables"
        :key="tb.id"
        class="card"
        :class="[tb.status, { disabled: !tb.enabled }]"
        @click="openDetail(tb)"
      >
        <div class="card-head">
          <span class="name">{{ tb.name }}</span>
          <span class="cap">{{ $t('{n} 人桌', 'Seats {n}', { n: tb.capacity }) }}</span>
        </div>

        <template v-if="!tb.enabled">
          <div class="card-status">{{ $t('已停用', 'Disabled') }}</div>
        </template>

        <template v-else-if="tb.status === 'in_service' && tb.current">
          <div class="countdown" :class="{ overtime: countdown(tb.current).overtime }">
            {{ countdown(tb.current).text }}
          </div>
          <div class="countdown-label">
            {{
              countdown(tb.current).overtime
                ? $t('已超时', 'Overtime')
                : $t('剩余', 'Remaining')
            }}
          </div>
          <div class="meta">
            {{ tb.current.startTime }} - {{ tb.current.endTime }} ·
            {{ $t('{n} 人', '{n} people', { n: tb.current.peopleCount }) }}
          </div>
          <div class="meta">
            {{ tb.current.userNickname || $t('用户 #{id}', 'User #{id}', { id: tb.current.userId }) }}
          </div>
        </template>

        <template v-else-if="tb.status === 'checked_in' && tb.current">
          <div class="card-status">{{ $t('已核销 · 待上钟', 'Checked in') }}</div>
          <div class="meta">{{ tb.current.startTime }} - {{ tb.current.endTime }}</div>
        </template>

        <template v-else-if="tb.status === 'booked' && tb.current">
          <div class="card-status">
            {{ $t('{time} 预约', 'Booked {time}', { time: tb.current.startTime }) }}
          </div>
          <div class="meta">
            {{ tb.current.startTime }} - {{ tb.current.endTime }} ·
            {{ $t('{n} 人', '{n} people', { n: tb.current.peopleCount }) }}
          </div>
        </template>

        <template v-else>
          <div class="card-status">{{ $t('空闲', 'Free') }}</div>
        </template>

        <div v-if="tb.items.length > 1" class="more">
          {{ $t('今日 {n} 场', '{n} sessions today', { n: tb.items.length }) }}
        </div>
      </div>
    </div>

    <!-- 桌位详情弹窗：当日预约列表 + 快捷操作 -->
    <div v-if="detailTable" class="modal-overlay" @click.self="closeDetail">
      <div class="modal">
        <h3>{{ detailTable.name }} · {{ currentStore?.name }}</h3>
        <p class="modal-desc">
          {{ date }} ·
          {{ $t('共 {n} 场有效预约', '{n} active bookings', { n: detailTable.items.length }) }}
        </p>

        <!-- 线下散客开台：免注册直接上钟 -->
        <div v-if="canWalkIn" class="walkin">
          <div class="walkin-title">{{ $t('线下开台（散客免注册）', 'Walk-in (no account needed)') }}</div>
          <div class="walkin-row">
            <label>{{ $t('人数', 'Guests') }}</label>
            <select v-model.number="walkInPeople">
              <option v-for="n in detailTable.capacity" :key="n" :value="n">
                {{ $t('{n} 人', '{n} people', { n }) }}
              </option>
            </select>
          </div>
          <div class="walkin-row walkin-hours">
            <button
              v-for="h in [1, 2, 3, 4, 6, 8]"
              :key="h"
              class="chip-btn"
              :class="{ active: walkInHours === h }"
              @click="walkInHours = h"
            >
              {{ $t('{h} 小时', '{h} h', { h }) }}
            </button>
            <button
              class="chip-btn"
              :class="{ active: walkInHours === 0 }"
              @click="walkInHours = 0"
            >
              {{ $t('全天', 'All day') }}
            </button>
          </div>
          <div class="walkin-row">
            <input
              v-model="walkInNote"
              class="walkin-note"
              maxlength="200"
              :placeholder="$t('备注（选填，如 称呼/电话）', 'Note (optional, e.g. name/phone)')"
            />
          </div>
          <div class="walkin-row walkin-foot">
            <span class="muted">{{ walkInEndHint() }}</span>
            <button
              class="btn btn-sm btn-success"
              :disabled="walkInBusy"
              @click="submitWalkIn"
            >
              {{ walkInBusy ? $t('开台中…', 'Starting…') : $t('开台上钟', 'Start now') }}
            </button>
          </div>
        </div>
        <div v-if="detailTable.items.length === 0" class="state">
          {{ $t('当日暂无预约', 'No bookings for this date') }}
        </div>
        <div v-for="a in detailTable.items" :key="a.id" class="appt">
          <div class="appt-info">
            <div class="appt-title">
              <code>{{ a.code }}</code>
              <span
                class="tag"
                :style="{ color: statusColors[a.status], borderColor: statusColors[a.status] }"
              >
                {{ statusLabel(a.status) }}
              </span>
            </div>
            <div class="muted">
              {{ a.startTime }} - {{ a.endTime }} ·
              {{ $t('{n} 人', '{n} people', { n: a.peopleCount }) }} ·
              {{ a.userNickname || $t('用户 #{id}', 'User #{id}', { id: a.userId }) }}
            </div>
            <div v-if="a.status === 'in_service'" class="muted">
              {{
                countdown(a).overtime
                  ? $t('已超时', 'Overtime')
                  : $t('剩余', 'Remaining')
              }}
              {{ countdown(a).text }}
            </div>
          </div>
          <div class="appt-actions">
            <button
              v-if="a.status === 'booked'"
              class="btn btn-sm btn-success"
              :disabled="operatingId !== null"
              @click="operate(a, 'checkin')"
            >
              {{ operatingId === a.id ? $t('核销中…', 'Checking in…') : $t('核销', 'Check in') }}
            </button>
            <button
              v-if="a.status === 'checked_in'"
              class="btn btn-sm"
              :disabled="operatingId !== null"
              @click="operate(a, 'clockin')"
            >
              {{ operatingId === a.id ? $t('处理中…', 'Processing…') : $t('上钟', 'Start') }}
            </button>
            <button
              v-if="a.status === 'in_service'"
              class="btn btn-sm btn-danger"
              :disabled="operatingId !== null"
              @click="operate(a, 'clockout')"
            >
              {{ operatingId === a.id ? $t('处理中…', 'Processing…') : $t('下钟', 'End') }}
            </button>
            <button
              v-if="a.status === 'pending' || a.status === 'booked' || a.status === 'checked_in'"
              class="btn btn-sm btn-cancel"
              :disabled="operatingId !== null"
              @click="operate(a, 'cancel')"
            >
              {{ $t('取消', 'Cancel') }}
            </button>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeDetail">{{ $t('关闭', 'Close') }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.board { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap; }
.toolbar h2 { margin: 0; font-size: 19px; font-weight: 700; letter-spacing: 0.01em; }
.filters { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
.filters select, .filters input {
  height: 36px;
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
.filters select:hover, .filters input:hover { border-color: var(--border-strong); }
.filters select:focus, .filters input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(232, 99, 58, 0.14);
}
.auto-hint { align-self: center; font-size: 12px; }
.state { text-align: center; padding: 40px; color: var(--text-muted); }
.error { color: var(--danger); }
.muted { color: var(--text-muted); }

.summary { display: flex; gap: 8px; flex-wrap: wrap; }
.chip {
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  border: 1px solid;
  font-variant-numeric: tabular-nums;
}
.chip-free {
  color: var(--text-muted);
  border-color: var(--border-strong);
  background: var(--surface);
}
.chip-in-service {
  color: var(--success);
  border-color: rgba(46, 158, 91, 0.3);
  background: var(--success-weak);
}
.chip-checked-in {
  color: var(--warning);
  border-color: rgba(185, 126, 30, 0.32);
  background: var(--warning-weak);
}
.chip-booked {
  color: var(--primary);
  border-color: rgba(232, 99, 58, 0.32);
  background: var(--primary-weak);
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
  gap: 12px;
}
.card {
  position: relative;
  background: var(--surface);
  border: 1px solid var(--border);
  border-top: 4px solid var(--border-strong);
  border-radius: var(--radius);
  padding: 14px;
  cursor: pointer;
  box-shadow: var(--shadow-sm);
  transition:
    transform var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
  min-height: 108px;
}
.card:hover {
  transform: translateY(-1px);
  box-shadow: var(--shadow);
}
.card.in_service { border-top-color: var(--success); background: var(--success-weak); }
.card.checked_in { border-top-color: var(--warning); background: var(--warning-weak); }
.card.booked { border-top-color: var(--primary); background: var(--primary-weak); }
.card.disabled { opacity: 0.55; }
.card-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 8px;
}
.card-head .name { font-size: 20px; font-weight: 700; color: var(--text); }
.card-head .cap { font-size: 12px; color: var(--text-muted); }
.card-status { font-size: 15px; font-weight: 600; color: var(--text-muted); padding: 6px 0; }
.card.checked_in .card-status { color: var(--warning); }
.card.booked .card-status { color: var(--primary); }
.countdown {
  font-size: 28px;
  font-weight: 700;
  color: var(--success);
  font-variant-numeric: tabular-nums;
  line-height: 1.2;
}
.countdown.overtime { color: var(--danger); }
.countdown-label { font-size: 12px; color: var(--text-muted); margin-bottom: 6px; }
.meta { font-size: 12px; color: var(--text-muted); margin-top: 2px; }
.more {
  position: absolute;
  bottom: 10px;
  right: 12px;
  font-size: 11px;
  color: var(--text-muted);
}

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(41, 32, 24, 0.4);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}
.modal {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  padding: 24px;
  width: 480px;
  max-width: 90vw;
  max-height: 80vh;
  overflow-y: auto;
  animation: modal-in var(--duration) var(--ease);
}
@keyframes modal-in {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
.modal h3 { margin: 0 0 8px; font-size: 15px; font-weight: 600; }
.modal-desc { margin: 0 0 12px; font-size: 13px; color: var(--text-muted); }
.walkin {
  margin-bottom: 12px;
  padding: 12px;
  border: 1px solid rgba(46, 158, 91, 0.24);
  border-radius: var(--radius);
  background: var(--success-weak);
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.walkin-title { font-size: 13px; font-weight: 600; color: var(--success); }
.walkin-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.walkin-row label { font-size: 13px; color: var(--text-muted); }
.walkin-row select {
  height: 36px;
  padding: 0 10px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 13px;
  background: var(--surface);
  color: var(--text);
  transition:
    border-color var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
.walkin-row select:hover { border-color: var(--border-strong); }
.walkin-row select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(232, 99, 58, 0.14);
}
.walkin-hours { gap: 6px; }
.chip-btn {
  padding: 5px 12px;
  border: 1px solid var(--border-strong);
  border-radius: 999px;
  background: var(--surface);
  font-size: 12px;
  cursor: pointer;
  color: var(--text-muted);
  transition:
    background var(--duration) var(--ease),
    border-color var(--duration) var(--ease),
    color var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
.chip-btn:hover { border-color: var(--success); color: var(--success); }
.chip-btn.active {
  border-color: var(--success);
  background: var(--success);
  color: #fff;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(46, 158, 91, 0.28);
}
.walkin-note {
  flex: 1;
  height: 36px;
  padding: 0 12px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 13px;
  background: var(--surface);
  transition:
    border-color var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
.walkin-note::placeholder { color: var(--text-faint); }
.walkin-note:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(232, 99, 58, 0.14);
}
.walkin-foot { justify-content: space-between; }
.walkin-foot .muted { font-size: 12px; }
.appt {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid var(--border);
}
.appt:last-of-type { border-bottom: none; }
.appt-info { display: flex; flex-direction: column; gap: 4px; font-size: 13px; }
.appt-title { display: flex; align-items: center; gap: 8px; }
.appt-info code {
  background: var(--surface-muted);
  border: 1px solid var(--border);
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.04em;
}
.tag {
  display: inline-block;
  padding: 2px 10px;
  border: 1px solid;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}
.appt-actions { white-space: nowrap; }
.btn {
  background: var(--primary);
  color: #fff;
  border: none;
  border-radius: var(--radius-sm);
  padding: 8px 16px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  box-shadow: var(--shadow-sm);
  transition:
    background var(--duration) var(--ease),
    transform var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease),
    filter var(--duration) var(--ease);
}
.btn:hover:not(:disabled) {
  background: var(--primary-hover);
  transform: translateY(-1px);
  box-shadow: var(--shadow);
}
.btn:active:not(:disabled) {
  background: var(--primary-active);
  transform: translateY(0);
  box-shadow: var(--shadow-sm);
}
.btn-sm { padding: 4px 10px; font-size: 12px; margin-right: 4px; }
.btn-success { background: var(--success); }
.btn-success:hover:not(:disabled) { background: var(--success); filter: brightness(1.07); }
.btn-success:active:not(:disabled) { background: var(--success); filter: brightness(0.94); }
.btn-danger { background: var(--danger); }
.btn-danger:hover:not(:disabled) { background: var(--danger); filter: brightness(1.07); }
.btn-danger:active:not(:disabled) { background: var(--danger); filter: brightness(0.94); }
.btn-cancel {
  background: var(--surface);
  color: var(--danger);
  border: 1px solid rgba(217, 69, 62, 0.3);
  box-shadow: none;
}
.btn-cancel:hover:not(:disabled) {
  background: var(--danger-weak);
  border-color: rgba(217, 69, 62, 0.45);
}
.btn:disabled { opacity: 0.55; cursor: not-allowed; box-shadow: none; }
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
</style>
