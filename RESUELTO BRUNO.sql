-- Active: 1693875076557@@127.0.0.1@3306@test_checkpoint_m3

/* 1  Del total de clientes que realizaron compras en 2020 ¿Qué porcentaje no había realizado compras en 2019? 
(Responder con valores entre 0 y 1, redondeado a 2 decimales) */

#985/2415 = 0.41#
WITH 
clientes2019 AS (
    SELECT DISTINCT IdCliente
    FROM venta
    WHERE YEAR(fecha) = 2019
),
clientes2020 AS (
    SELECT DISTINCT IdCliente
    FROM venta
    WHERE YEAR(fecha) = 2020
)
SELECT count(c20.IdCliente)/ (select count(`IdCliente`) FROM clientes2020)
FROM clientes2020 c20
WHERE c20.IdCliente NOT IN (
    SELECT IdCliente
    FROM clientes2019);

/* Del total de clientes que realizaron compras en 2020 ¿Qué porcentaje lo hizo sólo en una única sucursal? 
Responder con valores entre 0 y 1, redondeado a 2 decimales) */

-- 0.34

/* FORMA 1 */

WITH clientes2020 as
        (SELECT DISTINCT IdCliente
        FROM venta
        WHERE YEAR(fecha) = 2020),
    unasucursal as
        (SELECT DISTINCT v.IdCliente, count(DISTINCT IdSucursal) as numsucursal
        FROM venta v
        WHERE YEAR(fecha) = 2020
        GROUP BY v.IdCliente
        HAVING numsucursal = 1
        ORDER BY 1)
        SELECT (select count(`IdCliente`) from unasucursal)/(count(idcliente)) 
        FROM  clientes2020 c20 ;

/* FORMA 2 PARA VERIFICAR (COCIENTE DE LOS 2 SELECT) */ 
/* 814/2415 */

SELECT IdCliente, COUNT(IdSucursal) conteo
FROM (
	SELECT DISTINCT IdCliente, IdSucursal, COUNT(IdSucursal) OVER (PARTITION BY IdCliente) 
	FROM (
		SELECT *
		FROM venta
		WHERE year(Fecha) = 2020
	) ventas
) tabla
GROUP BY IdCliente
HAVING conteo = 1;

SELECT year(Fecha), IdCliente, COUNT(DISTINCT IdSucursal) distintas
FROM venta
WHERE year(Fecha) = 2020
GROUP BY IdCliente, year(Fecha)
HAVING distintas = 1;

/* FORMA 3 */
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
            YEAR(v.`Fecha`) = 2020
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
            YEAR(v.`Fecha`) = 2020
    )
SELECT
    count(`IdCliente`) / t porcentaje
FROM clientes2
    JOIN total
GROUP BY t;


/* Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo también en 2020? 
(Responder con valores entre 0 y 1, redondeado a 2 decimales) */

/* R)  0.85 */

/* FORMA 1 */
WITH 
clientes2020 AS (
    SELECT DISTINCT IdCliente
    FROM venta
    WHERE YEAR(fecha) = 2020
),
clientes2019 AS (
    SELECT DISTINCT IdCliente
    FROM venta
    WHERE YEAR(fecha) = 2019
)
SELECT count(c19.IdCliente)/ (select count(`IdCliente`) FROM clientes2019)
FROM clientes2019 c19
WHERE c19.IdCliente IN (
    SELECT IdCliente
    FROM clientes2020);


/* FORMA 2 */

SELECT count(DISTINCT IdCliente) / (SELECT count(distinct IdCliente) FROM venta WHERE year(Fecha) = 2019)
FROM (
	SELECT IdCliente, IdVenta, IdSucursal, year(Fecha)
	FROM venta
	WHERE year(Fecha) = 2019
) ANIO2019
JOIN (
	SELECT IdCliente, IdVenta, IdSucursal, year(Fecha)
	FROM venta
	WHERE year(Fecha) = 2020
) AS ANIO202020
USING (IdCliente);

