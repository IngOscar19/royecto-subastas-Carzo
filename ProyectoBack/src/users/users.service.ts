import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './user.entity';

export interface CreateUserData {
  email: string;
  passwordHash: string;
  name: string;
  role: UserRole;
  phone?: string;
}

export type SafeUser = Omit<User, 'password_hash'>;

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  findByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email } });
  }

  findById(id: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { id } });
  }

  async create(data: CreateUserData): Promise<User> {
    const user = this.usersRepository.create({
      email: data.email,
      password_hash: data.passwordHash,
      name: data.name,
      role: data.role,
      phone: data.phone ?? null,
    });
    return this.usersRepository.save(user);
  }

  sanitize(user: User): SafeUser {
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      phone: user.phone ?? null,
      created_at: user.created_at,
    };
  }
}
