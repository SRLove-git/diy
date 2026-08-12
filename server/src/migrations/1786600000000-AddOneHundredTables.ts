import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * IDOL BEADS 门店扩桌：新增 100 张桌（压测发现 6 张桌在高并发预约时全部被占满，
 * 时段冲突率接近 100%，导致核销链路无法充分覆盖）。
 *
 * 命名延续现有 A/B/C 风格，按容量分 4 组：
 * - D1~D25：1 人桌（25 张）
 * - E1~E25：2 人桌（25 张）
 * - F1~F25：2 人桌（25 张）
 * - G1~G25：4 人桌（25 张）
 * 每张桌按 (storeId, name) 防重复，可安全重跑。
 */
export class AddOneHundredTables1786600000000 implements MigrationInterface {
  name = 'AddOneHundredTables1786600000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const groups = [
      { prefix: 'D', capacity: 1, count: 25 },
      { prefix: 'E', capacity: 2, count: 25 },
      { prefix: 'F', capacity: 2, count: 25 },
      { prefix: 'G', capacity: 4, count: 25 },
    ];

    for (const g of groups) {
      for (let i = 1; i <= g.count; i++) {
        const name = `${g.prefix}${i}`;
        await queryRunner.query(
          `INSERT INTO \`store_tables\`
             (\`storeId\`, \`name\`, \`capacity\`, \`enabled\`, \`createdAt\`, \`updatedAt\`)
           SELECT s.\`id\`, ?, ?, 1, NOW(6), NOW(6)
           FROM \`stores\` s
           WHERE s.\`name\` = 'IDOL BEADS'
             AND NOT EXISTS (
               SELECT 1 FROM \`store_tables\` st
               WHERE st.\`storeId\` = s.\`id\` AND st.\`name\` = ?
             )`,
          [name, g.capacity, name],
        );
      }
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DELETE st FROM \`store_tables\` st
       JOIN \`stores\` s ON st.\`storeId\` = s.\`id\`
       WHERE s.\`name\` = 'IDOL BEADS'
         AND st.\`name\` REGEXP '^[D-G][0-9]+$'`,
    );
  }
}
