-- 011: viaje.id pasa de VARCHAR(6) a INT AUTO_INCREMENT.
-- El id viejo (TBS001...) se conserva como viaje.legajo (se renombra la columna, no se copia).
-- Se agrega viaje.sucursal_id (nullable, se completa el dia del deploy).
-- servicio.viaje_id pasa a INT. Sin DELIMITER: cada sentencia termina con doble punto y coma.
DROP TRIGGER IF EXISTS trg_viaje_id;;

DROP TRIGGER IF EXISTS trg_actualizar_estado_viaje;;

DROP TRIGGER IF EXISTS trg_actualizar_estado_viaje_update;;

DROP TRIGGER IF EXISTS trg_calcular_costo_insert;;

DROP TRIGGER IF EXISTS trg_calcular_costo_update;;

DROP TRIGGER IF EXISTS trg_calcular_costo_delete;;

DROP TABLE IF EXISTS viaje_seq;;

ALTER TABLE viaje
  ADD COLUMN id_new INT NOT NULL AUTO_INCREMENT,
  ADD UNIQUE KEY uq_id_new (id_new);;

ALTER TABLE servicio ADD COLUMN viaje_id_new INT NULL;;

UPDATE servicio s
JOIN viaje v ON v.id = s.viaje_id
SET s.viaje_id_new = v.id_new;;

ALTER TABLE servicio DROP FOREIGN KEY servicio_ibfk_1;;

ALTER TABLE servicio DROP PRIMARY KEY;;

ALTER TABLE servicio DROP COLUMN viaje_id;;

ALTER TABLE servicio CHANGE COLUMN viaje_id_new viaje_id INT NOT NULL;;

ALTER TABLE viaje
  DROP PRIMARY KEY,
  CHANGE COLUMN id legajo VARCHAR(20) NOT NULL,
  ADD UNIQUE KEY uq_viaje_legajo (legajo);;

ALTER TABLE viaje
  CHANGE COLUMN id_new id INT NOT NULL AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (id),
  DROP INDEX uq_id_new;;

ALTER TABLE viaje
  ADD COLUMN sucursal_id TINYINT NULL AFTER legajo,
  ADD KEY idx_viaje_sucursal (sucursal_id),
  ADD CONSTRAINT fk_viaje_sucursal FOREIGN KEY (sucursal_id) REFERENCES sucursal(id) ON DELETE RESTRICT ON UPDATE CASCADE;;

ALTER TABLE servicio ADD PRIMARY KEY (viaje_id, servicio_tipo_id);;

ALTER TABLE servicio
  ADD CONSTRAINT servicio_ibfk_1 FOREIGN KEY (viaje_id) REFERENCES viaje(id) ON DELETE CASCADE;;

CREATE TRIGGER trg_actualizar_estado_viaje AFTER INSERT ON servicio FOR EACH ROW
BEGIN
  DECLARE servicios_pendientes INT;
  SELECT COUNT(*) INTO servicios_pendientes
  FROM servicio
  WHERE viaje_id = NEW.viaje_id AND pagado_por = 'pendiente';
  IF servicios_pendientes = 0 THEN
    UPDATE viaje SET estado = 'finalizado' WHERE id = NEW.viaje_id;
  ELSE
    UPDATE viaje SET estado = 'pendiente' WHERE id = NEW.viaje_id;
  END IF;
END;;

CREATE TRIGGER trg_actualizar_estado_viaje_update AFTER UPDATE ON servicio FOR EACH ROW
BEGIN
  DECLARE servicios_pendientes INT;
  SELECT COUNT(*) INTO servicios_pendientes
  FROM servicio
  WHERE viaje_id = NEW.viaje_id AND pagado_por = 'pendiente';
  IF servicios_pendientes = 0 THEN
    UPDATE viaje SET estado = 'finalizado' WHERE id = NEW.viaje_id;
  ELSE
    UPDATE viaje SET estado = 'pendiente' WHERE id = NEW.viaje_id;
  END IF;
END;;

CREATE TRIGGER trg_calcular_costo_insert AFTER INSERT ON servicio FOR EACH ROW
BEGIN
  DECLARE v_moneda_viaje INT;
  SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = NEW.viaje_id;
  IF v_moneda_viaje = 1 THEN
    UPDATE viaje SET
      costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),
      costo_usd = 0
    WHERE id = NEW.viaje_id;
  ELSEIF v_moneda_viaje = 2 THEN
    UPDATE viaje SET
      costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),
      costo = 0
    WHERE id = NEW.viaje_id;
  ELSEIF v_moneda_viaje = 3 THEN
    UPDATE viaje SET
      costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),
      costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0)
    WHERE id = NEW.viaje_id;
  END IF;
END;;

CREATE TRIGGER trg_calcular_costo_update AFTER UPDATE ON servicio FOR EACH ROW
BEGIN
  DECLARE v_moneda_viaje INT;
  SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = NEW.viaje_id;
  IF v_moneda_viaje = 1 THEN
    UPDATE viaje SET
      costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),
      costo_usd = 0
    WHERE id = NEW.viaje_id;
  ELSEIF v_moneda_viaje = 2 THEN
    UPDATE viaje SET
      costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),
      costo = 0
    WHERE id = NEW.viaje_id;
  ELSEIF v_moneda_viaje = 3 THEN
    UPDATE viaje SET
      costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0),
      costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = NEW.viaje_id), 0)
    WHERE id = NEW.viaje_id;
  END IF;
END;;

CREATE TRIGGER trg_calcular_costo_delete AFTER DELETE ON servicio FOR EACH ROW
BEGIN
  DECLARE v_moneda_viaje INT;
  SELECT moneda_id INTO v_moneda_viaje FROM viaje WHERE id = OLD.viaje_id;
  IF v_moneda_viaje = 1 THEN
    UPDATE viaje SET
      costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor * IFNULL(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0),
      costo_usd = 0
    WHERE id = OLD.viaje_id;
  ELSEIF v_moneda_viaje = 2 THEN
    UPDATE viaje SET
      costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor / NULLIF(cotizacion, 0) ELSE valor END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0),
      costo = 0
    WHERE id = OLD.viaje_id;
  ELSEIF v_moneda_viaje = 3 THEN
    UPDATE viaje SET
      costo = IFNULL((SELECT SUM(CASE WHEN moneda_id = 1 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0),
      costo_usd = IFNULL((SELECT SUM(CASE WHEN moneda_id = 2 THEN valor ELSE 0 END) FROM servicio WHERE viaje_id = OLD.viaje_id), 0)
    WHERE id = OLD.viaje_id;
  END IF;
END;;