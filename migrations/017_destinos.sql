-- 017: destinos por viaje. Los servicios pasan a colgar de un destino (destino_id).
-- Los servicios viejos quedan con destino_id NULL ("Sin destino asignado").
-- servicio cambia su clave: ahora tiene id propio, asi un mismo tipo de servicio puede repetirse en destinos distintos.
CREATE TABLE viaje_destino (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  viaje_id INT NOT NULL,
  destino VARCHAR(100) NOT NULL,
  fecha_desde DATE NULL,
  fecha_hasta DATE NULL,
  orden SMALLINT NOT NULL DEFAULT 0,
  KEY idx_vd_viaje (viaje_id),
  CONSTRAINT fk_vd_viaje FOREIGN KEY (viaje_id) REFERENCES viaje(id) ON DELETE CASCADE
);;

ALTER TABLE servicio ADD KEY idx_servicio_viaje (viaje_id);;

ALTER TABLE servicio
  DROP PRIMARY KEY,
  ADD COLUMN id INT NOT NULL AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (id),
  ADD COLUMN destino_id INT NULL AFTER viaje_id,
  ADD KEY idx_servicio_destino (destino_id);;

ALTER TABLE servicio
  ADD CONSTRAINT fk_servicio_destino FOREIGN KEY (destino_id) REFERENCES viaje_destino(id) ON DELETE CASCADE;;

DROP PROCEDURE IF EXISTS guardar_destinos_viaje;;

DROP PROCEDURE IF EXISTS insertar_viaje;;

DROP PROCEDURE IF EXISTS actualizar_viaje;;

DROP PROCEDURE IF EXISTS obtener_viaje;;

CREATE PROCEDURE guardar_destinos_viaje(
  IN p_viaje_legajo VARCHAR(20),
  IN p_destinos JSON,
  IN p_sin_destino JSON
)
BEGIN
  DECLARE v_viaje_id INT DEFAULT NULL;
  DECLARE v_ida DATE DEFAULT NULL;
  DECLARE v_vuelta DATE DEFAULT NULL;
  DECLARE v_n INT DEFAULT 0;
  DECLARE v_i INT DEFAULT 0;
  DECLARE v_item JSON;
  DECLARE v_servicios JSON;
  DECLARE v_did INT DEFAULT NULL;
  DECLARE v_nombre VARCHAR(100);
  DECLARE v_desde DATE;
  DECLARE v_hasta DATE;

  SELECT id, fecha_ida, fecha_vuelta INTO v_viaje_id, v_ida, v_vuelta
  FROM viaje WHERE legajo = p_viaje_legajo;
  IF v_viaje_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Viaje no encontrado';
  END IF;

  IF p_destinos IS NOT NULL THEN
    IF JSON_TYPE(p_destinos) <> 'ARRAY' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lista de destinos invalida';
    END IF;

    DELETE FROM servicio WHERE viaje_id = v_viaje_id AND destino_id IS NOT NULL;

    DELETE FROM viaje_destino
    WHERE viaje_id = v_viaje_id
      AND id NOT IN (
        SELECT j.did
        FROM JSON_TABLE(p_destinos, '$[*]' COLUMNS (did INT PATH '$.destino_id' NULL ON EMPTY NULL ON ERROR)) j
        WHERE j.did IS NOT NULL
      );

    SET v_n = JSON_LENGTH(p_destinos);

    WHILE v_i < v_n DO
      SET v_item = JSON_EXTRACT(p_destinos, CONCAT('$[', v_i, ']'));
      SET v_did = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.destino_id'))), 'null'), '');
      SET v_nombre = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.destino'))), 'null'), '');
      SET v_desde = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.fecha_desde'))), 'null'), '');
      SET v_hasta = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.fecha_hasta'))), 'null'), '');

      IF v_nombre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del destino es obligatorio';
      END IF;

      IF v_desde IS NOT NULL AND v_hasta IS NOT NULL AND v_hasta < v_desde THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha hasta del destino no puede ser anterior a la fecha desde';
      END IF;

      IF v_ida IS NOT NULL AND v_vuelta IS NOT NULL AND (
           (v_desde IS NOT NULL AND (v_desde < v_ida OR v_desde > v_vuelta))
        OR (v_hasta IS NOT NULL AND (v_hasta < v_ida OR v_hasta > v_vuelta))
      ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Las fechas del destino exceden el rango de fechas del viaje';
      END IF;

      IF v_did IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM viaje_destino WHERE id = v_did AND viaje_id = v_viaje_id) THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destino inexistente';
        END IF;
        UPDATE viaje_destino
        SET destino = v_nombre, fecha_desde = v_desde, fecha_hasta = v_hasta, orden = v_i
        WHERE id = v_did;
      ELSE
        INSERT INTO viaje_destino (viaje_id, destino, fecha_desde, fecha_hasta, orden)
        VALUES (v_viaje_id, v_nombre, v_desde, v_hasta, v_i);
        SET v_did = LAST_INSERT_ID();
      END IF;

      SET v_servicios = JSON_EXTRACT(v_item, '$.servicios');
      IF v_servicios IS NOT NULL AND JSON_TYPE(v_servicios) = 'ARRAY' AND JSON_LENGTH(v_servicios) > 0 THEN
        INSERT INTO servicio (viaje_id, destino_id, servicio_tipo_id, valor, pagado_por, moneda_id, cotizacion, observacion)
        SELECT v_viaje_id, v_did, j.servicio_tipo_id, j.valor, j.pagado_por, j.moneda_id, j.cotizacion, j.observacion
        FROM JSON_TABLE(
          v_servicios, '$[*]'
          COLUMNS (
            servicio_tipo_id INT PATH '$.servicio_tipo_id',
            valor DECIMAL(12,2) PATH '$.valor' DEFAULT '0' ON EMPTY,
            pagado_por VARCHAR(10) PATH '$.pagado_por' DEFAULT '"pendiente"' ON EMPTY,
            moneda_id INT PATH '$.moneda_id',
            cotizacion DECIMAL(12,2) PATH '$.cotizacion' NULL ON EMPTY,
            observacion VARCHAR(255) PATH '$.observacion' NULL ON EMPTY
          )
        ) j;
      END IF;

      SET v_i = v_i + 1;
    END WHILE;
  END IF;

  IF p_sin_destino IS NOT NULL THEN
    IF JSON_TYPE(p_sin_destino) <> 'ARRAY' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lista de servicios sin destino invalida';
    END IF;

    DELETE FROM servicio WHERE viaje_id = v_viaje_id AND destino_id IS NULL;

    IF JSON_LENGTH(p_sin_destino) > 0 THEN
      INSERT INTO servicio (viaje_id, destino_id, servicio_tipo_id, valor, pagado_por, moneda_id, cotizacion, observacion)
      SELECT v_viaje_id, NULL, j.servicio_tipo_id, j.valor, j.pagado_por, j.moneda_id, j.cotizacion, j.observacion
      FROM JSON_TABLE(
        p_sin_destino, '$[*]'
        COLUMNS (
          servicio_tipo_id INT PATH '$.servicio_tipo_id',
          valor DECIMAL(12,2) PATH '$.valor' DEFAULT '0' ON EMPTY,
          pagado_por VARCHAR(10) PATH '$.pagado_por' DEFAULT '"pendiente"' ON EMPTY,
          moneda_id INT PATH '$.moneda_id',
          cotizacion DECIMAL(12,2) PATH '$.cotizacion' NULL ON EMPTY,
          observacion VARCHAR(255) PATH '$.observacion' NULL ON EMPTY
        )
      ) j;
    END IF;
  END IF;
