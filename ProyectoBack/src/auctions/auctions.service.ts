import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Auction, AuctionStatus } from "./auction.entity";
import { Bid } from "../bids/bid.entity";
import { User } from "../users/user.entity";
import { AuctionsGateway } from "./auctions.gateway";
import { CreateAuctionDto } from "./dto/create-auction.dto";
import { ListAuctionsDto } from "./dto/list-auctions.dto";
import { UpdateAuctionDto } from "./dto/update-auction.dto";

interface WinnerRow {
  userId: string;
  userName: string;
  amount: string;
}

@Injectable()
export class AuctionsService {
  constructor(
    @InjectRepository(Auction)
    private readonly auctionRepository: Repository<Auction>,
    @InjectRepository(Bid)
    private readonly bidRepository: Repository<Bid>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly gateway: AuctionsGateway,
  ) {}

  async create(dto: CreateAuctionDto, sellerId: string): Promise<Auction> {
    const now = new Date();
    const startDate = new Date(dto.startTime);
    const initialStatus =
      startDate.getTime() <= now.getTime() + 15000
        ? AuctionStatus.ACTIVE
        : AuctionStatus.SCHEDULED;

    const auction = this.auctionRepository.create({
      sellerId,
      title: dto.title,
      description: dto.description ?? null,
      images: dto.images ?? [],
      starting_price: dto.startingPrice,
      current_price: dto.startingPrice,
      min_increment: dto.minIncrement,
      buy_out_price: dto.buyOutPrice ?? null,
      start_time: dto.startTime,
      end_time: dto.endTime,
      status: initialStatus,
    });
    const saved = await this.auctionRepository.save(auction);

    if (initialStatus === AuctionStatus.ACTIVE) {
      this.gateway.emitAuctionStarted(saved.id, {
        auctionId: saved.id,
        currentPrice: Number(saved.current_price),
        endTime: saved.end_time.getTime(),
      });
    }

    return saved;
  }

  async findAll(query: ListAuctionsDto = {}): Promise<Auction[]> {
    const now = new Date();

    // Sincronizar automáticamente en BD subastas cuyo horario de inicio ya llegó
    try {
      await this.auctionRepository
        .createQueryBuilder()
        .update(Auction)
        .set({ status: AuctionStatus.ACTIVE })
        .where('status = :scheduled AND start_time <= :now AND end_time > :now', {
          scheduled: AuctionStatus.SCHEDULED,
          now,
        })
        .execute();
    } catch (_) {}

    const qb = this.auctionRepository
      .createQueryBuilder("auction")
      .leftJoin(User, "seller", "seller.id = auction.sellerId")
      .addSelect([
        'seller.name AS "seller_name"',
        'seller.email AS "seller_email"',
        'seller.phone AS "seller_phone"',
      ]);

    if (query.status === AuctionStatus.ACTIVE) {
      qb.andWhere("auction.status = :status", { status: query.status });
      qb.andWhere("auction.end_time > :now", { now });
    } else if (query.status) {
      qb.andWhere("auction.status = :status", { status: query.status });
    }

    if (query.sellerId) {
      qb.andWhere("auction.sellerId = :sellerId", { sellerId: query.sellerId });
    }

    if (query.winnerId) {
      qb.andWhere("auction.winnerId = :winnerId", { winnerId: query.winnerId });
    }

    if (query.search?.trim()) {
      qb.andWhere(
        "(auction.title ILIKE :search OR auction.description ILIKE :search)",
        { search: `%${query.search.trim()}%` },
      );
    }

    qb.orderBy("auction.start_time", "DESC");

    if (query.offset !== undefined) {
      qb.skip(query.offset);
    }

    if (query.limit !== undefined) {
      qb.take(query.limit);
    }

    const rawAndEntities = await qb.getRawAndEntities();
    return rawAndEntities.entities.map((auction, i) => {
      const raw = rawAndEntities.raw[i];
      auction.sellerName = raw?.seller_name || raw?.sellerName || null;
      auction.seller_name = auction.sellerName;
      auction.sellerEmail = raw?.seller_email || raw?.sellerEmail || null;
      auction.seller_email = auction.sellerEmail;
      auction.sellerPhone = raw?.seller_phone || raw?.sellerPhone || null;
      auction.seller_phone = auction.sellerPhone;
      return auction;
    });
  }

  async findById(id: string): Promise<Auction> {
    const qb = this.auctionRepository
      .createQueryBuilder("auction")
      .leftJoin(User, "seller", "seller.id = auction.sellerId")
      .addSelect([
        'seller.name AS "seller_name"',
        'seller.email AS "seller_email"',
        'seller.phone AS "seller_phone"',
      ])
      .where("auction.id = :id", { id });

    const rawAndEntities = await qb.getRawAndEntities();
    if (!rawAndEntities.entities.length) {
      throw new NotFoundException("Subasta no encontrada");
    }

    const auction = rawAndEntities.entities[0];
    const raw = rawAndEntities.raw[0];
    auction.sellerName = raw?.seller_name || raw?.sellerName || null;
    auction.seller_name = auction.sellerName;
    auction.sellerEmail = raw?.seller_email || raw?.sellerEmail || null;
    auction.seller_email = auction.sellerEmail;
    auction.sellerPhone = raw?.seller_phone || raw?.sellerPhone || null;
    auction.seller_phone = auction.sellerPhone;

    const now = new Date();
    if (
      auction.status === AuctionStatus.SCHEDULED &&
      new Date(auction.start_time).getTime() <= now.getTime() &&
      new Date(auction.end_time).getTime() > now.getTime()
    ) {
      auction.status = AuctionStatus.ACTIVE;
      await this.auctionRepository.save(auction);
    }
    return auction;
  }

