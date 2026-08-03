import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from '../users/users.module';
import { AdminGuard } from './admin.guard';
import { AdminStoresController } from './admin-stores.controller';
import { Store } from './store.entity';
import { StoreTable } from './store-table.entity';
import { StoresController } from './stores.controller';
import { StoresService } from './stores.service';
import { StoresSeedService } from './stores-seed.service';
import { TimeSlot } from './time-slot.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Store, StoreTable, TimeSlot]),
    UsersModule,
  ],
  controllers: [StoresController, AdminStoresController],
  providers: [StoresService, AdminGuard, StoresSeedService],
  exports: [StoresService],
})
export class StoresModule {}
