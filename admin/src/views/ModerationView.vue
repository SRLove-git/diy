<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { postApi, type Post } from '../api/posts'
import { videoApi, type Video } from '../api/videos'
import { moderationApi, type ModerationComment } from '../api/moderation'
import { chatAdminApi, type ChatGroup, type ChatMessage } from '../api/chat'
import { refreshPending } from '../stores/pending'
import { t } from '../i18n'

const activeTab = ref<'pending' | 'comments' | 'chat' | 'keywords'>('pending')

// ──── 待审核 ────
const pendingPosts = ref<Post[]>([])
const pendingVideos = ref<Video[]>([])
const loadingPending = ref(true)
const rejectTarget = ref<{ type: 'post' | 'video'; id: number } | null>(null)
const rejectReason = ref('')
const operatingId = ref<number | null>(null)

async function loadPending() {
  loadingPending.value = true
  try {
    const { data: postData } = await postApi.list({ status: 'pending', page: 1 })
    const { data: videoData } = await videoApi.list({ status: 'pending', page: 1 })
    const [posts] = postData
    const [videos] = videoData
    pendingPosts.value = posts
    pendingVideos.value = videos
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('加载失败', 'Failed to load'))
  } finally {
    loadingPending.value = false
  }
}

async function approvePending(type: 'post' | 'video', id: number) {
  operatingId.value = id
  try {
    if (type === 'post') await postApi.updateStatus(id, 'approved')
    else await videoApi.updateStatus(id, 'approved')
    await loadPending()
    await refreshPending()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    operatingId.value = null
  }
}

function openReject(type: 'post' | 'video', id: number) {
  rejectTarget.value = { type, id }
  rejectReason.value = ''
}

async function confirmReject() {
  if (!rejectTarget.value) return
  const { type, id } = rejectTarget.value
  operatingId.value = id
  try {
    if (type === 'post') await postApi.updateStatus(id, 'rejected', rejectReason.value)
    else await videoApi.updateStatus(id, 'rejected', rejectReason.value)
    rejectTarget.value = null
    await loadPending()
    await refreshPending()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    operatingId.value = null
  }
}

// ──── 评论管理 ────
const commentScope = ref<'post' | 'video'>('post')
const comments = ref<ModerationComment[]>([])
const commentTotal = ref(0)
const commentPage = ref(1)
const commentKeyword = ref('')
const commentHidden = ref('')
const loadingComments = ref(false)
const commentTotalPages = computed(() => Math.ceil(commentTotal.value / 20) || 1)

async function loadComments() {
  loadingComments.value = true
  try {
    const [rows, count] = await moderationApi.listComments({
      scope: commentScope.value,
      page: commentPage.value,
      keyword: commentKeyword.value || undefined,
      hidden: commentHidden.value || undefined,
    })
    comments.value = rows
    commentTotal.value = count
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('加载失败', 'Failed to load'))
  } finally {
    loadingComments.value = false
  }
}

function switchCommentScope() {
  commentPage.value = 1
  loadComments()
}

async function toggleCommentHidden(c: ModerationComment) {
  try {
    await moderationApi.hideComment(c.id, commentScope.value, !c.isHidden)
    await loadComments()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  }
}

// ──── 聊天巡查 ────
const chatTab = ref<'groups' | 'messages'>('groups')
const groups = ref<ChatGroup[]>([])
const groupTotal = ref(0)
const groupPage = ref(1)
const groupKeyword = ref('')
const loadingGroups = ref(false)
const groupTotalPages = computed(() => Math.ceil(groupTotal.value / 20) || 1)
const dissolveTarget = ref<ChatGroup | null>(null)
const dissolving = ref(false)

const messages = ref<ChatMessage[]>([])
const messageTotal = ref(0)
const messagePage = ref(1)
const messageScope = ref<'dm' | 'group'>('dm')
const messageKeyword = ref('')
const loadingMessages = ref(false)
const messageTotalPages = computed(() => Math.ceil(messageTotal.value / 20) || 1)
const recallTarget = ref<ChatMessage | null>(null)
const recalling = ref(false)

async function loadGroups() {
  loadingGroups.value = true
  try {
    const [rows, count] = await chatAdminApi.listGroups({
      page: groupPage.value,
      keyword: groupKeyword.value || undefined,
    })
    groups.value = rows
    groupTotal.value = count
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('加载失败', 'Failed to load'))
  } finally {
    loadingGroups.value = false
  }
}

