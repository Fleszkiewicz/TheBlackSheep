-- 024: filtro por sucursal en el listado de la Home (p_sucursal: 1 = Baradero, 2 = Hurlingham, NULL o 0 = todas)
DROP PROCEDURE IF EXISTS obtener_viajes;;

CREATE PROCEDURE obtener_viajes(
  IN filtro VARCHAR(20),
  IN p_limit INT,
  IN p_offset INT,
  IN p_mes INT,
  IN p_anio INT,
  IN p_search VARCHAR(50),
  IN p_sucursal INT
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
    t.apellido,
    t.nombre,
    v.fecha_ida,
    v.fecha_vuelta
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  LEFT JOIN viaje_pasajeros vt ON vt.viaje_id = v.id AND vt.es_titular = 1
  LEFT JOIN pasajeros t ON t.id = vt.pasajero_id
  WHERE (v_estado IS NULL OR ve.estado_calculado = v_estado)
    AND (p_mes IS NULL OR p_mes = 0 OR MONTH(v.fecha) = p_mes)
    AND (p_anio IS NULL OR p_anio = 0 OR YEAR(v.fecha) = p_anio)
    AND (p_sucursal IS NULL OR p_sucursal = 0 OR v.sucursal_id = p_sucursal)
    AND (v_pattern IS NULL OR v.legajo LIKE v_pattern OR t.apellido LIKE v_pattern OR t.nombre LIKE v_pattern)
  ORDER BY
    CASE WHEN v_orden = 'ASC' THEN v.fecha END ASC,
    CASE WHEN v_orden = 'DESC' THEN v.fecha END DESC,
    CASE WHEN v_orden = 'ASC' THEN v.id END ASC,
    CASE WHEN v_orden = 'DESC' THEN v.id END DESC
  LIMIT p_limit OFFSET p_offset;

  SELECT COUNT(*) AS total
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  LEFT JOIN viaje_pasajeros vt ON vt.viaje_id = v.id AND vt.es_titular = 1
  LEFT JOIN pasajeros t ON t.id = vt.pasajero_id
  WHERE (v_estado IS NULL OR ve.estado_calculado = v_estado)
    AND (p_mes IS NULL OR p_mes = 0 OR MONTH(v.fecha) = p_mes)
    AND (p_anio IS NULL OR p_anio = 0 OR YEAR(v.fecha) = p_anio)
    AND (p_sucursal IS NULL OR p_sucursal = 0 OR v.sucursal_id = p_sucursal)
    AND (v_pattern IS NULL OR v.legajo LIKE v_pattern OR t.apellido LIKE v_pattern OR t.nombre LIKE v_pattern);
END;;
