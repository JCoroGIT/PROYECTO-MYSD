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

-- TUPLAS

ALTER TABLE suministros_medicamentos
ADD CONSTRAINT ck_suministro_medicamento_cantidad_precio
CHECK (cantidad_med > 0 AND precio_suministro > 0);

ALTER TABLE ventas_medicamentos
ADD CONSTRAINT ck_venta_medicamento_cantidad_precio
CHECK (cantidad > 0 AND precio_unitario > 0);

ALTER TABLE empleados
ADD CONSTRAINT ck_empleado_salario_fecha
CHECK (salario > 0 AND fecha_contratacion <= CURRENT_DATE);

ALTER TABLE ventas
ADD CONSTRAINT ck_venta_total_metodo
CHECK (total >= 0 AND metodo_pago IS NOT NULL);

ALTER TABLE lotes
ADD CONSTRAINT ck_lote_cant_dispo
CHECK (cant_dispo >= 0);

ALTER TABLE medicamentos
ADD CONSTRAINT ck_medicamento_precio
CHECK (precio_unitario > 0);

ALTER TABLE personas
ADD CONSTRAINT ck_persona_edad
CHECK (edad > 0);

-- TUPLASOK

INSERT INTO proveedores
VALUES (100, 'Proveedor Tuplas', '900100100-0', '3000000100', 'Calle 100');

INSERT INTO farmacias
VALUES (100, 'Farmacia Tuplas', 'Calle 100', '3100000100');

INSERT INTO personas VALUES
(100, 'Persona Cien', 'CC', '1000000100', '3000000100', 'p100@email.com', 30, 'M'),
(101, 'Persona Ciento Uno', 'CC', '1000000101', '3000000101', 'p101@email.com', 31, 'F'),
(102, 'Persona Ciento Dos', 'CC', '1000000102', '3000000102', 'p102@email.com', 32, 'O');

INSERT INTO medicamentos VALUES
(100, 'Medicamento Cien', 5000.00, 'Analgesico', 'Oral'),
(101, 'Medicamento Ciento Uno', 12000.00, 'Antibiotico', 'Oral'),
(102, 'Medicamento Ciento Dos', 8000.00, 'Antialergico', 'Oral');

INSERT INTO suministros
VALUES (100, '2026-09-01', 175, 'Pendiente', 100, 100);

INSERT INTO suministros_medicamentos
VALUES (100, 100, 50, 3500.00);

INSERT INTO suministros_medicamentos
VALUES (100, 101, 100, 8000.00);

INSERT INTO suministros_medicamentos
VALUES (100, 102, 25, 5000.00);



INSERT INTO empleados
VALUES (100, 2500000, '2025-01-10', 'Administrador', 100);

INSERT INTO empleados
VALUES (101, 2200000, '2026-01-15', 'Farmaceutico', 101);

INSERT INTO empleados
VALUES (102, 3000000, '2026-05-20', 'Farmaceutico', 102);



INSERT INTO ventas
VALUES (100, '2026-09-20', 15000, 'Efectivo', 100, NULL, 100);

INSERT INTO ventas
VALUES (101, '2026-09-21', 24000, 'Tarjeta', 100, NULL, 101);

INSERT INTO ventas
VALUES (102, '2026-09-22', 8000, 'Transferencia', 100, NULL, 102);



INSERT INTO ventas_medicamentos
VALUES (100, 100, 3, 5000.00);

INSERT INTO ventas_medicamentos
VALUES (101, 101, 2, 12000.00);

INSERT INTO ventas_medicamentos
VALUES (102, 102, 1, 8000.00);



INSERT INTO lotes
VALUES (100, '2027-12-31', 0, 100, 100);

INSERT INTO lotes
VALUES (101, '2027-12-31', 50, 100, 100);



-- TUPLASNOOK

INSERT INTO proveedores
VALUES (110, 'Proveedor Nook', '900110110-0', '3000000110', 'Calle 110');

