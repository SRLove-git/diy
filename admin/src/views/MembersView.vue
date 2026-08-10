<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import {
  memberApi,
  type Coupon,
  type MemberPlan,
  type Membership,
  type SaveCouponPayload,
  type SavePlanPayload,
} from '../api/members'

const activeTab = ref<'members' | 'plans' | 'coupons'>('members')
const loading = ref(true)
const saving = ref(false)
const error = ref('')
const page = ref(1)
const total = ref(0)
const members = ref<Membership[]>([])
const plans = ref<MemberPlan[]>([])
const coupons = ref<Coupon[]>([])
const totalPages = computed(() => Math.ceil(total.value / 20) || 1)

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
  memberForm.levelName = '手作会员'
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
    alert('请输入用户ID')
    return
  }
  if (!memberForm.expireAt) {
    alert('请选择有效期')
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
    alert(e?.response?.data?.message ?? '保存失败')
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
    alert(e?.response?.data?.message ?? '操作失败')
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

async function loadAll() {
  loading.value = true
  error.value = ''
  try {
    await Promise.all([loadMembers(), loadPlans(), loadCoupons()])
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
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
    alert(e?.response?.data?.message ?? '保存失败')
  } finally {
    saving.value = false
  }
}

async function togglePlan(plan: MemberPlan) {
  try {
    await memberApi.togglePlan(plan.id, !plan.enabled)
    await loadPlans()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
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
    alert(e?.response?.data?.message ?? '保存失败')
  } finally {
    saving.value = false
  }
}

async function toggleCoupon(coupon: Coupon) {
  try {
    await memberApi.toggleCoupon(coupon.id, !coupon.enabled)
    await loadCoupons()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

function goPage(nextPage: number) {
  if (nextPage < 1 || nextPage > totalPages.value) return
  page.value = nextPage
  loadMembers()
}

function formatTime(value: string) {
  try {
    return new Date(value).toLocaleString('zh-CN')
  } catch {
    return value
  }
}

onMounted(loadAll)
</script>

<template>
  <div class="members-view">
    <div class="toolbar">
      <h2>会员运营</h2>
      <div class="actions">
        <button class="btn" @click="loadAll">刷新</button>
      </div>
    </div>

    <div class="tabs">
      <button class="tab" :class="{ active: activeTab === 'members' }" @click="activeTab = 'members'">会员列表</button>
      <button class="tab" :class="{ active: activeTab === 'plans' }" @click="activeTab = 'plans'">套餐管理</button>
      <button class="tab" :class="{ active: activeTab === 'coupons' }" @click="activeTab = 'coupons'">优惠券管理</button>
    </div>

    <div v-if="loading" class="state">加载中…</div>
    <div v-else-if="error" class="state error">{{ error }}</div>

    <template v-else>
      <section v-if="activeTab === 'members'" class="panel">
        <div class="section-bar">
          <div class="hint">开通、调整或删除会员记录；删除后该用户会员资格立即失效</div>
          <div class="filters">
            <input
              v-model="keyword"
              type="text"
              placeholder="用户名 / 用户ID / 会员编号"
              @keyup.enter="doMemberSearch"
            />
            <button class="btn" @click="doMemberSearch">搜索</button>
            <button class="btn" @click="openCreateMember">开通会员</button>
          </div>
        </div>
        <div v-if="!members.length" class="state">暂无会员记录</div>
        <table v-else class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>用户名</th>
              <th>会员编号</th>
              <th>等级</th>
              <th>有效期至</th>
              <th>状态</th>
              <th>最近更新</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in members" :key="item.id">
              <td>{{ item.id }}</td>
              <td>{{ item.userName || `用户 #${item.userId}` }}</td>
              <td><code>{{ item.memberNo }}</code></td>
              <td>{{ item.levelName }}</td>
              <td>{{ formatTime(item.expireAt) }}</td>
              <td>
                <span class="tag" :class="isMemberActive(item) ? 'tag-on' : 'tag-off'">
                  {{ isMemberActive(item) ? '有效' : '已过期' }}
                </span>
              </td>
              <td>{{ formatTime(item.updatedAt) }}</td>
              <td class="cell-actions">
                <button class="btn btn-sm" @click="openEditMember(item)">编辑</button>
                <button class="btn btn-sm btn-danger" @click="openDeleteMember(item)">删除</button>
              </td>
            </tr>
          </tbody>
        </table>
        <div v-if="members.length > 0" class="pagination">
          <button class="btn btn-sm" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
          <span class="page-info">{{ page }} / {{ totalPages }}（共 {{ total }} 条）</span>
          <button class="btn btn-sm" :disabled="page >= totalPages" @click="goPage(page + 1)">下一页</button>
        </div>
      </section>

      <section v-if="activeTab === 'plans'" class="panel">
        <div class="section-bar">
          <div class="hint">维护会员套餐价格、权益、推荐状态和上下架状态</div>
          <button class="btn" @click="openCreatePlan">新增套餐</button>
        </div>
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>名称</th>
              <th>时长</th>
              <th>售价</th>
              <th>原价</th>
              <th>权益</th>
              <th>角标</th>
              <th>推荐</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="plan in plans" :key="plan.id">
              <td>{{ plan.id }}</td>
              <td>{{ plan.name }}</td>
              <td>{{ plan.durationDays }} 天</td>
              <td>${{ plan.price }}</td>
              <td>${{ plan.originalPrice }}</td>
              <td class="multi-line">{{ plan.benefits.join('、') }}</td>
              <td>{{ plan.badge || '-' }}</td>
              <td>{{ plan.recommended ? '是' : '否' }}</td>
              <td>
                <span class="tag" :class="plan.enabled ? 'tag-on' : 'tag-off'">
                  {{ plan.enabled ? '已上架' : '已下架' }}
                </span>
              </td>
              <td class="cell-actions">
                <button class="btn btn-sm" @click="openEditPlan(plan)">编辑</button>
                <button class="btn btn-sm" :class="plan.enabled ? 'btn-danger' : 'btn-success'" @click="togglePlan(plan)">
                  {{ plan.enabled ? '下架' : '上架' }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </section>

      <section v-if="activeTab === 'coupons'" class="panel">
        <div class="section-bar">
          <div class="hint">维护优惠券面额、门槛、库存、到期时间和会员限制</div>
          <button class="btn" @click="openCreateCoupon">新增优惠券</button>
        </div>
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>名称</th>
              <th>面额</th>
              <th>门槛</th>
              <th>到期时间</th>
              <th>库存</th>
              <th>会员专享</th>
              <th>状态</th>
              <th>操作</th>
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
              <td>{{ coupon.membersOnly ? '是' : '否' }}</td>
              <td>
                <span class="tag" :class="coupon.enabled ? 'tag-on' : 'tag-off'">
                  {{ coupon.enabled ? '已上架' : '已下架' }}
                </span>
              </td>
              <td class="cell-actions">
                <button class="btn btn-sm" @click="openEditCoupon(coupon)">编辑</button>
                <button class="btn btn-sm" :class="coupon.enabled ? 'btn-danger' : 'btn-success'" @click="toggleCoupon(coupon)">
                  {{ coupon.enabled ? '下架' : '上架' }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </section>
    </template>

    <div v-if="memberDialogOpen" class="modal-overlay" @click.self="closeMemberDialog">
      <div class="modal">
        <h3>{{ editingMemberId ? '编辑会员' : '开通会员' }}</h3>
        <div class="form-grid">
          <label>
            <span>用户ID</span>
            <input
              v-model.number="memberForm.userId"
              type="number"
              min="1"
              :disabled="!!editingMemberId"
            />
          </label>
          <label>
            <span>会员等级</span>
            <input v-model="memberForm.levelName" type="text" placeholder="手作会员" />
          </label>
          <label class="full-row">
            <span>有效期至</span>
            <input v-model="memberForm.expireAt" type="datetime-local" />
          </label>
        </div>
        <label v-if="!editingMemberId" class="full-row">
          <span>按套餐开通（快捷填充有效期，仍可手动调整）</span>
          <select v-model="memberPlanId" @change="fillExpireFromPlan(Number(memberPlanId))">
            <option value="0">不按套餐，手动选择有效期</option>
            <option v-for="plan in plans" :key="plan.id" :value="plan.id">
              {{ plan.name }}（{{ plan.durationDays }} 天）
            </option>
          </select>
        </label>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeMemberDialog">取消</button>
          <button class="btn btn-sm" :disabled="saving" @click="saveMember">保存</button>
        </div>
      </div>
    </div>

    <div v-if="deleteTarget" class="modal-overlay" @click.self="cancelDeleteMember">
      <div class="modal">
        <h3>删除会员记录</h3>
        <p class="modal-desc">
          确认删除会员编号 {{ deleteTarget.memberNo }}（用户ID
          {{ deleteTarget.userName || `用户 #${deleteTarget.userId}` }}）？删除后该用户会员资格立即失效，操作不可恢复。
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelDeleteMember">取消</button>
          <button class="btn btn-sm btn-danger" :disabled="deleting" @click="confirmDeleteMember">
            {{ deleting ? '删除中…' : '确认删除' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="planDialogOpen" class="modal-overlay" @click.self="closePlanDialog">
      <div class="modal">
        <h3>{{ editingPlanId ? '编辑套餐' : '新增套餐' }}</h3>
        <div class="form-grid">
          <label>
            <span>套餐名称</span>
            <input v-model="planForm.name" type="text" />
          </label>
          <label>
            <span>时长（天）</span>
            <input v-model.number="planForm.durationDays" type="number" min="1" />
          </label>
          <label>
            <span>售价</span>
            <input v-model.number="planForm.price" type="number" min="0" step="0.01" />
          </label>
          <label>
            <span>原价</span>
            <input v-model.number="planForm.originalPrice" type="number" min="0" step="0.01" />
          </label>
          <label>
            <span>角标</span>
            <input v-model="planForm.badge" type="text" placeholder="推荐 / 最划算" />
          </label>
        </div>
        <label class="full-row">
          <span>权益列表</span>
          <textarea v-model="planBenefits" rows="5" placeholder="一行一条权益"></textarea>
        </label>
        <div class="check-row">
          <label><input v-model="planForm.recommended" type="checkbox" /> 推荐套餐</label>
          <label><input v-model="planForm.enabled" type="checkbox" /> 立即上架</label>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closePlanDialog">取消</button>
          <button class="btn btn-sm" :disabled="saving" @click="savePlan">保存</button>
        </div>
      </div>
    </div>

    <div v-if="couponDialogOpen" class="modal-overlay" @click.self="closeCouponDialog">
      <div class="modal">
        <h3>{{ editingCouponId ? '编辑优惠券' : '新增优惠券' }}</h3>
        <div class="form-grid">
          <label>
            <span>优惠券名称</span>
            <input v-model="couponForm.title" type="text" />
          </label>
          <label>
            <span>面额文案</span>
            <input v-model="couponForm.amount" type="text" placeholder="$20 / 8.8 折" />
          </label>
          <label>
            <span>使用门槛</span>
            <input v-model="couponForm.threshold" type="text" placeholder="满 $100 可用" />
          </label>
          <label>
            <span>库存</span>
            <input v-model.number="couponForm.stock" type="number" min="0" />
          </label>
          <label class="full-row">
            <span>到期时间</span>
            <input v-model="couponForm.expireAt" type="datetime-local" />
          </label>
        </div>
        <div class="check-row">
          <label><input v-model="couponForm.membersOnly" type="checkbox" /> 仅会员可领</label>
          <label><input v-model="couponForm.enabled" type="checkbox" /> 立即上架</label>
        </div>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="closeCouponDialog">取消</button>
          <button class="btn btn-sm" :disabled="saving" @click="saveCoupon">保存</button>
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
