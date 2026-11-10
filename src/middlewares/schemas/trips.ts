import { checkSchema, Schema } from "express-validator";

const tripPostSchemaValidator: Schema = {

  valor_total: {
    in: ["body"],
    isInt: {
      errorMessage: "El valor total debe ser un número",
      bail: true,
    },
    notEmpty: {
      errorMessage: "El valor total es obligatorio",
      bail: true,
    },
    trim: true,
  },
  destino: {
    in: ["body"],
    isIn: {
      options: [["internacional", "nacional"]],
      errorMessage: "El destino debe ser 'internacional' o 'nacional'",
      bail: true,
    },
    isString: true,
    notEmpty: {
      errorMessage: "El destino es obligatorio",
      bail: true,
    },
    trim: true,
  },
  cotizacion: {
    in: ["body"],
    optional: { options: { nullable: true } },
    isFloat: {
      errorMessage: "La cotización debe ser un número decimal",
      bail: true,
    },
    toFloat: true,
  },
  sucursal_id: {
    in: ["body"],
    isIn: { options: [[1, 2]], errorMessage: "Sucursal inválida", bail: true },
  },

  pago: {
    in: ["body"],
    isIn: {
      options: [["contado_efectivo", "contado_transferencia", "cuotas", "financiacion"]],
      errorMessage: "Forma de pago inválida",
    },
  },
  pasajeros: {
    in: ["body"],
    isArray: { options: { min: 1 }, errorMessage: "Debe haber al menos un pasajero" },
  },
};

const tripPatchSchemaValidator: Schema = {};

for (const key in tripPostSchemaValidator) {
  tripPatchSchemaValidator[key] = {
    ...tripPostSchemaValidator[key],
    optional: true,
  };
}

const tripDeleteSchemaValidator: Schema = {
  tid: {
    in: ["params"],
    isString: {
      errorMessage: "El ID del viaje debe ser una cadena de texto",
      bail: true,
    },
    trim: true,
    isLength: {
      options: { min: 1, max: 20 },
      errorMessage: "El ID del viaje no es válido",
    },
  },
};

const tripCancelSchemaValidator: Schema = {
  tid: {
    in: ["params"],
    isString: {
      errorMessage: "El ID del viaje debe ser una cadena de texto",
      bail: true,
    },
    trim: true,
    isLength: {
      options: { min: 1, max: 20 },
      errorMessage: "El ID del viaje no es válido",
    },
  },
  motivo: {
    in: ["body"],
    isString: {
      errorMessage: "El motivo debe ser una cadena de texto",
      bail: true,
    },
    trim: true,
    notEmpty: {
      errorMessage: "El motivo de la cancelación es obligatorio",
      bail: true,
    },
    isLength: {
      options: { max: 255 },
      errorMessage: "El motivo no puede superar los 255 caracteres",
    },
  },
};

export const tripPostSchema = checkSchema(tripPostSchemaValidator);
export const tripPatchSchema = checkSchema(tripPatchSchemaValidator);
export const tripDeleteSchema = checkSchema(tripDeleteSchemaValidator);
export const tripCancelSchema = checkSchema(tripCancelSchemaValidator);
