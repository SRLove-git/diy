<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { videoApi, type Video } from '../api/videos'
import { i18n, t } from '../i18n'

const videos = ref<Video[]>([])
const loading = ref(true)
const error = ref('')
const statusFilter = ref('')
const rejectReason = ref('')
const rejectingId = ref<number | null>(null)
const removingId = ref<number | null>(null)
const deletingId = ref<number | null>(null)

const statusTabs = [
  { value: '', label: '全部', labelEn: 'All' },
  { value: 'pending', label: '待审核', labelEn: 'Pending' },
  { value: 'approved', label: '已通过', labelEn: 'Approved' },
  { value: 'rejected', label: '已驳回', labelEn: 'Rejected' },
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

const statusLabelsEn: Record<string, string> = {
  pending: 'Pending',
  approved: 'Approved',
  rejected: 'Rejected',
}

function statusLabel(status: string): string {
  return t(statusLabels[status] ?? status, statusLabelsEn[status] ?? status)
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const params: any = {}
    if (statusFilter.value) params.status = statusFilter.value
    const { data } = await videoApi.list(params)
    videos.value = data[0]
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    loading.value = false
  }
}

async function approve(id: number) {
  try {
    await videoApi.updateStatus(id, 'approved')
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

function openReject(id: number) {
  rejectingId.value = id
  rejectReason.value = ''
}

async function confirmReject() {
  if (!rejectingId.value) return
  try {
    await videoApi.updateStatus(rejectingId.value, 'rejected', rejectReason.value)
    rejectingId.value = null
    rejectReason.value = ''
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

function cancelReject() {
  rejectingId.value = null
  rejectReason.value = ''
}

function openRemove(id: number) {
  removingId.value = id
}

async function confirmRemove() {
  if (!removingId.value) return
  try {
    await videoApi.remove(removingId.value)
    removingId.value = null
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

function cancelRemove() {
  removingId.value = null
}

function openDelete(id: number) {
  deletingId.value = id
}

async function confirmDelete() {
  if (!deletingId.value) return
  try {
    await videoApi.hardDelete(deletingId.value)
    deletingId.value = null
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
  }
}

function cancelDelete() {
  deletingId.value = null
}

function formatTime(t: string): string {
  try {
    const d = new Date(t)
    return d.toLocaleString(i18n.lang === 'en' ? 'en-US' : 'zh-CN')
  } catch {
    return t
  }
}

function mediaType(v: Video): string {
  return v.photos?.length
    ? t('照片 {n} 张', '{n} photos', { n: v.photos.length })
    : t('视频', 'Video')
}

onMounted(load)
</script>

<template>
  <div class="videos">
    <div class="toolbar">
      <h2>{{ $t('视频管理', 'Videos') }}</h2>
      <div class="filters">
        <select v-model="statusFilter" @change="load">
          <option v-for="t in statusTabs" :key="t.value" :value="t.value">
            {{ $t(t.label, t.labelEn) }}
          </option>
        </select>
        <button class="btn" @click="load">{{ $t('刷新', 'Refresh') }}</button>
      </div>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="videos.length === 0" class="state">
      {{ $t('暂无视频数据', 'No videos yet') }}
    </div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width: 60px">ID</th>
          <th style="width: 80px">{{ $t('用户ID', 'User ID') }}</th>
          <th style="width: 70px">{{ $t('类型', 'Type') }}</th>
          <th style="width: 120px">{{ $t('标题', 'Title') }}</th>
          <th>{{ $t('内容', 'Content') }}</th>
          <th style="width: 70px">{{ $t('封面', 'Cover') }}</th>
          <th style="width: 140px">{{ $t('标签', 'Tags') }}</th>
          <th style="width: 80px">{{ $t('状态', 'Status') }}</th>
          <th style="width: 110px">{{ $t('驳回原因', 'Reject reason') }}</th>
          <th style="width: 60px">{{ $t('点赞', 'Likes') }}</th>
          <th style="width: 60px">{{ $t('评论', 'Comments') }}</th>
          <th style="width: 60px">{{ $t('分享', 'Shares') }}</th>
          <th style="width: 60px">{{ $t('浏览', 'Views') }}</th>
          <th style="width: 150px">{{ $t('发布时间', 'Published') }}</th>
          <th style="width: 180px">{{ $t('操作', 'Actions') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="v in videos" :key="v.id">
          <td>{{ v.id }}</td>
          <td>{{ v.userId }}</td>
          <td>{{ mediaType(v) }}</td>
          <td>
            <span class="text-ellipsis" :title="v.title || '-'">{{ v.title || '-' }}</span>
          </td>
          <td class="content-cell">
            <div class="text-ellipsis" :title="v.content || '-'">{{ v.content || '-' }}</div>
          </td>
          <td>
            <img
              v-if="v.cover"
              class="cover"
              :src="v.cover"
              :alt="$t('封面', 'Cover')"
              @error="($event.target as HTMLImageElement).style.display = 'none'"
            />
            <span v-else class="muted">-</span>
          </td>
          <td>
            <span v-if="v.tags.length === 0" class="muted">-</span>
            <span v-else v-for="t in v.tags" :key="t" class="tag">#{{ t }}</span>
          </td>
          <td>
            <span
              class="status-tag"
              :style="{ color: statusColors[v.status], borderColor: statusColors[v.status] }"
            >
              {{ statusLabel(v.status) }}
            </span>
          </td>
          <td>
            <span v-if="v.rejectReason" class="reject-reason">{{ v.rejectReason }}</span>
            <span v-else class="muted">-</span>
          </td>
          <td>{{ v.likeCount }}</td>
          <td>{{ v.commentCount }}</td>
          <td>{{ v.shareCount }}</td>
          <td>{{ v.viewCount }}</td>
          <td>{{ formatTime(v.createdAt) }}</td>
          <td class="actions">
            <button
              v-if="v.status === 'pending'"
              class="btn btn-sm btn-success"
              @click="approve(v.id)"
            >
              {{ $t('通过', 'Approve') }}
            </button>
            <button
              v-if="v.status === 'pending'"
              class="btn btn-sm btn-danger"
              @click="openReject(v.id)"
            >
              {{ $t('驳回', 'Reject') }}
            </button>
            <button
              v-if="v.status === 'approved'"
              class="btn btn-sm btn-danger"
              @click="openRemove(v.id)"
            >
              {{ $t('下架', 'Remove') }}
            </button>
            <button
              v-if="v.status === 'rejected'"
              class="btn btn-sm btn-success"
              @click="approve(v.id)"
            >
              {{ $t('上架', 'Restore') }}
            </button>
            <button
              class="btn btn-sm btn-delete"
              @click="openDelete(v.id)"
            >
              {{ $t('删除', 'Delete') }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 驳回弹窗 -->
    <div v-if="rejectingId !== null" class="modal-overlay" @click.self="cancelReject">
      <div class="modal">
        <h3>{{ $t('驳回视频', 'Reject video') }}</h3>
        <textarea
          v-model="rejectReason"
          :placeholder="$t('请输入驳回原因（选填）', 'Enter reject reason (optional)')"
          rows="3"
        ></textarea>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelReject">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" @click="confirmReject">
            {{ $t('确认驳回', 'Confirm reject') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 下架确认弹窗 -->
    <div v-if="removingId !== null" class="modal-overlay" @click.self="cancelRemove">
      <div class="modal">
        <h3>{{ $t('下架视频', 'Remove video') }}</h3>
        <p class="modal-tip">
          {{ $t('确认下架该视频？下架后信息流和主页中将不再展示。', 'Remove this video? It will no longer be shown in feeds and on profiles.') }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelRemove">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" @click="confirmRemove">
            {{ $t('确认下架', 'Confirm remove') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 删除确认弹窗 -->
    <div v-if="deletingId !== null" class="modal-overlay" @click.self="cancelDelete">
      <div class="modal">
        <h3>{{ $t('删除视频', 'Delete video') }}</h3>
        <p class="modal-tip">
          {{ $t('确认永久删除该作品？删除后不可恢复，其点赞与评论记录将一并清除。', 'Permanently delete this video? This cannot be undone; its likes and comments will also be removed.') }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelDelete">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" @click="confirmDelete">
            {{ $t('确认删除', 'Confirm delete') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.videos { display: flex; flex-direction: column; gap: 16px; }
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
.content-cell { max-width: 180px; }
.text-ellipsis {
  display: inline-block;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 180px;
  vertical-align: middle;
}
.cover {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 6px;
  border: 1px solid #eceae6;
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
.btn-delete { background: #fff; color: #d9453e; border: 1px solid #f3d0cd; }
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
.modal-tip {
  margin: 0 0 8px;
  font-size: 13px;
  color: #555;
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}
</style>
