import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import type { SignOptions } from 'jsonwebtoken';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BidsModule } from '../bids/bids.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { SocketAuthMiddleware } from '../auth/socket-auth.middleware';
import { Auction } from './auction.entity';
import { AuctionsController } from './auctions.controller';
import { AuctionsGateway } from './auctions.gateway';
import { AuctionsService } from './auctions.service';
import { AuctionsScheduler } from './auctions.scheduler';
import { Bid } from '../bids/bid.entity';
import { User } from '../users/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Auction, Bid, User]),
    BidsModule,
    NotificationsModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>(
            'JWT_EXPIRES_IN',
            '7d',
          ) as SignOptions['expiresIn'],
        },
      }),
    }),
  ],
  controllers: [AuctionsController],
  providers: [
    AuctionsGateway,
    AuctionsService,
    AuctionsScheduler,
    SocketAuthMiddleware,
  ],
})
export class AuctionsModule {}
