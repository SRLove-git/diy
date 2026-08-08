/// 服务端返回的数据模型（字段与 NestJS 实体/接口对齐）。

num? _num(dynamic v) {
  if (v is num) return v;
  if (v is String && v.trim().isNotEmpty) return double.tryParse(v.trim());
  return null;
}

class User {
  const User({
    required this.id,
    required this.phone,
    this.username,
    this.nickname = '',
    this.avatar = '',
    this.bio = '',
    this.gender = 'secret',
    this.birthday,
    this.location = '',
    this.role = 'user',
    this.createdAt,
  });

  final int id;
  final String phone;
  final String? username;
  final String nickname;
  final String avatar;
  final String bio;
  final String gender;
  final String? birthday;
  final String location;
  final String role;
  final DateTime? createdAt;

  String get displayName => nickname.isNotEmpty ? nickname : '用户 #$id';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: (json['id'] as num?)?.toInt() ?? 0,
        phone: json['phone'] as String? ?? '',
        username: json['username'] as String?,
        nickname: json['nickname'] as String? ?? '',
        avatar: json['avatar'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        gender: json['gender'] as String? ?? 'secret',
        birthday: json['birthday'] as String?,
        location: json['location'] as String? ?? '',
        role: json['role'] as String? ?? 'user',
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString()),
      );
}

/// 帖子/视频中嵌入的作者摘要。
class Author {
  const Author({required this.id, this.nickname = '', this.avatar = ''});

  final int id;
  final String nickname;
  final String avatar;

  String get displayName => nickname.isNotEmpty ? nickname : '用户 #$id';

  factory Author.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return Author(id: (json is num) ? json.toInt() : 0);
    }
    return Author(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
    );
  }
}

class StoreTable {
  const StoreTable({
    required this.id,
    required this.name,
    required this.capacity,
    this.enabled = true,
    this.available = true,
  });

  final int id;
  final String name;
  final int capacity;
  final bool enabled;
  final bool available;

  factory StoreTable.fromJson(Map<String, dynamic> json) => StoreTable(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        capacity: (json['capacity'] as num?)?.toInt() ?? 1,
        enabled: json['enabled'] as bool? ?? true,
        available: json['available'] as bool? ?? true,
      );
}

