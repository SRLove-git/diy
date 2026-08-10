<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { postApi, type Post } from '../api/posts'
import { i18n, t } from '../i18n'

const posts = ref<Post[]>([])
const loading = ref(true)
const error = ref('')
const statusFilter = ref('')
const rejectReason = ref('')
const rejectingId = ref<number | null>(null)
const removingId = ref<number | null>(null)
const deletingId = ref<number | null>(null)
const previewPost = ref<Post | null>(null)
const previewIndex = ref(0)

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
    const { data } = await postApi.list(params)
    posts.value = data[0]
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    loading.value = false
  }
}

async function approve(id: number) {
  try {
    await postApi.updateStatus(id, 'approved')
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
    await postApi.updateStatus(rejectingId.value, 'rejected', rejectReason.value)
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
    await postApi.remove(removingId.value)
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
    await postApi.hardDelete(deletingId.value)
    deletingId.value = null
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
  }
}

function cancelDelete() {
  deletingId.value = null
}

function openPreview(p: Post, index = 0) {
  previewPost.value = p
  previewIndex.value = index
}

function closePreview() {
  previewPost.value = null
}

function prevImage() {
  if (!previewPost.value) return
  previewIndex.value =
    (previewIndex.value - 1 + previewPost.value.images.length) % previewPost.value.images.length
}

function nextImage() {
  if (!previewPost.value) return
  previewIndex.value = (previewIndex.value + 1) % previewPost.value.images.length
}

function formatTime(t: string): string {
  try {
    const d = new Date(t)
    return d.toLocaleString(i18n.lang === 'en' ? 'en-US' : 'zh-CN')
  } catch {
    return t
  }
}

onMounted(load)
</script>

<template>
  <div class="posts">
    <div class="toolbar">
      <h2>{{ $t('社区管理', 'Posts') }}</h2>
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
    <div v-else-if="posts.length === 0" class="state">
      {{ $t('暂无作品数据', 'No posts yet') }}
    </div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width: 60px">ID</th>
          <th style="width: 80px">{{ $t('用户ID', 'User ID') }}</th>
          <th>{{ $t('内容', 'Content') }}</th>
          <th>{{ $t('图片', 'Images') }}</th>
          <th>{{ $t('标签', 'Tags') }}</th>
          <th style="width: 80px">{{ $t('状态', 'Status') }}</th>
          <th>{{ $t('驳回原因', 'Reject reason') }}</th>
          <th style="width: 80px">{{ $t('点赞', 'Likes') }}</th>
          <th style="width: 80px">{{ $t('收藏', 'Collects') }}</th>
          <th style="width: 80px">{{ $t('评论', 'Comments') }}</th>
          <th style="width: 150px">{{ $t('发布时间', 'Published') }}</th>
          <th style="width: 180px">{{ $t('操作', 'Actions') }}</th>
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
            <button v-else class="img-btn" @click="openPreview(p)">
              {{ $t('{n} 张', '{n} images', { n: p.images.length }) }}
            </button>
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
              {{ statusLabel(p.status) }}
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
              {{ $t('通过', 'Approve') }}
            </button>
            <button
              v-if="p.status === 'pending'"
              class="btn btn-sm btn-danger"
              @click="openReject(p.id)"
            >
              {{ $t('驳回', 'Reject') }}
            </button>
            <button
              v-if="p.status === 'approved'"
              class="btn btn-sm btn-danger"
              @click="openRemove(p.id)"
            >
              {{ $t('下架', 'Remove') }}
            </button>
            <button
              v-if="p.status === 'rejected'"
              class="btn btn-sm btn-success"
              @click="approve(p.id)"
            >
              {{ $t('上架', 'Restore') }}
            </button>
            <button
              class="btn btn-sm btn-delete"
              @click="openDelete(p.id)"
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
        <h3>{{ $t('驳回作品', 'Reject post') }}</h3>
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
        <h3>{{ $t('下架作品', 'Remove post') }}</h3>
        <p class="modal-tip">
          {{ $t('确认下架该作品？下架后社区中将不再展示。', 'Remove this post? It will no longer be shown in the community.') }}
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
        <h3>{{ $t('删除作品', 'Delete post') }}</h3>
        <p class="modal-tip">
          {{ $t('确认永久删除该作品？删除后不可恢复，其点赞、评论与收藏记录将一并清除。', 'Permanently delete this post? This cannot be undone; its likes, comments and collects will also be removed.') }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="cancelDelete">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" @click="confirmDelete">
            {{ $t('确认删除', 'Confirm delete') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 图片预览 -->
    <div v-if="previewPost !== null" class="modal-overlay" @click.self="closePreview">
      <div class="preview-modal">
        <div class="preview-head">
          <h3>
            {{ $t('作品 #{id}', 'Post #{id}', { id: previewPost.id }) }} · {{ previewIndex + 1 }} / {{ previewPost.images.length }}
          </h3>
          <button class="btn btn-sm" @click="closePreview">{{ $t('关闭', 'Close') }}</button>
        </div>
        <div class="preview-body">
          <button
            v-if="previewPost.images.length > 1"
            class="preview-nav prev"
            @click.stop="prevImage"
          >‹</button>
          <img
            class="preview-img"
            :src="previewPost.images[previewIndex]"
            :alt="$t('作品 {id} 图片 {n}', 'Post {id} image {n}', { id: previewPost.id, n: previewIndex + 1 })"
            @error="($event.target as HTMLImageElement).src = 'data:image/svg+xml;utf8,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22100%22 height=%22100%22><rect width=%22100%22 height=%22100%22 fill=%22%23f0eeea%22/></svg>'"
          />
          <button
            v-if="previewPost.images.length > 1"
            class="preview-nav next"
            @click.stop="nextImage"
          >›</button>
        </div>
        <div class="preview-thumbs" v-if="previewPost.images.length > 1">
          <img
            v-for="(img, i) in previewPost.images"
            :key="i"
            class="thumb"
            :class="{ active: i === previewIndex }"
            :src="img"
            @click="previewIndex = i"
          />
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
.img-btn {
  border: 1px solid #eceae6;
  background: #fff;
  border-radius: 6px;
  padding: 2px 8px;
  font-size: 12px;
  color: #e8633a;
  cursor: pointer;
}
.preview-modal {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  width: 720px;
  max-width: 94vw;
}
.preview-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}
.preview-head h3 { margin: 0; font-size: 15px; }
.preview-body {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 320px;
  background: #f7f5f2;
  border-radius: 8px;
  overflow: hidden;
}
.preview-img {
  max-width: 100%;
  max-height: 520px;
  object-fit: contain;
}
.preview-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background: rgba(0,0,0,0.45);
  color: #fff;
  font-size: 22px;
  line-height: 1;
  cursor: pointer;
  z-index: 2;
}
.preview-nav.prev { left: 10px; }
.preview-nav.next { right: 10px; }
.preview-thumbs {
  display: flex;
  gap: 8px;
  margin-top: 12px;
  overflow-x: auto;
}
.thumb {
  width: 56px;
  height: 56px;
  object-fit: cover;
  border-radius: 6px;
  border: 2px solid transparent;
  cursor: pointer;
}
.thumb.active { border-color: #e8633a; }
</style>
