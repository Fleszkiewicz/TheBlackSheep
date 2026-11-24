-- 023: control de a que socio ya se le abono su parte de cada legajo (una fila = abonado)
CREATE TABLE IF NOT EXISTS viaje_socio_pago (
  viaje_id INT NOT NULL,
  socio VARCHAR(20) NOT NULL,
  monto_ars DECIMAL(14,2) NOT NULL DEFAULT 0,
  monto_usd DECIMAL(14,2) NOT NULL DEFAULT 0,
  abonado_at DATETIME NOT NULL,
  PRIMARY KEY (viaje_id, socio),
  CONSTRAINT fk_viaje_socio_pago_viaje FOREIGN KEY (viaje_id) REFERENCES viaje (id) ON DELETE CASCADE
);;
