import { checkSchema, Schema } from "express-validator";

const expensePostSchemaValidator: Schema = {
    motivo: {
        in: ["body"],
        isString: { errorMessage: "El motivo debe ser texto", bail: true },
        trim: true,
        notEmpty: { errorMessage: "El motivo es obligatorio", bail: true },
        isLength: {
            options: { max: 100 },
            errorMessage: "El motivo no puede superar los 100 caracteres",
        },
    },
    fecha: {
        in: ["body"],
        matches: {
            options: [/^\d{4}-\d{2}-\d{2}$/],
            errorMessage: "La fecha debe tener formato yyyy-mm-dd",
            bail: true,
        },
        isISO8601: {
            options: { strict: true },
            errorMessage: "La fecha no es válida",
        },
    },
    moneda: {
        in: ["body"],
        isIn: {
            options: [[1, 2]],
            errorMessage: "La moneda debe ser 1 (ARS) o 2 (USD)",
        },
        toInt: true,
    },
    monto: {
        in: ["body"],
        isFloat: {
            options: { gt: 0 },
            errorMessage: "El monto debe ser mayor a 0",
        },
        toFloat: true,
    },
    cotizacion: {
        in: ["body"],
        optional: { options: { nullable: true } },
        isFloat: {
            options: { gt: 0 },
            errorMessage: "La cotización debe ser mayor a 0",
        },
        toFloat: true,
    },
    sucursal: {
        in: ["body"],
        isIn: {
            options: [["baradero", "hurlingham", "ambas"]],
            errorMessage: "La sucursal debe ser 'baradero', 'hurlingham' o 'ambas'",
        },
    },
};



const expenseDeleteSchemaValidator: Schema = {
    eid: {
        in: ["params"],
        isInt: {
            options: { min: 1 },
            errorMessage: "El ID del gasto debe ser un número entero",
        },
        toInt: true,
    },
};

export const expensePostSchema = checkSchema(expensePostSchemaValidator);
export const expenseDeleteSchema = checkSchema(expenseDeleteSchemaValidator);