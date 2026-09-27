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
  serviceIcons,
  useToast,
} from './components';
import {
  beadPlans,
  brand,
  h5Tabs,
  mineMenu,
  reservationSteps,
  serviceGrid,
} from './data';
import { appointmentsApi, postsApi, storesApi } from './api';
import { useApi } from './hooks';
import { useAuth } from './auth';
import {
  addDays,
  appointmentStatusLabel,
  appointmentStatusTone,
  availabilityToSeats,
  formatDateTime,
  todayString,
} from './utils';
import type { Appointment } from './api/types';
import {
  ChevronRightIcon,
  HomeIcon,
  MineIcon,
  ScanIcon,
  SocialIcon,
} from './icons';

type Navigate = (page: string) => void;

const tabIcons: Record<string, (p: { size?: number }) => ReactNode> = {
  home: (p) => <HomeIcon {...p} />,
  social: (p) => <SocialIcon {...p} />,
  mine: (p) => <MineIcon {...p} />,
};

const FALLBACK_TIMES = ['10:00', '14:00', '19:00'];

function H5Top({ navigate }: { navigate: Navigate }) {
  return (
    <header className="h5-top">
      <div>
        <span>{brand.city}</span>
        <strong>{brand.store}</strong>
      </div>
      <a className="h5-user" onClick={() => navigate('mine')}>
        <MineIcon size={15} /> 我的
      </a>
    </header>
  );
}

function H5Title({ title, subtitle }: { title: string; subtitle: string }) {
  return (
    <section className="h5-title">
      <h1>{title}</h1>
      <p>{subtitle}</p>
    </section>
  );
}

function H5BottomNav({ active, navigate }: { active: string; navigate: Navigate }) {
  const homeActive = !['social', 'mine'].includes(active);
  return (
    <nav className="h5-bottom">
      {h5Tabs.map((t) => {
        const isActive = t.key === 'home' ? homeActive : active === t.key;
        return (
          <a
            key={t.key}
            className={isActive ? 'is-active' : ''}
            onClick={() => navigate(t.key)}
          >
            <span>{tabIcons[t.icon]({ size: 21 })}</span>
            <b>{t.label}</b>
          </a>
        );
      })}
    </nav>
  );
}

function PillTabs({
  items,
  active,
  onChange,
}: {
  items: string[];
  active: number;
  onChange: (i: number) => void;
}) {
  return (
    <div className="h5-tabs">
      {items.map((t, i) => (
        <button
          key={t}
          className={active === i ? 'is-active' : ''}
          onClick={() => onChange(i)}
        >
          {t}
        </button>
      ))}
    </div>
  );
}

function Actions({ children }: { children: ReactNode }) {
  return <div className="h5-actions">{children}</div>;
}

