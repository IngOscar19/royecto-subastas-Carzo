import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThanOrEqual, Repository } from 'typeorm';
import { Auction, AuctionStatus } from './auction.entity';
import { Bid } from '../bids/bid.entity';
import { User } from '../users/user.entity';
import { AuctionsGateway } from './auctions.gateway';
import { NotificationsService } from '../notifications/notifications.service';

interface WinnerRow {
  userId: string;
  userName: string;
  amount: string;
}

@Injectable()
export class AuctionsScheduler {
  private readonly logger = new Logger(AuctionsScheduler.name);

  constructor(
    @InjectRepository(Auction)
    private readonly auctionRepo: Repository<Auction>,
    @InjectRepository(Bid)
    private readonly bidRepo: Repository<Bid>,
    private readonly gateway: AuctionsGateway,
    private readonly notificationsService: NotificationsService,
  ) {}

  @Cron(CronExpression.EVERY_5_SECONDS)
  async closeExpiredAuctions(): Promise<void> {
    const now = new Date();
    const expired = await this.auctionRepo.findBy({
      status: AuctionStatus.ACTIVE,
      end_time: LessThanOrEqual(now),
    });

    for (const auction of expired) {
      await this.closeAuction(auction.id);
    }
  }

  @Cron(CronExpression.EVERY_5_SECONDS)
  async activateScheduledAuctions(): Promise<void> {
    const now = new Date();
    const ready = await this.auctionRepo.findBy({
      status: AuctionStatus.SCHEDULED,
      start_time: LessThanOrEqual(now),
    });

    for (const auction of ready) {
      auction.status = AuctionStatus.ACTIVE;
      await this.auctionRepo.save(auction);

      this.gateway.emitAuctionStarted(auction.id, {
        auctionId: auction.id,
        currentPrice: Number(auction.current_price),
        endTime: auction.end_time.getTime(),
      });

      this.logger.log(`Subasta ${auction.id} activada`);
    }
  }

  private async closeAuction(auctionId: string): Promise<void> {
    const result = await this.auctionRepo.manager.transaction(
      async (manager) => {
        const auction = await manager.findOne(Auction, {
          where: { id: auctionId },
          lock: { mode: 'pessimistic_write' },
        });

        if (!auction || auction.status !== AuctionStatus.ACTIVE) {
          return null;
        }

        const winner = await manager
          .createQueryBuilder(Bid, 'bid')
          .leftJoin(User, 'user', 'user.id = bid.userId')
          .select([
            'bid.userId AS "userId"',
            'user.name AS "userName"',
            'bid.amount AS "amount"',
          ])
          .where('bid.auctionId = :auctionId', { auctionId })
          .orderBy('bid.amount', 'DESC')
          .getRawOne<WinnerRow>();

        auction.status = AuctionStatus.CLOSED;
        auction.winnerId = winner?.userId ?? null;
        await manager.save(auction);

        return {
          winnerId: winner?.userId ?? null,
          winnerName: winner?.userName ?? null,
          finalPrice: Number(auction.current_price),
        };
      },
    );

    if (result) {
      this.gateway.emitAuctionClosed(auctionId, result);
      if (result.winnerId && result.winnerName) {
        void this.notificationsService.enqueueWonNotification({
          auctionId,
          winnerId: result.winnerId,
          winnerName: result.winnerName,
          finalPrice: result.finalPrice,
        });
      }
      this.logger.log(
        `Subasta ${auctionId} cerrada (winner: ${result.winnerId ?? 'ninguno'})`,
      );
    }
  }
}
