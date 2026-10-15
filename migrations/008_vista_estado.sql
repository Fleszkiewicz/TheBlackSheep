CREATE OR REPLACE SQL SECURITY INVOKER VIEW v_viaje_estado AS
SELECT
  v.id AS viaje_id,
  CASE
    WHEN v.cancelado = 1 THEN 'cancelado'
    WHEN v.es_legado = 1 THEN v.estado
    WHEN v.estado <> 'finalizado' THEN 'pendiente'
    WHEN DATE(UTC_TIMESTAMP() - INTERVAL 3 HOUR) < v.fecha_ida THEN 'en espera'
    WHEN DATE(UTC_TIMESTAMP() - INTERVAL 3 HOUR) <= v.fecha_vuelta THEN 'en curso'
    ELSE 'finalizado'
  END AS estado_calculado
FROM viaje v;;