import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import type { Server, Socket } from 'socket.io';
import { UserRole } from '../users/user.entity';
import { JwtPayload } from './jwt.strategy';

export interface SocketUser {
  userId: string;
  role: UserRole;
}

@Injectable()
export class SocketAuthMiddleware {
  private readonly secret: string;

  constructor(
    private readonly jwtService: JwtService,
    configService: ConfigService,
  ) {
    this.secret = configService.get<string>('JWT_SECRET') ?? 'dev-secret';
  }

  register(server: Server): void {
    server.use((socket, next) => {
      this.authenticate(socket)
        .then(() => next())
        .catch(() => next(new Error('Unauthorized')));
    });
  }

  async authenticate(socket: Socket): Promise<SocketUser> {
    const token = this.extractToken(socket);
    if (!token) {
      throw new Error('Unauthorized');
    }

    const payload = await this.jwtService.verifyAsync<JwtPayload>(token, {
      secret: this.secret,
    });

    const data = socket.data as { user?: SocketUser };
    const user = {
      userId: payload.userId,
      role: payload.role,
    } satisfies SocketUser;
    data.user = user;

    void socket.join(`user:${user.userId}`);

    return user;
  }

  extractToken(socket: Socket): string | null {
    const auth = socket.handshake.auth as { token?: string };
    if (auth?.token) {
      return auth.token;
    }

    const header = socket.handshake.headers.authorization;
    if (header?.startsWith('Bearer ')) {
      return header.slice('Bearer '.length);
    }

    return null;
  }
}