/* ¿Cuál es la sucursal con mayor venta (venta = Precio * Cantidad)? */

/* FLORES ID SUCURSAL 7*/

SELECT SUM(v.precio * v.cantidad),`IdSucursal` FROM venta v
GROUP BY 2 
ORDER BY 1 DESC
LIMIT 1;

SELECT * FROM sucursal
    WHERE `IdSucursal` = 7;


/* Solucion es flores */
WITH mayorventa as
    (
    SELECT SUM(v.precio * v.cantidad),`IdSucursal` FROM venta v
    GROUP BY 2 
    ORDER BY 1 DESC
    LIMIT 1)
    SELECT `sucursal` FROM sucursal
    WHERE `IdSucursal` = (SELECT`IdSucursal` from mayorventa);

 /* La ganancia neta por tipo de producto es las ventas menos las compras, se desea saber cuál tipo de 
producto tiene la mayor ganancia neta en el 2020 (Ganancia = Venta - Compra) */ 

/* Informatica IDTIPOPRODUCTO 8  */
WITH 
    ventasxproducto as (
        SELECT IdProducto , SUM(v.Precio*v.Cantidad) as vp from venta v
        WHERE YEAR(fecha) = 2020
        GROUP BY v.IdProducto),
    comprasxproducto as (
        SELECT IdProducto,SUM(c.precio*c.cantidad) as cp from compra c
        WHERE YEAR(fecha) = 2020
        GROUP BY c.IdProducto) 
    SELECT `IdTipoProducto`, sum(vp - cp) as ganancia, sum(vp)
    FROM producto 
        JOIN ventasxproducto USING(`IdProducto`)
        JOIN comprasxproducto USING(`IdProducto`)
    GROUP BY IdTipoProducto
    ORDER BY ganancia DESC;


/* /* La compañia desea saber el ingreso total de dinero mes a mes, teniendo en cuenta las ventas,las compras que 
se hacen en la compañia y los gastos adicionales es decir: [ingreso = ventas(precio*Cantidad) -compras(Precio*cantidad) - gastos]. 
Desean comparar dicho ingreso mes a mes entre 2020 y 2019 (ejemplo: ingreso_junio2020 - ingreso_junio2019), 

¿Cuál es el mes de 2020 que tuvo mayor crecimiento con respecto al de 2019? */

/* R 10 octubre y -1603900.690 mayor decrecimieto

   R 4 abrir  y 1744266.320 mayor crecimiento
 */ 

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



/* Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo sólo en una única sucursal? 
(Responder con valores entre 0 y 1, redondeado a 2 decimales) */

/*R) 0.64 */

WITH clientes2019 as
        (SELECT DISTINCT IdCliente
        FROM venta
        WHERE YEAR(fecha) = 2019),
    unasucursal as
        (SELECT DISTINCT v.IdCliente, count(DISTINCT IdSucursal) as numsucursal
        FROM venta v
        WHERE YEAR(fecha) = 2019
        GROUP BY v.IdCliente
        HAVING numsucursal = 1
        ORDER BY 1)
        SELECT (select count(`IdCliente`) from unasucursal)/(count(idcliente)) 
        FROM  clientes2019 c19 ;


/* La ganancia neta por sucursal es las ventas menos los gastos, el sector de Marketing desea saber cuál sucursal 
tiene la mayor ganancia neta en el 2020 (Ganancia = Venta - Gasto) */

/* mayor ganancia es flores con id 7 */

WITH 
    ventas as
        (select IdSucursal, sum(v.precio*v.cantidad) as venta from venta v
            where year(v.fecha) = 2020
            GROUP BY 1),
    gastos as
        (select IdSucursal, sum(g.monto) gasto from gasto g
            where year(g.fecha) = 2020
            GROUP BY 1)
        SELECT `IdSucursal`, SUM(venta-gasto) as ganancia FROM ventas
        JOIN gastos USING(`IdSucursal`)
        GROUP BY `IdSucursal`
        ORDER BY ganancia DESC;

