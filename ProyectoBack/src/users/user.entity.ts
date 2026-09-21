import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

export enum UserRole {
  SELLER = 'seller',
  BIDDER = 'bidder',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password_hash: string;

  @Column()
  name: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    enumName: 'user_role_enum',
  })
  role: UserRole;

  @Column({ type: 'varchar', length: 50, nullable: true })
  phone?: string | null;

  @CreateDateColumn({ type: 'timestamptz' })
  created_at: Date;
}
