import { PagadoPorType, DestinoType, EstadoType, PagoType } from "../constants/validation";

export interface CreateTripDTO {
  nombre: string;
  apellido: string;
  fecha: Date;
  valor_total: number;
  valor_total_usd?: number;
  sucursal_id: number;
  pago: PagoType;
  destino: DestinoType;
  fecha_ida: Date;
  fecha_vuelta: Date;
  moneda: number;
  cotizacion?: number | null;
  servicios: CreateServiceDTO[];
}

export interface UpdateTripDTO {
  nombre?: string;
  apellido?: string;
  valor_total?: number;
  valor_total_usd?: number;
  fecha?: Date;
  pago?: PagoType;
  destino?: DestinoType;
  fecha_ida?: Date;
  fecha_vuelta?: Date;
  moneda?: number;
  cotizacion?: number | null;
  servicios?: UpdateServiceInTripDTO[];
}

export interface CreateServiceDTO {
  id: number;
  valor: number;
  pagado_por: PagadoPorType;
  moneda: number;
  observacion?: string | null;
  cotizacion?: number | null;
}

export interface UpdateServiceInTripDTO {
  id: number;
  valor: number;
  pagado_por: PagadoPorType;
  moneda: number;
  cotizacion: number | null;
  observacion: string | null;
}

export interface TripResponseDTO {
  id: string;
  estado: EstadoType;
  cancelado?: 0 | 1;
  motivo_cancelacion?: string | null;
  fecha_cancelacion?: Date | null;
  es_legado?: 0 | 1;
  fecha: Date;
  fecha_ida: Date;
  fecha_vuelta: Date;
  moneda: string;
  pago: PagoType | null;
  destino: DestinoType;
  nombre: string | null;
  apellido: string;
  valor_total: number;
  valor_total_usd?: number | null;
  ganancia: number;
  ganancia_usd?: number | null;
  costo: number;
  costo_usd?: number | null;
  servicios: ServiceInTripDTO[];
  cotizacion: number;
}

export interface CancelTripDTO {
  motivo: string;
}

export interface ServiceInTripDTO {
  id: number;
  valor: number;
  nombre: string;
  pagado_por: PagadoPorType;
  cotizacion: number;
  moneda: string;
}

export interface GetTripsQueryDTO {
  filter?: string | number;
  limit?: number;
  page?: number;
  month?: number;
  year?: number;
  search?: string;
}

export interface PaginatedTripsResponseDTO {
  data: TripResponseDTO[];
  pagination: PaginationMetaDTO;
}

export interface PaginationMetaDTO {
  currentPage: number;
  totalItems: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
  limit: number;
}
