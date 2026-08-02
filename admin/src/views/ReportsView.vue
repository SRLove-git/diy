<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { reportApi, type Report, type ReportStatus } from '../api/reports'

const reports = ref<Report[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const statusFilter = ref<ReportStatus | ''>('')
const page = ref(1)
const pageSize = 20

const statusTabs = [
  { value: '', label: '全部' },
  { value: 'pending', label: '待处理' },
  { value: 'resolved', label: '已处理' },
  { value: 'dismissed', label: '已驳回' },
] as const

const statusLabels: Record<string, string> = {
  pending: '待处理',
  resolved: '已处理',
  dismissed: '已驳回',
}

const statusColors: Record<string, string> = {
  pending: '#E6A23C',
  resolved: '#67C23A',
  dismissed: '#909399',
}

const totalPages = computed(() => Math.ceil(total.value / pageSize) || 1)

async function load() {
  loading.value = true
  error.value = ''
  try {
    const params: { page: number; status?: string } = { page: page.value }
    if (statusFilter.value) params.status = statusFilter.value
    const data = await reportApi.list(params)
    reports.value = data[0]
    total.value = data[1]
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
}

function switchTab(val: ReportStatus | '') {
  statusFilter.value = val
  page.value = 1
  load()
}

function goPage(p: number) {
  if (p < 1 || p > totalPages.value) return
  page.value = p
  load()
}

async function resolveReport(id: number) {
  if (!confirm('确认标记为已处理？')) return
  try {
    await reportApi.resolve(id)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

async function dismissReport(id: number) {
  if (!confirm('确认驳回该举报？')) return
  try {
    await reportApi.dismiss(id)
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

function formatTime(t: string): string {
  try {
    const d = new Date(t)
    return d.toLocaleString('zh-CN')
  } catch {
    return t
  }
}

function truncate(text: string, max: number): string {
  return text.length > max ? text.slice(0, max) + '…' : text
}

onMounted(load)
</script>

<template>
  <div class="reports">
    <div class="toolbar">
      <h2>举报处理</h2>
      <button class="btn" @click="load">刷新</button>
    </div>

    <div class="tabs">
      <button
        v-for="t in statusTabs"
        :key="t.value"
        class="tab-btn"
        :class="{ active: statusFilter === t.value }"
        @click="switchTab(t.value)"
      >
        {{ t.label }}
      </button>
    </div>

    <div v-if="loading" class="state">加载中…</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="reports.length === 0" class="state">暂无举报数据</div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width:60px">ID</th>
          <th style="width:90px">举报人ID</th>
          <th style="width:90px">作品ID</th>
          <th>举报原因</th>
          <th style="width:80px">状态</th>
          <th style="width:150px">提交时间</th>
          <th style="width:150px">处理时间</th>
          <th style="width:140px">操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="r in reports" :key="r.id">
          <td>{{ r.id }}</td>
          <td>{{ r.reporterId }}</td>
          <td>{{ r.postId }}</td>
          <td class="reason-cell">
            <span :title="r.reason">{{ truncate(r.reason, 40) }}</span>
          </td>
          <td>
            <span
              class="tag"
              :style="{ color: statusColors[r.status], borderColor: statusColors[r.status] }"
            >
              {{ statusLabels[r.status] ?? r.status }}
            </span>
          </td>
          <td>{{ formatTime(r.createdAt) }}</td>
          <td>
            <span v-if="r.updatedAt && r.status !== 'pending'" class="muted">{{ formatTime(r.updatedAt) }}</span>
            <span v-else class="muted">-</span>
          </td>
          <td class="actions">
            <template v-if="r.status === 'pending'">
              <button class="btn btn-sm btn-success" @click="resolveReport(r.id)">处理</button>
              <button class="btn btn-sm btn-danger" @click="dismissReport(r.id)">驳回</button>
            </template>
            <span v-else-if="r.status === 'resolved'" class="muted">已处理</span>
            <span v-else-if="r.status === 'dismissed'" class="muted">已驳回</span>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 分页 -->
    <div v-if="!loading && reports.length > 0" class="pagination">
      <button class="btn btn-sm" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
      <span class="page-info">{{ page }} / {{ totalPages }}（共 {{ total }} 条）</span>
      <button class="btn btn-sm" :disabled="page >= totalPages" @click="goPage(page + 1)">下一页</button>
    </div>
  </div>
</template>

<style scoped>
.reports { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 18px; }
.tabs { display: flex; gap: 0; }
.tab-btn {
  padding: 6px 16px;
  border: 1px solid #eceae6;
  background: #fff;
  font-size: 13px;
  cursor: pointer;
  color: #8a8a8a;
}
.tab-btn:first-child { border-radius: 8px 0 0 8px; }
.tab-btn:last-child { border-radius: 0 8px 8px 0; }
.tab-btn.active {
  background: #e8633a;
  color: #fff;
  border-color: #e8633a;
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
.reason-cell { max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
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
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
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
</style>
