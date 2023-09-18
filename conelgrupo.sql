-- Active: 1693875076557@@127.0.0.1@3306@test_checkpoint_m3

/* SOLUCION DEL CHECKEPOINT */

/* 1) Un índice SQL mejora la eficiencia y rapidéz en la búsqueda de información. */

----??? 


/* ### 2) En la detección de Outliers, el método del Rango Intercuartil se basa en la utilización de la mediana.<br> */
    
    -- verdadero

### 3) Las tablas Maestros registran las operaciones ocurridas, todo tipo de transacciones donde intervienen las diferentes entidades del modelo.<br>

    ---??

/* ### 4) ¿Cuál de las siguientes es una tabla de hecho?
1. canal_venta<br>
2. calendario<br>
3. tipo_producto
4. venta<br> <---- Esta es
 */




 ### 5) El DER mostrado en la imagen:
/* 1. Es un Modelo Estrella, porque tiene una única tabla de hechos.<---- esta es
2. Es un Modelo Copo de Nieve, porque de la tabla venta se desprenden el resto de tablas.<br>
3. Niguna de las anteriores.<br> */





### 6) La ganancia neta por sucursal es las ventas menos los gastos (Ganancia = Venta - Gasto) ¿Cuál es la sucursal con mayor ganancia neta en 2019?

/* FOMRA 1 */

/* florez , con ganancia neta 1194532.070 */

WITH ventas as (
        SELECT
            SUM(v.Precio * v.Cantidad) as ventas_2019,
            v.`IdSucursal` as id
        FROM venta as v
        WHERE
            YEAR(v.fecha) = 2019
        GROUP BY
            2
    ),
    gastos as (
        SELECT
            SUM(g.Monto) as gastos_2019,
            g.`IdSucursal` as id
        FROM gasto g
        WHERE
            YEAR(g.Fecha) = 2019
        GROUP BY 2
    )
SELECT
    ventas_2019 - gastos_2019 as ganancia,
    ventas.id
FROM ventas
    JOIN gastos ON (ventas.id = gastos.id)
ORDER BY ganancia desc;

/* FORMA 2 */

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
            year(fecha) = 2019
        group by
            idsucursal
    ) as cg on cg.idsucursal = v.idsucursal
where year(v.fecha) = 2019
group by 1
order by 4 desc;

/* nombre de la sucursal*/

select * from sucursal where idsucursal=7;

#############################################################################################
### 7) La ganancia neta por producto es las ventas menos las compras (Ganancia = Venta - Compra) ¿Cuál es el tipo de producto con mayor ganancia neta en 2019?
/* FORMA 1 */
-- Informatica  1863220

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
                    year(Fecha) = 2019
                group by
                    Producto
            ) as sub1 on sub1.Producto = pro.IdProducto
        where
            year(ve.Fecha) = 2019
        group by
            IdProducto
    ) as sub2 on sub2.IdTipoProducto = tpro.IdTipoProducto
group by TIPO
order by FINAL desc;

/* FORMA 2   */

WITH ventas AS (
        SELECT
            v.idProducto,
            sum(v.Precio * v.Cantidad) AS ventas_2019
        FROM venta AS v
        WHERE
            YEAR(v.fecha) = 2019
        GROUP BY
            1
    ),
    compras AS (
        SELECT
            c.IdProducto,
            SUM(c.Precio * c.Cantidad) AS valor_compra
        FROM compra c
        WHERE
            YEAR(c.Fecha) = 2019
        GROUP BY
            1
    ),
    productos AS (
        SELECT
            p.idProducto,
            p.Producto,
            p.idTipoProducto
        FROM producto AS p
    )
SELECT
    sum(
        ventas.ventas_2019 - compras.valor_compra
    ) as ganancia,
    productos.idTipoProducto as id_tipo_producto
FROM productos
    JOIN compras ON productos.idProducto = compras.IdProducto
    JOIN ventas ON productos.idProducto = ventas.idProducto
GROUP BY 2
ORDER BY 1 DESC;

############################################################################################

