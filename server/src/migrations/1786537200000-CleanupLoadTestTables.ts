import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * 清理压测遗留桌位：删除 IDOL BEADS 门店的压测假桌（D–V 前缀），
 * 保留真实默认桌位 A1/A2/B1/B2/C1/C2（共 6 张）。
 *
 * 背景：AddOneHundredTables / AddTenThousandTables / AddFiveThousandSeats
 * 三个压测迁移已从迁移链移除，但已在库中生成的假桌需要清理。
 * 本迁移按 (storeId, name) 前缀幂等匹配，可安全重跑；
 * 生产库删除前已备份至 store_tables_backup_loadtest_20260812，如需恢复可回插。
 */
export class CleanupLoadTestTables1786537200000
  implements MigrationInterface
{
  name = 'CleanupLoadTestTables1786537200000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DELETE st FROM \`store_tables\` st
      JOIN \`stores\` s ON st.\`storeId\` = s.\`id\`
      WHERE s.\`name\` = 'IDOL BEADS'
        AND st.\`name\` REGEXP '^[D-V][0-9]+$'
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // 被删桌位为一次性压测数据，无法在 down 中重建；
    // 如需恢复，可参考迁移注释中的备份表说明。
  }
}
