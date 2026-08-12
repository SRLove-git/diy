<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { dashboardApi, type DashboardOverview, type TrendItem } from '../api/dashboard'
import { t } from '../i18n'

const overview = ref<DashboardOverview | null>(null)
const trends = ref<TrendItem[]>([])
const loading = ref(true)
const error = ref('')

async function load() {
  loading.value = true
  error.value = ''
  try {
    const [ov, tr] = await Promise.all([dashboardApi.overview(), dashboardApi.trends()])
    overview.value = ov
    trends.value = tr
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? t('加载失败', 'Failed to load')
  } finally {
    loading.value = false
  }
}

onMounted(load)

// 柱状图最大比例值
const maxVal = computed(() => {
  let max = 1
  for (const t of trends.value) {
    max = Math.max(max, t.users, t.appointments, t.posts, t.videos)
  }
  return max
})
</script>

<template>
  <div class="dashboard">
    <div class="toolbar">
      <h2>{{ $t('数据看板', 'Dashboard') }}</h2>
      <button class="btn btn-sm" @click="load">{{ $t('刷新', 'Refresh') }}</button>
    </div>

    <div v-if="loading" class="state">{{ $t('加载中…', 'Loading…') }}</div>
    <div v-else-if="error" class="state error">{{ error }}</div>

    <template v-else-if="overview">
      <!-- 核心指标卡片 -->
      <section class="cards">
        <div class="card">
          <div class="card-label">{{ $t('累计用户', 'Total users') }}</div>
          <div class="card-value">{{ overview.users.total.toLocaleString() }}</div>
          <div class="card-sub">
            {{ $t('今日新增 {n}', 'New today {n}', { n: overview.users.today }) }}
          </div>
        </div>
        <div class="card">
          <div class="card-label">{{ $t('累计预约', 'Total bookings') }}</div>
          <div class="card-value">{{ overview.appointments.total.toLocaleString() }}</div>
          <div class="card-sub">
            {{ $t('今日新增 {n}', 'New today {n}', { n: overview.appointments.today }) }}
          </div>
        </div>
        <div class="card">
          <div class="card-label">{{ $t('核销中', 'Checked in') }}</div>
          <div class="card-value">{{ overview.appointments.checkedIn }}</div>
          <div class="card-sub">
            {{ $t('服务中 {n}', 'In service {n}', { n: overview.appointments.inService }) }}
          </div>
        </div>
        <div class="card">
          <div class="card-label">{{ $t('已完成订单', 'Completed orders') }}</div>
          <div class="card-value">{{ overview.appointments.completed.toLocaleString() }}</div>
        </div>
        <!-- 社区 / Reels 前期暂不开放，相关指标卡先隐藏 -->
        <!-- <div class="card">
          <div class="card-label">累计作品</div>
          <div class="card-value">{{ overview.community.totalPosts.toLocaleString() }}</div>
          <div class="card-sub">今日 {{ overview.community.todayPosts }} 篇</div>
        </div>
        <div class="card">
          <div class="card-label">今日互动</div>
          <div class="card-value">{{ (overview.community.todayLikes + overview.community.todayComments).toLocaleString() }}</div>
          <div class="card-sub">点赞 {{ overview.community.todayLikes }} · 评论 {{ overview.community.todayComments }}</div>
        </div>
        <div class="card">
          <div class="card-label">短视频 / 照片作品</div>
          <div class="card-value">{{ overview.videos.total.toLocaleString() }}</div>
          <div class="card-sub">今日新增 {{ overview.videos.today }}</div>
        </div> -->
      </section>

      <!-- 社区 / Reels 前期暂不开放，待办审核先隐藏 -->
      <!-- <section class="todo-section">
        <h3>待办审核</h3>
        <div class="todo-cards">
          <RouterLink to="/posts" class="todo-card">
            <div class="todo-num">{{ overview.pending.posts }}</div>
            <div class="todo-label">社区作品待审核</div>
          </RouterLink>
          <RouterLink to="/videos" class="todo-card">
            <div class="todo-num">{{ overview.pending.videos }}</div>
            <div class="todo-label">短视频待审核</div>
          </RouterLink>
        </div>
      </section> -->

      <!-- 近7天趋势图表 -->
      <section class="chart-section">
        <h3>{{ $t('近 7 天趋势', 'Last 7 days trend') }}</h3>
        <div class="chart-table">
          <table class="table">
            <thead>
              <tr>
                <th>{{ $t('日期', 'Date') }}</th>
                <th>{{ $t('新注册', 'New sign-ups') }}</th>
                <th>{{ $t('新预约', 'New bookings') }}</th>
                <!-- <th>新作品</th>
                <th>点赞</th>
                <th>评论</th>
                <th>短视频</th> -->
              </tr>
            </thead>
            <tbody>
              <tr v-for="t in trends" :key="t.date">
                <td>{{ t.date }}</td>
                <td>{{ t.users }}</td>
                <td>{{ t.appointments }}</td>
                <!-- <td>{{ t.posts }}</td>
                <td>{{ t.likes }}</td>
                <td>{{ t.comments }}</td>
                <td>{{ t.videos }}</td> -->
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- 简易柱状图 -->
      <section class="chart-section">
        <h3>{{ $t('数据趋势图', 'Trend chart') }}</h3>
        <div class="bar-chart">
          <div
            v-for="t in trends"
            :key="t.date"
            class="bar-col"
            :title="`${t.date}: ${$t('注册', 'Sign-ups')} ${t.users} | ${$t('预约', 'Bookings')} ${t.appointments}`"
          >
            <div class="bar-group">
              <div
                class="bar bar-u"
                :style="{ height: Math.max(t.users / maxVal * 100, 8) + '%' }"
              ></div>
              <div
                class="bar bar-a"
                :style="{ height: Math.max(t.appointments / maxVal * 100, 8) + '%' }"
              ></div>
              <!-- <div
                class="bar bar-p"
                :style="{ height: Math.max(t.posts / maxVal * 100, 8) + '%' }"
              ></div>
              <div
                class="bar bar-v"
                :style="{ height: Math.max(t.videos / maxVal * 100, 8) + '%' }"
              ></div> -->
            </div>
            <div class="bar-label">{{ t.date.slice(5) }}</div>
          </div>
        </div>
        <div class="legend">
          <span class="legend-item"><i class="dot dot-u"></i> {{ $t('新注册', 'New sign-ups') }}</span>
          <span class="legend-item"><i class="dot dot-a"></i> {{ $t('新预约', 'New bookings') }}</span>
          <!-- <span class="legend-item"><i class="dot dot-p"></i> 新作品</span>
          <span class="legend-item"><i class="dot dot-v"></i> 短视频</span> -->
        </div>
      </section>
    </template>
  </div>