class TimeSlot {
  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.enabled = true,
  });

  final int id;
  final String startTime;
  final String endTime;
  final bool enabled;

  String get label => '$startTime-$endTime';

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        id: (json['id'] as num?)?.toInt() ?? 0,
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? true,
      );
}

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.address,
    this.lat,
    this.lng,
    this.rating = 5,
    this.images = const [],
    this.price = 0,
    this.memberPrice,
    this.businessHours = '',
    this.phone = '',
    this.tables = const [],
    this.slots = const [],
  });

  final int id;
  final String name;
  final String address;
  final double? lat;
  final double? lng;
  final double rating;
  final List<String> images;
  final double price;
  final double? memberPrice;
  final String businessHours;
  final String phone;
  final List<StoreTable> tables;
  final List<TimeSlot> slots;

  String get cover => images.isNotEmpty ? images.first : '';

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toDouble() ?? 5,
        images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        price: (json['price'] as num?)?.toDouble() ?? 0,
        memberPrice: (json['memberPrice'] as num?)?.toDouble(),
        businessHours: json['businessHours'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        tables: (json['tables'] as List?)
                ?.map((e) => StoreTable.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        slots: (json['slots'] as List?)
                ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class ActivitySession {
  const ActivitySession({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.bookedCount = 0,
    this.remaining,
  });

  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final int capacity;
  final int bookedCount;
  final int? remaining;

  int get remainingCount => remaining ?? (capacity - bookedCount);

  factory ActivitySession.fromJson(Map<String, dynamic> json) => ActivitySession(
        id: (json['id'] as num?)?.toInt() ?? 0,
        date: json['date'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        capacity: (json['capacity'] as num?)?.toInt() ?? 0,
        bookedCount: (json['bookedCount'] as num?)?.toInt() ?? 0,
        remaining: (json['remaining'] as num?)?.toInt(),
      );
}

class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.date,
    this.desc = '',
    this.tag = '',
    this.address = '',
    this.price = 0,
    this.memberPrice,
    this.bookable = false,
    this.membersOnly = false,
    this.sessions = const [],
  });

  final int id;
  final String title;
  final String date;
  final String desc;
  final String tag;
  final String address;
  final double price;
  final double? memberPrice;
  final bool bookable;
  final bool membersOnly;
  final List<ActivitySession> sessions;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        date: json['date'] as String? ?? '',
        desc: json['desc'] as String? ?? '',
        tag: json['tag'] as String? ?? '',
        address: json['address'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        memberPrice: (json['memberPrice'] as num?)?.toDouble(),
        bookable: json['bookable'] as bool? ?? false,
        membersOnly: json['membersOnly'] as bool? ?? false,
        sessions: (json['sessions'] as List?)
                ?.map((e) => ActivitySession.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class Appointment {
  const Appointment({
    required this.id,
    required this.type,
    required this.userId,
    this.storeId,
    required this.storeName,
    this.tableId,
    required this.tableName,
    this.slotId,
    this.activityId,
    this.activitySessionId,
    required this.activityName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.peopleCount,
    required this.code,
    required this.amount,
    required this.originalAmount,
    required this.payStatus,
    required this.payMethod,
    required this.status,
    this.note = '',
    this.couponTitle = '',
    this.couponDiscount = 0,
    this.checkInTime,
    this.serviceStartTime,
    this.serviceEndTime,
    this.createdAt,
  });

  final int id;
  final String type;
  final int userId;
  final int? storeId;
  final String storeName;
  final int? tableId;
  final String tableName;
  final int? slotId;
  final int? activityId;
  final int? activitySessionId;
  final String activityName;
  final String date;
  final String startTime;
  final String endTime;
  final int peopleCount;
  final String code;
  final double amount;
  final double originalAmount;
  final String payStatus;
  final String payMethod;
  final String status;
  final String note;
  final String couponTitle;
  final double couponDiscount;
  final DateTime? checkInTime;
  final DateTime? serviceStartTime;
  final DateTime? serviceEndTime;
  final DateTime? createdAt;

  String get title =>
      type == 'activity' && activityName.isNotEmpty ? activityName : storeName;

  String get statusLabel => switch (status) {
        'booked' => '待核销',
        'checked_in' => '已核销',
        'in_service' => '服务中',
        'completed' => '已完成',
        'cancelled' => '已取消',
        _ => status,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return Appointment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'store',
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      storeId: (json['storeId'] as num?)?.toInt(),
      storeName: json['storeName'] as String? ?? '',
      tableId: (json['tableId'] as num?)?.toInt(),
      tableName: json['tableName'] as String? ?? '',
      slotId: (json['slotId'] as num?)?.toInt(),
      activityId: (json['activityId'] as num?)?.toInt(),
      activitySessionId: (json['activitySessionId'] as num?)?.toInt(),
      activityName: json['activityName'] as String? ?? '',
      date: json['date'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      peopleCount: (json['peopleCount'] as num?)?.toInt() ?? 1,
      code: json['code'] as String? ?? '',
      amount: _num(json['amount'])?.toDouble() ?? 0,
      originalAmount: _num(json['originalAmount'])?.toDouble() ?? 0,
      payStatus: json['payStatus'] as String? ?? 'unpaid',
      payMethod: json['payMethod'] as String? ?? '',
      status: json['status'] as String? ?? 'booked',
      note: json['note'] as String? ?? '',
      couponTitle: json['couponTitle'] as String? ?? '',
      couponDiscount: _num(json['couponDiscount'])?.toDouble() ?? 0,
      checkInTime: dt(json['checkInTime']),
      serviceStartTime: dt(json['serviceStartTime']),
      serviceEndTime: dt(json['serviceEndTime']),
      createdAt: dt(json['createdAt']),
    );
  }
}

class PostMedia {
  const PostMedia({required this.type, required this.url, this.aspectRatio, this.duration});
  final String type;
  final String url;
  final double? aspectRatio;
  final double? duration;

  factory PostMedia.fromJson(Map<String, dynamic> json) => PostMedia(
        type: json['type'] as String? ?? 'image',
        url: json['url'] as String? ?? '',
        aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
        duration: (json['duration'] as num?)?.toDouble(),
      );
}

class Post {
  const Post({
    required this.id,
    required this.userId,
    this.title = '',
    this.content = '',
    this.location = '',
    this.images = const [],
    this.medias = const [],
    this.tags = const [],
    this.channelTag = '',
    this.status = 'pending',
    this.likeCount = 0,
    this.collectCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.shareCount = 0,
    this.createdAt,
    this.author,
  });

  final int id;
  final int userId;
  final String title;
  final String content;
  final String location;
  final List<String> images;
  final List<PostMedia> medias;
  final List<String> tags;
  final String channelTag;
  final String status;
  final int likeCount;
  final int collectCount;
  final int commentCount;
  final int viewCount;
  final int shareCount;
  final DateTime? createdAt;
  final Author? author;

  List<String> get mediaUrls => medias.isNotEmpty
      ? medias.map((m) => m.url).toList()
      : images;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: (json['id'] as num?)?.toInt() ?? 0,
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        location: json['location'] as String? ?? '',
        images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        medias: (json['medias'] as List?)
                ?.map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        channelTag: json['channelTag'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        collectCount: (json['collectCount'] as num?)?.toInt() ?? 0,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString()),
        author: Author.fromJson(json['author']),
      );
}

class Comment {
  const Comment({
    required this.id,
    required this.userId,
    required this.postId,
    this.parentId,
    this.replyToId,
    required this.content,
    this.likeCount = 0,
    this.createdAt,
    this.author,
    this.replyTo,
    this.replies = const [],
  });

  final int id;
  final int userId;
  final int postId;
  final int? parentId;
  final int? replyToId;
  final String content;
  final int likeCount;
  final DateTime? createdAt;
  final Author? author;
  final Author? replyTo;
  final List<Comment> replies;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: (json['id'] as num?)?.toInt() ?? 0,
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        postId: (json['postId'] as num?)?.toInt() ?? 0,
        parentId: (json['parentId'] as num?)?.toInt(),
        replyToId: (json['replyToId'] as num?)?.toInt(),
        content: json['content'] as String? ?? '',
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString()),
        author: Author.fromJson(json['author']),
        replyTo: json['replyTo'] == null
            ? null
            : Author.fromJson(json['replyTo']),
        replies: (json['replies'] as List?)
                ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class Video {
  const Video({
    required this.id,
    required this.userId,
    this.title = '',
    this.content = '',
    this.cover = '',
    this.videoUrl = '',
    this.photos = const [],
    this.filter = '',
    this.speed = 1,
    this.duration = 0,
    this.aspectRatio = 0,
    this.music = '',
    this.tags = const [],
    this.location = '',
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    this.createdAt,
    this.author,
    this.liked = false,
  });

  final int id;
  final int userId;
  final String title;
  final String content;
  final String cover;
  final String videoUrl;
  final List<String> photos;
  final String filter;
  final double speed;
  final int duration;
  final double aspectRatio;
  final String music;
  final List<String> tags;
  final String location;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final DateTime? createdAt;
  final Author? author;
  final bool liked;

  bool get isPhoto => videoUrl.isEmpty && photos.isNotEmpty;

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: (json['id'] as num?)?.toInt() ?? 0,
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        cover: json['cover'] as String? ?? '',
        videoUrl: json['videoUrl'] as String? ?? '',
        photos: (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        filter: json['filter'] as String? ?? '',
        speed: (json['speed'] as num?)?.toDouble() ?? 1,
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 0,
        music: json['music'] as String? ?? '',
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        location: json['location'] as String? ?? '',
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
        shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString()),
        author: Author.fromJson(json['author']),
        liked: json['liked'] as bool? ?? false,
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.contentType,
    required this.content,
    this.replyToId,
    this.replyPreview,
    this.forwarded = false,
    this.recalledAt,
    this.readAt,
    this.createdAt,
    this.author,
  });

  final int id;
  final int senderId;
  final String contentType;
  final String content;
  final int? replyToId;
  final String? replyPreview;
  final bool forwarded;
  final DateTime? recalledAt;
  final DateTime? readAt;
  final DateTime? createdAt;
  final Author? author;

  bool get isMine => false; // 由页面根据当前用户判断
  bool get isRecalled => recalledAt != null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: (json['id'] as num?)?.toInt() ?? 0,
        senderId: (json['senderId'] as num?)?.toInt() ?? 0,
        contentType: json['contentType'] as String? ?? 'text',
        content: json['content'] as String? ?? '',
        replyToId: (json['replyToId'] as num?)?.toInt(),
        replyPreview: json['replyPreview'] as String?,
        forwarded: json['forwarded'] as bool? ?? false,
        recalledAt: json['recalledAt'] == null
            ? null
            : DateTime.tryParse(json['recalledAt'].toString()),
        readAt: json['readAt'] == null
            ? null
            : DateTime.tryParse(json['readAt'].toString()),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString()),
        author: Author.fromJson(json['author']),
      );
}

