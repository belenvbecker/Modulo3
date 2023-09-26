USE `henry_checkpoint_m3`;


SELECT @@local_infile;

SET GLOBAL local_infile=1;
SET SQL_SAFE_UPDATES=0;
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

#6) La ganancia neta por sucursal es las ventas menos los gastos (Ganancia = Venta - Gasto) ¿Cuál es la sucursal con mayor ganancia neta en 2019? 
#alberdi

SELECT v.fecha, s.idsucursal, s.sucursal, SUM(v.precio * v.cantidad) - SUM(g.Monto)
FROM sucursal s
JOIN venta v ON (s.idsucursal = v.idSucursal)
JOIN gasto g ON (s.idSucursal = g.idsucursal)
WHERE YEAR(v.fecha) = 2019
GROUP BY (s.idSucursal)
ORDER BY 4 DESC;

#7) La ganancia neta por producto es las ventas menos las compras (Ganancia = Venta - Compra) ¿Cuál es el tipo de producto con mayor ganancia neta en 2019?
#informatica
SELECT tp.TipoProducto, (SUM(v.Precio*v.Cantidad) - SUM(c.Precio*v.Cantidad)) as ganancia
FROM producto p
JOIN venta v ON (p.IdProducto=v.IdProducto)
JOIN compra c ON (p.IdProducto= c.IdProducto)
JOIN tipo_producto tp ON (p.IdTipoProducto = tp.IdTipoProducto)
WHERE YEAR(v.Fecha)=2019
GROUP BY p.IdTipoProducto
ORDER BY 2 DESC;

#8) Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo en al menos dos sucursales? 
#(expresado en porcentaje y con dos decimales, por ejemplo 11.11) 

SELECT (COUNT(varSucursales.total) / (SELECT COUNT(DISTINCT idCliente) as total FROM venta WHERE YEAR(fecha) = 2019))*100
FROM (
	SELECT v.idCliente, COUNT(DISTINCT v.idSucursal) as total
	FROM venta v
    WHERE (YEAR(v.fecha) = 2019)
	GROUP BY (v.idCliente)
	HAVING (COUNT(DISTINCT v.idSucursal)>1)
) varSucursales;
#602/1674
#35.9618%

SELECT v.idCliente, COUNT(DISTINCT v.idSucursal) as total
	FROM venta v
    WHERE (YEAR(v.fecha) = 2019)
	GROUP BY (v.idCliente)
	HAVING (COUNT(DISTINCT v.idSucursal)>1);
#602

SELECT COUNT(DISTINCT idCliente) as total FROM venta WHERE YEAR(fecha) = 2019;
#1674


#9) Del total de clientes que realizaron compras en 2020 ¿Qué porcentaje no había realizado compras en 2019? 
#(expresado en porcentaje y con dos decimales, por ejemplo 11.11)

SELECT (COUNT(venta2020.cliente2020) / (SELECT count(distinct idcliente) as total FROM venta WHERE year(fecha)=2020)) *100
FROM (
	SELECT DISTINCT idcliente as cliente2020
    FROM venta WHERE Year(Fecha) = 2020
) venta2020
LEFT JOIN(
	SELECT DISTINCT idcliente as cliente2019
    FROM venta WHERE YEAR(Fecha)=2019
) venta2019
on venta2020.cliente2020= venta2019.cliente2019 
WHERE venta2019.cliente2019 is NULL;
#40.7867

#10) Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo también en 2020? 
#(expresado en porcentaje y con dos decimales, por ejemplo 11.11) 

SELECT (COUNT(venta2019.cliente2019) / (SELECT count(distinct idcliente) as total FROM venta WHERE year(fecha)=2019)) *100
FROM (
	SELECT DISTINCT idcliente as cliente2019
    FROM venta WHERE Year(Fecha) = 2019
) venta2019
INNER JOIN(
	SELECT DISTINCT idcliente as cliente2020
    FROM venta WHERE YEAR(Fecha)=2020
) venta2020
on venta2019.cliente2019 = venta2020.cliente2020;
#85.4241

#11) ¿Qué cantidad de clientes realizó compras sólo por el canal Presencial entre 2019 y 2020? 

