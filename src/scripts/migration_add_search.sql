-- ============================================================
-- Migration: Add server-side search to obtener_viajes SP
-- Run this against the production database (Railway)
-- ============================================================

DROP PROCEDURE IF EXISTS `obtener_viajes`;

DELIMITER ;;

CREATE PROCEDURE `obtener_viajes`(
  IN filtro VARCHAR(20),
  IN p_limit INT,
  IN p_offset INT,
  IN p_mes INT,
  IN p_anio INT,
  IN p_search VARCHAR(50)
)
BEGIN

  DECLARE filtros TEXT DEFAULT '';
  DECLARE orden VARCHAR(10) DEFAULT 'DESC';

  IF p_limit IS NULL OR p_limit <= 0 THEN SET p_limit = 10; END IF;
  IF p_offset IS NULL OR p_offset < 0 THEN SET p_offset = 0; END IF;

  IF LOWER(filtro) = 'asc' THEN SET orden = 'ASC';
  ELSEIF LOWER(filtro) = 'desc' THEN SET orden = 'DESC';
  END IF;

  IF LOWER(filtro) IN ('pendiente', 'finalizado', 'cancelado') THEN
    SET filtros = CONCAT(filtros, ' AND v.estado = "', filtro, '"');
  END IF;

  IF p_mes IS NOT NULL AND (p_anio IS NULL OR p_anio = 0) THEN
    SET filtros = CONCAT(filtros, ' AND MONTH(v.fecha) = ', p_mes, ' AND YEAR(v.fecha) = YEAR(CURDATE())');
  ELSEIF p_anio IS NOT NULL AND (p_mes IS NULL OR p_mes = 0) THEN
    SET filtros = CONCAT(filtros, ' AND YEAR(v.fecha) = ', p_anio);
  ELSEIF p_mes IS NOT NULL AND p_anio IS NOT NULL THEN
    SET filtros = CONCAT(filtros, ' AND MONTH(v.fecha) = ', p_mes, ' AND YEAR(v.fecha) = ', p_anio);
  END IF;

  -- NEW: search filter by ID or apellido
  IF p_search IS NOT NULL AND p_search != '' THEN
    SET filtros = CONCAT(filtros, ' AND (v.id LIKE CONCAT("%", "', p_search, '", "%") OR LOWER(v.apellido) LIKE CONCAT("%", LOWER("', p_search, '"), "%"))');
  END IF;

  SET @query = CONCAT(
    'SELECT
      v.id,
      v.fecha,
      v.estado,
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
              "id", st.id,
              "nombre", st.nombre,
              "pagado_por", s.pagado_por,
              "valor", s.valor,
              "moneda", m_s.moneda,
              "cotizacion", s.cotizacion,
              "observacion", s.observacion
            )
          )
          FROM servicio s
          LEFT JOIN servicio_tipo st ON s.servicio_tipo_id = st.id
          LEFT JOIN moneda m_s ON m_s.id = s.moneda_id
          WHERE s.viaje_id = v.id
        ), JSON_ARRAY()
      ) AS servicios
    FROM viaje v
    LEFT JOIN moneda m ON m.id = v.moneda_id
    WHERE 1=1 ',
    filtros,
    ' GROUP BY v.id, v.fecha, v.estado, v.apellido, v.valor_total, v.valor_total_usd, m.moneda, v.ganancia, v.ganancia_usd, v.costo, v.costo_usd, v.destino, v.fecha_ida, v.fecha_vuelta, v.cotizacion',
    ' ORDER BY v.fecha ', orden,
    ' LIMIT ', p_limit,
    ' OFFSET ', p_offset
  );

  PREPARE stmt FROM @query;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

  SET @count_query = CONCAT(
    'SELECT COUNT(*) AS total FROM viaje v WHERE 1=1 ', filtros
  );

  PREPARE stmt2 FROM @count_query;
  EXECUTE stmt2;
  DEALLOCATE PREPARE stmt2;

END ;;

DELIMITER ;
