import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UploadedFiles,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'node:path';
import { existsSync, mkdirSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import { Public } from '../common/public.decorator';
import { Roles } from '../common/roles.decorator';
import { UserRole } from '../users/user.entity';
import { AuctionsService } from './auctions.service';
import { BidsService } from '../bids/bids.service';
import { CreateAuctionDto } from './dto/create-auction.dto';
import { ListAuctionsDto } from './dto/list-auctions.dto';
import { ListBidsDto } from './dto/list-bids.dto';
import { UpdateAuctionDto } from './dto/update-auction.dto';

interface RequestWithUser {
  user: { userId: string; role: UserRole };
}

@Controller('auctions')
export class AuctionsController {
  constructor(
    private readonly auctionsService: AuctionsService,
    private readonly bidsService: BidsService,
  ) {}

  @Post('upload-images')
  @Roles(UserRole.SELLER)
  @UseInterceptors(
    FilesInterceptor('images', 20, {
      storage: diskStorage({
        destination: (_req, _file, cb) => {
          const uploadPath = join(process.cwd(), 'public', 'images', 'auctions');
          if (!existsSync(uploadPath)) {
            mkdirSync(uploadPath, { recursive: true });
          }
          cb(null, uploadPath);
        },
        filename: (_req, file, cb) => {
          const ext = extname(file.originalname).toLowerCase();
          const uniqueName = `${randomUUID()}${ext || '.jpg'}`;
          cb(null, uniqueName);
        },
      }),
      limits: {
        fileSize: 10 * 1024 * 1024,
        files: 20,
      },
      fileFilter: (_req, file, cb) => {
        if (!file.mimetype.match(/\/(jpg|jpeg|png|webp|heic|octet-stream)$/i)) {
          return cb(
            new BadRequestException(
              'Formato de imagen no soportado. Solo se permiten JPG, PNG, WEBP y HEIC',
            ),
            false,
          );
        }
        cb(null, true);
      },
    }),
  )
  uploadImages(@UploadedFiles() files: Array<Express.Multer.File>) {
    if (!files || files.length === 0) {
      throw new BadRequestException('No se han proporcionado imágenes para subir');
    }
    const urls = files.map((file) => `/images/auctions/${file.filename}`);
    return { urls };
  }

  @Post()
  @Roles(UserRole.SELLER)
  create(@Body() dto: CreateAuctionDto, @Req() req: RequestWithUser) {
    return this.auctionsService.create(dto, req.user.userId);
  }

  @Public()
  @Get()
  findAll(@Query() query: ListAuctionsDto) {
    return this.auctionsService.findAll(query);
  }

  @Public()
  @Get(':id')
  findById(@Param('id') id: string) {
    return this.auctionsService.findById(id);
  }

  @Patch(':id')
  @Roles(UserRole.SELLER)
  update(
    @Param('id') id: string,
    @Body() dto: UpdateAuctionDto,
    @Req() req: RequestWithUser,
  ) {
    return this.auctionsService.update(id, dto, req.user.userId);
  }

  @Get(':id/bids')
  findBids(@Param('id') id: string, @Query() query: ListBidsDto) {
    return this.bidsService.getAuctionBids(id, query.limit, query.offset);
  }

  @Post(':id/buy-now')
  @Roles(UserRole.BIDDER)
  buyNow(@Param('id') id: string, @Req() req: RequestWithUser) {
    return this.auctionsService.buyNow(id, req.user.userId);
  }

  @Post(':id/close')
  @Roles(UserRole.SELLER)
  closeAuction(@Param('id') id: string, @Req() req: RequestWithUser) {
    return this.auctionsService.closeAuction(id, req.user.userId);
  }
}
