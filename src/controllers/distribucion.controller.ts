import { NextFunction, Request, Response } from "express";
import { ResponseBuilder } from "../core/ResponseBuilder";
import { DistribucionService } from "../services/distribucion.service";

export class DistribucionController {
  constructor(private distribucionService: DistribucionService) { }

  list = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.distribucionService.list(String(req.params.tid));
      res.status(200).json(ResponseBuilder.success({ data, message: "Distribución obtenida exitosamente" }));
    } catch (error) {
      next(error);
    }
  };

  setAbonado = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.distribucionService.setAbonado(
        String(req.params.tid),
        req.params.socio,
        req.body?.abonado,
      );
      res.status(200).json(ResponseBuilder.success({ data, message: "Distribución actualizada" }));
    } catch (error) {
      next(error);
    }
  };
}
