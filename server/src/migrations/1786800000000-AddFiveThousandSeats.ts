import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * IDOL BEADS 门店新增 5,000 个座位：按 5,000 张 1 人桌落地
 * （每张 capacity=1，即 1 桌 = 1 座位），命名延续字母+数字风格：
 * - R1~R1000、S1~S1000、T1~T1000、U1~U1000、V1~V1000（各 1000 张）
 *
 * 使用递归 CTE 生成序号，单条 INSERT...SELECT 批量写入；
 * 按 (storeId, name) 防重复，可安全重跑。
 */
export class AddFiveThousandSeats1786800000000 implements MigrationInterface {
  name = 'AddFiveThousandSeats1786800000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // 先建 (storeId, name) 索引：NOT EXISTS 才能走索引，避免 5 千行逐行全表扫
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
      SELECT s.\`id\`, CONCAT(spec.\`prefix\`, seq.i), 1, 1, NOW(6), NOW(6)
      FROM \`stores\` s
      JOIN (
        SELECT 'R' AS \`prefix\`
        UNION ALL SELECT 'S'
        UNION ALL SELECT 'T'
        UNION ALL SELECT 'U'
        UNION ALL SELECT 'V'
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
         AND st.\`name\` REGEXP '^[R-V][0-9]+$'`,
    );
  }
}