async function confirmDissolve() {
  if (!dissolveTarget.value) return
  dissolving.value = true
  try {
    await chatAdminApi.dissolveGroup(dissolveTarget.value.id)
    dissolveTarget.value = null
    await loadGroups()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    dissolving.value = false
  }
}

async function loadMessages() {
  loadingMessages.value = true
  try {
    const [rows, count] = await chatAdminApi.searchMessages({
      scope: messageScope.value,
      page: messagePage.value,
      keyword: messageKeyword.value || undefined,
    })
    messages.value = rows
    messageTotal.value = count
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('加载失败', 'Failed to load'))
  } finally {
    loadingMessages.value = false
  }
}

async function confirmRecall() {
  if (!recallTarget.value) return
  recalling.value = true
  try {
    await chatAdminApi.recallMessage(recallTarget.value.id, messageScope.value)
    recallTarget.value = null
    await loadMessages()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('操作失败', 'Operation failed'))
  } finally {
    recalling.value = false
  }
}

function messagePreview(m: ChatMessage): string {
  if (m.recalledAt) return t('（已撤回）', '(recalled)')
  if (m.contentType === 'image') return t('[图片]', '[image]')
  if (m.contentType === 'voice') return t('[语音]', '[voice]')
  if (m.contentType === 'video') return t('[视频]', '[video]')
  return m.content
}

// ──── 敏感词 ────
const keywords = ref<string[]>([])
const newKeyword = ref('')
const keywordBusy = ref(false)

async function loadKeywords() {
  try {
    keywords.value = await moderationApi.listKeywords()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('加载失败', 'Failed to load'))
  }
}

async function addKeyword() {
  const kw = newKeyword.value.trim()
  if (!kw) return
  keywordBusy.value = true
  try {
    const res = await moderationApi.addKeyword(kw)
    keywords.value = res.keywords
    newKeyword.value = ''
    if (!res.added) alert(t('关键词已存在', 'Keyword already exists'))
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('添加失败', 'Failed to add'))
  } finally {
    keywordBusy.value = false
  }
}

async function removeKeyword(kw: string) {
  if (!confirm(t('确认删除关键词「{kw}」？', 'Remove keyword "{kw}"?', { kw }))) return
  keywordBusy.value = true
  try {
    const res = await moderationApi.removeKeyword(kw)
    keywords.value = res.keywords
  } catch (e: any) {
    alert(e?.response?.data?.message ?? t('删除失败', 'Failed to remove'))
  } finally {
    keywordBusy.value = false
  }
}

function formatTime(tm: string | null): string {
  if (!tm) return '-'
  const d = new Date(tm)
  return Number.isNaN(d.getTime()) ? '-' : d.toLocaleString()
}

onMounted(async () => {
  await loadPending()
  await loadComments()
  await loadGroups()
  await loadMessages()
  await loadKeywords()
})
</script>

