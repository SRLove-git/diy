import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../core/app_colors.dart';
import '../core/media_composer.dart';

class MediaPickerPage extends StatefulWidget {
  const MediaPickerPage({super.key, this.maxSelection = 20});

  final int maxSelection;

  @override
  State<MediaPickerPage> createState() => _MediaPickerPageState();
}

enum _MediaTab { all, video, image }

class _MediaPickerPageState extends State<MediaPickerPage> {
  final List<AssetEntity> _assets = [];
  final List<AssetEntity> _selected = [];
  _MediaTab _tab = _MediaTab.all;
  bool _loading = true;
  bool _finishing = false;
  String? _error;

  List<AssetEntity> get _visibleAssets => switch (_tab) {
    _MediaTab.video =>
      _assets.where((asset) => asset.type == AssetType.video).toList(),
    _MediaTab.image =>
      _assets.where((asset) => asset.type == AssetType.image).toList(),
    _ => _assets,
  };

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '需要允许访问相册，才能选择图片和视频';
      });
      return;
    }
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
      filterOption: FilterOptionGroup(),
    );
    final recent = albums.isEmpty ? null : albums.first;
    final assets = recent == null
        ? <AssetEntity>[]
        : await recent.getAssetListPaged(page: 0, size: 300);
    final filtered = <AssetEntity>[];
    for (final asset in assets) {
      if (asset.type == AssetType.video) {
        filtered.add(asset);
        continue;
      }
      if (asset.type != AssetType.image) continue;
      final mime = (asset.mimeType ?? await asset.mimeTypeAsync ?? '')
          .toLowerCase();
      final title = (asset.title ?? await asset.titleAsync).toLowerCase();
      if (mime == 'image/gif' || title.endsWith('.gif')) continue;
      filtered.add(asset);
    }
    if (!mounted) return;
    setState(() {
      _assets.addAll(filtered);
      _loading = false;
    });
  }

  void _toggle(AssetEntity asset) {
    final index = _selected.indexWhere((item) => item.id == asset.id);
    final reachedLimit = index < 0 && _selected.length >= widget.maxSelection;
    if (reachedLimit) {
      _toast('最多选择 ${widget.maxSelection} 个素材');
      return;
    }
    setState(() {
      if (index >= 0) {
        _selected.removeAt(index);
      } else {
        _selected.add(asset);
      }
    });
  }

  Future<void> _finish() async {
    if (_selected.isEmpty || _finishing) return;
    setState(() => _finishing = true);
    try {
      final result = <SelectedMediaFile>[];
      for (final asset in _selected) {
        final File? file = await asset.file;
        if (file == null) throw StateError('无法读取所选素材');
        result.add(
          SelectedMediaFile(
            path: file.path,
            type: asset.type == AssetType.video
                ? SelectedMediaType.video
                : SelectedMediaType.image,
          ),
        );
      }
      if (mounted) Navigator.pop(context, result);
    } catch (_) {
      if (mounted) _toast('部分素材读取失败，请重新选择');
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(child: _buildBody()),
            if (_selected.isNotEmpty) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 30, color: Color(0xFF15151B)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '最近项目',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded, size: 25),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, size: 20),
                SizedBox(width: 5),
                Text(
                  '草稿箱',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['全部', '视频', '图片'];
    return Row(
      children: List.generate(labels.length, (index) {
        final tab = _MediaTab.values[index];
        final selected = tab == _tab;
        return Expanded(
          child: InkWell(
            onTap: () => setState(() => _tab = tab),
            child: SizedBox(
              height: 54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF181820)
                          : const Color(0xFF8A8A91),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 3,
                    color: selected
                        ? const Color(0xFF17171D)
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: PhotoManager.openSetting,
                child: const Text('前往设置'),
              ),
            ],
          ),
        ),
      );
    }
    final visible = _visibleAssets;
    if (visible.isEmpty) return const Center(child: Text('暂无可选素材'));
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: visible.length,
      itemBuilder: (_, index) => _MediaTile(
        asset: visible[index],
        selectionIndex: _selected.indexWhere(
          (item) => item.id == visible[index].id,
        ),
        onTap: () => _toggle(visible[index]),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEC))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selected.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) => _SelectedPreview(
                asset: _selected[index],
                order: index + 1,
                onRemove: () => _toggle(_selected[index]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _finishing ? null : _finish,
              style: FilledButton.styleFrom(
                backgroundColor: Palette.primary,
                disabledBackgroundColor: Palette.accent.withValues(alpha: 0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _finishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '下一步 (${_selected.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPreview extends StatelessWidget {
  const _SelectedPreview({
    required this.asset,
    required this.order,
    required this.onRemove,
  });

  final AssetEntity asset;
  final int order;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FutureBuilder<Uint8List?>(
                future: asset.thumbnailDataWithSize(
                  const ThumbnailSize.square(180),
                ),
                builder: (_, snapshot) => snapshot.hasData
                    ? Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : const ColoredBox(color: Color(0xFFE5E5E7)),
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              width: 21,
              height: 21,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Palette.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$order',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: -5,
            top: -1,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFF5C5C61),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.asset,
    required this.selectionIndex,
    required this.onTap,
  });

  final AssetEntity asset;
  final int selectionIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(
              const ThumbnailSize.square(420),
            ),
            builder: (_, snapshot) => snapshot.hasData
                ? Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : const ColoredBox(color: Color(0xFFE5E5E7)),
          ),
          if (selectionIndex >= 0)
            ColoredBox(color: Colors.black.withValues(alpha: 0.12)),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 27,
              height: 27,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectionIndex >= 0
                    ? Palette.primary
                    : Colors.black26,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: selectionIndex >= 0
                  ? Text(
                      '${selectionIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          ),
          if (asset.type == AssetType.video)
            Positioned(
              left: 7,
              bottom: 6,
              child: Row(
                children: [
                  const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                  Text(
                    _duration(asset.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _duration(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}
