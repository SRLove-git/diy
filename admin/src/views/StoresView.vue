<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  storeApi,
  type Store,
  type StoreTable,
  type StorePackage,
} from '../api/stores'
import { t } from '../i18n'

const stores = ref<Store[]>([])
const loading = ref(false)
const error = ref('')

// 门店表单对话框
const showForm = ref(false)
const form = ref<Partial<Store>>({})
const isEdit = ref(false)
const saving = ref(false)

// 桌位管理
const showTables = ref(false)
const tables = ref<StoreTable[]>([])
const currentStore = ref<Store>()
const newTable = ref({ name: '', capacity: 2, enabled: true })
const tableDrafts = ref<Record<number, { name: string; capacity: number; enabled: boolean }>>({})

/** 列表始终按桌位名排序（数字感知：A2 排在 A10 前），新增/改名后自动归位 */
const sortedTables = computed(() =>
  [...tables.value].sort(
    (a, b) => a.name.localeCompare(b.name, undefined, { numeric: true }) || a.id - b.id,
  ),
)

// 时段管理（预约已改为按时长，时段不再使用，先隐藏）
// const showSlots = ref(false)
// const slots = ref<TimeSlot[]>([])
// const newSlot = ref({ startTime: '', endTime: '', enabled: true })
// const slotDrafts = ref<Record<number, { startTime: string; endTime: string; enabled: boolean }>>({})

// 时长套餐管理
const showPackages = ref(false)
const packages = ref<StorePackage[]>([])
const newPackage = ref({ name: '', hours: 5, price: 0, memberPrice: null as number | null, groupPrice: null as number | null, enabled: true })
const packageDrafts = ref<Record<number, { name: string; hours: number; price: number; memberPrice: number | null; groupPrice: number | null; enabled: boolean }>>({})

const err = ref('')

async function load() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await storeApi.list()
    stores.value = data
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  form.value = {
    name: '',
    address: '',
    businessHours: '10:00-22:00',
    phone: '',
    price: 39.9,
    memberPrice: null,
    groupPrice: null,
    allDayPrice: null,
    allDayMemberPrice: null,
    allDayGroupPrice: null,
    weekendSurchargePercent: 0,
    enabled: true,
  }
  isEdit.value = false
  showForm.value = true
}

function openEdit(s: Store) {
  form.value = { ...s, enabled: s.enabled }
  isEdit.value = true
  showForm.value = true
}

async function saveStore() {
  saving.value = true
  err.value = ''
  try {
    const payload = {
      name: form.value.name,
      address: form.value.address,
      businessHours: form.value.businessHours,
      phone: form.value.phone,
      price: form.value.price,
      memberPrice:
        form.value.memberPrice == null ? undefined : form.value.memberPrice,
      groupPrice:
        form.value.groupPrice == null ? undefined : form.value.groupPrice,
      allDayPrice:
        form.value.allDayPrice == null ? undefined : form.value.allDayPrice,
      allDayMemberPrice:
        form.value.allDayMemberPrice == null
          ? undefined
          : form.value.allDayMemberPrice,
      allDayGroupPrice:
        form.value.allDayGroupPrice == null
          ? undefined
          : form.value.allDayGroupPrice,
      weekendSurchargePercent: form.value.weekendSurchargePercent ?? 0,
      enabled: form.value.enabled,
    }
    if (isEdit.value) await storeApi.update(form.value.id!, payload)
    else await storeApi.create(payload)
    showForm.value = false
    await load()
  } catch (e: any) {
    err.value =
      e.response?.data?.message?.join?.(',') ||
      e.response?.data?.message ||
      t('保存失败', 'Save failed')
  } finally {
    saving.value = false
  }
}

