CREATE DOMAIN TEstado AS varchar(20)
CHECK (VALUE IN ('Pendiente', 'Recibido', 'Cancelado'));

CREATE DOMAIN TDocumento AS varchar(3)
CHECK (VALUE IN ('CC', 'TI', 'CE', 'PPT'));

CREATE DOMAIN TRestriccion AS varchar(20)
CHECK (VALUE IN ('Ninguna', 'Alergia', 'Especial', 'Diabetes', 'Hipertension', 'Cardiaca', 'Renal', 'Hepatica', 'Respiratoria', 'Neurologica'));

CREATE DOMAIN TSexo AS char(1)
CHECK (VALUE IN ('M', 'F', 'O'));

CREATE DOMAIN TMetodo AS varchar(20)
CHECK (VALUE IN ('Efectivo', 'Tarjeta', 'Transferencia'));

CREATE DOMAIN TMedicamento AS varchar(20)
CHECK (VALUE IN ('Analgesico', 'Antibiotico', 'Antialergico', 'Antiinflamatorio', 'Antipiretico', 'Antiespasmodico', 'Antidepresivo', 'Antihistaminico', 'Anticonvulsivo', 'Antimicotico', 'Antiviral', 'Antiparasitario', 'Anestesia', 'Cardiovascular', 'Respiratorio', 'Gastrointestinal', 'Endocrino', 'Dermatologico', 'Oftalmologico'));

CREATE DOMAIN TVia AS varchar(20)
CHECK (VALUE IN ('Oral', 'Inyectable', 'Topico', 'Transdermico', 'Inhalatoria'));

CREATE DOMAIN TCargo AS varchar(20)
CHECK (VALUE IN ('Administrador', 'Farmaceutico','Cajero','Auxiliar'));


-- CREACION DE TABLAS

CREATE TABLE proveedores (
    id_proveedor integer PRIMARY KEY,
    nombre varchar(100) NOT NULL,
    nit varchar(20) UNIQUE,
    telefono varchar(10),
    direccion varchar(100)
);

CREATE TABLE farmacias (
    id_farmacia integer PRIMARY KEY,
    nombre varchar(100) NOT NULL,
    direccion varchar(100),
    telefono varchar(10)
);

CREATE TABLE personas (
    id_persona integer PRIMARY KEY,
    nombre varchar(100) NOT NULL,
    tipo_documento TDocumento,
    documento char(10),
    telefono varchar(10),
    email varchar(100),
    edad integer,
    sexo TSexo,
    UNIQUE (tipo_documento, documento)
);

CREATE TABLE empleados (
    id_empleado integer PRIMARY KEY,
    salario integer,
    fecha_contratacion date,
    cargo TCargo,
    id_persona integer NOT NULL UNIQUE,
    FOREIGN KEY (id_persona) REFERENCES personas(id_persona)
);

CREATE TABLE pacientes (
    id_paciente integer PRIMARY KEY,
    fecha_nac date,
    direccion varchar(100),
    restricciones TRestriccion,
    id_persona integer NOT NULL UNIQUE,
    FOREIGN KEY (id_persona) REFERENCES personas(id_persona)
);

CREATE TABLE administradores (
    id_admin integer PRIMARY KEY,
    FOREIGN KEY (id_admin) REFERENCES empleados(id_empleado)
);

CREATE TABLE suministros (
    id_suministro integer PRIMARY KEY,
    fecha date,
    cantidad integer,
    estado TEstado,
    id_proveedor integer NOT NULL,
    id_farmacia integer NOT NULL,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
    FOREIGN KEY (id_farmacia) REFERENCES farmacias(id_farmacia)
);

CREATE TABLE inventarios (
    id_inventario integer PRIMARY KEY,
    fecha_actualizacion date,
    id_farmacia integer NOT NULL UNIQUE,
    FOREIGN KEY (id_farmacia) REFERENCES farmacias(id_farmacia)
);

CREATE TABLE medicamentos (
    id_medicamento integer PRIMARY KEY,
    nombre varchar(100) NOT NULL,
    precio_unitario decimal(10,2),
    tipo_medicamento TMedicamento,
    via_uso TVia
);

