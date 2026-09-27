import { useMemo, useState, type ReactNode } from 'react';
import {
  Avatar,
  Badge,
  FeedGrid,
  FlowSteps,
  KpiGrid,
  MaterialPalette,
  PixelBoard,
  PublishPostModal,
  SeatGrid,
  SeatLegend,
  useToast,
} from './components';
import {
  beadPlans,
  brand,
  mineMenu,
  pcNav,
  reservationSteps,
} from './data';
import { appointmentsApi, postsApi, storesApi } from './api';
import { useApi } from './hooks';
import { useAuth } from './auth';
import {
  addDays,
  appointmentStatusLabel,
  appointmentStatusTone,
  availabilityToSeats,
  todayString,
} from './utils';
import { ChevronRightIcon } from './icons';

type Navigate = (page: string) => void;

function PCShell({
  page,
  navigate,
  children,
}: {
  page: string;
  navigate: Navigate;
  children: ReactNode;
}) {
  const { me } = useAuth();
  return (
    <div className="pc-runtime">
      <header className="pc-nav">
        <div className="pc-nav-inner">
          <a className="pc-logo" onClick={() => navigate('home')}>
            <span className="mark">拼</span>
            {brand.name}
          </a>
          <nav>
            {pcNav.map((n) => (
              <a
                key={n.key}
                className={page === n.key ? 'is-active' : ''}
                onClick={() => navigate(n.key)}
              >
                {n.label}
              </a>
            ))}
          </nav>
          <a className="pc-nav-user" onClick={() => navigate('account')}>
            已登录 · {me?.nickname || me?.username || '已实名'}
          </a>
        </div>
      </header>
      <main className="pc-main">{children}</main>
    </div>
  );
}

function PageTitle({
  title,
  subtitle,
  actions,
}: {
  title: string;
  subtitle: string;
  actions?: ReactNode;
}) {
  return (
    <section className="pc-page-title">
      <div>
        <h1>{title}</h1>
        <p>{subtitle}</p>
      </div>
      {actions && <div className="actions">{actions}</div>}
    </section>
  );
}

function PCPanel({
  title,
  subtitle,
  extra,
  children,
}: {
  title: string;
  subtitle?: string;
  extra?: ReactNode;
  children: ReactNode;
}) {
  return (
    <section className="panel-card">
      <div className="panel-head">
        <div>
          <h2>{title}</h2>
          {subtitle && <p>{subtitle}</p>}
        </div>
        {extra}
      </div>
      {children}
    </section>
  );
}

function PCPillTabs({
  items,
  active,
  onChange,
}: {
  items: string[];
  active?: number;
  onChange?: (i: number) => void;
}) {
  const [inner, setInner] = useState(0);
  const current = active ?? inner;
  const set = onChange ?? setInner;
  return (
    <div className="h5-tabs">
      {items.map((t, i) => (
        <button
          key={t}
          className={current === i ? 'is-active' : ''}
          onClick={() => set(i)}
        >
          {t}
        </button>
      ))}
    </div>
  );
}

