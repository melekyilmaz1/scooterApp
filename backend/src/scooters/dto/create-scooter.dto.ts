// src/scooters/dto/create-scooter.dto.ts
import { IsNotEmpty, IsNumber, IsString } from 'class-validator';

export class CreateScooterDto {
  @IsNotEmpty()
  @IsNumber()
  latitude: number;

  @IsNotEmpty()
  @IsNumber()
  longitude: number;

  @IsNotEmpty()
  @IsString()
  unique_name: string;

  @IsNotEmpty()
  @IsNumber()
  battery_status: number;
}