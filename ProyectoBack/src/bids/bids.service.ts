import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Auction, AuctionStatus } from '../auctions/auction.entity';
import { UserRole } from '../users/user.entity';
import { Bid } from './bid.entity';
import { User } from '../users/user.entity';

const ANTI_SNIPING_WINDOW_MS = 30_000;

export type BidRejectReason =
  'amount_too_low' | 'auction_closed' | 'auction_not_active' | 'forbidden';

export interface PlaceBidSuccess {
  ok: true;
  bidId: string;
  userId: string;
  userName: string;
  amount: number;
  createdAt: string;
  currentPrice: number;
  endTime: number;
  newEndTime: number | null;
  previousTopBidderId: string | null;
}

export interface PlaceBidRejection {
  ok: false;
  reason: BidRejectReason;
  currentPrice: number;
}

export type PlaceBidResult = PlaceBidSuccess | PlaceBidRejection;

export interface BiddingUser {
  userId: string;
  role: UserRole;
}

export interface AuctionBidItem {
  bidId: string;
  userId: string;
  userName: string;
  amount: number;
  createdAt: string;
}


export interface UserBidHistoryItem {
  bidId: string;
  auctionId: string;
  auctionTitle: string;
  images: string[];
  auctionStatus: string;
  currentPrice: number;
  myHighestBid: number;
  createdAt: string;
}

export interface AuctionBidsPage {
  items: AuctionBidItem[];
  total: number;
  limit: number;
  offset: number;
}

interface BidRow {
  bidId: string;
  userId: string;
  userName: string;
  amount: string;
  createdAt: string | Date;
}

@Injectable()
export class BidsService {
  constructor(
    @InjectRepository(Auction)
    private readonly auctionRepo: Repository<Auction>,
    @InjectRepository(Bid)
    private readonly bidRepo: Repository<Bid>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  placeBid(
    auctionId: string,
    amount: number,
    user: BiddingUser,
  ): Promise<PlaceBidResult> {
    return this.bidRepo.manager.transaction(async (manager) => {
      const bidder = await manager.findOne(User, {
        where: { id: user.userId },
      });

      if (!bidder || bidder.role !== UserRole.BIDDER) {
        console.warn(
          `[BidsService] placeBid REJECTED: User ${user.userId} has role ${bidder?.role ?? 'unknown'} (expected ${UserRole.BIDDER})`,
        );
        return { ok: false, reason: 'forbidden', currentPrice: 0 };
      }

      const auction = await manager.findOne(Auction, {
        where: { id: auctionId },
        lock: { mode: 'pessimistic_write' },
      });

      if (!auction) {
        return { ok: false, reason: 'auction_not_active', currentPrice: 0 };
      }

      const now = Date.now();
      const currentPrice = Number(auction.current_price);

      if (
        auction.status === AuctionStatus.CLOSED ||
        now > auction.end_time.getTime()
      ) {
        return { ok: false, reason: 'auction_closed', currentPrice };
      }

      if (
        auction.status !== AuctionStatus.ACTIVE ||
        now < auction.start_time.getTime()
      ) {
        return { ok: false, reason: 'auction_not_active', currentPrice };
      }

      if (amount < currentPrice + Number(auction.min_increment)) {
        return { ok: false, reason: 'amount_too_low', currentPrice };
      }

      const previousTopBid = await manager.findOne(Bid, {
        where: { auctionId: auction.id },
        order: { createdAt: 'DESC' },
      });
      const previousTopBidderId =
        previousTopBid && previousTopBid.userId !== user.userId
          ? previousTopBid.userId
          : null;

      const bid = manager.create(Bid, {
        auctionId: auction.id,
        userId: user.userId,
        amount,
      });
      await manager.save(bid);

      auction.current_price = amount;

      let newEndTime: number | null = null;
      if (auction.end_time.getTime() - now <= ANTI_SNIPING_WINDOW_MS) {
        newEndTime = now + ANTI_SNIPING_WINDOW_MS;
        auction.end_time = new Date(newEndTime);
      }
      await manager.save(auction);

      return {
        ok: true,
        bidId: bid.id,
        userId: user.userId,
        userName: bidder.name ?? '',
        amount: Number(bid.amount),
        createdAt:
          bid.createdAt instanceof Date
            ? bid.createdAt.toISOString()
            : String(bid.createdAt),
        currentPrice: Number(auction.current_price),
        endTime: auction.end_time.getTime(),
        newEndTime,
        previousTopBidderId,
      } satisfies PlaceBidSuccess;
    });
  }

  async getAuctionBids(
    auctionId: string,
    limit = 50,
    offset = 0,
  ): Promise<AuctionBidsPage> {
    const auctionExists = await this.auctionRepo.existsBy({ id: auctionId });
    if (!auctionExists) {
      throw new NotFoundException('Subasta no encontrada');
    }

    const qb = this.bidRepo
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
      .orderBy('bid.createdAt', 'DESC');

    const [rows, total] = await Promise.all([
      qb.clone().offset(offset).limit(limit).getRawMany<BidRow>(),
      this.bidRepo.countBy({ auctionId }),
    ]);

    return {
      items: rows.map((row) => ({
        bidId: row.bidId,
        userId: row.userId,
        userName: row.userName,
        amount: Number(row.amount),
        createdAt:
          row.createdAt instanceof Date
            ? row.createdAt.toISOString()
            : row.createdAt,
      })),
      total,
      limit,
      offset,
    };
  }

  async getUserBids(userId: string): Promise<UserBidHistoryItem[]> {
    const rawBids = await this.bidRepo
      .createQueryBuilder("bid")
      .innerJoin(Auction, "auction", "auction.id = bid.auctionId")
      .select([
        'auction.id AS "auctionId"',
        'auction.title AS "auctionTitle"',
        'auction.images AS "images"',
        'auction.status AS "auctionStatus"',
        'auction.current_price AS "currentPrice"',
        'MAX(bid.amount) AS "myHighestBid"',
        'MAX(bid.createdAt) AS "createdAt"',
      ])
      .where("bid.userId = :userId", { userId })
      .groupBy("auction.id")
      .addGroupBy("auction.title")
      .addGroupBy("auction.images")
      .addGroupBy("auction.status")
      .addGroupBy("auction.current_price")
      .orderBy("MAX(bid.createdAt)", "DESC")
      .getRawMany();

    return rawBids.map((row) => ({
      bidId: row.bidId,
      auctionId: row.auctionId,
      auctionTitle: row.auctionTitle,
      images: Array.isArray(row.images)
        ? row.images
        : typeof row.images === "string"
          ? JSON.parse(row.images)
          : [],
      auctionStatus: row.auctionStatus,
      currentPrice: Number(row.currentPrice),
      myHighestBid: Number(row.myHighestBid),
      createdAt:
        row.createdAt instanceof Date
          ? row.createdAt.toISOString()
          : String(row.createdAt),
    }));
  }

}
