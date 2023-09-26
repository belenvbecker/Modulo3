-- Active: 1693875076557@@127.0.0.1@3306@test_checkpoint_m3


-- 1) La asignación de índices para las tablas en SQL no genera nunguna mejora en la performance
--  de los queries. -- FALSO

-- 2) Las tablas de hechos registran las operaciones ocurridas, todo tipo de transacciones donde 
-- intervienen las diferentes entidades del modelo. --  FALSO. No registran todas las transacciones 
-- u operaciones en una organización, sino solo aquellas que son relevantes.

-- 3) La regla de las 3 sigmas para detección de Outliers está basada en la Mediana. -- FALSO. se basa 
-- en la media y la desviación estándar de los datos.

-- 4) Los valores outliers se deben en todos los casos a cargas erróneas de los datos. FALSO. Son valores raros
-- eso no significan que sean cargas erróneas.

-- 5) Dada la siguiente consulta SQL: SELECT Fecha, Count(*) FROM venta GROUP BY Fecha; Si se pretende filtrar 
-- las fechas que contienen más de 10 ventas, es necesario usar la sentencia WHERE. FALSO. Se usa Having.

-- 6) ¿Cuál de las siguientes no es una tabla que representa una dimensión?
-- Opciones:
-- 1- cliente
-- 2- calendario
-- 3- venta -- ESTA
-- 4- provincia

-- 7) El negocio suele requerir con gran frecuencia consultas a nivel trimestral tanto sobre las ventas, 
-- como las compras y los gastos. Teniendo en cuenta el anterior DER, ¿qué sería lo más óptimo a la hora 
-- de generar las consultas frecuentes?
-- Opciones:
-- 1- No necesitamos crear más indices, con las claves primarias y foráneas, sería suficiente para cubrir 
-- cualquier necesidad de consulta.
-- 2- Sería aduecuado colocar un índice sobre el campo trimestre de la tabla calendario aunque este no 
-- sea una clave foránea. -- ESTA
-- 3- No se puede crear índices sobre campos que no son clave.

-- 8) ¿El DER presentado en la imagen anterior que tipo de modelo sigue?
-- Opciones:
-- 1- Es un Modelo Estrella, porque tiene una sóla tabla de hechos.
-- 2- Eo tiene ningún modelo estipulado, ya que no es un Modelo Estrella, porque contiene referencias 
-- circulares.
-- 3- Es un Modelo Copo de Nieve. -- ESTA

-- En tu motor de base de datos MySQL, ejecutá las instrucciones del script 'Checkpoint_Create_Insert.sql' 
-- (Si no trabajas con MySQL es posible que tengas que realizar algunos ajustes en el script. 
-- También están provistas las tablas en formato csv dentro de la carpeta 'tablas_cp').

-- 9) La ganancia neta por producto es las ventas menos las compras (Ganancia = Venta - Compra) ¿Cuál es el tipo de producto con mayor ganancia neta en 2020?
-- Opciones:
-- 1- Informática -- ESTA (Ganacia= $2.475.025)
-- 2- Impresión
-- 3- Grabacion

select
    TipoProducto as TIPO,
    sum(Todo) as FINAL
from tipo_producto as tpro
    join (
        select
            ve.IdProducto,
            pro.Producto,
            round(sum(ve.Precio * ve.Cantidad)) as Venta,
            round(Compra),
            round(
                sum(ve.Precio * ve.Cantidad) - Compra
            ) as Todo,
            IdTipoProducto
        from venta as ve
            join producto as pro on ve.IdProducto = pro.IdProducto
            join (
                select
                    IdProducto as Producto,
                    sum(Precio * Cantidad) as Compra
                from compra
                where
                    year(Fecha) = 2020
                group by
                    Producto
            ) as sub1 on sub1.Producto = pro.IdProducto
        where
            year(ve.Fecha) = 2020
        group by
            IdProducto
    ) as sub2 on sub2.IdTipoProducto = tpro.IdTipoProducto
group by TIPO
order by FINAL desc;


-- 10) A partir de los datos de las Ventas, Compras y Gastos de los años 2020 y 2019, si comparamos mes a mes 
-- (ejemplo: junio 2020-junio 2019), ¿Cuál fue el mes cuya diferencia entre ingresos y egresos es mayor? 
-- [Ventas (Precio * Cantidad) - Compras (Precio * Cantidad) – Gastos]. Respuesta_Ejemplo: 2 (Refiriendose al 
-- segundo mes del año, Febrero. OJO, sólo coloca el número de mes, no el nombre del mes).

