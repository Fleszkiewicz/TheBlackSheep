import { PoolConnection } from "mysql2/promise";
import { IBaseRepository } from "./repository.interface";
import { ServiceResponseDTO } from "../dtos/service.dto";

export interface IServiceRepository extends IBaseRepository {
  findAll(conn?: PoolConnection): Promise<ServiceResponseDTO[]>;
}
