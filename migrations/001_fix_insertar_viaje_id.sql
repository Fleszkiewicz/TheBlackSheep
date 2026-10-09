DROP PROCEDURE IF EXISTS insertar_viaje;;

CREATE PROCEDURE insertar_viaje(
  IN p_apellido VARCHAR(50),
  IN p_valor_total DECIMAL(12,2),
  IN p_valor_total_usd DECIMAL(12,2),
  IN p_destino ENUM('nacional', 'internacional'),
  IN p_fecha DATE,
  IN p_fecha_ida DATE,
  IN p_fecha_vuelta DATE,
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2)
)
BEGIN
  DECLARE new_id VARCHAR(6);

  INSERT INTO viaje (fecha, apellido, valor_total, valor_total_usd, destino, fecha_vuelta, fecha_ida, moneda_id, cotizacion)
  VALUES (
    p_fecha,
    p_apellido,
    p_valor_total,
    IFNULL(p_valor_total_usd, 0),
    p_destino,
    p_fecha_vuelta,
    p_fecha_ida,
    p_moneda_id,
    p_cotizacion
  );

  -- El trigger trg_viaje_id inserta en viaje_seq y arma el ID con ese número.
  -- LAST_INSERT_ID() devuelve ese mismo número, y es propio de TU conexión,
  -- así que no se mezcla con otras reservas creadas al mismo tiempo.
  SET new_id = CONCAT('TBS', LPAD(LAST_INSERT_ID(), 3, '0'));

  SELECT new_id AS id;
END