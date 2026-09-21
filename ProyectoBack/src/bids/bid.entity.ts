import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { numericTransformer } from '../common/numeric.transformer';

@Entity('bids')
@Index('IDX_bids_auction_id_created_at', ['auctionId', 'createdAt'])
export class Bid {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'auction_id', type: 'uuid' })
  auctionId: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: numericTransformer,
  })
  amount: number;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;
}