/* ---------------- pages ---------------- */
function PCHome({ navigate }: { navigate: Navigate }) {
  const hot = useApi(() => postsApi.hot(1).then(([items]) => items), []);
  const stores = useApi(() => storesApi.list(), []);
  const storeId = stores.data?.[0]?.id;
  const avail = useApi(
    () =>
      storeId
        ? appointmentsApi.availability(storeId, todayString())
        : Promise.resolve([]),
    [storeId],
  );
  const seats = useMemo(
    () => availabilityToSeats(avail.data ?? []),
    [avail.data],
  );
  const idle = seats.filter((s) => s.status === 'idle').length;
  const kpis = [
    { label: '大屏主视觉', value: '1', tone: 'blue' },
    { label: '热门作品', value: String(hot.data?.length ?? 0), tone: 'mint' },
    { label: '空闲座位', value: String(idle), tone: 'peach' },
    { label: '预约订单', value: '—', tone: 'lilac' },
  ];

  return (
    <>
      <section className="pc-hero">
        <div>
          <span className="eyebrow">拼豆创作 · 预约体验 · 社交社区</span>
          <h1>把照片变成拼豆作品</h1>
          <p>PC 前台适合大屏浏览作品、预约座位、查看社交和管理自己的订单。</p>
          <div className="ui-actions">
            <a className="is-primary" onClick={() => navigate('bead')}>
              智能生成
            </a>
            <a onClick={() => navigate('reservation')}>预约订座</a>
          </div>
        </div>
        <aside>
          <strong>账户状态</strong>
          <span>已登录 · 已实名认证</span>
          <b>预约订单可在线核销</b>
          <small>订单、消息和预约统一管理</small>
        </aside>
      </section>

      <div className="section-gap">
        <KpiGrid items={kpis} />
      </div>

      <div className="pc-two-col">
        <PCPanel
          title="座位状态"
          subtitle="空闲、已预约、使用中、异常一屏查看。"
          extra={<SeatLegend />}
        >
          <SeatGrid seats={seats} />
        </PCPanel>
        <PCPanel
          title="热门拼豆作品"
          extra={<a onClick={() => navigate('social')}>查看</a>}
        >
          {hot.loading ? (
            <div className="load-state">加载中…</div>
          ) : (
            <FeedGrid posts={(hot.data ?? []).slice(0, 2)} />
          )}
        </PCPanel>
      </div>

    </>
  );
}

function PCBead({ navigate }: { navigate: Navigate }) {
  const toast = useToast();
  return (
    <>
      <PageTitle
        title="PC 智能拼豆"
        subtitle="大屏上传、参数调整、分区预览和材料清单。"
        actions={
          <>
            <a className="btn btn-primary" onClick={() => toast('新增方案')}>
              新增方案
            </a>
            <a className="btn" onClick={() => navigate('social')}>
              发布作品
            </a>
          </>
        }
      />
      <KpiGrid
        items={[
          { label: '拼豆方案', value: String(beadPlans.length), tone: 'mint' },
          { label: '材料颜色', value: '5', tone: 'peach' },
          { label: '像素格', value: '256', tone: 'blue' },
        ]}
      />

      <div className="bead-studio section-gap">
        <PCPanel title="参数">
          <label className="upload-drop">
            <input type="file" accept="image/*" />
            <strong>上传图片</strong>
            <span>拍照、相册、拖拽上传</span>
          </label>
          <div className="bead-controls section-gap">
            <label>
              <span>尺寸</span>
              <select defaultValue="48cm x 48cm">
                <option>48cm x 48cm</option>
                <option>60cm x 40cm</option>
                <option>自定义尺寸</option>
              </select>
            </label>
            <label>
              <span>颜色数量</span>
              <input type="range" min={4} max={24} defaultValue={12} />
            </label>
          </div>
        </PCPanel>

        <PCPanel title="拼豆预览">
          <PixelBoard />
        </PCPanel>

        <PCPanel title="材料清单">
          <MaterialPalette />
          {beadPlans.slice(0, 3).map((p) => (
            <article className="material-row" key={p.name}>
              <strong>{p.name}</strong>
              <span>{p.size}</span>
              <b>{p.beads}</b>
            </article>
          ))}
        </PCPanel>
      </div>

      <div className="section-gap">
        <PCPanel title="方案记录">
          <div className="list">
            {beadPlans.map((p) => (
              <article key={p.name}>
                <Avatar>{p.avatar}</Avatar>
                <div>
                  <strong>{p.name}</strong>
                  <span>已生成</span>
                </div>
                <Badge tone="mint">已生成</Badge>
              </article>
            ))}
          </div>
        </PCPanel>
      </div>
    </>
  );
}