INSERT INTO farmacias
VALUES (110, 'Farmacia Nook', 'Calle 110', '3100000110');

INSERT INTO personas VALUES
(110, 'Persona Nook Uno', 'CC', '1000000110', '3000000110', 'p110@email.com', 30, 'M'),
(111, 'Persona Nook Dos', 'CC', '1000000111', '3000000111', 'p111@email.com', 30, 'M'),
(112, 'Persona Nook Tres', 'CC', '1000000112', '3000000112', 'p112@email.com', 30, 'M'),
(113, 'Persona Nook Cuatro', 'CC', '1000000113', '3000000113', 'p113@email.com', 30, 'M');

INSERT INTO medicamentos
VALUES (110, 'Medicamento Nook', 5000.00, 'Analgesico', 'Oral');

INSERT INTO empleados
VALUES (110, 2500000, '2025-01-10', 'Farmaceutico', 110);

INSERT INTO suministros
VALUES (110, '2026-09-01', 50, 'Pendiente', 110, 110);

INSERT INTO ventas
VALUES (110, '2026-09-20', 15000, 'Efectivo', 110, NULL, 110);

-- cantidad_med y precio_suministro deben ser mayores que 0
INSERT INTO suministros_medicamentos
VALUES (110, 110, 0, 3500.00);

INSERT INTO suministros_medicamentos
VALUES (110, 110, 100, 0);

INSERT INTO suministros_medicamentos
VALUES (110, 110, -10, -5000.00);

-- cantidad y precio_unitario deben ser mayores que 0.

INSERT INTO ventas_medicamentos
VALUES (110, 110, 0, 5000.00);

INSERT INTO ventas_medicamentos
VALUES (110, 110, 2, 0);

INSERT INTO ventas_medicamentos
VALUES (110, 110, -5, -8000.00);

-- salario debe ser mayor que 0 y fecha_contratacion no puede ser futura

INSERT INTO empleados
VALUES (111, 0, '2025-01-10', 'Administrador', 111);

INSERT INTO empleados
VALUES (112, -500000, '2026-01-15', 'Farmaceutico', 112);

INSERT INTO empleados
VALUES (113, 3000000, '2099-01-01', 'Farmaceutico', 113);

-- total no puede ser negativo y metodo_pago no puede ser nulo

INSERT INTO ventas
VALUES (111, '2026-09-20', -15000, 'Efectivo', 110, NULL, 110);

INSERT INTO ventas
VALUES (112, '2026-09-21', 24000, NULL, 110, NULL, 110);

INSERT INTO ventas
VALUES (113, '2026-09-22', -8000, NULL, 110, NULL, 110);

-- cant_dispo no puede ser negativa

INSERT INTO lotes
VALUES (110, '2027-12-31', -5, 110, 110);

-- precio_unitario del medicamento debe ser mayor que 0

INSERT INTO medicamentos
VALUES (111, 'Medicamento Gratis', 0, 'Analgesico', 'Oral');

INSERT INTO medicamentos
VALUES (112, 'Medicamento Negativo', -100.00, 'Analgesico', 'Oral');

-- edad debe ser mayor que 0

INSERT INTO personas
VALUES (114, 'Persona Cero', 'CC', '1000000114', '3000000114', 'p114@email.com', 0, 'M');

INSERT INTO personas
VALUES (115, 'Persona Negativa', 'CC', '1000000115', '3000000115', 'p115@email.com', -5, 'F');


-- ACCIONES

