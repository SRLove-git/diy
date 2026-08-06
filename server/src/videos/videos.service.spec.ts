import type { Repository } from 'typeorm';

import { Follow } from '../follows/follow.entity';
import { User } from '../users/user.entity';
import { VideoComment } from './video-comment.entity';
import { VideoHistory } from './video-history.entity';
import { VideoLike } from './video-like.entity';
import { Video } from './video.entity';
import { VideosService } from './videos.service';

describe('VideosService', () => {
  it('returns the author when a video is created', async () => {
    const savedVideo = {
      id: 42,
      userId: 7,
      title: '新作品',
      content: '',
      cover: '/uploads/post/cover.jpg',
      videoUrl: '/uploads/video/demo.mp4',
      photos: [],
      filter: '',
      trimStart: 0,
      trimEnd: 0,
      speed: 1,
      rotation: 0,
      duration: 15,
      aspectRatio: 0,
      music: '',
      tags: [],
      location: '',
      status: 'approved',
      rejectReason: '',
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
      viewCount: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    } as Video;

    const videos = {
      create: jest.fn().mockReturnValue(savedVideo),
      save: jest.fn().mockResolvedValue(savedVideo),
    } as unknown as Repository<Video>;
    const follows = {
      createQueryBuilder: jest.fn().mockReturnValue({
        select: jest.fn().mockReturnThis(),
        addSelect: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        groupBy: jest.fn().mockReturnThis(),
        getRawMany: jest.fn().mockResolvedValue([]),
      }),
    } as unknown as Repository<Follow>;
    const users = {
      find: jest
        .fn()
        .mockResolvedValue([
          { id: 7, nickname: '小木匠', avatar: '/uploads/avatar/me.jpg' },
        ]),
    } as unknown as Repository<User>;

    const service = new VideosService(
      videos,
      {} as Repository<VideoLike>,
      {} as Repository<VideoComment>,
      {} as Repository<VideoHistory>,
      follows,
      users,
    );

    const result = await service.create(7, { title: '新作品' });

    expect(result.author).toEqual({
      id: 7,
      nickname: '小木匠',
      avatar: '/uploads/avatar/me.jpg',
      followCount: 0,
    });
    expect(result.liked).toBe(false);
  });
});
