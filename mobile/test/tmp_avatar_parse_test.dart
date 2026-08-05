import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:diy_mobile/pages/short_video_models.dart';

void main() {
  test('parse create response with author avatar', () async {
    await dotenv.load();
    final json = {
      "id": 54,
      "userId": 3,
      "title": "t",
      "content": "c",
      "cover": "",
      "videoUrl": "/uploads/video/2026/08/x.mp4",
      "photos": [],
      "filter": "",
      "trimStart": 0,
      "trimEnd": 0,
      "speed": 1,
      "rotation": 0,
      "duration": 3,
      "aspectRatio": 0,
      "music": "",
      "tags": [],
      "location": "",
      "status": "approved",
      "rejectReason": "",
      "likeCount": 0,
      "commentCount": 0,
      "shareCount": 0,
      "viewCount": 0,
      "createdAt": "2026-08-05T04:49:20.545Z",
      "updatedAt": "2026-08-05T04:49:20.545Z",
      "author": {"id": 3, "nickname": "", "avatar": "/uploads/avatar/2026/08/1d1bc4a7-626c-4833-b45b-3af1d0603c87.jpg", "followCount": 0},
      "liked": false
    };
    final v = ShortVideo.fromServerJson(json);
    print('avatar=${v.avatar}');
    expect(v.avatar, contains('/uploads/avatar/'));
  });
}
