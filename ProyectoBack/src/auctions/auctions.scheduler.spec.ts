import { EntityManager, Repository } from 'typeorm';
import { NotificationsService } from '../notifications/notifications.service';
import { Auction, AuctionStatus } from './auction.entity';
import { Bid } from '../bids/bid.entity';
import { AuctionsGateway } from './auctions.gateway';
import { AuctionsScheduler } from './auctions.scheduler';

interface MockManager {
  findOne: jest.Mock;
  save: jest.Mock;
  createQueryBuilder: jest.Mock;
}

function buildAuction(overrides: Partial<Auction> = {}): Auction {
  return {
    id: 'auction-1',
    sellerId: 'user-seller',
    title: 'Test',
    description: null,
    images: [],
    starting_price: 100,
    current_price: 150,
    min_increment: 10,
    start_time: new Date(Date.now() - 60_000),
    end_time: new Date(Date.now() - 1_000),
    status: AuctionStatus.ACTIVE,
    winnerId: null,
    ...overrides,
  };
}

function setupScheduler(options: {
  auction: Auction | null;
  winner?: { userId: string; userName: string; amount: string } | null;
}) {
  const manager: MockManager = {
    findOne: jest.fn(),
    save: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  manager.findOne.mockImplementation(() => Promise.resolve(options.auction));
  manager.save.mockImplementation((entity: unknown) => Promise.resolve(entity));

  const qb = {
    leftJoin: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    where: jest.fn().mockReturnThis(),
    orderBy: jest.fn().mockReturnThis(),
    getRawOne: jest.fn().mockResolvedValue(options.winner ?? null),
  };
  manager.createQueryBuilder.mockReturnValue(qb);

  const auctionRepo = {
    findBy: jest
      .fn()
      .mockResolvedValue(options.auction ? [options.auction] : []),
    save: jest
      .fn()
      .mockImplementation((entity: unknown) => Promise.resolve(entity)),
    manager: {
      transaction: (cb: (m: EntityManager) => unknown) =>
        cb(manager as unknown as EntityManager),
    },
  };
  const bidRepo = {} as Repository<Bid>;
  const gateway = {
    emitAuctionClosed: jest.fn(),
    emitAuctionStarted: jest.fn(),
  };
  const notificationsService = {
    enqueueWonNotification: jest.fn().mockResolvedValue(undefined),
    enqueueOutbidNotification: jest.fn().mockResolvedValue(undefined),
  };

  const scheduler = new AuctionsScheduler(
    auctionRepo as unknown as Repository<Auction>,
    bidRepo,
    gateway as unknown as AuctionsGateway,
    notificationsService as unknown as NotificationsService,
  );

  return { scheduler, auctionRepo, manager, gateway, notificationsService };
}

describe('AuctionsScheduler', () => {
  it('cierra subastas activas expiradas con ganador', async () => {
    const { scheduler, auctionRepo, manager, gateway, notificationsService } =
      setupScheduler({
        auction: buildAuction(),
        winner: { userId: 'user-bidder', userName: 'Comprador', amount: '150' },
      });

    await scheduler.closeExpiredAuctions();

    expect(auctionRepo.findBy).toHaveBeenCalled();
    expect(manager.findOne).toHaveBeenCalledWith(
      Auction,
      expect.objectContaining({ lock: { mode: 'pessimistic_write' } }),
    );
    expect(manager.save).toHaveBeenCalledWith(
      expect.objectContaining({
        status: AuctionStatus.CLOSED,
        winnerId: 'user-bidder',
      }),
    );
    expect(gateway.emitAuctionClosed).toHaveBeenCalledWith('auction-1', {
      winnerId: 'user-bidder',
      winnerName: 'Comprador',
      finalPrice: 150,
    });
    expect(notificationsService.enqueueWonNotification).toHaveBeenCalledWith({
      auctionId: 'auction-1',
      winnerId: 'user-bidder',
      winnerName: 'Comprador',
      finalPrice: 150,
    });
  });

  it('cierra subastas sin ofertas con winner null y finalPrice = current_price', async () => {
    const { scheduler, gateway } = setupScheduler({
      auction: buildAuction(),
      winner: null,
    });

    await scheduler.closeExpiredAuctions();

    expect(gateway.emitAuctionClosed).toHaveBeenCalledWith('auction-1', {
      winnerId: null,
      winnerName: null,
      finalPrice: 150,
    });
  });

  it('no cierra si ya no está activa tras el lock', async () => {
    const { scheduler, gateway } = setupScheduler({
      auction: buildAuction({ status: AuctionStatus.CLOSED }),
      winner: null,
    });

    await scheduler.closeExpiredAuctions();

    expect(gateway.emitAuctionClosed).not.toHaveBeenCalled();
  });

  it('activa subastas programadas y emite auction_started global', async () => {
    const auction = buildAuction({
      status: AuctionStatus.SCHEDULED,
      end_time: new Date(Date.now() + 60_000),
    });
    const { scheduler, auctionRepo, gateway } = setupScheduler({ auction });

    await scheduler.activateScheduledAuctions();

    expect(auctionRepo.findBy).toHaveBeenCalled();
    expect(gateway.emitAuctionStarted).toHaveBeenCalledWith('auction-1', {
      auctionId: 'auction-1',
      currentPrice: 150,
      endTime: auction.end_time.getTime(),
    });
  });
});