class ConversationItem {
  const ConversationItem({
    required this.id,
    required this.peerId,
    this.peerNickname = '',
    this.peerAvatar = '',
    this.peerOnline = false,
    this.blockedByMe = false,
    this.blockedByPeer = false,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.pinned = false,
  });

  final int id;
  final int peerId;
  final String peerNickname;
  final String peerAvatar;
  final bool peerOnline;
  final bool blockedByMe;
  final bool blockedByPeer;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool pinned;

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    final peer = json['peer'] as Map<String, dynamic>? ?? const {};
    return ConversationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      peerId: (peer['id'] as num?)?.toInt() ?? 0,
      peerNickname: peer['nickname'] as String? ?? '',
      peerAvatar: peer['avatar'] as String? ?? '',
      peerOnline: peer['online'] as bool? ?? false,
      blockedByMe: peer['blockedByMe'] as bool? ?? false,
      blockedByPeer: peer['blockedByPeer'] as bool? ?? false,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.tryParse(json['lastMessageAt'].toString()),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      pinned: json['pinned'] as bool? ?? false,
    );
  }
}

class GroupItem {
  const GroupItem({
    required this.id,
    required this.name,
    required this.ownerId,
    this.memberCount = 0,
    this.memberAvatars = const [],
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isOwner = false,
  });

