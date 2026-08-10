<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import {
  memberApi,
  type Coupon,
  type MemberOrder,
  type MemberPlan,
  type Membership,
  type SaveCouponPayload,
  type SavePlanPayload,
} from '../api/members'
import { i18n, t } from '../i18n'

const activeTab = ref<'members' | 'orders' | 'plans' | 'coupons'>('members')
const loading = ref(true)
const saving = ref(false)
const error = ref('')
const page = ref(1)
const total = ref(0)
const members = ref<Membership[]>([])
const orders = ref<MemberOrder[]>([])
const plans = ref<MemberPlan[]>([])
const coupons = ref<Coupon[]>([])
const totalPages = computed(() => Math.ceil(total.value / 20) || 1)
const ordersPage = ref(1)
const ordersTotal = ref(0)
const ordersKeyword = ref('')
const orderBusyId = ref<number | null>(null)
const ordersTotalPages = computed(() => Math.ceil(ordersTotal.value / 20) || 1)

const keyword = ref('')
const memberDialogOpen = ref(false)
const editingMemberId = ref<number | null>(null)
const memberPlanId = ref(0)
const memberForm = reactive({
  userId: 0,
  levelName: '',
  expireAt: '',
})
const deleteTarget = ref<Membership | null>(null)
const deleting = ref(false)

const planDialogOpen = ref(false)
const editingPlanId = ref<number | null>(null)
const planForm = reactive<SavePlanPayload>({
  name: '',
  durationDays: 30,
  price: 0,
  originalPrice: 0,
  benefits: [],
  badge: '',
  recommended: false,
  enabled: true,
})
const planBenefits = ref('')

const couponDialogOpen = ref(false)
const editingCouponId = ref<number | null>(null)
const couponForm = reactive<SaveCouponPayload>({
  title: '',
  amount: '',
  threshold: '',
  expireAt: '',
  stock: 0,
  membersOnly: true,
  enabled: true,
})

function resetPlanForm() {
  editingPlanId.value = null
  planForm.name = ''
  planForm.durationDays = 30
  planForm.price = 0
  planForm.originalPrice = 0
  planForm.badge = ''
  planForm.recommended = false
  planForm.enabled = true
  planForm.benefits = []
  planBenefits.value = ''
}

function resetCouponForm() {
  editingCouponId.value = null
  couponForm.title = ''
  couponForm.amount = ''
  couponForm.threshold = ''
  couponForm.expireAt = ''
  couponForm.stock = 0
  couponForm.membersOnly = true
  couponForm.enabled = true
}

async function loadMembers() {
  const { data } = await memberApi.listMembers(
    page.value,
    keyword.value.trim() || undefined,
  )
  members.value = data[0]
  total.value = data[1]
}

function doMemberSearch() {
  page.value = 1
  loadMembers()
}

