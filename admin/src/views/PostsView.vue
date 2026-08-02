<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { postApi, type Post } from '../api/posts'

const posts = ref<Post[]>([])
const loading = ref(true)
const error = ref('')
const statusFilter = ref('')
const rejectReason = ref('')
const rejectingId = ref<number | null>(null)

const statusTabs = [
  { value: '', label: '全部' },
  { value: 'pending', label: '待审核' },
  { value: 'approved', label: '已通过' },
  { value: 'rejected', label: '已驳回' },
]

const statusLabels: Record<string, string> = {
  pending: '待审核',
  approved: '已通过',
  rejected: '已驳回',
}

const statusColors: Record<string, string> = {
  pending: '#E6A23C',
  approved: '#2E9E5B',
  rejected: '#D9453E',
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const params: any = {}
    if (statusFilter.value) params.status = statusFilter.value
    const { data } = await postApi.list(params)
    posts.value = data[0]
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
}

async function approve(id: number) {
  try {
    await postApi.updateStatus(id, 'approved')
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

function openReject(id: number) {
  rejectingId.value = id
  rejectReason.value = ''
}

async function confirmReject() {
  if (!rejectingId.value) return
  try {
    await postApi.updateStatus(rejectingId.value, 'rejected', rejectReason.value)
    rejectingId.value = null
    rejectReason.value = ''
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

function cancelReject() {
  rejectingId.value = null
  rejectReason.value = ''
}

async function removePost(id: number) {
  if (!confirm('确认下架该作品？')) return
  try {
    await postApi.remove(id)
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

onMounted(load)
</script>

<template>
  <div class="posts">
    <div class="toolbar">
      <h2>作品审核管理</h2>
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
    <div v-else-if="posts.length === 0" class="state">暂无作品数据</div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width: 60px">ID</th>
          <th style="width: 80px">用户ID</th>
          <th>内容</th>
          <th>图片</th>
          <th>标签</th>
          <th style="width: 80px">状态</th>
          <th>驳回原因</th>
          <th style="width: 80px">点赞</th>
          <th style="width: 80px">收藏</th>
          <th style="width: 80px">评论</th>
          <th style="width: 150px">发布时间</th>
          <th style="width: 180px">操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="p in posts" :key="p.id">
          <td>{{ p.id }}</td>
          <td>{{ p.userId }}</td>
          <td class="content-cell">
            <div class="text-ellipsis">{{ p.content || '-' }}</div>
          </td>
          <td>
            <span v-if="p.images.length === 0" class="muted">-</span>
            <span v-else>{{ p.images.length }} 张</span>
          </td>
          <td>
            <span v-if="p.tags.length === 0" class="muted">-</span>
            <span v-else v-for="t in p.tags" :key="t" class="tag">#{{ t }}</span>
          </td>
          <td>
            <span
              class="status-tag"
              :style="{ color: statusColors[p.status], borderColor: statusColors[p.status] }"
            >
              {{ statusLabels[p.status] ?? p.status }}
            </span>
          </td>
          <td>
            <span v-if="p.rejectReason" class="reject-reason">{{ p.rejectReason }}</span>
            <span v-else class="muted">-</span>
          </td>
          <td>{{ p.likeCount }}</td>
          <td>{{ p.collectCount }}</td>
          <td>{{ p.commentCount }}</td>
          <td>{{ formatTime(p.createdAt) }}</td>
          <td class="actions">
            <button
              v-if="p.status === 'pending'"
              class="btn btn-sm btn-success"
              @click="approve(p.id)"
            >
              通过
            </button>
            <button
              v-if="p.status === 'pending'"
              class="btn btn-sm btn-danger"
              @click="openReject(p.id)"
            >
              驳回
            </button>
            <button
              v-if="p.status === 'approved'"
              class="btn btn-sm btn-danger"
              @click="removePost(p.id)"
            >
              下架
            </button>
            <span v-if="p.status === 'rejected'" class="muted">-</span>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 驳回弹窗 -->
    <div v-if="rejectingId !== null" class="modal-overlay" @click.self="cancelReject">
      <div class="modal">
        <h3>驳回作品</h3>
        <textarea
          v-model="rejectReason"
          placeholder="请输入驳回原因（选填）"
          rows="3"
        ></textarea>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelReject">取消</button>
          <button class="btn btn-sm btn-danger" @click="confirmReject">确认驳回</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.posts { display: flex; flex-direction: column; gap: 16px; }
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
  vertical-align: middle;
}
.table th {
  background: #f7f5f2;
  font-weight: 600;
  color: #2b2b2b;
}
.content-cell { max-width: 200px; }
.text-ellipsis {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}
.tag {
  display: inline-block;
  font-size: 11px;
  color: #e8633a;
  margin-right: 4px;
}
.status-tag {
  display: inline-block;
  padding: 2px 8px;
  border: 1px solid;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}
.reject-reason {
  font-size: 12px;
  color: #d9453e;
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
.muted { color: #8a8a8a; }
.actions { white-space: nowrap; }

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
  border-radius: 12px;
  padding: 24px;
  width: 400px;
  max-width: 90vw;
}
.modal h3 { margin: 0 0 16px; font-size: 16px; }
.modal textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #eceae6;
  border-radius: 8px;
  font-size: 13px;
  resize: vertical;
  box-sizing: border-box;
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
</style>
