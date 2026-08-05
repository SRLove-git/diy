import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { UsersService } from '../users/users.service';
import { Follow } from './follow.entity';

/** 关注关系查询结果 */
export interface FollowStatus {
  user: { id: number; nickname: string; avatar: string };
  /** 我是否关注了对方 */
  following: boolean;
  /** 对方是否关注了我 */
  followedMe: boolean;
  /** 是否互相关注 */
  mutual: boolean;
  followerCount: number;
  followingCount: number;
}

@Injectable()
export class FollowsService {
  constructor(
    @InjectRepository(Follow)
    private readonly follows: Repository<Follow>,
    private readonly users: UsersService,
  ) {}

  /** 两人是否互相关注（聊天不受限的前置条件） */
  async isMutual(a: number, b: number): Promise<boolean> {
    if (a === b) return true;
    const rows = await this.follows.find({
      where: [
        { followerId: a, followeeId: b },
        { followerId: b, followeeId: a },
      ],
      select: { id: true },
    });
    return rows.length === 2;
  }

  /** 当前用户与目标用户的关注关系 + 目标粉丝/关注数 */
  async status(meId: number, targetId: number): Promise<FollowStatus> {
    const user = await this.users.findById(targetId);
    if (!user) throw new NotFoundException('用户不存在');

    const [following, followedMe] = await Promise.all([
      this.follows.existsBy({ followerId: meId, followeeId: targetId }),
      this.follows.existsBy({ followerId: targetId, followeeId: meId }),
    ]);
    const [followerCount, followingCount] = await Promise.all([
      this.follows.count({ where: { followeeId: targetId } }),
      this.follows.count({ where: { followerId: targetId } }),
    ]);
    return {
      user: { id: user.id, nickname: user.nickname, avatar: user.avatar },
      following,
      followedMe,
      mutual: following && followedMe,
      followerCount,
      followingCount,
    };
  }

  /** 我关注的人（发起群聊选人用） */
  async followingList(
    userId: number,
  ): Promise<Array<{ id: number; nickname: string; avatar: string }>> {
    const rows = await this.follows.find({
      where: { followerId: userId },
      order: { createdAt: 'DESC' },
    });
    const ids = rows.map((r) => r.followeeId);
    if (!ids.length) return [];
    const users = await this.users.findByIds(ids);
    return users.map((u) => ({
      id: u.id,
      nickname: u.nickname || `用户 #${u.id}`,
      avatar: u.avatar,
    }));
  }

  /** 设置关注/取消关注（幂等），返回最新状态 */
  async setFollow(
    meId: number,
    targetId: number,
    following: boolean,
  ): Promise<FollowStatus> {
    if (meId === targetId) throw new BadRequestException('不能关注自己');
    const user = await this.users.findById(targetId);
    if (!user) throw new NotFoundException('用户不存在');

    if (following) {
      try {
        await this.follows.insert({ followerId: meId, followeeId: targetId });
      } catch {
        // 已关注：唯一约束兜底，忽略重复插入
      }
    } else {
      await this.follows.delete({ followerId: meId, followeeId: targetId });
    }
    return this.status(meId, targetId);
  }
}