ALTER TABLE empleados
ADD CONSTRAINT fk_empleado_persona
    FOREIGN KEY (id_persona) REFERENCES personas(id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE pacientes
ADD CONSTRAINT fk_paciente_persona
    FOREIGN KEY (id_persona) REFERENCES personas(id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE administradores
ADD CONSTRAINT fk_administrador_empleado
    FOREIGN KEY (id_admin) REFERENCES empleados(id_empleado)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE inventarios
ADD CONSTRAINT fk_inventario_farmacia
    FOREIGN KEY (id_farmacia) REFERENCES farmacias(id_farmacia)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE lotes
ADD CONSTRAINT fk_lote_farmacia
    FOREIGN KEY (id_farmacia) REFERENCES farmacias(id_farmacia)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE suministros
ADD CONSTRAINT fk_suministro_farmacia
    FOREIGN KEY (id_farmacia) REFERENCES farmacias(id_farmacia)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE suministros_medicamentos
ADD CONSTRAINT fk_sm_suministro
    FOREIGN KEY (id_suministro) REFERENCES suministros(id_suministro)
    ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_sm_medicamento
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE ventas
ADD CONSTRAINT fk_venta_farmacia
    FOREIGN KEY (id_farmacia) REFERENCES farmacias(id_farmacia)
    ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT fk_venta_paciente
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente)
    ON DELETE SET NULL ON UPDATE CASCADE,
ADD CONSTRAINT fk_venta_empleado
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE ventas_medicamentos
ADD CONSTRAINT fk_vm_venta
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
    ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_vm_medicamento
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
    ON DELETE RESTRICT ON UPDATE CASCADE;
-- ACCIONESOK


INSERT INTO proveedores VALUES (300, 'Proveedor Cascada', '900300300-0', '3000000300', 'Calle 300');

INSERT INTO farmacias VALUES (300, 'Farmacia Cascada', 'Calle 300', '3100000300');

INSERT INTO personas VALUES
(300, 'Persona Cajero', 'CC', '1000000300', '3000000300', 'p300@email.com', 30, 'M'),
(301, 'Persona Paciente', 'CC', '1000000301', '3000000301', 'p301@email.com', 30, 'F'),
(302, 'Persona Admin', 'CC', '1000000302', '3000000302', 'p302@email.com', 30, 'M');

INSERT INTO empleados VALUES
(300, 2000000, '2025-01-10', 'Cajero', 300),
(301, 2500000, '2025-01-10', 'Administrador', 302);

INSERT INTO administradores VALUES (301);

INSERT INTO pacientes VALUES (300, '1996-01-01', 'Calle 300 #1', 'Ninguna', 301);

INSERT INTO inventarios VALUES (300, '2026-09-20', 300);

INSERT INTO medicamentos VALUES (300, 'Medicamento Cascada', 5000.00, 'Analgesico', 'Oral');

INSERT INTO lotes VALUES (300, '2027-12-31', 50, 300, 300);

INSERT INTO suministros VALUES (300, '2026-09-01', 50, 'Pendiente', 300, 300);

INSERT INTO suministros_medicamentos VALUES (300, 300, 50, 3500.00);

INSERT INTO ventas VALUES (300, '2026-09-20', 10000, 'Efectivo', 300, 300, 300);

INSERT INTO ventas_medicamentos VALUES (300, 300, 2, 5000.00);


-- al cambiar el id de la persona, empleado y paciente la siguen
UPDATE personas SET id_persona = 310 WHERE id_persona = 300;
UPDATE personas SET id_persona = 311 WHERE id_persona = 301;

-- debe devolver id_persona = 310 y 311
SELECT id_empleado AS id, id_persona FROM empleados WHERE id_empleado = 300
UNION ALL
SELECT id_paciente, id_persona FROM pacientes WHERE id_paciente = 300;

-- al cambiar el id del empleado, administrador y venta lo siguen
UPDATE empleados SET id_empleado = 305 WHERE id_empleado = 300;
UPDATE empleados SET id_empleado = 306 WHERE id_empleado = 301;

-- debe devolver id_empleado = 305 y id_admin = 306
SELECT id_empleado AS id FROM ventas WHERE id_venta = 300
UNION ALL
SELECT id_admin FROM administradores WHERE id_admin = 306;

-- al cambiar el id del paciente, la venta lo sigue
UPDATE pacientes SET id_paciente = 310 WHERE id_paciente = 300;

-- debe devolver id_paciente = 310
SELECT id_venta, id_paciente FROM ventas WHERE id_venta = 300;

-- al cambiar el id del medicamento, lote y detalles lo siguen
UPDATE medicamentos SET id_medicamento = 310 WHERE id_medicamento = 300;

-- debe devolver 310 en las tres columnas
SELECT l.id_medicamento AS lote, vm.id_medicamento AS venta_med, sm.id_medicamento AS sum_med
FROM lotes l, ventas_medicamentos vm, suministros_medicamentos sm
WHERE l.id_lote = 300 AND vm.id_venta = 300 AND sm.id_suministro = 300;

-- al cambiar el id de la farmacia, inventario, lote, suministro y venta la siguen
UPDATE farmacias SET id_farmacia = 310 WHERE id_farmacia = 300;

-- debe devolver 310 en las cuatro columnas
SELECT i.id_farmacia AS inventario, l.id_farmacia AS lote, s.id_farmacia AS suministro, v.id_farmacia AS venta
FROM inventarios i, lotes l, suministros s, ventas v
WHERE i.id_inventario = 300 AND l.id_lote = 300 AND s.id_suministro = 300 AND v.id_venta = 300;

-- al cambiar el id de la venta, su detalle lo sigue
UPDATE ventas SET id_venta = 310 WHERE id_venta = 300;

-- debe devolver id_venta = 310
SELECT id_venta, id_medicamento FROM ventas_medicamentos WHERE id_venta = 310;

-- al cambiar el id del suministro, su detalle lo sigue
UPDATE suministros SET id_suministro = 310 WHERE id_suministro = 300;

-- debe devolver id_suministro = 310
SELECT id_suministro, id_medicamento FROM suministros_medicamentos WHERE id_suministro = 310;


-- al borrar el paciente, la venta se conserva con id_paciente NULL
DELETE FROM pacientes WHERE id_paciente = 310;

-- debe devolver la venta 310 con id_paciente NULL
SELECT id_venta, id_paciente FROM ventas WHERE id_venta = 310;

-- al borrar la venta, se borra su detalle
DELETE FROM ventas WHERE id_venta = 310;

-- debe devolver 0 filas
SELECT * FROM ventas_medicamentos WHERE id_venta = 310;

-- al borrar el suministro, se borra su detalle
DELETE FROM suministros WHERE id_suministro = 310;

-- debe devolver 0 filas
SELECT * FROM suministros_medicamentos WHERE id_suministro = 310;

-- al borrar el empleado administrador, se borra su registro en administrador
DELETE FROM empleados WHERE id_empleado = 306;

-- debe devolver 0 filas
SELECT * FROM administradores WHERE id_admin = 306;

-- al borrar la farmacia sin ventas ni suministros, se borran su inventario y sus lotes
DELETE FROM farmacias WHERE id_farmacia = 310;

-- debe devolver 0 filas
SELECT id_inventario AS id FROM inventarios WHERE id_farmacia = 310
UNION ALL
SELECT id_lote FROM lote WHERE id_farmacia = 310;

-- ACCIONESNOOK


INSERT INTO proveedores VALUES (400, 'Proveedor Restrict 2', '900400400-0', '3000000400', 'Calle 400');

INSERT INTO farmacias VALUES
(400, 'Farmacia Con Suministro', 'Calle 400', '3100000400'),
(401, 'Farmacia Con Venta', 'Calle 401', '3100000401');

INSERT INTO personas VALUES
(400, 'Persona Empleado', 'CC', '1000000400', '3000000400', 'p400@email.com', 30, 'M'),
(401, 'Persona Paciente', 'CC', '1000000401', '3000000401', 'p401@email.com', 30, 'F');

INSERT INTO empleados VALUES (400, 2000000, '2025-01-10', 'Cajero', 400);

INSERT INTO pacientes VALUES (400, '1996-01-01', 'Calle 400 #1', 'Ninguna', 401);

INSERT INTO medicamentos VALUES
(400, 'Medicamento En Venta', 5000.00, 'Analgesico', 'Oral'),
(401, 'Medicamento En Suministro', 8000.00, 'Antialergico', 'Oral');

INSERT INTO suministros VALUES (400, '2026-09-01', 50, 'Pendiente', 400, 400);

INSERT INTO suministros_medicamentos VALUES (400, 401, 50, 6000.00);

INSERT INTO ventas VALUES (400, '2026-09-20', 10000, 'Efectivo', 401, 400, 400);

INSERT INTO ventas_medicamentos VALUES (400, 400, 2, 5000.00);


-- no se puede borrar una persona que es empleado
DELETE FROM personas WHERE id_persona = 400;

-- no se puede borrar una persona que es paciente
DELETE FROM personas WHERE id_persona = 401;

-- no se puede borrar una farmacia que tiene suministros
DELETE FROM farmacias WHERE id_farmacia = 400;

-- no se puede borrar una farmacia que tiene ventas
DELETE FROM farmacias WHERE id_farmacia = 401;

-- no se puede borrar un empleado que registró ventas
DELETE FROM empleados WHERE id_empleado = 400;

-- no se puede borrar un medicamento que tiene ventas
DELETE FROM medicamentos WHERE id_medicamento = 400;

-- no se puede borrar un medicamento que tiene suministros
DELETE FROM medicamentos WHERE id_medicamento = 401;

-- DISARADORES

-- Mantener empleado

CREATE OR REPLACE FUNCTION fn_sincronizar_administrador() RETURNS trigger AS $$
BEGIN
    IF NEW.cargo = 'Administrador' THEN
        INSERT INTO administradores VALUES (NEW.id_empleado) ON CONFLICT DO NOTHING;
    ELSE
        DELETE FROM administradores WHERE id_admin = NEW.id_empleado;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sincronizar_administrador
AFTER INSERT OR UPDATE OF cargo ON empleados
FOR EACH ROW EXECUTE FUNCTION fn_sincronizar_administrador();


CREATE OR REPLACE FUNCTION fn_limpiar_administrador() RETURNS trigger AS $$
BEGIN
    DELETE FROM administradores WHERE id_admin = OLD.id_empleado;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limpiar_administrador
BEFORE DELETE ON empleados
FOR EACH ROW EXECUTE FUNCTION fn_limpiar_administrador();


-- Mantener farmacia

CREATE OR REPLACE FUNCTION fn_crear_inventario() RETURNS trigger AS $$
BEGIN
    INSERT INTO inventarios VALUES (NEW.id_farmacia, CURRENT_DATE, NEW.id_farmacia)
    ON CONFLICT DO NOTHING;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_crear_inventario
AFTER INSERT ON farmacias
FOR EACH ROW EXECUTE FUNCTION fn_crear_inventario();


CREATE OR REPLACE FUNCTION fn_validar_baja_farmacia() RETURNS trigger AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM lotes WHERE id_farmacia = OLD.id_farmacia AND cant_dispo > 0) THEN
        RAISE EXCEPTION 'No se puede eliminar la farmacia % porque aun tiene stock', OLD.id_farmacia;
    END IF;
    DELETE FROM inventarios WHERE id_farmacia = OLD.id_farmacia;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_baja_farmacia
