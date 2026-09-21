import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';

export interface OutbidJobData {
  auctionId: string;
  outbidUserId: string;
  newBidderId: string;
  newBidderName: string;
  amount: number;
}

export interface WonJobData {
  auctionId: string;
  winnerId: string;
  winnerName: string;
  finalPrice: number;
}

@Processor('notifications-queue')
export class NotificationsProcessor extends WorkerHost {
  private readonly logger = new Logger(NotificationsProcessor.name);

  process(job: Job<any, any, string>): Promise<void> {
    switch (job.name) {
      case 'outbid': {
        const data = job.data as OutbidJobData;
        this.logger.log(
          `[BullMQ NotificationsProcessor] Job 'outbid' procesado: usuario ${data.outbidUserId} ha sido superado en la subasta ${data.auctionId} con la oferta de $${data.amount} por ${data.newBidderName}`,
        );
        break;
      }
      case 'won': {
        const data = job.data as WonJobData;
        this.logger.log(
          `[BullMQ NotificationsProcessor] Job 'won' procesado: el ganador ${data.winnerName} (${data.winnerId}) ha ganado la subasta ${data.auctionId} por $${data.finalPrice}`,
        );
        break;
      }
      default:
        this.logger.warn(
          `[BullMQ NotificationsProcessor] Job desconocido recibido: ${job.name}`,
        );
    }
    return Promise.resolve();
  }
}
