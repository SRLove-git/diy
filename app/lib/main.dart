import 'package:flutter/material.dart';

import 'interactive/prototype_app.dart';
import 'screens_registry.dart';

void main() {
  runApp(const PrototypeApp());
}

class DiyUiApp extends StatelessWidget {
  const DiyUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '手作星球 · UI 预览',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111113),
      ),
      home: const GalleryPage(),
    );
  }
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = screenRegistry.entries.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('手作星球 · 82 屏设计预览'),
        backgroundColor: const Color(0xFF111113),
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.66,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final name = items[i].key;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PreviewPage(title: name, builder: items[i].value),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: Center(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PreviewPage extends StatelessWidget {
  final String title;
  final Widget Function() builder;

  const PreviewPage({super.key, required this.title, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SizedBox(
          width: title == '59-视频横屏全屏' ? 956 : 440,
          height: title == '59-视频横屏全屏' ? 440 : 956,
          child: ClipRect(child: builder()),
        ),
      ),
    );
  }
}
