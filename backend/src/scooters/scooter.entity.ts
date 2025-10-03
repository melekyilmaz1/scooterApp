import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('scooters')
export class Scooter {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'double precision' })
  latitude: number;

  @Column({ type: 'double precision' })
  longitude: number;

  
  @Column({ unique: true, name: 'unique_name' })
  unique_name: string;

  @Column({ name: 'battery_status' })
  battery_status: number;
}
