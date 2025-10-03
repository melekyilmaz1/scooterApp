import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual } from 'typeorm';
import { Scooter } from './scooter.entity';
import { CreateScooterDto } from './dto/create-scooter.dto';

@Injectable()
export class ScootersService {
  constructor(
    @InjectRepository(Scooter)
    private scootersRepository: Repository<Scooter>,
  ) {}

  
  async create(createScooterDto: CreateScooterDto): Promise<Scooter> {
    console.log('🔍 Service - Gelen DTO:', createScooterDto);
    const newScooter = this.scootersRepository.create(createScooterDto);
    console.log('🔍 Service - Oluşturulan entity:', newScooter);
    return this.scootersRepository.save(newScooter);
  }

  
  async findAll(userRole: string): Promise<Scooter[]> {
    console.log('iOS uygulamasından gelen rol:', userRole);

    if (userRole === 'operator') {
      return this.scootersRepository.find();
    } else {
      return this.scootersRepository.find({
        where: {
          battery_status: MoreThanOrEqual(20),
        },
      });
    }
  }

  async delete(id: number): Promise<void> {
    await this.scootersRepository.delete(id);
  }
}
