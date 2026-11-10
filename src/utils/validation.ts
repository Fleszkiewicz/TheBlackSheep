import { ErrorFactory } from '../errors/errorFactory';
import { VALIDATION, CategoriaEdadType, PagadoPorType } from "../constants/validation";
import { PasajeroDTO, DestinoDTO, DestinoServicioDTO } from "../dtos/trip.dto";

/**
 * Parsea un valor opcional a entero con validación de rango
 */
export function parseOptionalInt(
  value: string | undefined | null,
  min?: number,
  max?: number
): number | null {
  if (!value || value === '') return null;

  const parsed = parseInt(value, 10);

  if (isNaN(parsed)) {
    return null;
  }

  if (min !== undefined && parsed < min) {
    throw ErrorFactory.badRequest(`El valor debe ser mayor o igual a ${min}`);
  }

  if (max !== undefined && parsed > max) {
    throw ErrorFactory.badRequest(`El valor debe ser menor o igual a ${max}`);
  }


  return parsed;
}

/**
 * Parsea un valor opcional a string
 */
export function parseOptionalString(value: unknown): string | null {
  if (value === undefined || value === null || value === '') {
    return null;
  }
  return String(value).trim();
}

/**
 * Parsea un valor que puede ser string o número
 */
export function parseStringOrNumber(value: unknown): string | number | null {
  if (value === undefined || value === null || value === '') {
    return null;
  }

  const stringValue = String(value).trim();
  const numberValue = Number(stringValue);

  return isNaN(numberValue) ? stringValue : numberValue;
}

/**
 * Sanitiza un string limitando su longitud y eliminando espacios
 */
export function sanitizeString(
  value: string,
  maxLength: number = 100
): string {
  return value.trim().substring(0, maxLength);
}

/**
 * Valida que una fecha sea válida
 */
export function validateDate(date: Date): boolean {
  return date instanceof Date && !isNaN(date.getTime());
}

/**
 * Valida que una fecha esté en un rango válido
 */
export function validateDateRange(
  startDate: Date,
  endDate: Date
): { valid: boolean; error?: string } {
  if (!validateDate(startDate)) {
    return { valid: false, error: 'Fecha de inicio inválida' };
  }

  if (!validateDate(endDate)) {
    return { valid: false, error: 'Fecha de fin inválida' };
  }

  if (startDate >= endDate) {
    return { valid: false, error: 'La fecha de inicio debe ser anterior a la fecha de fin' };
  }




  return { valid: true };
}

const optStr = (v: unknown, max: number, label: string): string | null => {
  if (v === undefined || v === null) return null;
  const s = String(v).trim();
  if (s === "") return null;
  if (s.length > max) {
    throw ErrorFactory.badRequest(`${label} no puede superar los ${max} caracteres`);
  }
  return s;
};

const optDate = (v: unknown, label: string): string | null => {
  const s = optStr(v, 10, label);
  if (s === null) return null;
  if (!/^\d{4}-\d{2}-\d{2}$/.test(s) || Number.isNaN(Date.parse(s))) {
    throw ErrorFactory.badRequest(`${label} inválida`);
  }
  return s;
};

export function parsePasajeros(input: unknown): PasajeroDTO[] {
  if (!Array.isArray(input) || input.length === 0) {
    throw ErrorFactory.badRequest("Debe haber al menos un pasajero");
  }
  if (input.length > 30) {
    throw ErrorFactory.badRequest("Demasiados pasajeros en el viaje");
  }

  const list: PasajeroDTO[] = input.map((raw, i) => {
    if (!raw || typeof raw !== "object") {
      throw ErrorFactory.badRequest(`Pasajero ${i + 1} inválido`);
    }
    const p = raw as Record<string, unknown>;

    const apellido = optStr(p.apellido, 50, "El apellido");
    if (!apellido) {
      throw ErrorFactory.badRequest(`El apellido del pasajero ${i + 1} es obligatorio`);
    }

    const categoria = optStr(p.categoria_edad, 10, "La categoría de edad");
    if (
      categoria &&
      !(VALIDATION.TRIP.CATEGORIA_EDAD_VALUES as readonly string[]).includes(categoria)
    ) {
      throw ErrorFactory.badRequest(`Categoría de edad inválida (pasajero ${i + 1})`);
    }

    const rawId = p.pasajero_id;
    const pasajeroId =
      rawId === undefined || rawId === null || rawId === "" ? null : Number(rawId);
    if (pasajeroId !== null && (!Number.isInteger(pasajeroId) || pasajeroId <= 0)) {
      throw ErrorFactory.badRequest(`Identificador inválido (pasajero ${i + 1})`);
    }

    return {
      pasajero_id: pasajeroId,
      es_titular: p.es_titular === true || p.es_titular === "true" || p.es_titular === 1,
      dni: optStr(p.dni, 20, "El DNI")?.replace(/[.\s]/g, "") || null,
      nombre: optStr(p.nombre, 50, "El nombre"),
      apellido,
      email: optStr(p.email, 100, "El email"),
      telefono: optStr(p.telefono, 30, "El teléfono"),
      pasaporte: optStr(p.pasaporte, 20, "El pasaporte"),
      vencimiento_dni: optDate(p.vencimiento_dni, "El vencimiento del DNI"),
      vencimiento_pasaporte: optDate(p.vencimiento_pasaporte, "El vencimiento del pasaporte"),
      categoria_edad: (categoria as PasajeroDTO["categoria_edad"]) ?? null,
    };
  });

  if (list.filter((p) => p.es_titular).length !== 1) {
    throw ErrorFactory.badRequest("Debe haber exactamente un titular");
  }

  const dnis = list.map((p) => p.dni).filter(Boolean);
  if (new Set(dnis).size !== dnis.length) {
    throw ErrorFactory.badRequest("Hay un DNI repetido entre los pasajeros");
  }

  return list;
}