CREATE TABLE lotes (
    id_lote integer PRIMARY KEY,
    fecha_ven date,
    cant_dispo integer,
    id_medicamento integer NOT NULL,
    id_farmacia integer NOT NULL,
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento),
    FOREIGN KEY (id_farmacia) REFERENCES farmacias(id_farmacia)
);

CREATE TABLE suministros_medicamentos (
    id_suministro integer NOT NULL,
    id_medicamento integer NOT NULL,
    cantidad_med integer,
    precio_suministro decimal(10,2),
    PRIMARY KEY (id_suministro, id_medicamento),
    FOREIGN KEY (id_suministro) REFERENCES suministros(id_suministro),
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
);

CREATE TABLE ventas (
    id_venta integer PRIMARY KEY,
    fecha date,
    total decimal(12,2),
    metodo_pago TMetodo,
    id_farmacia integer NOT NULL,
    id_paciente integer,
    id_empleado integer NOT NULL,
    FOREIGN KEY (id_farmacia) REFERENCES farmacias(id_farmacia),
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

CREATE TABLE ventas_medicamentos (
    id_venta integer NOT NULL,
    id_medicamento integer NOT NULL,
    cantidad integer,
    precio_unitario decimal(10,2),
    PRIMARY KEY (id_venta, id_medicamento),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
);


-- POBLAR OK

INSERT INTO proveedores VALUES
(1, 'MedSupply', '900123456-1', '3001112233', 'Calle 10 #20'),
(2, 'BioMedic', '900234567-2', '3012223344', 'Carrera 15 #30'),
(3, 'HealthCorp', '900345678-3', '3023334455', 'Calle 50 #12');

INSERT INTO farmacias VALUES
(1, 'VidaSana', 'Calle 10 #15', '3101112233'),
(2, 'SaludTotal', 'Carrera 20 #30', '3102223344'),
(3, 'Farmacia Central', 'Calle 40 #20', '3103334455');

INSERT INTO personas VALUES
(1, 'Juan Perez', 'CC', '1000000001', '3001112233', 'juan@email.com', 26, 'M'),
(2, 'Maria Gomez', 'CC', '1000000002', '3012223344', 'maria@email.com', 28, 'F'),
(3, 'Carlos Ruiz', 'CC', '1000000003', '3023334455', 'carlos@email.com', 24, 'M');

INSERT INTO empleados VALUES
(1, 2500000, '2025-01-10', 'Administrador', 1),
(2, 2200000, '2025-02-15', 'Farmaceutico', 2),
(3, 2300000, '2025-03-20', 'Farmaceutico', 3);

INSERT INTO pacientes VALUES
(1, '2000-05-10', 'Calle 1 #10', 'Ninguna', 1),
(2, '1998-08-15', 'Carrera 5 #20', 'Alergia', 2),
(3, '2002-03-20', 'Calle 30 #15', 'Especial', 3);

INSERT INTO administradores VALUES
(1);

INSERT INTO suministros VALUES
(1, '2026-09-01', 50, 'Recibido', 1, 1),
(2, '2026-09-05', 80, 'Recibido', 2, 2),
(3, '2026-09-10', 100, 'Pendiente', 3, 3);

INSERT INTO inventarios VALUES
(1, '2026-09-20', 1),
(2, '2026-09-20', 2),
(3, '2026-09-20', 3);

INSERT INTO medicamentos VALUES
(1, 'Acetaminofen', 5000.00, 'Analgesico', 'Oral'),
(2, 'Amoxicilina', 12000.00, 'Antibiotico', 'Oral'),
(3, 'Loratadina', 8000.00, 'Antialergico', 'Oral');

INSERT INTO lotes VALUES
(1, '2026-10-15', 50, 1, 1),
(2, '2027-03-20', 80, 2, 2),
(3, '2027-06-10', 100, 3, 3);

INSERT INTO suministros_medicamentos VALUES
(1, 1, 50, 3500.00),
(2, 2, 80, 9000.00),
(3, 3, 100, 6000.00);

INSERT INTO ventas VALUES
(1, '2026-09-20', 15000, 'Efectivo', 1, 1, 1),
(2, '2026-09-21', 24000, 'Tarjeta', 2, 2, 2),
(3, '2026-09-22', 8000, 'Transferencia', 3, 3, 3);

INSERT INTO ventas_medicamentos VALUES
(1, 1, 3, 5000.00),
(2, 2, 2, 12000.00),
(3, 3, 1, 8000.00);


-- POBLAR NOOK

INSERT INTO proveedores VALUES
(90, 'Proveedor Base', '900900900-0', '3000000090', 'Calle 90');

INSERT INTO farmacias VALUES
(90, 'Farmacia Base', 'Calle 90', '3100000090');

INSERT INTO personas VALUES
(90, 'Persona Base', 'CC', '1000000090', '3000000090', 'base@email.com', 30, 'M'),
(92, 'Persona Cargo', 'CC', '1000000092', '3000000092', 'cargo@email.com', 30, 'M');

INSERT INTO empleados VALUES
(90, 2000000, '2025-01-01', 'Farmaceutico', 90);

INSERT INTO pacientes VALUES
(90, '1996-01-01', 'Calle 90 #1', 'Ninguna', 90);

-- tipo_documento fuera del dominio
INSERT INTO personas VALUES
(91, 'Pedro Diaz', 'XX', '1000000091', '3005555555', 'pedro@email.com', 25, 'M');

-- (tipo_documento, documento) duplicado (UNIQUE)
INSERT INTO personas VALUES
(93, 'Persona Duplicada', 'CC', '1000000090', '3005555593', 'dup@email.com', 25, 'F');

-- cargo fuera del dominio
INSERT INTO empleados VALUES
(91, 2000000, '2025-01-01', 'Inexistente', 92);

-- estado fuera del dominio
INSERT INTO suministros VALUES
(90, '2026-09-25', 50, 'Inexistente', 90, 90);

-- metodo_pago fuera del dominio
INSERT INTO ventas VALUES
(90, '2026-09-25', 10000, 'Bitcoin', 90, 90, 90);

-- nit duplicado (UNIQUE)
INSERT INTO proveedores VALUES
(91, 'Proveedor X', '900900900-0', '3009999999', 'Calle 99');


-- XPoblar

INSERT INTO proveedores VALUES
(80, 'Proveedor Temporal', '900800800-0', '3000000080', 'Calle 80');

INSERT INTO farmacias VALUES
(80, 'Farmacia Temporal', 'Calle 80', '3100000080');

INSERT INTO personas VALUES
(80, 'Persona Temporal', 'CC', '1000000080', '3000000080', 'temporal@email.com', 40, 'F');

INSERT INTO empleados VALUES
(80, 2000000, '2025-01-01', 'Administrador', 80);

INSERT INTO pacientes VALUES
(80, '1986-01-01', 'Calle 80 #1', 'Ninguna', 80);

INSERT INTO administradores VALUES
(80);

INSERT INTO suministros VALUES
(80, '2026-09-01', 10, 'Recibido', 80, 80);

INSERT INTO inventarios VALUES
(80, '2026-09-20', 80);

INSERT INTO medicamentos VALUES
(80, 'Medicamento Temporal', 1000.00, 'Analgesico', 'Oral');

INSERT INTO lotes VALUES
(80, '2027-12-31', 10, 80, 80);

INSERT INTO suministros_medicamentos VALUES
(80, 80, 10, 800.00);

INSERT INTO ventas VALUES
(80, '2026-09-20', 1000, 'Efectivo', 80, 80, 80);

INSERT INTO ventas_medicamentos VALUES
(80, 80, 1, 1000.00);

DELETE FROM ventas_medicamentos
WHERE id_venta = 80;

DELETE FROM ventas
WHERE id_venta = 80;

DELETE FROM suministros_medicamentos
WHERE id_suministro = 80;

DELETE FROM lotes
WHERE id_lote = 80;

DELETE FROM suministros
WHERE id_suministro = 80;

DELETE FROM inventarios
WHERE id_inventario = 80;

DELETE FROM administradores
WHERE id_admin = 80;

DELETE FROM empleados
WHERE id_empleado = 80;

DELETE FROM pacientes
WHERE id_paciente = 80;

DELETE FROM personas
WHERE id_persona = 80;

DELETE FROM medicamentos
WHERE id_medicamento = 80;

DELETE FROM farmacias
WHERE id_farmacia = 80;

DELETE FROM proveedores
WHERE id_proveedor = 80;


-- XTABLAS

-- DROP TABLE IF EXISTS ventas_medicamentos;
-- DROP TABLE IF EXISTS ventas;
-- DROP TABLE IF EXISTS suministros_medicamentos;
-- DROP TABLE IF EXISTS lotes;
-- DROP TABLE IF EXISTS medicamentos;
-- DROP TABLE IF EXISTS inventarios;
-- DROP TABLE IF EXISTS suministros;
-- DROP TABLE IF EXISTS administradores;
-- DROP TABLE IF EXISTS pacientes;
-- DROP TABLE IF EXISTS empleados;
-- DROP TABLE IF EXISTS personas;
-- DROP TABLE IF EXISTS farmacias;
-- DROP TABLE IF EXISTS proveedores;

-- CONSULTAS

-- ADMIN

-- Ver el inventario de medicamentos

SELECT f.nombre AS farmacia, m.nombre, m.tipo_medicamento, l.cant_dispo

FROM lotes l
JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
JOIN farmacias f ON f.id_farmacia = l.id_farmacia

ORDER BY f.nombre, m.nombre;


-- Medicamentos que ya estan por vencerse

SELECT m.nombre, l.id_lote, l.fecha_ven, l.cant_dispo,
CASE WHEN l.fecha_ven < CURRENT_DATE THEN 'Vencido' ELSE 'Por vencer' END AS estado

FROM lotes l
JOIN medicamentos m ON m.id_medicamento = l.id_medicamento

WHERE l.fecha_ven <= CURRENT_DATE + INTERVAL '30 days'

ORDER BY l.fecha_ven;


-- Medicamentos registrados recientemente

SELECT id_medicamento, nombre, tipo_medicamento, precio_unitario
FROM medicamentos
ORDER BY id_medicamento DESC
LIMIT 10;



--EMPLEADO
-- Saber si hay stock de un medicamento

SELECT f.nombre AS farmacia, m.nombre, l.cant_dispo, l.fecha_ven

FROM medicamentos m
JOIN lotes l ON l.id_medicamento = m.id_medicamento
JOIN farmacias f ON f.id_farmacia = l.id_farmacia

WHERE m.id_medicamento = 2
AND l.cant_dispo > 0
AND l.fecha_ven >= CURRENT_DATE;


-- Registrar que llegaron medicamentos nuevos

INSERT INTO lotes
VALUES (4, '2027-12-31', 100, 3, 3);

UPDATE suministros

SET estado = 'Recibido'

WHERE id_suministro = 3;


--Registrar que se vendieron medicamentos

INSERT INTO ventas
VALUES (4, CURRENT_DATE, 12000, 'Efectivo', 2, 2, 2);

INSERT INTO ventas_medicamentos
VALUES (4, 2, 1, 12000.00);



--PROVEEDOR
--Cuanto stock hay de cada medicamento

SELECT m.id_medicamento, m.nombre, COALESCE(SUM(l.cant_dispo), 0) AS stock_total

FROM medicamentos m
LEFT JOIN lotes l ON l.id_medicamento = m.id_medicamento
                AND l.fecha_ven >= CURRENT_DATE

GROUP BY m.id_medicamento, m.nombre

ORDER BY m.nombre;


--Medicamentos con poco stock

SELECT m.id_medicamento, m.nombre, COALESCE(SUM(l.cant_dispo), 0) AS stock_total

FROM medicamentos m
LEFT JOIN lotes l ON l.id_medicamento = m.id_medicamento AND l.fecha_ven >= CURRENT_DATE
GROUP BY m.id_medicamento, m.nombre
HAVING COALESCE(SUM(l.cant_dispo), 0) <= 30
ORDER BY stock_total;

--Historial de suministros de un proveedor

SELECT id_suministro, fecha, cantidad, estado
FROM suministros
WHERE id_proveedor = 1
ORDER BY fecha DESC;


-- PACIENTE

SELECT id_venta, fecha, total, metodo_pago
FROM ventas
WHERE id_paciente = 1
ORDER BY fecha DESC;



-- operativas

-- ADMIN
-- VENTAS DEL MES Y METODO DE PAGO

SELECT f.nombre AS farmacia, v.metodo_pago, COUNT(*) AS num_ventas, SUM(v.total) AS total_vendido
FROM ventas v
JOIN farmacias f ON f.id_farmacia = v.id_farmacia
WHERE date_trunc('month', v.fecha) = date_trunc('month', CURRENT_DATE)
GROUP BY f.nombre, v.metodo_pago
ORDER BY f.nombre, total_vendido DESC;

-- MEDICAMENTOS MAS VENDIDOS

SELECT m.nombre, SUM(vm.cantidad) AS unidades,SUM(vm.cantidad * vm.precio_unitario) AS ingresos
FROM ventas_medicamentos vm
JOIN medicamentos m ON m.id_medicamento = vm.id_medicamento
GROUP BY m.id_medicamento, m.nombre
ORDER BY unidades DESC;

-- VENTAS X EMPLEADO

SELECT p.nombre, e.cargo, COUNT(v.id_venta) AS num_ventas,COALESCE(SUM(v.total), 0) AS total_vendido
FROM empleados e
JOIN personas p ON p.id_persona = e.id_persona
LEFT JOIN ventas v ON v.id_empleado = e.id_empleado
GROUP BY e.id_empleado, p.nombre, e.cargo
ORDER BY total_vendido DESC;


-- EMPLEADO

-- medicamentos vencidos

SELECT l.id_lote, l.fecha_ven, l.cant_dispo,m.nombre,m.tipo_medicamento
FROM lotes l
JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
WHERE l.id_medicamento = 2
    AND l.id_farmacia = 2
    AND l.cant_dispo > 0
    AND l.fecha_ven < CURRENT_DATE
ORDER BY l.fecha_ven;


-- Detalle de una venta

SELECT m.nombre, vm.cantidad, vm.precio_unitario,
       vm.cantidad * vm.precio_unitario AS subtotal
FROM ventas_medicamentos vm
JOIN medicamentos m ON m.id_medicamento = vm.id_medicamento
WHERE vm.id_venta = 1;

-- PACIENTE

-- HISTORIAL

SELECT v.fecha, f.nombre AS farmacia, m.nombre AS medicamento,
        vm.cantidad, vm.precio_unitario
FROM ventas v
JOIN ventas_medicamentos vm ON vm.id_venta = v.id_venta
JOIN medicamentos m ON m.id_medicamento = vm.id_medicamento
JOIN farmacias f ON f.id_farmacia = v.id_farmacia
WHERE v.id_paciente = 1
ORDER BY v.fecha DESC;

-- DONDE HAY UN MEDICAMENTO DISPONIBLE

SELECT f.nombre AS farmacia, m.nombre, m.precio_unitario, SUM(l.cant_dispo) AS disponible
FROM medicamentos m
JOIN lotes l ON l.id_medicamento = m.id_medicamento
JOIN farmacias f ON f.id_farmacia = l.id_farmacia
WHERE m.nombre ILIKE '%acetaminofen%' AND l.cant_dispo > 0 AND l.fecha_ven >= CURRENT_DATE
GROUP BY f.nombre, m.nombre, m.precio_unitario;


-- PROVEEDOR

-- CONSULTAR LA CANTIDAD DE MEDICAMENTOS SUMINISTRADOS POR UN PROVEEDOR

SELECT s.id_suministro, s.fecha, m.nombre, sm.cantidad_med,sm.precio_suministro,
       sm.cantidad_med * sm.precio_suministro AS subtotal
FROM suministros s
JOIN suministros_medicamentos sm ON sm.id_suministro = s.id_suministro
JOIN medicamentos m ON m.id_medicamento = sm.id_medicamento
WHERE s.id_proveedor = 1
ORDER BY s.fecha DESC;

-- Valor total suministrado por estado

SELECT s.estado, COUNT(DISTINCT s.id_suministro) AS num_suministros,
       SUM(sm.cantidad_med * sm.precio_suministro) AS valor_total
FROM suministros s
JOIN suministros_medicamentos sm ON sm.id_suministro = s.id_suministro
WHERE s.id_proveedor = 1
GROUP BY s.estado;

-- Pedidos pendientes y farmacia de destino

SELECT s.id_suministro, s.fecha, f.nombre AS farmacia_destino, s.cantidad
FROM suministros s
JOIN farmacias f ON f.id_farmacia = s.id_farmacia
WHERE s.id_proveedor = 3 AND s.estado = 'Pendiente'
ORDER BY s.fecha;