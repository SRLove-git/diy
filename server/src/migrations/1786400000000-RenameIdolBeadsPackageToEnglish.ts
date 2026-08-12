import { MigrationInterface, QueryRunner } from 'typeorm';

/** 将 IDOL BEADS 门店时长套餐名称改为英文，与用户端英文界面一致 */
export class RenameIdolBeadsPackageToEnglish1786400000000 implements MigrationInterface {
  name = 'RenameIdolBeadsPackageToEnglish1786400000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `UPDATE \`store_packages\`
       SET \`name\` = '6-Hour Fun Package'
       WHERE \`name\` = '6小时畅玩套餐'`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `UPDATE \`store_packages\`
       SET \`name\` = '6小时畅玩套餐'
       WHERE \`name\` = '6-Hour Fun Package'`,
    );
  }
}
