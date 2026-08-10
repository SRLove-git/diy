import 'package:flutter_test/flutter_test.dart';

import 'package:diy_ui_app/api/models.dart';

void main() {
  test('Coupon 解析字符串金额', () {
    final c = Coupon.fromJson({
      'id': 1,
      'title': '测试',
      'amount': '20',
      'threshold': '10',
      'expireAt': '2027-10-09T18:01:00.000Z',
      'stock': 5,
      'membersOnly': false,
      'received': false,
    });
    expect(c.amount, 20);
    expect(c.received, false);
  });

  test('MemberPlan 解析字符串价格', () {
    final p = MemberPlan.fromJson({
      'id': 1,
      'name': '月卡',
      'durationDays': 30,
      'price': '29.90',
      'originalPrice': '59.00',
      'benefits': ['会员价', '专属券'],
      'recommended': true,
    });
    expect(p.price, 29.9);
    expect(p.originalPrice, 59.0);
  });

  test('User 解析', () {
    final u = User.fromJson({
      'id': 32,
      'username': 'test_user',
      'email': 'test@example.com',
      'nickname': '测试用户',
      'avatar': 'https://x/a.png',
      'role': 'user',
    });
    expect(u.id, 32);
    expect(u.username, 'test_user');
    expect(u.email, 'test@example.com');
    expect(u.displayName, '测试用户');
  });

  test('帖子列表 [items, total] 分页解析', () {
    final page = Page.parse<Post>(
      [
        [
          {
            'id': 26,
            'userId': 2,
            'title': '',
            'content': '内容',
            'images': [],
            'medias': [],
            'tags': [],
            'author': {'nickname': '作者', 'avatar': ''},
          }
        ],
        1,
      ],
      Post.fromJson,
    );
    expect(page.total, 1);
    expect(page.items.first.author?.nickname, '作者');
  });

  test('会话列表 {items,total} 解析', () {
    final page = Page.parse<ConversationItem>(
      {
        'items': [
          {
            'id': 10,
            'peer': {
              'id': 33,
              'nickname': '测试用户33',
              'avatar': '',
              'online': false,
              'blockedByMe': false,
              'blockedByPeer': false,
            },
            'lastMessagePreview': 'text:你好',
            'unreadCount': 1,
            'pinned': false,
          }
        ],
        'total': 1,
      },
      ConversationItem.fromJson,
    );
    expect(page.items.first.peerId, 33);
    expect(page.items.first.unreadCount, 1);
  });

  test('预约列表解析', () {
    final a = Appointment.fromJson({
      'id': 1,
      'type': 'store',
      'userId': 32,
      'storeName': '拼豆',
      'tableName': 'A1',
      'date': '2026-08-08',
      'startTime': '10:00',
      'endTime': '11:30',
      'peopleCount': 2,
      'code': '123456',
      'amount': '39.8',
      'originalAmount': '79.8',
      'payStatus': 'paid',
      'payMethod': 'wechat',
      'status': 'booked',
    });
    expect(a.statusLabel, '待核销');
    expect(a.amount, 39.8);
  });

  test('待确认状态标签', () {
    final a = Appointment.fromJson({
      'id': 2,
      'type': 'store',
      'userId': 32,
      'storeName': '拼豆',
      'tableName': 'A1',
      'date': '2026-08-10',
      'startTime': '10:00',
      'endTime': '11:30',
      'peopleCount': 2,
      'code': '654321',
      'amount': '39.8',
      'originalAmount': '39.8',
      'payStatus': 'unpaid',
      'payMethod': '',
      'status': 'pending',
    });
    expect(a.statusLabel, '待确认');
  });

  test('会员开通申请解析与状态标签', () {
    final o = MemberOrder.fromJson({
      'id': 3,
      'planName': '月卡会员',
      'durationDays': 30,
      'amount': '19.90',
      'status': 'pending',
      'createdAt': '2026-08-10T10:00:00',
    });
    expect(o.planName, '月卡会员');
    expect(o.amount, 19.9);
    expect(o.statusLabel, '待确认');
  });

  test('通知解析稳定分类与英文文案', () {
    final n = AppNotification.fromJson({
      'id': 8,
      'title': 'Ada liked your post',
      'content': '"My work" got a like',
      'category': 'like',
      'channel': 'push',
      'read': false,
    });
    expect(n.title, 'Ada liked your post');
    expect(n.category, 'like');
    expect(n.read, false);
  });
}
