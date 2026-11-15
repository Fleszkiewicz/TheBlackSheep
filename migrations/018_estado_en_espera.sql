-- 018: reglas para que un legajo nuevo (es_legado = 0) pase de Pendiente a En espera.
-- Los legajos cancelados y los legados (es_legado = 1) no cambian.
-- Un legajo nuevo queda Pendiente mientras falte alguno de estos puntos:
--   1. Informacion de viaje: fecha de reserva, inicio, fin, tipo de destino, sucursal, pago, moneda y valor total
--      (en USD o Mixto tambien cotizacion mayor a 0).
--   2. Destinos: al menos uno, todos Confirmados (fechas completas, al menos un servicio, y cada servicio con
--      tipo, valor mayor a 0, moneda 1 o 2, cotizacion mayor a 0 si es USD y pagado_por distinto de pendiente).
--   3. Servicios sin destino: si existen, deben estar completos igual que los de un destino.
--   4. Pasajeros: un titular y todos con nombre, apellido, DNI, vencimiento de DNI y edad.
--   5. Vencimientos: ningun DNI vence antes de la fecha de fin. El pasaporte solo cuenta si tiene vencimiento cargado.
-- Con todo completo, el estado sale de las fechas: en espera, en curso o finalizado.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW v_viaje_estado AS
SELECT
  v.id AS viaje_id,
  CASE
    WHEN v.cancelado = 1 THEN 'cancelado'
    WHEN v.es_legado = 1 THEN v.estado

    /* 1. informacion de viaje incompleta */
    WHEN v.fecha IS NULL
      OR v.fecha_ida IS NULL
      OR v.fecha_vuelta IS NULL
      OR v.destino IS NULL
      OR v.sucursal_id IS NULL
      OR v.pago IS NULL
      OR v.moneda_id IS NULL
      OR v.moneda_id NOT IN (1, 2, 3)
      OR (v.moneda_id = 1 AND IFNULL(v.valor_total, 0) <= 0)
      OR (v.moneda_id = 2 AND IFNULL(v.valor_total_usd, 0) <= 0)
      OR (v.moneda_id = 3 AND (IFNULL(v.valor_total, 0) <= 0 OR IFNULL(v.valor_total_usd, 0) <= 0))
      OR (v.moneda_id IN (2, 3) AND IFNULL(v.cotizacion, 0) <= 0)
    THEN 'pendiente'

    /* 2. sin destinos, o algun destino sin confirmar */
    WHEN NOT EXISTS (SELECT 1 FROM viaje_destino d WHERE d.viaje_id = v.id)
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