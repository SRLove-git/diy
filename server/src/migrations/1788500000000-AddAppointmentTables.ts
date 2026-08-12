import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * 预约-桌位关联表：把一单多桌关系从 appointments.tables JSON 列
 * 抽成 appointment_tables 关联表，替代查询里的 JSON_TABLE 展开。
 *
 * - (appointmentId, tableId) 唯一索引：一单同桌只记一次；
 * - (storeId, date, tableId) 复合索引：availability 与冲突校验一步收窄，
 *   storeId/date 冗余存储，无需回表 appointments 过滤。
 * - 历史数据回填：JSON 数组展开 + 单桌（JSON 为空时）回退 tableId。
 * - 只对 appointments 建外键（ON DELETE CASCADE）；不建 store_tables 外键，
 *   避免历史预约引用已删除桌位导致迁移失败，脏 tableId 不影响可用性查询。
 */
export class AddAppointmentTables1788500000000 implements MigrationInterface {
  name = 'AddAppointmentTables1788500000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`appointment_tables\` (
        \`id\` int NOT NULL AUTO_INCREMENT,
        \`appointmentId\` int NOT NULL,
        \`tableId\` int NOT NULL,
        \`storeId\` int NOT NULL,
        \`date\` varchar(10) NOT NULL,
        \`createdAt\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        PRIMARY KEY (\`id\`)
      ) ENGINE=InnoDB
    `);

    // 回填 1) 多桌预约：tables JSON 数组展开（DISTINCT 兜底重复桌位）
    await queryRunner.query(`
      INSERT IGNORE INTO \`appointment_tables\` (\`appointmentId\`, \`tableId\`, \`storeId\`, \`date\`)
      SELECT DISTINCT a.id, t.tid, a.storeId, a.date
      FROM \`appointments\` a
      JOIN JSON_TABLE(a.tables, '$[*]' COLUMNS (tid INT PATH '$.id')) t
        ON a.tables IS NOT NULL AND JSON_LENGTH(a.tables) > 0
      WHERE t.tid IS NOT NULL AND a.storeId IS NOT NULL
    `);

    // 回填 2) 单桌预约：tables JSON 为空/缺失时回退 tableId
    await queryRunner.query(`
      INSERT IGNORE INTO \`appointment_tables\` (\`appointmentId\`, \`tableId\`, \`storeId\`, \`date\`)
      SELECT a.id, a.tableId, a.storeId, a.date
      FROM \`appointments\` a
      WHERE a.tableId IS NOT NULL AND a.storeId IS NOT NULL
        AND (a.tables IS NULL OR JSON_LENGTH(a.tables) = 0)
    `);

    await this.ensureIndex(
      queryRunner,
      'IDX_appointment_tables_appointment_table',
      'CREATE UNIQUE INDEX `IDX_appointment_tables_appointment_table` ON `appointment_tables` (`appointmentId`, `tableId`)',
    );
    await this.ensureIndex(
      queryRunner,
      'IDX_appointment_tables_store_date_table',
      'CREATE INDEX `IDX_appointment_tables_store_date_table` ON `appointment_tables` (`storeId`, `date`, `tableId`)',
    );
    await this.ensureForeignKey(
      queryRunner,
      'FK_appointment_tables_appointment',
      'ALTER TABLE `appointment_tables` ADD CONSTRAINT `FK_appointment_tables_appointment` FOREIGN KEY (`appointmentId`) REFERENCES `appointments`(`id`) ON DELETE CASCADE',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner
      .query(
        'ALTER TABLE `appointment_tables` DROP FOREIGN KEY `FK_appointment_tables_appointment`',
      )
      .catch(() => undefined);
    await queryRunner.query('DROP TABLE IF EXISTS `appointment_tables`');
  }

  /** 索引不存在时才创建（information_schema 判存在，重复执行安全） */
  private async ensureIndex(
    queryRunner: QueryRunner,
    indexName: string,
    createSql: string,
  ): Promise<void> {
    const rows = (await queryRunner.query(
      `SELECT 1 FROM information_schema.statistics
       WHERE table_schema = DATABASE() AND table_name = 'appointment_tables' AND index_name = ?
       LIMIT 1`,
      [indexName],
    )) as unknown as Array<Record<string, unknown>>;
    if (!rows.length) {
      try {
        await queryRunner.query(createSql);
      } catch (e) {
        // 多副本首次启动可能并发执行同一迁移：索引已被另一副本创建
        const msg = String((e as { message?: string })?.message ?? e);
        if (!msg.includes('Duplicate key name')) throw e;
      }
    }
  }

  /** 外键不存在时才创建，多副本并发重复创建（ER_DUP_KEYNAME）视为成功 */
  private async ensureForeignKey(
    queryRunner: QueryRunner,
    constraintName: string,
    createSql: string,
  ): Promise<void> {
    const rows = (await queryRunner.query(
      `SELECT 1 FROM information_schema.table_constraints
       WHERE constraint_schema = DATABASE() AND constraint_name = ?
       LIMIT 1`,
      [constraintName],
    )) as unknown as Array<Record<string, unknown>>;
    if (!rows.length) {
      try {
        await queryRunner.query(createSql);
      } catch (e) {
        const msg = String((e as { message?: string })?.message ?? e);
        if (!msg.includes('Duplicate')) throw e;
      }
    }
  }
}
