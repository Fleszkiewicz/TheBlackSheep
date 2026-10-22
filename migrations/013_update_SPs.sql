-- ==========================================
-- 1. ELIMINAR PROCEDIMIENTOS VIEJOS
-- ==========================================
DROP PROCEDURE IF EXISTS `insertar_viaje`;
DROP PROCEDURE IF EXISTS `actualizar_viaje`;
DROP PROCEDURE IF EXISTS `obtener_viaje`;
DROP PROCEDURE IF EXISTS `eliminar_viaje`;
DROP PROCEDURE IF EXISTS `insertar_servicio_viaje`;
DROP PROCEDURE IF EXISTS `actualizar_servicio_viaje`;
DROP PROCEDURE IF EXISTS `eliminar_servicio_viaje`;
DROP PROCEDURE IF EXISTS `recalcular_viaje_costo`;


-- ==========================================
-- 2. CREAR PROCEDIMIENTOS DE VIAJES
-- ==========================================

-- A. Insertar Viaje (El trigger 'trg_viaje_legajo' autogenera el legajo según la sucursal y el ID va por AUTO_INCREMENT)
DELIMITER ;;
CREATE PROCEDURE `insertar_viaje`(
  IN p_apellido VARCHAR(50),
  IN p_valor_total DECIMAL(12,2),
  IN p_valor_total_usd DECIMAL(12,2),
  IN p_destino ENUM('nacional', 'internacional'),
  IN p_fecha DATE,
  IN p_fecha_ida DATE,
  IN p_fecha_vuelta DATE,
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2),
  IN p_sucursal_id TINYINT
)
BEGIN
  INSERT INTO viaje (fecha, apellido, valor_total, valor_total_usd, destino, fecha_vuelta, fecha_ida, moneda_id, cotizacion, sucursal_id)
  VALUES (
    p_fecha,
    p_apellido,
    p_valor_total,
    IFNULL(p_valor_total_usd, 0),
    p_destino,
    p_fecha_vuelta,
    p_fecha_ida,
    p_moneda_id,
    p_cotizacion,
    p_sucursal_id
  );

  -- Retorna el legajo generado automáticamente (ej: TBSB001 o TBSH005) como id para la app
  SELECT legajo AS id FROM viaje WHERE id = LAST_INSERT_ID();
END;;
DELIMITER ;


-- B. Actualizar Viaje (Permite actualizar datos y gestiona el recálculo de legajo si cambia de sucursal)
DELIMITER ;;
CREATE PROCEDURE `actualizar_viaje` (
  IN p_id INT,                        -- Recibimos el ID numérico interno para buscar sin errores
  IN p_sucursal_id TINYINT,           -- Nueva sucursal (o la misma)
  IN p_apellido VARCHAR(50),
  IN p_valor_total DECIMAL(12,2),
  IN p_valor_total_usd DECIMAL(12,2),
  IN p_destino ENUM('nacional', 'internacional'),
  IN p_fecha DATE,
  IN p_fecha_ida DATE,
  IN p_fecha_vuelta DATE,
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2)
)
BEGIN
  DECLARE v_sucursal_actual TINYINT;
  DECLARE v_nuevo_prefijo VARCHAR(1);
  DECLARE v_next_num INT;
  DECLARE v_nuevo_legajo VARCHAR(10);

  -- 1. Consultamos cuál es la sucursal que tenía este viaje antes de actualizar
  SELECT sucursal_id INTO v_sucursal_actual FROM viaje WHERE id = p_id;

  -- 2. Si la sucursal cambió, calculamos un nuevo legajo independiente para la nueva sucursal
  IF p_sucursal_id <> v_sucursal_actual THEN
    -- Obtenemos el prefijo de la nueva sucursal ('B' o 'H')
    SELECT prefijo INTO v_nuevo_prefijo FROM sucursal WHERE id = p_sucursal_id;

    -- Buscamos el siguiente número correlativo disponible en la NUEVA sucursal
    SELECT COALESCE(MAX(CAST(SUBSTRING(v.legajo, 5) AS UNSIGNED)), 0) + 1 
    INTO v_next_num 
    FROM viaje v 
    WHERE v.sucursal_id = p_sucursal_id;

    -- Armamos el nuevo legajo (ej: TBSH003)
    SET v_nuevo_legajo = CONCAT('TBS', v_nuevo_prefijo, LPAD(v_next_num, 3, '0'));

    -- Actualizamos incluyendo el cambio de legajo y sucursal
    UPDATE viaje
    SET
        sucursal_id = p_sucursal_id,
        legajo = v_nuevo_legajo,
        apellido = IFNULL(p_apellido, apellido),
        valor_total = IFNULL(p_valor_total, valor_total),
        valor_total_usd = IFNULL(p_valor_total_usd, valor_total_usd),
        destino = IFNULL(p_destino, destino),
        moneda_id = IFNULL(p_moneda_id, moneda_id),
        fecha_ida = IFNULL(p_fecha_ida, fecha_ida),
        fecha_vuelta = IFNULL(p_fecha_vuelta, fecha_vuelta),
        cotizacion = IFNULL(p_cotizacion, cotizacion),
        fecha = IFNULL(p_fecha, fecha)
    WHERE id = p_id;

  ELSE
    -- 3. Si la sucursal es la misma, actualizamos normal sin tocar el legajo
    UPDATE viaje
    SET
        apellido = IFNULL(p_apellido, apellido),
        valor_total = IFNULL(p_valor_total, valor_total),
        valor_total_usd = IFNULL(p_valor_total_usd, valor_total_usd),
        destino = IFNULL(p_destino, destino),
        moneda_id = IFNULL(p_moneda_id, moneda_id),
        fecha_ida = IFNULL(p_fecha_ida, fecha_ida),
        fecha_vuelta = IFNULL(p_fecha_vuelta, fecha_vuelta),
        cotizacion = IFNULL(p_cotizacion, cotizacion),
        fecha = IFNULL(p_fecha, fecha)
    WHERE id = p_id;
  END IF;

  -- Retornamos el legajo resultante como id
  SELECT legajo AS id FROM viaje WHERE id = p_id;