async function toggleStore(s: Store) {
  try {
    await storeApi.update(s.id, { enabled: !s.enabled })
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

async function removeStore(s: Store) {
  if (
    !confirm(
      t(
        '确认删除门店「{name}」？其桌位和套餐将一并删除。',
        'Delete store "{name}"? Its tables and packages will also be deleted.',
        { name: s.name },
      ),
    )
  )
    return
  try {
    await storeApi.remove(s.id)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
  }
}

// ===== 桌位管理 =====
function openTableManager(s: Store) {
  currentStore.value = s
  tables.value = s.tables ?? []
  newTable.value = { name: '', capacity: 2, enabled: true }
  tableDrafts.value = {}
  showTables.value = true
}

async function addTable() {
  // 桌位名由服务端按容量规则自动生成（A=1人桌 / B=2人桌 / C=4人桌 + 序号）
  try {
    const { data } = await storeApi.addTable(currentStore.value!.id, newTable.value)
    tables.value.push(data)
    newTable.value = { name: '', capacity: 2, enabled: true }
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('添加失败', 'Add failed'))
  }
}

function editTable(t: StoreTable) {
  tableDrafts.value[t.id] = {
    name: t.name,
    capacity: t.capacity,
    enabled: t.enabled,
  }
}

async function saveTable(table: StoreTable) {
  const draft = tableDrafts.value[table.id]
  if (!draft) return
  try {
    const { data } = await storeApi.updateTable(table.id, draft)
    const idx = tables.value.findIndex((x) => x.id === table.id)
    if (idx >= 0) tables.value[idx] = data
    delete tableDrafts.value[table.id]
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('保存失败', 'Save failed'))
  }
}

function cancelTableEdit(id: number) {
  delete tableDrafts.value[id]
}

async function removeTable(table: StoreTable) {
  if (
    !confirm(
      t('确认删除桌位「{name}」？', 'Delete table "{name}"?', { name: table.name }),
    )
  )
    return
  try {
    await storeApi.removeTable(table.id)
    tables.value = tables.value.filter((x) => x.id !== table.id)
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
  }
}

// ===== 时段管理（预约已改为按时长，时段不再使用，先隐藏） =====
// function openSlotManager(s: Store) {
//   currentStore.value = s
//   slots.value = s.slots ?? []
//   newSlot.value = { startTime: '', endTime: '', enabled: true }
//   slotDrafts.value = {}
//   showSlots.value = true
// }
//
// async function addSlot() {
//   if (!newSlot.value.startTime || !newSlot.value.endTime) return
//   try {
//     const { data } = await storeApi.addSlot(currentStore.value!.id, newSlot.value)
//     slots.value.push(data)
//     newSlot.value = { startTime: '', endTime: '', enabled: true }
//   } catch (e: any) {
//     alert(e?.response?.data?.message ?? '添加失败')
//   }
// }
//
// function editSlot(t: TimeSlot) {
//   slotDrafts.value[t.id] = {
//     startTime: t.startTime,
//     endTime: t.endTime,
//     enabled: t.enabled,
//   }
// }
//
// async function saveSlot(t: TimeSlot) {
//   const draft = slotDrafts.value[t.id]
//   if (!draft) return
//   try {
//     const { data } = await storeApi.updateSlot(t.id, draft)
//     const idx = slots.value.findIndex((x) => x.id === t.id)
//     if (idx >= 0) slots.value[idx] = data
//     delete slotDrafts.value[t.id]
//   } catch (e: any) {
//     alert(e?.response?.data?.message ?? '保存失败')
//   }
// }
//
// function cancelSlotEdit(id: number) {
//   delete slotDrafts.value[id]
// }
//
// async function removeSlot(t: TimeSlot) {
//   if (!confirm(`确认删除时段 ${t.startTime}-${t.endTime}？`)) return
//   try {
//     await storeApi.removeSlot(t.id)
//     slots.value = slots.value.filter((x) => x.id !== t.id)
//   } catch (e: any) {
//     alert(e?.response?.data?.message ?? '删除失败')
//   }
// }

// ===== 时长套餐管理 =====
function openPackageManager(s: Store) {
  currentStore.value = s
  packages.value = [...(s.packages ?? [])].sort(
    (a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0),
  )
  newPackage.value = { name: '', hours: 5, price: 0, memberPrice: null, groupPrice: null, enabled: true }
  packageDrafts.value = {}
  showPackages.value = true
}

async function addPackage() {
  if (!newPackage.value.name || !newPackage.value.hours) return
  try {
    const { data } = await storeApi.addPackage(currentStore.value!.id, newPackage.value)
    packages.value.push(data)
    newPackage.value = { name: '', hours: 5, price: 0, memberPrice: null, groupPrice: null, enabled: true }
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('添加失败', 'Add failed'))
  }
}

function editPackage(p: StorePackage) {
  packageDrafts.value[p.id] = {
    name: p.name,
    hours: p.hours,
    price: p.price,
    memberPrice: p.memberPrice ?? null,
    groupPrice: p.groupPrice ?? null,
    enabled: p.enabled,
  }
}

async function savePackage(p: StorePackage) {
  const draft = packageDrafts.value[p.id]
  if (!draft || !draft.name || !draft.hours) return
  try {
    const { data } = await storeApi.updatePackage(p.id, draft)
    const idx = packages.value.findIndex((x) => x.id === p.id)
    if (idx >= 0) packages.value[idx] = data
    delete packageDrafts.value[p.id]
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('保存失败', 'Save failed'))
  }
}

