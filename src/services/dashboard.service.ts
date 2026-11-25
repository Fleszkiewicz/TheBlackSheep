import type { RowDataPacket } from "mysql2";
import { db } from "../db/db";
import { ErrorFactory } from "../errors/errorFactory";

/** Vistas del carrusel del Dashboard → SP que las calcula (migración 026) */
const VISTAS = {
  expedientes: {
    sp: "dashboard_expedientes",
    sets: ["kpis", "estados", "sucursales", "evolucion", "motivos"],
  },
  productos: {
    sp: "dashboard_productos",
    sets: ["kpis", "destinos", "servicios", "tipos", "edades"],
  },
  finanzas: {
    sp: "dashboard_finanzas",
    sets: ["kpis", "mensual", "pagos", "monedas", "socios"],
  },
  expensas: {
    sp: "dashboard_expensas",
    sets: ["kpis", "mensual", "sucursales"],
  },
} as const;

export type DashboardVista = keyof typeof VISTAS;

export const isDashboardVista = (v: unknown): v is DashboardVista =>
  typeof v === "string" && Object.prototype.hasOwnProperty.call(VISTAS, v);

export interface DashboardQuery {
  anio: number;
  mes: number | null;
  sucursal: number | null;
}

/** Columnas de texto; el resto llega de MySQL como número o DECIMAL (texto) y se convierte a number */
const TEXT_KEYS = new Set([
  "estado",
  "sucursal",
  "destino",
  "nombre",
  "tipo",
  "categoria_edad",
  "pago",
  "moneda",
  "socio",
  "categoria",
]);

const normalizeRow = (row: RowDataPacket): Record<string, unknown> => {
  const out: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(row)) {
    out[key] = value === null || TEXT_KEYS.has(key) ? value : Number(value);
  }
  return out;
};

export class DashboardService {
  async getVista(vista: DashboardVista, query: DashboardQuery): Promise<Record<string, unknown>> {
    const { sp, sets } = VISTAS[vista];
    const [result] = await db.query<RowDataPacket[][]>(`CALL ${sp}(?, ?, ?)`, [
      query.anio,
      query.mes,
      query.sucursal,
    ]);

    const resultSets = (result as unknown[]).filter(Array.isArray) as RowDataPacket[][];
    if (resultSets.length < sets.length) {
      throw ErrorFactory.internal("Respuesta inesperada del Dashboard");
    }

    const data: Record<string, unknown> = {};
    sets.forEach((name, i) => {
      const rows = resultSets[i].map(normalizeRow);
      data[name] = name === "kpis" ? (rows[0] ?? {}) : rows;
    });
    return data;
  }
}

export const dashboardService = new DashboardService();
