import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';

/**
 * 数据库迁移执行器（MySQL 命名锁版）。
 *
 * 生产使用 `--scale server=3` 多副本启动时，各副本会同时走到迁移逻辑；
 * 通过 MySQL 的 GET_LOCK / RELEASE_LOCK 命名锁串行化执行：
 * 拿到锁的副本执行全部未跑迁移，其余副本在锁上等待，拿到锁后发现迁移已记录，
 * 直接跳过。锁由独立连接持有，迁移本身走连接池，互不冲突。
 */
@Injectable()
export class MigrationsService implements OnApplicationBootstrap {
  private readonly logger = new Logger(MigrationsService.name);
  private static readonly LOCK_NAME = 'diy_migrations';
  /** 等待迁移锁的最长秒数：正常迁移在数分钟内完成，300s 足够兜底 */
  private static readonly LOCK_TIMEOUT_SECONDS = 300;

  constructor(
    private readonly dataSource: DataSource,
    private readonly config: ConfigService,
  ) {}

  async onApplicationBootstrap(): Promise<void> {
    if (this.config.get<string>('DB_MIGRATIONS_RUN') !== 'true') return;

    // 锁必须由独立连接持有：迁移执行走连接池，锁连接保持不动即可互斥
    const queryRunner = this.dataSource.createQueryRunner();
    try {
      await queryRunner.connect();
      const rows = (await queryRunner.query(
        'SELECT GET_LOCK(?, ?) AS acquired',
        [MigrationsService.LOCK_NAME, MigrationsService.LOCK_TIMEOUT_SECONDS],
      )) as Array<{ acquired: number }>;
      const acquired = Number(rows?.[0]?.acquired);
      if (acquired !== 1) {
        throw new Error(
          `获取数据库迁移锁失败（acquired=${acquired}）：可能是另一副本迁移超时或 MySQL 异常`,
        );
      }

      this.logger.log('开始执行数据库迁移（MySQL 命名锁已获取）');
      const executed = await this.dataSource.runMigrations();
      this.logger.log(
        executed.length > 0
          ? `数据库迁移完成，共执行 ${executed.length} 个迁移`
          : '数据库迁移检查完成，无待执行迁移',
      );
    } finally {
      await queryRunner
        .query('SELECT RELEASE_LOCK(?)', [MigrationsService.LOCK_NAME])
        .catch((e: unknown) =>
          this.logger.warn(
            `释放迁移锁失败（连接关闭后自动释放）: ${String(e)}`,
          ),
        );
      await queryRunner.release().catch(() => undefined);
    }
  }
}
