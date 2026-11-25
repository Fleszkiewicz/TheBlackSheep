-- 026: SP del Dashboard (ver DASHBOARD.md en la raiz). Parametros: p_anio obligatorio, p_mes y p_sucursal NULL o 0 = todos.
-- Mes = MONTH(viaje.fecha). Los graficos de evolucion ignoran p_mes. ARS: moneda 1 y 3; USD: moneda 2 y 3.
DROP PROCEDURE IF EXISTS dashboard_expedientes;;

CREATE PROCEDURE dashboard_expedientes(IN p_anio INT, IN p_mes INT, IN p_sucursal INT)
BEGIN
  SET p_mes = NULLIF(p_mes, 0);
  SET p_sucursal = NULLIF(p_sucursal, 0);

  -- 1) KPI (todos los estados)
  SELECT
    COUNT(*) AS total,
    COALESCE(SUM(ve.estado_calculado IN ('en espera', 'en curso')), 0) AS activos,
    COALESCE(SUM(ve.estado_calculado = 'finalizado'), 0) AS finalizados,
    COALESCE(SUM(ve.estado_calculado = 'cancelado'), 0) AS cancelados
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal);

  -- 2) Estados
  SELECT ve.estado_calculado AS estado, COUNT(*) AS cantidad
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
  GROUP BY ve.estado_calculado;

  -- 3) Por sucursal (cantidad e importes por moneda)
  SELECT
    v.sucursal_id,
    COALESCE(s.nombre, 'Sin sucursal') AS sucursal,
    COUNT(*) AS cantidad,
    COALESCE(SUM(CASE WHEN v.moneda_id IN (1, 3) THEN v.valor_total END), 0) AS monto_ars,
    COALESCE(SUM(CASE WHEN v.moneda_id IN (2, 3) THEN v.valor_total_usd END), 0) AS monto_usd
  FROM viaje v
  LEFT JOIN sucursal s ON s.id = v.sucursal_id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
  GROUP BY v.sucursal_id, s.nombre
  ORDER BY v.sucursal_id IS NULL, v.sucursal_id;

  -- 4) Evolucion mensual (12 meses, sin filtro de mes)
  SELECT MONTH(v.fecha) AS mes_num, COUNT(*) AS cantidad
  FROM viaje v
  WHERE YEAR(v.fecha) = p_anio
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
  GROUP BY MONTH(v.fecha)
  ORDER BY mes_num;

  -- 5) Motivos de cancelacion (sin legados ni cancelaciones sin categoria)
  SELECT v.categoria_cancelacion AS categoria, COUNT(*) AS cantidad
  FROM viaje v
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND v.cancelado = 1
    AND v.es_legado = 0
    AND v.categoria_cancelacion IS NOT NULL
  GROUP BY v.categoria_cancelacion
  ORDER BY cantidad DESC;
END;;

DROP PROCEDURE IF EXISTS dashboard_productos;;

CREATE PROCEDURE dashboard_productos(IN p_anio INT, IN p_mes INT, IN p_sucursal INT)
BEGIN
  SET p_mes = NULLIF(p_mes, 0);
  SET p_sucursal = NULLIF(p_sucursal, 0);

  -- 1) KPI: pasajeros (sin legados)
  SELECT COUNT(*) AS pasajeros
  FROM viaje_pasajeros vp
  INNER JOIN viaje v ON v.id = vp.viaje_id
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
    AND v.es_legado = 0;

  -- 2) Top 10 destinos (sin distinguir mayusculas ni espacios; excluye "Sin destino asignado")
  SELECT MIN(TRIM(d.destino)) AS destino, COUNT(*) AS cantidad
  FROM viaje_destino d
  INNER JOIN viaje v ON v.id = d.viaje_id
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
    AND LOWER(REGEXP_REPLACE(TRIM(d.destino), ' +', ' ')) <> 'sin destino asignado'
  GROUP BY LOWER(REGEXP_REPLACE(TRIM(d.destino), ' +', ' '))
  ORDER BY cantidad DESC, destino
  LIMIT 10;

  -- 3) Servicios por tipo
  SELECT st.id AS servicio_tipo_id, st.nombre, COUNT(*) AS cantidad
  FROM servicio s
  INNER JOIN servicio_tipo st ON st.id = s.servicio_tipo_id
  INNER JOIN viaje v ON v.id = s.viaje_id
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
  GROUP BY st.id, st.nombre
  ORDER BY cantidad DESC, st.nombre;

  -- 4) Nacional vs. internacional
  SELECT v.destino AS tipo, COUNT(*) AS cantidad
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
    AND v.destino IS NOT NULL
  GROUP BY v.destino;

  -- 5) Composicion por edad (sin legados)
  SELECT vp.categoria_edad, COUNT(*) AS cantidad
  FROM viaje_pasajeros vp
  INNER JOIN viaje v ON v.id = vp.viaje_id
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
    AND v.es_legado = 0
    AND vp.categoria_edad IS NOT NULL
  GROUP BY vp.categoria_edad;
