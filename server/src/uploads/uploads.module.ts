import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { UploadsController } from './uploads.controller';
import { createUploadProvider, UPLOAD_PROVIDER } from './uploads.provider';

@Module({
  controllers: [UploadsController],
  providers: [
    {
      provide: UPLOAD_PROVIDER,
      inject: [ConfigService],
      useFactory: createUploadProvider,
    },
  ],
})
export class UploadsModule {}
