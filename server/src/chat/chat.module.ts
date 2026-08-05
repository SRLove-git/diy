import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FollowsModule } from '../follows/follows.module';
import { User } from '../users/user.entity';
import { ChatController } from './chat.controller';
import { ChatGateway } from './chat.gateway';
import { ChatService } from './chat.service';
import { Conversation } from './conversation.entity';
import { Group } from './group.entity';
import { GroupMember } from './group-member.entity';
import { GroupMessage } from './group-message.entity';
import { GroupMessageDeletion } from './group-message-deletion.entity';
import { GroupRead } from './group-read.entity';
import { GroupsController } from './groups.controller';
import { GroupsService } from './groups.service';
import { Message } from './message.entity';
import { MessageStatus } from './message_status.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Conversation,
      Message,
      MessageStatus,
      Group,
      GroupMember,
      GroupMessage,
      GroupMessageDeletion,
      GroupRead,
      User,
    ]),
    FollowsModule,
  ],
  controllers: [ChatController, GroupsController],
  providers: [ChatService, GroupsService, ChatGateway],
  exports: [ChatService, GroupsService, ChatGateway],
})
export class ChatModule {}
