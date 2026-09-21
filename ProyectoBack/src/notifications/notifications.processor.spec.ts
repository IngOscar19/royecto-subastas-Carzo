import { Job } from 'bullmq';
import { NotificationsProcessor } from './notifications.processor';

describe('NotificationsProcessor', () => {
  let processor: NotificationsProcessor;

  beforeEach(() => {
    processor = new NotificationsProcessor();
  });

  it('procesa correctamente el job outbid', async () => {
    const job = {
      name: 'outbid',
      data: {
        auctionId: 'auction-1',
        outbidUserId: 'user-1',
        newBidderId: 'user-2',
        newBidderName: 'Bidder 2',
        amount: 2000,
      },
    } as Job;

    await expect(processor.process(job)).resolves.toBeUndefined();
  });

  it('procesa correctamente el job won', async () => {
    const job = {
      name: 'won',
      data: {
        auctionId: 'auction-1',
        winnerId: 'user-2',
        winnerName: 'Bidder 2',
        finalPrice: 2000,
      },
    } as Job;

    await expect(processor.process(job)).resolves.toBeUndefined();
  });
});
