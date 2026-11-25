-- PRUEBA 1: abastecimiento (proveedor -> suministro -> recepcion -> lote -> inventario)

CALL sv_proveedores.adicionar(2000, 'Proveedor Flujo', '900200020-0', '3002002000', 'Calle 2000');
CALL sv_farmacias.adicionar(2000, 'Farmacia Flujo', 'Calle 2000', '3102002000');
CALL sv_medicamentos.adicionar(2000, 'Medicamento Flujo Uno', 5000.00, 'Analgesico', 'Oral');
CALL sv_medicamentos.adicionar(2001, 'Medicamento Flujo Dos', 8000.00, 'Antialergico', 'Oral');

CALL sv_suministros.adicionar(2000, CURRENT_DATE, 2000, 2000, ARRAY[2000, 2001], ARRAY[100, 50], ARRAY[3500.00, 6000.00]);

-- debe devolver cantidad 150, estado Pendiente y el inventario de la farmacia vacio (0 filas)
BEGIN;
SELECT sv_suministros.consultar(2000);
FETCH ALL IN cur_suministros;
SELECT sv_lotes.inventario(2000);
FETCH ALL IN cur_lotes_inventario;
COMMIT;

CALL sv_suministros.recibir(2000, '2027-12-31');

-- debe devolver estado Recibido y stock 100 y 50 en Farmacia Flujo
BEGIN;
SELECT sv_suministros.consultar(2000);
FETCH ALL IN cur_suministros;
SELECT sv_lotes.inventario(2000);
FETCH ALL IN cur_lotes_inventario;
COMMIT;


-- PRUEBA 2: venta (empleado y paciente -> venta -> total y stock -> historial)

CALL sv_empleados.adicionar(2000, 2000, 'Empleado Flujo', 'CC', '1000002000', '3002002000', 'e2000@email.com', 30, 'M', 2000000, '2025-01-10', 'Cajero');
CALL sv_pacientes.adicionar(2000, 2001, 'Paciente Flujo', 'CC', '1000002001', '3002002001', 'p2001@email.com', 'F', '1996-01-01', 'Calle 2001 #1', 'Ninguna');

CALL sv_ventas.adicionar(2000, 2000, 2000, 2000, 'Tarjeta', ARRAY[2000, 2001], ARRAY[10, 5]);

-- debe devolver total 90000 (10 x 5000 + 5 x 8000)
BEGIN;
SELECT sv_ventas.consultar(2000);
FETCH ALL IN cur_ventas;
COMMIT;

-- debe devolver stock 90 y 45 (descontado por la venta)
BEGIN;
SELECT sv_lotes.stock_medicamento(2000);
FETCH ALL IN cur_lotes_stock;
COMMIT;

BEGIN;
SELECT sv_lotes.stock_medicamento(2001);
FETCH ALL IN cur_lotes_stock;
COMMIT;

-- debe devolver las 2 lineas de la venta, el historial del paciente y la venta del mes por Tarjeta
BEGIN;
SELECT sv_ventas.detalle(2000);
FETCH ALL IN cur_ventas_detalle;
SELECT sv_pacientes.historial_compras(2000);
FETCH ALL IN cur_pacientes_historial;
SELECT sv_ventas.ventas_mes(2000);
FETCH ALL IN cur_ventas_mes;
COMMIT;


DELETE FROM ventas_medicamentos WHERE id_venta IN (1000, 2000);
DELETE FROM ventas WHERE id_venta IN (1000, 2000);
DELETE FROM suministros_medicamentos WHERE id_suministro IN (1000, 1001, 1200, 1201, 2000);
DELETE FROM suministros WHERE id_suministro IN (1000, 1001, 1200, 1201, 2000);
DELETE FROM lotes WHERE id_farmacia IN (1000, 1200, 1201, 2000);
DELETE FROM pacientes WHERE id_paciente IN (1000, 2000);
DELETE FROM empleados WHERE id_empleado IN (1000, 1200, 2000);
DELETE FROM personas WHERE id_persona IN (1000, 1002, 1200, 2000, 2001);
DELETE FROM medicamentos WHERE id_medicamento IN (1000, 1001, 1200, 1201, 2000, 2001);
DELETE FROM farmacias WHERE id_farmacia IN (1000, 1200, 1201, 2000);
DELETE FROM proveedores WHERE id_proveedor IN (1000, 1200, 1201, 2000);