END;;
DELIMITER ;


-- C. Obtener Viaje (Recibe el legajo ej: 'TBSB001' y resuelve internamente)
DELIMITER ;;
CREATE PROCEDURE `obtener_viaje`(IN p_legajo VARCHAR(10))
BEGIN
  SELECT
    v.id,
    v.legajo AS codigo_id,
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
  WHERE v.legajo = p_legajo;
END;;
DELIMITER ;


-- D. Eliminar Viaje (Borra por legajo, eliminando en cascada sus servicios gracias a la FK)
DELIMITER ;;
CREATE PROCEDURE `eliminar_viaje`(IN p_legajo VARCHAR(10))
BEGIN
	DELETE FROM viaje WHERE legajo = p_legajo;
    SELECT p_legajo AS id;
END;;
DELIMITER ;


-- ==========================================
-- 3. CREAR PROCEDIMIENTOS DE SERVICIOS
-- ==========================================
-- Nota: Reciben 'p_viaje_legajo' para mantener compatibilidad con tu app, 
-- pero resuelven internamente el ID numérico para que los JOINs sean veloces.

-- A. Insertar Servicio
DELIMITER ;;
CREATE PROCEDURE `insertar_servicio_viaje`(
    IN p_viaje_legajo VARCHAR(10),
    IN p_servicio_tipo_id TINYINT,
    IN p_valor DECIMAL (12,2),
    IN p_pagado_por ENUM ('pablo','soledad', 'mariana','pendiente', 'mixto'),
    IN p_moneda_id INT,
    IN p_cotizacion DECIMAL (12,2)
)
BEGIN
    DECLARE v_viaje_id INT;
    SELECT id INTO v_viaje_id FROM viaje WHERE legajo = p_viaje_legajo;

    INSERT INTO servicio (viaje_id, servicio_tipo_id, valor, pagado_por, moneda_id, cotizacion)
    VALUES (v_viaje_id, p_servicio_tipo_id, p_valor, p_pagado_por, p_moneda_id, p_cotizacion);
END;;
DELIMITER ;


-- B. Actualizar Servicio
DELIMITER ;;
CREATE PROCEDURE `actualizar_servicio_viaje`(
    IN p_viaje_legajo VARCHAR(10), 
    IN p_servicio_tipo_id TINYINT, 
    IN p_valor DECIMAL (12,2), 
    IN p_pagado_por ENUM ('pablo','soledad', 'mariana','pendiente', 'mixto'), 
    IN p_moneda_id INT, 
    IN p_cotizacion DECIMAL (12,2)
)
BEGIN
    DECLARE v_viaje_id INT;
    SELECT id INTO v_viaje_id FROM viaje WHERE legajo = p_viaje_legajo;

    UPDATE servicio
    SET valor = IFNULL(p_valor, valor),
        pagado_por = IFNULL(p_pagado_por, pagado_por),
        moneda_id = IFNULL(p_moneda_id, moneda_id),
        cotizacion = IFNULL(p_cotizacion, cotizacion)
    WHERE viaje_id = v_viaje_id
      AND servicio_tipo_id = p_servicio_tipo_id;
END;;
DELIMITER ;


-- C. Eliminar Servicio
DELIMITER ;;
CREATE PROCEDURE `eliminar_servicio_viaje`(
    IN p_viaje_legajo VARCHAR(10), 
    IN p_servicio_tipo_id TINYINT
)
BEGIN
	DECLARE v_viaje_id INT;
    SELECT id INTO v_viaje_id FROM viaje WHERE legajo = p_viaje_legajo;

	DELETE FROM servicio 
    WHERE viaje_id = v_viaje_id 
      AND servicio_tipo_id = p_servicio_tipo_id;
END;;
DELIMITER ;


-- D. Recalcular Costo de Viaje
DELIMITER ;;
CREATE PROCEDURE `recalcular_viaje_costo`(IN p_viaje_legajo VARCHAR(10))
BEGIN
    DECLARE v_viaje_id INT;
    DECLARE v_moneda_viaje INT;
    DECLARE v_costo DECIMAL(15,2);

    SELECT id, moneda_id INTO v_viaje_id, v_moneda_viaje
    FROM viaje
    WHERE legajo = p_viaje_legajo;
    
    SELECT COALESCE(SUM(
        CASE
            WHEN s.moneda_id = v_moneda_viaje THEN s.valor
            ELSE 0
        END
    ), 0) INTO v_costo
    FROM servicio s
    WHERE s.viaje_id = v_viaje_id;

    UPDATE viaje
    SET costo = v_costo,
        ganancia = valor_total - v_costo
    WHERE id = v_viaje_id;
END;;
DELIMITER ;