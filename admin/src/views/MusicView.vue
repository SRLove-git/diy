<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { musicApi, type Music } from '../api/musics'

const musics = ref<Music[]>([])
const loading = ref(true)
const error = ref('')
const keyword = ref('')
const page = ref(1)
const pageSize = 20
const total = ref(0)

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / pageSize)))

async function load() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await musicApi.list({
      keyword: keyword.value || undefined,
      page: page.value,
      pageSize,
    })
    musics.value = data[0]
    total.value = data[1]
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? '加载失败'
  } finally {
    loading.value = false
  }
}

function search() {
  page.value = 1
  load()
}

function prevPage() {
  if (page.value > 1) {
    page.value -= 1
    load()
  }
}

function nextPage() {
  if (page.value < totalPages.value) {
    page.value += 1
    load()
  }
}

// ──── 新增 / 编辑表单 ────

const showUpload = ref(false)
const editingId = ref<number | null>(null)
const saving = ref(false)
const formTitle = ref('')
const formArtist = ref('')
const formDuration = ref(0)
const audioFile = ref<File | null>(null)
const coverFile = ref<File | null>(null)
const audioPreview = ref('')
const coverPreview = ref('')
const audioInput = ref<HTMLInputElement | null>(null)
const coverInput = ref<HTMLInputElement | null>(null)
const existingMusicUrl = ref('')
const existingCover = ref('')

function resetForm() {
  editingId.value = null
  formTitle.value = ''
  formArtist.value = ''
  formDuration.value = 0
  audioFile.value = null
  coverFile.value = null
  audioPreview.value = ''
  coverPreview.value = ''
  existingMusicUrl.value = ''
  existingCover.value = ''
  if (audioInput.value) audioInput.value.value = ''
  if (coverInput.value) coverInput.value.value = ''
}

function openUpload() {
  resetForm()
  showUpload.value = true
}

function closeUpload() {
  if (saving.value) return
  showUpload.value = false
  resetForm()
}

function openEdit(m: Music) {
  resetForm()
  editingId.value = m.id
  formTitle.value = m.title
  formArtist.value = m.artist
  formDuration.value = m.duration
  existingMusicUrl.value = m.musicUrl
  existingCover.value = m.cover
  showUpload.value = true
}

function onAudioSelected(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  audioFile.value = file ?? null
  if (audioPreview.value) {
    URL.revokeObjectURL(audioPreview.value)
    audioPreview.value = ''
  }
  if (!file) return
  const url = URL.createObjectURL(file)
  audioPreview.value = url
  // 读取音频时长，自动填充
  const el = new Audio(url)
  el.addEventListener(
    'loadedmetadata',
    () => {
      if (Number.isFinite(el.duration)) {
        formDuration.value = Math.round(el.duration)
      }
      URL.revokeObjectURL(url)
    },
    { once: true },
  )
  el.addEventListener('error', () => URL.revokeObjectURL(url), { once: true })
}

function onCoverSelected(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  coverFile.value = file ?? null
  if (coverPreview.value) {
    URL.revokeObjectURL(coverPreview.value)
    coverPreview.value = ''
  }
  if (file) coverPreview.value = URL.createObjectURL(file)
}

async function saveUpload() {
  if (!formTitle.value.trim()) {
    alert('请填写歌名')
    return
  }
  if (!editingId.value && !audioFile.value) {
    alert('请选择音频文件')
    return
  }
  saving.value = true
  try {
    let musicUrl = existingMusicUrl.value
    let cover = existingCover.value
    if (audioFile.value || coverFile.value) {
      const form = new FormData()
      if (audioFile.value) form.append('file', audioFile.value)
      if (coverFile.value) form.append('cover', coverFile.value)
      const res = editingId.value
        ? await musicApi.replaceFiles(editingId.value, form)
        : await musicApi.upload(form)
      musicUrl = res.data.musicUrl
      cover = res.data.cover
    }
    if (editingId.value) {
      await musicApi.update(editingId.value, {
        title: formTitle.value.trim(),
        artist: formArtist.value.trim(),
        duration: formDuration.value,
        musicUrl,
        cover,
      })
    }
    showUpload.value = false
    resetForm()
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '保存失败')
  } finally {
    saving.value = false
  }
}