SELECT filtro.IdCanal, count(*)
FROM ( 
	SELECT idCliente , idCanal, count(*) as cant_canales
	FROM (
		SELECT DISTINCT idCliente, idCanal
        FROM venta
		WHERE YEAR(fecha) in (2019,2020)
		ORDER BY idCliente) canal
	GROUP BY canal.idCliente
    HAVING (cant_canales = 1 and canal.idCanal=3)
)filtro ;
#33

SELECT DISTINCT idCliente, idCanal
FROM venta
WHERE YEAR(fecha) in (2019,2020)
ORDER BY idCliente;

#ema
SELECT IdCliente, IdCanal
FROM (
    SELECT DISTINCT v.IdCliente, cv.IdCanal
    FROM venta v
    JOIN canal_venta cv ON (v.IdCanal = cv.IdCanal AND YEAR(Fecha) IN (2019,2020))) clientes
GROUP BY IdCliente
HAVING IdCanal = 3 AND count(*) = 1;
#33



#12) ¿Cuál es la sucursal que más Venta (Precio * Cantidad) hizo en 2019 a clientes que viven fuera de su provincia?

SELECT SUM(v.Precio*v.Cantidad) as ventas, v.IdSucursal, s.sucursal
FROM venta v
JOIN sucursal s ON (v.IdSucursal=s.IdSucursal)
JOIN localidad l ON (s.IdLocalidad=l.IdLocalidad)
JOIN cliente c ON (c.idcliente=v.idcliente)
JOIN localidad l2 ON (c.idLocalidad=l2.idlocalidad)
WHERE Year(fecha)=2019 and l.Idprovincia != l2.IdProvincia
group by v.IdSucursal
order by ventas desc;
#Rosario1

#13) ¿Cuál fué el mes del año 2020, de mayor decrecimiento (o menor crecimiento) con respecto al mismo mes del año 2019 si se toman en cuenta 
#a nivel general Ventas (Precio * Cantidad) - Compras (Precio * Cantidad) - Gastos?	
/*REVISAR!!!

SELECT o.fecha, SUM(o.monto) as monto
FROM (
		SELECT MONTH(Fecha) as fecha, SUM(precio*cantidad) as monto
		FROM venta
		WHERE YEAR(Fecha)=2019
		GROUP BY MONTH(Fecha)
    UNION ALL
		SELECT MONTH(Fecha) as fecha, SUM(precio*cantidad*-1) as monto
		FROM compra
		WHERE YEAR(Fecha)=2019
		GROUP BY MONTH(Fecha)
    UNION ALL
		SELECT MONTH(Fecha) as fecha, SUM (Monto*-1) as monto
		FROM gasto
		WHERE YEAR(Fecha)=2019
		GROUP BY MONTH(Fecha)
) o
GROUP BY o.fecha
ORDER BY o.fecha;
*/

CREATE VIEW datos2019 AS
SELECT t.fecha, SUM(t.amount) AS amount
FROM (   
	SELECT  MONTH(Fecha) AS fecha, SUM(precio*cantidad) AS amount
			FROM venta
            WHERE YEAR(Fecha) = 2019
            GROUP BY MONTH(Fecha)
	UNION ALL
	SELECT MONTH(Fecha) AS fecha, SUM(precio*cantidad*-1) AS amount
		   FROM compra
           WHERE YEAR(Fecha) = 2019
           GROUP BY MONTH(Fecha)
	UNION ALL
	SELECT MONTH(Fecha) AS fecha, SUM(monto*-1) AS amount
		   FROM gasto
           WHERE YEAR(Fecha) = 2019
           GROUP BY MONTH(Fecha)
    ) t
    GROUP BY t.fecha
    ORDER BY t.fecha;
   

CREATE VIEW datos2020 AS
SELECT t.fecha, SUM(t.amount) AS amount
FROM (   
	SELECT  MONTH(Fecha) AS fecha, SUM(precio*cantidad) AS amount
			FROM venta
            WHERE YEAR(Fecha) = 2020
            GROUP BY MONTH(Fecha)
	UNION ALL
	SELECT MONTH(Fecha) AS fecha, SUM(precio*cantidad*-1) AS amount
		   FROM compra
           WHERE YEAR(Fecha) = 2020
           GROUP BY MONTH(Fecha)
	UNION ALL
	SELECT MONTH(Fecha) AS fecha, SUM(monto*-1) AS amount
		   FROM gasto
           WHERE YEAR(Fecha) = 2020
           GROUP BY MONTH(Fecha)
    ) t
    GROUP BY t.fecha
    ORDER BY t.fecha;

