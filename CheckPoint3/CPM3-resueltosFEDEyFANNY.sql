USE `henry_checkpoint_m3`;

-- 6) La ganancia neta por sucursal es las ventas menos los gastos (Ganancia = Venta - Gasto) ¿Cuál es la sucursal con mayor ganancia neta en 2019? *
SELECT  v.IdSucursal,
		SUM(v.Precio*v.Cantidad) AS Venta,
		SUM(g.Monto) AS Gasto,
        SUM(v.Precio*v.Cantidad) - SUM(g.Monto) AS Ganancia
FROM venta v
LEFT JOIN gasto g ON (v.IdSucursal = g.IdSucursal AND YEAR(v.Fecha) = 2019 AND YEAR(g.Fecha)=2019)
GROUP BY v.IdSucursal
ORDER BY Ganancia DESC;

select v.idSucursal, sum(v.Precio*v.Cantidad) as ventas, q1.gastos as gastos ,  (sum(v.Precio*v.Cantidad)-q1.gastos) as ganancia
from venta v
JOIN 	(select idSucursal, sum(Monto) as gastos
		from gasto
		Where YEAR(Fecha) = 2019
		group by idSucursal) q1 on q1.idSucursal = v.idSucursal 
where year(v.Fecha) = 2019
group by idSucursal
order by ganancia desc;


-- 7) La ganancia neta por producto es las ventas menos las compras (Ganancia = Venta - Compra) ¿Cuál es el tipo de producto con mayor ganancia neta en 2019? *

SELECT  v.IdProducto,
		tp.TipoProducto,
		SUM(v.Precio*v.Cantidad) AS Venta,
		SUM(c.Precio*v.Cantidad) AS Gasto,
        SUM(v.Precio*v.Cantidad) - SUM(c.Precio*v.Cantidad) AS Ganancia_neta
FROM venta v
JOIN compra c ON (v.IdProducto = c.IdProducto AND YEAR(c.Fecha) = 2019)
JOIN producto p ON (p.IdProducto = v.IdProducto)
JOIN tipo_producto tp ON (p.IdTipoProducto = tp.IdTipoProducto)
GROUP BY tp.TipoProducto
ORDER BY Ganancia_Neta DESC;

-- 8) Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo en al menos dos sucursales? (expresado en porcentaje y con dos decimales, por ejemplo 11.11) *

set @total_clientes = (SELECT count(distinct IdCliente)
FROM venta
where year(Fecha) = 2019); 

select  @total_clientes;

select count(*)/ @total_clientes * 100 from (select IdCliente, count(distinct IdSucursal) as cant_sucursales 
from venta 
where year(Fecha)=2019
group by IdCliente	
having cant_sucursales>=2)c;

-- 9) Del total de clientes que realizaron compras en 2020 ¿Qué porcentaje no había realizado compras en 2019? (expresado en porcentaje y con dos decimales, por ejemplo 11.11) *

set @total_clientes = (SELECT count(distinct IdCliente)
FROM venta
where year(Fecha) = 2020); 

select  @total_clientes;
SELECT COUNT(DISTINCT idCliente)*100/ @total_clientes
from venta
where year(Fecha)=2020 AND IdCliente NOT IN (SELECT DISTINCT idCliente 
                        FROM venta
                        WHERE YEAR(Fecha) = 2019);
                        

-- 10) Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo también en 2020? (expresado en porcentaje y con dos decimales, por ejemplo 11.11) *

set @total_clientes2019 = (SELECT count(distinct IdCliente)
FROM venta
where year(Fecha) = 2019); 

select  @total_clientes2019;

SELECT COUNT(DISTINCT idCliente)*100/ @total_clientes2019
from venta
where year(Fecha)=2019 AND IdCliente IN (SELECT DISTINCT idCliente 
                        FROM venta
                        WHERE YEAR(Fecha) = 2020);
                        
-- 11) ¿Qué cantidad de clientes realizó compras sólo por el canal Presencial entre 2019 y 2020? *

SELECT sum(v.cantidad*v.precio) AS ventas, s.Sucursal
FROM venta v
INNER JOIN sucursal s ON v.IdSucursal = s.IdSucursal 
WHERE year(v.fecha) = 2020
GROUP BY s.sucursal
ORDER BY ventas desc;

