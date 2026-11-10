import { PagadoPorType, DestinoType, EstadoType, PagoType, CategoriaEdadType } from "../constants/validation";

export interface CreateTripDTO {
  pasajeros: PasajeroDTO[];
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
  destinos: DestinoDTO[];
}

export interface UpdateTripDTO {
  pasajeros?: PasajeroDTO[];
  valor_total?: number;
  valor_total_usd?: number;
  fecha?: Date;
  pago?: PagoType;
  destino?: DestinoType;
  fecha_ida?: Date;
  fecha_vuelta?: Date;
  moneda?: number;
  cotizacion?: number | null;
  destinos?: DestinoDTO[];
  servicios_sin_destino?: DestinoServicioDTO[];
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
  pasajeros?: PasajeroDTO[];
  valor_total: number;
  valor_total_usd?: number | null;
  ganancia: number;
  ganancia_usd?: number | null;
  costo: number;
  costo_usd?: number | null;
  servicios: ServiceInTripDTO[];
  cotizacion: number;
  destinos?: DestinoDTO[];
  servicios_sin_destino?: DestinoServicioDTO[];
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

export interface PasajeroDTO {
  pasajero_id?: number | null;
  es_titular: boolean;
  dni?: string | null;
  nombre?: string | null;
  apellido: string;
  email?: string | null;
  telefono?: string | null;
  pasaporte?: string | null;
  vencimiento_dni?: string | null;
  vencimiento_pasaporte?: string | null;
  categoria_edad?: CategoriaEdadType | null;
}

export interface DestinoServicioDTO {
  servicio_tipo_id: number;
  valor: number;
  moneda_id: number;
  cotizacion?: number | null;
  pagado_por: PagadoPorType;
  observacion?: string | null;
}

export interface DestinoDTO {
  destino_id?: number | null;
  destino: string;
  fecha_desde?: string | null;
  fecha_hasta?: string | null;
  servicios: DestinoServicioDTO[];
}