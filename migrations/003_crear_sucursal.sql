CREATE TABLE sucursal (
  id TINYINT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  prefijo CHAR(1) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sucursal_nombre (nombre),
  UNIQUE KEY uq_sucursal_prefijo (prefijo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;;

INSERT INTO sucursal (id, nombre, prefijo) VALUES (1, 'Baradero', 'B'), (2, 'Hurlingham', 'H');;

ALTER TABLE expensa
  ADD COLUMN sucursal_id TINYINT NULL AFTER monto,
  ADD KEY idx_expensa_sucursal (sucursal_id),
  ADD CONSTRAINT fk_expensa_sucursal FOREIGN KEY (sucursal_id) REFERENCES sucursal (id)