  final int id;
  final String name;
  final int ownerId;
  final int memberCount;
  final List<String> memberAvatars;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isOwner;

  factory GroupItem.fromJson(Map<String, dynamic> json) => GroupItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        ownerId: (json['ownerId'] as num?)?.toInt() ?? 0,
        memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
        memberAvatars:
            (json['memberAvatars'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        lastMessagePreview: json['lastMessagePreview'] as String?,
        lastMessageAt: json['lastMessageAt'] == null
            ? null
            : DateTime.tryParse(json['lastMessageAt'].toString()),
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        isOwner: json['isOwner'] as bool? ?? false,
      );
}

class GroupMember {
  const GroupMember({
    required this.id,
    required this.userId,
    this.nickname = '',
    this.avatar = '',
    this.role = 'member',
  });

  final int id;
  final int userId;
  final String nickname;
  final String avatar;
  final String role;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return GroupMember(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      nickname: json['nickname'] as String? ??
          user['nickname'] as String? ??
          '',
      avatar: json['avatar'] as String? ?? user['avatar'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.content,
    this.channel = 'push',
    this.createdAt,
    this.sentAt,
    this.read = false,
  });

  final int id;
  final String title;
  final String content;
  final String channel;
  final DateTime? createdAt;
  final DateTime? sentAt;
  final bool read;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        channel: json['channel'] as String? ?? 'push',
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString()),
        sentAt: json['sentAt'] == null
            ? null
            : DateTime.tryParse(json['sentAt'].toString()),
        read: json['read'] as bool? ?? false,
      );
}

class Membership {
  const Membership({
    this.memberNo = '',
    this.levelName = '手作会员',
    this.status = 'none',
    this.expireAt,
    this.id,
  });

  final int? id;
  final String memberNo;
  final String levelName;
  final String status; // none / active / expired
  final DateTime? expireAt;

  bool get isActive => status == 'active';

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        id: (json['id'] as num?)?.toInt(),
        memberNo: json['memberNo'] as String? ?? '',
        levelName: json['levelName'] as String? ?? '手作会员',
        status: json['status'] as String? ?? 'none',
        expireAt: json['expireAt'] == null
            ? null
            : DateTime.tryParse(json['expireAt'].toString()),
      );
}

