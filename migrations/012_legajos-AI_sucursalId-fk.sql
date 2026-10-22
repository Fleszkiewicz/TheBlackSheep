ALTER TABLE viaje ADD sucursal_id TINYINT;
ALTER TABLE viaje ADD KEY idx_viaje_sucursal(sucursal_id);
ALTER TABLE viaje ADD CONSTRAINT fk_viaje_sucursal FOREIGN KEY (sucursal_id) REFERENCES sucursal(id) ON DELETE RESTRICT ON UPDATE CASCADE;

-- 1. Eliminamos el trigger viejo que ya no sirve
DROP TRIGGER IF EXISTS trg_viaje_id;
DROP TABLE viaje_seq;
DROP TRIGGER IF EXISTS trg_viaje_legajo;
ALTER TABLE viaje MODIFY legajo VARCHAR(20);


-- 2. Creamos el nuevo trigger con secuencias independientes por sucursal
DELIMITER ;;
CREATE TRIGGER `trg_viaje_legajo` BEFORE INSERT ON `viaje` FOR EACH ROW 
BEGIN
  DECLARE v_prefijo VARCHAR(1);
  DECLARE v_next_num INT;

  -- Paso A: Obtenemos la letra de la sucursal ('B' para Baradero, 'H' para Hurlingham)
  SELECT prefijo INTO v_prefijo 
  FROM sucursal 
  WHERE id = NEW.sucursal_id;

  -- Paso B: Calculamos el número siguiente buscando el max número actual de esa sucursal
  -- Extraemos los dígitos a partir del 5to carácter (ej: de 'TBSB015' toma '015')
  SELECT COALESCE(MAX(CAST(SUBSTRING(v.legajo, 5) AS UNSIGNED)), 0) + 1 
  INTO v_next_num 
  FROM viaje v 
  WHERE v.sucursal_id = NEW.sucursal_id;

  -- Paso C: Si la aplicación no mandó un legajo fijo, lo construimos automáticamente
  IF NEW.legajo IS NULL OR NEW.legajo = '' THEN
    SET NEW.legajo = CONCAT('TBS', v_prefijo, LPAD(v_next_num, 3, '0'));
  END IF;
END;;
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_viaje_actualizar_legajo`;

DELIMITER ;;
CREATE TRIGGER `trg_viaje_actualizar_legajo` BEFORE UPDATE ON `viaje` FOR EACH ROW 
BEGIN
  DECLARE v_nuevo_prefijo VARCHAR(1);
  DECLARE v_next_num INT;

  -- Si la sucursal cambió respecto a la que tenía guardada...
  IF NEW.sucursal_id <> OLD.sucursal_id THEN
    
    -- 1. Obtenemos el prefijo de la nueva sucursal ('B' o 'H')
    SELECT prefijo INTO v_nuevo_prefijo 
    FROM sucursal 
    WHERE id = NEW.sucursal_id;

    -- 2. Buscamos el siguiente número correlativo disponible exclusivamente en la NUEVA sucursal
    SELECT COALESCE(MAX(CAST(SUBSTRING(v.legajo, 5) AS UNSIGNED)), 0) + 1 
    INTO v_next_num 
    FROM viaje v 
    WHERE v.sucursal_id = NEW.sucursal_id;

    -- 3. Asignamos automáticamente el nuevo legajo (ej: TBSH003)
    SET NEW.legajo = CONCAT('TBS', v_nuevo_prefijo, LPAD(v_next_num, 3, '0'));
    
  END IF;
END;;
DELIMITER ;

