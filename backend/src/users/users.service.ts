// src/users/users.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './users.entity';
import { CreateUserDto } from './users.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async create(userDto: CreateUserDto): Promise<User>;
  async create(userDto: CreateUserDto[]): Promise<User[]>;

  async create(userDto: CreateUserDto | CreateUserDto[]): Promise<User | User[]> {
    if (Array.isArray(userDto)) {
      const entities = this.usersRepository.create(userDto);
      return await this.usersRepository.save(entities);
    } else {
      const entity = this.usersRepository.create(userDto);
      return await this.usersRepository.save(entity);
    }
  }

  async findOne(username: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { username } });
  }

  // Yeni eklenecek metot: Kullanıcının rolünü güncelle
  async updateRole(username: string, newRole: string): Promise<User | null> {
    const user = await this.usersRepository.findOne({ where: { username } });
    if (user) {
      user.role = newRole; // Kullanıcının rolünü güncelle
      return await this.usersRepository.save(user); // Değişikliği veri tabanına kaydet
    }
    return null; // Kullanıcı bulunamazsa null dön
  }
}