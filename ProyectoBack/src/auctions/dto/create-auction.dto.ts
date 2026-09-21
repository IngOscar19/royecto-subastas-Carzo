import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsDate,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  Min,
  Validate,
  ValidatorConstraint,
  ValidatorConstraintInterface,
  ValidationArguments,
} from 'class-validator';

@ValidatorConstraint({ name: 'startBeforeEnd', async: false })
export class StartBeforeEndConstraint implements ValidatorConstraintInterface {
  validate(endTime: Date, args: ValidationArguments): boolean {
    const startTime = (args.object as CreateAuctionDto).startTime;
    if (startTime === undefined || endTime === undefined) {
      return true;
    }
    return startTime.getTime() < endTime.getTime();
  }

  defaultMessage(): string {
    return 'startTime debe ser anterior a endTime';
  }
}

export class CreateAuctionDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsOptional()
  @IsString()
  description?: string | null;

  @IsArray({ message: 'Las imágenes deben enviarse como una lista' })
  @ArrayMinSize(1, { message: 'Debes incluir al menos 1 imagen para publicar la subasta' })
  @ArrayMaxSize(20, { message: 'No se pueden incluir más de 20 imágenes' })
  @IsString({ each: true })
  images: string[];

  @IsNumber()
  @IsPositive()
  startingPrice: number;

  @IsNumber()
  @Min(0)
  minIncrement: number;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  buyOutPrice?: number;

  @Type(() => Date)
  @IsDate()
  startTime: Date;

  @Type(() => Date)
  @IsDate()
  @Validate(StartBeforeEndConstraint)
  endTime: Date;
}

