import { HttpException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  WebSocketGateway,
} from '@nestjs/websockets';
import { decode, encode } from '@msgpack/msgpack';
import type { IncomingMessage } from 'http';
import { WebSocket } from 'ws';
import type { JwtPayload } from '../auth/auth.service';
import { ChatService } from './chat.service';
import type { Message } from './message.entity';

interface ChatFrame {
  type?: string;
  [key: string]: unknown;
}

/**
 * 用户间聊天 WebSocket 网关。
 *
 * 连接：ws(s)://<host>/ws?token=<accessToken>，握手时用 JWT_SECRET 校验。
 * 帧协议（JSON 文本帧）：
 *   客户端 → { type:'ping' } / { type:'send', conversationId, clientMsgId, content } / { type:'read', conversationId }
 *   服务端 → { type:'pong' } / { type:'sent', clientMsgId, message } / { type:'newMessage', message }
 *            / { type:'read', conversationId, readerId, readAt } / { type:'error', code, message }
 */
@WebSocketGateway({ path: '/ws' })
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  /** 在线连接表：userId -> 该用户的全部连接（支持多设备） */
  private readonly clients = new Map<number, Set<WebSocket>>();

  constructor(
    private readonly chat: ChatService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  handleConnection(client: WebSocket, request?: IncomingMessage): void {
    let userId: number;
    try {
      // 服务端 ws 实例的 client.url 为 undefined，需从握手请求中取 query
      const token = new URL(
        request?.url ?? '',
        'ws://localhost',
      ).searchParams.get('token');
      if (!token) throw new Error('缺少 token');
      const payload = this.jwt.verify<JwtPayload>(token, {
        secret: this.config.get<string>('JWT_SECRET'),
      });
      if (payload.type !== 'access' || !payload.sub)
        throw new Error('token 类型错误');
      userId = payload.sub;
    } catch {
      client.close(4001, 'unauthorized');
      return;
    }

    let set = this.clients.get(userId);
    if (!set) {
      set = new Set();
      this.clients.set(userId, set);
    }
    set.add(client);

    // 禁用 Nagle 算法：聊天帧都是小数据包，应立即发送不做合并缓冲
    const sock = (client as any)._socket;
    if (sock && typeof sock.setNoDelay === 'function') {
      sock.setNoDelay(true);
    }

    // 手动挂消息监听：ws adapter 的 @SubscribeMessage 回调拿不到 client，无法定向回复
    client.on('message', (buffer: Buffer) =>
      this.handleFrame(userId, client, buffer),
    );
    client.on('error', () => {
      /* 避免未捕获错误告警 */
    });
  }

  handleDisconnect(client: WebSocket): void {
    for (const [uid, set] of this.clients) {
      if (set.delete(client) && set.size === 0) {
        this.clients.delete(uid);
      }
    }
  }

  private handleFrame(userId: number, client: WebSocket, buffer: Buffer): void {
    let frame: ChatFrame;
    try {
      frame = decode(buffer) as ChatFrame;
    } catch {
      return;
    }
    switch (frame?.type) {
      case 'ping':
        this.reply(client, { type: 'pong' });
        break;
      case 'send':
        void this.onSend(userId, client, frame);
        break;
      case 'read':
        void this.onRead(userId, client, frame);
        break;
    }
  }

  private async onSend(
    userId: number,
    client: WebSocket,
    frame: ChatFrame,
  ): Promise<void> {
    const { conversationId, clientMsgId, content } = frame;
    if (!conversationId || typeof content !== 'string' || !content.trim()) {
      this.reply(client, {
        type: 'error',
        code: 'bad_request',
        message: '参数不合法',
      });
      return;
    }
    try {
      const { message, peerId } = await this.chat.sendMessage(
        userId,
        Number(conversationId),
        content,
      );
      // 通过 sendToUser 发给发送方自己的所有连接（比 reply(client) 更可靠，后者可能因单连接状态异常丢帧）
      this.sendToUser(userId, {
        type: 'sent',
        clientMsgId: clientMsgId ?? null,
        message: this.serializeMessage(message),
      });
      this.sendToUser(peerId, {
        type: 'newMessage',
        message: this.serializeMessage(message),
      });
    } catch (e) {
      this.reply(client, {
        type: 'error',
        code: 'send_failed',
        message: e instanceof HttpException ? e.message : '发送失败',
      });
    }
  }

  private async onRead(
    userId: number,
    client: WebSocket,
    frame: ChatFrame,
  ): Promise<void> {
    const conversationId = Number(frame.conversationId);
    if (!conversationId) return;
    try {
      const { readAt, peerId } = await this.chat.markRead(
        userId,
        conversationId,
      );
      this.sendToUser(peerId, {
        type: 'read',
        conversationId,
        readerId: userId,
        readAt: readAt?.toISOString?.() ?? readAt,
      });
    } catch {
      // 无权访问或会话不存在：静默忽略
    }
  }

  /** REST 发消息后的实时转发 */
  broadcastNewMessage(message: Message, peerId: number): void {
    this.sendToUser(peerId, {
      type: 'newMessage',
      message: this.serializeMessage(message),
    });
  }

  /** REST 标记已读后的实时转发 */
  broadcastRead(
    conversationId: number,
    peerId: number,
    readerId: number,
    readAt: Date,
  ): void {
    this.sendToUser(peerId, {
      type: 'read',
      conversationId,
      readerId,
      readAt: readAt?.toISOString?.() ?? readAt,
    });
  }

  /** 将 Message 实体转为可安全 msgpack 编码的纯对象（Date → ISO 字符串） */
  private serializeMessage(message: Message): Record<string, unknown> {
    return {
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      contentType: message.contentType,
      content: message.content,
      readAt: message.readAt?.toISOString?.() ?? message.readAt ?? null,
      createdAt: message.createdAt?.toISOString?.() ?? message.createdAt ?? null,
    };
  }

  private reply(client: WebSocket, payload: unknown): void {
    if (client.readyState !== WebSocket.OPEN) return;
    client.send(Buffer.from(encode(payload)), (err) => {
      if (err) console.warn('[ChatGateway] reply send error:', err.message);
    });
  }

  private sendToUser(userId: number, payload: unknown): void {
    const set = this.clients.get(userId);
    if (!set) return;
    const data = Buffer.from(encode(payload));
    for (const client of set) {
      if (client.readyState !== WebSocket.OPEN) continue;
      client.send(data, (err) => {
        if (err)
          console.warn(
            `[ChatGateway] sendToUser ${userId} error:`,
            err.message,
          );
      });
    }
  }
}
