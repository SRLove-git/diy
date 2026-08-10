import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../stores/admin.guard';
import { AddKeywordDto } from './moderation.dto';
import { ModerationService } from './moderation.service';

/** 管理端：内容审核关键词配置 */
@Controller('admin/moderation')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminModerationController {
  constructor(private readonly moderation: ModerationService) {}

  @Get('keywords')
  listKeywords() {
    return this.moderation.listKeywords();
  }

  @Post('keywords')
  addKeyword(@Body() dto: AddKeywordDto) {
    return this.moderation.addKeyword(dto.keyword);
  }

  @Delete('keywords/:keyword')
  removeKeyword(@Param('keyword') keyword: string) {
    return this.moderation.removeKeyword(keyword);
  }
}
