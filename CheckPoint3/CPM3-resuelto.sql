-- 7) La ganancia neta por producto es las ventas menos las compras (Ganancia = Venta - Compra) 
-- ¿Cuál es el tipo de producto con mayor ganancia neta en 2020?
-- Elige la opción correcta:
-- # 1- Informática #
-- 2- Impresión
-- 3- Grabacion

SELECT v.IdProducto,
		tp.TipoProducto,
		SUM(v.Precio*v.Cantidad) AS Venta,
		SUM(c.Precio*v.Cantidad) AS Compra,
        SUM(v.Precio*v.Cantidad) - SUM(c.Precio*v.Cantidad) AS Ganancia_neta
FROM venta v
LEFT JOIN  compra c ON v.IdProducto = c.IdProducto
LEFT JOIN producto p ON p.IdProducto= c.IdProducto
LEFT JOIN tipo_producto tp ON tp.IdTipoProducto= p.IdTipoProducto
where (YEAR (v.Fecha = 2020) and YEAR(c.Fecha = 2020))
GROUP BY tp.TipoProducto, v.IdProducto;

SELECT  v.IdProducto,
		tp.TipoProducto,
		SUM(v.Precio*v.Cantidad) AS Venta,
		SUM(c.Precio*v.Cantidad) AS Gasto,
        SUM(v.Precio*v.Cantidad) - SUM(c.Precio*v.Cantidad) AS Ganancia_neta
FROM venta v
JOIN compra c ON (v.IdProducto = c.IdProducto AND YEAR(c.Fecha) = 2020)
JOIN producto p ON (p.IdProducto = v.IdProducto)
JOIN tipo_producto tp ON (p.IdTipoProducto = tp.IdTipoProducto)
GROUP BY tp.TipoProducto
ORDER BY Ganancia_Neta DESC;

-- 8) Del total de clientes que realizaron compras en 2020 ¿Qué porcentaje lo hizo sólo en una única sucursal?
# 33.71 % #

-- Con esto sabemos el total de clientes que compraron en el 2020

set @total_clientes = (SELECT count(distinct IdCliente)
FROM venta
where year(Fecha) = 2020); 

select  @total_clientes;

select count(*)/ @total_clientes * 100 from (select IdCliente, count(distinct IdSucursal) as cant_sucursales -- le agrege el count(distinct IdSucursal)
from venta 
where year(Fecha)=2020
group by IdCliente	-- tomando en cuenta cada cliente,
having cant_sucursales=1)c;

set @total = (select count(*) from (select idcliente from cliente
join venta v using(idcliente)
where year(fecha)=2020
group by idcliente) p);

-- codigo lauti

select count(*) from 
(SELECT count(distinct sucursal) as cliente_una_s FROM venta
join sucursal s using(idsucursal)
where year(fecha)=2020
group by Idcliente
having count(distinct sucursal) = 1) xd;

### 9) Del total de clientes que realizaron compras en 2020 ¿Qué porcentaje no había realizado compras en 2019?

-- codigo naty con ayuda dani

SELECT COUNT(DISTINCT idCliente)*100/ @total_clientes
from venta
where year(Fecha)=2020 AND IdCliente NOT IN (SELECT DISTINCT idCliente 
                        FROM venta
                        WHERE YEAR(Fecha) = 2019);

-- codigo Dani

SELECT COUNT(DISTINCT idCliente)*100/@total_clientes_2020
FROM (SELECT DISTINCT idCliente
    FROM venta
    WHERE YEAR(Fecha) = 2020) c2020
WHERE idCliente NOT IN (SELECT DISTINCT idCliente 
                        FROM venta
                        WHERE YEAR(Fecha) = 2019);

### 10) Del total de clientes que realizaron compras en 2019 ¿Qué porcentaje lo hizo también en 2020?

set @total_clientes2019 = (SELECT count(distinct IdCliente)
FROM venta
where year(Fecha) = 2019); 

SELECT COUNT(DISTINCT idCliente)*100/ @total_clientes2019
from venta
where year(Fecha)=2019 AND IdCliente IN (SELECT DISTINCT idCliente 
                        FROM venta
                        WHERE YEAR(Fecha) = 2020);


### 11) ¿Qué cantidad de clientes realizó compras sólo por el canal OnLine entre 2019 y 2020?


