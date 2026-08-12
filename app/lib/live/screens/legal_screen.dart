import 'package:flutter/material.dart';

import '../live_theme.dart';
import '../live_widgets.dart';

/// 法律文档展示页（用户协议 / 隐私政策）。
///
/// [body] 为内置的轻量标记文本（见 legal_docs.dart）：
/// - `# ` / `## ` / `### ` 各级标题
/// - `- ` 无序列表、`1. ` 有序列表
/// - `> ` 版本说明等弱化行
/// - `---` 分隔线（忽略）
/// - `**` 加粗标记（剥离）
/// - 其余为普通段落
class LegalDocScreen extends StatelessWidget {
  const LegalDocScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  static const _bodyStyle = TextStyle(
    fontSize: 14,
    height: 1.7,
    color: LiveColors.textPrimary,
  );

  static const _bulletDotStyle = TextStyle(
    fontSize: 12,
    height: 1.7,
    color: LiveColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: Column(
        children: [
          LiveAppBar(title: title),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
              children: _buildBlocks(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBlocks() {
    final blocks = <Widget>[];
    for (final raw in body.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty || line.trim() == '---') continue;
      blocks.add(_block(line));
    }
    return blocks;
  }

  Widget _block(String line) {
    final t = line.trimLeft();
    if (t.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 14),
        child: Text(
          _plain(t.substring(2)),
          style: const TextStyle(
            fontSize: 21,
            height: 1.4,
            fontWeight: FontWeight.w800,
            color: LiveColors.textPrimary,
          ),
        ),
      );
    }
    if (t.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          _plain(t.substring(3)),
          style: const TextStyle(
            fontSize: 17,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: LiveColors.textPrimary,
          ),
        ),
      );
    }
    if (t.startsWith('### ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          _plain(t.substring(4)),
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: LiveColors.textPrimary,
          ),
        ),
      );
    }
    if (t.startsWith('> ')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          _plain(t.substring(2)),
          style: const TextStyle(
            fontSize: 12,
            height: 1.6,
            color: LiveColors.textTertiary,
          ),
        ),
      );
    }
    if (t.startsWith('- ')) {
      return Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text('•', style: _bulletDotStyle),
            ),
            Expanded(child: Text(_plain(t.substring(2)), style: _bodyStyle)),
          ],
        ),
      );
    }
    final numbered = RegExp(r'^(\d+)\.\s+').firstMatch(t);
    if (numbered != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '${numbered.group(1)}.',
                style: _bodyStyle.copyWith(color: LiveColors.textSecondary),
              ),
            ),
            Expanded(
              child: Text(_plain(t.substring(numbered.end)), style: _bodyStyle),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(_plain(t), style: _bodyStyle),
    );
  }

  /// 剥离 `**` 加粗标记（文档源以纯文本展示）。
  String _plain(String text) => text.replaceAll('**', '');
}
