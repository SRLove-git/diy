import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Store } from './store.entity';
import { StoreTable } from './store-table.entity';
import { TimeSlot } from './time-slot.entity';
import {
  CreateSlotDto,
  CreateStoreDto,
  CreateTableDto,
  UpdateSlotDto,
  UpdateStoreDto,
  UpdateTableDto,
} from './store.dto';

@Injectable()
export class StoresService {
  constructor(
    @InjectRepository(Store) private readonly stores: Repository<Store>,
    @InjectRepository(StoreTable)
    private readonly tables: Repository<StoreTable>,
    @InjectRepository(TimeSlot)
    private readonly slots: Repository<TimeSlot>,
  ) {}

  // ===== 客户端（只读，仅 enabled） =====

  /** 附近可约门店列表（距离由客户端按经纬度计算） */
  listEnabled(): Promise<Store[]> {
    return this.stores.find({ where: { enabled: true }, order: { id: 'ASC' } });
  }

  async detail(id: number): Promise<Store | null> {
    const store = await this.stores.findOne({
      where: { id, enabled: true },
      relations: { tables: true, slots: true },
    });
    if (!store) return null;
    store.tables = store.tables.filter((t) => t.enabled);
    store.slots = store.slots.filter((s) => s.enabled);
    return store;
  }

  // ===== 管理端（含 CRUD） =====

  adminList(): Promise<Store[]> {
    return this.stores.find({
      relations: { tables: true, slots: true },
      order: { id: 'DESC' },
    });
  }

  async adminDetail(id: number): Promise<Store> {
    const store = await this.stores.findOne({
      where: { id },
      relations: { tables: true, slots: true },
    });
    if (!store) throw new NotFoundException('门店不存在');
    return store;
  }

  create(dto: CreateStoreDto): Promise<Store> {
    return this.stores.save(
      this.stores.create({ ...dto, images: dto.images ?? [] }),
    );
  }

  async update(id: number, dto: UpdateStoreDto): Promise<Store> {
    const store = await this.adminDetail(id);
    Object.assign(store, dto);
    return this.stores.save(store);
  }

  async remove(id: number) {
    const store = await this.adminDetail(id);
    await this.stores.remove(store);
  }

  async addTable(storeId: number, dto: CreateTableDto): Promise<StoreTable> {
    await this.adminDetail(storeId);
    return this.tables.save(this.tables.create({ storeId, ...dto }));
  }

  async updateTable(id: number, dto: UpdateTableDto): Promise<StoreTable> {
    const table = await this.tables.findOneBy({ id });
    if (!table) throw new NotFoundException('桌位不存在');
    Object.assign(table, dto);
    return this.tables.save(table);
  }

  async removeTable(id: number) {
    const table = await this.tables.findOneBy({ id });
    if (!table) throw new NotFoundException('桌位不存在');
    await this.tables.remove(table);
  }

  async addSlot(storeId: number, dto: CreateSlotDto): Promise<TimeSlot> {
    await this.adminDetail(storeId);
    return this.slots.save(this.slots.create({ storeId, ...dto }));
  }

  async updateSlot(id: number, dto: UpdateSlotDto): Promise<TimeSlot> {
    const slot = await this.slots.findOneBy({ id });
    if (!slot) throw new NotFoundException('时段不存在');
    Object.assign(slot, dto);
    return this.slots.save(slot);
  }

  async removeSlot(id: number) {
    const slot = await this.slots.findOneBy({ id });
    if (!slot) throw new NotFoundException('时段不存在');
    await this.slots.remove(slot);
  }
}
