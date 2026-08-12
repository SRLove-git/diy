<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { appointmentApi, type Appointment } from '../api/appointments'
import { memberApi, type MemberOrder } from '../api/members'
import { i18n, t } from '../i18n'
import { pending, refreshPending } from '../stores/pending'

const appointments = ref<Appointment[]>([])
const memberOrders = ref<MemberOrder[]>([])
const ordersLoading = ref(true)
const ordersError = ref('')
const memberLoading = ref(true)
const memberError = ref('')
const busyId = ref<number | null>(null)

async function loadPendingOrders() {
  ordersLoading.value = true
  ordersError.value = ''
  try {
    const data = await appointmentApi.list({ status: 'pending', limit: 10 })
    appointments.value = data[0]
  } catch (e: any) {
    ordersError.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    ordersLoading.value = false
  }
}

async function loadPendingMemberOrders() {
  memberLoading.value = true
  memberError.value = ''
  try {
    const { data } = await memberApi.listOrders(1, undefined, 'pending')
    memberOrders.value = data[0]
  } catch (e: any) {
    memberError.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    memberLoading.value = false
  }
}

async function loadAll() {
  await Promise.all([loadPendingOrders(), loadPendingMemberOrders()])
}

async function confirmAppointment(o: Appointment) {
  if (
    !confirm(
      t(
        '确认预约码 {code} 的预约？确认后顾客可到店核销。',
        'Confirm the booking with code {code}? The customer can then check in at the store.',
        { code: o.code },
      ),
    )
  )
    return
  busyId.value = o.id
  try {
    await appointmentApi.adminConfirm(o.id)
    await Promise.all([loadPendingOrders(), refreshPending()])
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    busyId.value = null
  }
}

async function cancelAppointment(o: Appointment) {
  if (
    !confirm(
      t(
        '确认取消预约码 {code}？取消后用户将无法到店核销。',
        'Cancel booking {code}? The customer will no longer be able to check in.',
        { code: o.code },
      ),
    )
  )
    return
  busyId.value = o.id
  try {
    await appointmentApi.adminCancel(o.id)
    await Promise.all([loadPendingOrders(), refreshPending()])
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    busyId.value = null
  }
}

async function confirmMemberOrder(item: MemberOrder) {
  const user = item.userNickname || t('用户 #{id}', 'User #{id}', { id: item.userId })
  if (
    !confirm(
      t(
        '确认开通 {user} 的会员（{plan}，{days} 天，${amount}）？确认前请确认已收取到店支付费用。',
        'Activate membership for {user} ({plan}, {days} days, ${amount})? Please confirm the in-store payment was collected first.',
        {
          user,
          plan: item.planName,
          days: item.durationDays,
          amount: item.amount,
        },
      ),
    )
  )
    return
  busyId.value = item.id
  try {
    await memberApi.confirmOrder(item.id)
    await Promise.all([loadPendingMemberOrders(), refreshPending()])
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    busyId.value = null
  }
}

async function cancelMemberOrder(item: MemberOrder) {
  const user = item.userNickname || t('用户 #{id}', 'User #{id}', { id: item.userId })
  if (
    !confirm(
      t(
        '确认取消 {user} 的会员开通申请？',
        'Cancel the membership application of {user}?',
        { user },
      ),
    )
  )
    return
  busyId.value = item.id
  try {
    await memberApi.cancelOrder(item.id)
    await Promise.all([loadPendingMemberOrders(), refreshPending()])
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    busyId.value = null
  }
}

function tableLabel(o: Appointment): string {
  if (o.tables && o.tables.length) {
    return o.tables.map((x) => x.name).join(' + ')
  }
  return o.tableName || '-'
}

function formatTime(value: string) {
  try {
    return new Date(value).toLocaleString(i18n.lang === 'en' ? 'en-US' : 'zh-CN')
  } catch {
    return value
  }
}

const contentPending = () => pending.posts + pending.videos
const nothingPending =
  () =>
  appointments.value.length === 0 &&
  memberOrders.value.length === 0 &&
  contentPending() === 0

onMounted(async () => {
  await loadAll()
  await refreshPending()
})
</script>