END;;

CREATE PROCEDURE insertar_viaje(
  IN p_valor_total DECIMAL(12,2),
  IN p_valor_total_usd DECIMAL(12,2),
  IN p_destino ENUM('nacional','internacional'),
  IN p_fecha DATE,
  IN p_fecha_ida DATE,
  IN p_fecha_vuelta DATE,
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2),
  IN p_sucursal_id TINYINT,
  IN p_pago ENUM('contado_efectivo','contado_transferencia','cuotas','financiacion'),
  IN p_pasajeros JSON,
  IN p_destinos JSON
)
BEGIN
  DECLARE v_legajo VARCHAR(20);

  INSERT INTO viaje (fecha, valor_total, valor_total_usd, destino, fecha_ida, fecha_vuelta, moneda_id, cotizacion, pago, sucursal_id)
  VALUES (p_fecha, p_valor_total, IFNULL(p_valor_total_usd, 0), p_destino, p_fecha_ida, p_fecha_vuelta, p_moneda_id, p_cotizacion, p_pago, p_sucursal_id);

  SELECT legajo INTO v_legajo FROM viaje WHERE id = LAST_INSERT_ID();

  CALL guardar_pasajeros_viaje(v_legajo, p_pasajeros);

  IF p_destinos IS NOT NULL THEN
    CALL guardar_destinos_viaje(v_legajo, p_destinos, NULL);
  END IF;

  SELECT v_legajo AS id;
END;;

CREATE PROCEDURE actualizar_viaje(
  IN p_legajo VARCHAR(20),
  IN p_valor_total DECIMAL(12,2),
  IN p_valor_total_usd DECIMAL(12,2),
  IN p_destino ENUM('nacional','internacional'),
  IN p_fecha DATE,
  IN p_fecha_ida DATE,
  IN p_fecha_vuelta DATE,
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2),
  IN p_pago ENUM('contado_efectivo','contado_transferencia','cuotas','financiacion'),
  IN p_pasajeros JSON,
  IN p_destinos JSON,
  IN p_sin_destino JSON
)
BEGIN
  UPDATE viaje SET
    valor_total     = IFNULL(p_valor_total, valor_total),
    valor_total_usd = IFNULL(p_valor_total_usd, valor_total_usd),
    destino         = IFNULL(p_destino, destino),
    fecha           = IFNULL(p_fecha, fecha),
    fecha_ida       = IFNULL(p_fecha_ida, fecha_ida),
    fecha_vuelta    = IFNULL(p_fecha_vuelta, fecha_vuelta),
    moneda_id       = IFNULL(p_moneda_id, moneda_id),
    cotizacion      = IFNULL(p_cotizacion, cotizacion),
    pago            = IFNULL(p_pago, pago)
  WHERE legajo = p_legajo;

  IF p_pasajeros IS NOT NULL THEN
    CALL guardar_pasajeros_viaje(p_legajo, p_pasajeros);
  END IF;

  IF p_destinos IS NOT NULL OR p_sin_destino IS NOT NULL THEN
    CALL guardar_destinos_viaje(p_legajo, p_destinos, p_sin_destino);
  END IF;

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