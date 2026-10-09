import { ExpenseRepository } from "../repositories/expense.repository";
import {
    CreateExpenseDTO,
    ExpenseResponseDTO,
    GetExpensesQueryDTO,
} from "../dtos/expense.dto";
import { ErrorFactory } from "../errors/errorFactory";
import logger from "../config/logger.config";

export class ExpensesService {
    constructor(private expenseRepository: ExpenseRepository) { }

    async getExpenses(query: GetExpensesQueryDTO): Promise<ExpenseResponseDTO[]> {
        logger.info("Fetching expenses", { ...query });
        return this.expenseRepository.findAll(query);
    }

    async createExpense(data: CreateExpenseDTO): Promise<{ id: number }> {
        const isUsd = data.moneda === 2;

        if (isUsd && (!data.cotizacion || data.cotizacion <= 0)) {
            throw ErrorFactory.badRequest(
                "La cotización es obligatoria y debe ser mayor a 0 para gastos en USD",
            );
        }

        // En ARS la cotización no tiene sentido: se guarda vacía
        const id = await this.expenseRepository.create({
            ...data,
            cotizacion: isUsd ? data.cotizacion : null,
        });

        logger.info("Expense created", { expenseId: id });
        return { id };
    }

    async deleteExpense(id: number): Promise<{ id: number }> {
        const affected = await this.expenseRepository.delete(id);

        if (affected === 0) {
            throw ErrorFactory.notFound("Gasto no encontrado");
        }

        logger.info("Expense deleted", { expenseId: id });
        return { id };
    }
}