<template>
  <div class="alerts">
    <div class="toolbar">
      <h2>{{ $t('通知中心', 'Alert Center') }}</h2>
      <div class="actions">
        <button class="btn" @click="loadAll(); refreshPending()">{{ $t('刷新', 'Refresh') }}</button>
      </div>
    </div>

    <!-- 待处理统计 -->
    <div class="stats">
      <div class="stat-card">
        <span class="stat-num">{{ pending.appointments }}</span>
        <span class="stat-label">{{ $t('待确认订单', 'Pending orders') }}</span>
      </div>
      <div class="stat-card">
        <span class="stat-num">{{ pending.memberOrders }}</span>
        <span class="stat-label">{{ $t('会员开通申请', 'Membership applications') }}</span>
      </div>
      <div class="stat-card">
        <span class="stat-num">{{ contentPending() }}</span>
        <span class="stat-label">{{ $t('内容待审核', 'Content pending review') }}</span>
      </div>
    </div>

    <div v-if="nothingPending() && !ordersLoading && !memberLoading" class="state">
      {{ $t('暂无待处理事项', 'Nothing pending') }}
    </div>

    <!-- 待确认订单 -->
    <section class="panel">
      <div class="section-bar">
        <h3>{{ $t('待确认订单', 'Pending orders') }}</h3>
        <RouterLink class="link" to="/orders">
          {{ $t('查看全部订单 →', 'All orders →') }}
        </RouterLink>
      </div>
      <div v-if="ordersLoading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
      <div v-else-if="ordersError" class="state error">{{ ordersError }}</div>
      <div v-else-if="appointments.length === 0" class="state">
        {{ $t('没有待确认的订单', 'No pending orders') }}
      </div>
      <table v-else class="table">
        <thead>
          <tr>
            <th>{{ $t('预约码', 'Code') }}</th>
            <th>{{ $t('用户', 'User') }}</th>
            <th>{{ $t('门店', 'Store') }}</th>
            <th>{{ $t('桌位', 'Table') }}</th>
            <th>{{ $t('日期', 'Date') }}</th>
            <th>{{ $t('时段', 'Time') }}</th>
            <th>{{ $t('人数', 'Guests') }}</th>
            <th>{{ $t('操作', 'Actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="o in appointments" :key="o.id">
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
            <td>{{ tableLabel(o) }}</td>
            <td>{{ o.date }}</td>
            <td>{{ o.startTime }} - {{ o.endTime }}</td>
            <td>{{ $t('{n} 人', '{n} people', { n: o.peopleCount }) }}</td>
            <td class="cell-actions">
              <button
                class="btn btn-sm btn-success"
                :disabled="busyId !== null"
                @click="confirmAppointment(o)"
              >
                {{ busyId === o.id ? $t('确认中…', 'Confirming…') : $t('确认', 'Confirm') }}
              </button>
              <button
                class="btn btn-sm btn-danger"
                :disabled="busyId !== null"
                @click="cancelAppointment(o)"
              >
                {{ $t('取消', 'Cancel') }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </section>

    <!-- 会员开通申请 -->
    <section class="panel">
      <div class="section-bar">
        <h3>{{ $t('会员开通申请', 'Membership applications') }}</h3>
        <RouterLink class="link" to="/members">
          {{ $t('查看全部申请 →', 'All applications →') }}
        </RouterLink>
      </div>
      <div v-if="memberLoading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
      <div v-else-if="memberError" class="state error">{{ memberError }}</div>
      <div v-else-if="memberOrders.length === 0" class="state">
        {{ $t('没有待确认的开通申请', 'No pending applications') }}
      </div>
      <table v-else class="table">
        <thead>
          <tr>
            <th>ID</th>
            <th>{{ $t('用户', 'User') }}</th>
            <th>{{ $t('套餐', 'Plan') }}</th>
            <th>{{ $t('时长', 'Duration') }}</th>
            <th>{{ $t('金额', 'Amount') }}</th>
            <th>{{ $t('提交时间', 'Submitted') }}</th>
            <th>{{ $t('操作', 'Actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in memberOrders" :key="item.id">
            <td>{{ item.id }}</td>
            <td>
              <div class="user-cell">
                <span class="nickname">
                  {{ item.userNickname || $t('用户 #{id}', 'User #{id}', { id: item.userId }) }}
                </span>
                <span v-if="item.userEmail" class="sub">{{ item.userEmail }}</span>
              </div>
            </td>
            <td>{{ item.planName }}</td>
            <td>{{ $t('{n} 天', '{n} days', { n: item.durationDays }) }}</td>
            <td>${{ item.amount }}</td>
            <td>{{ formatTime(item.createdAt) }}</td>
            <td class="cell-actions">
              <button
                class="btn btn-sm btn-success"
                :disabled="busyId !== null"
                @click="confirmMemberOrder(item)"
              >
                {{ busyId === item.id ? $t('确认中…', 'Confirming…') : $t('确认开通', 'Confirm') }}
              </button>
              <button
                class="btn btn-sm btn-danger"
                :disabled="busyId !== null"
                @click="cancelMemberOrder(item)"
              >
                {{ $t('取消', 'Cancel') }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </section>

    <!-- 内容审核（社区 / Reels 暂未开放，仅展示计数） -->
    <div v-if="contentPending() > 0" class="audit-note">
      {{ $t('内容审核待处理：帖子 {posts} 条、视频 {videos} 条（社区 / Reels 模块暂未开放）', 'Content pending review: {posts} posts, {videos} videos (community / Reels not opened yet)', {
        posts: pending.posts,
        videos: pending.videos,
      }) }}
    </div>
  </div>
</template>

<style scoped>
.alerts { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 19px; font-weight: 700; letter-spacing: 0.01em; color: var(--text); }
.actions { display: flex; gap: 8px; }

/* 待处理统计卡片：每项一个语义强调色 */
.stats { display: flex; gap: 12px; flex-wrap: wrap; }
.stat-card {
  flex: 1;
  min-width: 160px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px 20px;
  box-shadow: var(--shadow-sm);
}
.stat-num {
  font-size: 28px;
  font-weight: 700;
  color: var(--primary);
  line-height: 1;
  font-variant-numeric: tabular-nums;
}
.stat-card:nth-child(2) .stat-num { color: var(--purple); }
.stat-card:nth-child(3) .stat-num { color: var(--info); }
.stat-label { font-size: 13px; color: var(--text-muted); }

/* 面板卡片 */
.panel {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px;
  box-shadow: var(--shadow-sm);
}
.section-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.section-bar h3 { margin: 0; font-size: 15px; font-weight: 600; color: var(--text); }
.link { font-size: 13px; color: var(--primary); text-decoration: none; font-weight: 600; }
.link:hover { color: var(--primary-hover); }

.state { text-align: center; padding: 32px; color: var(--text-muted); }
.error { color: var(--danger); }
.state.error { background: var(--danger-weak); border-radius: var(--radius-sm); }

/* 表格卡片 */
.table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  font-size: 13px;
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
.table code {
  background: var(--surface-muted);
  border: 1px solid var(--border);
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 12px;
  color: var(--text);
}
.user-cell { display: flex; flex-direction: column; }
.nickname { font-weight: 500; color: var(--text); }
.sub { font-size: 11px; color: var(--text-muted); }
.cell-actions { white-space: nowrap; display: flex; gap: 6px; }

/* 按钮：默认幽灵风格；成功 / 危险为浅底软风格，hover 转实色 */
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
.btn-sm { padding: 4px 10px; font-size: 12px; }
.btn-success { background: var(--success-weak); color: var(--success); border-color: transparent; }
.btn-success:hover:not(:disabled) { background: var(--success); color: #fff; box-shadow: 0 4px 12px rgba(46, 158, 91, 0.28); }
.btn-success:active:not(:disabled) { background: var(--success); color: #fff; box-shadow: none; }
.btn-danger { background: var(--danger-weak); color: var(--danger); border-color: transparent; }
.btn-danger:hover:not(:disabled) { background: var(--danger); color: #fff; box-shadow: 0 4px 12px rgba(217, 69, 62, 0.28); }
.btn-danger:active:not(:disabled) { background: var(--danger); color: #fff; box-shadow: none; }
.btn:disabled { opacity: 0.55; cursor: not-allowed; }

.audit-note {
  font-size: 13px;
  color: var(--text-muted);
  background: var(--primary-softer);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  padding: 10px 14px;
}
</style>