function Panel({
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
    <section className="panel-card section-gap">
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

function AppointmentRow({
  item,
  onAction,
}: {
  item: Appointment;
  onAction: (item: Appointment, action: string) => void;
}) {
  const canCancel = ['pending', 'booked'].includes(item.status);
  const canCheckIn = item.status === 'booked';
  const canClockOut = ['checked_in', 'in_service'].includes(item.status);
  return (
    <article>
      <Avatar>{item.storeName?.charAt(0) || '约'}</Avatar>
      <div>
        <strong>{item.storeName || '门店预约'}</strong>
        <span>
          {item.date} {item.startTime}-{item.endTime} · {item.peopleCount} 人
        </span>
        <span className="list-code">核销码 {item.code}</span>
      </div>
      <div className="row-side">
        <Badge tone={appointmentStatusTone[item.status] ?? 'butter'}>
          {appointmentStatusLabel[item.status] ?? item.status}
        </Badge>
        <div className="row-actions">
          {canCheckIn && (
            <a
              onClick={(e) => {
                e.stopPropagation();
                onAction(item, 'checkin');
              }}
            >
              核销
            </a>
          )}
          {canClockOut && (
            <a
              onClick={(e) => {
                e.stopPropagation();
                onAction(item, 'clockout');
              }}
            >
              下钟
            </a>
          )}
          {canCancel && (
            <a
              onClick={(e) => {
                e.stopPropagation();
                onAction(item, 'cancel');
              }}
            >
              取消
            </a>
          )}
        </div>
      </div>
    </article>
  );
}

/* ---------------- pages ---------------- */
function H5Home({ navigate }: { navigate: Navigate }) {
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
  const orders = useApi(() => appointmentsApi.myList(1, 1), []);

  const seats = useMemo(
    () => availabilityToSeats(avail.data ?? []),
    [avail.data],
  );
  const idleCount = seats.filter((s) => s.status === 'idle').length;
  const kpis = [
    { label: '门店数量', value: String(stores.data?.length ?? 0), tone: 'blue' },
    { label: '热门作品', value: String(hot.data?.length ?? 0), tone: 'mint' },
    { label: '空闲座位', value: String(idleCount), tone: 'peach' },
    { label: '我的订单', value: String(orders.data?.total ?? 0), tone: 'lilac' },
  ];

  return (
    <>
      <H5Title
        title="门店首页"
        subtitle="轮播图、功能宫格、座位状态、活动推荐和快捷订单入口。"
      />
      <section className="h5-carousel">
        <span>拼豆创作体验店</span>
        <strong>上传照片，自动生成拼豆方案</strong>
        <p>预约到店、核销计时、结束使用一站完成。</p>
      </section>

      <section className="h5-service-grid">
        {serviceGrid.map((s) => (
          <a key={s.key} onClick={() => navigate(s.route.replace('/h5/', ''))}>
            <b className="tone-blush">{serviceIcons[s.icon]({ size: 22 })}</b>
            <span>{s.label}</span>
          </a>
        ))}
      </section>

      <KpiGrid items={kpis} />

      <Panel
        title="座位状态"
        subtitle="空闲、已预约、使用中、异常一屏查看。"
        extra={<SeatLegend />}
      >
        <SeatGrid seats={seats} />
      </Panel>

      <Panel
        title="热门作品"
        extra={
          <a onClick={() => navigate('social')}>
            更多 <ChevronRightIcon size={14} />
          </a>
        }
      >
        {hot.loading ? (
          <div className="load-state">加载中…</div>
        ) : hot.error ? (
          <div className="error-state">{hot.error}</div>
        ) : (
          <FeedGrid posts={hot.data ?? []} />
        )}
      </Panel>

    </>
  );
}

function H5Bead({ navigate }: { navigate: Navigate }) {
  const toast = useToast();
  return (
    <>
      <H5Title
        title="智能拼豆版"
        subtitle="上传图片后生成拼豆方案、颜色编号、材料清单和制作入口。"
      />
      <Actions>
        <a className="btn btn-primary" onClick={() => toast('方案已保存')}>
          保存方案
        </a>
        <a className="btn" onClick={() => navigate('social')}>
          发布作品
        </a>
      </Actions>

      <section className="panel-card">
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
          <label>
            <span>豆子规格</span>
            <select defaultValue="5mm 标准豆">
              <option>5mm 标准豆</option>
              <option>2.6mm 迷你豆</option>
            </select>
          </label>
        </div>
        <div className="section-gap">
          <PixelBoard />
        </div>
        <div className="material-card section-gap">
          <h3>材料清单</h3>
          <MaterialPalette />
          {beadPlans.slice(0, 3).map((p) => (
            <article key={p.name}>
              <strong>{p.name}</strong>
              <span>{p.size}</span>
              <b>{p.beads}</b>
            </article>
          ))}
        </div>
      </section>

      <Panel title="我的方案" extra={<a onClick={() => toast('新建方案')}>新建</a>}>
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
      </Panel>
    </>
  );
}

function H5Reservation({ navigate }: { navigate: Navigate }) {
  const toast = useToast();
  const stores = useApi(() => storesApi.list(), []);
  const [storeId, setStoreId] = useState<number | null>(null);
  const [day, setDay] = useState(0);
  const [time, setTime] = useState(FALLBACK_TIMES[0]);
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
    : FALLBACK_TIMES;

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
      navigate('mine');
    } catch (e) {
      toast(e instanceof Error ? e.message : '创建失败');
    } finally {
      setCreating(false);
    }
  };

  return (
    <>
      <H5Title
        title="预约订座"
        subtitle="选择门店、日期、时间、人数和座位，支持支付预约和到店确认。"
      />
      <section className="booking-card">
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
            onChange={(e) => setPeople(Math.max(1, Number(e.target.value) || 1))}
          />
        </label>
        <div className="seat-picker section-gap">
          <span className="picker-label">选择座位</span>
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
        </div>
        <Actions>
          <a className="btn btn-primary" onClick={() => void submit()}>
            {creating ? '创建中…' : '创建预约'}
          </a>
          <a className="btn" onClick={() => navigate('seat')}>
            查看座位
          </a>
          <a className="btn" onClick={() => navigate('verify')}>
            一键核销
          </a>
        </Actions>
      </section>

      <Panel title="预约核销流程">
        <FlowSteps steps={reservationSteps} />
      </Panel>
    </>
  );
}

