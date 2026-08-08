import {
  Body,
  Controller,
  DefaultValuePipe,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../stores/admin.guard';
import { CommunityService } from './community.service';
import { UpdatePostStatusDto } from './post.dto';

/** 管理端：社区管理 */
@Controller('admin/posts')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminPostsController {
  constructor(private readonly community: CommunityService) {}

  /** 全量作品列表（可按状态筛选） */
  @Get()
  findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('status') status?: string,
  ) {
    return this.community.findAll(status, page);
  }

  /** 审核作品（通过/驳回） */
  @Patch(':id/status')
  updateStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdatePostStatusDto,
  ) {
    return this.community.updateStatus(id, dto);
  }

  /** 下架作品 */
  @Patch(':id/remove')
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.community.remove(id);
    return { removed: true };
  }

  /** 物理删除作品（含关联互动数据） */
  @Delete(':id')
  async hardDelete(@Param('id', ParseIntPipe) id: number) {
    await this.community.hardDelete(id);
    return { deleted: true };
  }
}
