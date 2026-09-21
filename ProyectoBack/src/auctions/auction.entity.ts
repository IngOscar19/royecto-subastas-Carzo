import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import { numericTransformer } from '../common/numeric.transformer';

export enum AuctionStatus {
  SCHEDULED = 'scheduled',
  ACTIVE = 'active',
  CLOSED = 'closed',
}

@Entity('auctions')
export class Auction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'seller_id', type: 'uuid' })
  sellerId: string;

  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({
    type: 'jsonb',
    array: false,
    default: () => "'[]'",
  })
  images: string[];

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: numericTransformer,
  })
  starting_price: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    default: 0,
    transformer: numericTransformer,
  })
  current_price: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    default: 0,
    transformer: numericTransformer,
  })
  min_increment: number;

  @Column({ type: 'timestamptz' })
  start_time: Date;

  @Column({ type: 'timestamptz' })
  end_time: Date;

  @Column({
    type: 'enum',
    enum: AuctionStatus,
    enumName: 'auction_status_enum',
    default: AuctionStatus.SCHEDULED,
  })
  status: AuctionStatus;

  @Column({ name: 'winner_id', type: 'uuid', nullable: true })
  winnerId: string | null;

  @Column({
    name: 'buy_out_price',
    type: 'decimal',
    precision: 12,
    scale: 2,
    nullable: true,
    transformer: numericTransformer,
  })
  buy_out_price: number | null;

  seller_name?: string | null;
  seller_email?: string | null;
  seller_phone?: string | null;
  sellerName?: string | null;
  sellerEmail?: string | null;
  sellerPhone?: string | null;
}
