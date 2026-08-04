import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'chat_api.dart';

/// 本地消息状态（与服务端发送状态机对齐：sending → sent → read，failed 可重发）
enum LocalMsgStatus { sending, sent, read, failed }

/// 本地缓存的聊天消息（对应 messages_local 表）
class LocalMessage {
  const LocalMessage({
    required this.clientMsgId,
    this.serverId,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = 'text',
    required this.sendTime,
    required this.status,
  });

  /// 本地唯一键：发送中为客户端流水号，服务端消息为 `srv-<id>`
  final String clientMsgId;

  /// 服务端消息 id（回执后回填）
  final int? serverId;

  final int conversationId;
  final int senderId;
  final String content;
  final String type;
  final DateTime sendTime;
  final LocalMsgStatus status;

  /// 转成聊天页使用的消息模型
  ChatMessage toChatMessage() => ChatMessage(
        id: serverId,
        conversationId: conversationId,
        senderId: senderId,
        contentType: type,
        content: content,
        createdAt: sendTime,
        clientMsgId: clientMsgId,
      );

  factory LocalMessage.fromRow(Map<String, Object?> row) => LocalMessage(
        clientMsgId: row['client_msg_id'] as String,
        serverId: row['server_id'] as int?,
        conversationId: row['conversation_id'] as int,
        senderId: row['sender_id'] as int,
        content: row['content'] as String,
        type: (row['type'] as String?) ?? 'text',
        sendTime: DateTime.fromMillisecondsSinceEpoch(row['send_time'] as int),
        status: LocalMsgStatus.values.firstWhere(
          (s) => s.name == row['status'],
          orElse: () => LocalMsgStatus.sent,
        ),
      );
}

/// 聊天消息本地缓存（SQLite messages_local 表）
///
/// 用途：
/// - 秒开：进入聊天页先读本地，再与服务端同步
/// - 弱网可用：服务端不可达时仍可查看历史与待发消息
/// - 发送流水：pending 消息本地留底，收到回执后回填 server_id / 更新状态
class LocalChatStore {
  LocalChatStore._();
  static final LocalChatStore instance = LocalChatStore._();

  static const _dbName = 'diy_chat.db';
  static const _table = 'messages_local';

  Future<Database>? _dbFuture;

  Future<Database> get _database => _dbFuture ??= _open();

  /// 建表 SQL（onCreate/onUpgrade 共用）
  String get _createSql => '''
    CREATE TABLE $_table (
      client_msg_id TEXT PRIMARY KEY,
      server_id INTEGER,
      conversation_id INTEGER NOT NULL,
      sender_id INTEGER NOT NULL,
      content TEXT NOT NULL,
      type TEXT NOT NULL DEFAULT 'text',
      send_time INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'sending'
    )
  ''';

  /// 索引 SQL：SQLite 索引不能引用隐藏列 rowid，只能使用实际列
  String get _createIndexSql => '''
    CREATE INDEX idx_msg_conv_time
    ON $_table(conversation_id, send_time DESC)
  ''';

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, _dbName),
      version: 2,
      onCreate: (db, _) async {
        await db.execute(_createSql);
        await db.execute(_createIndexSql);
      },
      onUpgrade: (db, oldVersion, _) async {
        // v1 索引引用了隐藏列 rowid 导致建表失败，这里重建表修复
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS $_table');
          await db.execute(_createSql);
          await db.execute(_createIndexSql);
        }
      },
    );
  }

  /// 发送前插入本地 pending 记录（同 clientMsgId 幂等覆盖）
  Future<void> insertPending({
    required String clientMsgId,
    required int conversationId,
    required int senderId,
    required String content,
    String type = 'text',
  }) async {
    final db = await _database;
    await db.insert(
      _table,
      {
        'client_msg_id': clientMsgId,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'type': type,
        'send_time': DateTime.now().millisecondsSinceEpoch,
        'status': LocalMsgStatus.sending.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 收到 sent 回执：回填服务端 id 并置为已发送
  Future<void> markSent(String clientMsgId, int serverId) async {
    final db = await _database;
    await db.update(
      _table,
      {'server_id': serverId, 'status': LocalMsgStatus.sent.name},
      where: 'client_msg_id = ?',
      whereArgs: [clientMsgId],
    );
  }

  /// 发送彻底失败（REST 兜底也失败）
  Future<void> markFailed(String clientMsgId) async {
    final db = await _database;
    await db.update(
      _table,
      {'status': LocalMsgStatus.failed.name},
      where: 'client_msg_id = ?',
      whereArgs: [clientMsgId],
    );
  }

  /// 删除本地消息（聊天受限被拒绝时清理占位气泡，避免重进页面又出现）
  Future<void> removeByClientMsgId(String clientMsgId) async {
    final db = await _database;
    await db.delete(
      _table,
      where: 'client_msg_id = ?',
      whereArgs: [clientMsgId],
    );
  }

  /// 对端已读回执：本会话自己发送的已送达消息置为已读
  Future<void> markRead(int conversationId) async {
    final db = await _database;
    await db.update(
      _table,
      {'status': LocalMsgStatus.read.name},
      where: 'conversation_id = ? AND status = ?',
      whereArgs: [conversationId, LocalMsgStatus.sent.name],
    );
  }

  /// 保存收到的新消息（以 server_id 去重，幂等）
  Future<void> saveIncoming(ChatMessage message) async {
    final id = message.id;
    if (id == null) return;
    final db = await _database;
    await db.insert(
      _table,
      {
        'client_msg_id': 'srv-$id',
        'server_id': id,
        'conversation_id': message.conversationId,
        'sender_id': message.senderId,
        'content': message.content,
        'type': message.contentType,
        'send_time': message.createdAt?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
        'status': LocalMsgStatus.read.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 拉取某会话本地消息（时间升序返回，上限 [limit]）
  Future<List<LocalMessage>> messages(
    int conversationId, {
    int limit = 100,
  }) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'send_time DESC, rowid DESC',
      limit: limit,
    );
    return rows.reversed.map(LocalMessage.fromRow).toList();
  }

  /// 登录态恢复后将 sender_id=0 的本机消息修正为真实 id
  /// （发送瞬间 user 尚未就绪时以 0 占位，会导致气泡被判定到对方一侧）
  Future<void> fixSenderIds(int myId) async {
    final db = await _database;
    await db.update(
      _table,
      {'sender_id': myId},
      where: 'sender_id = 0',
    );
  }

  /// 删除会话的本地消息（删除会话时调用）
  Future<void> clearConversation(int conversationId) async {
    final db = await _database;
    await db.delete(
      _table,
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }
}