SELECT * FROM sucursal
WHERE `IdSucursal` = 7;


/* ¿Cuántos outliers existen en la variable monto de la venta (Cantidad * Precio) de la tabla venta? Utilizando 
el método Tres Sigmas aplicado por Producto */

/* R) 51 */


WITH outlaier as
(SELECT IdProducto,
        avg(v.Precio*v.Cantidad) as promedio,
        std(v.Precio*v.Cantidad) as std,
        avg(v.Precio*v.Cantidad) + 3*std(v.Precio*v.Cantidad) as maximo,
        avg(v.Precio*v.Cantidad) - 3*std(v.Precio*v.Cantidad) as minimo
FROM venta v
    GROUP BY `IdProducto`)
SELECT count(*) as cantidad_outlaier FROM outlaier o
JOIN producto p USING (`IdProducto`)
JOIN venta v USING (`IdProducto`)
WHERE (v.precio*v.cantidad > o.maximo OR v.precio*v.cantidad < minimo )  ;



/* Carga de nuevos archivos */
DROP TABLE empleos;
CREATE TABLE empleos (
    idDato INT AUTO_INCREMENT PRIMARY KEY,
    año INT,
    experiencia INT,
    tipo_empleo VARCHAR(255),
    titulo_empleo VARCHAR(255),
    salario DECIMAL(10, 2),
    moneda VARCHAR(10),
    salario_USD DECIMAL(10, 2),
    idResidencia INT,
    porcentaje_remoto DECIMAL(5, 2),
    tamaño_compañía VARCHAR(50)
);

SET GLOBAL local_infile = 'ON';

LOAD DATA LOCAL INFILE 
'C:\\Users\\Marcos\\OneDrive\\Escritorio\\HENRY--Checkpoint-M3---DATAPT01-main\\ds_salaries_SIN_SE.csv'
INTO TABLE data_salario  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines
;

select * from data_salario;

/* Cargar paises */
DROP TABLE paises;
CREATE TABLE paises (
    Codigo CHAR(2) PRIMARY KEY,
    idPais INT,
    Nombre VARCHAR(255) NOT NULL
);

LOAD DATA LOCAL INFILE 
'C:\\Users\\Marcos\\OneDrive\\Escritorio\\HENRY--Checkpoint-M3---DATAPT01-main\\countries.txt'
INTO TABLE paises  
FIELDS TERMINATED BY '\t'
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines
; 

SELECT * from paises;



/*¿ Cuántos países NO tienen información sobre los salarios de sus Data Scientists? */

    -- R/: 225 PAISES

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


/* Teniendo en cuenta la tabla countries.txt, ¿Cuántos países NO tienen información sobre los salarios? 
(Ingresar solo el número. Ej: 22) */

    /* R) 199 */

SELECT DISTINCT count(`idPais`) FROM paises
WHERE idPais not in (SELECT idResidencia from data_salario)
ORDER BY 1;

-- FORMA 2
select (select count(*) from paises) - (SELECT count(DISTINCT idResidencia) FROM data_salario);

/* ¿Qué país pagó el salario en dolares (SalarioUSD) más alto en 2022 para tamaños de compañia (L)? TIp: usar like para 
la busqueda de el tamaño de compañia. */

    /* United States con id 236 */

/* Forma 1 */
select max(salarioUSD), `idResidencia` FROM data_salario
WHERE TamanoCompania LIKE '%L%' AND año = 2022
GROUP BY 2
ORDER BY 1 DESC;

/* Forma 2 */
select * from data_salario
WHERE TamanoCompania LIKE '%L%' AND año = 2022
ORDER BY salarioUSD DESC;

/* Forma 3 */

SELECT *
FROM data_salario e 
JOIN paises p ON ( e.`idResidencia` = p.`idPais`)
WHERE Año = 2022 AND TamanoCompania like '%L%' AND salarioUSD = (SELECT max(salarioUSD) FROM data_salario 
																WHERE Año = 2022 AND TamanoCompania like '%L%' )