class MemberPlan {
  const MemberPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.originalPrice,
    this.benefits = const [],
    this.badge = '',
    this.recommended = false,
  });

  final int id;
  final String name;
  final int durationDays;
  final double price;
  final double originalPrice;
  final List<String> benefits;
  final String badge;
  final bool recommended;

  factory MemberPlan.fromJson(Map<String, dynamic> json) => MemberPlan(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
        price: _num(json['price'])?.toDouble() ?? 0,
        originalPrice: _num(json['originalPrice'])?.toDouble() ?? 0,
        benefits: (json['benefits'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        badge: json['badge'] as String? ?? '',
        recommended: json['recommended'] as bool? ?? false,
      );
}

class Coupon {
  const Coupon({
    required this.id,
    required this.title,
    required this.amount,
    this.threshold = '无门槛',
    this.expireAt,
    this.stock = 0,
    this.membersOnly = true,
    this.received = false,
    this.userCouponId,
    this.status = 'unused',
    this.receivedAt,
  });

  final int id;
  final String title;
  final double amount;
  final String threshold;
  final DateTime? expireAt;
  final int stock;
  final bool membersOnly;
  final bool received;
  final int? userCouponId;
  final String status;
  final DateTime? receivedAt;

  bool get usable => status == 'unused' && (expireAt == null || expireAt!.isAfter(DateTime.now()));

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        amount: _num(json['amount'])?.toDouble() ?? 0,
        threshold: json['threshold'] as String? ?? '无门槛',
        expireAt: json['expireAt'] == null
            ? null
            : DateTime.tryParse(json['expireAt'].toString()),
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        membersOnly: json['membersOnly'] as bool? ?? true,
        received: json['received'] as bool? ?? false,
        userCouponId: (json['userCouponId'] as num?)?.toInt(),
        status: json['status'] as String? ?? 'unused',
        receivedAt: json['receivedAt'] == null
            ? null
            : DateTime.tryParse(json['receivedAt'].toString()),
      );
}

class Music {
  const Music({
    required this.id,
    required this.title,
    this.artist = '',
    this.cover = '',
    this.musicUrl = '',
    this.duration = 0,
  });

  final int id;
  final String title;
  final String artist;
  final String cover;
  final String musicUrl;
  final int duration;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        cover: json['cover'] as String? ?? '',
        musicUrl: json['musicUrl'] as String? ?? '',
        duration: (json['duration'] as num?)?.toInt() ?? 0,
      );
}

class FollowStatus {
  const FollowStatus({
    required this.userId,
    required this.nickname,
    this.avatar = '',
    this.following = false,
    this.followedMe = false,
    this.mutual = false,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  final int userId;
  final String nickname;
  final String avatar;
  final bool following;
  final bool followedMe;
  final bool mutual;
  final int followerCount;
  final int followingCount;

  factory FollowStatus.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return FollowStatus(
      userId: (user['id'] as num?)?.toInt() ?? 0,
      nickname: user['nickname'] as String? ?? '',
      avatar: user['avatar'] as String? ?? '',
      following: json['following'] as bool? ?? false,
      followedMe: json['followedMe'] as bool? ?? false,
      mutual: json['mutual'] as bool? ?? false,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class FollowUser {
  const FollowUser({
    required this.id,
    required this.nickname,
    this.avatar = '',
    this.following = false,
  });

  final int id;
  final String nickname;
  final String avatar;
  final bool following;

  factory FollowUser.fromJson(Map<String, dynamic> json) => FollowUser(
        id: (json['id'] as num?)?.toInt() ?? 0,
        nickname: json['nickname'] as String? ?? '',
        avatar: json['avatar'] as String? ?? '',
        following: json['following'] as bool? ?? false,
      );
}

/// 分页助手：多数列表接口返回 `[items, total]` 或 `{items, total}`。
class Page<T> {
  const Page({required this.items, required this.total});

  final List<T> items;
  final int total;

  static Page<T> parse<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson, {
    List<T> Function(List<dynamic>)? itemsOf,
  }) {
    if (raw is List && raw.length == 2) {
      final list = raw[0] as List? ?? [];
      return Page(
        items: itemsOf != null ? itemsOf(list) : list.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
        total: (raw[1] as num?)?.toInt() ?? list.length,
      );
    }
    if (raw is Map<String, dynamic>) {
      final list = raw['items'] as List? ?? [];
      return Page(
        items: itemsOf != null ? itemsOf(list) : list.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
        total: (raw['total'] as num?)?.toInt() ?? list.length,
      );
    }
    return const Page(items: [], total: 0);
  }
}
