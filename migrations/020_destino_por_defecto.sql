-- 020: destino por defecto para los servicios que no tienen destino.
-- Son los servicios de los legajos de la version anterior (donde no existian los destinos).
-- A cada legajo con servicios sin destino se le crea el destino Sin destino asignado,
-- con las mismas fechas del viaje, y esos servicios pasan a colgar de el.
-- Los dos triggers AFTER UPDATE de servicio se quitan mientras dura el UPDATE y se recrean iguales,
-- para que reasignar el destino no recalcule costos ni cambie el estado guardado de los legajos viejos.
-- La migracion se puede repetir sin duplicar destinos.
DROP TRIGGER IF EXISTS trg_actualizar_estado_viaje_update;;

DROP TRIGGER IF EXISTS trg_calcular_costo_update;;

INSERT INTO viaje_destino (viaje_id, destino, fecha_desde, fecha_hasta, orden)
SELECT v.id, 'Sin destino asignado', v.fecha_ida, v.fecha_vuelta,
       (SELECT COUNT(*) FROM viaje_destino d0 WHERE d0.viaje_id = v.id)
FROM viaje v
WHERE EXISTS (SELECT 1 FROM servicio s WHERE s.viaje_id = v.id AND s.destino_id IS NULL)
  AND NOT EXISTS (SELECT 1 FROM viaje_destino d WHERE d.viaje_id = v.id AND d.destino = 'Sin destino asignado');;

UPDATE servicio s
INNER JOIN viaje_destino d ON d.viaje_id = s.viaje_id AND d.destino = 'Sin destino asignado'
SET s.destino_id = d.id
WHERE s.destino_id IS NULL;;

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