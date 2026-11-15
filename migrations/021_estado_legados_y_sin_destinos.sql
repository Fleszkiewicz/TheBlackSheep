-- 021: ajustes de estado para legajos heredados y legajos sin destinos.
-- 1. Legajos sin destinos y sin servicios: siguen Pendientes (estan vacios, esperando que se cargue un destino).
-- 2. Legajos sin destinos pero con servicios (heredados de la version anterior): ya no se frenan por no tener destino.
--    Siguen avanzando segun el resto de sus datos y servicios (en espera, en curso o finalizado segun las fechas).
-- 3. Legados (es_legado = 1): conservan el estado guardado. Si estan finalizados y el viaje esta en curso por fechas
--    se muestran En curso, igual que en la version anterior (que lo calculaba en pantalla).
-- Todo lo demas es igual a la 019.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW v_viaje_estado AS
SELECT
  v.id AS viaje_id,
  CASE
    WHEN v.cancelado = 1 THEN 'cancelado'
    /* legados: conservan el estado que traian, y si estan finalizados con el viaje en curso se ven En curso */
    WHEN v.es_legado = 1 THEN
      CASE
        WHEN v.estado = 'finalizado'
          AND v.fecha_ida IS NOT NULL
          AND v.fecha_vuelta IS NOT NULL
          AND DATE(UTC_TIMESTAMP() - INTERVAL 3 HOUR) BETWEEN v.fecha_ida AND v.fecha_vuelta
        THEN 'en curso'
        ELSE v.estado
      END

    /* 1. informacion de viaje incompleta */
    WHEN v.fecha IS NULL
      OR v.fecha_ida IS NULL
      OR v.fecha_vuelta IS NULL
      OR v.destino IS NULL
      OR v.sucursal_id IS NULL
      OR v.moneda_id IS NULL
      OR v.moneda_id NOT IN (1, 2, 3)
      OR (v.moneda_id = 1 AND IFNULL(v.valor_total, 0) <= 0)
      OR (v.moneda_id = 2 AND IFNULL(v.valor_total_usd, 0) <= 0)
      OR (v.moneda_id = 3 AND (IFNULL(v.valor_total, 0) <= 0 OR IFNULL(v.valor_total_usd, 0) <= 0))
      OR (v.moneda_id IN (2, 3) AND IFNULL(v.cotizacion, 0) <= 0)
    THEN 'pendiente'

    /* 2. legajo vacio (sin destinos y sin servicios), o algun destino sin confirmar.
          Sin destinos pero con servicios (heredado de la version anterior): no se frena por falta de destino */
    WHEN NOT EXISTS (SELECT 1 FROM viaje_destino d WHERE d.viaje_id = v.id)
      AND NOT EXISTS (SELECT 1 FROM servicio s WHERE s.viaje_id = v.id)
    THEN 'pendiente'
    WHEN EXISTS (
      SELECT 1 FROM viaje_destino d
      WHERE d.viaje_id = v.id
        AND (
          d.fecha_desde IS NULL
          OR d.fecha_hasta IS NULL
          OR NOT EXISTS (SELECT 1 FROM servicio s WHERE s.destino_id = d.id)
          OR EXISTS (
            SELECT 1 FROM servicio s
            WHERE s.destino_id = d.id
              AND (
                s.servicio_tipo_id IS NULL OR s.servicio_tipo_id <= 0
                OR IFNULL(s.valor, 0) <= 0
                OR s.moneda_id IS NULL OR s.moneda_id NOT IN (1, 2)
                OR (s.moneda_id = 2 AND IFNULL(s.cotizacion, 0) <= 0)
                OR s.pagado_por IS NULL OR s.pagado_por = 'pendiente'
              )
          )
        )
    ) THEN 'pendiente'

    /* 3. servicios sin destino incompletos */
    WHEN EXISTS (
      SELECT 1 FROM servicio s
      WHERE s.viaje_id = v.id
        AND s.destino_id IS NULL
        AND (
          s.servicio_tipo_id IS NULL OR s.servicio_tipo_id <= 0
          OR IFNULL(s.valor, 0) <= 0
          OR s.moneda_id IS NULL OR s.moneda_id NOT IN (1, 2)
          OR (s.moneda_id = 2 AND IFNULL(s.cotizacion, 0) <= 0)
          OR s.pagado_por IS NULL OR s.pagado_por = 'pendiente'
        )
    ) THEN 'pendiente'

    /* 4. pasajeros: falta el titular o datos obligatorios */
    WHEN NOT EXISTS (
      SELECT 1 FROM viaje_pasajeros vp WHERE vp.viaje_id = v.id AND vp.es_titular = 1
    ) THEN 'pendiente'
    WHEN EXISTS (
      SELECT 1
      FROM viaje_pasajeros vp
      INNER JOIN pasajeros p ON p.id = vp.pasajero_id
      WHERE vp.viaje_id = v.id
        AND (
          p.nombre IS NULL OR TRIM(p.nombre) = ''
          OR p.apellido IS NULL OR TRIM(p.apellido) = ''
          OR p.dni IS NULL OR TRIM(p.dni) = ''
          OR p.vencimiento_dni IS NULL
          OR vp.categoria_edad IS NULL
        )
    ) THEN 'pendiente'

    /* 5. documentos que vencen antes de la fecha de fin del viaje */
    WHEN EXISTS (
      SELECT 1
      FROM viaje_pasajeros vp
      INNER JOIN pasajeros p ON p.id = vp.pasajero_id
      WHERE vp.viaje_id = v.id
        AND (
          p.vencimiento_dni < v.fecha_vuelta
          OR (p.vencimiento_pasaporte IS NOT NULL AND p.vencimiento_pasaporte < v.fecha_vuelta)
        )
    ) THEN 'pendiente'

    WHEN DATE(UTC_TIMESTAMP() - INTERVAL 3 HOUR) < v.fecha_ida THEN 'en espera'
    WHEN DATE(UTC_TIMESTAMP() - INTERVAL 3 HOUR) <= v.fecha_vuelta THEN 'en curso'
    ELSE 'finalizado'
  END AS estado_calculado
FROM viaje v;;