BEFORE DELETE ON farmacias
FOR EACH ROW EXECUTE FUNCTION fn_validar_baja_farmacia();


-- Mantener proveedor

CREATE OR REPLACE FUNCTION fn_validar_nit() RETURNS trigger AS $$
BEGIN
    IF NEW.nit IS NOT NULL AND NEW.nit !~ '^[0-9]{9}-[0-9]$' THEN
        RAISE EXCEPTION 'El NIT % no tiene el formato 000000000-0', NEW.nit;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_nit
BEFORE INSERT OR UPDATE OF nit ON proveedores
FOR EACH ROW EXECUTE FUNCTION fn_validar_nit();


-- Mantener medicamento

CREATE OR REPLACE FUNCTION fn_validar_nombre_medicamento() RETURNS trigger AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM medicamentos
        WHERE lower(trim(nombre)) = lower(trim(NEW.nombre))
            AND id_medicamento <> NEW.id_medicamento) THEN
        RAISE EXCEPTION 'Ya existe un medicamento con el nombre %', NEW.nombre;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_nombre_medicamento
BEFORE INSERT OR UPDATE OF nombre ON medicamentos
FOR EACH ROW EXECUTE FUNCTION fn_validar_nombre_medicamento();


-- Mantener inventario

CREATE OR REPLACE FUNCTION fn_actualizar_inventario() RETURNS trigger AS $$
DECLARE
    v_farmacia integer;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_farmacia := OLD.id_farmacia;
    ELSE
        v_farmacia := NEW.id_farmacia;
    END IF;
    UPDATE inventarios SET fecha_actualizacion = CURRENT_DATE
    WHERE id_farmacia = v_farmacia;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_inventario
