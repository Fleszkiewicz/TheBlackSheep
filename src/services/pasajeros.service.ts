import { PasajeroRepository } from "../repositories/pasajero.repository";
import { PasajeroBusquedaDTO } from "../dtos/pasajero.dto";
import { ErrorFactory } from "../errors/errorFactory";

export class PasajerosService {
    constructor(private pasajeroRepository: PasajeroRepository) { }

    async searchByDni(rawDni: string): Promise<PasajeroBusquedaDTO[]> {
        const dni = rawDni.replace(/[.\s]/g, "");
        if (dni.length < 3) return [];
        if (!/^[0-9A-Za-z]{3,20}$/.test(dni)) {
            throw ErrorFactory.badRequest("El DNI contiene caracteres inválidos");
        }
        return this.pasajeroRepository.searchByDni(dni, 8);
    }
}