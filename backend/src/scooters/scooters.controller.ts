// src/scooters/scooters.controller.ts

import { Controller, Get, Request, UseGuards, Post, Body, Delete, Param, ForbiddenException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ScootersService } from './scooters.service';
import { CreateScooterDto } from './dto/create-scooter.dto';

@Controller('scooters')
export class ScootersController {
  constructor(private readonly scootersService: ScootersService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get()
  async findAll(@Request() req) {
    const userRole = req.user.role;
    const scooters = await this.scootersService.findAll(userRole);
    return scooters;
  }

  @Post()
  async create(@Body() createScooterDto: any) {
    console.log('🔍 Debug - Gelen veri:', createScooterDto);
    try {
      const result = await this.scootersService.create(createScooterDto);
      console.log('✅ Scooter başarıyla eklendi:', result);
      return {
        message: 'Scooter başarıyla eklendi',
        data: result,
      };
    } catch (error) {
      console.error('❌ Scooter ekleme hatası:', error);
      return {
        message: 'Scooter eklenirken hata oluştu',
        error: error.message,
      };
    }
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete(':id')
  async remove(@Request() req, @Param('id') id: string) {
    if (req.user.role !== 'operator') {
      throw new ForbiddenException('Sadece operatörler silebilir');
    }
    await this.scootersService.delete(Number(id));
    return { message: 'Silindi' };
  }
}