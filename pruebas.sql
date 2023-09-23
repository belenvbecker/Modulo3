-- Active: 1693354461857@@127.0.0.1@3306@henry_checkpoint_m3
/* 16) La ganancia neta por sucursal es las ventas menos los 
gastos (Ganancia = Venta - Gasto) ¿Cuál es la sucursal con 
mayor ganancia neta en 2020 en la provincia de Córdoba si 
además quitamos los pagos por comisiones? */

-- MODIFICAMOS LAS TABLAS 
ALTER Table venta
ADD COLUMN porcentaje int;

UPDATE venta v
INNER JOIN quiroz q ON v.`idempleado` = q.idempleado
SET v.porcentaje = q.`Porcentaje`;

ALTER Table quiroz
ADD COLUMN idempleado int;

UPDATE quiroz 
set idempleado = (`IdSucursal`*1000000 + `CodigoEmpleado`);

SELECT *from venta
where `IdSucursal`=26;

ALTER Table cerro
ADD COLUMN idempleado int;

UPDATE cerro 
set idempleado = (`IdSucursal`*1000000 + `CodigoEmpleado`);

ALTER Table centro
ADD COLUMN idempleado int;

UPDATE centro 
set idempleado = (`IdSucursal`*1000000 + `CodigoEmpleado`);

SELECT * from venta
where `IdSucursal` in (27);



-- AGREGAMOS DATOS TABLA VENTA

UPDATE venta v
INNER JOIN quiroz q ON v.`idempleado` = q.idempleado
SET v.porcentaje = q.`Porcentaje`;

UPDATE venta v
INNER JOIN centro c ON v.`idempleado` = c.idempleado
SET v.porcentaje = c.`Porcentaje`;

UPDATE venta v
INNER JOIN cerro ce ON v.`idempleado` = ce.idempleado
SET v.porcentaje = ce.`Porcentaje`;




-- EN ESTE CODIGO HABIAN CALCULADO LA GANANCIA

WITH ventas AS (
    SELECT
        SUM(v.Precio * v.Cantidad)
        as ventas_neto,
        v.IdSucursal as id
    FROM venta as v
    WHERE
        YEAR(v.fecha) = 2020
    GROUP BY
        2
),
gastos as (
    SELECT
        SUM(g.Monto) as gastos_2019,
        g.IdSucursal as id
    FROM gasto g
    WHERE
        YEAR(g.Fecha) = 2020
    GROUP BY 2
)
SELECT
    ventas_neto - gastos_2019 as ganancia,
    ventas.id
FROM ventas
    JOIN gastos ON (ventas.id = gastos.id)
    JOIN sucursal s ON (s.IdSucursal = ventas.id)
    JOIN localidad l ON (s.idlocalidad = l.IdLocalidad)
WHERE IdProvincia = 2
ORDER BY ganancia desc;

-- CALCULO CADA UNO POR SEPARADO ME DA SUCURSAL 25 (CBA CENTRO)

SELECT sum(porcentaje) FROM venta
where `IdSucursal`=25; -- 9539

SELECT sum(porcentaje) FROM venta
where `IdSucursal`=26; --11680

SELECT sum(porcentaje) FROM venta
where `IdSucursal`=27; --7245

SELECT 1096302.620 - 9539; -- 1086763.620
SELECT 992876.590 - 11680; -- 981196.590

SELECT 703928.640 - 7245; -- 696683.640
