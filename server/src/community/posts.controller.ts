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
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { AuthUser } from '../auth/current-user.decorator';
import { CreatePostDto } from './post.dto';
import { CommunityService } from './community.service';

/** 客户端：社区作品（发布/列表/详情） */
@Controller('posts')
export class PostsController {
  constructor(private readonly community: CommunityService) {}

  /** 发布作品 */
  @Post()
  @UseGuards(JwtAuthGuard)
  create(@CurrentUser() user: AuthUser, @Body() dto: CreatePostDto) {
    return this.community.create(user.id, dto);
  }

  /** 最新信息流（仅展示已通过审核的作品） */
  @Get()
  latest(@Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number) {
    return this.community.listLatest(page);
  }

  /** 热门信息流 */
  @Get('hot')
  hot(@Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number) {
    return this.community.listHot(page);
  }

  /** 我的作品列表 */
  @Get('mine')
  @UseGuards(JwtAuthGuard)
  myPosts(
    @CurrentUser() user: AuthUser,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
  ) {
    return this.community.myPosts(user.id, page);
  }

  /** 作品详情 */
  @Get(':id')
  detail(@Param('id', ParseIntPipe) id: number) {
    return this.community.detail(id);
  }
}
