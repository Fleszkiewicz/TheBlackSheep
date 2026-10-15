DROP PROCEDURE IF EXISTS obtener_viajes;;

CREATE PROCEDURE obtener_viajes(
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
  DECLARE v_estado VARCHAR(20) DEFAULT NULL;

  IF p_limit IS NULL OR p_limit <= 0 THEN SET p_limit = 10; END IF;
  IF p_offset IS NULL OR p_offset < 0 THEN SET p_offset = 0; END IF;

  IF LOWER(filtro) = 'asc' THEN SET orden = 'ASC';
  ELSEIF LOWER(filtro) = 'desc' THEN SET orden = 'DESC';
  END IF;

  SET v_estado = REPLACE(LOWER(TRIM(filtro)), '_', ' ');
  IF v_estado IN ('pendiente', 'en espera', 'en curso', 'finalizado', 'cancelado') THEN
    SET filtros = CONCAT(filtros, ' AND ve.estado_calculado = "', v_estado, '"');
  END IF;

  IF p_mes IS NOT NULL AND (p_anio IS NULL OR p_anio = 0) THEN
    SET filtros = CONCAT(filtros, ' AND MONTH(v.fecha) = ', p_mes);
  ELSEIF p_anio IS NOT NULL AND (p_mes IS NULL OR p_mes = 0) THEN
    SET filtros = CONCAT(filtros, ' AND YEAR(v.fecha) = ', p_anio);
  ELSEIF p_mes IS NOT NULL AND p_anio IS NOT NULL THEN
    SET filtros = CONCAT(filtros, ' AND MONTH(v.fecha) = ', p_mes, ' AND YEAR(v.fecha) = ', p_anio);
  END IF;

  SET @tbs_search  = NULLIF(TRIM(p_search), '');
  SET @tbs_pattern = CONCAT('%', LOWER(IFNULL(@tbs_search, '')), '%');
  SET filtros = CONCAT(filtros, ' AND (? IS NULL OR v.id LIKE ? OR LOWER(v.apellido) LIKE ?)');

  SET @query = CONCAT(
    'SELECT
      v.id,
      v.fecha,
      ve.estado_calculado AS estado,
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
    INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
    LEFT JOIN moneda m ON m.id = v.moneda_id
    WHERE 1=1 ',
    filtros,
    ' GROUP BY v.id, v.fecha, ve.estado_calculado, v.apellido, v.valor_total, v.valor_total_usd, m.moneda, v.ganancia, v.ganancia_usd, v.costo, v.costo_usd, v.destino, v.fecha_ida, v.fecha_vuelta, v.cotizacion',
    ' ORDER BY v.fecha ', orden,
    ' LIMIT ', p_limit,
    ' OFFSET ', p_offset
  );

  PREPARE stmt FROM @query;
  EXECUTE stmt USING @tbs_search, @tbs_pattern, @tbs_pattern;
  DEALLOCATE PREPARE stmt;

  SET @count_query = CONCAT(
    'SELECT COUNT(*) AS total FROM viaje v INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id WHERE 1=1 ',
    filtros
  );

  PREPARE stmt2 FROM @count_query;
  EXECUTE stmt2 USING @tbs_search, @tbs_pattern, @tbs_pattern;
  DEALLOCATE PREPARE stmt2;
END;;

DROP PROCEDURE IF EXISTS obtener_viaje;;

CREATE PROCEDURE obtener_viaje(IN p_id VARCHAR(6))
BEGIN
  SELECT
    v.id,
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
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  LEFT JOIN moneda m ON m.id = v.moneda_id
  WHERE v.id = p_id;
END;;

DROP PROCEDURE IF EXISTS resumen_financiero;;

CREATE PROCEDURE resumen_financiero(
  IN p_mes INT,
  IN p_anio INT,
  IN p_moneda INT
)
BEGIN
  SELECT
    T.moneda,
    MONTHNAME(T.fecha_ref) AS mes,
    MONTH(T.fecha_ref) AS mes_num,
    SUM(T.ingreso) AS ingreso,
    SUM(T.egreso) AS egreso,
    SUM(T.ingreso) - SUM(T.egreso) AS ganancia
  FROM (
    SELECT 'ars' AS moneda, 1 AS moneda_id, v.fecha AS fecha_ref,
           v.valor_total AS ingreso, IFNULL(v.costo, 0) AS egreso
    FROM viaje v
    INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
    WHERE v.moneda_id = 1
      AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
      AND YEAR(v.fecha) = p_anio

    UNION ALL

    SELECT 'usd' AS moneda, 2 AS moneda_id, v.fecha AS fecha_ref,
           IFNULL(v.valor_total_usd, 0) AS ingreso, IFNULL(v.costo_usd, 0) AS egreso
    FROM viaje v
    INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
    WHERE v.moneda_id = 2
      AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
      AND YEAR(v.fecha) = p_anio

    UNION ALL

    SELECT 'ars' AS moneda, 1 AS moneda_id, v.fecha AS fecha_ref,
           IFNULL(v.valor_total, 0) AS ingreso, IFNULL(v.costo, 0) AS egreso
    FROM viaje v
    INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
    WHERE v.moneda_id = 3
      AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
      AND YEAR(v.fecha) = p_anio

    UNION ALL

    SELECT 'usd' AS moneda, 2 AS moneda_id, v.fecha AS fecha_ref,
           IFNULL(v.valor_total_usd, 0) AS ingreso, IFNULL(v.costo_usd, 0) AS egreso
    FROM viaje v
    INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
    WHERE v.moneda_id = 3
      AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
      AND YEAR(v.fecha) = p_anio

    UNION ALL

    SELECT 'ars' AS moneda, 1 AS moneda_id, e.fecha AS fecha_ref,
           0 AS ingreso, e.monto AS egreso
    FROM expensa e
    WHERE e.moneda_id = 1 AND YEAR(e.fecha) = p_anio

    UNION ALL

    SELECT 'usd' AS moneda, 2 AS moneda_id, e.fecha AS fecha_ref,
           0 AS ingreso, e.monto AS egreso
    FROM expensa e
    WHERE e.moneda_id = 2 AND YEAR(e.fecha) = p_anio
  ) AS T
  WHERE (p_moneda IS NULL OR T.moneda_id = p_moneda)
    AND (p_mes IS NULL OR MONTH(T.fecha_ref) = p_mes)
  GROUP BY T.moneda, T.moneda_id, MONTH(T.fecha_ref), MONTHNAME(T.fecha_ref)
  ORDER BY mes_num, T.moneda;
END;;