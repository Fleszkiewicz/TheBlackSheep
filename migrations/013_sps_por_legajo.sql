-- 013: stored procedures de viajes y servicios. El identificador publico es el legajo.
-- El id numerico interno de viaje nunca sale de la base.
DROP PROCEDURE IF EXISTS insertar_viaje;;

DROP PROCEDURE IF EXISTS actualizar_viaje;;

DROP PROCEDURE IF EXISTS obtener_viaje;;

DROP PROCEDURE IF EXISTS obtener_viajes;;

DROP PROCEDURE IF EXISTS eliminar_viaje;;

DROP PROCEDURE IF EXISTS insertar_servicio_viaje;;

DROP PROCEDURE IF EXISTS actualizar_servicio_viaje;;

DROP PROCEDURE IF EXISTS eliminar_servicio_viaje;;

DROP PROCEDURE IF EXISTS recalcular_viaje_costo;;

CREATE PROCEDURE insertar_viaje(
  IN p_apellido VARCHAR(50),
  IN p_valor_total DECIMAL(12,2),
  IN p_valor_total_usd DECIMAL(12,2),
  IN p_destino ENUM('nacional','internacional'),
  IN p_fecha DATE,
  IN p_fecha_ida DATE,
  IN p_fecha_vuelta DATE,
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2),
  IN p_sucursal_id TINYINT
)
BEGIN
  INSERT INTO viaje (fecha, apellido, valor_total, valor_total_usd, destino, fecha_ida, fecha_vuelta, moneda_id, cotizacion, sucursal_id)
  VALUES (p_fecha, p_apellido, p_valor_total, IFNULL(p_valor_total_usd, 0), p_destino, p_fecha_ida, p_fecha_vuelta, p_moneda_id, p_cotizacion, p_sucursal_id);

  SELECT legajo AS id FROM viaje WHERE id = LAST_INSERT_ID();
END;;

CREATE PROCEDURE actualizar_viaje(
  IN p_legajo VARCHAR(20),
  IN p_apellido VARCHAR(50),
  IN p_valor_total DECIMAL(12,2),
  IN p_valor_total_usd DECIMAL(12,2),
  IN p_destino ENUM('nacional','internacional'),
  IN p_fecha DATE,
  IN p_fecha_ida DATE,
  IN p_fecha_vuelta DATE,
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2)
)
BEGIN
  UPDATE viaje SET
    apellido        = IFNULL(p_apellido, apellido),
    valor_total     = IFNULL(p_valor_total, valor_total),
    valor_total_usd = IFNULL(p_valor_total_usd, valor_total_usd),
    destino         = IFNULL(p_destino, destino),
    fecha           = IFNULL(p_fecha, fecha),
    fecha_ida       = IFNULL(p_fecha_ida, fecha_ida),
    fecha_vuelta    = IFNULL(p_fecha_vuelta, fecha_vuelta),
    moneda_id       = IFNULL(p_moneda_id, moneda_id),
    cotizacion      = IFNULL(p_cotizacion, cotizacion)
  WHERE legajo = p_legajo;

  SELECT legajo AS id FROM viaje WHERE legajo = p_legajo;
END;;

CREATE PROCEDURE obtener_viaje(IN p_legajo VARCHAR(20))
BEGIN
  SELECT
    v.legajo AS id,
    v.sucursal_id,
    v.fecha,
    ve.estado_calculado AS estado,
    v.cancelado,
    v.motivo_cancelacion,
    v.fecha_cancelacion,
    v.es_legado,
    v.apellido,
    v.valor_total,
    v.valor_total_usd,
    v.fecha_ida,
    v.fecha_vuelta,
    m.moneda,
    v.ganancia,
    v.ganancia_usd,
    v.costo,
    v.costo_usd,
    v.destino,
    v.cotizacion,
    COALESCE(
      (
        SELECT JSON_ARRAYAGG(
          JSON_OBJECT(
            'id', st.id,
            'nombre', st.nombre,
            'pagado_por', s.pagado_por,
            'valor', s.valor,
            'moneda', m_s.moneda,
            'cotizacion', s.cotizacion,
            'observacion', s.observacion
          )
        )
        FROM servicio s
        LEFT JOIN servicio_tipo st ON s.servicio_tipo_id = st.id
        LEFT JOIN moneda m_s ON m_s.id = s.moneda_id
        WHERE s.viaje_id = v.id
      ), JSON_ARRAY()
    ) AS servicios
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  LEFT JOIN moneda m ON m.id = v.moneda_id
  WHERE v.legajo = p_legajo;
END;;

