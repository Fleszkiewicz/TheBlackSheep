import { IServiceRepository } from "../interfaces/service.repository.interface";
import { ServiceResponseDTO } from "../dtos/service.dto";
import logger from "../config/logger.config";

export class ServicesService {
  constructor(private serviceRepository: IServiceRepository) {}

  async getServices(): Promise<ServiceResponseDTO[]> {
    logger.info("Fetching all services");
    return await this.serviceRepository.findAll();
  }
}
