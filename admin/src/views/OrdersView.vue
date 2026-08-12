<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref } from 'vue'
import jsQR from 'jsqr'
import { appointmentApi, type Appointment } from '../api/appointments'
import { memberApi, type UserCoupon } from '../api/members'
import { storeApi, type Store } from '../api/stores'
import { refreshPending } from '../stores/pending'
import { i18n, t } from '../i18n'

const orders = ref<Appointment[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const statusFilter = ref('')
const storeFilter = ref('')
const dateFilter = ref('')
const keywordFilter = ref('')
const codeFilter = ref('')
const page = ref(1)
const pageSize = 20
const stores = ref<Store[]>([])
const operatingId = ref<number | null>(null)
const cancelTarget = ref<Appointment | null>(null)
const checkinCode = ref('')
const checkinBusy = ref(false)
const checkinResult = ref<Appointment | null>(null)
const showCheckinModal = ref(false)
const checkinError = ref('')
// 优惠券核销（订单页直接核销优惠券）
const couponRedeemOpen = ref(false)
const couponRedeemCode = ref('')
const couponQuerying = ref(false)
const couponBusy = ref(false)
const couponResult = ref<UserCoupon | null>(null)
const couponError = ref('')
// 扫码核销
const showScanModal = ref(false)
const scanError = ref('')
const scanning = ref(false)
const scanVideoEl = ref<HTMLVideoElement | null>(null)
let scanStream: MediaStream | null = null
let scanTimer: number | undefined
// 动态时间：服务中订单时长每秒走动；列表每 30 秒静默自动刷新
const now = ref(Date.now())
let nowTimer: number | undefined
let refreshTimer: number | undefined

const totalPages = computed(() => Math.ceil(total.value / pageSize) || 1)

const statusTabs = [
  { value: '', label: '全部', labelEn: 'All' },
  { value: 'pending', label: '待确认', labelEn: 'Pending' },
  { value: 'booked', label: '待核销', labelEn: 'To check in' },
  { value: 'checked_in', label: '已核销', labelEn: 'Checked in' },
  { value: 'in_service', label: '服务中', labelEn: 'In service' },
  { value: 'completed', label: '已完成', labelEn: 'Completed' },
  { value: 'cancelled', label: '已取消', labelEn: 'Cancelled' },
]

const statusLabels: Record<string, string> = {
  pending: '待确认',
  booked: '待核销',
  checked_in: '已核销',
  in_service: '服务中',
  completed: '已完成',
  cancelled: '已取消',
}

const statusColors: Record<string, string> = {
  pending: '#8B5CF6',
  booked: '#E8633A',
  checked_in: '#E6A23C',
  in_service: '#2E9E5B',
  completed: '#8A8A8A',
  cancelled: '#D9453E',
}

const statusLabelsEn: Record<string, string> = {
  pending: 'Pending',
  booked: 'To check in',
  checked_in: 'Checked in',
  in_service: 'In service',
  completed: 'Completed',
  cancelled: 'Cancelled',
}

function statusLabel(status: string): string {
  return t(statusLabels[status] ?? status, statusLabelsEn[status] ?? status)
}

async function loadStores() {
  try {
    const { data } = await storeApi.list()
    stores.value = data
  } catch {
    stores.value = []
  }
}

async function fetchOrders(silent = false) {
  try {
    const params: any = { page: page.value, limit: pageSize }
    if (statusFilter.value) params.status = statusFilter.value
    if (storeFilter.value) params.storeId = storeFilter.value
    if (dateFilter.value) params.date = dateFilter.value
    if (keywordFilter.value.trim()) params.keyword = keywordFilter.value.trim()
    if (codeFilter.value.trim()) params.code = codeFilter.value.trim()
    const data = await appointmentApi.list(params)
    orders.value = data[0]
    total.value = data[1]
  } catch (e: any) {
    if (!silent) error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
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
  action: 'confirm' | 'checkin' | 'clockin' | 'clockout',
) {
  const prompts = {
    confirm: t(
      '确认预约码 {code} 的预约？确认后顾客可到店核销。',
      'Confirm the booking with code {code}? The customer can then check in at the store.',
      { code: order.code },
    ),
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
  }
  if (!confirm(prompts[action])) return

  operatingId.value = order.id
  try {
    if (action === 'confirm') await appointmentApi.adminConfirm(order.id)
    if (action === 'checkin') await appointmentApi.adminCheckIn(order.id)
    if (action === 'clockin') await appointmentApi.clockIn(order.id)
    if (action === 'clockout') await appointmentApi.clockOut(order.id)
    await load()
    await refreshPending()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    operatingId.value = null
  }
}

/** 输入核销码核销（核销即上钟，结束时间固定为预约时段） */
function openCheckinModal() {
  checkinCode.value = ''
  checkinError.value = ''
  checkinResult.value = null
  showCheckinModal.value = true
}

/** 打开扫码弹窗并启动摄像头 */
function openScanModal() {
  showScanModal.value = true
  scanError.value = ''
  scanning.value = false
  nextTick(startScanner)
}

async function startScanner() {
  try {
    scanStream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: 'environment' },
      audio: false,
    })
    const video = scanVideoEl.value
    if (!video) {
      stopScanner()
      return
    }
    video.srcObject = scanStream
    await video.play()
    scanning.value = true
    scanTimer = window.setInterval(scanFrame, 200)
  } catch (e) {
    scanError.value = cameraErrorText(e)
  }
}

