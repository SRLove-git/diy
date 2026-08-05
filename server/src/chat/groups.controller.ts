import {
  Body,
  Controller,
  DefaultValuePipe,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import type { AuthUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ChatGateway } from './chat.gateway';
import { CreateGroupDto, MarkGroupReadDto, SendGroupMessageDto } from './group.dto';
import { GroupsService } from './groups.service';
import type { MessageContentType } from './chat.service';

/** 客户端：群聊（建群 / 群列表 / 群消息 / 已读 / 成员） */
@Controller('groups')
@UseGuards(JwtAuthGuard)
export class GroupsController {
  constructor(
    private readonly groups: GroupsService,
    private readonly gateway: ChatGateway,
  ) {}

  /** 创建群聊（成员仅限有效用户，本人自动加入） */
  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateGroupDto) {
    return this.groups.create(user.id, dto.name, dto.memberIds);
  }

  /** 我的群列表（含最后一条预览 / 未读数 / 成员头像） */
  @Get()
  mine(
    @CurrentUser() user: AuthUser,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
  ) {
    return this.groups.myGroups(user.id, Math.max(1, page));
  }

  /** 群成员 */
  @Get(':id/members')
  members(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.groups.listMembers(id, user.id);
  }

  /** 群历史消息（游标分页） */
  @Get(':id/messages')
  messages(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseIntPipe) id: number,
    @Query('cursor', new DefaultValuePipe(0), ParseIntPipe) cursor: number,
    @Query('limit', new DefaultValuePipe(50), ParseIntPipe) limit: number,
  ) {
    return this.groups.getMessages(user.id, id, Math.max(0, cursor), limit);
  }

  /** 发群消息（REST 兜底，实时推送由 Gateway 负责） */
  @Post(':id/messages')
  async send(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: SendGroupMessageDto,
  ) {
    const type: MessageContentType =
      dto.contentType === 'image'
        ? 'image'
        : dto.contentType === 'voice'
          ? 'voice'
          : 'text';
    const { message, memberIds } = await this.groups.sendMessage(
      user.id,
      id,
      type,
      dto.content,
    );
    await this.gateway.broadcastGroupMessage(
      message as unknown as Record<string, unknown>,
      memberIds,
      id,
    );
    return message;
  }

  /** 标记已读 */
  @Post(':id/read')
  read(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: MarkGroupReadDto,
  ) {
    return this.groups.markRead(user.id, id, dto.lastMessageId);
  }
}
