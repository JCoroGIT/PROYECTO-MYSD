-- ACTORES

-- SV_ADMINISTRADOR

CREATE SCHEMA sv_administrador;

CREATE PROCEDURE sv_administrador.empleado_adicionar(
    p_id_empleado integer,
    p_id_persona integer,
    p_nombre varchar,
    p_tipo_documento TDocumento,
    p_documento varchar,
    p_telefono varchar,
    p_email varchar,
    p_edad integer,
    p_sexo TSexo,
    p_salario integer,
    p_fecha_contratacion date,
    p_cargo TCargo)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_empleados.adicionar(p_id_empleado, p_id_persona, p_nombre, p_tipo_documento, p_documento, p_telefono, p_email, p_edad, p_sexo, p_salario, p_fecha_contratacion, p_cargo);
END;
$$;

CREATE PROCEDURE sv_administrador.empleado_modificar(
    p_id_empleado integer,
    p_salario integer,
    p_cargo TCargo,
    p_telefono varchar,
    p_email varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_empleados.modificar(p_id_empleado, p_salario, p_cargo, p_telefono, p_email);
END;
$$;

CREATE PROCEDURE sv_administrador.empleado_eliminar(
    p_id_empleado integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_empleados.eliminar(p_id_empleado);
END;
$$;

CREATE FUNCTION sv_administrador.empleado_consultar(
    p_id_empleado integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_empleados.consultar(p_id_empleado);
END;
$$;

CREATE PROCEDURE sv_administrador.farmacia_adicionar(
    p_id_farmacia integer,
    p_nombre varchar,
    p_direccion varchar,
    p_telefono varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_farmacias.adicionar(p_id_farmacia, p_nombre, p_direccion, p_telefono);
END;
$$;

CREATE PROCEDURE sv_administrador.farmacia_modificar(
    p_id_farmacia integer,
    p_nombre varchar,
    p_direccion varchar,
    p_telefono varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_farmacias.modificar(p_id_farmacia, p_nombre, p_direccion, p_telefono);
END;
$$;

CREATE PROCEDURE sv_administrador.farmacia_eliminar(
    p_id_farmacia integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_farmacias.eliminar(p_id_farmacia);
END;
$$;

CREATE FUNCTION sv_administrador.farmacia_consultar(
    p_id_farmacia integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_farmacias.consultar(p_id_farmacia);
END;
$$;

CREATE PROCEDURE sv_administrador.medicamento_adicionar(
    p_id_medicamento integer,
    p_nombre varchar,
    p_precio_unitario numeric,
    p_tipo_medicamento TMedicamento,
    p_via_uso TVia)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_medicamentos.adicionar(p_id_medicamento, p_nombre, p_precio_unitario, p_tipo_medicamento, p_via_uso);
END;
$$;

CREATE PROCEDURE sv_administrador.medicamento_modificar(
    p_id_medicamento integer,
    p_nombre varchar,
    p_precio_unitario numeric,
    p_tipo_medicamento TMedicamento,
    p_via_uso TVia)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_medicamentos.modificar(p_id_medicamento, p_nombre, p_precio_unitario, p_tipo_medicamento, p_via_uso);
END;
$$;

CREATE PROCEDURE sv_administrador.medicamento_eliminar(
    p_id_medicamento integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_medicamentos.eliminar(p_id_medicamento);
END;
$$;

CREATE FUNCTION sv_administrador.medicamento_consultar(
    p_id_medicamento integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_medicamentos.consultar(p_id_medicamento);
END;
$$;

CREATE PROCEDURE sv_administrador.proveedor_adicionar(
    p_id_proveedor integer,
    p_nombre varchar,
    p_nit varchar,
    p_telefono varchar,
    p_direccion varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_proveedores.adicionar(p_id_proveedor, p_nombre, p_nit, p_telefono, p_direccion);
END;
$$;

CREATE PROCEDURE sv_administrador.proveedor_modificar(
    p_id_proveedor integer,
    p_nombre varchar,
    p_nit varchar,
    p_telefono varchar,
    p_direccion varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_proveedores.modificar(p_id_proveedor, p_nombre, p_nit, p_telefono, p_direccion);
END;
$$;

CREATE PROCEDURE sv_administrador.proveedor_eliminar(
    p_id_proveedor integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL sv_proveedores.eliminar(p_id_proveedor);
END;
$$;

CREATE FUNCTION sv_administrador.proveedor_consulta(
    p_id_proveedor integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_proveedores.consultar(p_id_proveedor);
END;
$$;

CREATE FUNCTION sv_administrador.inventario_consultar(
    p_id_farmacia integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_lotes.inventario(p_id_farmacia);
END;
$$;

CREATE FUNCTION sv_administrador.ventas_por_empleado(
    p_id_empleado integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_empleados.ventas_por_empleado(p_id_empleado);
END;
$$;

CREATE FUNCTION sv_administrador.medicamentos_mas_vendidos(
    p_limite integer DEFAULT 10)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_medicamentos.mas_vendidos(p_limite);
END;
$$;

CREATE FUNCTION sv_administrador.lotes_por_vencer(
    p_dias integer DEFAULT 30,
    p_id_farmacia integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_lotes.por_vencer(p_dias, p_id_farmacia);
END;
$$;

CREATE FUNCTION sv_administrador.medicamentos_recientes(
    p_limite integer DEFAULT 10)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_medicamentos.recientes(p_limite);
END;
$$;


-- SV_PROVEEDOR

CREATE SCHEMA sv_proveedor;

CREATE FUNCTION sv_proveedor.stock_consultar(
    p_id_medicamento integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_lotes.stock_medicamento(p_id_medicamento);
END;
$$;

CREATE FUNCTION sv_proveedor.stock_bajo(
    p_limite integer DEFAULT 30)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_lotes.stock_bajo(p_limite);
END;
$$;

CREATE FUNCTION sv_proveedor.suministro_historial(
    p_id_proveedor integer)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_suministros.consultar(NULL, p_id_proveedor);
END;
$$;

CREATE FUNCTION sv_proveedor.suministro_detalle(
    p_id_proveedor integer)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_suministros.detalle(NULL, p_id_proveedor);
END;
$$;

CREATE FUNCTION sv_proveedor.suministro_valor_estado(
    p_id_proveedor integer)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_suministros.valor_por_estado(p_id_proveedor);
END;
$$;

CREATE FUNCTION sv_proveedor.suministro_pendientes(
    p_id_proveedor integer)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN sv_suministros.pendientes(p_id_proveedor);
END;
$$;


-- SEGURIDAD

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_administrador') THEN
        CREATE ROLE rol_administrador NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_proveedor') THEN
        CREATE ROLE rol_proveedor NOLOGIN;
    END IF;
END;
$$;

REVOKE ALL ON ALL ROUTINES IN SCHEMA sv_empleados, sv_pacientes, sv_farmacias, sv_proveedores,
    sv_medicamentos, sv_lotes, sv_suministros, sv_ventas, sv_administrador, sv_proveedor FROM PUBLIC;

-- Administrador

GRANT USAGE ON SCHEMA sv_administrador, sv_empleados, sv_farmacias, sv_medicamentos, sv_proveedores, sv_lotes
TO rol_administrador;

GRANT EXECUTE ON ALL ROUTINES IN SCHEMA sv_administrador, sv_empleados, sv_farmacias, sv_medicamentos, sv_proveedores, sv_lotes
TO rol_administrador;

GRANT SELECT, INSERT, UPDATE, DELETE ON personas, empleados, administradores, farmacias, inventarios, medicamentos, proveedores
TO rol_administrador;

GRANT SELECT ON pacientes, lotes, ventas, ventas_medicamentos TO rol_administrador;

-- Proveedor

GRANT USAGE ON SCHEMA sv_proveedor, sv_lotes, sv_suministros TO rol_proveedor;

GRANT EXECUTE ON ALL ROUTINES IN SCHEMA sv_proveedor, sv_lotes, sv_suministros TO rol_proveedor;

GRANT SELECT ON medicamentos, lotes, farmacias, suministros, suministros_medicamentos TO rol_proveedor;


-- XSEGURIDAD

-- DROP SCHEMA IF EXISTS sv_administrador CASCADE;
-- DROP SCHEMA IF EXISTS sv_proveedor CASCADE;
-- DROP OWNED BY rol_administrador;
-- DROP OWNED BY rol_proveedor;
-- DROP ROLE IF EXISTS rol_administrador;
-- DROP ROLE IF EXISTS rol_proveedor;


-- SEGURIDADOK

CALL sv_proveedores.adicionar(1200, 'Proveedor Seguridad', '900120012-0', '3001201200', 'Calle 1200');
CALL sv_farmacias.adicionar(1200, 'Farmacia Seguridad', 'Calle 1200', '3101201200');
CALL sv_medicamentos.adicionar(1200, 'Medicamento Seguridad', 4000.00, 'Analgesico', 'Oral');
CALL sv_suministros.adicionar(1200, '2026-11-10', 1200, 1200, ARRAY[1200], ARRAY[40], ARRAY[3000.00]);
CALL sv_suministros.recibir(1200, '2027-12-31');
CALL sv_suministros.adicionar(1201, '2026-11-11', 1200, 1200, ARRAY[1200], ARRAY[10], ARRAY[3200.00]);

-- el administrador usa sus servicios
SET ROLE rol_administrador;

CALL sv_administrador.proveedor_adicionar(1201, 'Proveedor Admin', '900120013-0', '3001201201', 'Calle 1201');
CALL sv_administrador.proveedor_modificar(1201, NULL, NULL, '3001201299', NULL);
CALL sv_administrador.farmacia_adicionar(1201, 'Farmacia Admin', 'Calle 1201', '3101201201');
CALL sv_administrador.farmacia_modificar(1201, NULL, 'Calle 1201 Sur', NULL);
CALL sv_administrador.medicamento_adicionar(1201, 'Medicamento Admin', 6000.00, 'Antibiotico', 'Oral');
CALL sv_administrador.medicamento_modificar(1201, NULL, 6500.00, NULL, NULL);
CALL sv_administrador.empleado_adicionar(1200, 1200, 'Empleado Seguridad', 'CC', '1000001200', '3001201200', 'e1200@email.com', 30, 'M', 2000000, '2025-01-10', 'Cajero');
CALL sv_administrador.empleado_modificar(1200, 2200000, NULL, NULL, NULL);

RESET ROLE;

-- debe devolver 1 fila de cada una con los valores modificados
SELECT telefono FROM proveedores WHERE id_proveedor = 1201;
SELECT direccion FROM farmacias WHERE id_farmacia = 1201;
SELECT precio_unitario FROM medicamentos WHERE id_medicamento = 1201;
SELECT salario FROM empleados WHERE id_empleado = 1200;

SET ROLE rol_administrador;

CALL sv_administrador.proveedor_eliminar(1201);
CALL sv_administrador.farmacia_eliminar(1201);
CALL sv_administrador.medicamento_eliminar(1201);
CALL sv_administrador.empleado_eliminar(1200);

RESET ROLE;

-- debe devolver 0 filas
SELECT 1 FROM proveedores WHERE id_proveedor = 1201
UNION ALL
SELECT 1 FROM farmacias WHERE id_farmacia = 1201
UNION ALL
SELECT 1 FROM medicamentos WHERE id_medicamento = 1201
UNION ALL
SELECT 1 FROM empleados WHERE id_empleado = 1200;

-- consultas del administrador
BEGIN;
SET LOCAL ROLE rol_administrador;
SELECT sv_administrador.empleado_consultar();
FETCH ALL IN cur_empleados;
SELECT sv_administrador.farmacia_consultar(1200);
FETCH ALL IN cur_farmacias;
SELECT sv_administrador.medicamento_consultar(1200);
FETCH ALL IN cur_medicamentos;
SELECT sv_administrador.proveedor_consulta(1200);
FETCH ALL IN cur_proveedores;
SELECT sv_administrador.inventario_consultar(1200);
FETCH ALL IN cur_lotes_inventario;
SELECT sv_administrador.ventas_por_empleado();
FETCH ALL IN cur_empleados_ventas;
SELECT sv_administrador.medicamentos_mas_vendidos(5);
FETCH ALL IN cur_medicamentos_mas_vendidos;
SELECT sv_administrador.lotes_por_vencer(600, 1200);
FETCH ALL IN cur_lotes_por_vencer;
SELECT sv_administrador.medicamentos_recientes(3);
FETCH ALL IN cur_medicamentos_recientes;
COMMIT;

-- el proveedor usa sus servicios (debe devolver el stock 40, los suministros 1200 y 1201, subtotal 120000 y 32000, valor 120000 Recibido y 32000 Pendiente, y el suministro 1201 pendiente)
BEGIN;
SET LOCAL ROLE rol_proveedor;
SELECT sv_proveedor.stock_consultar(1200);
FETCH ALL IN cur_lotes_stock;
SELECT sv_proveedor.stock_bajo(50);
FETCH ALL IN cur_lotes_stock_bajo;
SELECT sv_proveedor.suministro_historial(1200);
FETCH ALL IN cur_suministros;
SELECT sv_proveedor.suministro_detalle(1200);
FETCH ALL IN cur_suministros_detalle;
SELECT sv_proveedor.suministro_valor_estado(1200);
FETCH ALL IN cur_suministros_valor;
SELECT sv_proveedor.suministro_pendientes(1200);
FETCH ALL IN cur_suministros_pendientes;
COMMIT;


-- SEGURIDADNOOK

-- el proveedor no puede usar los servicios del administrador
BEGIN;
SET LOCAL ROLE rol_proveedor;
CALL sv_administrador.empleado_adicionar(1300, 1300, 'Empleado Nook', 'CC', '1000001300', '3001301300', 'e1300@email.com', 30, 'M', 2000000, '2025-01-10', 'Cajero');
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_proveedor;
SELECT sv_administrador.empleado_consultar();
ROLLBACK;

-- el proveedor no puede llamar un componente que modifica tablas que no le pertenecen
BEGIN;
SET LOCAL ROLE rol_proveedor;
CALL sv_lotes.adicionar(5200, '2027-12-31', 10, 1200, 1200);
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_proveedor;
CALL sv_suministros.cancelar(1201);
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_proveedor;
CALL sv_ventas.adicionar(1300, 1200, 1, NULL, 'Efectivo', ARRAY[1200], ARRAY[1]);
ROLLBACK;

-- el proveedor no puede leer tablas del negocio
BEGIN;
SET LOCAL ROLE rol_proveedor;
SELECT * FROM empleados;
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_proveedor;
DELETE FROM lotes;
ROLLBACK;

-- el administrador no puede usar los servicios del proveedor
BEGIN;
SET LOCAL ROLE rol_administrador;
SELECT sv_proveedor.stock_bajo();
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_administrador;
SELECT sv_proveedor.suministro_historial(1200);
ROLLBACK;

-- el administrador no accede a suministros ni registra ventas
BEGIN;
SET LOCAL ROLE rol_administrador;
SELECT * FROM suministros;
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_administrador;
CALL sv_ventas.adicionar(1300, 1200, 1, NULL, 'Efectivo', ARRAY[1200], ARRAY[1]);
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_administrador;
CALL sv_lotes.adicionar(5200, '2027-12-31', 10, 1200, 1200);
ROLLBACK;

-- debe devolver 0 filas
SELECT * FROM lotes WHERE id_lote = 5200;
SELECT * FROM empleados WHERE id_empleado = 1300;
SELECT * FROM suministros WHERE id_suministro = 1201 AND estado <> 'Pendiente';