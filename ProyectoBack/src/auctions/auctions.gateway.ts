import { Inject, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import {
  ConnectedSocket,
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import type { Server, Socket } from 'socket.io';
import { Repository } from 'typeorm';
import Redis from 'ioredis';
import { REDIS_CLIENT } from '../redis/redis.module';
import {
  SocketAuthMiddleware,
  SocketUser,
} from '../auth/socket-auth.middleware';
import { BidsService, PlaceBidResult } from '../bids/bids.service';
import { NotificationsService } from '../notifications/notifications.service';
import { Auction } from './auction.entity';
import { Bid } from '../bids/bid.entity';
import { User } from '../users/user.entity';
import { JoinAuctionDto } from './dto/join-auction.dto';
import { PlaceBidDto } from './dto/place-bid.dto';

const AUCTION_STATE_TTL = 300;

interface AuctionStateCache {
  currentPrice: number;
  endTime: number;
}

interface BidRow {
  bidId: string;
  userId: string;
  userName: string;
  amount: string;
  createdAt: string | Date;
}

function stateKey(auctionId: string): string {
  return `auction:${auctionId}:state`;
}

@WebSocketGateway()
@Injectable()
export class AuctionsGateway {
  @WebSocketServer()
  server: Server;

  constructor(
    @InjectRepository(Auction)
    private readonly auctionRepo: Repository<Auction>,
    @InjectRepository(Bid)
    private readonly bidRepo: Repository<Bid>,
    @Inject(REDIS_CLIENT)
    private readonly redis: Redis,
    private readonly bidsService: BidsService,
    private readonly socketAuthMiddleware: SocketAuthMiddleware,
    private readonly notificationsService: NotificationsService,
  ) {}

  afterInit(server: Server): void {
    this.socketAuthMiddleware.register(server);
  }

  private getSocketUser(client: Socket): SocketUser | undefined {
    const data = client.data as { user?: SocketUser } | undefined;
    return data?.user;
  }

  @SubscribeMessage('join_auction')
  async handleJoinAuction(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: JoinAuctionDto,
  ): Promise<void> {
    const auctionId = payload?.auctionId;

    if (!auctionId || typeof auctionId !== 'string') {
      client.emit('auction_error', { message: 'auctionId is required' });
      return;
    }

    let auction: Auction | null;
    try {
      auction = await this.auctionRepo.findOneBy({ id: auctionId });
    } catch {
      client.emit('auction_error', { message: 'Failed to load auction' });
      return;
    }

    if (!auction) {
      client.emit('auction_error', { message: 'Auction not found' });
      return;
    }

    void client.join(auctionId);

    const { currentPrice, endTime } = await this.readAuctionState(auction);
    const lastBids = await this.readLastBids(auctionId);

    client.emit('auction_snapshot', {
      auctionId: auction.id,
      currentPrice,
      endTime,
      lastBids,
      status: auction.status,
    });
  }

  @SubscribeMessage('place_bid')
  async handlePlaceBid(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: PlaceBidDto,
  ): Promise<void> {
    const user = this.getSocketUser(client);
    if (!user?.userId) {
      client.emit('auction_error', { message: 'Not authenticated' });
      return;
    }

    const auctionId = payload?.auctionId;
    const amount = payload?.amount;

    if (
      typeof auctionId !== 'string' ||
      !auctionId ||
      typeof amount !== 'number' ||
      !Number.isFinite(amount) ||
      amount <= 0
    ) {
      client.emit('auction_error', { message: 'Invalid bid payload' });
      return;
    }

    let result: PlaceBidResult;
    try {
      result = await this.bidsService.placeBid(auctionId, amount, user);
    } catch {
      client.emit('auction_error', { message: 'Failed to place bid' });
      return;
    }

    if (!result.ok) {
      client.emit('bid_rejected', {
        reason: result.reason,
        currentPrice: result.currentPrice,
      });
      return;
    }

    try {
      await this.redis.set(
        stateKey(auctionId),
        JSON.stringify({
          currentPrice: result.currentPrice,
          endTime: result.endTime,
        }),
        'EX',
        AUCTION_STATE_TTL,
      );
    } catch {
      // Redis caído: el estado se sirve desde Postgres igualmente
    }

    if (result.newEndTime !== null) {
      this.server.emit('time_extended', {
        auctionId,
        newEndTime: result.newEndTime,
      });
    }

    this.server.emit('new_bid', {
      auctionId,
      bidId: result.bidId,
      userId: result.userId,
      userName: result.userName,
      amount: result.amount,
      createdAt: result.createdAt,
    });

    if (result.previousTopBidderId) {
      void this.notificationsService.enqueueOutbidNotification({
        auctionId,
        outbidUserId: result.previousTopBidderId,
        newBidderId: result.userId,
        newBidderName: result.userName,
        amount: result.amount,
      });

      this.server
        .to(`user:${result.previousTopBidderId}`)
        .emit('outbid_notification', {
          auctionId,
          amount: result.amount,
          newBidderName: result.userName,
          message: `¡Tu oferta en la subasta ha sido superada por ${result.userName} ($${result.amount})!`,
        });
    }
  }

  async emitAuctionClosed(
    auctionId: string,
    payload: {
      winnerId: string | null;
      winnerName: string | null;
      finalPrice: number;
    },
  ): Promise<void> {
    try {
      await this.redis.del(stateKey(auctionId));
    } catch (_) {}

    if (this.server) {
      this.server.emit('auction_closed', { ...payload, auctionId });
    }
  }

  emitNewBid(
    auctionId: string,
    payload: {
      bidId: string;
      userId: string;
      userName: string;
      amount: number;
      createdAt: string;
    },
  ): void {
    if (this.server) {
      this.server.emit('new_bid', { ...payload, auctionId });
    }
  }

  emitAuctionStarted(
    auctionId: string,
    payload: { auctionId: string; currentPrice: number; endTime: number },
  ): void {
    if (this.server) {
      this.server.emit('auction_started', payload);
    }
  }

  private async readAuctionState(
    auction: Auction,
  ): Promise<{ currentPrice: number; endTime: number }> {
    const key = stateKey(auction.id);

    try {
      const raw = await this.redis.get(key);
      if (raw) {
        const parsed = JSON.parse(raw) as Partial<AuctionStateCache>;
        if (
          typeof parsed.currentPrice === 'number' &&
          typeof parsed.endTime === 'number'
        ) {
          return {
            currentPrice: parsed.currentPrice,
            endTime: parsed.endTime,
          };
        }
      }
    } catch {
      // cache corrupto o Redis caído: cae a Postgres
    }

    const state = {
      currentPrice: auction.current_price,
      endTime: auction.end_time.getTime(),
    };

    try {
      await this.redis.set(key, JSON.stringify(state), 'EX', AUCTION_STATE_TTL);
    } catch {
      // Redis caído: no cachear, servir desde Postgres igualmente
    }

    return state;
  }

  private async readLastBids(auctionId: string): Promise<
    {
      bidId: string;
      userId: string;
      userName: string;
      amount: number;
      createdAt: string;
    }[]
  > {
    const rows = await this.bidRepo
      .createQueryBuilder('bid')
      .leftJoin(User, 'user', 'user.id = bid.userId')
      .select([
        'bid.id AS "bidId"',
        'bid.userId AS "userId"',
        'user.name AS "userName"',
        'bid.amount AS "amount"',
        'bid.createdAt AS "createdAt"',
      ])
      .where('bid.auctionId = :auctionId', { auctionId })
      .orderBy('bid.createdAt', 'DESC')
      .limit(20)
      .getRawMany<BidRow>();

    return rows.map((row) => ({
      bidId: row.bidId,
      userId: row.userId,
      userName: row.userName,
      amount: Number(row.amount),
      createdAt:
        row.createdAt instanceof Date
          ? row.createdAt.toISOString()
          : row.createdAt,
    }));
  }
}
