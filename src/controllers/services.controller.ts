import { NextFunction, Response, Request } from "express";
import { ResponseBuilder } from "../core/ResponseBuilder";
import { ServicesService } from "../services/services.service";

export class ServicesController {
  constructor(private servicesService: ServicesService) {}

  // Tipos de servicio (servicio_tipo); los servicios de cada viaje se guardan con los destinos
  getServices = async (
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      const services = await this.servicesService.getServices();

      res.status(200).json(ResponseBuilder.success({ data: services }));
    } catch (error) {
      next(error);
    }
  };
}
