-- ==========================================================
-- 014: legajos por sucursal con secuencia propia
-- ==========================================================

-- 1. El legajo ya no se recalcula al editar (la sucursal queda fija)
DROP TRIGGER IF EXISTS trg_viaje_actualizar_legajo;

-- 2. Tabla de secuencia: guarda el ÚLTIMO número usado por sucursal
CREATE TABLE IF NOT EXISTS sucursal_legajo_seq (
  sucursal_id   TINYINT NOT NULL PRIMARY KEY,
  ultimo_numero INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_seq_sucursal FOREIGN KEY (sucursal_id) REFERENCES sucursal(id)
);

-- 1 = Baradero, 2 = Hurlingham. Se ajusta el día del deploy (ver final)
INSERT IGNORE INTO sucursal_legajo_seq (sucursal_id, ultimo_numero) VALUES (1, 0), (2, 0);

-- 3. Trigger de alta
DROP TRIGGER IF EXISTS trg_viaje_legajo;
DELIMITER ;;
CREATE TRIGGER trg_viaje_legajo BEFORE INSERT ON viaje FOR EACH ROW
BEGIN
  DECLARE v_prefijo VARCHAR(1);
  DECLARE v_num INT;

  IF NEW.legajo IS NULL OR NEW.legajo = '' THEN
    SELECT prefijo INTO v_prefijo FROM sucursal WHERE id = NEW.sucursal_id;
    IF v_prefijo IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sucursal inválida: no se puede generar el legajo';
    END IF;

    -- El UPDATE bloquea la fila hasta el commit: dos altas simultáneas no repiten número
    UPDATE sucursal_legajo_seq
    SET ultimo_numero = ultimo_numero + 1
    WHERE sucursal_id = NEW.sucursal_id;

    SELECT ultimo_numero INTO v_num
    FROM sucursal_legajo_seq
    WHERE sucursal_id = NEW.sucursal_id;

    IF v_num IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Falta la fila de la sucursal en sucursal_legajo_seq';
    END IF;

    SET NEW.legajo = CONCAT('TBS', v_prefijo, IF(v_num < 1000, LPAD(v_num, 3, '0'), v_num));
  END IF;
END;;
DELIMITER ;

-- 4. Actualizar viaje por legajo (sin tocar sucursal ni legajo)
DROP PROCEDURE IF EXISTS actualizar_viaje;
DELIMITER ;;
CREATE PROCEDURE actualizar_viaje(
  IN p_legajo VARCHAR(20),
  IN p_apellido VARCHAR(50),
  IN p_valor_total DECIMAL(12,2),
  IN p_valor_total_usd DECIMAL(12,2),
  IN p_destino ENUM('nacional','internacional'),
  IN p_fecha DATE,
  IN p_fecha_ida DATE,
  IN p_fecha_vuelta DATE,
  IN p_moneda_id INT,
  IN p_cotizacion DECIMAL(12,2)
)
BEGIN
  UPDATE viaje SET
    apellido        = IFNULL(p_apellido, apellido),
    valor_total     = IFNULL(p_valor_total, valor_total),
    valor_total_usd = IFNULL(p_valor_total_usd, valor_total_usd),
    destino         = IFNULL(p_destino, destino),
    fecha           = IFNULL(p_fecha, fecha),
    fecha_ida       = IFNULL(p_fecha_ida, fecha_ida),
    fecha_vuelta    = IFNULL(p_fecha_vuelta, fecha_vuelta),
    moneda_id       = IFNULL(p_moneda_id, moneda_id),
    cotizacion      = IFNULL(p_cotizacion, cotizacion)
  WHERE legajo = p_legajo;

  SELECT p_legajo AS id;
END;;
DELIMITER ;

-- 5. Obtener viaje: id = legajo, y se agrega sucursal_id
USE theblacksheep_test;

DROP PROCEDURE IF EXISTS obtener_viajes;
DELIMITER ;;
CREATE PROCEDURE obtener_viajes(
  IN p_orden VARCHAR(4),
  IN p_limit INT,
  IN p_offset INT,
  IN p_mes INT,
  IN p_anio INT,
  IN p_sucursal_id TINYINT
)
BEGIN
  SELECT
    v.legajo AS id,
    v.sucursal_id,
    v.fecha,
    ve.estado_calculado AS estado,
    v.cancelado,
    v.apellido,
    v.valor_total,
    v.valor_total_usd,
    v.fecha_ida,
    v.fecha_vuelta,
    m.moneda,
    v.destino
  FROM viaje v
  INNER JOIN v_viaje_estado ve ON ve.viaje_id = v.id
  LEFT JOIN moneda m ON m.id = v.moneda_id
  WHERE (p_mes IS NULL OR MONTH(v.fecha) = p_mes)
    AND (p_anio IS NULL OR YEAR(v.fecha) = p_anio)
    AND (p_sucursal_id IS NULL OR v.sucursal_id = p_sucursal_id)
  ORDER BY 
    CASE WHEN p_orden = 'asc' THEN v.fecha END ASC,
    CASE WHEN p_orden = 'desc' OR p_orden IS NULL THEN v.fecha END DESC,
    v.id DESC
  LIMIT p_limit OFFSET p_offset;
END;;
DELIMITER ;