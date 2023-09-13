USE `checkpoint_m2`;

-- 1) ¿Cuál fue el canal de venta con mayores ventas registradas en el año 2017?
select idcanal, count(precio*cantidad) as ventas from venta
  where year(fecha)=2017
	group by idcanal
	order by ventas desc;
    
    select * from canal_venta;
    select * from venta;
    
    -- 2) ¿Cuál fue el canal de venta con menor cantidad de productos vendidos en el año 2020?
    select idcanal, count(cantidad*precio) as ventas from venta
    where year(fecha)=2020
    group by idcanal
    order by ventas asc;
    
    -- 3)¿Cuál es el Id del empleado que menor cantidad de productos vendió en el histórico de ventas de la empresa?
select idempleado, count(precio*cantidad) as ventas from venta
group by IdEmpleado
order by ventas asc;

-- 4) cuál es el mes con su respectivo año, con el promedio más bajo de este tiempo de entrega?
-- 4) ¿Cuál es el mes con su respectivo año, con el promedio más bajo de tiempo de entrega?
select date_format(fecha, '%m%Y') as MesAño, avg(TIMESTAMPDIFF(day, fecha, fecha_entrega)) AS TiempoEntrega
from venta
group by MesAño
order by TiempoEntrega asc;

-- 5)¿Cuál es el promedio de precio de los productos cuyo concepto comienza con la letra C?
select avg(precio) as promedio from producto
where concepto like 'C%';

-- 6) ¿Cuál es el id del Producto cuyo nombre es EPSON COPYFAX 2000?
select idproducto from producto
where concepto like 'EPSON COPYFAX 2000';

select * from producto;

-- 7) ¿Cuantos productos tienen la palabra CD en alguna parte de su descripción y su precio es mayor a 500?
-- ¿Cuantos productos tienen la palabra " CD " (mayúsculas o minúsculas) en alguna 
-- parte de su descripción (Concepto = Descripción del Producto) y su precio es mayor a 500?
select count(idproducto) from producto
where concepto like '%CD%' and precio > 500;

select * from producto
where concepto like '%CD%';

-- 8)Considerando el año 2017, ¿Cuál fue el mes (considerando la fecha de venta, es 
-- decir, usando el campo Fecha) con mayor monto total de venta (monto de venta = Precio*Cantidad) 
-- para el empleado 1426?
select date_format(fecha, '%m') as mes, sum(precio*cantidad) as ventas from venta
where year (fecha) = 2017 and idempleado=1426
group by mes
order by ventas desc;