// ──── 删除 ────

const deletingId = ref<number | null>(null)
const deleting = ref(false)

function openDelete(id: number) {
  deletingId.value = id
}

async function confirmDelete() {
  if (deletingId.value === null) return
  deleting.value = true
  try {
    await musicApi.remove(deletingId.value)
    deletingId.value = null
    if (musics.value.length === 1 && page.value > 1) page.value -= 1
    await load()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
  } finally {
    deleting.value = false
  }
}

function cancelDelete() {
  if (deleting.value) return
  deletingId.value = null
}

// ──── 展示辅助 ────

function toUrl(u: string): string {
  return u || ''
}

function formatDuration(seconds: number): string {
  if (!seconds) return '-'
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return `${m}:${String(s).padStart(2, '0')}`
}

function formatTime(t: string): string {
  try {
    return new Date(t).toLocaleString('zh-CN')
  } catch {
    return t
  }
}

onMounted(load)
</script>

<template>
  <div class="music">
    <div class="toolbar">
      <h2>曲库管理</h2>
      <div class="filters">
        <input
          v-model="keyword"
          class="search-input"
          placeholder="搜索歌名 / 歌手"
          @keyup.enter="search"
        />
        <button class="btn" @click="search">搜索</button>
        <button class="btn btn-plain" @click="search">刷新</button>
        <button class="btn" @click="openUpload">上传曲目</button>
      </div>
    </div>

    <div v-if="loading" class="state">加载中…</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="musics.length === 0" class="state">暂无曲目数据</div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width: 60px">ID</th>
          <th style="width: 70px">封面</th>
          <th style="width: 180px">歌名</th>
          <th style="width: 140px">歌手</th>
          <th style="width: 80px">时长</th>
          <th>试听</th>
          <th style="width: 150px">创建时间</th>
          <th style="width: 140px">操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="m in musics" :key="m.id">
          <td>{{ m.id }}</td>
          <td>
            <img
              v-if="m.cover"
              class="cover"
              :src="toUrl(m.cover)"
              alt="封面"
              @error="($event.target as HTMLImageElement).style.display = 'none'"
            />
            <span v-else class="muted">-</span>
          </td>
          <td>
            <span class="title" :title="m.title">{{ m.title }}</span>
          </td>
          <td>
            <span class="muted">{{ m.artist || '-' }}</span>
          </td>
          <td>{{ formatDuration(m.duration) }}</td>
          <td>
            <audio
              v-if="m.musicUrl"
              controls
              preload="none"
              :src="toUrl(m.musicUrl)"
              style="height: 32px"
            ></audio>
            <span v-else class="muted">-</span>
          </td>
          <td>{{ formatTime(m.createdAt) }}</td>
          <td class="actions">
            <button class="btn btn-sm" @click="openEdit(m)">编辑</button>
            <button class="btn btn-sm btn-danger" @click="openDelete(m.id)">
              删除
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <div class="pager">
      <span>共 {{ total }} 首 · 第 {{ page }} / {{ totalPages }} 页</span>
      <div class="pager-buttons">
        <button class="btn btn-plain btn-sm" :disabled="page <= 1" @click="prevPage">
          上一页
        </button>
        <button
          class="btn btn-plain btn-sm"
          :disabled="page >= totalPages"
          @click="nextPage"
        >
          下一页
        </button>
      </div>
    </div>

    <!-- 上传 / 编辑弹窗 -->
    <div v-if="showUpload" class="modal-overlay" @click.self="closeUpload">
      <div class="modal">
        <h3>{{ editingId ? '编辑曲目' : '上传曲目' }}</h3>
        <label class="field">
          <span>歌名 *</span>
          <input v-model="formTitle" type="text" maxlength="200" placeholder="请输入歌名" />
        </label>
        <label class="field">
          <span>歌手</span>
          <input v-model="formArtist" type="text" maxlength="100" placeholder="请输入歌手 / 作者" />
        </label>
        <label class="field">
          <span>时长（秒）</span>
          <input
            v-model.number="formDuration"
            type="number"
            min="0"
            placeholder="选择音频后自动识别"
          />
        </label>
        <label class="field">
          <span>{{ editingId ? '重新上传音频（选填）' : '音频文件 *' }}</span>
          <input
            ref="audioInput"
            type="file"
            accept="audio/*"
            @change="onAudioSelected"
          />
        </label>
        <div v-if="audioPreview || existingMusicUrl" class="preview">
          <audio
            v-if="audioPreview || existingMusicUrl"
            controls
            preload="none"
            :src="audioPreview || toUrl(existingMusicUrl)"
          ></audio>
        </div>
        <label class="field">
          <span>{{ editingId ? '重新上传封面（选填）' : '封面（选填）' }}</span>
          <input
            ref="coverInput"
            type="file"
            accept="image/*"
            @change="onCoverSelected"
          />
        </label>
        <div v-if="coverPreview || existingCover" class="preview">
          <img
            class="cover-preview"
            :src="coverPreview || toUrl(existingCover)"
            alt="封面预览"
          />
        </div>
        <div class="modal-actions">
          <button class="btn btn-plain btn-sm" :disabled="saving" @click="closeUpload">
            取消
          </button>
          <button class="btn btn-sm" :disabled="saving" @click="saveUpload">
            {{ saving ? '保存中…' : '保存' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 删除确认弹窗 -->
    <div v-if="deletingId !== null" class="modal-overlay" @click.self="cancelDelete">
      <div class="modal">
        <h3>删除曲目</h3>
        <p class="modal-tip">确认删除该曲目？删除后拍摄页选曲将不再展示。</p>
        <div class="modal-actions">
          <button class="btn btn-plain btn-sm" :disabled="deleting" @click="cancelDelete">
            取消
          </button>
          <button class="btn btn-sm btn-danger" :disabled="deleting" @click="confirmDelete">
            {{ deleting ? '删除中…' : '确认删除' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.music { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap; }
.toolbar h2 { margin: 0; font-size: 18px; }
.filters { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.search-input {
  padding: 7px 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  font-size: 13px;
  width: 200px;
}
.state { text-align: center; padding: 40px; color: var(--text-muted); }
.error { color: var(--danger); }
.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.table th, .table td {
  padding: 10px 8px;
  border-bottom: 1px solid var(--border);
  text-align: left;
  vertical-align: middle;
}
.table th {
  background: #f7f5f2;
  font-weight: 600;
  color: var(--text);
}
.cover {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 6px;
  border: 1px solid var(--border);
}
.title {
  display: inline-block;
  max-width: 170px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  vertical-align: middle;
}
.btn {
  background: var(--primary);
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 13px;
  cursor: pointer;
}
.btn:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-plain { background: #fff; color: var(--text); border: 1px solid var(--border); }
.btn-sm { padding: 4px 10px; font-size: 12px; }
.btn-danger { background: var(--danger); }
.muted { color: var(--text-muted); }
.actions { white-space: nowrap; }
.actions .btn { margin-right: 6px; }
.pager {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
  color: var(--text-muted);
}
.pager-buttons { display: flex; gap: 8px; }

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
  width: 440px;
  max-width: 92vw;
  max-height: 88vh;
  overflow-y: auto;
}
.modal h3 { margin: 0 0 16px; font-size: 16px; }
.field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; font-size: 13px; color: #555; }
.field input[type='text'],
.field input[type='number'] {
  padding: 9px 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  font-size: 13px;
}
.field input[type='file'] { font-size: 13px; }
.preview { margin: -4px 0 14px; }
.preview audio { width: 100%; height: 36px; }
.cover-preview {
  width: 96px;
  height: 96px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid var(--border);
}
.modal-tip { margin: 0 0 8px; font-size: 13px; color: #555; }
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 18px;
}
</style>