/* ### 8) Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo en al menos dos sucursales? (expresado en porcentaje y con dos decimales, por ejemplo 11.11) */

/* clientes que realizacon compras 2019 */

/* 602/1674 = 0.3596 = 0.36 */

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
            cant_sucursales >= 2
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

-- 9) Del total de clientes que realizaron compras en 2020 ¿Qué porcentaje no había realizado compras en 2019?

-- expresado en porcentaje y con dos decimales, por ejemplo 11.11

-- Resultado 40.79 (985 /2415)

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

## 10) Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo también en 2020? (expresado en porcentaje y con dos decimales, por ejemplo 11.11)

/* 0.8542  =  1430/1674 */

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


### 11) ¿Qué cantidad de clientes realizó compras sólo por el canal Presencial entre 2019 y 2020?

/* FORMA 1 */

SELECT COUNT(DISTINCT IdCliente) AS cantidad_clientes_presencial
FROM venta
WHERE IdCanal = 3
  and year(fecha) between 2019 
  AND 2020
  AND IdCliente NOT IN (
    SELECT DISTINCT IdCliente
    FROM venta
    WHERE idcanal in (1,2)
      AND Fecha >= '2019-01-01'
      AND Fecha <= '2020-12-31'
  );



/*12 ¿Cuál es la sucursal que más Venta (Precio * Cantidad) hizo en 2019 a clientes que viven fuera de su provincia?
Flores
Rosario1 <------ Esta es :)
Córdoba Centro*/
SELECT
  s.`IdSucursal`,
  SUM(v.`Precio` * v.`Cantidad`) AS TotalVenta
FROM venta v
    JOIN cliente c 
        ON v.`IdCliente` = c.`IdCliente`
    JOIN sucursal s 
        ON v.`IdSucursal` = s.`IdSucursal`
    JOIN localidad l_sucursal 
        ON s.`IdLocalidad` = l_sucursal.`IdLocalidad`
    JOIN localidad l_cliente 
        ON c.`IdLocalidad` = l_cliente.`IdLocalidad`
WHERE YEAR(v.`Fecha`) = 2019
  AND l_cliente.`IdProvincia` != l_sucursal.`IdProvincia`
GROUP BY s.`IdSucursal`
ORDER BY TotalVenta DESC
LIMIT 1;

### 13) ¿Cuál fué el mes del año 2020, de mayor decrecimiento (o menor crecimiento) con respecto al mismo mes del año 2019 si se toman en cuenta a nivel general Ventas (Precio * Cantidad) - Compras (Precio * Cantidad) - Gastos? 
#### Responder el Número del Mes:

/* Octubre  -1603900.690 */

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
    
/* ######################################################## */

### 15) ¿Cuál es el código de empleado del empleado que mayor comisión obtuvo en diciembre del año 2020?

/* Cargado de tablas */
SET GLOBAL local_infile = 'ON';

/*Carga centro */

DROP TABLE centro;

CREATE Table centro (CodigoEmpleado int,
                        IdSucursal INT,
                        Apellido_y_Nombre VARCHAR(100),
                        Sucursal VARCHAR(100),
                        Anio int,
                        Mes int,
                        Porcentaje int)
;

/* LOAD DATA LOCAL INFILE 
'/home/pc/Documentos/henry/SoyHenryDataScience/Modulo3/CP M3/Comisiones Córdoba Centro.csv'
INTO TABLE centro  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines; */
SELECT * FROM centro;

/* Carga Cerro */

CREATE Table cerro (CodigoEmpleado int,
                        IdSucursal INT,
                        Apellido_y_Nombre VARCHAR(100),
                        Sucursal VARCHAR(100),
                        Anio INT,
                        Mes int,
                        Porcentaje int)
;

/* LOAD DATA LOCAL INFILE 
'/home/pc/Documentos/henry/SoyHenryDataScience/Modulo3/CP M3/Comisiones Córdoba Cerro de las Rosas.csv'
INTO TABLE cerro  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines
; */
SELECT * FROM cerro;