AFTER INSERT OR UPDATE OR DELETE ON lotes
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_inventario();



-- *EMPLEADO*


-- Registrar venta

CREATE OR REPLACE FUNCTION fn_validar_cargo_venta() RETURNS trigger AS $$
DECLARE
    v_cargo TCargo;
BEGIN
    SELECT cargo INTO v_cargo FROM empleados WHERE id_empleado = NEW.id_empleado;
    IF v_cargo IS NULL OR v_cargo NOT IN ('Farmaceutico', 'Cajero') THEN
        RAISE EXCEPTION 'El empleado % no tiene un cargo autorizado para registrar ventas', NEW.id_empleado;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_cargo_venta
BEFORE INSERT ON ventas
FOR EACH ROW EXECUTE FUNCTION fn_validar_cargo_venta();


CREATE OR REPLACE FUNCTION fn_verificar_stock() RETURNS trigger AS $$
DECLARE
    v_farmacia integer;
    v_disponible integer;
BEGIN
    SELECT id_farmacia INTO v_farmacia FROM ventas WHERE id_venta = NEW.id_venta;

    SELECT COALESCE(SUM(cant_dispo), 0) INTO v_disponible
    FROM lotes
    WHERE id_medicamento = NEW.id_medicamento
        AND id_farmacia = v_farmacia
        AND fecha_ven >= CURRENT_DATE;

    IF v_disponible < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente del medicamento % en la farmacia % (disponible: %, solicitado: %)',
            NEW.id_medicamento, v_farmacia, v_disponible, NEW.cantidad;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_stock
