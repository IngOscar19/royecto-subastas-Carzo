import { Injectable, Logger } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { OutbidJobData, WonJobData } from './notifications.processor';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectQueue('notifications-queue')
    private readonly notificationsQueue: Queue,
  ) {}

  async enqueueOutbidNotification(data: OutbidJobData): Promise<void> {
    try {
      await this.notificationsQueue.add('outbid', data, {
        attempts: 3,
        backoff: { type: 'exponential', delay: 1000 },
      });
      this.logger.log(
        `Job 'outbid' encolado para usuario superado: ${data.outbidUserId}`,
      );
    } catch (error) {
      this.logger.error(
        `Error al encolar job 'outbid': ${
          error instanceof Error ? error.message : String(error)
        }`,
      );
    }
  }

  async enqueueWonNotification(data: WonJobData): Promise<void> {
    try {
      await this.notificationsQueue.add('won', data, {
        attempts: 3,
        backoff: { type: 'exponential', delay: 1000 },
      });
      this.logger.log(
        `Job 'won' encolado para ganador: ${data.winnerId} en subasta: ${data.auctionId}`,
      );
    } catch (error) {
      this.logger.error(
        `Error al encolar job 'won': ${
          error instanceof Error ? error.message : String(error)
        }`,
      );
    }
  }
}
