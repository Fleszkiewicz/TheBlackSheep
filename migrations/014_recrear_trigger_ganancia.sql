-- 014: recrea trg_actualizar_ganancia_before_update_valTotal con la misma logica,
-- pero sin el definer root@% que venia del backup de produccion (no existe en la base local).
DROP TRIGGER IF EXISTS trg_actualizar_ganancia_before_update_valTotal;;

CREATE TRIGGER trg_actualizar_ganancia_before_update_valTotal BEFORE UPDATE ON viaje FOR EACH ROW
BEGIN
  DECLARE v_base_ars DECIMAL(14,2);
  DECLARE v_base_usd DECIMAL(14,2);
  SET v_base_ars = COALESCE(NULLIF(NEW.valor_total, 0), OLD.valor_total, 0);
  SET v_base_usd = COALESCE(NULLIF(NEW.valor_total_usd, 0), OLD.valor_total_usd, 0);
  IF NEW.moneda_id = 1 THEN
    SET NEW.valor_total     = ROUND(v_base_ars, 2);
    SET NEW.valor_total_usd = 0;
    SET NEW.ganancia        = ROUND(COALESCE(NEW.valor_total, 0) - COALESCE(NEW.costo, 0), 2);
    SET NEW.ganancia_usd    = 0;
  ELSEIF NEW.moneda_id = 2 THEN
    IF NEW.cotizacion IS NULL OR NEW.cotizacion <= 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cotizacion invalida para convertir a USD';
    END IF;
    SET NEW.valor_total_usd = ROUND(v_base_usd + (v_base_ars / NEW.cotizacion), 2);
    SET NEW.valor_total     = 0;
    SET NEW.ganancia_usd    = ROUND(COALESCE(NEW.valor_total_usd, 0) - COALESCE(NEW.costo_usd, 0), 2);
    SET NEW.ganancia        = 0;
  ELSEIF NEW.moneda_id = 3 THEN
    SET NEW.valor_total     = ROUND(v_base_ars, 2);
    SET NEW.valor_total_usd = ROUND(v_base_usd, 2);
    SET NEW.ganancia        = ROUND(COALESCE(NEW.valor_total, 0) - COALESCE(NEW.costo, 0), 2);
    SET NEW.ganancia_usd    = ROUND(COALESCE(NEW.valor_total_usd, 0) - COALESCE(NEW.costo_usd, 0), 2);
  END IF;
END;;