BEFORE INSERT ON ventas_medicamentos
FOR EACH ROW EXECUTE FUNCTION fn_verificar_stock();


CREATE OR REPLACE FUNCTION fn_descontar_stock() RETURNS trigger AS $$
DECLARE
    v_farmacia integer;
    v_pendiente integer := NEW.cantidad;
    v_tomar integer;
    r record;
BEGIN
    SELECT id_farmacia INTO v_farmacia FROM ventas WHERE id_venta = NEW.id_venta;

    FOR r IN
        SELECT id_lote, cant_dispo
        FROM lotes
        WHERE id_medicamento = NEW.id_medicamento
            AND id_farmacia = v_farmacia
            AND cant_dispo > 0
            AND fecha_ven >= CURRENT_DATE
        ORDER BY fecha_ven
        FOR UPDATE
    LOOP
        EXIT WHEN v_pendiente = 0;
        v_tomar := LEAST(r.cant_dispo, v_pendiente);
        UPDATE lotes SET cant_dispo = cant_dispo - v_tomar WHERE id_lote = r.id_lote;
        v_pendiente := v_pendiente - v_tomar;
    END LOOP;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON ventas_medicamentos
FOR EACH ROW EXECUTE FUNCTION fn_descontar_stock();

-- Registrar venta: el total sale del detalle

