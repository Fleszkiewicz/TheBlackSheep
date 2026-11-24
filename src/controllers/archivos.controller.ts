import { NextFunction, Request, Response } from "express";
import { ResponseBuilder } from "../core/ResponseBuilder";
import { ErrorFactory } from "../errors/errorFactory";
import { ArchivoService } from "../services/archivos.service";

const parseArchivoId = (raw: unknown): number => {
  const id = Number(raw);
  if (!Number.isInteger(id) || id <= 0) throw ErrorFactory.badRequest("Identificador de archivo inválido");
  return id;
};

export class ArchivosController {
  constructor(private archivoService: ArchivoService) { }

  list = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.archivoService.list(String(req.params.tid));
      res.status(200).json(ResponseBuilder.success({ data, message: "Archivos obtenidos exitosamente" }));
    } catch (error) {
      next(error);
    }
  };

  presign = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { nombre, mime, size, categoria } = req.body ?? {};
      const data = await this.archivoService.presignUpload(String(req.params.tid), { nombre, mime, size, categoria });
      res.status(200).json(ResponseBuilder.success({ data, message: "URL de subida generada" }));
    } catch (error) {
      next(error);
    }
  };

  register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { key, nombre, categoria } = req.body ?? {};
      const result = await this.archivoService.register(String(req.params.tid), { key, nombre, categoria });
      res.status(201).json(ResponseBuilder.created(result, "Archivo guardado exitosamente"));
    } catch (error) {
      next(error);
    }
  };

  downloadUrl = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const inline = req.query.disposition !== "attachment";
      const data = await this.archivoService.downloadUrl(String(req.params.tid), parseArchivoId(req.params.aid), inline);
      res.status(200).json(ResponseBuilder.success({ data, message: "URL de descarga generada" }));
    } catch (error) {
      next(error);
    }
  };

  remove = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      await this.archivoService.remove(String(req.params.tid), parseArchivoId(req.params.aid));
      res.status(200).json(ResponseBuilder.deleted("Archivo eliminado exitosamente"));
    } catch (error) {
      next(error);
    }
  };
}
