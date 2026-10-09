import { Router } from "express";
import DIContainer from "../core/DIContainer";
import { validateRequest } from "../middlewares/validateRequest";
import {
    expenseDeleteSchema,
    expensePostSchema,
} from "../middlewares/schemas/expenses";

const router = Router();

router.get("/", DIContainer.getExpensesController().getExpenses);

router.post(
    "/",
    expensePostSchema,
    validateRequest,
    DIContainer.getExpensesController().createExpense,
);

router.delete(
    "/:eid",
    expenseDeleteSchema,
    validateRequest,
    DIContainer.getExpensesController().deleteExpense,
);

export default router;