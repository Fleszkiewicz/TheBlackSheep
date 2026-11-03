ALTER TABLE viaje ADD legajo VARCHAR(6) UNIQUE;
SET SQL_SAFE_UPDATES = 0;
UPDATE viaje SET legajo = id;

SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE servicio DROP PRIMARY KEY;
ALTER TABLE servicio ADD COLUMN viaje_id_temp INT;

-- Quitamos la PK vieja de viaje y la hacemos INT AUTO_INCREMENT
ALTER TABLE viaje DROP PRIMARY KEY;
ALTER TABLE viaje MODIFY COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE viaje MODIFY COLUMN id VARCHAR(6) NULL;
UPDATE viaje SET id = NULL;
ALTER TABLE viaje MODIFY COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

DROP TRIGGER IF EXISTS trg_actualizar_estado_viaje;
DROP TRIGGER IF EXISTS trg_calcular_costo_insert;
DROP TRIGGER IF EXISTS trg_actualizar_estado_viaje_update;
DROP TRIGGER IF EXISTS trg_calcular_costo_update;
DROP TRIGGER IF EXISTS trg_calcular_costo_delete;

SET FOREIGN_KEY_CHECKS = 0;
UPDATE servicio s
SET s.viaje_id_temp = (
    SELECT v.id 
    FROM viaje v 
    WHERE v.legajo = s.viaje_id
);

-- 1. Eliminamos la columna vieja de texto
ALTER TABLE servicio DROP COLUMN viaje_id;

-- 2. Renombramos la temporal al nombre definitivo
ALTER TABLE servicio RENAME COLUMN viaje_id_temp TO viaje_id;
ALTER TABLE servicio MODIFY COLUMN viaje_id INT NOT NULL;

-- 3. Recreamos la clave primaria compuesta
ALTER TABLE servicio ADD PRIMARY KEY (viaje_id, servicio_tipo_id);

-- 4. Recreamos la clave foránea hacia viaje
ALTER TABLE servicio 
ADD CONSTRAINT servicio_ibfk_1 
FOREIGN KEY (viaje_id) REFERENCES viaje(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

SET FOREIGN_KEY_CHECKS = 1;

DELIMITER ;;

CREATE TRIGGER `trg_actualizar_estado_viaje` AFTER INSERT ON `servicio` FOR EACH ROW BEGIN
  DECLARE servicios_pendientes INT;
  SELECT COUNT(*) INTO servicios_pendientes FROM servicio WHERE viaje_id = NEW.viaje_id AND pagado_por = 'pendiente';
  IF servicios_pendientes = 0 THEN
    UPDATE viaje SET estado = 'finalizado' WHERE id = NEW.viaje_id;
  ELSE
    UPDATE viaje SET estado = 'pendiente' WHERE id = NEW.viaje_id;
  END IF;
END;;

CREATE TRIGGER `trg_calcular_costo_insert` AFTER INSERT ON `servicio` FOR EACH ROW BEGIN
    DECLARE v_moneda_viaje INT;
    SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = NEW.viaje_id;
    IF v_moneda_viaje = 1 THEN
        UPDATE viaje SET costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0), costo_usd = 0 WHERE id = NEW.viaje_id;
    ELSEIF v_moneda_viaje = 2 THEN
        UPDATE viaje SET costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0), costo = 0 WHERE id = NEW.viaje_id;
    ELSEIF v_moneda_viaje = 3 THEN
        UPDATE viaje SET costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0), costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0) WHERE id = NEW.viaje_id;
    END IF;
END;;

CREATE TRIGGER `trg_actualizar_estado_viaje_update` AFTER UPDATE ON `servicio` FOR EACH ROW BEGIN
  DECLARE servicios_pendientes INT;
  SELECT COUNT(*) INTO servicios_pendientes FROM servicio WHERE viaje_id = NEW.viaje_id AND pagado_por = 'pendiente';
  IF servicios_pendientes = 0 THEN
    UPDATE viaje SET estado = 'finalizado' WHERE id = NEW.viaje_id;
  ELSE
    UPDATE viaje SET estado = 'pendiente' WHERE id = NEW.viaje_id;
  END IF;
END;;

CREATE TRIGGER `trg_calcular_costo_update` AFTER UPDATE ON `servicio` FOR EACH ROW BEGIN
    DECLARE v_moneda_viaje INT;
    SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = NEW.viaje_id;
    IF v_moneda_viaje = 1 THEN
        UPDATE viaje SET costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0), costo_usd = 0 WHERE id = NEW.viaje_id;
    ELSEIF v_moneda_viaje = 2 THEN
        UPDATE viaje SET costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0), costo = 0 WHERE id = NEW.viaje_id;
    ELSEIF v_moneda_viaje = 3 THEN
        UPDATE viaje SET costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0), costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0) WHERE id = NEW.viaje_id;
    END IF;
END;;

CREATE TRIGGER `trg_calcular_costo_delete` AFTER DELETE ON `servicio` FOR EACH ROW BEGIN
    DECLARE v_moneda_viaje INT;
    SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = OLD.viaje_id;
    IF v_moneda_viaje = 1 THEN
        UPDATE viaje SET costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0), costo_usd = 0 WHERE id = OLD.viaje_id;
    ELSEIF v_moneda_viaje = 2 THEN
        UPDATE viaje SET costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0), costo = 0 WHERE id = OLD.viaje_id;
    ELSEIF v_moneda_viaje = 3 THEN
        UPDATE viaje SET costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0), costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0) WHERE id = OLD.viaje_id;
    END IF;
END;;

DELIMITER ;