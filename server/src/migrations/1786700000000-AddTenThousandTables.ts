import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * IDOL BEADS 门店大规模扩桌：新增 10,000 张桌，支撑高并发压测与超大客流。
 *
 * 命名延续字母+数字风格，分 10 组 × 1000 张：
 * - H1~H1000、I1~I1000、J1~J1000：1 人桌（3000 张）
 * - K1~K1000、L1~L1000、M1~M1000、N1~N1000：2 人桌（4000 张）
 * - O1~O1000、P1~P1000、Q1~Q1000：4 人桌（3000 张）
 *
 * 使用递归 CTE 生成 1~1000 序号，单条 INSERT...SELECT 批量写入；
 * 按 (storeId, name) 防重复，可安全重跑。
 * 注意：MySQL 要求 WITH RECURSIVE 位于 INSERT 之后（INSERT ... WITH ... SELECT）。
 */
export class AddTenThousandTables1786700000000 implements MigrationInterface {
  name = 'AddTenThousandTables1786700000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // 先建 (storeId, name) 索引：NOT EXISTS 才能走索引，避免 1 万行逐行全表扫
    await queryRunner.query(
      `CREATE INDEX \`IDX_store_tables_store_name\` ON \`store_tables\` (\`storeId\`, \`name\`)`,
    );
    await queryRunner.query(`
      INSERT INTO \`store_tables\`
        (\`storeId\`, \`name\`, \`capacity\`, \`enabled\`, \`createdAt\`, \`updatedAt\`)
      WITH RECURSIVE seq AS (
        SELECT 1 AS i
        UNION ALL
        SELECT i + 1 FROM seq WHERE i < 1000
      )
      SELECT s.\`id\`, CONCAT(spec.\`prefix\`, seq.i), spec.\`capacity\`, 1, NOW(6), NOW(6)
      FROM \`stores\` s
      JOIN (
        SELECT 'H' AS \`prefix\`, 1 AS \`capacity\`
        UNION ALL SELECT 'I', 1
        UNION ALL SELECT 'J', 1
        UNION ALL SELECT 'K', 2
        UNION ALL SELECT 'L', 2
        UNION ALL SELECT 'M', 2
        UNION ALL SELECT 'N', 2
        UNION ALL SELECT 'O', 4
        UNION ALL SELECT 'P', 4
        UNION ALL SELECT 'Q', 4
      ) spec
      JOIN seq ON seq.i <= 1000
      WHERE s.\`name\` = 'IDOL BEADS'
        AND NOT EXISTS (
          SELECT 1 FROM \`store_tables\` st
          WHERE st.\`storeId\` = s.\`id\` AND st.\`name\` = CONCAT(spec.\`prefix\`, seq.i)
        )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX \`IDX_store_tables_store_name\` ON \`store_tables\``,
    );
    await queryRunner.query(
      `DELETE st FROM \`store_tables\` st
       JOIN \`stores\` s ON st.\`storeId\` = s.\`id\`
       WHERE s.\`name\` = 'IDOL BEADS'
         AND st.\`name\` REGEXP '^[H-Q][0-9]+$'`,
    );
  }
}