function H5Seat({ navigate }: { navigate: Navigate }) {
  const toast = useToast();
  const my = useApi(() => appointmentsApi.myList(1, 20), []);
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

  const act = async (item: Appointment, action: string) => {
    try {
      if (action === 'checkin') {
        await appointmentsApi.checkIn(item.code);
        toast('核销成功，已开始计时');
      } else if (action === 'clockout') {
        await appointmentsApi.clockOut(item.id);
        toast('已下钟，订单完成');
      } else if (action === 'cancel') {
        await appointmentsApi.cancel(item.id);
        toast('预约已取消');
      }
      my.reload();
    } catch (e) {
      toast(e instanceof Error ? e.message : '操作失败');
    }
  };

  const active = (my.data?.items ?? []).filter((a) =>
    ['pending', 'booked', 'checked_in', 'in_service'].includes(a.status),
  );

  return (
    <>
      <H5Title
        title="座位管理"
        subtitle="查看空闲座位、预约状态、使用计时和结束使用。"
      />
      {active[0] && (
        <section className="seat-timer-card">
          <span>当前预约</span>
          <strong>
            {active[0].tableName || active[0].storeName} ·{' '}
            {appointmentStatusLabel[active[0].status]}
          </strong>
          <p>
            {active[0].date} {active[0].startTime}-{active[0].endTime} · 核销码{' '}
            {active[0].code}
          </p>
          <Actions>
            <a
              className="btn btn-primary"
              onClick={() =>
                void act(
                  active[0],
                  active[0].status === 'booked' ? 'checkin' : 'clockout',
                )
              }
            >
              {active[0].status === 'booked' ? '核销上钟' : '结束使用'}
            </a>
            <a className="btn" onClick={() => navigate('verify')}>
              一键核销
            </a>
            <a className="btn" onClick={() => navigate('reservation')}>
              创建预约
            </a>
          </Actions>
        </section>
      )}

      <Panel
        title="座位状态"
        subtitle="空闲、已预约、使用中、异常一屏查看。"
        extra={<SeatLegend />}
      >
        <SeatGrid seats={seats} />
      </Panel>

    </>
  );
}