</template>

<style scoped>
.dashboard { display: flex; flex-direction: column; gap: 20px; }
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.toolbar h2 { margin: 0; font-size: 19px; font-weight: 700; letter-spacing: 0.01em; color: var(--text); }

.state { text-align: center; padding: 40px; color: var(--text-muted); }
.error { color: var(--danger); }
.state.error { background: var(--danger-weak); border-radius: var(--radius-sm); }

/* 幽灵按钮：白底细边，hover 转浅灰底 */
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

/* 指标卡片 */
.cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 20px;
  box-shadow: var(--shadow-sm);
}
.card-label { font-size: 13px; color: var(--text-muted); margin-bottom: 8px; }
.card-value {
  font-size: 28px;
  font-weight: 700;
  color: var(--text);
  margin-bottom: 4px;
  letter-spacing: -0.01em;
  font-variant-numeric: tabular-nums;
}
.card-sub { font-size: 12px; color: var(--text-muted); }

/* 图表区块 */
.chart-section {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 20px;
  box-shadow: var(--shadow-sm);
}
.chart-section h3 {
  font-size: 15px;
  font-weight: 600;
  margin: 0 0 12px;
  color: var(--text);
}
.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
  font-variant-numeric: tabular-nums;
}
.table th, .table td {
  padding: 10px 8px;
  border-bottom: 1px solid var(--border);
  text-align: center;
}
.table th {
  background: var(--surface-muted);
  color: var(--text-muted);
  font-weight: 600;
  font-size: 12px;
  letter-spacing: 0.03em;
}
.table th:first-child { border-top-left-radius: var(--radius-sm); }
.table th:last-child { border-top-right-radius: var(--radius-sm); }
.table tbody tr { transition: background var(--duration) var(--ease); }
.table tbody tr:hover { background: var(--surface-muted); }
.table tbody tr:last-child td { border-bottom: none; }

/* 柱状图 */
.bar-chart {
  display: flex;
  align-items: flex-end;
  gap: 12px;
  height: 180px;
  padding: 16px 0;
}
.bar-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%;
  gap: 6px;
  border-radius: var(--radius-sm);
  transition: background var(--duration) var(--ease);
}
.bar-col:hover { background: var(--surface-muted); }
.bar-group {
  flex: 1;
  width: 100%;
  display: flex;
  align-items: flex-end;
  justify-content: center;
  gap: 3px;
}
.bar {
  width: 14px;
  border-radius: 4px 4px 0 0;
  min-height: 3px;
  transition: height 0.3s var(--ease);
}
.bar-u { background: var(--info); }
.bar-a { background: var(--primary); }
.bar-p { background: var(--success); }
.bar-label {
  font-size: 11px;
  color: var(--text-muted);
  margin-top: 4px;
}

.legend {
  display: flex;
  justify-content: center;
  gap: 20px;
  padding-top: 4px;
}
.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: var(--text-muted);
}
.dot {
  width: 10px;
  height: 10px;
  border-radius: 3px;
  display: inline-block;
}
.dot-u { background: var(--info); }
.dot-a { background: var(--primary); }
.dot-p { background: var(--success); }

/* 待办卡片（可点击，hover 轻微上浮） */
.todo-section h3 {
  font-size: 15px;
  font-weight: 600;
  margin: 0 0 12px;
  color: var(--text);
}
.todo-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.todo-card {
  display: flex;
  align-items: center;
  gap: 14px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px 20px;
  text-decoration: none;
  box-shadow: var(--shadow-sm);
  transition:
    transform var(--duration) var(--ease),
    box-shadow var(--duration) var(--ease),
    border-color var(--duration) var(--ease);
}
.todo-card:hover {
  transform: translateY(-1px);
  box-shadow: var(--shadow);
  border-color: var(--border-strong);
}
.todo-num {
  font-size: 26px;
  font-weight: 700;
  color: var(--primary);
  min-width: 40px;
  font-variant-numeric: tabular-nums;
}
.todo-label { font-size: 13px; color: var(--text-muted); }

.bar-v { background: var(--purple); }
.dot-v { background: var(--purple); }
</style>
