### 13) ¿Cuál fué el mes del año 2020, de mayor decrecimiento (o menor crecimiento) con respecto al mismo mes del año 2019 si se toman en cuenta a nivel general Ventas (Precio * Cantidad) - Compras (Precio * Cantidad) - Gastos? 
#### Responder el Número del Mes:

USE `henry_checkpoint_m3`;
CREATE VIEW mesventas_2019 AS
SELECT 
    MONTH(V.Fecha) AS MesVenta,
    SUM(V.Precio * V.Cantidad - GS.Monto) AS Ganancia
    FROM venta V
    INNER JOIN sucursal S
        ON S.IdSucursal = V.IdSucursal
    INNER JOIN gasto GS
        ON S.IdSucursal = GS.IdSucursal
    WHERE YEAR(V.Fecha) = '2019' AND 
          YEAR(GS.Fecha) = '2019' AND
          MONTH(V.Fecha) = MONTH(GS.Fecha)
    GROUP BY MONTH(V.Fecha) ;

CREATE VIEW mesventas_2020 AS
SELECT 
    MONTH(V.Fecha) AS MesVenta,
    SUM(V.Precio * V.Cantidad - GS.Monto) AS Ganancia
    FROM venta V
    INNER JOIN sucursal S
        ON S.IdSucursal = V.IdSucursal
    INNER JOIN gasto GS
        ON S.IdSucursal = GS.IdSucursal
    WHERE YEAR(V.Fecha) = '2020' AND 
          YEAR(GS.Fecha) = '2020' AND
          MONTH(V.Fecha) = MONTH(GS.Fecha)
    GROUP BY MONTH(V.Fecha) ;

SELECT
    MV2020.MesVenta,
    MV2019.Ganancia AS VentaMV2019,
    MV2020.Ganancia AS Venta2020,
    MV2020.Ganancia - MV2019.Ganancia AS DiferenciaVenta,
    ROUND((MV2020.Ganancia / MV2019.Ganancia),2) AS PorcentajeVenta,
    CASE
        WHEN MV2020.Ganancia > MV2019.Ganancia THEN "Crecimiento"
        WHEN MV2020.Ganancia < MV2019.Ganancia THEN "Decrecimiento"
    END AS 'Crecimiento / Decrecimiento'
    FROM mesventas_2020 AS MV2020
    INNER JOIN mesventas_2019 MV2019
        ON MV2020.MesVenta = MV2019.MesVenta
    GROUP BY MV2020.MesVenta
    ORDER BY DiferenciaVenta ;


SELECT 
*
FROM
comisionesempleados;