  async buyNow(auctionId: string, userId: string): Promise<Auction> {
    const user = await this.userRepository.findOneBy({ id: userId });
    if (!user) throw new NotFoundException("Usuario no encontrado");

    const result = await this.auctionRepository.manager.transaction(
      async (manager) => {
        const auction = await manager.findOne(Auction, {
          where: { id: auctionId },
          lock: { mode: "pessimistic_write" },
        });

        if (!auction) throw new NotFoundException("Subasta no encontrada");
        if (auction.status !== AuctionStatus.ACTIVE) {
          throw new BadRequestException("La subasta no está activa");
        }
        if (!auction.buy_out_price || Number(auction.buy_out_price) <= 0) {
          throw new BadRequestException("Esta subasta no tiene precio de compra directa");
        }

        const buyoutAmount = Number(auction.buy_out_price);
        auction.current_price = buyoutAmount;
        auction.status = AuctionStatus.CLOSED;
        auction.winnerId = userId;

        const bid = manager.create(Bid, {
          auctionId,
          userId,
          amount: buyoutAmount,
        });

        const savedBid = await manager.save(bid);
        await manager.save(auction);

        return {
          auction,
          bid: savedBid,
          closedPayload: {
            winnerId: userId,
            winnerName: user.name,
            finalPrice: buyoutAmount,
          },
        };
      },
    );

    this.gateway.emitNewBid(auctionId, {
      bidId: result.bid.id,
      userId,
      userName: user.name,
      amount: result.closedPayload.finalPrice,
      createdAt: result.bid.createdAt instanceof Date
        ? result.bid.createdAt.toISOString()
        : new Date().toISOString(),
    });
    await this.gateway.emitAuctionClosed(auctionId, result.closedPayload);
    return result.auction;
  }

  async closeAuction(auctionId: string, sellerId: string): Promise<Auction> {
    const result = await this.auctionRepository.manager.transaction(
      async (manager) => {
        const auction = await manager.findOne(Auction, {
          where: { id: auctionId },
          lock: { mode: "pessimistic_write" },
        });

        if (!auction) throw new NotFoundException("Subasta no encontrada");
        if (auction.sellerId !== sellerId) {
          throw new ForbiddenException("No tienes permiso para finalizar esta subasta");
        }
        if (auction.status === AuctionStatus.CLOSED) {
          throw new BadRequestException("La subasta ya está cerrada");
        }

        const winner = await manager
          .createQueryBuilder(Bid, "bid")
          .leftJoin(User, "user", "user.id = bid.userId")
          .select([
            'bid.userId AS "userId"',
            'user.name AS "userName"',
            'bid.amount AS "amount"',
          ])
          .where("bid.auctionId = :auctionId", { auctionId })
          .orderBy("bid.amount", "DESC")
          .getRawOne<WinnerRow>();

        auction.status = AuctionStatus.CLOSED;
        auction.winnerId = winner?.userId ?? null;
        await manager.save(auction);

        return {
          auction,
          closedPayload: {
            winnerId: winner?.userId ?? null,
            winnerName: winner?.userName ?? null,
            finalPrice: Number(auction.current_price),
          },
        };
      },
    );

    await this.gateway.emitAuctionClosed(auctionId, result.closedPayload);
    return result.auction;
  }

  async update(
    id: string,
    dto: UpdateAuctionDto,
    userId: string,
  ): Promise<Auction> {
    const auction = await this.auctionRepository.findOneBy({ id });
    if (!auction) {
      throw new NotFoundException("Subasta no encontrada");
    }
    if (auction.sellerId !== userId) {
      throw new ForbiddenException(
        "No tienes permisos para editar esta subasta",
      );
    }

    if (
      dto.startingPrice !== undefined ||
      dto.minIncrement !== undefined ||
      dto.startTime !== undefined
    ) {
      if (auction.status !== AuctionStatus.SCHEDULED) {
        throw new BadRequestException(
          "Solo se pueden editar precio inicial, incremento o inicio en subastas programadas",
        );
      }
      const bidsCount = await this.bidRepository.countBy({ auctionId: id });
      if (bidsCount > 0) {
        throw new BadRequestException(
          "No se pueden modificar condiciones comerciales de una subasta con pujas",
        );
      }
    }

    if (dto.title !== undefined) auction.title = dto.title;
    if (dto.description !== undefined) auction.description = dto.description;
    if (dto.images !== undefined) auction.images = dto.images;
    if (dto.startingPrice !== undefined) {
      auction.starting_price = dto.startingPrice;
      auction.current_price = dto.startingPrice;
    }
    if (dto.minIncrement !== undefined)
      auction.min_increment = dto.minIncrement;
    if (dto.buyOutPrice !== undefined)
      auction.buy_out_price = dto.buyOutPrice;
    if (dto.startTime !== undefined) auction.start_time = dto.startTime;
    if (dto.endTime !== undefined) auction.end_time = dto.endTime;

    return this.auctionRepository.save(auction);
  }
}