select c.IdLocalidad, c.IdCliente, p.IdProvincia
from cliente c
INNER JOIN localidad l ON c.IdLocalidad = l.IdLocalidad
INNER JOIN provincia p ON l.IdProvincia = p.IdProvincia
INNER JOIN venta v on v.IdCliente=c.IdCliente
WHERE year(fecha) = 2020 
GROUP BY p.IdProvincia;

SELECT c.IdCliente, l.IdProvincia
FROM cliente c
JOIN localidad l ON c.IdLocalidad = l.IdLocalidad
ORDER BY c.IdCliente;

SELECT sum(cantidad*precio) AS productos_vendidos, Provincia
FROM venta v
INNER JOIN sucursal s ON v.IdSucursal = s.IdSucursal 
INNER JOIN localidad l ON s.IdLocalidad = l.IdLocalidad
INNER JOIN cliente c ON c.IdLocalidad = l.IdLocalidad
INNER JOIN provincia p ON l.IdProvincia = p.IdProvincia
WHERE year(fecha) = 2020 
group by s.IdSucursal;


SELECT  v.IdSucursal, sum(v.Precio * v.Cantidad) AS totalVentas
    FROM venta v
    INNER JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
    INNER JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad) -- localidad de la sucursal
    INNER JOIN CLIENTE C ON (c.idcliente=v.idcliente)
    INNER JOIN localidad l2 ON (c.IdLocalidad = l2.IdLocalidad) -- localidad del cliente
    WHERE year(Fecha) = 2020 and  l.idprovincia != l2.idprovincia
    GROUP BY v.IDSUCURSAL 
    ORDER BY totalventas DESC;
    
SELECT v.IdCliente,l.IdProvincia FROM venta v
join sucursal s using(idsucursal)
join localidad l on(s.idlocalidad=l.IdLocalidad);

SELECT cq.IdCliente,lq.IdProvincia as prov  FROM cliente cq
join localidad lq on(lq.idlocalidad=cq.idlocalidad)
group by cq.idcliente;
SELECT sucursal,v.idsucursal,v.idventa,fecha,l.idprovincia,prov_cliente,sum(precio*cantidad) as ventas FROM venta v
join sucursal s using(idsucursal)
join localidad l on(s.idlocalidad=l.IdLocalidad)
join(
SELECT cq.IdCliente,lq.IdProvincia as prov_cliente  FROM cliente cq
join localidad lq on(lq.idlocalidad=cq.idlocalidad)) q1 on(v.idcliente=q1.IdCliente)
where year(fecha)=2020
group by v.idsucursal
having l.idprovincia!=prov_cliente
order by ventas desc ;

SELECT s.Sucursal, SUM(V.Precio * V.Cantidad) as Venta
FROM VENTA V
JOIN sucursal S USING (IdSucursal)
JOIN LOCALIDAD using (IdLocalidad)
JOIN provincia p using (idprovincia)
JOIN 
	(select c.IdCliente, p.IdProvincia
    from cliente c 
    join localidad using (idlocalidad)
    join provincia p using(idprovincia)) DC on (DC.IdCliente=v.Idcliente)
where year(v.fecha) = 2020 AND (p.IdProvincia != dc.IdProvincia)
group by s.Sucursal
ORDER BY Venta desc;

SELECT  v.IdCliente, 
		v.IdSucursal, 
        l.IdProvincia, 
        v.Precio * v.Cantidad AS Ventas
FROM venta v
JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad)
WHERE year(Fecha) = 2020
ORDER BY IdCliente;

SELECT c.IdCliente, l.IdProvincia
		FROM cliente c
		JOIN localidad l ON (c.IdLocalidad = l.IdLocalidad)
		ORDER BY IdCliente;

SELECT	t1.IdCliente, 
		t1.IdSucursal, 
		t1.IdProvincia AS Prov_Sucursal, 
		t2.IdProvincia AS Prov_Cliente,
		t1.Ventas
