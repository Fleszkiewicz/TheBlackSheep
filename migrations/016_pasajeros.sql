-- 016: modelo de pasajeros. pasajeros = maestro global de personas (DNI opcional y unico).
-- viaje_pasajeros = quienes viajan en cada viaje (titular + acompanantes) y su categoria de edad en ese viaje.
-- viaje deja de tener apellido y nombre: el titular se obtiene de viaje_pasajeros (es_titular = 1).
CREATE TABLE pasajeros (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  dni VARCHAR(20) NULL,
  nombre VARCHAR(50) NULL,
  apellido VARCHAR(50) NOT NULL,
  email VARCHAR(100) NULL,
  telefono VARCHAR(30) NULL,
  pasaporte VARCHAR(20) NULL,
  vencimiento_dni DATE NULL,
  vencimiento_pasaporte DATE NULL,
  origen_viaje_id INT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_pasajeros_dni (dni),
  KEY idx_pasajeros_apellido (apellido)
);;

CREATE TABLE viaje_pasajeros (
  viaje_id INT NOT NULL,
  pasajero_id INT NOT NULL,
  es_titular TINYINT(1) NOT NULL DEFAULT 0,
  categoria_edad ENUM('infante','menor','adulto','mayor') NULL,
  titular_unico TINYINT GENERATED ALWAYS AS (IF(es_titular = 1, 1, NULL)) VIRTUAL,
  PRIMARY KEY (viaje_id, pasajero_id),
  UNIQUE KEY uq_un_titular_por_viaje (viaje_id, titular_unico),
  KEY idx_vp_pasajero (pasajero_id),
  CONSTRAINT fk_vp_viaje FOREIGN KEY (viaje_id) REFERENCES viaje(id) ON DELETE CASCADE,
  CONSTRAINT fk_vp_pasajero FOREIGN KEY (pasajero_id) REFERENCES pasajeros(id)
);;

INSERT INTO pasajeros (apellido, nombre, origen_viaje_id)
SELECT apellido, nombre, id FROM viaje;;

INSERT INTO viaje_pasajeros (viaje_id, pasajero_id, es_titular)
SELECT origen_viaje_id, id, 1 FROM pasajeros WHERE origen_viaje_id IS NOT NULL;;

ALTER TABLE pasajeros DROP COLUMN origen_viaje_id;;

ALTER TABLE viaje DROP COLUMN apellido, DROP COLUMN nombre;;

DROP PROCEDURE IF EXISTS insertar_viaje;;

DROP PROCEDURE IF EXISTS actualizar_viaje;;

DROP PROCEDURE IF EXISTS obtener_viaje;;

DROP PROCEDURE IF EXISTS obtener_viajes;;

DROP PROCEDURE IF EXISTS guardar_pasajeros_viaje;;

