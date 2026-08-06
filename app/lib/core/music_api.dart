import 'api_client.dart';

/// 曲库条目
class MusicItem {
  const MusicItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.cover,
    required this.musicUrl,
    required this.duration,
  });

  final int id;
  final String title;
  final String artist;
  final String cover;
  final String musicUrl;
  final int duration;

  factory MusicItem.fromServerJson(Map<String, dynamic> json) => MusicItem(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        artist: (json['artist'] ?? '') as String,
        cover: (json['cover'] ?? '') as String,
        musicUrl: (json['musicUrl'] ?? '') as String,
        duration: ((json['duration'] ?? 0) as num).toInt(),
      );

  /// 列表展示名：歌名 - 歌手
  String get display => artist.isEmpty ? title : '$title · $artist';
}

/// 曲库 REST API（对应服务端 music 模块，拍摄页选择配乐）
class MusicApi {
  MusicApi._();

  /// 曲库列表（歌名/歌手模糊搜索）
  static Future<List<MusicItem>> list({String? keyword, int page = 1}) async {
    final resp = await ApiClient.instance.get(
      '/musics',
      queryParameters: {
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'page': page,
      },
    );
    return ((resp.data[0] ?? []) as List)
        .map((e) => MusicItem.fromServerJson(e as Map<String, dynamic>))
        .toList();
  }
}
