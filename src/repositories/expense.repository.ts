import { PoolConnection } from "mysql2/promise";
import { QueryExecutor } from "../core/QueryExecutor";
import { SUCURSAL } from "../constants/sucursal";
import {
    CreateExpenseDTO,
    ExpenseResponseDTO,
    GetExpensesQueryDTO,
} from "../dtos/expense.dto";

export class ExpenseRepository {
    async findAll(
        query: GetExpensesQueryDTO,
        conn?: PoolConnection,
    ): Promise<ExpenseResponseDTO[]> {
        const conditions = ["YEAR(e.fecha) = ?"];
        const params: (number | string)[] = [query.year];

        if (query.month) {
            conditions.push("MONTH(e.fecha) = ?");
            params.push(query.month);
        }
        if (query.moneda) {
            conditions.push("e.moneda_id = ?");
            params.push(query.moneda);
        }
        if (query.sucursal) {
            conditions.push("e.sucursal_id = ?");
            params.push(SUCURSAL.IDS[query.sucursal]);
        }

        const rows = await QueryExecutor.executeSelect<any>(
            `SELECT
         e.id,
         e.motivo,
         DATE_FORMAT(e.fecha, '%Y-%m-%d') AS fecha,
         m.moneda,
         e.cotizacion,
         e.monto
       FROM expensa e
       INNER JOIN moneda m ON m.id = e.moneda_id
       WHERE ${conditions.join(" AND ")}
       ORDER BY e.fecha DESC, e.id DESC`,
            params,
            conn,
        );

        return rows.map((r) => ({
            ...r,
            cotizacion: r.cotizacion === null ? null : Number(r.cotizacion),
            monto: Number(r.monto),
        }));
    }

    async create(data: CreateExpenseDTO, conn?: PoolConnection): Promise<number> {
        // "ambas" se guarda como NULL; las demás, con el id de la sucursal
        const sucursalId =
            data.sucursal === "ambas" ? null : SUCURSAL.IDS[data.sucursal];

        return QueryExecutor.executeInsert(
            "INSERT INTO expensa (motivo, fecha, moneda_id, cotizacion, monto, sucursal_id) VALUES (?, ?, ?, ?, ?, ?)",
            [
                data.motivo,
                data.fecha,
                data.moneda,
                data.cotizacion ?? null,
                data.monto,
                sucursalId,
            ],
            conn,
        );
    }

    async delete(id: number, conn?: PoolConnection): Promise<number> {
        return QueryExecutor.executeDelete(
            "DELETE FROM expensa WHERE id = ?",
            [id],
            conn,
        );
    }
}