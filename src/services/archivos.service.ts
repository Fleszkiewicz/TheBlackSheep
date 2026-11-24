import { randomUUID } from "node:crypto";
import {
  DeleteObjectCommand,
  GetObjectCommand,
  HeadObjectCommand,
  PutObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import type { ResultSetHeader, RowDataPacket } from "mysql2";
import { db } from "../db/db";
import { ErrorFactory } from "../errors/errorFactory";
import logger from "../config/logger.config";
import { getStorage } from "../config/storage.config";
import {
  ARCHIVO_MAX_BYTES,
  ARCHIVO_MIME_EXT,
  cleanFileName,
  isCategoria,
} from "../utils/archivos";

const UPLOAD_TTL = 300; // segundos que vale la URL de subida
const DOWNLOAD_TTL = 300; // segundos que vale la URL de descarga

export interface ArchivoDTO {
  id: number;
  nombre: string;
  categoria: string;
  mime: string;
  size: number;
  fecha: string;
}

interface ArchivoRow extends RowDataPacket {
  id: number;
  nombre_original: string;
  categoria: string;
  storage_key: string;
  mime: string;
  size_bytes: number;
  created_at: Date;
}

const toDTO = (r: ArchivoRow): ArchivoDTO => ({
  id: r.id,
  nombre: r.nombre_original,
  categoria: r.categoria,
  mime: r.mime,
  size: r.size_bytes,
  fecha: new Date(r.created_at).toISOString().slice(0, 10),
});

export class ArchivoService {
  private async viajeId(legajo: string): Promise<number> {
    const [rows] = await db.query<RowDataPacket[]>("SELECT id FROM viaje WHERE legajo = ?", [legajo]);
    if (rows.length === 0) throw ErrorFactory.notFound("Viaje no encontrado");
    return rows[0].id as number;
  }

  private async findRow(legajo: string, archivoId: number): Promise<ArchivoRow> {
    const [rows] = await db.query<ArchivoRow[]>(
      `SELECT a.* FROM viaje_archivo a
       JOIN viaje v ON v.id = a.viaje_id
       WHERE v.legajo = ? AND a.id = ?`,
      [legajo, archivoId],
    );
    if (rows.length === 0) throw ErrorFactory.notFound("Archivo no encontrado");
    return rows[0];
  }

  async list(legajo: string): Promise<ArchivoDTO[]> {
    const viajeId = await this.viajeId(legajo);
    const [rows] = await db.query<ArchivoRow[]>(
      "SELECT * FROM viaje_archivo WHERE viaje_id = ? ORDER BY categoria, created_at DESC",
      [viajeId],
    );
    return rows.map(toDTO);
  }

  /** Paso 1: valida y devuelve una URL firmada para que el navegador suba directo al bucket */
  async presignUpload(
    legajo: string,
    input: { nombre: unknown; mime: unknown; size: unknown; categoria: unknown },
  ): Promise<{ url: string; key: string; headers: Record<string, string> }> {
    const viajeId = await this.viajeId(legajo);

    const nombre = cleanFileName(input.nombre);
    if (!nombre) throw ErrorFactory.badRequest("El archivo no tiene nombre");
    if (!isCategoria(input.categoria)) throw ErrorFactory.badRequest("Categoría inválida");

    const mime = String(input.mime ?? "");
    const ext = ARCHIVO_MIME_EXT[mime];
    if (!ext) throw ErrorFactory.badRequest("Solo se permiten PDF e imágenes (JPG, PNG o WEBP)");

    const size = Number(input.size);
    if (!Number.isInteger(size) || size <= 0) throw ErrorFactory.badRequest("Tamaño inválido");
    if (size > ARCHIVO_MAX_BYTES) throw ErrorFactory.badRequest("El archivo supera los 10 MB");

    const key = `viajes/${viajeId}/${randomUUID()}.${ext}`;
    const { s3, bucket } = getStorage();
    const url = await getSignedUrl(
      s3,
      new PutObjectCommand({ Bucket: bucket, Key: key, ContentType: mime, ContentLength: size }),
      {
        expiresIn: UPLOAD_TTL,
        // firmar estos headers obliga al navegador a subir exactamente ese tipo y tamaño
        signableHeaders: new Set(["content-type", "content-length"]),
      },
    );

    return { url, key, headers: { "Content-Type": mime } };
  }

  /** Paso 2: el navegador ya subio; verificamos en el bucket y recien ahi guardamos en la base */
  async register(
    legajo: string,
    input: { key: unknown; nombre: unknown; categoria: unknown },
  ): Promise<ArchivoDTO> {
    const viajeId = await this.viajeId(legajo);

    const key = String(input.key ?? "");
    if (!key.startsWith(`viajes/${viajeId}/`) || key.includes("..")) {
      throw ErrorFactory.badRequest("Clave de archivo inválida");
    }
    const nombre = cleanFileName(input.nombre);
    if (!nombre) throw ErrorFactory.badRequest("El archivo no tiene nombre");
    if (!isCategoria(input.categoria)) throw ErrorFactory.badRequest("Categoría inválida");

    const { s3, bucket } = getStorage();
    let size: number;
    let mime: string;
    try {
      const head = await s3.send(new HeadObjectCommand({ Bucket: bucket, Key: key }));
      size = head.ContentLength ?? 0;
      mime = head.ContentType ?? "";
    } catch {
      throw ErrorFactory.badRequest("El archivo no se encontró en el almacenamiento. Intenta subirlo de nuevo");
    }

    if (!ARCHIVO_MIME_EXT[mime] || size <= 0 || size > ARCHIVO_MAX_BYTES) {
      await this.deleteObject(key);
      throw ErrorFactory.badRequest("El archivo subido no cumple los requisitos (PDF o imagen, hasta 10 MB)");
    }

    try {
      const [res] = await db.query<ResultSetHeader>(
        `INSERT INTO viaje_archivo (viaje_id, nombre_original, categoria, storage_key, mime, size_bytes)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [viajeId, nombre, input.categoria, key, mime, size],
      );
      const [rows] = await db.query<ArchivoRow[]>("SELECT * FROM viaje_archivo WHERE id = ?", [res.insertId]);
      logger.info("Archivo registrado", { legajo, archivoId: res.insertId });
      return toDTO(rows[0]);
    } catch (e) {
      if ((e as { code?: string }).code === "ER_DUP_ENTRY") {
        throw ErrorFactory.conflict("El archivo ya estaba registrado");
      }
      throw e;
    }
  }

  async downloadUrl(legajo: string, archivoId: number, inline: boolean): Promise<{ url: string }> {
    const row = await this.findRow(legajo, archivoId);
    const { s3, bucket } = getStorage();
    const filename = encodeURIComponent(row.nombre_original);
    const url = await getSignedUrl(
      s3,
      new GetObjectCommand({
        Bucket: bucket,
        Key: row.storage_key,
        ResponseContentType: row.mime,
        ResponseContentDisposition: `${inline ? "inline" : "attachment"}; filename*=UTF-8''${filename}`,
      }),
      { expiresIn: DOWNLOAD_TTL },
    );
    return { url };
  }

  async remove(legajo: string, archivoId: number): Promise<void> {
    const row = await this.findRow(legajo, archivoId);
    await db.query("DELETE FROM viaje_archivo WHERE id = ?", [row.id]);
    await this.deleteObject(row.storage_key);
    logger.info("Archivo eliminado", { legajo, archivoId });
  }

  /** Para borrar un legajo: leer las keys ANTES de eliminarlo (la cascada borra las filas) */
  async keysByLegajo(legajo: string): Promise<string[]> {
    const [rows] = await db.query<RowDataPacket[]>(
      `SELECT a.storage_key FROM viaje_archivo a
       JOIN viaje v ON v.id = a.viaje_id WHERE v.legajo = ?`,
      [legajo],
    );
    return rows.map((r) => r.storage_key as string);
  }

  async deleteObjects(keys: string[]): Promise<void> {
    await Promise.all(keys.map((k) => this.deleteObject(k)));
  }

  /** Nunca lanza: si falla el bucket queda un objeto huerfano, pero no se rompe la operacion principal */
  private async deleteObject(key: string): Promise<void> {
    try {
      const { s3, bucket } = getStorage();
      await s3.send(new DeleteObjectCommand({ Bucket: bucket, Key: key }));
    } catch (e) {
      logger.error("No se pudo borrar el objeto del bucket", { key, error: (e as Error).message });
    }
  }
}

export const archivoService = new ArchivoService();
