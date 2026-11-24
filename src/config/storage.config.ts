import { S3Client } from "@aws-sdk/client-s3";

let client: S3Client | null = null;

/**
 * Cliente S3 apuntando a Cloudflare R2.
 * Se crea de forma perezosa para leer process.env cuando dotenv ya cargo,
 * y para que la app arranque aunque todavia no esten las variables R2_*.
 */
export function getStorage(): { s3: S3Client; bucket: string } {
  const accountId = process.env.R2_ACCOUNT_ID;
  const accessKeyId = process.env.R2_ACCESS_KEY_ID;
  const secretAccessKey = process.env.R2_SECRET_ACCESS_KEY;
  const bucket = process.env.R2_BUCKET;

  if (!accountId || !accessKeyId || !secretAccessKey || !bucket) {
    throw new Error(
      "Almacenamiento no configurado: faltan R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY o R2_BUCKET",
    );
  }

  if (!client) {
    client = new S3Client({
      region: "auto",
      endpoint: process.env.R2_ENDPOINT || `https://${accountId}.r2.cloudflarestorage.com`,
      credentials: { accessKeyId, secretAccessKey },
      forcePathStyle: !!process.env.R2_ENDPOINT, // MinIO/local necesita path-style
      // R2 no acepta los checksums automaticos que agregan las versiones nuevas del SDK
      requestChecksumCalculation: "WHEN_REQUIRED",
      responseChecksumValidation: "WHEN_REQUIRED",
    });
  }
  return { s3: client, bucket };
}
