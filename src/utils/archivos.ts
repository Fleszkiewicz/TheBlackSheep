export const ARCHIVO_MAX_BYTES = 10 * 1024 * 1024;

export const ARCHIVO_CATEGORIAS = ["Pasajeros", "Servicios", "Cobranza", "Otros"] as const;
export type ArchivoCategoria = (typeof ARCHIVO_CATEGORIAS)[number];

/** mime permitido -> extension que se usa en la key del bucket */
export const ARCHIVO_MIME_EXT: Record<string, string> = {
  "application/pdf": "pdf",
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
};

export const isCategoria = (v: unknown): v is ArchivoCategoria =>
  typeof v === "string" && (ARCHIVO_CATEGORIAS as readonly string[]).includes(v);

/** Deja solo el nombre (sin rutas), sin caracteres de control y con largo acotado */
export function cleanFileName(raw: unknown): string {
  const base = String(raw ?? "")
    .replace(/[\\/]+/g, "_")
    .replace(/[\u0000-\u001f\u007f]/g, "")
    .trim();
  return base.slice(0, 255);
}
