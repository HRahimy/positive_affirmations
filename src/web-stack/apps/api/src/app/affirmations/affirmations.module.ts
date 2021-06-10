import { Module } from '@nestjs/common';
import { entities } from './entities';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [TypeOrmModule.forFeature([...entities])],
  controllers: [],
  providers: [],
})
export class AffirmationsModule {}
