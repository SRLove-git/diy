import 'package:flutter/material.dart';

import '../../core/appointment_api.dart';
import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/post_api.dart';
import '../community/post_card.dart';

/// 首页：问候头部 + 活动专区 + 附近门店 + 最新作品信息流
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Activity> _activities = [];
  List<Store> _stores = [];
  List<Post> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        AppointmentApi.fetchActivities(),
        AppointmentApi.fetchStores(),
        PostApi.fetchLatest(page: 1),
      ]);
      if (!mounted) return;
      setState(() {
        _activities = results[0] as List<Activity>;
        _stores = results[1] as List<Store>;
        _posts = (results[2] as ({List<Post> items, int total})).items;
        _loading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refresh() => _load();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;
    final nickname = user?.nickname ?? '手作人';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(nickname: nickname)),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoadError(onRetry: _load),
                )
              else ...[
                if (_activities.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: _SectionTitle('活动专区')),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 168,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _activities.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) =>
                            _ActivityCard(activity: _activities[i]),
                      ),
                    ),
                  ),
                ],
                if (_stores.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: _SectionTitle('附近门店')),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 132,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _stores.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) =>
                            _StoreCard(store: _stores[i]),
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 18, 16, 6),
                    child: Text(
                      '最新作品',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ),
                if (_posts.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text(
                          '还没有作品，去社区逛逛吧',
                          style: TextStyle(color: Color(0xFFA8A8A8)),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, i) =>
                        PostCard(post: _posts[i], compact: true),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.nickname});

  final String nickname;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFEDA75),
                  Color(0xFFFA7E1E),
                  Color(0xFFD62976),
                  Color(0xFF962FBF),
                  Color(0xFF4F5BD5),
                ],
              ),
            ),
            child: Center(
              child: Text(
                nickname.isEmpty ? '?' : nickname[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '你好呀',
                  style: TextStyle(fontSize: 12, color: Color(0xFFA8A8A8)),
                ),
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          _RoundIconButton(
            icon: Icons.search,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('搜索功能即将上线')),
              );
            },
          ),
          const SizedBox(width: 8),
          const _RoundIconButton(icon: Icons.notifications_none, onTap: null),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF111111)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111111),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3F4), Color(0xFFFFE8EF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFED4956),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              activity.tag,
              style: const TextStyle(color: Colors.white, fontSize: 10.5),
            ),
          ),
          const Spacer(),
          Text(
            activity.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${activity.date} · ¥${activity.price}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF737373)),
          ),
          const SizedBox(height: 4),
          Text(
            activity.bookable ? '可预约' : '已约满',
            style: TextStyle(
              fontSize: 12,
              color: activity.bookable
                  ? const Color(0xFF2E9E5B)
                  : const Color(0xFFA8A8A8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final cover =
        store.images.isNotEmpty ? ChatApi.resolveUrl(store.images.first) : '';
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 74,
            width: double.infinity,
            child: cover.isEmpty
                ? const ColoredBox(
                    color: Color(0xFFEFEFEF),
                    child: Icon(Icons.storefront_outlined,
                        color: Color(0xFFA8A8A8)),
                  )
                : Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFEFEFEF),
                      child: Icon(Icons.storefront_outlined,
                          color: Color(0xFFA8A8A8)),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${store.rating} 分 · ¥${store.price}/人',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF737373)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, color: Color(0xFFA8A8A8), size: 40),
          const SizedBox(height: 12),
          const Text(
            '加载失败，请检查网络',
            style: TextStyle(color: Color(0xFFA8A8A8)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
