import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Store } from '../stores/store.entity';
import { StoreTable } from '../stores/store-table.entity';
import { TimeSlot } from '../stores/time-slot.entity';
import { UsersModule } from '../users/users.module';
import { AdminAppointmentsController } from './admin-appointments.controller';
import { Appointment } from './appointment.entity';
import { AppointmentsController } from './appointments.controller';
import { AppointmentsService } from './appointments.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Appointment, Store, StoreTable, TimeSlot]),
    UsersModule,
  ],
  controllers: [AppointmentsController, AdminAppointmentsController],
  providers: [AppointmentsService],
})
export class AppointmentsModule {}
