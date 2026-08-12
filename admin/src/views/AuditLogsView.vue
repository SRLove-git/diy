<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { auditApi, type AuditLog } from '../api/audit'
import { t } from '../i18n'

const logs = ref<AuditLog[]>([])
const total = ref(0)
const loading = ref(true)
const error = ref('')
const actions = ref<string[]>([])

const action = ref('')
const actor = ref('')
const from = ref('')
const to = ref('')
const page = ref(1)
const pageSize = 20
const totalPages = computed(() => Math.ceil(total.value / pageSize) || 1)
const expanded = ref<Set<number>>(new Set())

async function load() {
  loading.value = true
  error.value = ''
  try {
    const [rows, count] = await auditApi.list({
      page: page.value,
      pageSize,
      action: action.value || undefined,
      actor: actor.value || undefined,
      from: from.value || undefined,
      to: to.value || undefined,
    })
    logs.value = rows
    total.value = count
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    loading.value = false
  }
}

function applyFilters() {
  page.value = 1
  load()
}

function resetFilters() {
  action.value = ''
  actor.value = ''
  from.value = ''
  to.value = ''
  page.value = 1
  load()
}

function goPage(p: number) {
  page.value = p
  load()
}

function toggleDetail(id: number) {
  const next = new Set(expanded.value)
  if (next.has(id)) next.delete(id)
  else next.add(id)
  expanded.value = next
}

function detailText(log: AuditLog): string {
  try {
    return JSON.stringify(log.detail, null, 2)
  } catch {
    return String(log.detail ?? '')
  }
}

function formatTime(tm: string): string {
  const d = new Date(tm)
  return Number.isNaN(d.getTime()) ? '-' : d.toLocaleString()
}

onMounted(async () => {
  await load()
  try {
    actions.value = await auditApi.actions()
  } catch {
    // 动作列表加载失败不阻塞页面
  }
})
</script>

<template>
  <div class="audit">
    <div class="toolbar">
      <h2>{{ $t('审计日志', 'Audit Logs') }}</h2>
      <div class="filters">
        <select v-model="action" class="filter-select">
          <option value="">{{ $t('全部操作', 'All actions') }}</option>
          <option v-for="a in actions" :key="a" :value="a">{{ a }}</option>
        </select>
        <input
          v-model="actor"
          type="text"
          :placeholder="$t('操作人用户名/昵称', 'Actor username / nickname')"
          @keyup.enter="applyFilters"
        />
        <input v-model="from" type="date" :title="$t('开始日期', 'From')" />
        <input v-model="to" type="date" :title="$t('结束日期', 'To')" />
        <button class="btn" @click="applyFilters">{{ $t('查询', 'Search') }}</button>
        <button class="btn" @click="resetFilters">{{ $t('重置', 'Reset') }}</button>
        <button class="btn" @click="load">{{ $t('刷新', 'Refresh') }}</button>
      </div>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="logs.length === 0" class="state">
      {{ $t('暂无审计日志', 'No audit logs') }}
    </div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width:160px">{{ $t('时间', 'Time') }}</th>
          <th style="width:130px">{{ $t('操作人', 'Actor') }}</th>
          <th style="width:180px">{{ $t('操作', 'Action') }}</th>
          <th style="width:90px">{{ $t('目标', 'Target') }}</th>
          <th style="width:140px">{{ $t('IP', 'IP') }}</th>
          <th>{{ $t('详情', 'Detail') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="log in logs" :key="log.id">
          <td class="nowrap">{{ formatTime(log.createdAt) }}</td>
          <td>
            <template v-if="log.actor">
              {{ log.actor.nickname || log.actor.username || '#' + log.actor.id }}
              <span class="muted">@{{ log.actor.username || '-' }}</span>
            </template>
            <span v-else class="muted">{{ $t('未知/系统', 'Unknown / System') }}</span>
          </td>
          <td>
            <span class="action-tag">{{ log.action }}</span>
          </td>
          <td>
            <template v-if="log.targetType">
              <span class="muted">{{ log.targetType }}</span>
              <span v-if="log.targetId">#{{ log.targetId }}</span>
            </template>
            <span v-else class="muted">-</span>
          </td>
          <td class="nowrap">{{ log.ip || '-' }}</td>
          <td>
            <template v-if="log.detail && Object.keys(log.detail).length">
              <button class="btn btn-sm" @click="toggleDetail(log.id)">
                {{ expanded.has(log.id) ? $t('收起', 'Collapse') : $t('展开', 'Expand') }}
              </button>
              <pre v-if="expanded.has(log.id)" class="detail">{{ detailText(log) }}</pre>
            </template>
            <span v-else class="muted">-</span>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="!loading && logs.length > 0" class="pagination">
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
  </div>
</template>

<style scoped>
.audit { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
.toolbar h2 { margin: 0; font-size: 19px; font-weight: 700; letter-spacing: 0.01em; color: var(--text); }
.filters { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
.filters input, .filters select {
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
.filters input { width: 160px; }
.filters input::placeholder { color: var(--text-faint); }
.filters input:focus, .filters select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(232, 99, 58, 0.14);
}
.filter-select { width: 170px; }
.state { text-align: center; padding: 40px; color: var(--text-muted); }
.error { color: var(--danger); }
.state.error { background: var(--danger-weak); border-radius: var(--radius-sm); }

/* 幽灵按钮（查询 / 重置 / 刷新 / 展开 / 分页共用） */
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
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-sm { padding: 4px 10px; font-size: 12px; }

/* 表格卡片 */
.table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  font-variant-numeric: tabular-nums;
}
.table th, .table td { padding: 10px 12px; text-align: left; border-bottom: 1px solid var(--border); font-size: 13px; vertical-align: top; }
.table th { background: var(--surface-muted); color: var(--text-muted); font-weight: 600; font-size: 12px; letter-spacing: 0.03em; white-space: nowrap; }
.table tbody tr { transition: background var(--duration) var(--ease); }
.table tbody tr:hover { background: var(--surface-muted); }
.table tbody tr:last-child td { border-bottom: none; }
.nowrap { white-space: nowrap; }
.muted { color: var(--text-muted); font-size: 12px; }
.action-tag { display: inline-block; padding: 2px 10px; border-radius: 999px; background: var(--primary-weak); color: var(--primary); font-size: 12px; font-weight: 600; }
.detail { margin: 8px 0 0; padding: 10px 12px; background: var(--surface-muted); border: 1px solid var(--border); border-radius: var(--radius-sm); color: var(--text-muted); font-size: 12px; max-height: 240px; overflow: auto; white-space: pre-wrap; word-break: break-all; }
.pagination { display: flex; align-items: center; gap: 12px; justify-content: flex-end; }
.page-info { color: var(--text-muted); font-size: 13px; font-variant-numeric: tabular-nums; }
</style>