function cancelPackageEdit(id: number) {
  delete packageDrafts.value[id]
}

async function removePackage(p: StorePackage) {
  if (
    !confirm(t('确认删除套餐「{name}」？', 'Delete package "{name}"?', { name: p.name }))
  )
    return
  try {
    await storeApi.removePackage(p.id)
    packages.value = packages.value.filter((x) => x.id !== p.id)
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
  }
}

onMounted(load)
</script>

<template>
  <div class="stores">
    <div class="toolbar">
      <h2>{{ $t('门店管理', 'Stores') }}</h2>
      <button class="primary" @click="openCreate">{{ $t('新增门店', 'New store') }}</button>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="stores.length === 0" class="empty">
      {{ $t('暂无门店，点击「新增门店」开始配置', 'No stores yet. Click "New store" to configure one.') }}
    </div>

    <table v-else class="grid">
      <thead>
        <tr>
          <th>ID</th><th>{{ $t('名称', 'Name') }}</th><th>{{ $t('地址', 'Address') }}</th>
          <th>{{ $t('电话', 'Phone') }}</th><th>{{ $t('营业时间', 'Hours') }}</th>
          <th>{{ $t('评分', 'Rating') }}</th><th>{{ $t('桌位', 'Tables') }}</th>
          <th>{{ $t('套餐', 'Packages') }}</th><th>{{ $t('状态', 'Status') }}</th>
          <th>{{ $t('操作', 'Actions') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="s in stores" :key="s.id" :class="{ 'row-off': !s.enabled }">
          <td>{{ s.id }}</td>
          <td>{{ s.name }}</td>
          <td class="addr">{{ s.address }}</td>
          <td>{{ s.phone || '-' }}</td>
          <td>{{ s.businessHours }}</td>
          <td>{{ s.rating }}</td>
          <td>{{ s.tables?.length ?? 0 }}</td>
          <td>{{ s.packages?.length ?? 0 }}</td>
          <td>
            <span class="tag" :class="s.enabled ? 'tag-on' : 'tag-off'">
              {{ s.enabled ? $t('营业中', 'Open') : $t('已停用', 'Disabled') }}
            </span>
          </td>
          <td class="ops">
            <button @click="openEdit(s)">{{ $t('编辑', 'Edit') }}</button>
            <button @click="openTableManager(s)">{{ $t('桌位', 'Tables') }}</button>
            <button @click="openPackageManager(s)">{{ $t('套餐', 'Packages') }}</button>
            <button :class="s.enabled ? '' : 'primary'" @click="toggleStore(s)">
              {{ s.enabled ? $t('停用', 'Disable') : $t('启用', 'Enable') }}
            </button>
            <button class="danger" @click="removeStore(s)">{{ $t('删除', 'Delete') }}</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 门店新增/编辑 -->
    <div v-if="showForm" class="mask">
      <div class="dialog">
        <h3>{{ isEdit ? $t('编辑门店', 'Edit store') : $t('新增门店', 'New store') }}</h3>
        <label>{{ $t('门店名称', 'Store name') }}<input v-model="form.name" /></label>
        <label>{{ $t('地址', 'Address') }}<input v-model="form.address" /></label>
        <div class="row">
          <label>{{ $t('门市价（$/人）', 'Regular price ($/person)') }}<input v-model.number="form.price" type="number" min="0" step="0.1" /></label>
          <label>{{ $t('会员价（$/人，0 = 会员免费）', 'Member price ($/person, 0 = free)') }}<input v-model.number="form.memberPrice" type="number" min="0" step="0.1" /></label>
          <label>{{ $t('多人同行价（$/人）', 'Group price ($/person)') }}<input v-model.number="form.groupPrice" type="number" min="0" step="0.1" /></label>
        </div>
        <label>
          {{ $t('全天不限时价（$/人，留空 = 按营业时长 × 小时价）', 'All-day price ($/person, empty = opening hours × hourly rate)') }}
          <input v-model.number="form.allDayPrice" type="number" min="0" step="0.1" />
        </label>
        <div class="row">
          <label>{{ $t('全天会员价（$/人）', 'All-day member price ($/person)') }}<input v-model.number="form.allDayMemberPrice" type="number" min="0" step="0.1" /></label>
          <label>{{ $t('全天多人价（$/人）', 'All-day group price ($/person)') }}<input v-model.number="form.allDayGroupPrice" type="number" min="0" step="0.1" /></label>
        </div>
        <label>
          {{ $t('周末/节假日加价（%，0 = 不加价）', 'Weekend/holiday surcharge (%, 0 = none)') }}
          <input v-model.number="form.weekendSurchargePercent" type="number" min="0" max="100" />
        </label>
        <label>{{ $t('营业时间', 'Business hours') }}<input v-model="form.businessHours" :placeholder="$t('如 10:00-22:00', 'e.g. 10:00-22:00')" /></label>
        <label>{{ $t('联系电话', 'Phone') }}<input v-model="form.phone" /></label>
        <label class="check-label">
          <input v-model="form.enabled" type="checkbox" />
          <span>{{ $t('门店营业中（停用后用户端不再展示）', 'Store is open (disabled stores are hidden in the app)') }}</span>
        </label>
        <p v-if="err" class="error">{{ err }}</p>
        <div class="actions">
          <button @click="showForm = false">{{ $t('取消', 'Cancel') }}</button>
          <button class="primary" :disabled="saving" @click="saveStore">
            {{ $t('保存', 'Save') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 桌位管理 -->
    <div v-if="showTables" class="mask">
      <div class="dialog wide">
        <h3>{{ $t('桌位配置 · {name}', 'Table setup · {name}', { name: currentStore?.name ?? '' }) }}</h3>
        <p style="margin:0 0 10px;color:#8a8a93;font-size:12px">
          {{ $t('桌位名按容量自动生成：A=1人桌 / B=2人桌 / C=4人桌，序号为同类型最小空闲号；座位号 = 桌名-序号（如 B1-2）。修改容量会自动重命名。', 'Names auto-generate from capacity: A=1 / B=2 / C=4 seats, index = smallest free; seat = name-N (e.g. B1-2). Changing capacity renames the table.') }}
        </p>
        <table class="grid">
          <thead>
            <tr>
              <th>{{ $t('桌位', 'Table') }}</th>
              <th>{{ $t('容纳人数', 'Capacity') }}</th>
              <th>{{ $t('状态', 'Status') }}</th>
              <th>{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="t in sortedTables" :key="t.id">
              <template v-if="tableDrafts[t.id]">
                <td>{{ tableDrafts[t.id].name }}</td>
                <td>
                  <select v-model.number="tableDrafts[t.id].capacity">
                    <option :value="1">{{ $t('1人桌（A）', '1-seat (A)') }}</option>
                    <option :value="2">{{ $t('2人桌（B）', '2-seat (B)') }}</option>
                    <option :value="4">{{ $t('4人桌（C）', '4-seat (C)') }}</option>
                  </select>
                </td>
                <td><label><input v-model="tableDrafts[t.id].enabled" type="checkbox" /> {{ $t('启用', 'Enabled') }}</label></td>
                <td class="ops">
                  <button class="primary" @click="saveTable(t)">{{ $t('保存', 'Save') }}</button>
                  <button @click="cancelTableEdit(t.id)">{{ $t('取消', 'Cancel') }}</button>
                </td>
              </template>
              <template v-else>
                <td>{{ t.name }}</td>
                <td>{{ t.capacity }}</td>
                <td>
                  <span class="tag" :class="t.enabled ? 'tag-on' : 'tag-off'">
                    {{ t.enabled ? $t('启用', 'Enabled') : $t('停用', 'Disabled') }}
                  </span>
                </td>
                <td class="ops">
                  <button @click="editTable(t)">{{ $t('编辑', 'Edit') }}</button>
                  <button class="danger" @click="removeTable(t)">{{ $t('删除', 'Delete') }}</button>
                </td>
              </template>
            </tr>
            <tr v-if="tables.length === 0">
              <td colspan="4" class="empty">{{ $t('暂无桌位', 'No tables yet') }}</td>
            </tr>
          </tbody>
        </table>
        <div class="row">
          <span style="color:#8a8a93;font-size:13px">{{ $t('桌位名自动生成', 'Name auto-generated') }}</span>
          <select v-model.number="newTable.capacity">
            <option :value="1">{{ $t('1人桌（A）', '1-seat (A)') }}</option>
            <option :value="2">{{ $t('2人桌（B）', '2-seat (B)') }}</option>
            <option :value="4">{{ $t('4人桌（C）', '4-seat (C)') }}</option>
          </select>
          <label class="check-label"><input v-model="newTable.enabled" type="checkbox" /> {{ $t('启用', 'Enabled') }}</label>
          <button class="primary" @click="addTable">{{ $t('添加', 'Add') }}</button>
        </div>
        <div class="actions">
          <button class="primary" @click="showTables = false">{{ $t('完成', 'Done') }}</button>
        </div>
      </div>
    </div>

    <!-- 时段管理（预约已改为按时长，时段不再使用，先隐藏） -->
    <!-- <div v-if="showSlots" class="mask">
      <div class="dialog wide">
        <h3>时段配置 · {{ currentStore?.name }}</h3>
        <table class="grid">
          <thead><tr><th>开始</th><th>结束</th><th>状态</th><th>操作</th></tr></thead>
          <tbody>
            <tr v-for="t in slots" :key="t.id">
              <template v-if="slotDrafts[t.id]">
                <td><input v-model="slotDrafts[t.id].startTime" type="time" /></td>
                <td><input v-model="slotDrafts[t.id].endTime" type="time" /></td>
                <td><label><input v-model="slotDrafts[t.id].enabled" type="checkbox" /> 启用</label></td>
                <td class="ops">
                  <button class="primary" @click="saveSlot(t)">保存</button>
                  <button @click="cancelSlotEdit(t.id)">取消</button>
                </td>
              </template>
              <template v-else>
                <td>{{ t.startTime }}</td>
                <td>{{ t.endTime }}</td>
                <td>
                  <span class="tag" :class="t.enabled ? 'tag-on' : 'tag-off'">
                    {{ t.enabled ? '启用' : '停用' }}
                  </span>
                </td>
                <td class="ops">
                  <button @click="editSlot(t)">编辑</button>
                  <button class="danger" @click="removeSlot(t)">删除</button>
                </td>
              </template>
            </tr>
            <tr v-if="slots.length === 0"><td colspan="4" class="empty">暂无时段</td></tr>
          </tbody>
        </table>
        <div class="row">
          <input v-model="newSlot.startTime" type="time" />
          <input v-model="newSlot.endTime" type="time" />
          <label class="check-label"><input v-model="newSlot.enabled" type="checkbox" /> 启用</label>
          <button class="primary" @click="addSlot">添加</button>
        </div>
        <div class="actions">
          <button class="primary" @click="showSlots = false">完成</button>
        </div>
      </div>
    </div> -->

    <!-- 时长套餐管理 -->
    <div v-if="showPackages" class="mask">
      <div class="dialog wide">
        <h3>{{ $t('时长套餐配置 · {name}', 'Package setup · {name}', { name: currentStore?.name ?? '' }) }}</h3>
        <p class="hint-text">
          {{ $t('用户预约时可选择「按小时 / 时长套餐 / 全天不限时」；套餐价为$/人。', 'Users can choose Hourly / Package / All-day when booking; package price is $/person.') }}
        </p>
        <table class="grid">
          <thead>
            <tr>
              <th>{{ $t('套餐名', 'Package name') }}</th>
              <th>{{ $t('时长（小时）', 'Duration (h)') }}</th>
              <th>{{ $t('价格（$/人）', 'Price ($/person)') }}</th>
              <th>{{ $t('会员价', 'Member price') }}</th>
              <th>{{ $t('多人同行价', 'Group price') }}</th>
              <th>{{ $t('状态', 'Status') }}</th>
              <th>{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in packages" :key="p.id">
              <template v-if="packageDrafts[p.id]">
                <td><input v-model="packageDrafts[p.id].name" /></td>
                <td><input v-model.number="packageDrafts[p.id].hours" type="number" min="1" /></td>
                <td><input v-model.number="packageDrafts[p.id].price" type="number" min="0" step="0.1" /></td>
                <td><input v-model.number="packageDrafts[p.id].memberPrice" type="number" min="0" step="0.1" /></td>
                <td><input v-model.number="packageDrafts[p.id].groupPrice" type="number" min="0" step="0.1" /></td>
                <td><label><input v-model="packageDrafts[p.id].enabled" type="checkbox" /> {{ $t('启用', 'Enabled') }}</label></td>
                <td class="ops">
                  <button class="primary" @click="savePackage(p)">{{ $t('保存', 'Save') }}</button>
                  <button @click="cancelPackageEdit(p.id)">{{ $t('取消', 'Cancel') }}</button>
                </td>
              </template>
              <template v-else>
                <td>{{ p.name }}</td>
                <td>{{ $t('{h} 小时', '{h} h', { h: p.hours }) }}</td>
                <td>${{ p.price }}</td>
                <td>{{ p.memberPrice != null ? '$' + p.memberPrice : '-' }}</td>
                <td>{{ p.groupPrice != null ? '$' + p.groupPrice : '-' }}</td>
                <td>
                  <span class="tag" :class="p.enabled ? 'tag-on' : 'tag-off'">
                    {{ p.enabled ? $t('启用', 'Enabled') : $t('停用', 'Disabled') }}
                  </span>
                </td>
                <td class="ops">
                  <button @click="editPackage(p)">{{ $t('编辑', 'Edit') }}</button>
                  <button class="danger" @click="removePackage(p)">{{ $t('删除', 'Delete') }}</button>
                </td>
              </template>
            </tr>
            <tr v-if="packages.length === 0">
              <td colspan="7" class="empty">
                {{ $t('暂无套餐，可添加如「5 小时套餐」「6 小时套餐」', 'No packages yet, e.g. add a "5-Hour Package" or "6-Hour Package"') }}
              </td>
            </tr>
          </tbody>
        </table>
        <div class="row">
          <input v-model="newPackage.name" :placeholder="$t('套餐名，如 5 小时套餐', 'Package name, e.g. 5-Hour Package')" />
          <input v-model.number="newPackage.hours" type="number" min="1" :placeholder="$t('时长（小时）', 'Duration (h)')" />
          <input v-model.number="newPackage.price" type="number" min="0" step="0.1" :placeholder="$t('价格（$/人）', 'Price ($/person)')" />
          <input v-model.number="newPackage.memberPrice" type="number" min="0" step="0.1" :placeholder="$t('会员价', 'Member price')" />
          <input v-model.number="newPackage.groupPrice" type="number" min="0" step="0.1" :placeholder="$t('多人价', 'Group price')" />
          <button class="primary" @click="addPackage">{{ $t('添加', 'Add') }}</button>
        </div>
        <div class="actions">
          <button class="primary" @click="showPackages = false">{{ $t('完成', 'Done') }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
h2 { margin: 0; font-size: 18px; }
.state { text-align: center; padding: 40px; color: #8a8a8a; }
.error { color: #d9453e; }
.hint-text { font-size: 12px; color: #8a8a8a; margin: 0 0 10px; }
.grid {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  font-size: 14px;
}
.grid th, .grid td {
  padding: 12px;
  border-bottom: 1px solid #f0eeea;
  text-align: left;
}
.grid th { background: #faf8f5; color: #8a8a8a; font-weight: 500; }
.grid input[type="text"], .grid input[type="number"], .grid input[type="time"] {
  width: 100px;
  padding: 6px 8px;
  border: 1px solid #eceae6;
  border-radius: 6px;
  font-size: 13px;
  box-sizing: border-box;
}
.addr { max-width: 240px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.row-off td { color: #b0aca6; }
.tag {
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
.ops button {
  margin-right: 6px;
  border: 1px solid #eceae6;
  background: #fff;
  border-radius: 8px;
  padding: 4px 10px;
  font-size: 13px;
  cursor: pointer;
}
.ops .danger { color: #d9453e; border-color: #f3d0cd; }
button.primary {
  background: #e8633a;
  color: #fff;
  border: 1px solid #e8633a;
  border-radius: 8px;
  padding: 8px 16px;
  cursor: pointer;
}
button.primary:disabled { opacity: 0.5; }
.mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}
.dialog {
  width: 440px;
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  max-height: 80vh;
  overflow: auto;
}
.dialog.wide { width: 680px; }
.dialog h3 { margin: 0 0 16px; }
.dialog label {
  display: block;
  font-size: 13px;
  color: #8a8a8a;
  margin-bottom: 12px;
}
.dialog .check-label {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #2b2b2b;
}
.dialog .check-label input { width: auto; margin: 0; }
.dialog input {
  width: 100%;
  height: 40px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  padding: 0 10px;
  margin-top: 4px;
  box-sizing: border-box;
  font-size: 14px;
}
.row { display: flex; gap: 8px; align-items: flex-end; margin-top: 12px; flex-wrap: wrap; }
.row label { flex: 1; }
.row input { flex: 1; }
.row .check-label { flex: 0 0 auto; }
.actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
.actions button:not(.primary) {
  border: 1px solid #eceae6;
  background: #fff;
  border-radius: 8px;
  padding: 8px 20px;
  cursor: pointer;
}
.empty { color: #8a8a8a; text-align: center; padding: 40px 0; }
.error { color: #d9453e; font-size: 13px; }
</style>