<template>
  <div class="moderation">
    <div class="toolbar">
      <h2>{{ $t('内容审核', 'Moderation') }}</h2>
      <div class="tabs">
        <button class="tab" :class="{ active: activeTab === 'pending' }" @click="activeTab = 'pending'">
          {{ $t('待审核', 'Pending') }}
        </button>
        <button class="tab" :class="{ active: activeTab === 'comments' }" @click="activeTab = 'comments'">
          {{ $t('评论管理', 'Comments') }}
        </button>
        <button class="tab" :class="{ active: activeTab === 'chat' }" @click="activeTab = 'chat'">
          {{ $t('聊天巡查', 'Chat') }}
        </button>
        <button class="tab" :class="{ active: activeTab === 'keywords' }" @click="activeTab = 'keywords'">
          {{ $t('敏感词', 'Keywords') }}
        </button>
      </div>
    </div>

    <!-- 待审核 -->
    <section v-if="activeTab === 'pending'">
      <div v-if="loadingPending" class="state">{{ $t('加载中…', 'Loading…') }}</div>
      <div v-else class="pending-grid">
        <div class="card">
          <h3>{{ $t('待审核帖子', 'Pending posts') }}（{{ pendingPosts.length }}）</h3>
          <table v-if="pendingPosts.length" class="table">
            <thead>
              <tr>
                <th style="width:50px">ID</th>
                <th>{{ $t('内容', 'Content') }}</th>
                <th style="width:90px">{{ $t('互动', 'Engagement') }}</th>
                <th style="width:160px">{{ $t('发布时间', 'Posted') }}</th>
                <th style="width:150px">{{ $t('操作', 'Actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in pendingPosts" :key="p.id">
                <td>{{ p.id }}</td>
                <td class="ellipsis">{{ p.content || '-' }}</td>
                <td class="muted">👍{{ p.likeCount }} 💬{{ p.commentCount }}</td>
                <td class="nowrap">{{ formatTime(p.createdAt) }}</td>
                <td class="actions">
                  <button class="btn btn-sm btn-success" :disabled="operatingId !== null" @click="approvePending('post', p.id)">
                    {{ $t('通过', 'Approve') }}
                  </button>
                  <button class="btn btn-sm btn-danger" :disabled="operatingId !== null" @click="openReject('post', p.id)">
                    {{ $t('驳回', 'Reject') }}
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
          <p v-else class="state small">{{ $t('暂无待审核帖子', 'No pending posts') }}</p>
        </div>

        <div class="card">
          <h3>{{ $t('待审核视频', 'Pending videos') }}（{{ pendingVideos.length }}）</h3>
          <table v-if="pendingVideos.length" class="table">
            <thead>
              <tr>
                <th style="width:50px">ID</th>
                <th>{{ $t('标题/内容', 'Title / Content') }}</th>
                <th style="width:90px">{{ $t('互动', 'Engagement') }}</th>
                <th style="width:160px">{{ $t('发布时间', 'Posted') }}</th>
                <th style="width:150px">{{ $t('操作', 'Actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="v in pendingVideos" :key="v.id">
                <td>{{ v.id }}</td>
                <td class="ellipsis">{{ v.title || v.content || '-' }}</td>
                <td class="muted">👍{{ v.likeCount }} 💬{{ v.commentCount }}</td>
                <td class="nowrap">{{ formatTime(v.createdAt) }}</td>
                <td class="actions">
                  <button class="btn btn-sm btn-success" :disabled="operatingId !== null" @click="approvePending('video', v.id)">
                    {{ $t('通过', 'Approve') }}
                  </button>
                  <button class="btn btn-sm btn-danger" :disabled="operatingId !== null" @click="openReject('video', v.id)">
                    {{ $t('驳回', 'Reject') }}
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
          <p v-else class="state small">{{ $t('暂无待审核视频', 'No pending videos') }}</p>
        </div>
      </div>
    </section>

    <!-- 评论管理 -->
    <section v-if="activeTab === 'comments'">
      <div class="card">
        <div class="card-head">
          <div class="filters">
            <select v-model="commentScope" @change="switchCommentScope">
              <option value="post">{{ $t('帖子评论', 'Post comments') }}</option>
              <option value="video">{{ $t('视频评论', 'Video comments') }}</option>
            </select>
            <input v-model="commentKeyword" type="text" :placeholder="$t('评论内容关键词', 'Content keyword')" @keyup.enter="switchCommentScope" />
            <select v-model="commentHidden" @change="switchCommentScope">
              <option value="">{{ $t('全部状态', 'All status') }}</option>
              <option value="false">{{ $t('正常', 'Visible') }}</option>
              <option value="true">{{ $t('已隐藏', 'Hidden') }}</option>
            </select>
            <button class="btn" @click="switchCommentScope">{{ $t('查询', 'Search') }}</button>
          </div>
        </div>
        <div v-if="loadingComments" class="state">{{ $t('加载中…', 'Loading…') }}</div>
        <table v-else class="table">
          <thead>
            <tr>
              <th style="width:50px">ID</th>
              <th style="width:120px">{{ $t('作者', 'Author') }}</th>
              <th style="width:80px">{{ $t('目标', 'Target') }}</th>
              <th>{{ $t('评论内容', 'Content') }}</th>
              <th style="width:160px">{{ $t('时间', 'Time') }}</th>
              <th style="width:90px">{{ $t('状态', 'Status') }}</th>
              <th style="width:110px">{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in comments" :key="c.id">
              <td>{{ c.id }}</td>
              <td>{{ c.author ? (c.author.nickname || c.author.username || '#' + c.author.id) : '#' + c.userId }}</td>
              <td class="muted">#{{ c.targetId }}</td>
              <td class="ellipsis">{{ c.content }}</td>
              <td class="nowrap">{{ formatTime(c.createdAt) }}</td>
              <td>
                <span class="tag" :class="c.isHidden ? 'tag-banned' : 'tag-normal'">
                  {{ c.isHidden ? $t('已隐藏', 'Hidden') : $t('正常', 'Visible') }}
                </span>
              </td>
              <td class="actions">
                <button class="btn btn-sm" :class="c.isHidden ? 'btn-success' : 'btn-danger'" @click="toggleCommentHidden(c)">
                  {{ c.isHidden ? $t('恢复', 'Restore') : $t('隐藏', 'Hide') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        <p v-if="!loadingComments && comments.length === 0" class="state small">{{ $t('暂无评论', 'No comments') }}</p>
        <div v-if="!loadingComments && comments.length > 0" class="pagination">
          <button class="btn btn-sm" :disabled="commentPage <= 1" @click="commentPage--; loadComments()">
            {{ $t('上一页', 'Prev') }}
          </button>
          <span class="page-info">{{ $t('第 {p} / {t} 页', 'Page {p} / {t}', { p: commentPage, t: commentTotalPages }) }}</span>
          <button class="btn btn-sm" :disabled="commentPage >= commentTotalPages" @click="commentPage++; loadComments()">
            {{ $t('下一页', 'Next') }}
          </button>
        </div>
      </div>
    </section>

    <!-- 聊天巡查 -->
    <section v-if="activeTab === 'chat'">
      <div class="tabs sub">
        <button class="tab" :class="{ active: chatTab === 'groups' }" @click="chatTab = 'groups'; loadGroups()">
          {{ $t('群聊管理', 'Groups') }}
        </button>
        <button class="tab" :class="{ active: chatTab === 'messages' }" @click="chatTab = 'messages'; loadMessages()">
          {{ $t('消息巡查', 'Messages') }}
        </button>
      </div>

      <div v-if="chatTab === 'groups'" class="card">
        <div class="filters">
          <input v-model="groupKeyword" type="text" :placeholder="$t('群名称关键词', 'Group name keyword')" @keyup.enter="groupPage = 1; loadGroups()" />
          <button class="btn" @click="groupPage = 1; loadGroups()">{{ $t('查询', 'Search') }}</button>
        </div>
        <div v-if="loadingGroups" class="state">{{ $t('加载中…', 'Loading…') }}</div>
        <table v-else class="table">
          <thead>
            <tr>
              <th style="width:50px">ID</th>
              <th>{{ $t('群名称', 'Group name') }}</th>
              <th style="width:120px">{{ $t('群主', 'Owner') }}</th>
              <th style="width:70px">{{ $t('成员', 'Members') }}</th>
              <th style="width:200px">{{ $t('最后消息', 'Last message') }}</th>
              <th style="width:160px">{{ $t('创建时间', 'Created') }}</th>
              <th style="width:100px">{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="g in groups" :key="g.id">
              <td>{{ g.id }}</td>
              <td>{{ g.name }}</td>
              <td>{{ g.owner ? (g.owner.nickname || g.owner.username || '#' + g.owner.id) : '#' + g.ownerId }}</td>
              <td>{{ g.memberCount }}</td>
              <td class="ellipsis">{{ g.lastMessagePreview || '-' }}<span class="muted"> {{ g.lastMessageAt ? formatTime(g.lastMessageAt) : '' }}</span></td>
              <td class="nowrap">{{ formatTime(g.createdAt) }}</td>
              <td>
                <button class="btn btn-sm btn-danger" @click="dissolveTarget = g">
                  {{ $t('解散', 'Dissolve') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        <p v-if="!loadingGroups && groups.length === 0" class="state small">{{ $t('暂无群聊', 'No groups') }}</p>
        <div v-if="!loadingGroups && groups.length > 0" class="pagination">
          <button class="btn btn-sm" :disabled="groupPage <= 1" @click="groupPage--; loadGroups()">
            {{ $t('上一页', 'Prev') }}
          </button>
          <span class="page-info">{{ $t('第 {p} / {t} 页', 'Page {p} / {t}', { p: groupPage, t: groupTotalPages }) }}</span>
          <button class="btn btn-sm" :disabled="groupPage >= groupTotalPages" @click="groupPage++; loadGroups()">
            {{ $t('下一页', 'Next') }}
          </button>
        </div>
      </div>

      <div v-else class="card">
        <div class="filters">
          <select v-model="messageScope" @change="messagePage = 1; loadMessages()">
            <option value="dm">{{ $t('私聊消息', 'Private messages') }}</option>
            <option value="group">{{ $t('群消息', 'Group messages') }}</option>
          </select>
          <input v-model="messageKeyword" type="text" :placeholder="$t('消息内容关键词', 'Content keyword')" @keyup.enter="messagePage = 1; loadMessages()" />
          <button class="btn" @click="messagePage = 1; loadMessages()">{{ $t('查询', 'Search') }}</button>
        </div>
        <div v-if="loadingMessages" class="state">{{ $t('加载中…', 'Loading…') }}</div>
        <table v-else class="table">
          <thead>
            <tr>
              <th style="width:50px">ID</th>
              <th style="width:120px">{{ $t('发送人', 'Sender') }}</th>
              <th>{{ $t('内容', 'Content') }}</th>
              <th style="width:160px">{{ $t('时间', 'Time') }}</th>
              <th style="width:90px">{{ $t('状态', 'Status') }}</th>
              <th style="width:100px">{{ $t('操作', 'Actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="m in messages" :key="m.id">
              <td>{{ m.id }}</td>
              <td>{{ m.sender.nickname || m.sender.username || '#' + m.sender.id }}</td>
              <td class="ellipsis">{{ messagePreview(m) }}</td>
              <td class="nowrap">{{ formatTime(m.createdAt) }}</td>
              <td>
                <span class="tag" :class="m.recalledAt ? 'tag-banned' : 'tag-normal'">
                  {{ m.recalledAt ? $t('已撤回', 'Recalled') : $t('正常', 'Active') }}
                </span>
              </td>
              <td>
                <button class="btn btn-sm btn-danger" :disabled="!!m.recalledAt" @click="recallTarget = m">
                  {{ $t('撤回', 'Recall') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        <p v-if="!loadingMessages && messages.length === 0" class="state small">{{ $t('暂无消息', 'No messages') }}</p>
        <div v-if="!loadingMessages && messages.length > 0" class="pagination">
          <button class="btn btn-sm" :disabled="messagePage <= 1" @click="messagePage--; loadMessages()">
            {{ $t('上一页', 'Prev') }}
          </button>
          <span class="page-info">{{ $t('第 {p} / {t} 页', 'Page {p} / {t}', { p: messagePage, t: messageTotalPages }) }}</span>
          <button class="btn btn-sm" :disabled="messagePage >= messageTotalPages" @click="messagePage++; loadMessages()">
            {{ $t('下一页', 'Next') }}
          </button>
        </div>
      </div>
    </section>

    <!-- 敏感词 -->
    <section v-if="activeTab === 'keywords'" class="card">
      <div class="filters">
        <input v-model="newKeyword" type="text" :placeholder="$t('输入新敏感词', 'New keyword')" maxlength="50" @keyup.enter="addKeyword" />
        <button class="btn btn-primary" :disabled="keywordBusy" @click="addKeyword">
          {{ $t('添加', 'Add') }}
        </button>
      </div>
      <div class="keyword-list">
        <span v-for="kw in keywords" :key="kw" class="keyword">
          {{ kw }}
          <button class="keyword-remove" :disabled="keywordBusy" @click="removeKeyword(kw)">×</button>
        </span>
        <p v-if="keywords.length === 0" class="state small">{{ $t('暂无敏感词', 'No keywords') }}</p>
      </div>
      <p class="hint">
        {{ $t('命中敏感词的内容将被机审拦截；修改即时生效。', 'Content matching a keyword is blocked by auto-moderation; changes take effect immediately.') }}
      </p>
    </section>

    <!-- 驳回原因弹窗 -->
    <div v-if="rejectTarget" class="modal-overlay" @click.self="rejectTarget = null">
      <div class="modal">
        <h3>{{ $t('驳回内容', 'Reject content') }} #{{ rejectTarget.id }}</h3>
        <textarea v-model="rejectReason" rows="3" :placeholder="$t('驳回原因（将展示给作者）', 'Reason (shown to the author)')" maxlength="500" />
        <div class="modal-actions">
          <button class="btn btn-sm" @click="rejectTarget = null">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" :disabled="operatingId !== null" @click="confirmReject">
            {{ $t('确认驳回', 'Confirm reject') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 解散群聊确认 -->
    <div v-if="dissolveTarget" class="modal-overlay" @click.self="dissolveTarget = null">
      <div class="modal">
        <h3>{{ $t('解散群聊', 'Dissolve group') }}</h3>
        <p class="modal-desc">
          {{ $t('确认解散群「{name}」？群成员、群消息将全部删除且不可恢复。', 'Dissolve "{name}"? All members and messages will be permanently deleted.', { name: dissolveTarget.name }) }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="dissolveTarget = null">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" :disabled="dissolving" @click="confirmDissolve">
            {{ dissolving ? $t('解散中…', 'Dissolving…') : $t('确认解散', 'Confirm dissolve') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 撤回消息确认 -->
    <div v-if="recallTarget" class="modal-overlay" @click.self="recallTarget = null">
      <div class="modal">
        <h3>{{ $t('撤回消息', 'Recall message') }}</h3>
        <p class="modal-desc">
          {{ $t('确认撤回该消息？撤回后所有用户均不可见。', 'Recall this message? It becomes invisible to all users.') }}
        </p>
        <div class="modal-actions">
          <button class="btn btn-sm" @click="recallTarget = null">{{ $t('取消', 'Cancel') }}</button>
          <button class="btn btn-sm btn-danger" :disabled="recalling" @click="confirmRecall">
            {{ recalling ? $t('撤回中…', 'Recalling…') : $t('确认撤回', 'Confirm recall') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.moderation { display: flex; flex-direction: column; gap: 16px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
.toolbar h2 { margin: 0; font-size: 18px; }
.tabs { display: flex; gap: 6px; }
.tabs.sub { margin-bottom: 12px; }
.tab { padding: 6px 14px; border: 1px solid #eceae6; background: #fff; border-radius: 8px; cursor: pointer; font-size: 13px; }
.tab.active { background: var(--primary); border-color: var(--primary); color: #fff; font-weight: 600; }
.pending-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.card { background: #fff; border-radius: 10px; padding: 16px; box-shadow: var(--shadow); display: flex; flex-direction: column; gap: 12px; }
.card h3 { font-size: 15px; margin: 0; }
.card-head { display: flex; justify-content: space-between; align-items: center; }
.filters { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
.filters input, .filters select { padding: 6px 10px; border: 1px solid #eceae6; border-radius: 8px; font-size: 13px; }
.filters input { width: 180px; }
.state { text-align: center; padding: 30px; color: #8a8a8a; }
.state.small { padding: 14px; }
.table { width: 100%; border-collapse: collapse; }
.table th, .table td { padding: 9px 10px; text-align: left; border-bottom: 1px solid #f0ede9; font-size: 13px; vertical-align: top; }
.table th { background: #faf8f6; color: #6b6b6b; font-weight: 600; white-space: nowrap; }
.nowrap { white-space: nowrap; }
.ellipsis { max-width: 320px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.muted { color: #9a9a9a; font-size: 12px; }
.actions { display: flex; gap: 6px; }
.tag { display: inline-block; padding: 2px 8px; border-radius: 999px; font-size: 12px; background: #f0ede9; color: #555; }
.tag-normal { background: #e8f6ec; color: #2e9e5b; }
.tag-banned { background: #fdecec; color: #d9453e; }
.pagination { display: flex; align-items: center; gap: 12px; justify-content: flex-end; }
.page-info { color: #8a8a8a; font-size: 13px; }
.keyword-list { display: flex; flex-wrap: wrap; gap: 8px; }
.keyword { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; background: #fdeee8; color: #d95b3a; border-radius: 999px; font-size: 13px; }
.keyword-remove { border: none; background: transparent; color: inherit; cursor: pointer; font-size: 15px; line-height: 1; padding: 0; }
.hint { color: #9a9a9a; font-size: 12px; }
.modal-overlay { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.35); display: flex; align-items: center; justify-content: center; z-index: 100; }
.modal { width: 420px; background: #fff; border-radius: 12px; padding: 24px; display: flex; flex-direction: column; gap: 14px; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18); }
.modal h3 { font-size: 16px; }
.modal textarea { padding: 10px; border: 1px solid #eceae6; border-radius: 8px; font-size: 14px; resize: vertical; }
.modal-desc { color: #8a8a8a; font-size: 13px; }
.modal-actions { display: flex; justify-content: flex-end; gap: 8px; }
</style>