CREATE PROCEDURE guardar_pasajeros_viaje(
  IN p_viaje_legajo VARCHAR(20),
  IN p_pasajeros JSON
)
BEGIN
  DECLARE v_viaje_id INT DEFAULT NULL;
  DECLARE v_n INT DEFAULT 0;
  DECLARE v_i INT DEFAULT 0;
  DECLARE v_titulares INT DEFAULT 0;
  DECLARE v_item JSON;
  DECLARE v_pid INT DEFAULT NULL;
  DECLARE v_pid_dni INT DEFAULT NULL;
  DECLARE v_dni VARCHAR(20);
  DECLARE v_nombre VARCHAR(50);
  DECLARE v_apellido VARCHAR(50);
  DECLARE v_email VARCHAR(100);
  DECLARE v_telefono VARCHAR(30);
  DECLARE v_pasaporte VARCHAR(20);
  DECLARE v_venc_dni DATE;
  DECLARE v_venc_pas DATE;
  DECLARE v_categoria VARCHAR(10);
  DECLARE v_es_titular TINYINT DEFAULT 0;

  SELECT id INTO v_viaje_id FROM viaje WHERE legajo = p_viaje_legajo;
  IF v_viaje_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Viaje no encontrado';
  END IF;

  IF p_pasajeros IS NULL OR JSON_TYPE(p_pasajeros) <> 'ARRAY' OR JSON_LENGTH(p_pasajeros) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe haber al menos un pasajero';
  END IF;

  SET v_n = JSON_LENGTH(p_pasajeros);

  SELECT COUNT(*) INTO v_titulares
  FROM JSON_TABLE(
    p_pasajeros, '$[*]'
    COLUMNS (es_titular VARCHAR(10) PATH '$.es_titular' DEFAULT '"false"' ON EMPTY)
  ) j
  WHERE j.es_titular IN ('true', '1');

  IF v_titulares <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El viaje debe tener exactamente un titular';
  END IF;

  DELETE FROM viaje_pasajeros WHERE viaje_id = v_viaje_id;

  WHILE v_i < v_n DO
    SET v_item = JSON_EXTRACT(p_pasajeros, CONCAT('$[', v_i, ']'));
    SET v_pid = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.pasajero_id'))), 'null'), '');
    SET v_dni = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.dni'))), 'null'), '');
    SET v_dni = NULLIF(REPLACE(REPLACE(v_dni, '.', ''), ' ', ''), '');
    SET v_nombre = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.nombre'))), 'null'), '');
    SET v_apellido = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.apellido'))), 'null'), '');
    SET v_email = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.email'))), 'null'), '');
    SET v_telefono = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.telefono'))), 'null'), '');
    SET v_pasaporte = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.pasaporte'))), 'null'), '');
    SET v_venc_dni = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.vencimiento_dni'))), 'null'), '');
    SET v_venc_pas = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.vencimiento_pasaporte'))), 'null'), '');
    SET v_categoria = NULLIF(NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.categoria_edad'))), 'null'), '');
    SET v_es_titular = IF(JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.es_titular')) IN ('true', '1'), 1, 0);

    IF v_apellido IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido del pasajero es obligatorio';
    END IF;

    SET v_pid_dni = NULL;
    IF v_dni IS NOT NULL THEN
      SELECT id INTO v_pid_dni FROM pasajeros WHERE dni = v_dni;
    END IF;

    IF v_pid_dni IS NOT NULL THEN
      SET v_pid = v_pid_dni;
      UPDATE pasajeros SET
        nombre = v_nombre,
        apellido = v_apellido,
        email = IFNULL(v_email, email),
        telefono = IFNULL(v_telefono, telefono),
        pasaporte = IFNULL(v_pasaporte, pasaporte),
        vencimiento_dni = IFNULL(v_venc_dni, vencimiento_dni),
        vencimiento_pasaporte = IFNULL(v_venc_pas, vencimiento_pasaporte)
      WHERE id = v_pid;
    ELSEIF v_pid IS NOT NULL THEN
      UPDATE pasajeros SET
        dni = IFNULL(v_dni, dni),
        nombre = v_nombre,
        apellido = v_apellido,
        email = IFNULL(v_email, email),
        telefono = IFNULL(v_telefono, telefono),
        pasaporte = IFNULL(v_pasaporte, pasaporte),
        vencimiento_dni = IFNULL(v_venc_dni, vencimiento_dni),
        vencimiento_pasaporte = IFNULL(v_venc_pas, vencimiento_pasaporte)
      WHERE id = v_pid;
    ELSE
      INSERT INTO pasajeros (dni, nombre, apellido, email, telefono, pasaporte, vencimiento_dni, vencimiento_pasaporte)
      VALUES (v_dni, v_nombre, v_apellido, v_email, v_telefono, v_pasaporte, v_venc_dni, v_venc_pas);
      SET v_pid = LAST_INSERT_ID();
    END IF;

    IF EXISTS (SELECT 1 FROM viaje_pasajeros WHERE viaje_id = v_viaje_id AND pasajero_id = v_pid) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pasajero repetido en el viaje';
    END IF;

    INSERT INTO viaje_pasajeros (viaje_id, pasajero_id, es_titular, categoria_edad)
    VALUES (v_viaje_id, v_pid, v_es_titular, v_categoria);

    SET v_i = v_i + 1;
  END WHILE;
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
  IN p_pasajeros JSON
)
BEGIN
  DECLARE v_legajo VARCHAR(20);

  INSERT INTO viaje (fecha, valor_total, valor_total_usd, destino, fecha_ida, fecha_vuelta, moneda_id, cotizacion, pago, sucursal_id)
  VALUES (p_fecha, p_valor_total, IFNULL(p_valor_total_usd, 0), p_destino, p_fecha_ida, p_fecha_vuelta, p_moneda_id, p_cotizacion, p_pago, p_sucursal_id);

  SELECT legajo INTO v_legajo FROM viaje WHERE id = LAST_INSERT_ID();

  CALL guardar_pasajeros_viaje(v_legajo, p_pasajeros);

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
  IN p_pasajeros JSON
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
  LEFT JOIN viaje_pasajeros vt ON vt.viaje_id = v.id AND vt.es_titular = 1
  LEFT JOIN pasajeros t ON t.id = vt.pasajero_id
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
    AND (v_pattern IS NULL OR v.legajo LIKE v_pattern OR t.apellido LIKE v_pattern OR t.nombre LIKE v_pattern);
END;;