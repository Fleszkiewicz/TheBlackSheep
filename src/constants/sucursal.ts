// Los ids tienen que coincidir con las filas que inserta la migración 003.
export const SUCURSAL = {
    IDS: { baradero: 1, hurlingham: 2 },
    // "ambas" no es una sucursal: en la base se guarda como NULL
    VALUES: ["baradero", "hurlingham", "ambas"],
} as const;

export type SucursalType = (typeof SUCURSAL.VALUES)[number];
export type SucursalFilterType = Exclude<SucursalType, "ambas">;