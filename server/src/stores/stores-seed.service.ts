import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Store } from './store.entity';
import { StoreTable } from './store-table.entity';
import { TimeSlot } from './time-slot.entity';

/**
 * 基础数据自动补种：
 * 门店存在但未配置桌位/时段时，插入默认桌位与可约时段，
 * 避免新部署环境预约流程因空表而不可用（issue #9 / #17）。
 */
@Injectable()
export class StoresSeedService implements OnApplicationBootstrap {
  private readonly logger = new Logger('StoresSeed');

  constructor(
    @InjectRepository(Store) private readonly stores: Repository<Store>,
    @InjectRepository(StoreTable)
    private readonly tables: Repository<StoreTable>,
    @InjectRepository(TimeSlot)
    private readonly slots: Repository<TimeSlot>,
  ) {}

  async onApplicationBootstrap() {
    try {
      const stores = await this.stores.find();
      if (!stores.length) return; // 无门店时不补种

      let fixed = 0;
      for (const store of stores) {
        const [tableCount, slotCount] = await Promise.all([
          this.tables.countBy({ storeId: store.id }),
          this.slots.countBy({ storeId: store.id }),
        ]);

        if (tableCount === 0) {
          await this.tables.save([
            this.tables.create({ storeId: store.id, name: 'A1', capacity: 2 }),
            this.tables.create({ storeId: store.id, name: 'A2', capacity: 2 }),
            this.tables.create({ storeId: store.id, name: 'B1', capacity: 4 }),
            this.tables.create({ storeId: store.id, name: 'B2', capacity: 4 }),
          ]);
          fixed++;
        }

        if (slotCount === 0) {
          await this.slots.save([
            this.slots.create({ storeId: store.id, startTime: '09:00', endTime: '10:30' }),
            this.slots.create({ storeId: store.id, startTime: '10:30', endTime: '12:00' }),
            this.slots.create({ storeId: store.id, startTime: '13:00', endTime: '14:30' }),
            this.slots.create({ storeId: store.id, startTime: '14:30', endTime: '16:00' }),
            this.slots.create({ storeId: store.id, startTime: '16:00', endTime: '17:30' }),
            this.slots.create({ storeId: store.id, startTime: '19:00', endTime: '20:30' }),
            this.slots.create({ storeId: store.id, startTime: '20:30', endTime: '22:00' }),
          ]);
          fixed++;
        }
      }

      if (fixed > 0) {
        this.logger.log(`已为 ${stores.length} 家门店补种默认桌位/时段（修正 ${fixed} 项）`);
      }
    } catch (e) {
      this.logger.error(`补种失败: ${(e as Error).message}`);
    }
  }
}
