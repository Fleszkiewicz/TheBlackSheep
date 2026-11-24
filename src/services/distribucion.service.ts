import type { RowDataPacket } from "mysql2";
import { db } from "../db/db";
import { ErrorFactory } from "../errors/errorFactory";
import logger from "../config/logger.config";

export const SOCIOS = ["pablo", "soledad", "marian"] as const;
export type Socio = (typeof SOCIOS)[number];

export const isSocio = (v: unknown): v is Socio =>
  typeof v === "string" && (SOCIOS as readonly string[]).includes(v);

export interface PagoSocioDTO {
  socio: Socio;
  monto_ars: number;
  monto_usd: number;
  fecha: string;
}

interface PagoRow extends RowDataPacket {
  socio: Socio;
  monto_ars: string;
  monto_usd: string;
  fecha: string;
}

export class DistribucionService {
  private async viajeId(legajo: string): Promise<number> {
    const [rows] = await db.query<RowDataPacket[]>("SELECT id FROM viaje WHERE legajo = ?", [legajo]);
    if (rows.length === 0) throw ErrorFactory.notFound("Viaje no encontrado");
    return rows[0].id as number;
  }

  /** Socios que ya cobraron este legajo (los que no aparecen, estan pendientes) */
  async list(legajo: string): Promise<PagoSocioDTO[]> {
    const viajeId = await this.viajeId(legajo);
    return this.listById(viajeId);
  }

  private async listById(viajeId: number): Promise<PagoSocioDTO[]> {
    const [rows] = await db.query<PagoRow[]>(
      `SELECT socio, monto_ars, monto_usd, DATE_FORMAT(abonado_at, '%Y-%m-%d') AS fecha
       FROM viaje_socio_pago WHERE viaje_id = ? ORDER BY abonado_at`,
      [viajeId],
    );
    return rows.map((r) => ({
      socio: r.socio,
      monto_ars: Number(r.monto_ars),
      monto_usd: Number(r.monto_usd),
      fecha: r.fecha,
    }));
  }

  /**
   * Marca o desmarca como abonado. Al marcar guarda el monto de ese momento
   * (un tercio de la ganancia) para poder controlar liquidaciones futuras.
   * Marcar dos veces no pisa el registro original.
   */
  async setAbonado(legajo: string, socio: unknown, abonado: unknown): Promise<PagoSocioDTO[]> {
    if (!isSocio(socio)) throw ErrorFactory.badRequest("Socio inválido");
    if (typeof abonado !== "boolean") throw ErrorFactory.badRequest("El campo 'abonado' debe ser verdadero o falso");

    const viajeId = await this.viajeId(legajo);

    if (abonado) {
      await db.query(
        `INSERT INTO viaje_socio_pago (viaje_id, socio, monto_ars, monto_usd, abonado_at)
         SELECT id, ?, ROUND(COALESCE(ganancia, 0) / 3, 2), ROUND(COALESCE(ganancia_usd, 0) / 3, 2),
                UTC_TIMESTAMP() - INTERVAL 3 HOUR
         FROM viaje WHERE id = ?
         ON DUPLICATE KEY UPDATE viaje_id = viaje_id`,
        [socio, viajeId],
      );
    } else {
      await db.query("DELETE FROM viaje_socio_pago WHERE viaje_id = ? AND socio = ?", [viajeId, socio]);
    }

    logger.info("Distribucion de ganancias actualizada", { legajo, socio, abonado });
    return this.listById(viajeId);
  }
}

export const distribucionService = new DistribucionService();
