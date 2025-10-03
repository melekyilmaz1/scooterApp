// src/scooters/scooters.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScootersController } from './scooters.controller';
import { ScootersService } from './scooters.service';
import { Scooter } from './scooter.entity'; 

@Module({
  imports: [TypeOrmModule.forFeature([Scooter])],
  controllers: [ScootersController],
  providers: [ScootersService],
  exports: [ScootersService],
})
export class ScootersModule {}
