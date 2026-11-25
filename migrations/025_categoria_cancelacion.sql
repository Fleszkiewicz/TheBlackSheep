-- 025: categoria fija de cancelacion (codigos; el front muestra los textos)
ALTER TABLE viaje
  ADD COLUMN categoria_cancelacion ENUM('economicos','problemas_familiares','sin_respuesta','otra_agencia','cambio_planes','salud','otro') NULL AFTER cancelado;;

UPDATE viaje
SET categoria_cancelacion = CASE TRIM(motivo_cancelacion)
    WHEN 'Económico' THEN 'economicos'
    WHEN 'Económicos' THEN 'economicos'
    WHEN 'Problemas familiares' THEN 'problemas_familiares'
    WHEN 'Sin respuesta del cliente' THEN 'sin_respuesta'
    WHEN 'Eligió otra agencia / competidor' THEN 'otra_agencia'
    WHEN 'Eligió otra agencia' THEN 'otra_agencia'
    WHEN 'Cambio de fechas o planes' THEN 'cambio_planes'
    WHEN 'Problemas de salud' THEN 'salud'
    WHEN 'Otro motivo' THEN 'otro'
    ELSE NULL
  END
WHERE cancelado = 1 AND motivo_cancelacion IS NOT NULL;;

DROP PROCEDURE IF EXISTS obtener_viaje;;

CREATE PROCEDURE obtener_viaje(IN p_legajo VARCHAR(20))
BEGIN
  SELECT
    v.legajo AS id,
    v.sucursal_id,
    v.fecha,
    ve.estado_calculado AS estado,
    v.cancelado,
    v.categoria_cancelacion,
    v.motivo_cancelacion,
    v.fecha_cancelacion,
    v.es_legado,
    t.apellido,
    t.nombre,
    v.pago,
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
            'pasajero_id', p.id,
            'es_titular', IF(vp.es_titular = 1, CAST('true' AS JSON), CAST('false' AS JSON)),
            'categoria_edad', vp.categoria_edad,
            'dni', p.dni,
            'nombre', p.nombre,
            'apellido', p.apellido,
            'email', p.email,
            'telefono', p.telefono,
            'pasaporte', p.pasaporte,
            'vencimiento_dni', p.vencimiento_dni,
            'vencimiento_pasaporte', p.vencimiento_pasaporte
          )
        )
        FROM viaje_pasajeros vp
        INNER JOIN pasajeros p ON p.id = vp.pasajero_id
        WHERE vp.viaje_id = v.id
      ), JSON_ARRAY()
    ) AS pasajeros,
    COALESCE(
      (
        SELECT JSON_ARRAYAGG(
          JSON_OBJECT(
            'destino_id', d.id,
            'destino', d.destino,
            'fecha_desde', d.fecha_desde,
            'fecha_hasta', d.fecha_hasta,
            'orden', d.orden,
            'servicios', COALESCE(
              (
                SELECT JSON_ARRAYAGG(
                  JSON_OBJECT(
                    'servicio_tipo_id', s.servicio_tipo_id,
                    'nombre', st.nombre,
                    'valor', s.valor,
                    'moneda_id', s.moneda_id,
                    'moneda', m_s.moneda,
                    'cotizacion', s.cotizacion,
                    'pagado_por', s.pagado_por,
                    'observacion', s.observacion
                  )
                )
                FROM servicio s
                LEFT JOIN servicio_tipo st ON st.id = s.servicio_tipo_id
                LEFT JOIN moneda m_s ON m_s.id = s.moneda_id
                WHERE s.destino_id = d.id
              ), JSON_ARRAY()
            )
          )
        )
        FROM viaje_destino d
        WHERE d.viaje_id = v.id
      ), JSON_ARRAY()
    ) AS destinos,
    COALESCE(
      (
        SELECT JSON_ARRAYAGG(
          JSON_OBJECT(
            'servicio_tipo_id', s.servicio_tipo_id,
            'nombre', st.nombre,
            'valor', s.valor,
            'moneda_id', s.moneda_id,
            'moneda', m_s.moneda,
            'cotizacion', s.cotizacion,
            'pagado_por', s.pagado_por,
            'observacion', s.observacion
          )
        )
        FROM servicio s
        LEFT JOIN servicio_tipo st ON st.id = s.servicio_tipo_id
        LEFT JOIN moneda m_s ON m_s.id = s.moneda_id
        WHERE s.viaje_id = v.id AND s.destino_id IS NULL
      ), JSON_ARRAY()
    ) AS servicios_sin_destino,
    COALESCE(
      (
        SELECT JSON_ARRAYAGG(
          JSON_OBJECT(
            'id', st.id,
            'nombre', st.nombre,
            'destino_id', s.destino_id,
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
  LEFT JOIN viaje_pasajeros vt ON vt.viaje_id = v.id AND vt.es_titular = 1
  LEFT JOIN pasajeros t ON t.id = vt.pasajero_id
  WHERE v.legajo = p_legajo;
END;;