CREATE TABLE expensa (
  id INT NOT NULL AUTO_INCREMENT,
  motivo VARCHAR(100) NOT NULL,
  fecha DATE NOT NULL,
  moneda_id INT NOT NULL,
  cotizacion DECIMAL(12,2) NULL,
  monto DECIMAL(12,2) UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY fk_expensa_moneda_idx (moneda_id),
  KEY idx_expensa_fecha (fecha),
  CONSTRAINT fk_expensa_moneda FOREIGN KEY (moneda_id) REFERENCES moneda (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci