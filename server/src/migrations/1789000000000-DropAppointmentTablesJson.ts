import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * 删除 appointments.tables JSON 列。
 * 前置：AddAppointmentTables1788500000000 已建关联表并回填历史数据，
 * 且服务端已切换为从 appointment_tables 派生（实体 @VirtualColumn 同名兼容 API）。
 * down 时重建列并从关联表聚合回填（仅 id，保底可恢复）。
 */
export class DropAppointmentTablesJson1789000000000 implements MigrationInterface {
  name = 'DropAppointmentTablesJson1789000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const rows = (await queryRunner.query(
      `SELECT 1 FROM information_schema.columns
       WHERE table_schema = DATABASE() AND table_name = 'appointments' AND column_name = 'tables'
       LIMIT 1`,
    )) as unknown as Array<Record<string, unknown>>;
    if (rows.length) {
      await queryRunner.query(
        'ALTER TABLE `appointments` DROP COLUMN `tables`',
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE `appointments` ADD COLUMN `tables` json NULL',
    );
    await queryRunner.query(`
      UPDATE \`appointments\` a
      LEFT JOIN (
        SELECT appointmentId, JSON_ARRAYAGG(JSON_OBJECT('id', tableId)) AS j
        FROM appointment_tables
        GROUP BY appointmentId
      ) x ON x.appointmentId = a.id
      SET a.tables = x.j
    `);
  }
}