/* Quiroz */

DROP TABLE quiroz;
CREATE Table quiroz (CodigoEmpleado int,
                        IdSucursal INT,
                        Apellido_y_Nombre VARCHAR(100),
                        Sucursal VARCHAR(100),
                        Anio INT,
                        Mes int,
                        Porcentaje int)
;

/* LOAD DATA LOCAL INFILE 
'/home/pc/Documentos/henry/SoyHenryDataScience/Modulo3/CP M3/Comisiones Córdoba Quiróz.csv'
INTO TABLE quiroz  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines
; */


########################################################


### 15) ¿Cuál es el código de empleado del empleado que mayor comisión obtuvo en diciembre del año 2020?
/* El codigo del empleado es 3929 */
-- 47734.94770

/* Agregamos id empleado */

ALTER TABLE quiroz 
ADD idEmpleado INT AFTER CodigoEmpleado ;

UPDATE quiroz SET `idEmpleado` = IdSucursal*1000000 + CodigoEmpleado;


ALTER TABLE centro 
ADD idEmpleado INT AFTER CodigoEmpleado ;

UPDATE centro SET `idEmpleado` = IdSucursal*1000000 + CodigoEmpleado;

ALTER TABLE cerro 
ADD idEmpleado INT AFTER CodigoEmpleado ;

UPDATE cerro SET `idEmpleado` = IdSucursal*1000000 + CodigoEmpleado;

###############################################################################
/* FORMA 1 :)*/
WITH 
    todo as
        (SELECT * FROM quiroz
        UNION
        SELECT * FROM centro
        UNION
        SELECT * FROM cerro)
SELECT v.`IdEmpleado` , sum(v.Precio*v.Cantidad*t.Porcentaje/100) as comision 
FROM todo t
LEFT JOIN venta v ON (v.`idEmpleado`=t.`idEmpleado`)
WHERE t.Anio = 2020 and t.mes = 12 AND
YEAR(v.`Fecha`) = 2020 and MONTH(v.`Fecha`) = 12 
GROUP BY v.`idEmpleado`
ORDER BY comision DESC;




/* FORMA 2 */
WITH 
    todo as
        (SELECT * FROM quiroz 
        WHERE Anio = 2020 and mes = 12 
        UNION
        SELECT * FROM centro
        WHERE Anio = 2020 and mes = 12 
        UNION
        SELECT * FROM cerro
        WHERE Anio = 2020 and mes = 12 )
SELECT v.`IdEmpleado` , sum(v.Precio*v.Cantidad*t.porcentaje/100) as comision 
FROM todo t
LEFT JOIN venta v ON (v.`idEmpleado`=t.`idEmpleado`)
    WHERE YEAR(v.`Fecha`) = 2020 and MONTH(v.`Fecha`) = 12 
GROUP BY v.`idEmpleado`
ORDER BY comision DESC;


/* Verificacion: el cliente 3929 tiene una comision de 17% en dic 2020. */
SELECT sum(Precio*Cantidad*17/100) FROM venta
WHERE `IdEmpleado` = 27003929
AND YEAR(FECHA) =2020 AND MONTH(Fecha) =12
GROUP BY `IdEmpleado`;



-- 16) ¿Cuál es la sucursal que más comisión pagó en el año 2020?
/*Córdoba Centro. <-- Esta es :)
Córdoba Quiroz.
Cerro De Las Rosas.*/ 

WITH 
    todo as
        (SELECT * FROM quiroz
        UNION
        SELECT * FROM centro
        UNION
        SELECT * FROM cerro)
SELECT v.`idSucursal` , sum(v.Precio*v.Cantidad*t.Porcentaje/100) as comision 
FROM todo t
LEFT JOIN venta v ON (v.`idEmpleado`=t.`idEmpleado`)
WHERE t.Anio = 2020 AND
YEAR(v.`Fecha`) = 2020
GROUP BY v.`idSucursal`
ORDER BY comision DESC;


SELECT * FROM sucursal
WHERE `IdSucursal` = 25;

    

