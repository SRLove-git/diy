import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
  Fragment,
  type CSSProperties,
  type ReactNode,
} from 'react';
import {
  ArrowIcon,
  BeadIcon,
  CheckIcon,
  ClockIcon,
  CommentIcon,
  HeartIcon,
  SeatIcon,
  StarIcon,
} from './icons';
import {
  materialPalette,
  pixelBoard,
  seatMeta,
} from './data';
import { postsApi } from './api';
import type { Comment, Post } from './api/types';
import { formatDateTime } from './utils';

/* ---------------- toast ---------------- */
const ToastContext = createContext<(msg: string) => void>(() => {});

export function useToast() {
  return useContext(ToastContext);
}

export function ToastProvider({ children }: { children: ReactNode }) {
  const [message, setMessage] = useState('');
  const [visible, setVisible] = useState(false);
  const timer = useRef<number>();

  const show = useCallback((msg: string) => {
    setMessage(msg);
    setVisible(true);
    window.clearTimeout(timer.current);
    timer.current = window.setTimeout(() => setVisible(false), 1800);
  }, []);

  return (
    <ToastContext.Provider value={show}>
      {children}
      <div className={`toast ${visible ? 'is-visible' : ''}`} role="status">
        {message}
      </div>
    </ToastContext.Provider>
  );
}

/* ---------------- small atoms ---------------- */
export function Chip({ children }: { children: ReactNode }) {
  return <span className="chip">{children}</span>;
}

export function Badge({
  children,
  tone = 'blush',
}: {
  children: ReactNode;
  tone?: string;
}) {
  return <em className={`badge tone-${tone}`}>{children}</em>;
}

export function Avatar({ children, size }: { children: ReactNode; size?: 'lg' }) {
  return <span className={`avatar ${size === 'lg' ? 'is-lg' : ''}`}>{children}</span>;
}

export const serviceIcons: Record<string, (p: { size?: number }) => ReactNode> = {
  bead: (p) => <BeadIcon {...p} />,
  clock: (p) => <ClockIcon {...p} />,
  check: (p) => <CheckIcon {...p} />,
  seat: (p) => <SeatIcon {...p} />,
};

/* ---------------- KPI ---------------- */
export function KpiGrid({
  items,
}: {
  items: { label: string; value: string; tone: string }[];
}) {
  return (
    <div className="kpi-grid">
      {items.map((k) => (
        <article className={`kpi-card tone-${k.tone}`} key={k.label}>
          <span>{k.label}</span>
          <strong>{k.value}</strong>
        </article>
      ))}
    </div>
  );
}

export type SeatStatus = 'idle' | 'reserved' | 'using' | 'abnormal';

export interface SeatCell {
  id: string;
  status: SeatStatus;
}

export function SeatGrid({
  seats,
  onSelect,
}: {
  seats?: SeatCell[];
  onSelect?: (id: string) => void;
}) {
  const toast = useToast();
  const cells = seats ?? [];
  if (!cells.length) {
    return <div className="empty-state">暂无座位数据</div>;
  }
  return (
    <div className="seat-grid">
      {cells.map((s) => {
        const meta = seatMeta[s.status];
        return (
          <button
            className={`seat ${s.status}`}
            key={s.id}
            onClick={() => {
              if (onSelect) onSelect(s.id);
              else toast(`${s.id} · ${meta.label}`);
            }}
          >
            <strong>{s.id}</strong>
            <span>{meta.label}</span>
          </button>
        );
      })}
    </div>
  );
}

export function SeatLegend() {
  return (
    <div className="seat-legend">
      <span className="idle">空闲</span>
      <span className="reserved">已预约</span>
      <span className="using">使用中</span>
      <span className="abnormal">异常</span>
    </div>
  );
}

/* ---------------- feed ---------------- */
function avatarChar(name: string | undefined): string {
  return name?.charAt(0) || '拼';
}

function coverOf(post: Post): string | null {
  if (post.images?.length) return post.images[0];
  if (post.medias?.length) {
    const first =
      post.medias.find((m) => m.type === 'image') ?? post.medias[0];
    return first.url;
  }
  return null;
}

export function FeedCard({ post }: { post: Post }) {
  const toast = useToast();
  const [likeCount, setLikeCount] = useState(post.likeCount);
  const [collectCount, setCollectCount] = useState(post.collectCount);
  const [commentCount, setCommentCount] = useState(post.commentCount);
  const [liked, setLiked] = useState(false);
  const [collected, setCollected] = useState(false);
  const [busy, setBusy] = useState<'like' | 'collect' | null>(null);
  const [showComments, setShowComments] = useState(false);
  const cover = coverOf(post);

  const onLike = async () => {
    if (busy) return;
    setBusy('like');
    try {
      const res = await postsApi.like(post.id);
      setLiked(res.liked);
      setLikeCount((c) => Math.max(0, c + (res.liked ? 1 : -1)));
    } catch (e) {
      toast(e instanceof Error ? e.message : '操作失败');
    } finally {
      setBusy(null);
    }
  };

  const onCollect = async () => {
    if (busy) return;
    setBusy('collect');
    try {
      const res = await postsApi.collect(post.id);
      setCollected(res.collected);
      setCollectCount((c) => Math.max(0, c + (res.collected ? 1 : -1)));
    } catch (e) {
      toast(e instanceof Error ? e.message : '操作失败');
    } finally {
      setBusy(null);
    }
  };

  return (
    <>
      <article className="feed-card">
        <div className="feed-author">
          <Avatar>{avatarChar(post.author?.nickname)}</Avatar>
          <div>
            <strong>{post.author?.nickname ?? `用户 #${post.userId}`}</strong>
            <small>{formatDateTime(post.createdAt)}</small>
          </div>
        </div>
        <p>{post.content}</p>
        {cover ? (
          <img className="feed-cover" src={cover} alt="" loading="lazy" />
        ) : (
          <div className="visual-cover" />
        )}
        <div className="feed-actions">
          <button className={liked ? 'is-active' : ''} onClick={onLike}>
            <HeartIcon size={15} /> 点赞 {likeCount}
          </button>
          <button onClick={() => setShowComments(true)}>
            <CommentIcon size={15} /> 评论 {commentCount}
          </button>
          <button className={collected ? 'is-active' : ''} onClick={onCollect}>
            <StarIcon size={15} /> 收藏 {collectCount}
          </button>
        </div>
      </article>
      {showComments && (
        <PostComments
          postId={post.id}
          onClose={() => setShowComments(false)}
          onAdded={() => setCommentCount((c) => c + 1)}
        />
      )}
    </>
  );
}

