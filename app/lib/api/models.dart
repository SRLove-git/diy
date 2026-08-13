/// 服务端返回的数据模型（字段与 NestJS 实体/接口对齐）。
library;

num? _num(dynamic v) {
  if (v is num) return v;
  if (v is String && v.trim().isNotEmpty) return double.tryParse(v.trim());
  return null;
}

class User {
  const User({
    required this.id,
    this.email,
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
  final String? email;
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
    email: json['email'] as String?,
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
    this.groupPrice,
    this.allDayPrice,
    this.allDayMemberPrice,
    this.allDayGroupPrice,
    this.weekendSurchargePercent = 0,
    this.businessHours = '',
    this.phone = '',
    this.tables = const [],
    this.slots = const [],
    this.packages = const [],
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
  final double? groupPrice;
  final double? allDayPrice;
  final double? allDayMemberPrice;
  final double? allDayGroupPrice;
  final int weekendSurchargePercent;
  final String businessHours;
  final String phone;
  final List<StoreTable> tables;
  final List<TimeSlot> slots;
  final List<StorePackage> packages;

  String get cover => images.isNotEmpty ? images.first : '';

  /// 按小时预约的档位单价（元/人，含整段时长）：
  /// 时长恰好等于套餐时长 → 按套餐价；时长超过套餐 → 套餐价 + 超出小时 × 小时单价；
  /// 时长小于最小套餐 → 无适用套餐，按普通小时价。
  ({double normal, double member, double group}) hourlyUnitPrices(
    int hours, {
    double? memberRate,
    double? groupRate,
  }) {
    final mRate = memberRate ?? price;
    final gRate = groupRate ?? price;
    StorePackage? best;
    for (final p in packages) {
      if (!p.enabled || p.hours > hours) continue;
      if (best == null || p.hours > best.hours) best = p;
    }
    if (best == null) {
      return (
        normal: price * hours,
        member: mRate * hours,
        group: gRate * hours,
      );
    }
    final extra = hours - best.hours;
    return (
      normal: best.price + extra * price,
      member: (best.memberPrice ?? best.price) + extra * mRate,
      group: (best.groupPrice ?? best.price) + extra * gRate,
    );
  }

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    rating: (json['rating'] as num?)?.toDouble() ?? 5,
    images:
        (json['images'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    price: (json['price'] as num?)?.toDouble() ?? 0,
    memberPrice: (json['memberPrice'] as num?)?.toDouble(),
    groupPrice: (json['groupPrice'] as num?)?.toDouble(),
    allDayPrice: (json['allDayPrice'] as num?)?.toDouble(),
    allDayMemberPrice: (json['allDayMemberPrice'] as num?)?.toDouble(),
    allDayGroupPrice: (json['allDayGroupPrice'] as num?)?.toDouble(),
    weekendSurchargePercent:
        (json['weekendSurchargePercent'] as num?)?.toInt() ?? 0,
    businessHours: json['businessHours'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    tables:
        (json['tables'] as List?)
            ?.map((e) => StoreTable.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    slots:
        (json['slots'] as List?)
            ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    packages:
        (json['packages'] as List?)
            ?.map((e) => StorePackage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

/// 门店时长套餐（如 5 小时 / 6 小时）。
class StorePackage {
  const StorePackage({
    required this.id,
    required this.name,
    required this.hours,
    required this.price,
    this.memberPrice,
    this.groupPrice,
    this.enabled = true,
  });

  final int id;
  final String name;
  final int hours;
  final double price;
  final double? memberPrice;
  final double? groupPrice;
  final bool enabled;

  factory StorePackage.fromJson(Map<String, dynamic> json) => StorePackage(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    hours: (json['hours'] as num?)?.toInt() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    memberPrice: (json['memberPrice'] as num?)?.toDouble(),
    groupPrice: (json['groupPrice'] as num?)?.toDouble(),
    enabled: json['enabled'] as bool? ?? true,
  );
}

/// 桌位可用性：某日某桌的已占用时段窗口。
class TableAvailability {
  const TableAvailability({
    required this.id,
    required this.name,
    required this.capacity,
    this.bookedWindows = const [],
  });

  final int id;
  final String name;
  final int capacity;
  final List<BookedWindow> bookedWindows;

  /// 指定时段 [start, end) 与该桌已占用窗口是否无重叠。
  bool isFree(String start, String end) => bookedWindows.every((w) {
    final ws = _tm(w.startTime);
    final we = _tm(w.endTime);
    return ws >= _tm(end) || we <= _tm(start);
  });

  factory TableAvailability.fromJson(Map<String, dynamic> json) =>
      TableAvailability(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        capacity: (json['capacity'] as num?)?.toInt() ?? 1,
        bookedWindows:
            (json['bookedWindows'] as List?)
                ?.map((e) => BookedWindow.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class BookedWindow {
  const BookedWindow({
    required this.startTime,
    required this.endTime,
    this.status = 'booked',
  });

  final String startTime;
  final String endTime;
  final String status;

  factory BookedWindow.fromJson(Map<String, dynamic> json) => BookedWindow(
    startTime: json['startTime'] as String? ?? '',
    endTime: json['endTime'] as String? ?? '',
    status: json['status'] as String? ?? 'booked',
  );
}

int _tm(String time) {
  final p = time.split(':');
  return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
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

  factory ActivitySession.fromJson(Map<String, dynamic> json) =>
      ActivitySession(
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
    sessions:
        (json['sessions'] as List?)
            ?.map((e) => ActivitySession.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

class Appointment {
  const Appointment({
    required this.id,
    required this.type,
    this.bookingType = 'hourly',
    this.durationHours,
    this.packageName = '',
    required this.userId,
    this.storeId,
    required this.storeName,
    this.tableId,
    required this.tableName,
    this.slotId,
    this.tables = const [],
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
    this.userNickname = '',
    this.userEmail,
    this.note = '',
    this.userCouponId,
    this.couponTitle = '',
    this.couponDiscount = 0,
    this.couponCode,
    this.checkInTime,
    this.serviceStartTime,
    this.serviceEndTime,
    this.createdAt,
  });

  final int id;
  final String type;
  final String bookingType;
  final int? durationHours;
  final String packageName;
  final int userId;
  final int? storeId;
  final String storeName;
  final int? tableId;
  final String tableName;
  final int? slotId;
  final List<TableSeat> tables;
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

  /// 管理端列表附带：用户昵称 / 邮箱（普通列表接口不返回）。
  final String userNickname;
  final String? userEmail;

  final String note;
  final int? userCouponId;
  final String couponTitle;
  final double couponDiscount;
  final String? couponCode;
  final DateTime? checkInTime;
  final DateTime? serviceStartTime;
  final DateTime? serviceEndTime;
  final DateTime? createdAt;

  String get title =>
      type == 'activity' && activityName.isNotEmpty ? activityName : storeName;

  /// 桌位展示名：一单多桌时用 "4人桌1 + 单人桌1"，旧单桌用 tableName。
  String get tableLabel {
    if (tables.isNotEmpty) {
      return tables.map((t) => t.name).join(' + ');
    }
    return tableName;
  }

  /// 座位标签：按各桌分配人数自动派座（如 B1-1、B1-2 = 第一个二人桌的 1/2 号座位）。
  /// 无多桌明细（旧单桌数据）时为空。
  String get seatLabel {
    if (tables.isEmpty) return '';
    return [
      for (final t in tables)
        for (var i = 1; i <= t.people; i++) '${t.name}-$i',
    ].join('、');
  }

  String get statusLabel => switch (status) {
    'pending' => '待确认',
    'booked' => '待核销',
    'checked_in' => '已核销',
    'in_service' => '服务中',
    'completed' => '已完成',
    'cancelled' => '已取消',
    _ => status,
  };

  /// 预约结束时间（date + endTime）。
  DateTime? get endDateTime {
    final d = DateTime.tryParse(date);
    if (d == null) return null;
    final t = endTime.split(':');
    if (t.length < 2) return null;
    return DateTime(
      d.year,
      d.month,
      d.day,
      int.tryParse(t[0]) ?? 0,
      int.tryParse(t[1]) ?? 0,
    );
  }

  /// 待核销订单是否已超过预约结束时间（订单已失效）。
  bool isExpired([DateTime? now]) {
    if (status != 'booked') return false;
    final end = endDateTime;
    return end != null && !end.isAfter(now ?? DateTime.now());
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return Appointment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'store',
      bookingType: json['bookingType'] as String? ?? 'hourly',
      durationHours: (json['durationHours'] as num?)?.toInt(),
      packageName: json['packageName'] as String? ?? '',
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      storeId: (json['storeId'] as num?)?.toInt(),
      storeName: json['storeName'] as String? ?? '',
      tableId: (json['tableId'] as num?)?.toInt(),
      tableName: json['tableName'] as String? ?? '',
      slotId: (json['slotId'] as num?)?.toInt(),
      tables:
          (json['tables'] as List?)
              ?.map((e) => TableSeat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
      userNickname: json['userNickname'] as String? ?? '',
      userEmail: json['userEmail'] as String?,
      note: json['note'] as String? ?? '',
      userCouponId: (json['userCouponId'] as num?)?.toInt(),
      couponTitle: json['couponTitle'] as String? ?? '',
      couponDiscount: _num(json['couponDiscount'])?.toDouble() ?? 0,
      couponCode: json['couponCode'] as String?,
      checkInTime: dt(json['checkInTime']),
      serviceStartTime: dt(json['serviceStartTime']),
      serviceEndTime: dt(json['serviceEndTime']),
      createdAt: dt(json['createdAt']),
    );
  }
}

class PostMedia {
  const PostMedia({
    required this.type,
    required this.url,
    this.aspectRatio,
    this.duration,
  });
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

/// 预约桌位明细（一单多桌）：桌位 + 容纳人数 + 该桌分配人数。
class TableSeat {
  const TableSeat({
    required this.id,
    required this.name,
    required this.capacity,
    required this.people,
  });

  final int id;
  final String name;
  final int capacity;
  final int people;

  factory TableSeat.fromJson(Map<String, dynamic> json) => TableSeat(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    capacity: (json['capacity'] as num?)?.toInt() ?? 1,
    people: (json['people'] as num?)?.toInt() ?? 0,
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

  List<String> get mediaUrls =>
      medias.isNotEmpty ? medias.map((m) => m.url).toList() : images;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: (json['id'] as num?)?.toInt() ?? 0,
    userId: (json['userId'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    location: json['location'] as String? ?? '',
    images:
        (json['images'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    medias:
        (json['medias'] as List?)
            ?.map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    tags:
        (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
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
    replyTo: json['replyTo'] == null ? null : Author.fromJson(json['replyTo']),
    replies:
        (json['replies'] as List?)
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
    photos:
        (json['photos'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    filter: json['filter'] as String? ?? '',
    speed: (json['speed'] as num?)?.toDouble() ?? 1,
    duration: (json['duration'] as num?)?.toInt() ?? 0,
    aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 0,
    music: json['music'] as String? ?? '',
    tags:
        (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
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
      userId:
          (json['userId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      nickname:
          json['nickname'] as String? ?? user['nickname'] as String? ?? '',
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
    this.category = 'system',
    this.channel = 'push',
    this.createdAt,
    this.sentAt,
    this.read = false,
    this.actionType,
    this.actionId,
  });

  final int id;
  final String title;
  final String content;
  final String category;
  final String channel;
  final DateTime? createdAt;
  final DateTime? sentAt;
  final bool read;

  /// 点击跳转类型：post / video / user
  final String? actionType;
  final int? actionId;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        category: json['category'] as String? ?? 'system',
        channel: json['channel'] as String? ?? 'push',
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString()),
        sentAt: json['sentAt'] == null
            ? null
            : DateTime.tryParse(json['sentAt'].toString()),
        read: json['read'] as bool? ?? false,
        actionType: json['actionType'] as String?,
        actionId: (json['actionId'] as num?)?.toInt(),
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

/// 管理端会员列表条目（附带用户显示名）。
class AdminMembership {
  const AdminMembership({
    required this.id,
    required this.userId,
    this.userName = '',
    this.memberNo = '',
    this.levelName = '手作会员',
    this.status = 'none',
    this.expireAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String userName;
  final String memberNo;
  final String levelName;
  final String status; // active / expired
  final DateTime? expireAt;
  final DateTime? updatedAt;

  String get statusLabel => switch (status) {
    'active' => '已开通',
    'expired' => '已过期',
    _ => status,
  };

  factory AdminMembership.fromJson(Map<String, dynamic> json) {
    final expireRaw = json['expireAt'];
    final expire = expireRaw == null
        ? null
        : DateTime.tryParse(expireRaw.toString());
    final rawStatus = json['status'] as String? ?? '';
    return AdminMembership(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userName: json['userName'] as String? ?? '',
      memberNo: json['memberNo'] as String? ?? '',
      levelName: json['levelName'] as String? ?? '手作会员',
      status: rawStatus.isNotEmpty
          ? rawStatus
          : (expire == null || expire.isAfter(DateTime.now())
                ? 'active'
                : 'expired'),
      expireAt: expire,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'].toString()),
    );
  }
}

class MemberOrder {
  const MemberOrder({
    required this.id,
    required this.planName,
    required this.durationDays,
    required this.amount,
    required this.status,
    this.userNickname = '',
    this.userEmail,
    this.createdAt,
  });

  final int id;
  final String planName;
  final int durationDays;
  final double amount;
  final String status; // pending / confirmed / cancelled
  final String userNickname;
  final String? userEmail;
  final DateTime? createdAt;

  String get statusLabel => switch (status) {
    'pending' => '待确认',
    'confirmed' => '已开通',
    'cancelled' => '已取消',
    _ => status,
  };

  factory MemberOrder.fromJson(Map<String, dynamic> json) => MemberOrder(
    id: (json['id'] as num?)?.toInt() ?? 0,
    planName: json['planName'] as String? ?? '',
    durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
    amount: _num(json['amount'])?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'pending',
    userNickname: json['userNickname'] as String? ?? '',
    userEmail: json['userEmail'] as String?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.tryParse(json['createdAt'].toString()),
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
    this.enabled = true,
  });

  final int id;
  final String name;
  final int durationDays;
  final double price;
  final double originalPrice;
  final List<String> benefits;
  final String badge;
  final bool recommended;
  final bool enabled;

  factory MemberPlan.fromJson(Map<String, dynamic> json) => MemberPlan(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
    price: _num(json['price'])?.toDouble() ?? 0,
    originalPrice: _num(json['originalPrice'])?.toDouble() ?? 0,
    benefits:
        (json['benefits'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    badge: json['badge'] as String? ?? '',
    recommended: json['recommended'] as bool? ?? false,
    enabled: json['enabled'] as bool? ?? true,
  );
}

class Coupon {
  const Coupon({
    required this.id,
    required this.title,
    required this.amount,
    this.amountRaw = '',
    this.threshold = '无门槛',
    this.expireAt,
    this.stock = 0,
    this.membersOnly = true,
    this.enabled = true,
    this.received = false,
    this.userCouponId,
    this.status = 'unused',
    this.receivedAt,
    this.code = '',
    this.usedAt,
    this.redeemedBy,
    this.userId,
    this.userNickname = '',
    this.userEmail,
  });

  final int id;
  final String title;
  final double amount;
  final String amountRaw;
  final String threshold;
  final DateTime? expireAt;
  final int stock;
  final bool membersOnly;
  final bool enabled;
  final bool received;
  final int? userCouponId;
  final String status;
  final DateTime? receivedAt;
  final String code;
  final DateTime? usedAt;
  final int? redeemedBy;

  /// 券码查询 / 核销确认返回：持券用户信息。
  final int? userId;
  final String userNickname;
  final String? userEmail;

  bool get usable =>
      status == 'unused' &&
      (expireAt == null || expireAt!.isAfter(DateTime.now()));

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: (json['id'] as num?)?.toInt() ?? 0,
    // 核销前确认接口返回 couponTitle/couponAmount/couponThreshold 字段
    title: (json['title'] as String?) ?? (json['couponTitle'] as String? ?? ''),
    amountRaw:
        (json['amount'] as String?) ?? (json['couponAmount']?.toString() ?? ''),
    amount:
        _num(json['amount'])?.toDouble() ??
        _num(json['couponAmount'])?.toDouble() ??
        0,
    threshold:
        (json['threshold'] as String?) ??
        (json['couponThreshold'] as String? ?? '无门槛'),
    expireAt: json['expireAt'] == null
        ? null
        : DateTime.tryParse(json['expireAt'].toString()),
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    membersOnly: json['membersOnly'] as bool? ?? true,
    enabled: json['enabled'] as bool? ?? true,
    received: json['received'] as bool? ?? false,
    userCouponId: (json['userCouponId'] as num?)?.toInt(),
    status: json['status'] as String? ?? 'unused',
    receivedAt: json['receivedAt'] == null
        ? null
        : DateTime.tryParse(json['receivedAt'].toString()),
    code: json['code'] as String? ?? '',
    usedAt: json['usedAt'] == null
        ? null
        : DateTime.tryParse(json['usedAt'].toString()),
    redeemedBy: (json['redeemedBy'] as num?)?.toInt(),
    userId: (json['userId'] as num?)?.toInt(),
    userNickname: json['userNickname'] as String? ?? '',
    userEmail: json['userEmail'] as String?,
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
        items: itemsOf != null
            ? itemsOf(list)
            : list.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
        total: (raw[1] as num?)?.toInt() ?? list.length,
      );
    }
    if (raw is Map<String, dynamic>) {
      final list = raw['items'] as List? ?? [];
      return Page(
        items: itemsOf != null
            ? itemsOf(list)
            : list.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
        total: (raw['total'] as num?)?.toInt() ?? list.length,
      );
    }
    return const Page(items: [], total: 0);
  }
}
