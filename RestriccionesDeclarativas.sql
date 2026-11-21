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