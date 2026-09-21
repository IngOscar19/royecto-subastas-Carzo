import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsDate,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  Min,
  Validate,
} from 'class-validator';
import { StartBeforeEndConstraint } from './create-auction.dto';

export class UpdateAuctionDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string | null;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20, { message: 'No se pueden incluir más de 20 imágenes' })
  @IsString({ each: true })
  images?: string[];

  @IsOptional()
  @IsNumber()
  @IsPositive()
  startingPrice?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  minIncrement?: number;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  buyOutPrice?: number;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  startTime?: Date;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  @Validate(StartBeforeEndConstraint)
  endTime?: Date;
}