CREATE PROCEDURE obtener_viajes(
  IN filtro VARCHAR(20),
  IN p_limit INT,
  IN p_offset INT,
  IN p_mes INT,
  IN p_anio INT,
  IN p_search VARCHAR(50)
)
BEGIN
  DECLARE v_orden VARCHAR(4) DEFAULT 'DESC';
  DECLARE v_estado VARCHAR(20) DEFAULT NULL;
  DECLARE v_search VARCHAR(50) DEFAULT NULL;
  DECLARE v_pattern VARCHAR(60) DEFAULT NULL;

  IF p_limit IS NULL OR p_limit <= 0 THEN SET p_limit = 10; END IF;
  IF p_offset IS NULL OR p_offset < 0 THEN SET p_offset = 0; END IF;

  IF LOWER(TRIM(filtro)) = 'asc' THEN SET v_orden = 'ASC'; END IF;

  SET v_estado = REPLACE(LOWER(TRIM(filtro)), '_', ' ');
  IF v_estado NOT IN ('pendiente', 'en espera', 'en curso', 'finalizado', 'cancelado') THEN
    SET v_estado = NULL;
  END IF;

  SET v_search = NULLIF(TRIM(p_search), '');
  IF v_search IS NOT NULL THEN
    SET v_pattern = CONCAT('%', v_search, '%');
  END IF;

  SELECT
    v.legajo AS id,
    v.sucursal_id,
    v.fecha,
    ve.estado_calculado AS estado,
    v.apellido,
    v.fecha_ida,
    v.fecha_vuelta
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE (v_estado IS NULL OR ve.estado_calculado = v_estado)
    AND (p_mes IS NULL OR p_mes = 0 OR MONTH(v.fecha) = p_mes)
    AND (p_anio IS NULL OR p_anio = 0 OR YEAR(v.fecha) = p_anio)
    AND (v_pattern IS NULL OR v.legajo LIKE v_pattern OR v.apellido LIKE v_pattern)
  ORDER BY
    CASE WHEN v_orden = 'ASC' THEN v.fecha END ASC,
    CASE WHEN v_orden = 'DESC' THEN v.fecha END DESC,
    CASE WHEN v_orden = 'ASC' THEN v.id END ASC,
    CASE WHEN v_orden = 'DESC' THEN v.id END DESC
  LIMIT p_limit OFFSET p_offset;

  SELECT COUNT(*) AS total
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE (v_estado IS NULL OR ve.estado_calculado = v_estado)
    AND (p_mes IS NULL OR p_mes = 0 OR MONTH(v.fecha) = p_mes)
    AND (p_anio IS NULL OR p_anio = 0 OR YEAR(v.fecha) = p_anio)
    AND (v_pattern IS NULL OR v.legajo LIKE v_pattern OR v.apellido LIKE v_pattern);
END;;

CREATE PROCEDURE eliminar_viaje(IN p_legajo VARCHAR(20))
BEGIN
  DELETE FROM viaje WHERE legajo = p_legajo;

  IF ROW_COUNT() > 0 THEN
    SELECT p_legajo AS id;
  END IF;
END;;

CREATE PROCEDURE insertar_servicio_viaje(
  IN p_viaje_legajo VARCHAR(20),
  IN p_servicio_tipo_id TINYINT,
  IN p_valor DECIMAL(12,2),
  IN p_pagado_por ENUM('pablo','soledad','mariana','pendiente','mixto'),
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2),
  IN p_observacion VARCHAR(255)
)
BEGIN
  DECLARE v_viaje_id INT;

  SELECT id INTO v_viaje_id FROM viaje WHERE legajo = p_viaje_legajo;
  IF v_viaje_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Viaje no encontrado';
  END IF;

  INSERT INTO servicio (viaje_id, servicio_tipo_id, valor, pagado_por, moneda_id, cotizacion, observacion)
  VALUES (v_viaje_id, p_servicio_tipo_id, p_valor, IFNULL(p_pagado_por, 'pendiente'), p_moneda_id, p_cotizacion, p_observacion);
END;;

CREATE PROCEDURE actualizar_servicio_viaje(
  IN p_viaje_legajo VARCHAR(20),
  IN p_servicio_tipo_id TINYINT,
  IN p_valor DECIMAL(12,2),
  IN p_pagado_por ENUM('pablo','soledad','mariana','pendiente','mixto'),
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2),
  IN p_observacion VARCHAR(255)
)
BEGIN
  DECLARE v_viaje_id INT;

  SELECT id INTO v_viaje_id FROM viaje WHERE legajo = p_viaje_legajo;
  IF v_viaje_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Viaje no encontrado';
  END IF;

  UPDATE servicio SET
    valor       = IFNULL(p_valor, valor),
    pagado_por  = IFNULL(p_pagado_por, pagado_por),
    moneda_id   = IFNULL(p_moneda_id, moneda_id),
    cotizacion  = IFNULL(p_cotizacion, cotizacion),
    observacion = IFNULL(p_observacion, observacion)
  WHERE viaje_id = v_viaje_id
    AND servicio_tipo_id = p_servicio_tipo_id;
END;;

CREATE PROCEDURE eliminar_servicio_viaje(
  IN p_viaje_legajo VARCHAR(20),
  IN p_servicio_tipo_id TINYINT
)
BEGIN
  DECLARE v_viaje_id INT;

  SELECT id INTO v_viaje_id FROM viaje WHERE legajo = p_viaje_legajo;
  IF v_viaje_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Viaje no encontrado';
  END IF;

  DELETE FROM servicio
  WHERE viaje_id = v_viaje_id
    AND servicio_tipo_id = p_servicio_tipo_id;
END;;