export function parseServicios(input: unknown, label: string): DestinoServicioDTO[] {
  if (!Array.isArray(input)) {
    throw ErrorFactory.badRequest(`Lista de servicios inválida (${label})`);
  }
  if (input.length > 50) {
    throw ErrorFactory.badRequest(`Demasiados servicios (${label})`);
  }

  return input.map((raw, i) => {
    if (!raw || typeof raw !== "object") {
      throw ErrorFactory.badRequest(`Servicio ${i + 1} inválido (${label})`);
    }
    const s = raw as Record<string, unknown>;

    const tipo = Number(s.servicio_tipo_id);
    if (!Number.isInteger(tipo) || tipo <= 0) {
      throw ErrorFactory.badRequest(`El servicio ${i + 1} no tiene tipo (${label})`);
    }

    const valor = Number(s.valor ?? 0);
    if (!Number.isFinite(valor) || valor < 0 || valor > VALIDATION.SERVICE.VALOR_MAX) {
      throw ErrorFactory.badRequest(`Valor inválido en el servicio ${i + 1} (${label})`);
    }

    const moneda = Number(s.moneda_id);
    if (moneda !== 1 && moneda !== 2) {
      throw ErrorFactory.badRequest(`Moneda inválida en el servicio ${i + 1} (${label})`);
    }

    const cotizacion =
      s.cotizacion === undefined || s.cotizacion === null || s.cotizacion === ""
        ? null
        : Number(s.cotizacion);
    if (cotizacion !== null && (!Number.isFinite(cotizacion) || cotizacion <= 0)) {
      throw ErrorFactory.badRequest(`Cotización inválida en el servicio ${i + 1} (${label})`);
    }

    const pagadoPor = String(s.pagado_por ?? "pendiente");
    if (!(VALIDATION.SERVICE.PAGADO_POR_VALUES as readonly string[]).includes(pagadoPor)) {
      throw ErrorFactory.badRequest(`"Pagado por" inválido en el servicio ${i + 1} (${label})`);
    }

    return {
      servicio_tipo_id: tipo,
      valor,
      moneda_id: moneda,
      cotizacion,
      pagado_por: pagadoPor as PagadoPorType,
      observacion: optStr(s.observacion, 255, "La observación"),
    };
  });
}

export function parseDestinos(
  input: unknown,
  rango?: { ida?: unknown; vuelta?: unknown },
): DestinoDTO[] {
  if (!Array.isArray(input)) {
    throw ErrorFactory.badRequest("Lista de destinos inválida");
  }
  if (input.length > 20) {
    throw ErrorFactory.badRequest("Demasiados destinos en el viaje");
  }

  const ida = rango?.ida ? String(rango.ida).slice(0, 10) : null;
  const vuelta = rango?.vuelta ? String(rango.vuelta).slice(0, 10) : null;

  return input.map((raw, i) => {
    if (!raw || typeof raw !== "object") {
      throw ErrorFactory.badRequest(`Destino ${i + 1} inválido`);
    }
    const d = raw as Record<string, unknown>;

    const nombre = optStr(d.destino, 100, "El destino");
    if (!nombre) {
      throw ErrorFactory.badRequest(`El nombre del destino ${i + 1} es obligatorio`);
    }

    const desde = optDate(d.fecha_desde, `La fecha desde de ${nombre}`);
    const hasta = optDate(d.fecha_hasta, `La fecha hasta de ${nombre}`);
    if (desde && hasta && hasta < desde) {
      throw ErrorFactory.badRequest(
        `En ${nombre}, la fecha hasta no puede ser anterior a la fecha desde`,
      );
    }
    if (ida && vuelta) {
      for (const f of [desde, hasta]) {
        if (f && (f < ida || f > vuelta)) {
          throw ErrorFactory.badRequest(
            `Las fechas de ${nombre} exceden el rango de fechas del viaje`,
          );
        }
      }
    }

    const rawId = d.destino_id;
    const destinoId =
      rawId === undefined || rawId === null || rawId === "" ? null : Number(rawId);
    if (destinoId !== null && (!Number.isInteger(destinoId) || destinoId <= 0)) {
      throw ErrorFactory.badRequest(`Identificador inválido en ${nombre}`);
    }

    return {
      destino_id: destinoId,
      destino: nombre,
      fecha_desde: desde,
      fecha_hasta: hasta,
      servicios: d.servicios === undefined ? [] : parseServicios(d.servicios, nombre),
    };
  });
}