function toLocalInput(d: Date) {
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(
    d.getHours(),
  )}:${pad(d.getMinutes())}`
}

function defaultExpireAt() {
  const d = new Date()
  d.setDate(d.getDate() + 30)
  return toLocalInput(d)
}

function openCreateMember() {
  editingMemberId.value = null
  memberPlanId.value = 0
  memberForm.userId = 0
  memberForm.levelName = i18n.lang === 'en' ? 'Craft Member' : '手作会员'
  memberForm.expireAt = defaultExpireAt()
  memberDialogOpen.value = true
}

function openEditMember(item: Membership) {
  editingMemberId.value = item.id
  memberPlanId.value = 0
  memberForm.userId = item.userId
  memberForm.levelName = item.levelName
  memberForm.expireAt = item.expireAt.slice(0, 16)
  memberDialogOpen.value = true
}

function closeMemberDialog() {
  memberDialogOpen.value = false
  editingMemberId.value = null
}

function fillExpireFromPlan(planId: number) {
  const plan = plans.value.find((p) => p.id === planId)
  if (!plan) return
  const d = new Date()
  d.setDate(d.getDate() + plan.durationDays)
  memberForm.expireAt = toLocalInput(d)
}

async function saveMember() {
  if (!editingMemberId.value && !memberForm.userId) {
    alert(t('请输入用户ID', 'Please enter the user ID'))
    return
  }
  if (!memberForm.expireAt) {
    alert(t('请选择有效期', 'Please choose an expiry date'))
    return
  }
  saving.value = true
  try {
    const expireAt = new Date(memberForm.expireAt).toISOString()
    if (editingMemberId.value) {
      await memberApi.updateMembership(editingMemberId.value, {
        levelName: memberForm.levelName || undefined,
        expireAt,
      })
    } else {
      await memberApi.createMembership({
        userId: memberForm.userId,
        levelName: memberForm.levelName || undefined,
        expireAt,
      })
    }
    closeMemberDialog()
    await loadMembers()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('保存失败', 'Save failed'))
  } finally {
    saving.value = false
  }
}

function openDeleteMember(item: Membership) {
  deleteTarget.value = item
}

function cancelDeleteMember() {
  deleteTarget.value = null
}

async function confirmDeleteMember() {
  if (!deleteTarget.value) return
  deleting.value = true
  try {
    await memberApi.deleteMembership(deleteTarget.value.id)
    deleteTarget.value = null
    await loadMembers()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    deleting.value = false
  }
}

function isMemberActive(item: Membership) {
  return new Date(item.expireAt) > new Date()
}

async function loadPlans() {
  const { data } = await memberApi.listPlans()
  plans.value = data
}

async function loadCoupons() {
  const { data } = await memberApi.listCoupons()
  coupons.value = data
}

async function loadOrders() {
  const { data } = await memberApi.listOrders(
    ordersPage.value,
    ordersKeyword.value.trim() || undefined,
  )
  orders.value = data[0]
  ordersTotal.value = data[1]
}

function doOrderSearch() {
  ordersPage.value = 1
  loadOrders()
}

function goOrdersPage(p: number) {
  if (p < 1 || p > ordersTotalPages.value) return
  ordersPage.value = p
  loadOrders()
}

async function confirmOrder(item: MemberOrder) {
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
  orderBusyId.value = item.id
  try {
    await memberApi.confirmOrder(item.id)
    await loadOrders()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    orderBusyId.value = null
  }
}

async function cancelOrder(item: MemberOrder) {
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
  orderBusyId.value = item.id
  try {
    await memberApi.cancelOrder(item.id)
    await loadOrders()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    orderBusyId.value = null
  }
}

async function loadAll() {
  loading.value = true
  error.value = ''
  try {
    await Promise.all([loadMembers(), loadOrders(), loadPlans(), loadCoupons()])
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    loading.value = false
  }
}

function openCreatePlan() {
  resetPlanForm()
  planDialogOpen.value = true
}

function openEditPlan(plan: MemberPlan) {
  editingPlanId.value = plan.id
  planForm.name = plan.name
  planForm.durationDays = plan.durationDays
  planForm.price = Number(plan.price)
  planForm.originalPrice = Number(plan.originalPrice)
  planForm.badge = plan.badge
  planForm.recommended = plan.recommended
  planForm.enabled = plan.enabled
  planForm.benefits = [...plan.benefits]
  planBenefits.value = plan.benefits.join('\n')
  planDialogOpen.value = true
}

function closePlanDialog() {
  planDialogOpen.value = false
  resetPlanForm()
}

async function savePlan() {
  planForm.benefits = planBenefits.value
    .split('\n')
    .map((item) => item.trim())
    .filter(Boolean)
  saving.value = true
  try {
    if (editingPlanId.value) {
      await memberApi.updatePlan(editingPlanId.value, { ...planForm })
    } else {
      await memberApi.createPlan({ ...planForm })
    }
    closePlanDialog()
    await loadPlans()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('保存失败', 'Save failed'))
  } finally {
    saving.value = false
  }
}

async function togglePlan(plan: MemberPlan) {
  try {
    await memberApi.togglePlan(plan.id, !plan.enabled)
    await loadPlans()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

function openCreateCoupon() {
  resetCouponForm()
  couponDialogOpen.value = true
}

function openEditCoupon(coupon: Coupon) {
  editingCouponId.value = coupon.id
  couponForm.title = coupon.title
  couponForm.amount = coupon.amount
  couponForm.threshold = coupon.threshold
  couponForm.expireAt = coupon.expireAt.slice(0, 16)
  couponForm.stock = coupon.stock
  couponForm.membersOnly = coupon.membersOnly
  couponForm.enabled = coupon.enabled
  couponDialogOpen.value = true
}

function closeCouponDialog() {
  couponDialogOpen.value = false
  resetCouponForm()
}

async function saveCoupon() {
  saving.value = true
  try {
    const payload = {
      ...couponForm,
      expireAt: new Date(couponForm.expireAt).toISOString(),
    }
    if (editingCouponId.value) {
      await memberApi.updateCoupon(editingCouponId.value, payload)
    } else {
      await memberApi.createCoupon(payload)
    }
    closeCouponDialog()
    await loadCoupons()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('保存失败', 'Save failed'))
  } finally {
    saving.value = false
  }
}

async function toggleCoupon(coupon: Coupon) {
  try {
    await memberApi.toggleCoupon(coupon.id, !coupon.enabled)
    await loadCoupons()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

function goPage(nextPage: number) {
  if (nextPage < 1 || nextPage > totalPages.value) return
  page.value = nextPage
  loadMembers()
}

function formatTime(value: string) {
  try {
    return new Date(value).toLocaleString(i18n.lang === 'en' ? 'en-US' : 'zh-CN')
  } catch {
    return value
  }
}

onMounted(loadAll)
</script>

<template>
  <div class="members-view">
    <div class="toolbar">
      <h2>{{ $t('会员运营', 'Members') }}</h2>
      <div class="actions">
        <button class="btn" @click="loadAll">{{ $t('刷新', 'Refresh') }}</button>
      </div>
    </div>

    <div class="tabs">
      <button class="tab" :class="{ active: activeTab === 'members' }" @click="activeTab = 'members'">
        {{ $t('会员列表', 'Members') }}
      </button>
      <button class="tab" :class="{ active: activeTab === 'orders' }" @click="activeTab = 'orders'">
        {{ $t('开通申请', 'Applications') }}
      </button>
      <button class="tab" :class="{ active: activeTab === 'plans' }" @click="activeTab = 'plans'">
        {{ $t('套餐管理', 'Plans') }}
      </button>
      <button class="tab" :class="{ active: activeTab === 'coupons' }" @click="activeTab = 'coupons'">
        {{ $t('优惠券管理', 'Coupons') }}
      </button>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>

    <template v-else>
      <section v-if="activeTab === 'members'" class="panel">
        <div class="section-bar">
          <div class="hint">
            {{ $t('开通、调整或删除会员记录；删除后该用户会员资格立即失效', 'Create, adjust or delete membership records; deleting one revokes the membership immediately.') }}
          </div>
          <div class="filters">
            <input
              v-model="keyword"
              type="text"
              :placeholder="$t('用户名 / 用户ID / 会员编号', 'Username / user ID / member no.')"
              @keyup.enter="doMemberSearch"
            />
            <button class="btn" @click="doMemberSearch">{{ $t('搜索', 'Search') }}</button>
            <button class="btn" @click="openCreateMember">{{ $t('开通会员', 'Add member') }}</button>
          </div>
        </div>
        <div v-if="!members.length" class="state">
          {{ $t('暂无会员记录', 'No membership records') }}
        </div>
        <table v-else class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>{{ $t('用户名', 'Username') }}</th>
              <th>{{ $t('会员编号', 'Member no.') }}</th>
              <th>{{ $t('等级', 'Level') }}</th>
              <th>{{ $t('有效期至', 'Expires') }}</th>
              <th>{{ $t('状态', 'Status') }}</th>
              <th>{{ $t('最近更新', 'Updated') }}</th>
              <th>{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in members" :key="item.id">
              <td>{{ item.id }}</td>
              <td>{{ item.userName || $t('用户 #{id}', 'User #{id}', { id: item.userId }) }}</td>
              <td><code>{{ item.memberNo }}</code></td>
              <td>{{ item.levelName }}</td>
              <td>{{ formatTime(item.expireAt) }}</td>
              <td>
                <span class="tag" :class="isMemberActive(item) ? 'tag-on' : 'tag-off'">
                  {{ isMemberActive(item) ? $t('有效', 'Active') : $t('已过期', 'Expired') }}
                </span>
              </td>
              <td>{{ formatTime(item.updatedAt) }}</td>
              <td class="cell-actions">
                <button class="btn btn-sm" @click="openEditMember(item)">{{ $t('编辑', 'Edit') }}</button>
                <button class="btn btn-sm btn-danger" @click="openDeleteMember(item)">
                  {{ $t('删除', 'Delete') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        <div v-if="members.length > 0" class="pagination">
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
      </section>

      <section v-if="activeTab === 'orders'" class="panel">
        <div class="section-bar">
          <div class="hint">
            {{ $t('用户在 App 提交的开通申请：确认到店收款后点「确认开通」，会员按套餐时长开通/顺延', 'Applications submitted in the app: after confirming in-store payment, click "Confirm"; membership starts or extends by the plan duration.') }}
          </div>
          <div class="filters">
            <input
              v-model="ordersKeyword"
              type="text"
              :placeholder="$t('用户名 / 用户ID', 'Username / user ID')"
              @keyup.enter="doOrderSearch"
            />
            <button class="btn" @click="doOrderSearch">{{ $t('搜索', 'Search') }}</button>
          </div>
        </div>
        <div v-if="!orders.length" class="state">
          {{ $t('暂无开通申请', 'No applications yet') }}
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
              <th>{{ $t('状态', 'Status') }}</th>
              <th>{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in orders" :key="item.id">
              <td>{{ item.id }}</td>
              <td>{{ item.userNickname || $t('用户 #{id}', 'User #{id}', { id: item.userId }) }}</td>
              <td>{{ item.planName }}</td>
              <td>{{ $t('{n} 天', '{n} days', { n: item.durationDays }) }}</td>
              <td>${{ item.amount }}</td>
              <td>{{ formatTime(item.createdAt) }}</td>
              <td>
                <span
                  class="tag"
                  :class="{
                    'tag-on': item.status === 'confirmed',
                    'tag-off': item.status === 'cancelled',
                  }"
                >
                  {{
                    item.status === 'pending'
                      ? $t('待确认', 'Pending')
                      : item.status === 'confirmed'
                        ? $t('已开通', 'Activated')
                        : $t('已取消', 'Cancelled')
                  }}
                </span>
              </td>
              <td class="cell-actions">
                <button
                  v-if="item.status === 'pending'"
                  class="btn btn-sm btn-success"
                  :disabled="orderBusyId !== null"
                  @click="confirmOrder(item)"
                >
                  {{ orderBusyId === item.id ? $t('确认中…', 'Confirming…') : $t('确认开通', 'Confirm') }}
                </button>
                <button
                  v-if="item.status === 'pending'"
                  class="btn btn-sm btn-danger"
                  :disabled="orderBusyId !== null"
                  @click="cancelOrder(item)"
                >
                  {{ $t('取消', 'Cancel') }}
                </button>
                <span v-if="item.status !== 'pending'" class="muted">-</span>
              </td>
            </tr>
          </tbody>
        </table>
        <div v-if="orders.length > 0" class="pagination">
          <button
            class="btn btn-sm"
            :disabled="ordersPage <= 1"
            @click="goOrdersPage(ordersPage - 1)"
          >
            {{ $t('上一页', 'Prev') }}
          </button>
          <span class="page-info">
            {{ $t('第 {p} / {t} 页（共 {n} 条）', 'Page {p} / {t} ({n} total)', { p: ordersPage, t: ordersTotalPages, n: ordersTotal }) }}
          </span>
          <button
            class="btn btn-sm"
            :disabled="ordersPage >= ordersTotalPages"
            @click="goOrdersPage(ordersPage + 1)"
          >
            {{ $t('下一页', 'Next') }}
          </button>
        </div>
      </section>

      <section v-if="activeTab === 'plans'" class="panel">
        <div class="section-bar">
          <div class="hint">
            {{ $t('维护会员套餐价格、权益、推荐状态和上下架状态', 'Manage plan prices, benefits, recommendation and listing status.') }}
          </div>
          <button class="btn" @click="openCreatePlan">{{ $t('新增套餐', 'New plan') }}</button>
        </div>
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>{{ $t('名称', 'Name') }}</th>
              <th>{{ $t('时长', 'Duration') }}</th>
              <th>{{ $t('售价', 'Price') }}</th>
              <th>{{ $t('原价', 'Original') }}</th>
              <th>{{ $t('权益', 'Benefits') }}</th>
              <th>{{ $t('角标', 'Badge') }}</th>
              <th>{{ $t('推荐', 'Recommended') }}</th>
              <th>{{ $t('状态', 'Status') }}</th>
              <th>{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="plan in plans" :key="plan.id">
              <td>{{ plan.id }}</td>
              <td>{{ plan.name }}</td>
              <td>{{ $t('{n} 天', '{n} days', { n: plan.durationDays }) }}</td>
              <td>${{ plan.price }}</td>
              <td>${{ plan.originalPrice }}</td>
              <td class="multi-line">
                {{ plan.benefits.join(i18n.lang === 'en' ? ', ' : '、') }}
              </td>
              <td>{{ plan.badge || '-' }}</td>
              <td>{{ plan.recommended ? $t('是', 'Yes') : $t('否', 'No') }}</td>
              <td>
                <span class="tag" :class="plan.enabled ? 'tag-on' : 'tag-off'">
                  {{ plan.enabled ? $t('已上架', 'Listed') : $t('已下架', 'Unlisted') }}
                </span>
              </td>
              <td class="cell-actions">
                <button class="btn btn-sm" @click="openEditPlan(plan)">{{ $t('编辑', 'Edit') }}</button>
                <button class="btn btn-sm" :class="plan.enabled ? 'btn-danger' : 'btn-success'" @click="togglePlan(plan)">
                  {{ plan.enabled ? $t('下架', 'Unlist') : $t('上架', 'List') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </section>

      <section v-if="activeTab === 'coupons'" class="panel">
        <div class="section-bar">
          <div class="hint">
            {{ $t('维护优惠券面额、门槛、库存、到期时间和会员限制', 'Manage coupon amounts, thresholds, stock, expiry and member restrictions.') }}
          </div>
          <button class="btn" @click="openCreateCoupon">{{ $t('新增优惠券', 'New coupon') }}</button>
        </div>
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>{{ $t('名称', 'Name') }}</th>
              <th>{{ $t('面额', 'Amount') }}</th>
              <th>{{ $t('门槛', 'Threshold') }}</th>
              <th>{{ $t('到期时间', 'Expires') }}</th>
              <th>{{ $t('库存', 'Stock') }}</th>
              <th>{{ $t('会员专享', 'Members only') }}</th>
              <th>{{ $t('状态', 'Status') }}</th>
              <th>{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="coupon in coupons" :key="coupon.id">
              <td>{{ coupon.id }}</td>
              <td>{{ coupon.title }}</td>
              <td>{{ coupon.amount }}</td>
              <td>{{ coupon.threshold }}</td>
              <td>{{ formatTime(coupon.expireAt) }}</td>
              <td>{{ coupon.stock }}</td>
              <td>{{ coupon.membersOnly ? $t('是', 'Yes') : $t('否', 'No') }}</td>
              <td>
                <span class="tag" :class="coupon.enabled ? 'tag-on' : 'tag-off'">
                  {{ coupon.enabled ? $t('已上架', 'Listed') : $t('已下架', 'Unlisted') }}
                </span>
              </td>
              <td class="cell-actions">
                <button class="btn btn-sm" @click="openEditCoupon(coupon)">{{ $t('编辑', 'Edit') }}</button>
                <button class="btn btn-sm" :class="coupon.enabled ? 'btn-danger' : 'btn-success'" @click="toggleCoupon(coupon)">
                  {{ coupon.enabled ? $t('下架', 'Unlist') : $t('上架', 'List') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </section>
    </template>

    <div v-if="memberDialogOpen" class="modal-overlay" @click.self="closeMemberDialog">
      <div class="modal">
        <h3>{{ editingMemberId ? $t('编辑会员', 'Edit member') : $t('开通会员', 'Add member') }}</h3>
        <div class="form-grid">
          <label>
            <span>{{ $t('用户ID', 'User ID') }}</span>
            <input
              v-model.number="memberForm.userId"
              type="number"
              min="1"
              :disabled="!!editingMemberId"
            />
          </label>
          <label>
            <span>{{ $t('会员等级', 'Membership level') }}</span>
            <input v-model="memberForm.levelName" type="text" :placeholder="$t('手作会员', 'Craft Member')" />
          </label>
          <label class="full-row">
            <span>{{ $t('有效期至', 'Expires') }}</span>
            <input v-model="memberForm.expireAt" type="datetime-local" />
          </label>
        </div>
        <label v-if="!editingMemberId" class="full-row">
          <span>
            {{ $t('按套餐开通（快捷填充有效期，仍可手动调整）', 'Activate by plan (auto-fills expiry, still adjustable)') }}
          </span>
          <select v-model="memberPlanId" @change="fillExpireFromPlan(Number(memberPlanId))">
            <option value="0">{{ $t('不按套餐，手动选择有效期', 'No plan; choose expiry manually') }}</option>
            <option v-for="plan in plans" :key="plan.id" :value="plan.id">
              {{ $t('{name}（{days} 天）', '{name} ({days} days)', { name: plan.name, days: plan.durationDays }) }}
            </option>
          </select>
        </label>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeMemberDialog">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm" :disabled="saving" @click="saveMember">
            {{ $t('保存', 'Save') }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="deleteTarget" class="modal-overlay" @click.self="cancelDeleteMember">
      <div class="modal">
        <h3>{{ $t('删除会员记录', 'Delete membership record') }}</h3>
        <p class="modal-desc">
          {{ $t('确认删除会员编号 {no}（用户 {user}）？删除后该用户会员资格立即失效，操作不可恢复。', 'Delete membership {no} (user {user})? The membership will end immediately and this cannot be undone.', {
            no: deleteTarget.memberNo,
            user: deleteTarget.userName || $t('用户 #{id}', 'User #{id}', { id: deleteTarget.userId }),
          }) }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelDeleteMember">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" :disabled="deleting" @click="confirmDeleteMember">
            {{ deleting ? $t('删除中…', 'Deleting…') : $t('确认删除', 'Confirm delete') }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="planDialogOpen" class="modal-overlay" @click.self="closePlanDialog">
      <div class="modal">
        <h3>{{ editingPlanId ? $t('编辑套餐', 'Edit plan') : $t('新增套餐', 'New plan') }}</h3>
        <div class="form-grid">
          <label>
            <span>{{ $t('套餐名称', 'Plan name') }}</span>
            <input v-model="planForm.name" type="text" />
          </label>
          <label>
            <span>{{ $t('时长（天）', 'Duration (days)') }}</span>
            <input v-model.number="planForm.durationDays" type="number" min="1" />
          </label>
          <label>
            <span>{{ $t('售价', 'Price') }}</span>
            <input v-model.number="planForm.price" type="number" min="0" step="0.01" />
          </label>
          <label>
            <span>{{ $t('原价', 'Original price') }}</span>
            <input v-model.number="planForm.originalPrice" type="number" min="0" step="0.01" />
          </label>
          <label>
            <span>{{ $t('角标', 'Badge') }}</span>
            <input v-model="planForm.badge" type="text" :placeholder="$t('推荐 / 最划算', 'Recommended / Best value')" />
          </label>
        </div>
        <label class="full-row">
          <span>{{ $t('权益列表', 'Benefits') }}</span>
          <textarea v-model="planBenefits" rows="5" :placeholder="$t('一行一条权益', 'One benefit per line')"></textarea>
        </label>
        <div class="check-row">
          <label><input v-model="planForm.recommended" type="checkbox" /> {{ $t('推荐套餐', 'Recommended plan') }}</label>
          <label><input v-model="planForm.enabled" type="checkbox" /> {{ $t('立即上架', 'List now') }}</label>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closePlanDialog">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm" :disabled="saving" @click="savePlan">{{ $t('保存', 'Save') }}</button>
        </div>
      </div>
    </div>

    <div v-if="couponDialogOpen" class="modal-overlay" @click.self="closeCouponDialog">
      <div class="modal">
        <h3>{{ editingCouponId ? $t('编辑优惠券', 'Edit coupon') : $t('新增优惠券', 'New coupon') }}</h3>
        <div class="form-grid">
          <label>
            <span>{{ $t('优惠券名称', 'Coupon name') }}</span>
            <input v-model="couponForm.title" type="text" />
          </label>
          <label>
            <span>{{ $t('面额文案', 'Amount text') }}</span>
            <input v-model="couponForm.amount" type="text" :placeholder="$t('$20 / 8.8 折', '$20 / 12% off')" />
          </label>
          <label>
            <span>{{ $t('使用门槛', 'Threshold') }}</span>
            <input v-model="couponForm.threshold" type="text" :placeholder="$t('满 $100 可用', 'Min. spend $100')" />
          </label>
          <label>
            <span>{{ $t('库存', 'Stock') }}</span>
            <input v-model.number="couponForm.stock" type="number" min="0" />
          </label>
          <label class="full-row">
            <span>{{ $t('到期时间', 'Expiry') }}</span>
            <input v-model="couponForm.expireAt" type="datetime-local" />
          </label>
        </div>
        <div class="check-row">
          <label><input v-model="couponForm.membersOnly" type="checkbox" /> {{ $t('仅会员可领', 'Members only') }}</label>
          <label><input v-model="couponForm.enabled" type="checkbox" /> {{ $t('立即上架', 'List now') }}</label>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeCouponDialog">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm" :disabled="saving" @click="saveCoupon">{{ $t('保存', 'Save') }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.members-view { display: flex; flex-direction: column; gap: 16px; }
.toolbar, .section-bar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 18px; }
.filters { display: flex; gap: 8px; align-items: center; }
.filters input {
  padding: 6px 12px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  font-size: 13px;
  width: 170px;
}
.tabs { display: flex; gap: 8px; }
.tab {
  padding: 8px 14px;
  border: 1px solid #eceae6;
  border-radius: 999px;
  background: #fff;
  cursor: pointer;
}
.tab.active { background: #e8633a; color: #fff; border-color: #e8633a; }
.panel {
  background: #fff;
  border: 1px solid #eceae6;
  border-radius: 16px;
  padding: 16px;
}
.hint { font-size: 13px; color: #8a8a8a; }
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
  vertical-align: top;
}
.table th {
  background: #f7f5f2;
  color: #2b2b2b;
  font-weight: 600;
}
.table code {
  background: #f7f5f2;
  padding: 2px 6px;
  border-radius: 4px;
}
.multi-line { max-width: 260px; line-height: 1.6; }
.tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
}
.tag-on { background: #f0f9eb; color: #2e9e5b; border: 1px solid #c2e7b0; }
.tag-off { background: #fef0f0; color: #d9453e; border: 1px solid #fbc4c4; }
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
.btn:disabled { opacity: 0.6; cursor: not-allowed; }
.cell-actions {
  white-space: nowrap;
  display: flex;
  gap: 6px;
}
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-top: 16px;
}
.page-info { color: #8a8a8a; font-size: 13px; }
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
  border-radius: 16px;
  padding: 24px;
  width: 640px;
  max-width: calc(100vw - 32px);
}
.modal h3 { margin: 0 0 16px; font-size: 18px; }
.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}
.form-grid label, .full-row {
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 13px;
}
.full-row { margin-top: 12px; }
.full-row textarea, .form-grid input {
  width: 100%;
  box-sizing: border-box;
}
.form-grid input, .full-row textarea, .full-row select {
  border: 1px solid #eceae6;
  border-radius: 10px;
  padding: 10px 12px;
  font-size: 13px;
  box-sizing: border-box;
}
.full-row select { background: #fff; }
.full-row input:disabled { background: #f7f5f2; color: #8a8a8a; }
.modal-desc { font-size: 13px; color: #8a8a8a; margin: 0 0 16px; line-height: 1.6; }
.check-row {
  display: flex;
  gap: 20px;
  margin-top: 14px;
  font-size: 13px;
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 20px;
}
</style>