Select count(*) from(SELECT IdCanal, COUNT(DISTINCT idCanal) as Total_Clientes
FROM venta
WHERE ( year(fecha) = 2020 or year(fecha)=2019)
group by IdCliente
having Total_Clientes= 1) a
where a.IdCanal=2;


### 12) ¿Cuál es la sucursal que más Venta (Precio * Cantidad) hizo en 2020 a clientes que viven fuera de su provincia?

## Con lucas para ver Sucursal con mas Ventas
SELECT sum(v.cantidad*v.precio) AS ventas, s.Sucursal
FROM venta v
INNER JOIN sucursal s ON v.IdSucursal = s.IdSucursal 
WHERE year(v.fecha) = 2020
GROUP BY s.sucursal
ORDER BY ventas desc;

# Con Dani viendo si sacamos los clientes que compraron en un lugar que esta por fuera de su prov.

select c.IdLocalidad, c.IdCliente, p.IdProvincia
from cliente c
INNER JOIN localidad l ON c.IdLocalidad = l.IdLocalidad
INNER JOIN provincia p ON l.IdProvincia = p.IdProvincia
INNER JOIN venta v on v.IdCliente=c.IdCliente
WHERE year(fecha) = 2020 
GROUP BY p.IdProvincia;

#Donde viven los clientes?

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


# Lo saqeu del grupo del sup
SELECT  v.IdSucursal, sum(v.Precio * v.Cantidad) AS totalVentas
    FROM venta v
    INNER JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
    INNER JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad) -- localidad de la sucursal
    INNER JOIN CLIENTE C ON (c.idcliente=v.idcliente)
    INNER JOIN localidad l2 ON (c.IdLocalidad = l2.IdLocalidad) -- localidad del cliente
    WHERE year(Fecha) = 2020 and  l.idprovincia != l2.idprovincia
    GROUP BY v.IDSUCURSAL 
    ORDER BY totalventas DESC;
    
    
  #Codigo de Lauti
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

# Lo hizo Guille
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

-- Tabla 1: Ventas y provincias de las sucursales que realizo cada cliente durante 2020 as t1
SELECT  v.IdCliente, 
		v.IdSucursal, 
        l.IdProvincia, 
        v.Precio * v.Cantidad AS Ventas
FROM venta v
JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad)
WHERE year(Fecha) = 2020
ORDER BY IdCliente;

-- Tabla 2: Provincias a las que pertenece cada cliente
SELECT c.IdCliente, l.IdProvincia
		FROM cliente c
		JOIN localidad l ON (c.IdLocalidad = l.IdLocalidad)
		ORDER BY IdCliente;

## Ventas realizadas a clientes que viven fuera de la provincia a la que pertenece la sucursal
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


## Cuenta los clientes que tienen sus provincias diferente a las provincias de las sucursales donde realizaron la compra
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


# Cantidad de clientes que realizaron compras en cada sucursal durante 2020
SELECT IdSucursal, count(*)
from   (SELECT DISTINCT IdCliente, IdSucursal
		FROM venta
        WHERE year(Fecha) = 2020) d
GROUP BY IdSucursal
ORDER BY IdSucursal;

# Lista de las provincias donde esta cada sucursal en las que compro cada cliente durante 2020
SELECT DISTINCT v.IdCliente, v.IdSucursal, l.IdProvincia
		FROM venta v
        JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
        JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad)
        WHERE year(Fecha) = 2020
        ORDER BY IdCliente;




## lista de sucursales con sus respectivas provincias
SELECT s.IdSucursal, l.IdProvincia
FROM sucursal s
JOIN localidad l ON (s.IdLocalidad = l.IdLocalidad)
ORDER BY IdSucursal;


## lista de clientes con sus respectivas provincias
SELECT c.IdCliente, l.IdProvincia
FROM cliente c
JOIN localidad l ON (c.IdLocalidad = l.IdLocalidad)
ORDER BY IdCliente;


SELECT DISTINCT IdCliente
FROM venta
WHERE IdSucursal = 2 and year(Fecha) = 2020;

### 13) ¿Cuál fué el mes del año 2020, de mayor crecimiento con respecto al mismo mes del año 2019 si se toman en cuenta a nivel general Ventas (Precio * Cantidad) - Compras (Precio * Cantidad) - Gastos? 





