<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { musicApi, type Music } from '../api/musics'
import { i18n, t } from '../i18n'

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
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
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
    alert(t('请填写歌名', 'Please enter the song title'))
    return
  }
  if (!editingId.value && !audioFile.value) {
    alert(t('请选择音频文件', 'Please choose an audio file'))
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
    alert(e?.response?.data?.message ?? t('保存失败', 'Save failed'))
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
    alert(e?.response?.data?.message ?? t('删除失败', 'Delete failed'))
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
    return new Date(t).toLocaleString(i18n.lang === 'en' ? 'en-US' : 'zh-CN')
  } catch {
    return t
  }
}

onMounted(load)
</script>

<template>
  <div class="music">
    <div class="toolbar">
      <h2>{{ $t('曲库管理', 'Music Library') }}</h2>
      <div class="filters">
        <input
          v-model="keyword"
          class="search-input"
          :placeholder="$t('搜索歌名 / 歌手', 'Search title / artist')"
          @keyup.enter="search"
        />
        <button class="btn" @click="search">{{ $t('搜索', 'Search') }}</button>
        <button class="btn btn-plain" @click="search">{{ $t('刷新', 'Refresh') }}</button>
        <button class="btn btn-primary" @click="openUpload">{{ $t('上传曲目', 'Upload track') }}</button>
      </div>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>
    <div v-else-if="musics.length === 0" class="state">
      {{ $t('暂无曲目数据', 'No tracks yet') }}
    </div>

    <table v-else class="table">
      <thead>
        <tr>
          <th style="width: 60px">ID</th>
          <th style="width: 70px">{{ $t('封面', 'Cover') }}</th>
          <th style="width: 180px">{{ $t('歌名', 'Title') }}</th>
          <th style="width: 140px">{{ $t('歌手', 'Artist') }}</th>
          <th style="width: 80px">{{ $t('时长', 'Duration') }}</th>
          <th>{{ $t('试听', 'Preview') }}</th>
          <th style="width: 150px">{{ $t('创建时间', 'Created') }}</th>
          <th style="width: 140px">{{ $t('操作', 'Actions') }}</th>
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
              :alt="$t('封面', 'Cover')"
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
            <button class="btn btn-sm" @click="openEdit(m)">{{ $t('编辑', 'Edit') }}</button>
            <button class="btn btn-sm btn-danger" @click="openDelete(m.id)">
              {{ $t('删除', 'Delete') }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <div class="pager">
      <span>
        {{ $t('共 {n} 首 · 第 {p} / {t} 页', '{n} tracks · Page {p} / {t}', { n: total, p: page, t: totalPages }) }}
      </span>
      <div class="pager-buttons">
        <button class="btn btn-plain btn-sm" :disabled="page <= 1" @click="prevPage">
          {{ $t('上一页', 'Prev') }}
        </button>
        <button
          class="btn btn-plain btn-sm"
          :disabled="page >= totalPages"
          @click="nextPage"
        >
          {{ $t('下一页', 'Next') }}
        </button>
      </div>
    </div>

    <!-- 上传 / 编辑弹窗 -->
    <div v-if="showUpload" class="modal-overlay" @click.self="closeUpload">
      <div class="modal">
        <h3>{{ editingId ? $t('编辑曲目', 'Edit track') : $t('上传曲目', 'Upload track') }}</h3>
        <label class="field">
          <span>{{ $t('歌名 *', 'Title *') }}</span>
          <input v-model="formTitle" type="text" maxlength="200" :placeholder="$t('请输入歌名', 'Enter title')" />
        </label>
        <label class="field">
          <span>{{ $t('歌手', 'Artist') }}</span>
          <input v-model="formArtist" type="text" maxlength="100" :placeholder="$t('请输入歌手 / 作者', 'Enter artist / author')" />
        </label>
        <label class="field">
          <span>{{ $t('时长（秒）', 'Duration (seconds)') }}</span>
          <input
            v-model.number="formDuration"
            type="number"
            min="0"
            :placeholder="$t('选择音频后自动识别', 'Auto-detected after choosing audio')"
          />
        </label>
        <label class="field">
          <span>
            {{ editingId ? $t('重新上传音频（选填）', 'Re-upload audio (optional)') : $t('音频文件 *', 'Audio file *') }}
          </span>
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
          <span>
            {{ editingId ? $t('重新上传封面（选填）', 'Re-upload cover (optional)') : $t('封面（选填）', 'Cover (optional)') }}
          </span>
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
            :alt="$t('封面预览', 'Cover preview')"
          />
        </div>
        <div class="modal-actions">
          <button class="btn btn-plain btn-sm" :disabled="saving" @click="closeUpload">
            {{ $t('取消', 'Cancel') }}
          </button>
          <button class="btn btn-sm btn-primary" :disabled="saving" @click="saveUpload">
            {{ saving ? $t('保存中…', 'Saving…') : $t('保存', 'Save') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 删除确认弹窗 -->
    <div v-if="deletingId !== null" class="modal-overlay" @click.self="cancelDelete">
      <div class="modal">
        <h3>{{ $t('删除曲目', 'Delete track') }}</h3>
        <p class="modal-tip">
          {{ $t('确认删除该曲目？删除后拍摄页选曲将不再展示。', 'Delete this track? It will no longer appear in the recorder song picker.') }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-plain btn-sm" :disabled="deleting" @click="cancelDelete">
            {{ $t('取消', 'Cancel') }}
          </button>
          <button class="btn btn-sm btn-danger" :disabled="deleting" @click="confirmDelete">
            {{ deleting ? $t('删除中…', 'Deleting…') : $t('确认删除', 'Confirm delete') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.music { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap; }
.toolbar h2 { margin: 0; font-size: 19px; font-weight: 700; letter-spacing: 0.01em; color: var(--text); }
.filters { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.search-input {
  height: 36px;
  padding: 0 12px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 13px;
  width: 200px;
  background: var(--surface);
  color: var(--text);
  transition:
    border-color var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
.search-input::placeholder { color: var(--text-faint); }
.search-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(232, 99, 58, 0.14);
}
.state { text-align: center; padding: 40px; color: var(--text-muted); }
.error { color: var(--danger); }
.state.error { background: var(--danger-weak); border-radius: var(--radius-sm); }

/* 表格卡片 */
.table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  font-size: 13px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  font-variant-numeric: tabular-nums;
}
.table th, .table td {
  padding: 10px 8px;
  border-bottom: 1px solid var(--border);
  text-align: left;
  vertical-align: middle;
}
.table th {
  background: var(--surface-muted);
  color: var(--text-muted);
  font-weight: 600;
  font-size: 12px;
  letter-spacing: 0.03em;
  white-space: nowrap;
}
.table tbody tr { transition: background var(--duration) var(--ease); }
.table tbody tr:hover { background: var(--surface-muted); }
.table tbody tr:last-child td { border-bottom: none; }
.cover {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: var(--radius-sm);
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

/* 按钮：默认幽灵风格；btn-primary 品牌橙实色；危险浅底软风格 */
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
.btn-plain { background: var(--surface); color: var(--text); border: 1px solid var(--border); }
.btn-sm { padding: 4px 10px; font-size: 12px; }
.btn-primary {
  background: var(--primary);
  border-color: transparent;
  color: #fff;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(232, 99, 58, 0.22);
}
.btn-primary:hover:not(:disabled) {
  background: var(--primary-hover);
  border-color: transparent;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(232, 99, 58, 0.3);
}
.btn-primary:active:not(:disabled) {
  background: var(--primary-active);
  transform: translateY(0);
  box-shadow: 0 2px 6px rgba(232, 99, 58, 0.24);
}
.btn-danger { background: var(--danger-weak); color: var(--danger); border-color: transparent; }
.btn-danger:hover:not(:disabled) { background: var(--danger); color: #fff; box-shadow: 0 4px 12px rgba(217, 69, 62, 0.28); }
.btn-danger:active:not(:disabled) { background: var(--danger); color: #fff; box-shadow: none; }
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

/* 弹窗 */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(41, 32, 24, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}
.modal {
  background: var(--surface);
  border-radius: var(--radius-lg);
  padding: 24px;
  width: 440px;
  max-width: 92vw;
  max-height: 88vh;
  overflow-y: auto;
  box-shadow: var(--shadow-lg);
}
.modal h3 { margin: 0 0 16px; font-size: 16px; font-weight: 600; color: var(--text); }
.field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; font-size: 13px; color: var(--text-muted); }
.field input[type='text'],
.field input[type='number'] {
  height: 36px;
  padding: 0 12px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 13px;
  background: var(--surface);
  color: var(--text);
  transition:
    border-color var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease);
}
.field input[type='text']:focus,
.field input[type='number']:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(232, 99, 58, 0.14);
}
.field input[type='file'] { font-size: 13px; }
.preview { margin: -4px 0 14px; }
.preview audio { width: 100%; height: 36px; }
.cover-preview {
  width: 96px;
  height: 96px;
  object-fit: cover;
  border-radius: var(--radius-sm);
  border: 1px solid var(--border);
}
.modal-tip { margin: 0 0 8px; font-size: 13px; color: var(--text-muted); }
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 18px;
}
</style>
