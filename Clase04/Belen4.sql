-- Active: 1693875076557@@127.0.0.1@3306@henry_04
-- La Dirección de Ventas ha solicitado las siguientes tablas a Marketing con el fin de que sean integradas:

-- 1) La tabla de puntos de venta propios.
-- 2) La tabla de empleados.
-- 3) La tabla de proveedores. 
-- 4) La tabla de clientes.
-- 5) La tabla de productos.
-- 6) La tabla de ventas.
-- 7) La tabla de gastos. 
-- 8) La tabla de compras.

-- 1)
CREATE DATABASE if not EXISTS henry_04;
use henry_04;
SET GLOBAL local_infile = 'ON';
CREATE Table if not exists canaldeventa(
      codigo INT PRIMARY KEY ,
      descripcion VARCHAR(50));

LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\CanalDeVenta.csv'
INTO TABLE canaldeventa  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines

drop table canaldeventa

select * from canaldeventa


-- 2)
CREATE Table if not exists empleados(
      ID_empleado int ,
      Apellido varchar (50),
      Nombre varchar (50),
      Sucursal varchar (50),
      Sector varchar (50),
      Cargo varchar (50),
      Salario decimal (10,2))


LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\empleados.csv'
INTO TABLE empleados  
FIELDS TERMINATED BY ';'
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines

drop table empleados

select * from empleados


-- 3)
CREATE Table if not exists proveedores(
      IDProveedor int PRIMARY KEY,
      Nombre varchar (50),
      Address varchar (50),
      City varchar (50),
      State varchar (50),
      Country varchar (50),
      departamen varchar (50))

LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\proveedores.csv'
INTO TABLE proveedores  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines

drop table proveedores

select * from proveedores


-- 4)
CREATE Table if not exists Clientes(
      ID int PRIMARY KEY,
      Provincia varchar (50),
      Nombre_y_Apellido varchar (100),
      Domicilio varchar (50),
      Telefono varchar (50),
      Edad int,
      Localidad varchar (50),
      X varchar (100),
      Y varchar (100),
      Fecha_Alta date,
      Usuario_Alta varchar (50),
      Fecha_Ultima_Modificacion date,
      Usuario_Ultima_Modificacion varchar (50),
      Marca_Baja int,
      col10 varchar (50))

LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\Clientes.csv'
INTO TABLE Clientes  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines

drop table Clientes

select * from Clientes


-- 5)
CREATE Table if not exists Productos(
      ID_PRODUCTO int PRIMARY KEY,
      Concepto varchar(100),
      Tipo varchar(100),
      Precio decimal (10,2))

LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\productos.csv'
INTO TABLE Productos  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines


drop table Productos

select * from Productos


-- 6)
CREATE Table if not exists Ventas(
      IdVenta int PRIMARY KEY,
      Fecha date, 
      Fecha_Entrega date,
      IdCanal int,
      IdCliente int,
      IdSucursal int,
      IdEmpleado int,
      IdProducto int,
      Precio decimal(10,2),
      Cantidad int)

LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\venta.csv'
INTO TABLE Ventas  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines


drop table Ventas

select * from Ventas


-- 7)
CREATE Table if not exists TiposdeGasto(
      IdTipoGasto int PRIMARY KEY,
      Descripcion varchar (100),
      Monto_Aproximado int)

LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\TiposdeGasto.csv'
INTO TABLE TiposdeGasto  
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines


drop table TiposdeGasto

select * from TiposdeGasto


-- 8)
CREATE Table if not exists Compra(
      IdCompra int PRIMARY KEY,
      Fecha date, 
      IdProducto int,
      Cantidad int,
      Precio decimal (10,2),
      IdProveedor int)

LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\Compra.csv'
INTO TABLE Compra 
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines


drop table Compra

select * from Compra

CREATE Table if not exists Sucursales(
      IdSucursal INT PRIMARY KEY,
      Sucursal varchar (100),
      Direccion varchar (100),
      Localidad varchar (100),
      Provincia varchar (100),
      Latitud Decimal (13,10),
      Longitud Decimal (13,10))

LOAD DATA LOCAL INFILE 
'C:\\Users\\belen\\OneDrive\\Escritorio\\Modulo3\\Clase04\\Homework\\Sucursales.csv'
INTO TABLE Sucursales
FIELDS TERMINATED BY ';'
ENCLOSED BY '\"' 
ESCAPED BY '\"' 
LINES TERMINATED BY '\n'
ignore 1 lines

Select * from sucursales;