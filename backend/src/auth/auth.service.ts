// src/auth/auth.service.ts
import { BadRequestException, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { User } from '../users/users.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService, 
    private readonly jwtService: JwtService,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async register(username: string, password_plain: string) {
    const existingUser = await this.userRepository.findOne({ where: { username } });
    if (existingUser) {
      throw new BadRequestException('Bu kullanıcı adı zaten kullanılıyor.');
    }

    const salt = await bcrypt.genSalt();
    const password_hash = await bcrypt.hash(password_plain, salt);

    const newUser = this.userRepository.create({
      username,
      password: password_hash,
      role: 'user',
    });

    await this.userRepository.save(newUser);
    return { message: 'Kullanıcı başarıyla kaydedildi.' };
  }

  async login(username: string, password_plain: string) {
    const user = await this.userRepository.findOne({ where: { username } });
    if (!user) {
      throw new BadRequestException('Kullanıcı adı veya şifre yanlış.');
    }

    const isMatch = await bcrypt.compare(password_plain, user.password);
    if (!isMatch) {
      throw new BadRequestException('Kullanıcı adı veya şifre yanlış.');
    }

    const payload = { username: user.username, sub: user.id };
    
    const token = await this.jwtService.signAsync(payload)
    console.log(token)
    return { 
      access_token: token,
      user: {
        username: user.username,
        role: user.role
      }
    };
  }
}