FROM   (SELECT  v.IdCliente, 
				v.IdSucursal, 
				l.IdProvincia, 
				v.Precio * v.Cantidad AS Ventas
		FROM venta v
		JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
		JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad)
		WHERE year(Fecha) = 2020
		ORDER BY IdCliente) t1
JOIN   (SELECT c.IdCliente, l.IdProvincia
		FROM cliente c
		JOIN localidad l ON (c.IdLocalidad = l.IdLocalidad)
		ORDER BY IdCliente) t2 ON (t2.IdCliente = t1.IdCliente)
WHERE t1.IdProvincia != t2. IdProvincia
ORDER BY IdCliente;

SELECT IdSucursal, sum(Ventas)
FROM (SELECT    t1.IdCliente, 
				t1.IdSucursal, 
				t1.IdProvincia AS Prov_Sucursal, 
				t2. IdProvincia AS Prov_Cliente,
				t1.Ventas
	  FROM (SELECT  v.IdCliente, 
					v.IdSucursal, 
					l.IdProvincia, 
					v.Precio * v.Cantidad AS Ventas
			FROM venta v
			JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
			JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad)
			WHERE year(Fecha) = 2020
			ORDER BY IdCliente) t1
	  JOIN   (SELECT c.IdCliente, l.IdProvincia
			  FROM cliente c
			  JOIN localidad l ON (c.IdLocalidad = l.IdLocalidad)
			  ORDER BY IdCliente) t2 ON (t2.IdCliente = t1.IdCliente)
WHERE t1.IdProvincia <> t2. IdProvincia) t3
GROUP BY IdSucursal
ORDER BY sum(Ventas) DESC;

SELECT IdSucursal, count(*)
from   (SELECT DISTINCT IdCliente, IdSucursal
		FROM venta
        WHERE year(Fecha) = 2020) d
GROUP BY IdSucursal
ORDER BY IdSucursal;

SELECT DISTINCT v.IdCliente, v.IdSucursal, l.IdProvincia
		FROM venta v
        JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
        JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad)
        WHERE year(Fecha) = 2020
        ORDER BY IdCliente;

SELECT s.IdSucursal, l.IdProvincia
FROM sucursal s
JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad)
ORDER BY IdSucursal;

SELECT c.IdCliente, l.IdProvincia
FROM cliente c
JOIN localidad l ON (c.IdLocalidad = l.IdLocalidad)
ORDER BY IdCliente;


SELECT DISTINCT IdCliente
FROM venta
WHERE IdSucursal = 2 and year(Fecha) = 2020;

-- 12) ¿Cuál es la sucursal que más Venta (Precio * Cantidad) hizo en 2019 a clientes que viven fuera de su provincia? *

SELECT  v.IdSucursal, sum(v.Precio * v.Cantidad) AS totalVentas
    FROM venta v
    INNER JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
    INNER JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad) -- localidad de la sucursal
    INNER JOIN CLIENTE C ON (c.idcliente=v.idcliente)
    INNER JOIN localidad l2 ON (c.IdLocalidad = l2.IdLocalidad) -- localidad del cliente
    WHERE year(Fecha) = 2019 and  l.idprovincia != l2.idprovincia
    GROUP BY v.IDSUCURSAL 
    ORDER BY totalventas DESC;
    
    -- 13) ¿Cuál fué el mes del año 2020, de mayor decrecimiento (o menor crecimiento) con respecto al mismo mes del año 2019 si se toman en cuenta a nivel general Ventas (Precio * Cantidad) - Compras (Precio * Cantidad) - Gastos?  *
    
    Select month(Fecha),  v (Precio * Cantidad) - c (Precio * Cantidad) - g.monto
    from venta v
    INNER JOIN compra c on (v.IdProducto = c.IdProducto)
    INNER JOIN gasto g on (g.IdSucursal=v.IdSucursal)
    WHERE month(Fecha)= 2020
    GROUP BY MONTH(v.Fecha);
    
    
    
    SELECT q2020.mes AS mes, (q2020.Ganancia_mes_2020-q2019.Ganancia_mes_2019) AS crecimiento
