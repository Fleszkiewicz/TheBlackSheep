import { NextFunction, Request, Response } from "express";
import { PasajerosService } from "../services/pasajeros.service";
import { ResponseBuilder } from "../core/ResponseBuilder";
import { parseOptionalString } from "../utils/validation";

export class PasajerosController {
    constructor(private pasajerosService: PasajerosService) { }

    buscar = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
        try {
            const dni = parseOptionalString(req.query.dni) ?? "";
            const data = await this.pasajerosService.searchByDni(dni);
            res.status(200).json(ResponseBuilder.success({ data }));
        } catch (error) {
            next(error);
        }
    };
}