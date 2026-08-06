import 'package:flutter/material.dart';

import '../../core/post_api.dart';
import 'post_card.dart';

/// 社区页：发现 / 关注 双 Tab + 频道分类 + 信息流
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  static const _channels = ['推荐', '最新', '热门', '教程', '日常', '活动'];

  String _channel = '推荐';
  List<Post> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _load();
    });
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final following = _tab.index == 1;
      final channelParam = _channel == '推荐' ? null : _channel;
      final result = following
          ? await PostApi.fetchFollowing()
          : switch (_channel) {
              '热门' => await PostApi.fetchHot(channel: channelParam),
              _ => await PostApi.fetchLatest(channel: channelParam),
            };
      if (!mounted) return;
      setState(() {
        _posts = result.items;
        _loading = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '加载失败，请检查网络';
      });
    }
  }

  Future<void> _refresh() => _load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '社区',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('搜索功能即将上线')),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        size: 21,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tab,
              labelColor: const Color(0xFF111111),
              unselectedLabelColor: const Color(0xFFA8A8A8),
              indicatorColor: const Color(0xFFED4956),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: '发现'),
                Tab(text: '关注'),
              ],
            ),
            if (_tab.index == 0)
              SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _channels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = _channels[i];
                    final selected = c == _channel;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _channel = c);
                        _load();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF111111)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF737373),
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _buildFeed(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(Icons.cloud_off, color: Color(0xFFA8A8A8), size: 40),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFA8A8A8)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _load, child: const Text('重试')),
              ],
            ),
          ),
        ],
      );
    }
    if (_posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              '这里还没有内容，发布第一条作品吧',
              style: TextStyle(color: Color(0xFFA8A8A8)),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4),
      itemCount: _posts.length,
      itemBuilder: (context, i) => PostCard(post: _posts[i]),
    );
  }
}