FROM (SELECT MONTH(v.Fecha) AS mes, SUM(v.Precio*v.Cantidad)-SUM(c.Precio*c.Cantidad*-1)-SUM(g.Monto*-1) AS Ganancia_mes_2020
		FROM venta v
		JOIN compra c ON(c.idProducto=v.idProducto)
		JOIN gasto g ON(g.IdSucursal=v.IdSucursal)
		WHERE YEAR(v.Fecha) = 2020
		GROUP BY MONTH(v.Fecha)) q2020
JOIN (SELECT MONTH(v.Fecha) AS mes, SUM(v.Precio*v.Cantidad)-SUM(c.Precio*c.Cantidad*-1)-SUM(g.Monto*-1) AS Ganancia_mes_2019
		FROM venta v
		JOIN compra c ON(c.idProducto=v.idProducto)
		JOIN gasto g ON(g.IdSucursal=v.IdSucursal)
		WHERE YEAR(v.Fecha) = 2019
		GROUP BY MONTH(v.Fecha)) q2019 ON (q2019.mes = q2020.mes)
GROUP BY mes
ORDER BY crecimiento ASC;

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
    
SELECT 
    datos2020.fecha, datos2019.amount AS anio2019,datos2020.amount AS anio2020,
    datos2020.amount - datos2019.amount AS diferencia,
    (datos2020.amount - datos2019.amount) / ABS(datos2019.amount) * 100 AS crecimiento
FROM datos2020
JOIN datos2019 USING (fecha)
ORDER BY 5 DESC;

-- Cada una de las sucursales de la provincia de Córdoba, disponibilizaron un excel donde registraron el porcentaje de comisión que se le otorgó a cada uno de los empleados sobre la venta que realizaron. Es necesario incluir esas tablas (Comisiones Córdoba Centro.xlsx, Comisiones Córdoba Quiróz.xlsx y Comisiones Córdoba Cerro de las Rosas.xlsx) en el modelo y contestar las siguientes preguntas: *



CREATE TABLE IF NOT EXISTS comisionesEmpleados (
    CodigoEmpleado INT NOT NULL,
	IdSucursal INT NOT NULL,
    Apellido_y_Nombre VARCHAR (80),
    Sucursal VARCHAR (80),
    Anio INT NOT NULL,
    Mes INT NOT NULL,
    Porcentaje INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

LOAD DATA INFILE "C:\Users\Fede\Documents\Henry\checkpoints\Comisiones Córdoba Quiróz.csv"
INTO TABLE comisionesEmpleados
FIELDS TERMINATED BY ';'
ENCLOSED BY ''
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:\Users\Fede\Documents\Henry\checkpoints\Comisiones Córdoba Centro.csv"
INTO TABLE comisionesEmpleados
FIELDS TERMINATED BY ';'
ENCLOSED BY ''
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:\Users\Fede\Documents\Henry\checkpoints\Comisiones Córdoba Cerro de las Rosas.csv"
INTO TABLE comisionesEmpleados
FIELDS TERMINATED BY ';'
ENCLOSED BY ''
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

USE `henry_checkpoint_m3`;


-- 15) ¿Cuál es el código de empleado del empleado que mayor comisión obtuvo en diciembre del año 2020?

SELECT e.CodigoEmpleado, sum(ce.Porcentaje/100 * (v.Precio*v.Cantidad)) AS Comision
FROM venta v 
JOIN empleado e on v.IdEmpleado=e.IdEmpleado
JOIN comisionesempleados ce on e.CodigoEmpleado=ce.CodigoEmpleado
WHERE ce.Anio = 2020 AND ce.Mes = 12
group by v.IdEmpleado
order by Comision;


-- 16) ¿Cuál es la sucursal que más comisión pagó en el año 2020? 

SELECT v.IdSucursal, sum(ce.Porcentaje/100 * (v.Precio*v.Cantidad)) AS Comision
FROM venta v 
JOIN empleado e on v.IdEmpleado=e.IdEmpleado
JOIN comisionesempleados ce on e.CodigoEmpleado=ce.CodigoEmpleado
WHERE ce.Anio = 2020
group by v.IdSucursal
order by Comision;


SELECT sucursal, SUM(comision) AS total_comision
FROM tabla_comisiones
WHERE YEAR(fecha) = 2020
GROUP BY sucursal
ORDER BY total_comision DESC
LIMIT 1;