SELECT datos2020.fecha, datos2019.amount as anio2019, datos2020.amount as anio2020,
	   (datos2020.amount - datos2019.amount) as diferencia,
       ((datos2020.amount - datos2019.amount) / abs(datos2019.amount)) * 100 as crecimiento
FROM datos2019
JOIN datos2020 USING (fecha)
ORDER BY 5 ;
       
#Cada una de las sucursales de la provincia de Córdoba, disponibilizaron un excel donde registraron el porcentaje de comisión que se le otorgó a cada uno de los empleados sobre la venta que realizaron. Es necesario incluir esas tablas (Comisiones Córdoba Centro.xlsx, Comisiones Córdoba Quiróz.xlsx 
#y Comisiones Córdoba Cerro de las Rosas.xlsx) en el modelo y contestar las siguientes preguntas: 

DROP TABLE comisionesEmpleados;
CREATE TABLE IF NOT EXISTS comisionesEmpleados (
    CodigoEmpleado INT NOT NULL,
	IdSucursal INT NOT NULL,
    Apellido_y_Nombre VARCHAR (80),
    Sucursal VARCHAR (80),
    Anio INT NOT NULL,
    Mes INT NOT NULL,
    Porcentaje INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;


LOAD DATA LOCAL INFILE "/home/maxi/SoyHenry/HENRY Complete/CPM3/checkpointm32021/Comisiones_Quiroz.csv" INTO TABLE comisionesEmpleados
FIELDS TERMINATED BY ";" LINES TERMINATED BY "\n" IGNORE 1 LINES;
SELECT COUNT(*) from comisionesEmpleados;
#QUIROZ

LOAD DATA LOCAL INFILE "/home/maxi/SoyHenry/HENRY Complete/CPM3/checkpointm32021/Comisiones_Centro.csv" INTO TABLE comisionesEmpleados
FIELDS TERMINATED BY ';' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
SELECT COUNT(*) from comisionesEmpleados;
#CENTRO


LOAD DATA LOCAL INFILE "/home/maxi/SoyHenry/HENRY Complete/CPM3/checkpointm32021/Comisiones_Cerro_Rosas.csv" INTO TABLE comisionesEmpleados
FIELDS TERMINATED BY ';' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
SELECT COUNT(*) from comisionesEmpleados;
#CERRO



#15) ¿Cuál es el código de empleado del empleado que mayor comisión obtuvo en diciembre del año 2020?

SELECT ce.CodigoEmpleado, ce.anio, ce.mes, ((ce.porcentaje/100)*datoemp.comtotal) as COMISIONTOTAL
FROM comisionesEmpleados ce
JOIN (
	SELECT v.idEmpleado, YEAR(v.Fecha), MONTH(v.Fecha), SUM(v.precio*v.cantidad) as comtotal
	FROM venta v
    JOIN empleado e ON(v.IdEmpleado=e.IdEmpleado)
    WHERE YEAR(v.Fecha)=2020 AND MONTH(v.Fecha)=12
    GROUP BY v.idEmpleado,YEAR(v.Fecha), MONTH(v.Fecha)
) datoemp
ON ((ce.idsucursal*1000000 + ce.CodigoEmpleado) = datoemp.idEmpleado)
WHERE ce.anio=2020 and ce.mes=12
GROUP BY ce.CodigoEmpleado
ORDER BY 4 DESC;
#3929

#16) ¿Cuál es la sucursal que más comisión pagó en el año 2020? 

SELECT ce.IdSucursal, ce.anio , ((ce.porcentaje/100)*SUM(v.precio*v.cantidad))
FROM comisionesEmpleados ce
JOIN venta v on (ce.IdSucursal=v.IdSucursal AND ce.anio=2020)
WHERE year(v.fecha)=2020
GROUP BY ce.IdSucursal, ce.anio
ORDER BY 3 DESC;
















