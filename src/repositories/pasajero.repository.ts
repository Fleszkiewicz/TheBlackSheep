import { QueryExecutor } from "../core/QueryExecutor";
import { PasajeroBusquedaDTO } from "../dtos/pasajero.dto";

export class PasajeroRepository {
    async searchByDni(dniPrefix: string, limit: number): Promise<PasajeroBusquedaDTO[]> {
        return QueryExecutor.executeSelect<PasajeroBusquedaDTO>(
            `SELECT id, dni, nombre, apellido, email, telefono, pasaporte,
              DATE_FORMAT(vencimiento_dni, '%Y-%m-%d') AS vencimiento_dni,
              DATE_FORMAT(vencimiento_pasaporte, '%Y-%m-%d') AS vencimiento_pasaporte
       FROM pasajeros
       WHERE dni IS NOT NULL AND dni LIKE ?
       ORDER BY dni
       LIMIT ?`,
            [`${dniPrefix}%`, limit],
        );
    }
}