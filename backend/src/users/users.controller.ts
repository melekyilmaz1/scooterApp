import { Controller, Post, Body, Get, Param, Put, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './users.dto';
import { AuthGuard } from '@nestjs/passport'; // AuthGuard'ı import etmeyi unutmayın

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('register')
  register(@Body() dto: CreateUserDto) {
    return this.usersService.create(dto);
  }

  @Get(':username')
  findOne(@Param('username') username: string) {
    return this.usersService.findOne(username);
  }

  // Yeni eklenecek metot: Kullanıcının rolünü güncelle
  // Bu endpoint'e sadece yetkili kullanıcılar (örneğin adminler) erişebilmeli.
  // Bu yüzden @UseGuards(AuthGuard('jwt')) ile korunuyor.
  @UseGuards(AuthGuard('jwt'))
  @Put(':username/role') // Örnek: PUT /users/operator_kullanici_adi/role
  async updateUserRole(
    @Param('username') username: string,
    @Body('role') role: string // İstek gövdesinden yeni rolü al
  ) {
    // Burada daha gelişmiş yetkilendirme kontrolleri de eklenebilir.
    // Örneğin, sadece "admin" rolüne sahip kullanıcıların bu işlemi yapabilmesi gibi.

    const updatedUser = await this.usersService.updateRole(username, role);
    if (!updatedUser) {
      // Kullanıcı bulunamazsa bir hata fırlatın (örn: throw new NotFoundException('Kullanıcı bulunamadı.');)
      return { message: 'Kullanıcı bulunamadı veya rol güncellenemedi.' };
    }
    return { message: `Kullanıcı ${username} rolü ${role} olarak güncellendi.`, user: updatedUser };
  }
}