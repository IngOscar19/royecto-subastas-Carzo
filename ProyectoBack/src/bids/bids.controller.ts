import { Controller, Get, Req } from "@nestjs/common";
import { Roles } from "../common/roles.decorator";
import { UserRole } from "../users/user.entity";
import { BidsService } from "./bids.service";

interface RequestWithUser {
  user: { userId: string; role: UserRole };
}

@Controller("bids")
export class BidsController {
  constructor(private readonly bidsService: BidsService) {}

  @Get("my-bids")
  @Roles(UserRole.BIDDER)
  getMyBids(@Req() req: RequestWithUser) {
    return this.bidsService.getUserBids(req.user.userId);
  }
}
