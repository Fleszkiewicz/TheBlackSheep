import { SucursalFilterType, SucursalType } from "../constants/sucursal";

export interface CreateExpenseDTO {
    motivo: string;
    fecha: string; // "YYYY-MM-DD"
    moneda: number; // 1 = ARS, 2 = USD (ids de la tabla moneda)
    cotizacion?: number | null;
    monto: number;
    sucursal: SucursalType;
}

export interface GetExpensesQueryDTO {
    year: number;
    month?: number;
    moneda?: number;
    sucursal?: SucursalFilterType; // sin valor = todas
}

export interface ExpenseResponseDTO {
    id: number;
    motivo: string;
    fecha: string;
    moneda: string;
    cotizacion: number | null;
    monto: number;
}