function PCReservation({ navigate }: { navigate: Navigate }) {
  const toast = useToast();
  const stores = useApi(() => storesApi.list(), []);
  const [storeId, setStoreId] = useState<number | null>(null);
  const [day, setDay] = useState(0);
  const [time, setTime] = useState('10:00');
  const [people, setPeople] = useState(1);
  const [tableId, setTableId] = useState<number | null>(null);
  const [creating, setCreating] = useState(false);

  const date = addDays(todayString(), day);
  const effectiveStoreId = storeId ?? stores.data?.[0]?.id ?? null;
  const store = useApi(
    () =>
      effectiveStoreId
        ? storesApi.detail(effectiveStoreId)
        : Promise.resolve(null),
    [effectiveStoreId],
  );
  const avail = useApi(
    () =>
      effectiveStoreId
        ? appointmentsApi.availability(effectiveStoreId, date)
        : Promise.resolve([]),
    [effectiveStoreId, date],
  );

  const times = store.data?.slots?.length
    ? store.data.slots.map((s) => s.startTime)
    : ['10:00', '14:00', '19:00'];

  const submit = async () => {
    if (!effectiveStoreId || !tableId) {
      toast('请选择门店和座位');
      return;
    }
    setCreating(true);
    try {
      await appointmentsApi.create({
        type: 'store',
        storeId: effectiveStoreId,
        tableId,
        date,
        startTime: time,
        bookingType: 'hourly',
        durationHours: 1,
        peopleCount: people,
        payMethod: 'wechat',
      });
      toast('预约已创建');
      navigate('account');
    } catch (e) {
      toast(e instanceof Error ? e.message : '创建失败');
    } finally {
      setCreating(false);
    }
  };

  return (
    <>
      <PageTitle
        title="PC 预约订座"
        subtitle="门店筛选、日期筛选、座位平面图和支付核销。"
        actions={
          <a className="btn btn-primary" onClick={() => void submit()}>
            {creating ? '创建中…' : '新建预约'}
          </a>
        }
      />

      <div className="pc-two-col section-gap">
        <PCPanel title="预约信息">
          <div className="booking-card">
            <label className="field">
              <span>门店</span>
              <select
                value={effectiveStoreId ?? ''}
                onChange={(e) => setStoreId(Number(e.target.value) || null)}
              >
                <option value="">请选择门店</option>
                {(stores.data ?? []).map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
              </select>
            </label>
            <div className="booking-row">
              {['今天', '明天', '后天'].map((d, i) => (
                <button
                  key={d}
                  className={day === i ? 'is-active' : ''}
                  onClick={() => {
                    setDay(i);
                    setTableId(null);
                  }}
                >
                  {d}
                </button>
              ))}
            </div>
            <div className="booking-row">
              {times.map((t) => (
                <button
                  key={t}
                  className={time === t ? 'is-active' : ''}
                  onClick={() => setTime(t)}
                >
                  {t}
                </button>
              ))}
            </div>
            <label className="field">
              <span>人数</span>
              <input
                type="number"
                min={1}
                value={people}
                onChange={(e) =>
                  setPeople(Math.max(1, Number(e.target.value) || 1))
                }
              />
            </label>
          </div>
        </PCPanel>
        <PCPanel title="选择座位">
          {(avail.data ?? []).length ? (
            <div className="seat-grid">
              {(avail.data ?? []).map((t) => {
                const occupied = t.bookedWindows.length > 0;
                return (
                  <button
                    key={t.id}
                    className={`seat ${tableId === t.id ? 'is-picked' : ''} ${
                      occupied ? 'reserved' : 'idle'
                    }`}
                    disabled={occupied}
                    onClick={() => setTableId(t.id)}
                  >
                    <strong>{t.name}</strong>
                    <span>{occupied ? '已占用' : `${t.capacity} 人桌`}</span>
                  </button>
                );
              })}
            </div>
          ) : (
            <div className="empty-state">暂无可用座位</div>
          )}
        </PCPanel>
      </div>

      <div className="section-gap">
        <PCPanel title="预约核销流程">
          <FlowSteps steps={reservationSteps} />
        </PCPanel>
      </div>
    </>
  );
}

function PCSocial() {
  const [tab, setTab] = useState(0);
  const [publish, setPublish] = useState(false);
  const feed = useApi(() => {
    if (tab === 3) return postsApi.hot(1).then(([items]) => items);
    return postsApi.latest(1).then(([items]) => items);
  }, [tab]);

  return (
    <>
      <PageTitle
        title="PC 社交作品"
        subtitle="瀑布流作品、详情评论、关注收藏和举报。"
        actions={
          <a className="btn btn-primary" onClick={() => setPublish(true)}>
            发布作品
          </a>
        }
      />
      <PCPillTabs
        items={['推荐', '关注', '附近', '热门']}
        active={tab}
        onChange={setTab}
      />
      <div className="section-gap">
        {feed.loading ? (
          <div className="load-state">加载中…</div>
        ) : feed.error ? (
          <div className="error-state">{feed.error}</div>
        ) : (
          <FeedGrid posts={feed.data ?? []} />
        )}
      </div>
      {publish && (
        <PublishPostModal
          onClose={() => setPublish(false)}
          onPublished={() => feed.reload()}
        />
      )}
    </>
  );
}

function PCAccount() {
  const { me, logout } = useAuth();
  const toast = useToast();
  const orders = useApi(() => appointmentsApi.myList(1, 20), []);

  const act = async (id: number, code: string, action: string) => {
    try {
      if (action === 'checkin') await appointmentsApi.checkIn(code);
      else if (action === 'clockout') await appointmentsApi.clockOut(id);
      else if (action === 'cancel') await appointmentsApi.cancel(id);
      toast('操作成功');
      orders.reload();
    } catch (e) {
      toast(e instanceof Error ? e.message : '操作失败');
    }
  };

  return (
    <>
      <PageTitle
        title="PC 我的账户"
        subtitle="订单、消息、实名认证和售后。"
        actions={
          <a className="btn btn-primary" onClick={() => logout()}>
            退出登录
          </a>
        }
      />

      <div className="pc-two-col section-gap">
        <div>
          <section className="profile-card">
            <Avatar size="lg">{me?.nickname?.charAt(0) || '拼'}</Avatar>
            <div>
              <strong>{me?.nickname || me?.username || '拼豆会员'}</strong>
              <span>{me?.email || '已实名认证'}</span>
            </div>
          </section>
          <div className="wallet-grid section-gap">
            <article>
              <span>账号</span>
              <strong>{me?.username ?? '—'}</strong>
            </article>
            <article>
              <span>预约订单</span>
              <strong>{orders.data?.total ?? 0}</strong>
            </article>
            <article>
              <span>状态</span>
              <strong>{me?.isBanned ? '已封禁' : '正常'}</strong>
            </article>
          </div>
        </div>

        <PCPanel title="账户功能">
          <div className="menu-list">
            {mineMenu.map((m) => (
              <a key={m} onClick={() => (m === '退出登录' ? logout() : toast(m))}>
                {m}
                <ChevronRightIcon size={16} className="chev" />
              </a>
            ))}
          </div>
        </PCPanel>
      </div>

      <div className="section-gap">
        <PCPanel title="订单记录">
          {orders.loading ? (
            <div className="load-state">加载中…</div>
          ) : (orders.data?.items ?? []).length ? (
            <div className="list">
              {orders.data!.items.map((o) => (
                <article key={o.id}>
                  <Avatar>{o.storeName?.charAt(0) || '约'}</Avatar>
                  <div>
                    <strong>{o.storeName || '门店预约'}</strong>
                    <span>
                      {o.date} {o.startTime}-{o.endTime} · {o.peopleCount} 人
                    </span>
                  </div>
                  <Badge tone={appointmentStatusTone[o.status] ?? 'butter'}>
                    {appointmentStatusLabel[o.status] ?? o.status}
                  </Badge>
                  <div className="row-actions">
                    {o.status === 'booked' && (
                      <a onClick={() => void act(o.id, o.code, 'checkin')}>核销</a>
                    )}
                    {['checked_in', 'in_service'].includes(o.status) && (
                      <a onClick={() => void act(o.id, o.code, 'clockout')}>下钟</a>
                    )}
                    {['pending', 'booked'].includes(o.status) && (
                      <a onClick={() => void act(o.id, o.code, 'cancel')}>取消</a>
                    )}
                  </div>
                </article>
              ))}
            </div>
          ) : (
            <div className="empty-state">还没有预约订单</div>
          )}
        </PCPanel>
      </div>
    </>
  );
}

const pcPages: Record<string, (p: { navigate: Navigate }) => ReactNode> = {
  home: PCHome,
  bead: PCBead,
  reservation: PCReservation,
  social: PCSocial,
  account: PCAccount,
};

export function PCApp({ page, navigate }: { page: string; navigate: Navigate }) {
  const Page = pcPages[page] ?? PCHome;
  return (
    <PCShell page={page} navigate={navigate}>
      <Page navigate={navigate} />
    </PCShell>
  );
}