export function FeedGrid({ posts }: { posts: Post[] }) {
  if (!posts.length) return <div className="empty-state">还没有作品</div>;
  return (
    <div className="feed-grid">
      {posts.map((p) => (
        <FeedCard key={p.id} post={p} />
      ))}
    </div>
  );
}

function PostComments({
  postId,
  onClose,
  onAdded,
}: {
  postId: number;
  onClose: () => void;
  onAdded: () => void;
}) {
  const toast = useToast();
  const [comments, setComments] = useState<Comment[]>([]);
  const [loading, setLoading] = useState(true);
  const [text, setText] = useState('');
  const [sending, setSending] = useState(false);

  useEffect(() => {
    let active = true;
    postsApi
      .comments(postId)
      .then(([items]) => {
        if (active) setComments(items);
      })
      .catch(() => undefined)
      .finally(() => {
        if (active) setLoading(false);
      });
    return () => {
      active = false;
    };
  }, [postId]);

  const submit = async () => {
    const content = text.trim();
    if (!content || sending) return;
    setSending(true);
    try {
      const c = await postsApi.addComment(postId, content);
      setComments((prev) => [c, ...prev]);
      setText('');
      onAdded();
    } catch (e) {
      toast(e instanceof Error ? e.message : '评论失败');
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <div className="modal-head">
          <strong>评论</strong>
          <button onClick={onClose}>关闭</button>
        </div>
        <div className="comment-list">
          {loading ? (
            <div className="load-state">加载中…</div>
          ) : comments.length ? (
            comments.map((c) => (
              <article className="comment-item" key={c.id}>
                <Avatar>{avatarChar(c.author?.nickname)}</Avatar>
                <div>
                  <strong>{c.author?.nickname ?? `用户 #${c.userId}`}</strong>
                  <p>{c.content}</p>
                </div>
              </article>
            ))
          ) : (
            <div className="empty-state">还没有评论，来抢沙发</div>
          )}
        </div>
        <div className="comment-input">
          <input
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter') void submit();
            }}
            placeholder="写下你的评论…"
          />
          <button
            className="btn btn-primary btn-sm"
            onClick={() => void submit()}
            disabled={sending}
          >
            发送
          </button>
        </div>
      </div>
    </div>
  );
}

export function PublishPostModal({
  onClose,
  onPublished,
}: {
  onClose: () => void;
  onPublished: (post: Post) => void;
}) {
  const toast = useToast();
  const [content, setContent] = useState('');
  const [title, setTitle] = useState('');
  const [sending, setSending] = useState(false);

  const submit = async () => {
    if (!content.trim() || sending) return;
    setSending(true);
    try {
      const post = await postsApi.create({ content: content.trim(), title: title.trim() });
      onPublished(post);
      onClose();
    } catch (e) {
      toast(e instanceof Error ? e.message : '发布失败');
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <div className="modal-head">
          <strong>发布作品</strong>
          <button onClick={onClose}>关闭</button>
        </div>
        <div className="publish-body">
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="标题（可选）"
          />
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="分享你的拼豆作品…"
            rows={5}
          />
        </div>
        <div className="comment-input">
          <button
            className="btn btn-primary"
            onClick={() => void submit()}
            disabled={sending || !content.trim()}
          >
            {sending ? '发布中…' : '发布'}
          </button>
        </div>
      </div>
    </div>
  );
}

/* ---------------- pixel board ---------------- */
export function PixelBoard() {
  return (
    <div className="pixel-board">
      {pixelBoard.map((c, i) => (
        <i key={i} style={{ '--c': c } as CSSProperties} />
      ))}
    </div>
  );
}

export function MaterialPalette() {
  return (
    <div className="color-palette">
      {materialPalette.map((m) => (
        <span key={m.code} style={{ '--c': m.color } as CSSProperties}>
          {m.code} {m.name}
        </span>
      ))}
    </div>
  );
}

/* ---------------- flow steps ---------------- */
export function FlowSteps({ steps }: { steps: string[] }) {
  return (
    <div className="flow-steps">
      {steps.map((s, i) => (
        <Fragment key={s}>
          {i > 0 && <i />}
          <span>{s}</span>
        </Fragment>
      ))}
    </div>
  );
}

/* ---------------- misc ---------------- */
export function LinkArrow({ children }: { children: ReactNode }) {
  return (
    <span className="link">
      {children}
      <ArrowIcon size={14} />
    </span>
  );
}