-- CRECIMIENTO ABRIL
-- DECRECIMIENTO OCTUBRE
WITH  ganancia2020 AS
        (SELECT mv,
        v.sv-sc-sg as ganancia2020
        from ((SELECT MONTH(`Fecha`) as mv,
        sum(`Precio`*`Cantidad`) as sv
        from venta
        where YEAR(fecha)=2020
        GROUP BY 1
        ORDER BY 1)) as v
        join ((SELECT MONTH(`Fecha`) as mc,
        sum(`Precio`*`Cantidad`) as sc
        from compra
        where YEAR(fecha)=2020
        GROUP BY 1
        ORDER BY 1)) as c on v.mv = c.mc
        join ((SELECT MONTH(`Fecha`) as mg, sum(monto) as sg
        from gasto
        where YEAR(fecha)=2020
        GROUP BY 1
        ORDER BY 1)) as g on v.mv = g.mg
        order by 2 asc ),
    ganancia2019 AS
        (SELECT mv,
        v.sv-sc-sg as ganancia2019
        from ((SELECT MONTH(`Fecha`) as mv,
        sum(`Precio`*`Cantidad`) as sv
        from venta
        where YEAR(fecha)=2019
        GROUP BY 1
        ORDER BY 1)) as v
        join ((SELECT MONTH(`Fecha`) as mc,
        sum(`Precio`*`Cantidad`) as sc
        from compra
        where YEAR(fecha)=2019
        GROUP BY 1
        ORDER BY 1)) as c on v.mv = c.mc
        join ((SELECT MONTH(`Fecha`) as mg, sum(monto) as sg
        from gasto
        where YEAR(fecha)=2019
        GROUP BY 1
        ORDER BY 1)) as g on v.mv = g.mg
        order by 2 asc)
        SELECT  g20.mv, 
                ganancia2020-ganancia2019 as diferencia
        FROM ganancia2020 as g20
        join ganancia2019 as g19 on g20.mv = g19.mv
        ORDER BY 2 ASC;


-- 11) Del total de clientes que realizaron compras en 2020, ¿Qué porcentaje no había realizado compras en 2019?
-- Opciones:
-- 1-0.45
-- 2-0.38
-- 3-0.41 -- ESTA
-- 4-0.51

WITH clientes2020 as (
        select
            idCliente as Cliente2020
        from venta
        where
            year(Fecha) = 2020
            and idcliente not in (
                select
                    idCliente as Cliente2019
                from venta
                where
                    year(Fecha) = 2019
                group by
                    idCliente
            )
        group by
            idCliente
    ),
    clientes_totales as (
        select
            idCliente as totales
        from venta
        where
            year(Fecha) = 2020
        group by idCliente
    )
select
    count(clientes2020.Cliente2020) / count(clientes_totales.totales) as porcentaje
from clientes2020
    RIGHT JOIN clientes_totales ON (
        clientes_totales.totales = clientes2020.Cliente2020
    );

-- 12) Del total de clientes que realizaron compras en 2019, ¿Qué porcentaje lo hizo también en 2020?
-- Opciones:
-- 1-0.88
-- 2-0.90
-- 3-0.82
-- 4-0.85 -- ESTA

WITH clientes2019 as (
        select
            idCliente as Cliente2019
        from venta
        where
            year(Fecha) = 2019
            and idcliente in (
                select
                    idCliente as Cliente2020
                from venta
                where
                    year(Fecha) = 2020
                group by
                    idCliente
            )
        group by
            idCliente
    ),
    clientes_totales as (
        select
            idCliente as totales
        from venta
        where
            year(Fecha) = 2019
        group by idCliente
    )
select
    count(clientes2019.Cliente2019) / count(clientes_totales.totales) as porcentaje
from clientes2019
    RIGHT JOIN clientes_totales ON (
        clientes_totales.totales = clientes2019.Cliente2019
    );


-- 13) ¿Qué cantidad de clientes realizó compras sólo por el canal presencial entre 2019 y 2020?
-- Respuesta: 33.00 (NOMINAL)

