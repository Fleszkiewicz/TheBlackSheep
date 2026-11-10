import { ITripRepository } from "../interfaces/trip.repository.interface";
import {
  CreateTripDTO,
  UpdateTripDTO,
  GetTripsQueryDTO,
  PaginatedTripsResponseDTO,
  TripResponseDTO,
} from "../dtos/trip.dto";
import { TransactionManager } from "../core/TransactionManager";
import { ResponseBuilder } from "../core/ResponseBuilder";
import { ErrorFactory } from "../errors/errorFactory";
import { VALIDATION } from "../constants/validation";
import {
  sanitizeString,
  validateDate,
  validateDateRange,
} from "../utils/validation";
import logger from "../config/logger.config";

export class TripService {
  constructor(
    private tripRepository: ITripRepository,
  ) { }

  async getTrips(query: GetTripsQueryDTO): Promise<PaginatedTripsResponseDTO> {
    let filter = query.filter ?? null;
    if (filter !== null && typeof filter === "string") {
      filter = sanitizeString(filter, VALIDATION.DB.MAX_STRING_LENGTH);
    }

    const limit = query.limit ?? 10;
    const page = query.page ?? 1;
    const offset = (page - 1) * limit;

    if (limit < 1 || limit > VALIDATION.DB.MAX_STRING_LENGTH) {
      throw ErrorFactory.badRequest("Límite inválido");
    }

    if (offset < 0) {
      throw ErrorFactory.badRequest("Página inválida");
    }

    const month = query.month ?? null;
    const year = query.year ?? null;

    if (
      month !== null &&
      (month < VALIDATION.FINANCE.MIN_MONTH ||
        month > VALIDATION.FINANCE.MAX_MONTH)
    ) {
      throw ErrorFactory.badRequest("Mes inválido");
    }

    if (year !== null && year < 2000) {
      throw ErrorFactory.badRequest("Año inválido");
    }

    const search = query.search ? sanitizeString(query.search, 50) || null : null;

    logger.info("Fetching trips", { filter, limit, offset, month, year, search });

    const { data, total } = await this.tripRepository.findAll(
      filter,
      limit,
      offset,
      month,
      year,
      search,
    );

    const pagination = ResponseBuilder.buildPagination(page, limit, total);
    return {
      data,
      pagination,
    };
  }

  async getTrip(id: string): Promise<TripResponseDTO> {
    logger.info("Fetching trip", { tripId: id });

    const trip = await this.tripRepository.findById(id);

    if (!trip) {
      throw ErrorFactory.notFound("Viaje no encontrado");
    }

    return trip;
  }

  async createTrip(data: CreateTripDTO): Promise<{ id: string }> {
    this.validateTripDates(data.fecha_ida, data.fecha_vuelta);

    const titular = data.pasajeros.find((p) => p.es_titular);
    logger.info("Creating trip", { apellido: titular?.apellido, destinosCount: data.destinos.length });

    const tripId = await TransactionManager.execute(async (conn) => {
      const id = await this.tripRepository.create(
        {
          pasajeros: data.pasajeros,
          valor_total: data.valor_total,
          valor_total_usd: data.valor_total_usd,
          sucursal_id: data.sucursal_id,
          destino: data.destino,
          fecha: data.fecha,
          fecha_ida: data.fecha_ida,
          fecha_vuelta: data.fecha_vuelta,
          moneda: data.moneda,
          cotizacion: data.cotizacion,
          pago: data.pago,
          destinos: data.destinos,
        },
        conn,
      );

      logger.info("Trip created successfully", { tripId: id });
      return id;
    });

    return { id: tripId };
  }

  async updateTrip(id: string, data: UpdateTripDTO): Promise<{ id: string }> {
    if (data.fecha_ida && data.fecha_vuelta) {
      this.validateTripDates(data.fecha_ida, data.fecha_vuelta);
    }

    logger.info("Updating trip", { tripId: id });

    const tripId = await TransactionManager.execute(async (conn) => {
      const updatedId = await this.tripRepository.update(
        id,
        {
          pasajeros: data.pasajeros,
          valor_total: data.valor_total,
          valor_total_usd: data.valor_total_usd,
          destino: data.destino,
          fecha: data.fecha,
          fecha_ida: data.fecha_ida,
          fecha_vuelta: data.fecha_vuelta,
          moneda: data.moneda,
          cotizacion: data.cotizacion,
          pago: data.pago,
          destinos: data.destinos,
          servicios_sin_destino: data.servicios_sin_destino,
        },
        conn,
      );

      logger.info("Trip updated successfully", { tripId: updatedId });
      return updatedId;
    });

    return { id: tripId };
  }

  async deleteTrip(id: string): Promise<{ id: string }> {
    logger.info("Deleting trip", { tripId: id });

    const deletedId = await TransactionManager.execute(async (conn) => {
      return await this.tripRepository.delete(id, conn);
    });

    logger.info("Trip deleted successfully", { tripId: deletedId });
    return { id: deletedId };
  }

  async cancelTrip(id: string, motivo: string): Promise<{ id: string }> {
    logger.info("Cancelling trip", { tripId: id });

    const trip = await this.tripRepository.findById(id);
    if (!trip) {
      throw ErrorFactory.notFound("Viaje no encontrado");
    }
    if (trip.cancelado === 1) {
      throw ErrorFactory.conflict("El viaje ya está cancelado");
    }

    await TransactionManager.execute(async (conn) => {
      await this.tripRepository.cancel(id, motivo, conn);
    });

    logger.info("Trip cancelled successfully", { tripId: id });
    return { id };
  }

  async revertTripCancellation(id: string): Promise<{ id: string }> {
    logger.info("Reverting trip cancellation", { tripId: id });

    const trip = await this.tripRepository.findById(id);
    if (!trip) {
      throw ErrorFactory.notFound("Viaje no encontrado");
    }
    if (trip.cancelado !== 1) {
      throw ErrorFactory.conflict("El viaje ya no está cancelado");
    }

    await TransactionManager.execute(async (conn) => {
      await this.tripRepository.revertCancel(id, conn);
    });

    logger.info("Trip cancellation reverted", { tripId: id });
    return { id };
  }

  private validateTripDates(startDate: Date, endDate: Date): void {
    if (!validateDate(startDate)) {
      throw ErrorFactory.badRequest("Fecha de ida inválida");
    }

    if (!validateDate(endDate)) {
      throw ErrorFactory.badRequest("Fecha de vuelta inválida");
    }

    const validation = validateDateRange(startDate, endDate);
    if (!validation.valid) {
      throw ErrorFactory.badRequest(validation.error || "Error en las fechas");
    }
  }
}