CREATE OR REPLACE FUNCTION fn_actualizar_total_venta() RETURNS trigger AS $$
DECLARE
    v_venta integer;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_venta := OLD.id_venta;
    ELSE
        v_venta := NEW.id_venta;
    END IF;

    UPDATE ventas
    SET total = (SELECT COALESCE(SUM(cantidad * precio_unitario), 0)
                FROM ventas_medicamentos WHERE id_venta = v_venta)
    WHERE id_venta = v_venta;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_total_venta
AFTER INSERT OR UPDATE OR DELETE ON ventas_medicamentos
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_total_venta();


CREATE OR REPLACE FUNCTION fn_validar_total_venta() RETURNS trigger AS $$
DECLARE
    v_suma numeric;
BEGIN
    SELECT COALESCE(SUM(cantidad * precio_unitario), 0) INTO v_suma
    FROM ventas_medicamentos
    WHERE id_venta = NEW.id_venta;

    IF NEW.total <> v_suma THEN
        RAISE EXCEPTION 'El total % de la venta % no coincide con su detalle (%)', NEW.total, NEW.id_venta, v_suma;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_total_venta
BEFORE UPDATE OF total ON ventas
FOR EACH ROW EXECUTE FUNCTION fn_validar_total_venta();


-- Registrar lote

CREATE OR REPLACE FUNCTION fn_validar_vencimiento_lote() RETURNS trigger AS $$
BEGIN
    IF NEW.fecha_ven <= CURRENT_DATE THEN
        RAISE EXCEPTION 'No se puede registrar un lote vencido (fecha_ven = %)', NEW.fecha_ven;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_vencimiento_lote
BEFORE INSERT OR UPDATE OF fecha_ven ON lotes
FOR EACH ROW EXECUTE FUNCTION fn_validar_vencimiento_lote();


-- Mantener suministro

CREATE OR REPLACE FUNCTION fn_validar_estado_suministro() RETURNS trigger AS $$
BEGIN
    IF OLD.estado IN ('Recibido', 'Cancelado') AND NEW.estado <> OLD.estado THEN
        RAISE EXCEPTION 'El suministro % ya esta % y no puede cambiar de estado', OLD.id_suministro, OLD.estado;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_estado_suministro
BEFORE UPDATE OF estado ON suministros
FOR EACH ROW EXECUTE FUNCTION fn_validar_estado_suministro();


-- Mantener paciente

CREATE OR REPLACE FUNCTION fn_validar_fecha_nacimiento() RETURNS trigger AS $$
DECLARE
    v_edad integer;
BEGIN
    IF NEW.fecha_nac IS NULL THEN
        RETURN NEW;
    END IF;

    IF NEW.fecha_nac > CURRENT_DATE THEN
        RAISE EXCEPTION 'La fecha de nacimiento % no puede ser futura', NEW.fecha_nac;
    END IF;

    SELECT edad INTO v_edad FROM personas WHERE id_persona = NEW.id_persona;

    IF v_edad IS DISTINCT FROM date_part('year', age(CURRENT_DATE, NEW.fecha_nac))::integer THEN
        RAISE EXCEPTION 'La fecha de nacimiento % no coincide con la edad registrada (%)', NEW.fecha_nac, v_edad;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_fecha_nacimiento
BEFORE INSERT OR UPDATE OF fecha_nac, id_persona ON pacientes
FOR EACH ROW EXECUTE FUNCTION fn_validar_fecha_nacimiento();

-- Registrar suministro

CREATE OR REPLACE FUNCTION fn_validar_estado_inicial() RETURNS trigger AS $$
BEGIN
    IF NEW.estado <> 'Pendiente' THEN
        RAISE EXCEPTION 'Todo suministro nuevo debe registrarse como Pendiente';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_estado_inicial
