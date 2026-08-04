import 'dart:async';

import 'package:flutter/material.dart';

import '../core/chat_api.dart';
import '../core/music_api.dart';

/// 音乐选择结果。
/// - 返回 null：用户关闭弹层，选择不变
/// - 返回 [MusicPickResult.music] 为 null：选择「原声」（清除配乐）
class MusicPickResult {
  const MusicPickResult(this.music);

  final MusicItem? music;
}

/// 打开曲库选择弹层（深色，TikTok 风格）
Future<MusicPickResult?> showMusicPicker(
  BuildContext context, {
  MusicItem? current,
}) {
  return showModalBottomSheet<MusicPickResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MusicPickerSheet(current: current),
  );
}

class MusicPickerSheet extends StatefulWidget {
  const MusicPickerSheet({super.key, this.current});

  final MusicItem? current;

  @override
  State<MusicPickerSheet> createState() => _MusicPickerSheetState();
}

class _MusicPickerSheetState extends State<MusicPickerSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<MusicItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load([String? keyword]) async {
    setState(() => _loading = true);
    try {
      final items = await MusicApi.list(keyword: keyword);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load(v));
  }

  static String _fmt(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A44),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                const Text(
                  '选择音乐',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // 原声：清除配乐
                GestureDetector(
                  onTap: () =>
                      Navigator.pop(context, const MusicPickResult(null)),
                  child: Row(
                    children: [
                      Icon(
                        widget.current == null
                            ? Icons.check_circle_rounded
                            : Icons.music_off_rounded,
                        color: widget.current == null
                            ? const Color(0xFFFF718D)
                            : Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '原声',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: '搜索歌曲 / 歌手',
                hintStyle: const TextStyle(color: Color(0xFF777788)),
                isDense: true,
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF777788),
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFF25252E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white30),
                  )
                : _items.isEmpty
                ? const Center(
                    child: Text(
                      '未找到相关音乐',
                      style: TextStyle(color: Color(0xFF8A8A96)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 2),
                    itemBuilder: (_, i) => _buildItem(_items[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(MusicItem item) {
    final selected = widget.current?.id == item.id;
    return InkWell(
      onTap: () => Navigator.pop(context, MusicPickResult(item)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 封面
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: item.cover.isEmpty
                    ? Container(
                        color: const Color(0xFF2C2C36),
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                      )
                    : Image.network(
                        ChatApi.resolveUrl(item.cover),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF2C2C36),
                          child: const Icon(
                            Icons.music_note_rounded,
                            color: Colors.white70,
                            size: 22,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // 标题 + 歌手
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.artist.isEmpty ? '未知歌手' : item.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8A8A96),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 时长
            Text(
              _fmt(item.duration),
              style: const TextStyle(color: Color(0xFF6A6A76), fontSize: 12),
            ),
            const SizedBox(width: 8),
            // 选中态
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: selected
                  ? const Color(0xFFFF718D)
                  : const Color(0xFF4A4A56),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