END;;

DROP PROCEDURE IF EXISTS dashboard_finanzas;;

CREATE PROCEDURE dashboard_finanzas(IN p_anio INT, IN p_mes INT, IN p_sucursal INT)
BEGIN
  SET p_mes = NULLIF(p_mes, 0);
  SET p_sucursal = NULLIF(p_sucursal, 0);

  -- 1) KPI: facturacion, costos y ganancia por moneda (sin restar expensas)
  SELECT
    t.facturacion_ars, t.costo_ars, t.facturacion_ars - t.costo_ars AS ganancia_ars,
    t.facturacion_usd, t.costo_usd, t.facturacion_usd - t.costo_usd AS ganancia_usd
  FROM (
    SELECT
      COALESCE(SUM(CASE WHEN v.moneda_id IN (1, 3) THEN v.valor_total END), 0) AS facturacion_ars,
      COALESCE(SUM(CASE WHEN v.moneda_id IN (1, 3) THEN v.costo END), 0) AS costo_ars,
      COALESCE(SUM(CASE WHEN v.moneda_id IN (2, 3) THEN v.valor_total_usd END), 0) AS facturacion_usd,
      COALESCE(SUM(CASE WHEN v.moneda_id IN (2, 3) THEN v.costo_usd END), 0) AS costo_usd
    FROM viaje v
    INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
    WHERE YEAR(v.fecha) = p_anio
      AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
      AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
      AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
  ) t;

  -- 2) Mes a mes (12 meses, sin filtro de mes)
  SELECT
    MONTH(v.fecha) AS mes_num,
    COALESCE(SUM(CASE WHEN v.moneda_id IN (1, 3) THEN v.valor_total END), 0) AS ingreso_ars,
    COALESCE(SUM(CASE WHEN v.moneda_id IN (1, 3) THEN v.costo END), 0) AS costo_ars,
    COALESCE(SUM(CASE WHEN v.moneda_id IN (2, 3) THEN v.valor_total_usd END), 0) AS ingreso_usd,
    COALESCE(SUM(CASE WHEN v.moneda_id IN (2, 3) THEN v.costo_usd END), 0) AS costo_usd
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
  GROUP BY MONTH(v.fecha)
  ORDER BY mes_num;

  -- 3) Formas de pago (sin legados)
  SELECT v.pago, COUNT(*) AS cantidad
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
    AND v.es_legado = 0
    AND v.pago IS NOT NULL
  GROUP BY v.pago
  ORDER BY cantidad DESC;

  -- 4) Expedientes por moneda
  SELECT v.moneda_id, m.moneda, COUNT(*) AS cantidad
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  LEFT JOIN moneda m ON m.id = v.moneda_id
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
    AND v.moneda_id IS NOT NULL
  GROUP BY v.moneda_id, m.moneda
  ORDER BY v.moneda_id;

  -- 5) Liquidacion a socios (sin legados). Abonado = monto guardado al marcar; pendiente = cuota actual (ganancia / 3)
  SELECT
    so.socio,
    COALESCE(SUM(p.monto_ars), 0) AS abonado_ars,
    COALESCE(SUM(p.monto_usd), 0) AS abonado_usd,
    COALESCE(SUM(CASE WHEN p.viaje_id IS NULL THEN ROUND(COALESCE(v.ganancia, 0) / 3, 2) END), 0) AS pendiente_ars,
    COALESCE(SUM(CASE WHEN p.viaje_id IS NULL THEN ROUND(COALESCE(v.ganancia_usd, 0) / 3, 2) END), 0) AS pendiente_usd
  FROM (
    SELECT 'pablo' AS socio, 1 AS orden
    UNION ALL SELECT 'soledad', 2
    UNION ALL SELECT 'mariana', 3
  ) so
  CROSS JOIN viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  LEFT JOIN viaje_socio_pago p ON p.viaje_id = v.id AND p.socio = so.socio
  WHERE YEAR(v.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
    AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
    AND v.es_legado = 0
  GROUP BY so.socio, so.orden
  ORDER BY so.orden;
END;;

DROP PROCEDURE IF EXISTS dashboard_expensas;;

CREATE PROCEDURE dashboard_expensas(IN p_anio INT, IN p_mes INT, IN p_sucursal INT)
BEGIN
  SET p_mes = NULLIF(p_mes, 0);
  SET p_sucursal = NULLIF(p_sucursal, 0);

  -- 1) KPI: expensas por moneda y sucursal, ganancia de viajes y balance neto (ganancia - expensas)
  SELECT
    x.total_ars, x.total_usd,
    x.baradero_ars, x.baradero_usd, x.hurlingham_ars, x.hurlingham_usd,
    g.ganancia_ars, g.ganancia_usd,
    g.ganancia_ars - x.total_ars AS balance_ars,
    g.ganancia_usd - x.total_usd AS balance_usd
  FROM (
    SELECT
      COALESCE(SUM(CASE WHEN e.moneda_id = 1 THEN e.monto END), 0) AS total_ars,
      COALESCE(SUM(CASE WHEN e.moneda_id = 2 THEN e.monto END), 0) AS total_usd,
      COALESCE(SUM(CASE WHEN e.moneda_id = 1 AND e.sucursal_id = 1 THEN e.monto END), 0) AS baradero_ars,
      COALESCE(SUM(CASE WHEN e.moneda_id = 2 AND e.sucursal_id = 1 THEN e.monto END), 0) AS baradero_usd,
      COALESCE(SUM(CASE WHEN e.moneda_id = 1 AND e.sucursal_id = 2 THEN e.monto END), 0) AS hurlingham_ars,
      COALESCE(SUM(CASE WHEN e.moneda_id = 2 AND e.sucursal_id = 2 THEN e.monto END), 0) AS hurlingham_usd
    FROM expensa e
    WHERE YEAR(e.fecha) = p_anio
      AND (p_mes IS NULL OR MONTH(e.fecha) = p_mes)
      AND (p_sucursal IS NULL OR e.sucursal_id = p_sucursal)
  ) x
  CROSS JOIN (
    SELECT
      COALESCE(SUM(CASE WHEN v.moneda_id IN (1, 3) THEN v.valor_total - COALESCE(v.costo, 0) END), 0) AS ganancia_ars,
      COALESCE(SUM(CASE WHEN v.moneda_id IN (2, 3) THEN COALESCE(v.valor_total_usd, 0) - COALESCE(v.costo_usd, 0) END), 0) AS ganancia_usd
    FROM viaje v
    INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
    WHERE YEAR(v.fecha) = p_anio
      AND (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
      AND (p_sucursal IS NULL OR v.sucursal_id = p_sucursal)
      AND ve.estado_calculado IN ('en espera', 'en curso', 'finalizado')
  ) g;

  -- 2) Evolucion mensual (12 meses, sin filtro de mes)
  SELECT
    MONTH(e.fecha) AS mes_num,
    COALESCE(SUM(CASE WHEN e.moneda_id = 1 THEN e.monto END), 0) AS ars,
    COALESCE(SUM(CASE WHEN e.moneda_id = 2 THEN e.monto END), 0) AS usd
  FROM expensa e
  WHERE YEAR(e.fecha) = p_anio
    AND (p_sucursal IS NULL OR e.sucursal_id = p_sucursal)
  GROUP BY MONTH(e.fecha)
  ORDER BY mes_num;

  -- 3) Por sucursal
  SELECT
    e.sucursal_id,
    COALESCE(s.nombre, 'Sin sucursal') AS sucursal,
    COALESCE(SUM(CASE WHEN e.moneda_id = 1 THEN e.monto END), 0) AS ars,
    COALESCE(SUM(CASE WHEN e.moneda_id = 2 THEN e.monto END), 0) AS usd
  FROM expensa e
  LEFT JOIN sucursal s ON s.id = e.sucursal_id
  WHERE YEAR(e.fecha) = p_anio
    AND (p_mes IS NULL OR MONTH(e.fecha) = p_mes)
    AND (p_sucursal IS NULL OR e.sucursal_id = p_sucursal)
  GROUP BY e.sucursal_id, s.nombre
  ORDER BY e.sucursal_id IS NULL, e.sucursal_id;
END;;
