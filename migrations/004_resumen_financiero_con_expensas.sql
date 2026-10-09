DROP PROCEDURE IF EXISTS resumen_financiero;;

CREATE PROCEDURE resumen_financiero(
  IN p_mes INT,
  IN p_anio INT,
  IN p_moneda INT
)
BEGIN
    SELECT
        T.moneda,
        MONTHNAME(T.fecha_ref) AS mes,
        MONTH(T.fecha_ref) AS mes_num,
        SUM(T.ingreso) AS ingreso,
        SUM(T.egreso) AS egreso,
        SUM(T.ingreso) - SUM(T.egreso) AS ganancia
    FROM (
        SELECT 'ars' AS moneda, 1 AS moneda_id, v.fecha AS fecha_ref,
               v.valor_total AS ingreso, IFNULL(v.costo, 0) AS egreso
        FROM viaje v
        WHERE v.moneda_id = 1 AND v.estado = 'finalizado' AND YEAR(v.fecha) = p_anio

        UNION ALL

        SELECT 'usd' AS moneda, 2 AS moneda_id, v.fecha AS fecha_ref,
               IFNULL(v.valor_total_usd, 0) AS ingreso, IFNULL(v.costo_usd, 0) AS egreso
        FROM viaje v
        WHERE v.moneda_id = 2 AND v.estado = 'finalizado' AND YEAR(v.fecha) = p_anio

        UNION ALL

        SELECT 'ars' AS moneda, 1 AS moneda_id, v.fecha AS fecha_ref,
               IFNULL(v.valor_total, 0) AS ingreso, IFNULL(v.costo, 0) AS egreso
        FROM viaje v
        WHERE v.moneda_id = 3 AND v.estado = 'finalizado' AND YEAR(v.fecha) = p_anio

        UNION ALL

        SELECT 'usd' AS moneda, 2 AS moneda_id, v.fecha AS fecha_ref,
               IFNULL(v.valor_total_usd, 0) AS ingreso, IFNULL(v.costo_usd, 0) AS egreso
        FROM viaje v
        WHERE v.moneda_id = 3 AND v.estado = 'finalizado' AND YEAR(v.fecha) = p_anio

        UNION ALL

        SELECT 'ars' AS moneda, 1 AS moneda_id, e.fecha AS fecha_ref,
               0 AS ingreso, e.monto AS egreso
        FROM expensa e
        WHERE e.moneda_id = 1 AND YEAR(e.fecha) = p_anio

        UNION ALL

        SELECT 'usd' AS moneda, 2 AS moneda_id, e.fecha AS fecha_ref,
               0 AS ingreso, e.monto AS egreso
        FROM expensa e
        WHERE e.moneda_id = 2 AND YEAR(e.fecha) = p_anio

    ) AS T
    WHERE (p_moneda IS NULL OR T.moneda_id = p_moneda)
      AND (p_mes IS NULL OR MONTH(T.fecha_ref) = p_mes)
    GROUP BY T.moneda, T.moneda_id, MONTH(T.fecha_ref), MONTHNAME(T.fecha_ref)
    ORDER BY mes_num, T.moneda;
END