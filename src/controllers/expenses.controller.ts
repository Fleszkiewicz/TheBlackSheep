import { NextFunction, Request, Response } from "express";
import { ExpensesService } from "../services/expenses.service";
import { ResponseBuilder } from "../core/ResponseBuilder";
import { parseOptionalInt } from "../utils/validation";



export class ExpensesController {
    constructor(private expensesService: ExpensesService) { }

    getExpenses = async (
        req: Request,
        res: Response,
        next: NextFunction,
    ): Promise<void> => {
        try {
            const year =
                parseOptionalInt(req.query.year as string, 2000, 2100) ??
                new Date().getFullYear();
            const month = parseOptionalInt(req.query.month as string, 1, 12);
            const moneda = parseOptionalInt(req.query.moneda as string, 1, 2);

            // Solo se aceptan sucursales reales; cualquier otro valor = sin filtro
            const sucursalParam = req.query.sucursal;
            const sucursal =
                sucursalParam === "baradero" || sucursalParam === "hurlingham"
                    ? sucursalParam
                    : undefined;

            const expenses = await this.expensesService.getExpenses({
                year,
                month: month ?? undefined,
                moneda: moneda ?? undefined,
                sucursal,
            });

            res.status(200).json(
                ResponseBuilder.success({
                    data: expenses,
                    message: "Gastos obtenidos exitosamente",
                }),
            );
        } catch (error) {
            next(error);
        }
    };

    createExpense = async (
        req: Request,
        res: Response,
        next: NextFunction,
    ): Promise<void> => {
        try {
            const { motivo, fecha, moneda, cotizacion, monto, sucursal } = req.body;

            const result = await this.expensesService.createExpense({
                motivo,
                fecha,
                moneda,
                cotizacion,
                monto,
                sucursal,
            });

            res
                .status(201)
                .json(ResponseBuilder.created(result, "Gasto creado exitosamente"));
        } catch (error) {
            next(error);
        }
    };

    deleteExpense = async (
        req: Request,
        res: Response,
        next: NextFunction,
    ): Promise<void> => {
        try {
            const { eid } = req.params;
            await this.expensesService.deleteExpense(Number(eid));

            res
                .status(200)
                .json(ResponseBuilder.deleted("Gasto eliminado exitosamente"));
        } catch (error) {
            next(error);
        }
    };
}