SELECT COUNT(DISTINCT IdCliente) AS cantidad_clientes_presencial
FROM venta
WHERE IdCanal = 2
  and year(fecha) between 2019 
  AND 2020
  AND IdCliente NOT IN (
    SELECT DISTINCT IdCliente
    FROM venta
    WHERE idcanal in (1,3)
      AND Fecha >= '2019-01-01'
      AND Fecha <= '2020-12-31'
  );


-- 14) El sector de Marketing desea saber cuál sucursal tiene la mayor ganancia neta en el 2020,
-- (Ganancia = suma_total(Venta - Gasto) ¿Cuál es la sucursal con mayor ganancia neta en 2020?.
-- Respuesta: Flores (IDSucursal 7)

select
    v.idsucursal,
    sum(v.precio * v.cantidad) as ventas,
    cg.gs as gastos,
    sum(v.precio * v.cantidad) - cg.gs as ganacias
from venta v
    join (
        select
            idsucursal,
            sum(monto) as gs
        from gasto
        where
            year(fecha) = 2020
        group by
            idsucursal
    ) as cg on cg.idsucursal = v.idsucursal
where year(v.fecha) = 2020
group by 1
order by 4 desc;

Select * from sucursal where idsucursal=7;


-- 15) Del total de clientes que realizaron compras en 2019, ¿Qué porcentaje lo hizo sólo en una única sucursal?
-- Opciones:
-- 1-0.45
-- 2-0.64 -- ESTA
-- 3-0.41
-- 4-0.51

WITH clientes2 as (
        SELECT
            v.`IdCliente`,
            COUNT(DISTINCT s.`IdSucursal`) as cant_sucursales
        FROM cliente c
            JOIN venta v ON (v.`IdCliente` = c.`IdCliente`)
            JOIN sucursal s ON (
                s.`IdSucursal` = v.`IdSucursal`
            )
        WHERE
            YEAR(v.`Fecha`) = 2019
        GROUP BY 1
        HAVING
            cant_sucursales = 1
    ),
    total as (
        SELECT
            COUNT(DISTINCT v.idCliente) as t
        FROM cliente c
            JOIN venta v ON (v.`IdCliente` = c.`IdCliente`)
        WHERE
            YEAR(v.`Fecha`) = 2019
    )
SELECT
    count(`IdCliente`) / t porcentaje
FROM clientes2
    JOIN total
GROUP BY t;

-- Pablo es un estudiante de la carrera de Data Science en Henry, por lo que le interesa saber un poco más 
-- sobre las remuneraciones del área. Para esto, cuenta con un script de carga SQL llamado 
-- "Checkpoint_Create_Insert_salaries_SE.sql" donde posee sólo datos para "experiencia=SE' pero además, un 
-- csv llamado "ds_salaries_SIN_SE.csv" donde contiene el resto de los registros con otros valores para el 
-- campo "experiencia", con lo que decide hacer un ETL, ejecutando el primer script para crear la tabla y 
-- cargar los datos, pero adicionando los datos del CSV. (Si no trabajas con MySQL es posible que tengas que 
-- realizar algunos ajustes en el script. También están provistas las tablas en formato csv dentro de la 
-- carpeta 'tablas_cp').


-- 16) ¿ Cuántos países NO tienen información sobre los salarios de sus Data Scientists?
-- 225
SELECT DISTINCT count(`idPais`) FROM paises
WHERE idPais not in (SELECT idResidencia from data_salario
    WHERE tituloempleo = 'Data Scientist')
ORDER BY 1;

-- FORMA 2
SELECT 
*
from paises
WHERE `idPais` not in (SELECT 
                        `idResidencia`
                        from data_salario
                        where `tituloempleo` = 'Data Scientist'
                        GROUP BY `idResidencia`);

-- 17) ¿Cuál es el promedio de salarios en usd de los Data Scientist de la muestra en 2020?
SELECT AVG(salarioUsd) AS promedio_salario
FROM data_salario
WHERE año = 2020 and TituloEmpleo='Data Scientist';

-- Respuesta 85970.52

-- 18) Si consideramos el tipo de cambio como el salario en moneda local dividido el salario en USD, 
-- ¿cuál es el mayor valor de esta variable en la muestra ?

SELECT MAX(salario/salarioUsd) AS mayor_valor
FROM data_salario;

-- Respuesta 759.27