/** 区分摄像头打不开的具体原因，给出可执行的提示 */
function cameraErrorText(err: unknown): string {
  // HTTP（非 localhost）不是安全来源，浏览器不提供摄像头 API，此时必须先解决访问协议
  if (!window.isSecureContext) {
    return t(
      '当前页面不是安全来源（需 HTTPS 或 localhost），浏览器禁止网页使用摄像头。请用 https:// 访问后台，或使用手动输入核销码。',
      'This page is not a secure context (HTTPS or localhost is required), so the browser blocks camera access. Open the admin via https:// or enter the code manually.',
    )
  }
  const name = err instanceof DOMException ? err.name : ''
  if (name === 'NotAllowedError' || name === 'PermissionDeniedError') {
    return t(
      '摄像头权限被拒绝。请在浏览器地址栏的网站设置中允许摄像头后重试，或使用手动输入核销码。',
      'Camera permission was denied. Allow camera access in the site settings and retry, or enter the code manually.',
    )
  }
  if (name === 'NotFoundError' || name === 'OverconstrainedError') {
    return t(
      '未检测到可用摄像头，请连接摄像头后重试，或使用手动输入核销码。',
      'No camera found. Connect a camera and retry, or enter the code manually.',
    )
  }
  if (name === 'NotReadableError') {
    return t(
      '摄像头被其他程序占用，请关闭占用程序后重试，或使用手动输入核销码。',
      'The camera is in use by another app. Close it and retry, or enter the code manually.',
    )
  }
  return t(
    '无法打开摄像头（{reason}），请检查浏览器权限，或使用手动输入核销码',
    'Unable to open the camera ({reason}). Check browser permissions or enter the code manually.',
    { reason: name || 'unknown' },
  )
}

function scanFrame() {
  const video = scanVideoEl.value
  if (!video || video.readyState < 2) return
  const canvas = document.createElement('canvas')
  canvas.width = video.videoWidth
  canvas.height = video.videoHeight
  const ctx = canvas.getContext('2d', { willReadFrequently: true })
  if (!ctx) return
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height)
  const img = ctx.getImageData(0, 0, canvas.width, canvas.height)
  const result = jsQR(img.data, img.width, img.height)
  // App 端预约码/优惠券二维码内容就是 6 位核销码
  if (result && /^[A-Z0-9]{6}$/i.test(result.data)) {
    stopScanner()
    showScanModal.value = false
    handleScannedCode(result.data)
  }
}

/** 扫码结果分流：先按优惠券核销码识别，命中则进入优惠券核销，否则按预约码核销 */
async function handleScannedCode(raw: string) {
  const code = raw.trim().toUpperCase()
  try {
    const { data } = await memberApi.findCouponByCode(code)
    openCouponRedeem()
    couponRedeemCode.value = code
    couponResult.value = data
  } catch (e: any) {
    // 400：是优惠券码但已核销/已过期，打开优惠券弹窗展示原因；否则按预约码处理
    if (e?.response?.status === 400) {
      openCouponRedeem()
      couponRedeemCode.value = code
      couponError.value = e?.response?.data?.message ?? t('查询失败', 'Query failed')
    } else {
      openCheckinModal()
      checkinCode.value = code
    }
  }
}

