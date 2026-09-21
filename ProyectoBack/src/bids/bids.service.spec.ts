import { EntityManager, Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { Auction, AuctionStatus } from '../auctions/auction.entity';
import { User, UserRole } from '../users/user.entity';
import { Bid } from './bid.entity';
import { BidsService } from './bids.service';

interface MockManager {
  findOne: jest.Mock;
  create: jest.Mock;
  save: jest.Mock;
}

const BIDDER: { userId: string; role: UserRole } = {
  userId: 'user-bidder',
  role: UserRole.BIDDER,
};

const SELLER: { userId: string; role: UserRole } = {
  userId: 'user-seller',
  role: UserRole.SELLER,
};

function buildAuction(overrides: Partial<Auction> = {}): Auction {
  const now = Date.now();
  return {
    id: 'auction-1',
    sellerId: 'user-seller',
    title: 'Test',
    description: null,
    images: [],
    starting_price: 100,
    current_price: 100,
    min_increment: 10,
    start_time: new Date(now - 60_000),
    end_time: new Date(now + 60_000),
    status: AuctionStatus.ACTIVE,
    winnerId: null,
    ...overrides,
  };
}

function setupService(auction: Auction | null, user: User | null) {
  const manager: MockManager = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  manager.findOne.mockImplementation((entity: unknown) => {
    if (entity === Auction) {
      return Promise.resolve(auction);
    }
    if (entity === User) {
      return Promise.resolve(user);
    }
    return Promise.resolve(null);
  });

  manager.create.mockImplementation((_entity: unknown, data: unknown) => ({
    id: 'bid-1',
    createdAt: new Date(),
    ...(data as object),
  }));

  manager.save.mockImplementation((entity: unknown) => Promise.resolve(entity));

  const repo = {
    manager: {
      transaction: (cb: (m: EntityManager) => unknown) =>
        cb(manager as unknown as EntityManager),
    },
  };

  const service = new BidsService(
    {} as Repository<Auction>,
    repo as unknown as Repository<Bid>,
    {} as Repository<User>,
  );

  return { service, manager };
}

describe('BidsService.placeBid', () => {
  it('rechaza si el usuario no es bidder', async () => {
    const { service } = setupService(buildAuction(), {
      id: 'user-seller',
      name: 'Vendedor',
      role: UserRole.SELLER,
    } as User);
    await expect(service.placeBid('auction-1', 200, SELLER)).resolves.toEqual({
      ok: false,
      reason: 'forbidden',
      currentPrice: 0,
    });
  });

  it('rechaza si la subasta no existe', async () => {
    const { service } = setupService(null, null);
    await expect(service.placeBid('auction-1', 200, BIDDER)).resolves.toEqual({
      ok: false,
      reason: 'auction_not_active',
      currentPrice: 0,
    });
  });

  it('rechaza si la subasta está cerrada', async () => {
    const { service } = setupService(
      buildAuction({ status: AuctionStatus.CLOSED }),
      null,
    );
    await expect(service.placeBid('auction-1', 200, BIDDER)).resolves.toEqual({
      ok: false,
      reason: 'auction_closed',
      currentPrice: 100,
    });
  });

  it('rechaza si la subasta no está activa (scheduled)', async () => {
    const { service } = setupService(
      buildAuction({ status: AuctionStatus.SCHEDULED }),
      null,
    );
    await expect(service.placeBid('auction-1', 200, BIDDER)).resolves.toEqual({
      ok: false,
      reason: 'auction_not_active',
      currentPrice: 100,
    });
  });

  it('rechaza si el monto es menor a currentPrice + minIncrement', async () => {
    const { service } = setupService(buildAuction(), null);
    await expect(service.placeBid('auction-1', 109, BIDDER)).resolves.toEqual({
      ok: false,
      reason: 'amount_too_low',
      currentPrice: 100,
    });
  });

  it('acepta un monto válido, persiste el bid y actualiza current_price', async () => {
    const { service, manager } = setupService(buildAuction(), {
      id: 'user-bidder',
      name: 'Comprador',
      role: UserRole.BIDDER,
    } as User);

    const result = await service.placeBid('auction-1', 150, BIDDER);

    expect(result.ok).toBe(true);
    if (!result.ok) return;

    expect(manager.findOne).toHaveBeenCalledWith(
      Auction,
      expect.objectContaining({ lock: { mode: 'pessimistic_write' } }),
    );
    expect(manager.create).toHaveBeenCalledWith(
      Bid,
      expect.objectContaining({
        auctionId: 'auction-1',
        userId: 'user-bidder',
        amount: 150,
      }),
    );
    expect(manager.save).toHaveBeenCalledTimes(2);
    expect(result.currentPrice).toBe(150);
    expect(result.userName).toBe('Comprador');
    expect(result.newEndTime).toBeNull();
  });

  it('extiende end_time si la puja llega en los últimos 30 segundos', async () => {
    const now = Date.now();
    const auction = buildAuction({
      end_time: new Date(now + 20_000),
    });
    const { service } = setupService(auction, {
      id: 'user-bidder',
      name: 'Comprador',
      role: UserRole.BIDDER,
    } as User);

    const result = await service.placeBid('auction-1', 150, BIDDER);

    expect(result.ok).toBe(true);
    if (!result.ok) return;

    expect(result.newEndTime).not.toBeNull();
    expect(result.newEndTime).toBeGreaterThanOrEqual(now + 30_000);
    expect(result.endTime).toBe(result.newEndTime);
    expect(auction.end_time.getTime()).toBe(result.newEndTime);
  });

  it('no extiende end_time si falta más de 30 segundos', async () => {
    const { service } = setupService(
      buildAuction({ end_time: new Date(Date.now() + 45_000) }),
      null,
    );
    const result = await service.placeBid('auction-1', 150, BIDDER);
    expect(result.ok).toBe(true);
    if (!result.ok) return;
    expect(result.newEndTime).toBeNull();
  });
});

describe('BidsService.getAuctionBids', () => {
  function setupHistory(rows: unknown[], total: number, exists: boolean) {
    const qb = {
      leftJoin: jest.fn().mockReturnThis(),
      select: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      orderBy: jest.fn().mockReturnThis(),
      clone: jest.fn().mockReturnThis(),
      offset: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      getRawMany: jest.fn().mockResolvedValue(rows),
    };
    const auctionRepo = {
      existsBy: jest.fn().mockResolvedValue(exists),
    } as unknown as Repository<Auction>;
    const bidRepo = {
      createQueryBuilder: jest.fn().mockReturnValue(qb),
      countBy: jest.fn().mockResolvedValue(total),
      manager: { transaction: jest.fn() },
    } as unknown as Repository<Bid>;
    const service = new BidsService(
      auctionRepo,
      bidRepo,
      {} as Repository<User>,
    );
    return { service };
  }

  it('devuelve historial paginado con el mismo shape que el snapshot', async () => {
    const { service } = setupHistory(
      [
        {
          bidId: 'b2',
          userId: 'u2',
          userName: 'Ana',
          amount: '200',
          createdAt: new Date('2026-01-01T00:00:02.000Z'),
        },
        {
          bidId: 'b1',
          userId: 'u1',
          userName: 'Luis',
          amount: '150',
          createdAt: new Date('2026-01-01T00:00:01.000Z'),
        },
      ],
      2,
      true,
    );

    const result = await service.getAuctionBids('auction-1', 50, 0);

    expect(result.total).toBe(2);
    expect(result.items).toEqual([
      {
        bidId: 'b2',
        userId: 'u2',
        userName: 'Ana',
        amount: 200,
        createdAt: '2026-01-01T00:00:02.000Z',
      },
      {
        bidId: 'b1',
        userId: 'u1',
        userName: 'Luis',
        amount: 150,
        createdAt: '2026-01-01T00:00:01.000Z',
      },
    ]);
  });

  it('lanza NotFoundException si la subasta no existe', async () => {
    const { service } = setupHistory([], 0, false);
    await expect(
      service.getAuctionBids('auction-inexistente', 50, 0),
    ).rejects.toThrow(NotFoundException);
  });
});
