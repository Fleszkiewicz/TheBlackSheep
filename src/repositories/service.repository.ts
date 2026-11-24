import { PoolConnection } from "mysql2/promise";
import { db } from "../db/db";
import { IServiceRepository } from "../interfaces/service.repository.interface";
import { ServiceResponseDTO } from "../dtos/service.dto";
import { QueryExecutor } from "../core/QueryExecutor";

/**
 * Repositorio de tipos de servicio (servicio_tipo)
 */
export class ServiceRepository implements IServiceRepository {
  async getConnection(): Promise<PoolConnection> {
    return db.getConnection();
  }

  async findAll(conn?: PoolConnection): Promise<ServiceResponseDTO[]> {
    return await QueryExecutor.executeSelect<ServiceResponseDTO>(
      "SELECT * FROM servicio_tipo",
      [],
      conn,
    );
  }
}
