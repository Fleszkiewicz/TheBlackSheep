-- 022: archivos adjuntos por legajo (los binarios viven en Cloudflare R2, aca solo los metadatos)
CREATE TABLE IF NOT EXISTS viaje_archivo (
  id INT NOT NULL AUTO_INCREMENT,
  viaje_id INT NOT NULL,
  nombre_original VARCHAR(255) NOT NULL,
  categoria VARCHAR(30) NOT NULL DEFAULT 'Otros',
  storage_key VARCHAR(500) NOT NULL,
  mime VARCHAR(100) NOT NULL,
  size_bytes INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_viaje_archivo_key (storage_key),
  KEY idx_viaje_archivo_viaje (viaje_id),
  CONSTRAINT fk_viaje_archivo_viaje FOREIGN KEY (viaje_id) REFERENCES viaje (id) ON DELETE CASCADE
);;
