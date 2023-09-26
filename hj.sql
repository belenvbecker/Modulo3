use henry_04;

CREATE TABLE IF NOT EXISTS sucursales (
	ID			INTEGER,
	Sucursal	VARCHAR(40),
	Domicilio	VARCHAR(150),
	Localidad	VARCHAR(80),
	Provincia	VARCHAR(50),
	Latitud	cimen(30),
	Longitud	VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

LOAD DATA INFILE 'C:\\Users\\belen\\OneDrive\\Escritorio\\M3\\m3\\Clase 04\\Homework_Resuelto\\Sucursales_UTF8.csv' 
INTO TABLE sucursales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT * FROM sucursal;