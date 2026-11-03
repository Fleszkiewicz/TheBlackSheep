-- 012: legajos nuevos con contador propio por sucursal (TBSB001, TBSH001, ...).
-- Los legajos viejos (TBS001...) no se tocan. El legajo no se recalcula al editar.
CREATE TABLE IF NOT EXISTS sucursal_legajo_seq (
  sucursal_id TINYINT NOT NULL PRIMARY KEY,
  ultimo_numero INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_seq_sucursal FOREIGN KEY (sucursal_id) REFERENCES sucursal(id)
);;

INSERT IGNORE INTO sucursal_legajo_seq (sucursal_id, ultimo_numero)
SELECT id, 0 FROM sucursal;;

DROP TRIGGER IF EXISTS trg_viaje_legajo;;

CREATE TRIGGER trg_viaje_legajo BEFORE INSERT ON viaje FOR EACH ROW
BEGIN
  DECLARE v_prefijo CHAR(1);
  DECLARE v_num INT;

  IF NEW.legajo IS NULL OR NEW.legajo = '' THEN
    SELECT prefijo INTO v_prefijo FROM sucursal WHERE id = NEW.sucursal_id;
    IF v_prefijo IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sucursal invalida: no se puede generar el legajo';
    END IF;

    INSERT INTO sucursal_legajo_seq (sucursal_id, ultimo_numero)
    VALUES (NEW.sucursal_id, 1)
    ON DUPLICATE KEY UPDATE ultimo_numero = ultimo_numero + 1;

    SELECT ultimo_numero INTO v_num
    FROM sucursal_legajo_seq
    WHERE sucursal_id = NEW.sucursal_id;

    SET NEW.legajo = CONCAT('TBS', v_prefijo, IF(v_num < 1000, LPAD(v_num, 3, '0'), v_num));
  END IF;
END;;