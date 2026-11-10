export interface PasajeroBusquedaDTO {
    id: number;
    dni: string;
    nombre: string | null;
    apellido: string;
    email: string | null;
    telefono: string | null;
    pasaporte: string | null;
    vencimiento_dni: string | null;
    vencimiento_pasaporte: string | null;
}