function H5Verify() {
  const toast = useToast();
  const [code, setCode] = useState('');
  const [preview, setPreview] = useState<Appointment | null>(null);
  const [busy, setBusy] = useState(false);

  const lookup = async () => {
    const c = code.trim().toUpperCase();
    if (!/^[A-Z0-9]{6}$/.test(c)) {
      toast('请输入 6 位核销码');
      return;
    }
    setBusy(true);
    try {
      const a = await appointmentsApi.findByCode(c);
      setPreview(a);
    } catch (e) {
      toast(e instanceof Error ? e.message : '查询失败');
    } finally {
      setBusy(false);
    }
  };

  const checkIn = async () => {
    if (!preview) return;
    setBusy(true);
    try {
      await appointmentsApi.checkIn(preview.code);
      toast('核销成功');
      setPreview(null);
      setCode('');
    } catch (e) {
      toast(e instanceof Error ? e.message : '核销失败');
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <H5Title
        title="一键核销"
        subtitle="支持抖音团购码、站内订单码、扫码核销和人工确认。"
      />
      <section className="panel-card">
        <div className="composer-card">
          <ScanIcon size={24} />
          <input
            value={code}
            onChange={(e) => setCode(e.target.value)}
            placeholder="输入 6 位预约核销码"
          />
        </div>
        <Actions>
          <a className="btn btn-primary" onClick={() => void lookup()}>
            查询核销码
          </a>
          <a className="btn" onClick={() => toast('请扫描二维码')}>
            抖音核销
          </a>
        </Actions>
        {preview && (
          <div className="verify-preview">
            <div>
              <strong>{preview.storeName}</strong>
              <span>
                {preview.date} {preview.startTime}-{preview.endTime} ·{' '}
                {preview.peopleCount} 人
              </span>
              <b>{appointmentStatusLabel[preview.status] ?? preview.status}</b>
            </div>
            <a className="btn btn-primary" onClick={() => void checkIn()}>
              {busy ? '处理中…' : '确认核销'}
            </a>
          </div>
        )}
      </section>

      <Panel title="预约核销流程">
        <FlowSteps steps={reservationSteps} />
      </Panel>
    </>
  );
}

function H5Social() {
  const [tab, setTab] = useState(0);
  const [publish, setPublish] = useState(false);
  const feed = useApi(() => {
    if (tab === 3) return postsApi.hot(1).then(([items]) => items);
    return postsApi.latest(1).then(([items]) => items);
  }, [tab]);

  return (
    <>
      <H5Title
        title="社交服务"
        subtitle="独立朋友圈，支持作品发布、点赞、评论、收藏、举报和删除不良评论。"
      />
      <section className="composer-card">
        <Avatar>拼</Avatar>
        <a onClick={() => setPublish(true)}>分享今天完成的拼豆作品...</a>
      </section>
      <PillTabs
        items={['推荐', '关注', '附近', '热门']}
        active={tab}
        onChange={setTab}
      />
      <Actions>
        <a className="btn btn-primary" onClick={() => setPublish(true)}>
          发布作品
        </a>
      </Actions>
      {feed.loading ? (
        <div className="load-state">加载中…</div>
      ) : feed.error ? (
        <div className="error-state">{feed.error}</div>
      ) : (
        <FeedGrid posts={feed.data ?? []} />
      )}
      {publish && (
        <PublishPostModal
          onClose={() => setPublish(false)}
          onPublished={() => feed.reload()}
        />
      )}
    </>
  );
}

function H5Mine() {
  const { me, logout } = useAuth();
  const orders = useApi(() => appointmentsApi.myList(1, 20), []);
  const [selected, setSelected] = useState<Appointment | null>(null);
  const toast = useToast();

  const act = async (item: Appointment, action: string) => {
    try {
      if (action === 'checkin') {
        await appointmentsApi.checkIn(item.code);
        toast('核销成功');
      } else if (action === 'clockout') {
        await appointmentsApi.clockOut(item.id);
        toast('已下钟');
      } else if (action === 'cancel') {
        await appointmentsApi.cancel(item.id);
        toast('已取消');
      }
      orders.reload();
    } catch (e) {
      toast(e instanceof Error ? e.message : '操作失败');
    }
  };

  return (
    <>
      <H5Title
        title="我的中心"
        subtitle="实名认证、安全设置、我的发布、订单和退出登录。"
      />
      <section className="profile-card">
        <Avatar size="lg">{me?.nickname?.charAt(0) || '拼'}</Avatar>
        <div>
          <strong>{me?.nickname || me?.username || '拼豆会员'}</strong>
          <span>
            {me?.email
              ? `邮箱 ${me.email}`
              : '已实名认证'}
          </span>
        </div>
      </section>
      <div className="wallet-grid">
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
      <section className="menu-list">
        {mineMenu.map((m) => (
          <a key={m} onClick={() => (m === '退出登录' ? logout() : toast(m))}>
            {m}
            <ChevronRightIcon size={16} className="chev" />
          </a>
        ))}
      </section>
      <Panel title="我的订单">
        {orders.loading ? (
          <div className="load-state">加载中…</div>
        ) : (orders.data?.items ?? []).length ? (
          <div className="list">
            {orders.data!.items.map((o) => (
              <div key={o.id} onClick={() => setSelected(o)}>
                <AppointmentRow item={o} onAction={act} />
              </div>
            ))}
          </div>
        ) : (
          <div className="empty-state">还没有预约订单</div>
        )}
      </Panel>
      {selected && (
        <div className="modal-backdrop" onClick={() => setSelected(null)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-head">
              <strong>订单详情</strong>
              <button onClick={() => setSelected(null)}>关闭</button>
            </div>
            <div className="order-detail">
              <p>
                <span>订单号</span>
                <b>PD{String(selected.id).padStart(6, '0')}</b>
              </p>
              <p>
                <span>门店</span>
                <b>{selected.storeName || '—'}</b>
              </p>
              <p>
                <span>时间</span>
                <b>
                  {selected.date} {selected.startTime}-{selected.endTime}
                </b>
              </p>
              <p>
                <span>金额</span>
                <b>￥{selected.amount?.toFixed(2)}</b>
              </p>
              <p>
                <span>核销码</span>
                <b>{selected.code}</b>
              </p>
              <p>
                <span>创建时间</span>
                <b>{formatDateTime(selected.createdAt)}</b>
              </p>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

const h5Pages: Record<string, (p: { navigate: Navigate }) => ReactNode> = {
  home: H5Home,
  bead: H5Bead,
  reservation: H5Reservation,
  seat: H5Seat,
  verify: H5Verify,
  social: H5Social,
  mine: H5Mine,
};

export function H5App({ page, navigate }: { page: string; navigate: Navigate }) {
  const Page = h5Pages[page] ?? H5Home;
  return (
    <div className="h5-runtime">
      <div className="h5-phone">
        <H5Top navigate={navigate} />
        <div className="h5-scroll">
          <Page navigate={navigate} />
        </div>
        <H5BottomNav active={page} navigate={navigate} />
      </div>
    </div>
  );
}