function stopScanner() {
  if (scanTimer) {
    clearInterval(scanTimer)
    scanTimer = undefined
  }
  if (scanStream) {
    scanStream.getTracks().forEach((t) => t.stop())
    scanStream = null
  }
  if (scanVideoEl.value) scanVideoEl.value.srcObject = null
}

function closeScanModal() {
  stopScanner()
  showScanModal.value = false
}

function closeCheckinModal() {
  showCheckinModal.value = false
  checkinResult.value = null
}

function resetCheckin() {
  checkinCode.value = ''
  checkinError.value = ''
  checkinResult.value = null
}

async function checkInByCode() {
  const code = checkinCode.value.trim()
  if (!/^[A-Za-z0-9]{6}$/.test(code)) {
    checkinError.value = t(
      '请输入 6 位数字或字母核销码',
      'Please enter the 6-character check-in code',
    )
    return
  }
  checkinBusy.value = true
  checkinError.value = ''
  try {
    const result = await appointmentApi.checkInByCode(code)
    checkinResult.value = result
    await load()
  } catch (e: any) {
    checkinError.value = e?.response?.data?.message ?? t('核销失败', 'Check-in failed')
  } finally {
    checkinBusy.value = false
  }
}

/** 优惠券核销：打开弹窗 */
function openCouponRedeem() {
  couponRedeemCode.value = ''
  couponResult.value = null
  couponError.value = ''
  couponRedeemOpen.value = true
}

function closeCouponRedeem() {
  couponRedeemOpen.value = false
  couponRedeemCode.value = ''
  couponResult.value = null
  couponError.value = ''
}

/** 查询优惠券（先确认再核销） */
async function queryCouponRedeem() {
  const code = couponRedeemCode.value.trim()
  if (!/^[A-Za-z0-9]{6}$/.test(code)) {
    couponError.value = t(
      '请输入 6 位数字或字母核销码',
      'Please enter the 6-character code',
    )
    return
  }
  couponQuerying.value = true
  couponError.value = ''
  couponResult.value = null
  try {
    const { data } = await memberApi.findCouponByCode(code)
    couponResult.value = data
  } catch (e: any) {
    couponError.value = e?.response?.data?.message ?? t('查询失败', 'Query failed')
  } finally {
    couponQuerying.value = false
  }
}

