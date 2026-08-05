<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { storeApi, type Store, type StoreTable, type TimeSlot } from '../api/stores'

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

// 时段管理
const showSlots = ref(false)
const slots = ref<TimeSlot[]>([])
const newSlot = ref({ startTime: '', endTime: '', enabled: true })
const slotDrafts = ref<Record<number, { startTime: string; endTime: string; enabled: boolean }>>({})

const err = ref('')

async function load() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await storeApi.list()
    stores.value = data
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
}

function openCreate() {
  form.value = {
    name: '',
    address: '',
    lat: 30.3,
    lng: 120.1,
    businessHours: '10:00-22:00',
    phone: '',
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
    if (isEdit.value) await storeApi.update(form.value.id!, form.value)
    else await storeApi.create(form.value)
    showForm.value = false
    await load()
  } catch (e: any) {
    err.value = e.response?.data?.message?.join?.(',') || e.response?.data?.message || '保存失败'
  } finally {
    saving.value = false
  }
}

async function toggleStore(s: Store) {
  try {
    await storeApi.update(s.id, { enabled: !s.enabled })
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

async function removeStore(s: Store) {
  if (!confirm(`确认删除门店「${s.name}」？其桌位和时段将一并删除。`)) return
  try {
    await storeApi.remove(s.id)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
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
  if (!newTable.value.name) return
  try {
    const { data } = await storeApi.addTable(currentStore.value!.id, newTable.value)
    tables.value.push(data)
    newTable.value = { name: '', capacity: 2, enabled: true }
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '添加失败')
  }
}

function editTable(t: StoreTable) {
  tableDrafts.value[t.id] = {
    name: t.name,
    capacity: t.capacity,
    enabled: t.enabled,
  }
}

async function saveTable(t: StoreTable) {
  const draft = tableDrafts.value[t.id]
  if (!draft || !draft.name) return
  try {
    const { data } = await storeApi.updateTable(t.id, draft)
    const idx = tables.value.findIndex((x) => x.id === t.id)
    if (idx >= 0) tables.value[idx] = data
    delete tableDrafts.value[t.id]
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '保存失败')
  }
}

function cancelTableEdit(id: number) {
  delete tableDrafts.value[id]
}

async function removeTable(t: StoreTable) {
  if (!confirm(`确认删除桌位「${t.name}」？`)) return
  try {
    await storeApi.removeTable(t.id)
    tables.value = tables.value.filter((x) => x.id !== t.id)
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
  }
}

// ===== 时段管理 =====
function openSlotManager(s: Store) {
  currentStore.value = s
  slots.value = s.slots ?? []
  newSlot.value = { startTime: '', endTime: '', enabled: true }
  slotDrafts.value = {}
  showSlots.value = true
}

async function addSlot() {
  if (!newSlot.value.startTime || !newSlot.value.endTime) return
  try {
    const { data } = await storeApi.addSlot(currentStore.value!.id, newSlot.value)
    slots.value.push(data)
    newSlot.value = { startTime: '', endTime: '', enabled: true }
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '添加失败')
  }
}

function editSlot(t: TimeSlot) {
  slotDrafts.value[t.id] = {
    startTime: t.startTime,
    endTime: t.endTime,
    enabled: t.enabled,
  }
}

async function saveSlot(t: TimeSlot) {
  const draft = slotDrafts.value[t.id]
  if (!draft) return
  try {
    const { data } = await storeApi.updateSlot(t.id, draft)
    const idx = slots.value.findIndex((x) => x.id === t.id)
    if (idx >= 0) slots.value[idx] = data
    delete slotDrafts.value[t.id]
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '保存失败')
  }
}

function cancelSlotEdit(id: number) {
  delete slotDrafts.value[id]
}

async function removeSlot(t: TimeSlot) {
  if (!confirm(`确认删除时段 ${t.startTime}-${t.endTime}？`)) return
  try {
    await storeApi.removeSlot(t.id)
    slots.value = slots.value.filter((x) => x.id !== t.id)
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
  }
}

onMounted(load)
</script>

