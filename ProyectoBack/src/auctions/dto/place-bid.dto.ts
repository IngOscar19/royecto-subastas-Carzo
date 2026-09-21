import { IsNumber, IsPositive, IsUUID } from 'class-validator';

export class PlaceBidDto {
  @IsUUID()
  auctionId: string;

  @IsNumber()
  @IsPositive()
  amount: number;
}
