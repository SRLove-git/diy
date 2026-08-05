import 'dart:async';

import 'package:flutter/material.dart';

import '../core/video_api.dart';
import 'profile/reels_player_page.dart';
import 'short_video_models.dart';

/// 短视频搜索页：顶部搜索框 + 结果宫格。
///
/// 从视频页点击搜索图标进入，初始为空白页仅展示搜索框；
/// 输入关键词后按标题 / 文案 / 配乐 / 地点 / 标签模糊搜索，
/// 点击结果进入 [ReelsPlayerPage] 播放。
class ShortVideoSearchPage extends StatefulWidget {
  const ShortVideoSearchPage({super.key});

  @override
  State<ShortVideoSearchPage> createState() => _ShortVideoSearchPageState();
}

class _ShortVideoSearchPageState extends State<ShortVideoSearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  final List<ShortVideo> _videos = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(text.trim());
    });
  }

  Future<void> _search(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _videos.clear();
        _searched = false;
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
    });
    try {
      final result = await VideoApi.search(keyword);
      if (!mounted) return;
      setState(() {
        _videos
          ..clear()
          ..addAll(result.items);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '搜索失败，请稍后再试';
      });
    }
  }

  void _openReels(ShortVideo video) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReelsPlayerPage(video: video)),
    );
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF22222A), size: 20),
        ),
        titleSpacing: 0,
        title: Container(
          height: 38,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F5),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: Color(0xFF8E8E8E), size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: _onChanged,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (text) {
                    _debounce?.cancel();
                    _search(text.trim());
                  },
                  style: const TextStyle(
                    color: Color(0xFF111118),
                    fontSize: 14,
                  ),
                  cursorColor: const Color(0xFF111118),
                  decoration: const InputDecoration(
                    hintText: '搜索视频 / 话题 / 配乐',
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF8E8E8E)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: _clear,
                  child: const Icon(Icons.cancel_rounded,
                      color: Color(0xFF8E8E8E), size: 18),
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB0B0B8)),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 44, color: Color(0xFF777788)),
            const SizedBox(height: 10),
            const Text(
              '搜索失败，请稍后再试',
              style: TextStyle(color: Color(0xFF777788), fontSize: 14),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _search(_controller.text.trim()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '重试',
                  style: TextStyle(color: Color(0xFF22222A), fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (!_searched) {
      // 空白页：仅提示输入关键词
      return const Center(
        child: Text(
          '输入关键词搜索视频',
          style: TextStyle(color: Color(0xFF9A9AA6), fontSize: 14),
        ),
      );
    }
    if (_videos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 44, color: Color(0xFFC0C0C8)),
            SizedBox(height: 10),
            Text(
              '没有找到相关视频',
              style: TextStyle(color: Color(0xFF9A9AA6), fontSize: 14),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: _videos.length,
      itemBuilder: (_, i) => _SearchVideoCell(
        video: _videos[i],
        onTap: () => _openReels(_videos[i]),
      ),
    );
  }
}

/// 搜索结果宫格单元：封面 + 播放角标 + 时长 + 作者
class _SearchVideoCell extends StatelessWidget {
  const _SearchVideoCell({required this.video, required this.onTap});

  final ShortVideo video;
  final VoidCallback onTap;

  String get _cover {
    if (video.cover.isNotEmpty) return video.cover;
    if (video.photos.isNotEmpty) return video.photos.first;
    return '';
  }

  String _durationText() {
    final s = video.duration.inSeconds;
    if (s <= 0) return '';
    final m = s ~/ 60;
    final sec = s % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isPhoto = video.isPhoto || video.videoUrl.isEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _cover.isNotEmpty
                ? Image.network(
                    _cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFF2F2F6),
                      child: const Icon(
                        Icons.movie_outlined,
                        color: Color(0xFFC0C0C8),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFFF2F2F6),
                    child: const Icon(
                      Icons.movie_outlined,
                      color: Color(0xFFC0C0C8),
                    ),
                  ),
            if (isPhoto)
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.photo_outlined,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              )
            else
              const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            // 底部渐变 + 作者 / 时长
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.92),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        video.user,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF22222A),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (!isPhoto && _durationText().isNotEmpty)
                      Text(
                        _durationText(),
                        style: const TextStyle(
                          color: Color(0xFF22222A),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