<template>
  <div class="stores">
    <div class="toolbar">
      <h2>门店管理</h2>
      <button class="primary" @click="openCreate">新增门店</button>
    </div>

    <div v-if="loading" class="state">加载中…</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="stores.length === 0" class="empty">暂无门店，点击「新增门店」开始配置</div>

    <table v-else class="grid">
      <thead>
        <tr>
          <th>ID</th><th>名称</th><th>地址</th><th>电话</th><th>营业时间</th>
          <th>评分</th><th>桌位</th><th>时段</th><th>状态</th><th>操作</th>
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
          <td>{{ s.slots?.length ?? 0 }}</td>
          <td>
            <span class="tag" :class="s.enabled ? 'tag-on' : 'tag-off'">
              {{ s.enabled ? '营业中' : '已停用' }}
            </span>
          </td>
          <td class="ops">
            <button @click="openEdit(s)">编辑</button>
            <button @click="openTableManager(s)">桌位</button>
            <button @click="openSlotManager(s)">时段</button>
            <button :class="s.enabled ? '' : 'primary'" @click="toggleStore(s)">
              {{ s.enabled ? '停用' : '启用' }}
            </button>
            <button class="danger" @click="removeStore(s)">删除</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 门店新增/编辑 -->
    <div v-if="showForm" class="mask">
      <div class="dialog">
        <h3>{{ isEdit ? '编辑门店' : '新增门店' }}</h3>
        <label>门店名称<input v-model="form.name" /></label>
        <label>地址<input v-model="form.address" /></label>
        <div class="row">
          <label>纬度<input v-model.number="form.lat" /></label>
          <label>经度<input v-model.number="form.lng" /></label>
        </div>
        <label>营业时间<input v-model="form.businessHours" placeholder="如 10:00-22:00" /></label>
        <label>联系电话<input v-model="form.phone" /></label>
        <label class="check-label">
          <input v-model="form.enabled" type="checkbox" />
          <span>门店营业中（停用后用户端不再展示）</span>
        </label>
        <p v-if="err" class="error">{{ err }}</p>
        <div class="actions">
          <button @click="showForm = false">取消</button>
          <button class="primary" :disabled="saving" @click="saveStore">保存</button>
        </div>
      </div>
    </div>

    <!-- 桌位管理 -->
    <div v-if="showTables" class="mask">
      <div class="dialog wide">
        <h3>桌位配置 · {{ currentStore?.name }}</h3>
        <table class="grid">
          <thead><tr><th>桌位</th><th>容纳人数</th><th>状态</th><th>操作</th></tr></thead>
          <tbody>
            <tr v-for="t in tables" :key="t.id">
              <template v-if="tableDrafts[t.id]">
                <td><input v-model="tableDrafts[t.id].name" /></td>
                <td><input v-model.number="tableDrafts[t.id].capacity" type="number" min="1" /></td>
                <td><label><input v-model="tableDrafts[t.id].enabled" type="checkbox" /> 启用</label></td>
                <td class="ops">
                  <button class="primary" @click="saveTable(t)">保存</button>
                  <button @click="cancelTableEdit(t.id)">取消</button>
                </td>
              </template>
              <template v-else>
                <td>{{ t.name }}</td>
                <td>{{ t.capacity }}</td>
                <td>
                  <span class="tag" :class="t.enabled ? 'tag-on' : 'tag-off'">
                    {{ t.enabled ? '启用' : '停用' }}
                  </span>
                </td>
                <td class="ops">
                  <button @click="editTable(t)">编辑</button>
                  <button class="danger" @click="removeTable(t)">删除</button>
                </td>
              </template>
            </tr>
            <tr v-if="tables.length === 0"><td colspan="4" class="empty">暂无桌位</td></tr>
          </tbody>
        </table>
        <div class="row">
          <input v-model="newTable.name" placeholder="桌位名，如 B1" />
          <input v-model.number="newTable.capacity" type="number" min="1" placeholder="人数" />
          <label class="check-label"><input v-model="newTable.enabled" type="checkbox" /> 启用</label>
          <button class="primary" @click="addTable">添加</button>
        </div>
        <div class="actions">
          <button class="primary" @click="showTables = false">完成</button>
        </div>
      </div>
    </div>

    <!-- 时段管理 -->
    <div v-if="showSlots" class="mask">
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