BEFORE INSERT ON suministros
FOR EACH ROW EXECUTE FUNCTION fn_validar_estado_inicial();


-- Mantener suministro_medicamento

CREATE OR REPLACE FUNCTION fn_actualizar_cantidad_suministro() RETURNS trigger AS $$
DECLARE
    v_suministro integer;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_suministro := OLD.id_suministro;
    ELSE
        v_suministro := NEW.id_suministro;
    END IF;

    UPDATE suministros
    SET cantidad = (SELECT COALESCE(SUM(cantidad_med), 0)
                    FROM suministros_medicamentos
                    WHERE id_suministro = v_suministro)
    WHERE id_suministro = v_suministro;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_cantidad_suministro
AFTER INSERT OR UPDATE OR DELETE ON suministros_medicamentos
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_cantidad_suministro();

-- DISPARADORESOK


INSERT INTO farmacia VALUES (800, 'Farmacia Total', 'Calle 800', '3100000800');

INSERT INTO persona VALUES (800, 'Persona Total', 'CC', '1000000800', '3000000800', 'p800@email.com', 30, 'M');

INSERT INTO empleado VALUES (800, 2000000, '2025-01-10', 'Farmaceutico', 800);

INSERT INTO medicamento VALUES
(800, 'Medicamento Total Uno', 5000.00, 'Analgesico', 'Oral'),
(801, 'Medicamento Total Dos', 8000.00, 'Antialergico', 'Oral');

INSERT INTO lote VALUES
(800, '2027-12-31', 100, 800, 800),
(801, '2027-12-31', 100, 801, 800);

INSERT INTO venta VALUES (800, CURRENT_DATE, 0, 'Efectivo', 800, NULL, 800);

-- al agregar lineas, el total es la suma del detalle
INSERT INTO venta_medicamento VALUES (800, 800, 2, 5000.00);
INSERT INTO venta_medicamento VALUES (800, 801, 1, 8000.00);

-- debe devolver 18000
SELECT id_venta, total FROM venta WHERE id_venta = 800;

-- al cambiar una linea, el total se recalcula
UPDATE venta_medicamento SET cantidad = 3 WHERE id_venta = 800 AND id_medicamento = 800;

-- debe devolver 23000
SELECT id_venta, total FROM venta WHERE id_venta = 800;

-- al borrar una linea, el total se recalcula
DELETE FROM venta_medicamento WHERE id_venta = 800 AND id_medicamento = 801;

-- debe devolver 15000
SELECT id_venta, total FROM venta WHERE id_venta = 800;

-- al cambiar el id de la venta, el total se conserva
UPDATE venta SET id_venta = 810 WHERE id_venta = 800;

-- debe devolver 15000
SELECT id_venta, total FROM venta WHERE id_venta = 810;

-- una venta sin detalle conserva total 0
INSERT INTO venta VALUES (811, CURRENT_DATE, 0, 'Efectivo', 800, NULL, 800);

-- debe devolver 0
SELECT id_venta, total FROM venta WHERE id_venta = 811;

-- al borrar la venta, su detalle se borra sin error
DELETE FROM venta WHERE id_venta = 810;

-- debe devolver 0 filas
SELECT * FROM venta_medicamento WHERE id_venta = 810;

-- DISPARADORESNOOK

INSERT INTO venta VALUES (820, CURRENT_DATE, 0, 'Efectivo', 800, NULL, 800);

INSERT INTO venta_medicamento VALUES (820, 800, 2, 5000.00);

-- no se puede poner a mano un total distinto al del detalle
UPDATE venta SET total = 1 WHERE id_venta = 820;

-- no se puede poner un total a una venta sin detalle
UPDATE venta SET total = 5000 WHERE id_venta = 811;

-- debe seguir en 10000
SELECT id_venta, total FROM venta WHERE id_venta = 820;