async function confirmCouponRedeem() {
  couponBusy.value = true
  couponError.value = ''
  try {
    couponResult.value = await memberApi.redeemCouponByCode(
      couponRedeemCode.value.trim(),
    )
  } catch (e: any) {
    couponError.value = e?.response?.data?.message ?? t('核销失败', 'Redeem failed')
  } finally {
    couponBusy.value = false
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
    await refreshPending()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
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

function formatDateTime(value: string): string {
  try {
    return new Date(value).toLocaleString(i18n.lang === 'en' ? 'en-US' : 'zh-CN')
  } catch {
    return value
  }
}

function formatDuration(s: string | null, e: string | null): string {
  if (!s || !e) return '-'
  const start = new Date(s).getTime()
  const end = new Date(e).getTime()
  if (!Number.isFinite(start) || !Number.isFinite(end)) return '-'
  // 服务端/浏览器时钟偏差或异常数据可能让结束早于开始，按 0 处理，避免显示负数
  const ms = Math.max(0, end - start)
  const h = Math.floor(ms / 3600000).toString().padStart(2, '0')
  const m = (Math.floor(ms / 60000) % 60).toString().padStart(2, '0')
  const sec = (Math.floor(ms / 1000) % 60).toString().padStart(2, '0')
  return `${h}:${m}:${sec}`
}

function durationEnd(o: Appointment): string | null {
  // 服务中：显示到当前时刻的已用时长；已完成/已下钟：显示实际下钟时间
  return o.status === 'in_service' ? new Date(now.value).toISOString() : o.serviceEndTime
}

function bookingLabel(o: Appointment): string {
  if (o.type === 'activity') return t('活动', 'Activity')
  if (o.bookingType === 'all_day') return t('全天不限时', 'All-day')
  if (o.bookingType === 'package' && o.packageName) return o.packageName
  if (o.durationHours) return t('{h} 小时', '{h} h', { h: o.durationHours })
  return t('按小时', 'Hourly')
}

function tableLabel(o: Appointment): string {
  if (o.tables && o.tables.length) {
    return o.tables.map((t) => t.name).join(' + ')
  }
  return o.tableName || '-'
}

// 线下支付，金额/支付列已隐藏，格式化函数一并注释
// function fmtAmount(v: number | undefined): string {
//   const value = Number(v ?? 0)
//   return Number.isInteger(value) ? String(value) : value.toFixed(2)
// }

onMounted(() => {
  loadStores()
  load()
  // 有服务中订单时每秒走动一次计时
  nowTimer = window.setInterval(() => {
    if (orders.value.some((o) => o.status === 'in_service')) {
      now.value = Date.now()
    }
  }, 1000)
  // 每 30 秒静默刷新列表，状态与时间自动更新
  refreshTimer = window.setInterval(() => {
    fetchOrders(true)
  }, 30000)
})

onUnmounted(() => {
  if (nowTimer) clearInterval(nowTimer)
  if (refreshTimer) clearInterval(refreshTimer)
  stopScanner()
})
</script>

<template>
  <div class="orders">
    <div class="toolbar">
      <h2>{{ $t('预约订单管理', 'Appointment Orders') }}</h2>
      <div class="filters">
        <select v-model="statusFilter" @change="applyFilters">
          <option v-for="t in statusTabs" :key="t.value" :value="t.value">
            {{ $t(t.label, t.labelEn) }}
          </option>
        </select>
        <select v-model="storeFilter" @change="applyFilters">
          <option value="">{{ $t('全部门店', 'All stores') }}</option>
          <option v-for="s in stores" :key="s.id" :value="s.id">{{ s.name }}</option>
        </select>
        <input v-model="dateFilter" type="date" @change="applyFilters" />
        <input
          v-model="keywordFilter"
          :placeholder="$t('搜索用户（用户名/邮箱/昵称）', 'Search user (username/email/nickname)')"
          @keyup.enter="applyFilters"
        />
        <input
          v-model="codeFilter"
          class="code-search"
          :placeholder="$t('核销码', 'Check-in code')"
          maxlength="6"
          @keyup.enter="applyFilters"
        />
        <button
          class="btn btn-success checkin-entry"
          @click="openCheckinModal"
        >
          {{ $t('核销码核销', 'Check in by code') }}
        </button>
        <button class="btn btn-success scan-entry" @click="openScanModal">
          {{ $t('扫码核销', 'Scan QR') }}
        </button>
        <button class="btn btn-success coupon-entry" @click="openCouponRedeem">
          {{ $t('优惠券核销', 'Redeem coupon') }}
        </button>
        <button class="btn" @click="applyFilters">{{ $t('查询', 'Search') }}</button>
        <button class="btn" @click="load">{{ $t('刷新', 'Refresh') }}</button>
        <span class="muted auto-hint">{{ $t('自动刷新 30s', 'Auto-refresh 30s') }}</span>
      </div>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="orders.length === 0" class="state">
      {{ $t('暂无订单数据', 'No orders yet') }}
    </div>

    <table v-else class="table">
      <thead>
        <tr>
          <th>{{ $t('预约码', 'Code') }}</th>
          <th>{{ $t('用户', 'User') }}</th>
          <th>{{ $t('门店', 'Store') }}</th>
          <th>{{ $t('类型/桌位', 'Type/Table') }}</th>
          <th>{{ $t('日期', 'Date') }}</th>
          <th>{{ $t('时段', 'Time') }}</th>
          <th>{{ $t('人数', 'Guests') }}</th>
          <!-- 线下支付，金额/支付列先隐藏 -->
          <!-- <th>金额/支付</th> -->
          <th>{{ $t('备注', 'Note') }}</th>
          <th>{{ $t('状态', 'Status') }}</th>
          <th>{{ $t('核销', 'Checked in') }}</th>
          <th>{{ $t('上钟', 'Started') }}</th>
          <th>{{ $t('下钟', 'Ended') }}</th>
          <th>{{ $t('时长', 'Duration') }}</th>
          <th>{{ $t('操作', 'Actions') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="o in orders" :key="o.id">
          <td><code>{{ o.code }}</code></td>
          <td>
            <div class="user-cell">
              <span class="nickname">
                {{ o.userNickname || $t('用户 #{id}', 'User #{id}', { id: o.userId }) }}
              </span>
              <span v-if="o.userEmail" class="sub">{{ o.userEmail }}</span>
            </div>
          </td>
          <td>{{ o.storeName }}</td>
          <td>
            <span v-if="o.type === 'activity'" class="tag tag-activity">
              {{ $t('活动', 'Activity') }}
            </span>
            <span v-else>{{ tableLabel(o) }}</span>
          </td>
          <td>{{ o.date }}</td>
          <td>
            {{ o.startTime }} - {{ o.endTime }}
            <span v-if="o.type !== 'activity'" class="muted">（{{ bookingLabel(o) }}）</span>
          </td>
          <td>{{ $t('{n} 人', '{n} people', { n: o.peopleCount }) }}</td>
          <!-- 线下支付，金额/支付列先隐藏 -->
          <!-- <td>
            <span :style="{ color: o.payStatus === 'paid' ? '#2e9e5b' : '#e6a23c' }">
              {{ o.payStatus === 'paid' ? '已支付' : '待支付' }} ${{ fmtAmount(o.amount) }}
            </span>
            <span v-if="o.payMethod" class="muted">
              （{{ o.payMethod === 'alipay' ? '支付宝' : '微信' }}）
            </span>
          </td> -->
          <td class="note-cell">
            <span v-if="o.note" :title="o.note" class="note">{{ o.note }}</span>
            <span v-else class="muted">-</span>
          </td>
          <td>
            <span
              class="tag"
              :style="{ color: statusColors[o.status], borderColor: statusColors[o.status] }"
            >
              {{ statusLabel(o.status) }}
            </span>
          </td>
          <td>{{ formatTime(o.checkInTime) }}</td>
          <td>{{ formatTime(o.serviceStartTime) }}</td>
          <td>{{ formatTime(o.serviceEndTime) }}</td>
          <td>{{ formatDuration(o.serviceStartTime, durationEnd(o)) }}</td>
          <td class="actions">
            <button
              v-if="o.status === 'pending'"
              class="btn btn-sm btn-success"
              :disabled="operatingId !== null"
              @click="operate(o, 'confirm')"
            >
              {{ operatingId === o.id ? $t('确认中…', 'Confirming…') : $t('确认', 'Confirm') }}
            </button>
            <button
              v-if="o.status === 'booked'"
              class="btn btn-sm btn-success"
              :disabled="operatingId !== null"
              @click="operate(o, 'checkin')"
            >
              {{ operatingId === o.id ? $t('核销中…', 'Checking in…') : $t('核销', 'Check in') }}
            </button>
            <button
              v-if="o.status === 'checked_in'"
              class="btn btn-sm"
              :disabled="operatingId !== null"
              @click="operate(o, 'clockin')"
            >
              {{ operatingId === o.id ? $t('处理中…', 'Processing…') : $t('上钟', 'Start') }}
            </button>
            <button
              v-if="o.status === 'in_service'"
              class="btn btn-sm btn-danger"
              :disabled="operatingId !== null"
              @click="operate(o, 'clockout')"
            >
              {{ operatingId === o.id ? $t('处理中…', 'Processing…') : $t('下钟', 'End') }}
            </button>
            <button
              v-if="o.status === 'pending' || o.status === 'booked' || o.status === 'checked_in'"
              class="btn btn-sm btn-cancel"
              :disabled="operatingId !== null"
              @click="openCancel(o)"
            >
              {{ $t('取消', 'Cancel') }}
            </button>
            <span v-if="o.status === 'completed' || o.status === 'cancelled'" class="muted">-</span>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 分页 -->
    <div v-if="!loading && orders.length > 0" class="pagination">
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

    <!-- 扫码核销弹窗 -->
    <div v-if="showScanModal" class="modal-overlay" @click.self="closeScanModal">
      <div class="modal scan-modal">
        <h3>{{ $t('扫码核销', 'Scan QR to check in') }}</h3>
        <p class="modal-desc">
          {{ $t('将摄像头对准顾客出示的预约码或优惠券二维码，识别后自动进入对应的核销流程。', 'Point the camera at the customer booking or coupon QR code; it will start the matching redemption flow automatically.') }}
        </p>
        <div class="scan-box">
          <video ref="scanVideoEl" autoplay playsinline muted></video>
          <div v-if="scanError" class="scan-error">{{ scanError }}</div>
          <div v-else-if="scanning" class="scan-tip">
            {{ $t('正在识别二维码…', 'Scanning QR code…') }}
          </div>
        </div>
        <div class="scan-manual">
          <span class="muted">{{ $t('无法扫码？', 'Cannot scan?') }}</span>
          <button class="btn btn-sm" @click="closeScanModal(); openCheckinModal()">
            {{ $t('手动输入核销码', 'Enter code manually') }}
          </button>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeScanModal">{{ $t('取消', 'Cancel') }}</button>
        </div>
      </div>
    </div>

    <!-- 核销码核销弹窗：输入核销码 → 核销成功展示订单信息 -->
    <div v-if="showCheckinModal" class="modal-overlay" @click.self="closeCheckinModal">
      <div class="modal checkin-modal">
        <template v-if="checkinResult === null">
          <h3>{{ $t('核销码核销', 'Check in by code') }}</h3>
          <p class="modal-desc">
            {{ $t('输入顾客出示的 6 位数字或字母核销码，核销即上钟开始计时，结束时间固定为预约时段。', 'Enter the 6-character code shown by the customer. Check-in starts the timer; the end time stays fixed.') }}
          </p>
          <input
            v-model="checkinCode"
            class="checkin-input"
            type="text"
            maxlength="6"
            :placeholder="$t('请输入核销码', 'Enter check-in code')"
            autofocus
            @input="checkinCode = checkinCode.toUpperCase()"
            @keyup.enter="checkInByCode"
          />
          <p v-if="checkinError" class="checkin-error">{{ checkinError }}</p>
          <div class="modal-actions">
            <button class="btn btn-sm" @click="closeCheckinModal">{{ $t('取消', 'Cancel') }}</button>
            <button
              class="btn btn-sm btn-success"
              :disabled="checkinBusy || checkinCode.trim().length !== 6"
              @click="checkInByCode"
            >
              {{ checkinBusy ? $t('核销中…', 'Checking in…') : $t('立即核销', 'Check in now') }}
            </button>
          </div>
        </template>
        <template v-else>
          <h3>{{ $t('核销成功', 'Checked in') }}</h3>
          <div class="result-info">
            <p><span class="muted">{{ $t('预约码', 'Code') }}</span> <code>{{ checkinResult.code }}</code></p>
            <p><span class="muted">{{ $t('门店', 'Store') }}</span> {{ checkinResult.storeName }}</p>
            <p>
              <span class="muted">{{ $t('桌位 / 人数', 'Table / Guests') }}</span>
              {{ tableLabel(checkinResult) }} · {{ $t('{n} 人', '{n} people', { n: checkinResult.peopleCount }) }}
            </p>
            <p>
              <span class="muted">{{ $t('时间', 'Time') }}</span>
              {{ checkinResult.date }} {{ checkinResult.startTime }}-{{ checkinResult.endTime }}
            </p>
            <p v-if="checkinResult.couponTitle">
              <span class="muted">{{ $t('优惠券', 'Coupon') }}</span>
              {{ checkinResult.couponTitle }}（-{{ checkinResult.couponDiscount }}）
              · <span style="color: #2e9e5b">{{ $t('已一并核销', 'Redeemed together') }}</span>
            </p>
            <p>
              <span class="muted">{{ $t('状态', 'Status') }}</span>
              <span class="tag" style="color: #2e9e5b; border-color: #2e9e5b">
                {{ $t('服务中（已开始计时）', 'In service (timer started)') }}
              </span>
            </p>
          </div>
          <div class="modal-actions">
            <button class="btn btn-sm" @click="resetCheckin">{{ $t('继续核销', 'Check in another') }}</button>
            <button class="btn btn-sm btn-success" @click="closeCheckinModal">
              {{ $t('完成', 'Done') }}
            </button>
          </div>
        </template>
      </div>
    </div>

    <!-- 优惠券核销弹窗：输入优惠券核销码 → 查询确认 → 核销 -->
    <div v-if="couponRedeemOpen" class="modal-overlay" @click.self="closeCouponRedeem">
      <div class="modal">
        <h3>{{ $t('优惠券核销', 'Redeem coupon') }}</h3>
        <p class="modal-desc">
          {{ $t('输入顾客卡包中的 6 位数字或字母核销码，先查询确认，再点击核销。', 'Enter the 6-character code from the customer wallet to confirm, then redeem.') }}
        </p>
        <div class="redeem-row">
          <input
            v-model="couponRedeemCode"
            type="text"
            maxlength="6"
            :placeholder="$t('6 位数字或字母核销码', '6-character code')"
            @input="couponRedeemCode = couponRedeemCode.toUpperCase()"
            @keyup.enter="queryCouponRedeem"
          />
          <button class="btn btn-sm" :disabled="couponQuerying" @click="queryCouponRedeem">
            {{ couponQuerying ? $t('查询中…', 'Querying…') : $t('查询', 'Query') }}
          </button>
        </div>
        <p v-if="couponError" class="redeem-error">{{ couponError }}</p>
        <div v-if="couponResult" class="redeem-result">
          <div class="redeem-line">
            <span>{{ $t('用户', 'User') }}</span>
            <strong>
              {{ couponResult.userNickname || $t('用户 #{id}', 'User #{id}', { id: couponResult.userId }) }}
            </strong>
          </div>
          <div class="redeem-line">
            <span>{{ $t('优惠券', 'Coupon') }}</span>
            <strong>{{ couponResult.couponTitle }}（{{ couponResult.couponAmount }}）</strong>
          </div>
          <div class="redeem-line">
            <span>{{ $t('门槛', 'Threshold') }}</span>
            <strong>{{ couponResult.couponThreshold }}</strong>
          </div>
          <div class="redeem-line">
            <span>{{ $t('到期时间', 'Expires') }}</span>
            <strong>{{ formatDateTime(couponResult.expireAt) }}</strong>
          </div>
          <div class="redeem-line">
            <span>{{ $t('状态', 'Status') }}</span>
            <strong v-if="couponResult.status === 'used'" class="redeem-used">
              {{ $t('已核销', 'Redeemed') }}
            </strong>
            <strong v-else class="redeem-ok">
              {{ $t('可核销', 'Ready to redeem') }}
            </strong>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeCouponRedeem">{{ $t('取消', 'Cancel') }}</button>
          <button
            class="btn btn-sm btn-success"
            :disabled="couponBusy || !couponResult || couponResult.status === 'used'"
            @click="confirmCouponRedeem"
          >
            {{ couponBusy ? $t('核销中…', 'Redeeming…') : $t('确认核销', 'Confirm redeem') }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="cancelTarget !== null" class="modal-overlay" @click.self="cancelCancel">
      <div class="modal">
        <h3>{{ $t('取消预约', 'Cancel booking') }}</h3>
        <p class="modal-desc">
          {{ $t('确认取消预约码 {code}？取消后用户将无法到店核销。', 'Cancel booking {code}? The customer will no longer be able to check in.', { code: cancelTarget.code }) }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelCancel">{{ $t('关闭', 'Close') }}</button>
          <button class="btn btn-sm btn-danger" :disabled="operatingId !== null" @click="confirmCancel">
            {{ $t('确认取消', 'Confirm cancel') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.orders { display: flex; flex-direction: column; gap: 16px; }
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
.filters input::placeholder { color: var(--text-faint); }
.filters .auto-hint { font-size: 12px; }
.filters .code-search {
  width: 90px;
  letter-spacing: 1px;
  font-variant-numeric: tabular-nums;
}
.filters .checkin-entry {
  padding: 9px 22px;
  font-size: 14px;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(46, 158, 91, 0.24);
}
.filters .checkin-entry:hover:not(:disabled) {
  box-shadow: 0 6px 16px rgba(46, 158, 91, 0.3);
}
.filters .scan-entry {
  padding: 9px 18px;
  font-size: 14px;
  font-weight: 600;
}
.filters .coupon-entry {
  padding: 9px 18px;
  font-size: 14px;
  font-weight: 600;
}
.state { text-align: center; padding: 40px; color: var(--text-muted); }
.error { color: var(--danger); }
.table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  font-size: 13px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}
.table th, .table td {
  padding: 10px 10px;
  border-bottom: 1px solid var(--border);
  text-align: left;
  vertical-align: middle;
}
.table th:first-child, .table td:first-child { padding-left: 16px; }
.table th:last-child, .table td:last-child { padding-right: 16px; }
.table tbody tr { transition: background var(--duration) var(--ease); }
.table tbody tr:hover { background: var(--surface-muted); }
.table tbody tr:last-child td { border-bottom: none; }
.table th {
  background: var(--surface-muted);
  font-size: 12px;
  font-weight: 600;
  color: var(--text-muted);
  letter-spacing: 0.02em;
  white-space: nowrap;
}
.table td { font-variant-numeric: tabular-nums; }
.table code {
  background: var(--surface-muted);
  border: 1px solid var(--border);
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.04em;
}
.user-cell { display: flex; flex-direction: column; }
.nickname { font-weight: 500; }
.sub { font-size: 11px; color: var(--text-muted); }
.note-cell { max-width: 120px; }
.note {
  display: inline-block;
  max-width: 120px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  vertical-align: middle;
  color: var(--text-muted);
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
.tag-activity { background: var(--primary-weak); color: var(--primary); border-color: transparent; }
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
  width: 400px;
  max-width: 90vw;
  animation: modal-in var(--duration) var(--ease);
}
@keyframes modal-in {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
.modal h3 { margin: 0 0 16px; font-size: 15px; font-weight: 600; }
.modal-desc { margin: 0 0 8px; font-size: 13px; color: var(--text-muted); }
.checkin-modal .checkin-input {
  width: 100%;
  height: 56px;
  margin: 12px 0 4px;
  border: 2px solid var(--success);
  border-radius: var(--radius);
  background: var(--surface-muted);
  text-align: center;
  font-size: 26px;
  font-weight: 700;
  letter-spacing: 10px;
  color: var(--text);
  font-variant-numeric: tabular-nums;
  outline: none;
  transition:
    border-color var(--duration) var(--ease),
    background var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
.checkin-modal .checkin-input:focus {
  background: var(--surface);
  box-shadow: 0 0 0 4px rgba(46, 158, 91, 0.14);
}
.checkin-modal .checkin-error {
  margin: 8px 0 0;
  color: var(--danger);
  background: var(--danger-weak);
  border-radius: var(--radius-sm);
  padding: 8px 12px;
  font-size: 13px;
}
.redeem-row {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-top: 12px;
}
.redeem-row input {
  flex: 1;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  padding: 10px 12px;
  font-size: 18px;
  letter-spacing: 3px;
  text-transform: uppercase;
  box-sizing: border-box;
  background: var(--surface);
  color: var(--text);
  outline: none;
}
.redeem-row input:focus {
  border-color: var(--success);
  box-shadow: 0 0 0 3px rgba(46, 158, 91, 0.14);
}
.redeem-error { color: var(--danger); font-size: 13px; margin: 10px 0 0; }
.redeem-result {
  margin-top: 16px;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 12px 14px;
  background: var(--surface-muted);
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.redeem-line {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  font-size: 13px;
}
.redeem-line span { color: var(--text-muted); }
.redeem-line strong { color: var(--text); text-align: right; }
.redeem-ok { color: #2e9e5b; }
.redeem-used { color: #d9453e; }
.scan-modal .scan-box {
  position: relative;
  margin: 12px 0 10px;
  border-radius: var(--radius);
  overflow: hidden;
  background: #141414;
  aspect-ratio: 1;
}
.scan-modal .scan-box video {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.scan-modal .scan-tip,
.scan-modal .scan-error {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 8px;
  text-align: center;
  font-size: 12px;
  color: #fff;
  background: rgba(0, 0, 0, 0.55);
}
.scan-modal .scan-error {
  top: 0;
  bottom: auto;
  color: #ffb4ab;
}
.scan-modal .scan-manual {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 13px;
}
.result-info {
  margin-top: 4px;
  padding: 10px 14px;
  background: var(--surface-muted);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
}
.result-info p {
  display: flex;
  gap: 12px;
  margin: 6px 0;
  font-size: 13px;
}
.result-info .muted {
  width: 76px;
  flex: none;
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
</style>
