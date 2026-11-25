import { NextFunction, Request, Response } from "express";
import { ResponseBuilder } from "../core/ResponseBuilder";
import { ErrorFactory } from "../errors/errorFactory";
import { DashboardService, isDashboardVista } from "../services/dashboard.service";

export class DashboardController {
  constructor(private dashboardService: DashboardService) { }

  getVista = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const vista = req.params.vista;
      if (!isDashboardVista(vista)) {
        throw ErrorFactory.notFound("Sección del Dashboard inexistente");
      }

      const anio = Number(req.query.anio);
      if (!Number.isInteger(anio) || anio < 2000 || anio > 2100) {
        throw ErrorFactory.badRequest("Falta el año o no es válido");
      }

      const mesParam = Number(req.query.mes);
      const mes = Number.isInteger(mesParam) && mesParam >= 1 && mesParam <= 12 ? mesParam : null;

      // Solo se aceptan sucursales reales; cualquier otro valor = todas (1 = Baradero, 2 = Hurlingham)
      const sucursalParam = req.query.sucursal;
      const sucursal =
        sucursalParam === "baradero" ? 1 : sucursalParam === "hurlingham" ? 2 : null;

      const data = await this.dashboardService.getVista(vista, { anio, mes, sucursal });
      res.status(200).json(ResponseBuilder.success({ data }));
    } catch (error) {
      next(error);
    }
  };
}
