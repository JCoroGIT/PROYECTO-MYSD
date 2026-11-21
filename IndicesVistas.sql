-- INDICES


-- Registrar venta / Mantener lote: fn_verificar_stock y fn_descontar_stock filtran por farmacia, medicamento y vencimiento
CREATE INDEX idx_lotes_farmacia_medicamento_ven ON lotes (id_farmacia, id_medicamento, fecha_ven);

-- Medicamentos por vencerse
CREATE INDEX idx_lotes_fecha_ven ON lotes (fecha_ven);

-- Historial de compras de un paciente
CREATE INDEX idx_ventas_paciente_fecha ON ventas (id_paciente, fecha DESC);

-- Ventas del mes por farmacia
CREATE INDEX idx_ventas_farmacia_fecha ON ventas (id_farmacia, fecha);

-- Historial de suministros de un proveedor
CREATE INDEX idx_suministros_proveedor_fecha ON suministros (id_proveedor, fecha DESC);


-- VISTAS

-- Stock vigente por farmacia y medicamento
CREATE OR REPLACE VIEW v_inventario_farmacia AS
SELECT f.id_farmacia, f.nombre AS farmacia, m.id_medicamento, m.nombre AS medicamento, m.tipo_medicamento, SUM(l.cant_dispo) AS stock
FROM lotes l
JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
JOIN farmacias f ON f.id_farmacia = l.id_farmacia
WHERE l.fecha_ven >= CURRENT_DATE
GROUP BY f.id_farmacia, f.nombre, m.id_medicamento, m.nombre, m.tipo_medicamento;

-- Lotes vencidos o por vencer en 30 dias
CREATE OR REPLACE VIEW v_lotes_vencimiento AS
SELECT l.id_lote, f.nombre AS farmacia, m.nombre AS medicamento, l.fecha_ven, l.cant_dispo, CASE WHEN l.fecha_ven < CURRENT_DATE THEN 'Vencido' ELSE 'Por vencer' END AS estado
FROM lotes l
JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
JOIN farmacias f ON f.id_farmacia = l.id_farmacia
WHERE l.fecha_ven <= CURRENT_DATE + INTERVAL '30 days';

-- Detalle de ventas con subtotal
CREATE OR REPLACE VIEW v_ventas_detalle AS
SELECT v.id_venta, v.fecha, v.metodo_pago, v.id_paciente, v.id_empleado, f.nombre AS farmacia,m.nombre AS medicamento, vm.cantidad, vm.precio_unitario,vm.cantidad * vm.precio_unitario AS subtotal

FROM ventas v
JOIN ventas_medicamentos vm ON vm.id_venta = v.id_venta
JOIN medicamentos m ON m.id_medicamento = vm.id_medicamento
JOIN farmacias f ON f.id_farmacia = v.id_farmacia;

-- Detalle de suministros con subtotal
CREATE OR REPLACE VIEW v_suministros_detalle AS
SELECT s.id_suministro, s.id_proveedor, s.id_farmacia, s.fecha, s.estado,
m.nombre AS medicamento, sm.cantidad_med, sm.precio_suministro,
sm.cantidad_med * sm.precio_suministro AS subtotal

FROM suministros s
JOIN suministros_medicamentos sm ON sm.id_suministro = s.id_suministro
JOIN medicamentos m ON m.id_medicamento = sm.id_medicamento;


-- XINDICESVISTAS

-- DROP VIEW IF EXISTS v_suministros_detalle;
-- DROP VIEW IF EXISTS v_ventas_detalle;
-- DROP VIEW IF EXISTS v_lotes_vencimiento;
-- DROP VIEW IF EXISTS v_inventario_farmacia;

-- DROP INDEX IF EXISTS idx_suministros_proveedor_fecha;
-- DROP INDEX IF EXISTS idx_ventas_farmacia_fecha;
-- DROP INDEX IF EXISTS idx_ventas_paciente_fecha;
-- DROP INDEX IF EXISTS idx_lotes_fecha_ven;
-- DROP INDEX IF EXISTS idx_lotes_farmacia_medicamento_ven;


-- INDICESVISTASOK

INSERT INTO proveedores VALUES (700, 'Proveedor Indices', '900700700-0', '3000000700', 'Calle 700');

INSERT INTO farmacias VALUES (700, 'Farmacia Indices', 'Calle 700', '3100000700');

INSERT INTO personas VALUES
(700, 'Persona Cajero Indices', 'CC', '1000000700', '3000000700', 'p700@email.com', 30, 'M'),
(701, 'Persona Paciente Indices', 'CC', '1000000701', '3000000701', 'p701@email.com', 30, 'F');

INSERT INTO empleados VALUES (700, 2000000, '2025-01-10', 'Cajero', 700);

INSERT INTO pacientes VALUES (700, (CURRENT_DATE - INTERVAL '30 years')::date, 'Calle 700 #1', 'Ninguna', 701);

INSERT INTO medicamentos VALUES
(700, 'Medicamento Indice Uno', 5000.00, 'Analgesico', 'Oral'),
(701, 'Medicamento Indice Dos', 8000.00, 'Antialergico', 'Oral');

INSERT INTO lotes VALUES
(700, CURRENT_DATE + 10, 40, 700, 700),
(701, '2099-12-31', 100, 700, 700),
(702, '2099-12-31', 60, 701, 700);

INSERT INTO suministros VALUES (700, CURRENT_DATE, 0, 'Pendiente', 700, 700);

INSERT INTO suministros_medicamentos VALUES (700, 700, 50, 3500.00);
INSERT INTO suministros_medicamentos VALUES (700, 701, 20, 6000.00);

INSERT INTO ventas VALUES (700, CURRENT_DATE, 0, 'Efectivo', 700, 700, 700);

INSERT INTO ventas_medicamentos VALUES (700, 700, 3, 5000.00);
INSERT INTO ventas_medicamentos VALUES (700, 701, 2, 8000.00);


-- vistas

-- debe devolver 137 y 58
SELECT medicamento, stock FROM v_inventario_farmacia WHERE id_farmacia = 700 ORDER BY medicamento;

-- debe devolver el lote 700 como Por vencer con 37 unidades
SELECT id_lote, medicamento, cant_dispo, estado FROM v_lotes_vencimiento WHERE farmacia = 'Farmacia Indices';

-- debe devolver subtotales 15000 y 16000
SELECT medicamento, cantidad, precio_unitario, subtotal FROM v_ventas_detalle WHERE id_paciente = 700 ORDER BY medicamento;

-- debe devolver subtotales 175000 y 120000
SELECT medicamento, cantidad_med, precio_suministro, subtotal FROM v_suministros_detalle WHERE id_proveedor = 700 ORDER BY medicamento;