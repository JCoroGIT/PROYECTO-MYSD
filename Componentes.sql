-- COMPONENTES

-- SV_EMPLEADOS

CREATE SCHEMA sv_empleados;

CREATE PROCEDURE sv_empleados.adicionar(
    p_id_empleado integer, p_id_persona integer, p_nombre varchar, p_tipo_documento TDocumento,
    p_documento varchar, p_telefono varchar, p_email varchar, p_edad integer, p_sexo TSexo,
    p_salario integer, p_fecha_contratacion date, p_cargo TCargo)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO personas (id_persona, nombre, tipo_documento, documento, telefono, email, edad, sexo)
        VALUES (p_id_persona, p_nombre, p_tipo_documento, p_documento, p_telefono, p_email, p_edad, p_sexo);
        INSERT INTO empleados (id_empleado, salario, fecha_contratacion, cargo, id_persona)
        VALUES (p_id_empleado, p_salario, p_fecha_contratacion, p_cargo, p_id_persona);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_empleados.adicionar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_empleados.modificar(
    p_id_empleado integer, p_salario integer, p_cargo TCargo, p_telefono varchar, p_email varchar)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE empleados
        SET salario = COALESCE(p_salario, salario), cargo = COALESCE(p_cargo, cargo)
        WHERE id_empleado = p_id_empleado;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El empleado % no existe', p_id_empleado;
        END IF;
        UPDATE personas
        SET telefono = COALESCE(p_telefono, telefono), email = COALESCE(p_email, email)
        WHERE id_persona = (SELECT id_persona FROM empleados WHERE id_empleado = p_id_empleado);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_empleados.modificar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_empleados.eliminar(p_id_empleado integer)
LANGUAGE plpgsql AS $$
DECLARE
    v_persona integer;
BEGIN
    BEGIN
        SELECT id_persona INTO v_persona FROM empleados WHERE id_empleado = p_id_empleado;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El empleado % no existe', p_id_empleado;
        END IF;
        DELETE FROM empleados WHERE id_empleado = p_id_empleado;
        IF NOT EXISTS (SELECT 1 FROM pacientes WHERE id_persona = v_persona) THEN
            DELETE FROM personas WHERE id_persona = v_persona;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_empleados.eliminar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE FUNCTION sv_empleados.consultar(p_id_empleado integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_empleados';
BEGIN
    OPEN cur FOR
        SELECT e.id_empleado, p.nombre, p.tipo_documento, p.documento, p.telefono, p.email,
               e.cargo, e.salario, e.fecha_contratacion
        FROM empleados e
        JOIN personas p ON p.id_persona = e.id_persona
        WHERE p_id_empleado IS NULL OR e.id_empleado = p_id_empleado
        ORDER BY e.id_empleado;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_empleados.ventas_por_empleado(p_id_empleado integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_empleados_ventas';
BEGIN
    OPEN cur FOR
        SELECT e.id_empleado, p.nombre, e.cargo, COUNT(v.id_venta) AS num_ventas,
               COALESCE(SUM(v.total), 0) AS total_vendido
        FROM empleados e
        JOIN personas p ON p.id_persona = e.id_persona
        LEFT JOIN ventas v ON v.id_empleado = e.id_empleado
        WHERE p_id_empleado IS NULL OR e.id_empleado = p_id_empleado
        GROUP BY e.id_empleado, p.nombre, e.cargo
        ORDER BY total_vendido DESC;
    RETURN cur;
END;
$$;


-- SV_PACIENTES

CREATE SCHEMA sv_pacientes;

CREATE PROCEDURE sv_pacientes.adicionar(
    p_id_paciente integer, p_id_persona integer, p_nombre varchar, p_tipo_documento TDocumento,
    p_documento varchar, p_telefono varchar, p_email varchar, p_sexo TSexo,
    p_fecha_nac date, p_direccion varchar, p_restricciones TRestriccion)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO personas (id_persona, nombre, tipo_documento, documento, telefono, email, edad, sexo)
        VALUES (p_id_persona, p_nombre, p_tipo_documento, p_documento, p_telefono, p_email,
                date_part('year', age(CURRENT_DATE, p_fecha_nac))::integer, p_sexo);
        INSERT INTO pacientes (id_paciente, fecha_nac, direccion, restricciones, id_persona)
        VALUES (p_id_paciente, p_fecha_nac, p_direccion, p_restricciones, p_id_persona);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_pacientes.adicionar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_pacientes.modificar(
    p_id_paciente integer, p_direccion varchar, p_restricciones TRestriccion,
    p_telefono varchar, p_email varchar)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE pacientes
        SET direccion = COALESCE(p_direccion, direccion),
            restricciones = COALESCE(p_restricciones, restricciones)
        WHERE id_paciente = p_id_paciente;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El paciente % no existe', p_id_paciente;
        END IF;
        UPDATE personas
        SET telefono = COALESCE(p_telefono, telefono), email = COALESCE(p_email, email)
        WHERE id_persona = (SELECT id_persona FROM pacientes WHERE id_paciente = p_id_paciente);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_pacientes.modificar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_pacientes.eliminar(p_id_paciente integer)
LANGUAGE plpgsql AS $$
DECLARE
    v_persona integer;
BEGIN
    BEGIN
        SELECT id_persona INTO v_persona FROM pacientes WHERE id_paciente = p_id_paciente;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El paciente % no existe', p_id_paciente;
        END IF;
        DELETE FROM pacientes WHERE id_paciente = p_id_paciente;
        IF NOT EXISTS (SELECT 1 FROM empleados WHERE id_persona = v_persona) THEN
            DELETE FROM personas WHERE id_persona = v_persona;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_pacientes.eliminar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE FUNCTION sv_pacientes.consultar(p_id_paciente integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_pacientes';
BEGIN
    OPEN cur FOR
        SELECT pa.id_paciente, p.nombre, p.tipo_documento, p.documento, p.telefono, p.email,
               p.edad, pa.fecha_nac, pa.direccion, pa.restricciones
        FROM pacientes pa
        JOIN personas p ON p.id_persona = pa.id_persona
        WHERE p_id_paciente IS NULL OR pa.id_paciente = p_id_paciente
        ORDER BY pa.id_paciente;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_pacientes.historial_compras(p_id_paciente integer)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_pacientes_historial';
BEGIN
    OPEN cur FOR
        SELECT v.id_venta, v.fecha, f.nombre AS farmacia, m.nombre AS medicamento,
               vm.cantidad, vm.precio_unitario
        FROM ventas v
        JOIN ventas_medicamentos vm ON vm.id_venta = v.id_venta
        JOIN medicamentos m ON m.id_medicamento = vm.id_medicamento
        JOIN farmacias f ON f.id_farmacia = v.id_farmacia
        WHERE v.id_paciente = p_id_paciente
        ORDER BY v.fecha DESC, v.id_venta;
    RETURN cur;
END;
$$;


-- SV_FARMACIAS

CREATE SCHEMA sv_farmacias;

CREATE PROCEDURE sv_farmacias.adicionar(
    p_id_farmacia integer, p_nombre varchar, p_direccion varchar, p_telefono varchar)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO farmacias (id_farmacia, nombre, direccion, telefono)
        VALUES (p_id_farmacia, p_nombre, p_direccion, p_telefono);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_farmacias.adicionar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_farmacias.modificar(
    p_id_farmacia integer, p_nombre varchar, p_direccion varchar, p_telefono varchar)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE farmacias
        SET nombre = COALESCE(p_nombre, nombre),
            direccion = COALESCE(p_direccion, direccion),
            telefono = COALESCE(p_telefono, telefono)
        WHERE id_farmacia = p_id_farmacia;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La farmacia % no existe', p_id_farmacia;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_farmacias.modificar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_farmacias.eliminar(p_id_farmacia integer)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        DELETE FROM farmacias WHERE id_farmacia = p_id_farmacia;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La farmacia % no existe', p_id_farmacia;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_farmacias.eliminar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE FUNCTION sv_farmacias.consultar(p_id_farmacia integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_farmacias';
BEGIN
    OPEN cur FOR
        SELECT id_farmacia, nombre, direccion, telefono
        FROM farmacias
        WHERE p_id_farmacia IS NULL OR id_farmacia = p_id_farmacia
        ORDER BY id_farmacia;
    RETURN cur;
END;
$$;


-- SV_PROVEEDORES

CREATE SCHEMA sv_proveedores;

CREATE PROCEDURE sv_proveedores.adicionar(
    p_id_proveedor integer, p_nombre varchar, p_nit varchar, p_telefono varchar, p_direccion varchar)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO proveedores (id_proveedor, nombre, nit, telefono, direccion)
        VALUES (p_id_proveedor, p_nombre, p_nit, p_telefono, p_direccion);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_proveedores.adicionar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_proveedores.modificar(
    p_id_proveedor integer, p_nombre varchar, p_nit varchar, p_telefono varchar, p_direccion varchar)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE proveedores
        SET nombre = COALESCE(p_nombre, nombre),
            nit = COALESCE(p_nit, nit),
            telefono = COALESCE(p_telefono, telefono),
            direccion = COALESCE(p_direccion, direccion)
        WHERE id_proveedor = p_id_proveedor;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El proveedor % no existe', p_id_proveedor;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_proveedores.modificar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_proveedores.eliminar(p_id_proveedor integer)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        DELETE FROM proveedores WHERE id_proveedor = p_id_proveedor;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El proveedor % no existe', p_id_proveedor;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_proveedores.eliminar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE FUNCTION sv_proveedores.consultar(p_id_proveedor integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_proveedores';
BEGIN
    OPEN cur FOR
        SELECT id_proveedor, nombre, nit, telefono, direccion
        FROM proveedores
        WHERE p_id_proveedor IS NULL OR id_proveedor = p_id_proveedor
        ORDER BY id_proveedor;
    RETURN cur;
END;
$$;


-- SV_MEDICAMENTOS

CREATE SCHEMA sv_medicamentos;

CREATE PROCEDURE sv_medicamentos.adicionar(
    p_id_medicamento integer, p_nombre varchar, p_precio_unitario numeric,
    p_tipo_medicamento TMedicamento, p_via_uso TVia)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO medicamentos (id_medicamento, nombre, precio_unitario, tipo_medicamento, via_uso)
        VALUES (p_id_medicamento, p_nombre, p_precio_unitario, p_tipo_medicamento, p_via_uso);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_medicamentos.adicionar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_medicamentos.modificar(
    p_id_medicamento integer, p_nombre varchar, p_precio_unitario numeric,
    p_tipo_medicamento TMedicamento, p_via_uso TVia)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE medicamentos
        SET nombre = COALESCE(p_nombre, nombre),
            precio_unitario = COALESCE(p_precio_unitario, precio_unitario),
            tipo_medicamento = COALESCE(p_tipo_medicamento, tipo_medicamento),
            via_uso = COALESCE(p_via_uso, via_uso)
        WHERE id_medicamento = p_id_medicamento;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El medicamento % no existe', p_id_medicamento;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_medicamentos.modificar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_medicamentos.eliminar(p_id_medicamento integer)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        DELETE FROM medicamentos WHERE id_medicamento = p_id_medicamento;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El medicamento % no existe', p_id_medicamento;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_medicamentos.eliminar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE FUNCTION sv_medicamentos.consultar(p_id_medicamento integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_medicamentos';
BEGIN
    OPEN cur FOR
        SELECT id_medicamento, nombre, precio_unitario, tipo_medicamento, via_uso
        FROM medicamentos
        WHERE p_id_medicamento IS NULL OR id_medicamento = p_id_medicamento
        ORDER BY id_medicamento;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_medicamentos.mas_vendidos(p_limite integer DEFAULT 10)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_medicamentos_mas_vendidos';
BEGIN
    OPEN cur FOR
        SELECT m.id_medicamento, m.nombre, SUM(vm.cantidad) AS unidades,
               SUM(vm.cantidad * vm.precio_unitario) AS ingresos
        FROM ventas_medicamentos vm
        JOIN medicamentos m ON m.id_medicamento = vm.id_medicamento
        GROUP BY m.id_medicamento, m.nombre
        ORDER BY unidades DESC, m.id_medicamento
        LIMIT p_limite;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_medicamentos.recientes(p_limite integer DEFAULT 10)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_medicamentos_recientes';
BEGIN
    OPEN cur FOR
        SELECT id_medicamento, nombre, tipo_medicamento, precio_unitario
        FROM medicamentos
        ORDER BY id_medicamento DESC
        LIMIT p_limite;
    RETURN cur;
END;
$$;


-- SV_LOTES

CREATE SCHEMA sv_lotes;

CREATE PROCEDURE sv_lotes.adicionar(
    p_id_lote integer, p_fecha_ven date, p_cant_dispo integer, p_id_medicamento integer, p_id_farmacia integer)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO lotes (id_lote, fecha_ven, cant_dispo, id_medicamento, id_farmacia)
        VALUES (p_id_lote, p_fecha_ven, p_cant_dispo, p_id_medicamento, p_id_farmacia);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_lotes.adicionar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_lotes.modificar(p_id_lote integer, p_fecha_ven date, p_cant_dispo integer)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM lotes WHERE id_lote = p_id_lote) THEN
            RAISE EXCEPTION 'El lote % no existe', p_id_lote;
        END IF;
        IF p_fecha_ven IS NOT NULL THEN
            UPDATE lotes SET fecha_ven = p_fecha_ven WHERE id_lote = p_id_lote;
        END IF;
        IF p_cant_dispo IS NOT NULL THEN
            UPDATE lotes SET cant_dispo = p_cant_dispo WHERE id_lote = p_id_lote;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_lotes.modificar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_lotes.eliminar(p_id_lote integer)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        DELETE FROM lotes WHERE id_lote = p_id_lote;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El lote % no existe', p_id_lote;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_lotes.eliminar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE FUNCTION sv_lotes.consultar(p_id_lote integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_lotes';
BEGIN
    OPEN cur FOR
        SELECT id_lote, fecha_ven, cant_dispo, id_medicamento, id_farmacia
        FROM lotes
        WHERE p_id_lote IS NULL OR id_lote = p_id_lote
        ORDER BY id_lote;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_lotes.inventario(p_id_farmacia integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_lotes_inventario';
BEGIN
    OPEN cur FOR
        SELECT f.nombre AS farmacia, m.nombre, m.tipo_medicamento, l.id_lote, l.fecha_ven, l.cant_dispo
        FROM lotes l
        JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
        JOIN farmacias f ON f.id_farmacia = l.id_farmacia
        WHERE p_id_farmacia IS NULL OR l.id_farmacia = p_id_farmacia
        ORDER BY f.nombre, m.nombre, l.fecha_ven;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_lotes.stock_medicamento(p_id_medicamento integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_lotes_stock';
BEGIN
    OPEN cur FOR
        SELECT m.id_medicamento, m.nombre, COALESCE(SUM(l.cant_dispo), 0) AS stock_total
        FROM medicamentos m
        LEFT JOIN lotes l ON l.id_medicamento = m.id_medicamento AND l.fecha_ven >= CURRENT_DATE
        WHERE p_id_medicamento IS NULL OR m.id_medicamento = p_id_medicamento
        GROUP BY m.id_medicamento, m.nombre
        ORDER BY m.nombre;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_lotes.stock_bajo(p_limite integer DEFAULT 30)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_lotes_stock_bajo';
BEGIN
    OPEN cur FOR
        SELECT m.id_medicamento, m.nombre, COALESCE(SUM(l.cant_dispo), 0) AS stock_total
        FROM medicamentos m
        LEFT JOIN lotes l ON l.id_medicamento = m.id_medicamento AND l.fecha_ven >= CURRENT_DATE
        GROUP BY m.id_medicamento, m.nombre
        HAVING COALESCE(SUM(l.cant_dispo), 0) <= p_limite
        ORDER BY stock_total, m.nombre;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_lotes.por_vencer(p_dias integer DEFAULT 30, p_id_farmacia integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_lotes_por_vencer';
BEGIN
    OPEN cur FOR
        SELECT l.id_lote, f.nombre AS farmacia, m.nombre AS medicamento, l.fecha_ven, l.cant_dispo,
               CASE WHEN l.fecha_ven < CURRENT_DATE THEN 'Vencido' ELSE 'Por vencer' END AS estado
        FROM lotes l
        JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
        JOIN farmacias f ON f.id_farmacia = l.id_farmacia
        WHERE l.fecha_ven <= CURRENT_DATE + p_dias
          AND (p_id_farmacia IS NULL OR l.id_farmacia = p_id_farmacia)
        ORDER BY l.fecha_ven;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_lotes.disponibilidad(p_nombre varchar)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_lotes_disponibilidad';
BEGIN
    OPEN cur FOR
        SELECT f.nombre AS farmacia, m.nombre, m.precio_unitario, SUM(l.cant_dispo) AS disponible
        FROM medicamentos m
        JOIN lotes l ON l.id_medicamento = m.id_medicamento
        JOIN farmacias f ON f.id_farmacia = l.id_farmacia
        WHERE m.nombre ILIKE '%' || p_nombre || '%'
          AND l.cant_dispo > 0 AND l.fecha_ven >= CURRENT_DATE
        GROUP BY f.nombre, m.nombre, m.precio_unitario
        ORDER BY f.nombre, m.nombre;
    RETURN cur;
END;
$$;


-- SV_SUMINISTROS

CREATE SCHEMA sv_suministros;

CREATE PROCEDURE sv_suministros.adicionar(
    p_id_suministro integer, p_fecha date, p_id_proveedor integer, p_id_farmacia integer,
    p_medicamentos integer[], p_cantidades integer[], p_precios numeric[])
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        IF COALESCE(cardinality(p_medicamentos), 0) = 0
           OR cardinality(p_medicamentos) <> COALESCE(cardinality(p_cantidades), 0)
           OR cardinality(p_medicamentos) <> COALESCE(cardinality(p_precios), 0) THEN
            RAISE EXCEPTION 'Medicamentos, cantidades y precios deben tener el mismo numero de elementos';
        END IF;
        INSERT INTO suministros (id_suministro, fecha, cantidad, estado, id_proveedor, id_farmacia)
        VALUES (p_id_suministro, p_fecha, 0, 'Pendiente', p_id_proveedor, p_id_farmacia);
        FOR i IN 1..cardinality(p_medicamentos) LOOP
            INSERT INTO suministros_medicamentos (id_suministro, id_medicamento, cantidad_med, precio_suministro)
            VALUES (p_id_suministro, p_medicamentos[i], p_cantidades[i], p_precios[i]);
        END LOOP;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_suministros.adicionar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_suministros.recibir(p_id_suministro integer, p_fecha_ven date)
LANGUAGE plpgsql AS $$
DECLARE
    v_farmacia integer;
    v_estado varchar;
BEGIN
    BEGIN
        SELECT id_farmacia, estado INTO v_farmacia, v_estado
        FROM suministros WHERE id_suministro = p_id_suministro FOR UPDATE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El suministro % no existe', p_id_suministro;
        END IF;
        IF v_estado <> 'Pendiente' THEN
            RAISE EXCEPTION 'El suministro % ya esta %', p_id_suministro, v_estado;
        END IF;
        LOCK TABLE lotes IN SHARE ROW EXCLUSIVE MODE;
        INSERT INTO lotes (id_lote, fecha_ven, cant_dispo, id_medicamento, id_farmacia)
        SELECT (SELECT COALESCE(MAX(id_lote), 0) FROM lotes) + row_number() OVER (ORDER BY sm.id_medicamento),
               p_fecha_ven, sm.cantidad_med, sm.id_medicamento, v_farmacia
        FROM suministros_medicamentos sm
        WHERE sm.id_suministro = p_id_suministro;
        UPDATE suministros SET estado = 'Recibido' WHERE id_suministro = p_id_suministro;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_suministros.recibir: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE PROCEDURE sv_suministros.cancelar(p_id_suministro integer)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE suministros SET estado = 'Cancelado' WHERE id_suministro = p_id_suministro;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El suministro % no existe', p_id_suministro;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_suministros.cancelar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE FUNCTION sv_suministros.consultar(p_id_suministro integer DEFAULT NULL, p_id_proveedor integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_suministros';
BEGIN
    OPEN cur FOR
        SELECT id_suministro, fecha, cantidad, estado, id_proveedor, id_farmacia
        FROM suministros
        WHERE (p_id_suministro IS NULL OR id_suministro = p_id_suministro)
          AND (p_id_proveedor IS NULL OR id_proveedor = p_id_proveedor)
        ORDER BY fecha DESC, id_suministro;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_suministros.detalle(p_id_suministro integer DEFAULT NULL, p_id_proveedor integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_suministros_detalle';
BEGIN
    OPEN cur FOR
        SELECT s.id_suministro, s.fecha, s.estado, m.nombre AS medicamento, sm.cantidad_med,
               sm.precio_suministro, sm.cantidad_med * sm.precio_suministro AS subtotal
        FROM suministros s
        JOIN suministros_medicamentos sm ON sm.id_suministro = s.id_suministro
        JOIN medicamentos m ON m.id_medicamento = sm.id_medicamento
        WHERE (p_id_suministro IS NULL OR s.id_suministro = p_id_suministro)
          AND (p_id_proveedor IS NULL OR s.id_proveedor = p_id_proveedor)
        ORDER BY s.fecha DESC, s.id_suministro, m.nombre;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_suministros.pendientes(p_id_proveedor integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_suministros_pendientes';
BEGIN
    OPEN cur FOR
        SELECT s.id_suministro, s.fecha, f.nombre AS farmacia_destino, s.cantidad
        FROM suministros s
        JOIN farmacias f ON f.id_farmacia = s.id_farmacia
        WHERE s.estado = 'Pendiente'
          AND (p_id_proveedor IS NULL OR s.id_proveedor = p_id_proveedor)
        ORDER BY s.fecha, s.id_suministro;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_suministros.valor_por_estado(p_id_proveedor integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_suministros_valor';
BEGIN
    OPEN cur FOR
        SELECT s.estado, COUNT(DISTINCT s.id_suministro) AS num_suministros,
               SUM(sm.cantidad_med * sm.precio_suministro) AS valor_total
        FROM suministros s
        JOIN suministros_medicamentos sm ON sm.id_suministro = s.id_suministro
        WHERE p_id_proveedor IS NULL OR s.id_proveedor = p_id_proveedor
        GROUP BY s.estado
        ORDER BY s.estado;
    RETURN cur;
END;
$$;


-- SV_VENTAS

CREATE SCHEMA sv_ventas;

CREATE PROCEDURE sv_ventas.adicionar(
    p_id_venta integer, p_id_farmacia integer, p_id_empleado integer, p_id_paciente integer,
    p_metodo_pago TMetodo, p_medicamentos integer[], p_cantidades integer[],
    p_fecha date DEFAULT CURRENT_DATE)
LANGUAGE plpgsql AS $$
DECLARE
    v_precio numeric;
BEGIN
    BEGIN
        IF COALESCE(cardinality(p_medicamentos), 0) = 0
           OR cardinality(p_medicamentos) <> COALESCE(cardinality(p_cantidades), 0) THEN
            RAISE EXCEPTION 'Medicamentos y cantidades deben tener el mismo numero de elementos';
        END IF;
        INSERT INTO ventas (id_venta, fecha, total, metodo_pago, id_farmacia, id_paciente, id_empleado)
        VALUES (p_id_venta, p_fecha, 0, p_metodo_pago, p_id_farmacia, p_id_paciente, p_id_empleado);
        FOR i IN 1..cardinality(p_medicamentos) LOOP
            SELECT precio_unitario INTO v_precio FROM medicamentos WHERE id_medicamento = p_medicamentos[i];
            IF NOT FOUND THEN
                RAISE EXCEPTION 'El medicamento % no existe', p_medicamentos[i];
            END IF;
            INSERT INTO ventas_medicamentos (id_venta, id_medicamento, cantidad, precio_unitario)
            VALUES (p_id_venta, p_medicamentos[i], p_cantidades[i], v_precio);
        END LOOP;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sv_ventas.adicionar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE FUNCTION sv_ventas.consultar(p_id_venta integer DEFAULT NULL, p_id_paciente integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_ventas';
BEGIN
    OPEN cur FOR
        SELECT id_venta, fecha, total, metodo_pago, id_farmacia, id_paciente, id_empleado
        FROM ventas
        WHERE (p_id_venta IS NULL OR id_venta = p_id_venta)
          AND (p_id_paciente IS NULL OR id_paciente = p_id_paciente)
        ORDER BY fecha DESC, id_venta;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_ventas.detalle(p_id_venta integer)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_ventas_detalle';
BEGIN
    OPEN cur FOR
        SELECT m.nombre, vm.cantidad, vm.precio_unitario, vm.cantidad * vm.precio_unitario AS subtotal
        FROM ventas_medicamentos vm
        JOIN medicamentos m ON m.id_medicamento = vm.id_medicamento
        WHERE vm.id_venta = p_id_venta
        ORDER BY m.nombre;
    RETURN cur;
END;
$$;

CREATE FUNCTION sv_ventas.ventas_mes(p_id_farmacia integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_ventas_mes';
BEGIN
    OPEN cur FOR
        SELECT f.nombre AS farmacia, v.metodo_pago, COUNT(*) AS num_ventas, SUM(v.total) AS total_vendido
        FROM ventas v
        JOIN farmacias f ON f.id_farmacia = v.id_farmacia
        WHERE date_trunc('month', v.fecha) = date_trunc('month', CURRENT_DATE)
          AND (p_id_farmacia IS NULL OR v.id_farmacia = p_id_farmacia)
        GROUP BY f.nombre, v.metodo_pago
        ORDER BY f.nombre, total_vendido DESC;
    RETURN cur;
END;
$$;


-- XCOMPONENTES

-- DROP SCHEMA IF EXISTS sv_ventas CASCADE;
-- DROP SCHEMA IF EXISTS sv_suministros CASCADE;
-- DROP SCHEMA IF EXISTS sv_lotes CASCADE;
-- DROP SCHEMA IF EXISTS sv_medicamentos CASCADE;
-- DROP SCHEMA IF EXISTS sv_proveedores CASCADE;
-- DROP SCHEMA IF EXISTS sv_farmacias CASCADE;
-- DROP SCHEMA IF EXISTS sv_pacientes CASCADE;
-- DROP SCHEMA IF EXISTS sv_empleados CASCADE;


-- COMPONENTESOK

CALL sv_proveedores.adicionar(1000, 'Proveedor Componentes', '900100001-0', '3001001000', 'Calle 1000');

CALL sv_farmacias.adicionar(1000, 'Farmacia Componentes', 'Calle 1000', '3101001000');

CALL sv_medicamentos.adicionar(1000, 'Medicamento Componente Uno', 5000.00, 'Analgesico', 'Oral');
CALL sv_medicamentos.adicionar(1001, 'Medicamento Componente Dos', 8000.00, 'Antialergico', 'Oral');

CALL sv_empleados.adicionar(1000, 1000, 'Empleado Componente', 'CC', '1000001000', '3001001000', 'e1000@email.com', 30, 'M', 2000000, '2025-01-10', 'Farmaceutico');
CALL sv_empleados.adicionar(1001, 1001, 'Admin Componente', 'CC', '1000001001', '3001001001', 'e1001@email.com', 35, 'F', 3000000, '2025-01-10', 'Administrador');

CALL sv_pacientes.adicionar(1000, 1002, 'Paciente Componente', 'CC', '1000001002', '3001001002', 'p1002@email.com', 'F', '1996-01-01', 'Calle 1000 #1', 'Ninguna');

-- debe incluir los empleados 1000 (Farmaceutico) y 1001 (Administrador) y devolver 1 fila en administradores
BEGIN;
SELECT sv_empleados.consultar();
FETCH ALL IN cur_empleados;
COMMIT;
SELECT * FROM administradores WHERE id_admin = 1001;

CALL sv_empleados.modificar(1000, 2100000, NULL, '3009990000', NULL);

-- debe devolver salario 2100000 y telefono 3009990000
BEGIN;
SELECT sv_empleados.consultar(1000);
FETCH ALL IN cur_empleados;
COMMIT;

CALL sv_pacientes.modificar(1000, 'Carrera 1000 #2', 'Alergia', NULL, NULL);

-- debe devolver direccion Carrera 1000 #2 y restricciones Alergia
BEGIN;
SELECT sv_pacientes.consultar(1000);
FETCH ALL IN cur_pacientes;
COMMIT;

CALL sv_farmacias.modificar(1000, 'Farmacia Componentes Norte', NULL, NULL);
CALL sv_proveedores.modificar(1000, NULL, NULL, '3001002000', NULL);
CALL sv_medicamentos.modificar(1000, NULL, 5500.00, NULL, NULL);

-- debe devolver 1 fila de cada una con los valores nuevos y el inventario creado por el trigger
SELECT nombre FROM farmacias WHERE id_farmacia = 1000;
SELECT telefono FROM proveedores WHERE id_proveedor = 1000;
SELECT precio_unitario FROM medicamentos WHERE id_medicamento = 1000;
SELECT id_inventario FROM inventarios WHERE id_farmacia = 1000;

CALL sv_medicamentos.modificar(1000, NULL, 5000.00, NULL, NULL);

CALL sv_suministros.adicionar(1000, '2026-11-01', 1000, 1000, ARRAY[1000, 1001], ARRAY[100, 50], ARRAY[3500.00, 6000.00]);

-- debe devolver cantidad 150 y estado Pendiente
BEGIN;
SELECT sv_suministros.consultar(1000);
FETCH ALL IN cur_suministros;
COMMIT;

-- debe devolver subtotales 350000 y 300000
BEGIN;
SELECT sv_suministros.detalle(1000);
FETCH ALL IN cur_suministros_detalle;
COMMIT;

-- debe devolver el suministro 1000 pendiente hacia Farmacia Componentes Norte
BEGIN;
SELECT sv_suministros.pendientes(1000);
FETCH ALL IN cur_suministros_pendientes;
COMMIT;

CALL sv_suministros.recibir(1000, '2027-12-31');

-- debe devolver estado Recibido y 2 lotes nuevos con 100 y 50 unidades
SELECT estado FROM suministros WHERE id_suministro = 1000;
SELECT id_medicamento, cant_dispo, fecha_ven FROM lotes WHERE id_farmacia = 1000 ORDER BY id_medicamento;

-- debe devolver valor_total 650000 para Recibido
BEGIN;
SELECT sv_suministros.valor_por_estado(1000);
FETCH ALL IN cur_suministros_valor;
COMMIT;

CALL sv_suministros.adicionar(1001, '2026-11-02', 1000, 1000, ARRAY[1000], ARRAY[10], ARRAY[3500.00]);
CALL sv_suministros.cancelar(1001);

-- debe devolver Cancelado
SELECT estado FROM suministros WHERE id_suministro = 1001;

CALL sv_lotes.adicionar(5000, '2027-06-30', 20, 1000, 1000);
CALL sv_lotes.modificar(5000, NULL, 25);

-- debe devolver cant_dispo 25
BEGIN;
SELECT sv_lotes.consultar(5000);
FETCH ALL IN cur_lotes;
COMMIT;

CALL sv_ventas.adicionar(1000, 1000, 1000, 1000, 'Efectivo', ARRAY[1000, 1001], ARRAY[3, 2]);

-- debe devolver total 31000
BEGIN;
SELECT sv_ventas.consultar(1000);
FETCH ALL IN cur_ventas;
COMMIT;

-- debe devolver subtotales 15000 y 16000
BEGIN;
SELECT sv_ventas.detalle(1000);
FETCH ALL IN cur_ventas_detalle;
COMMIT;

-- debe devolver el stock descontado por lote: el que vence primero (5000) queda con 22, el otro de Componente Uno con 100 y el de Componente Dos con 48
BEGIN;
SELECT sv_lotes.inventario(1000);
FETCH ALL IN cur_lotes_inventario;
COMMIT;

-- debe incluir stock total 122 (Componente Uno) y 48 (Componente Dos)
BEGIN;
SELECT sv_lotes.stock_medicamento();
FETCH ALL IN cur_lotes_stock;
COMMIT;

-- debe incluir Medicamento Componente Dos con stock 48
BEGIN;
SELECT sv_lotes.stock_bajo(50);
FETCH ALL IN cur_lotes_stock_bajo;
COMMIT;

-- debe devolver los 3 lotes de la farmacia 1000 (vencen dentro de 600 dias)
BEGIN;
SELECT sv_lotes.por_vencer(600, 1000);
FETCH ALL IN cur_lotes_por_vencer;
COMMIT;

-- debe devolver Farmacia Componentes Norte con 122 unidades
BEGIN;
SELECT sv_lotes.disponibilidad('componente uno');
FETCH ALL IN cur_lotes_disponibilidad;
COMMIT;

-- debe devolver la compra del paciente 1000 con 2 lineas
BEGIN;
SELECT sv_pacientes.historial_compras(1000);
FETCH ALL IN cur_pacientes_historial;
COMMIT;

-- debe devolver 1 venta de Efectivo por 31000 en Farmacia Componentes Norte
BEGIN;
SELECT sv_ventas.ventas_mes(1000);
FETCH ALL IN cur_ventas_mes;
COMMIT;

-- debe devolver 1 venta y 31000 para el empleado 1000
BEGIN;
SELECT sv_empleados.ventas_por_empleado(1000);
FETCH ALL IN cur_empleados_ventas;
COMMIT;

-- debe incluir 3 unidades de Componente Uno y 2 de Componente Dos
BEGIN;
SELECT sv_medicamentos.mas_vendidos(100);
FETCH ALL IN cur_medicamentos_mas_vendidos;
COMMIT;

-- debe devolver 1001 y 1000
BEGIN;
SELECT sv_medicamentos.recientes(2);
FETCH ALL IN cur_medicamentos_recientes;
COMMIT;

BEGIN;
SELECT sv_medicamentos.consultar(1000);
FETCH ALL IN cur_medicamentos;
SELECT sv_farmacias.consultar(1000);
FETCH ALL IN cur_farmacias;
SELECT sv_proveedores.consultar(1000);
FETCH ALL IN cur_proveedores;
COMMIT;

CALL sv_pacientes.adicionar(1001, 1003, 'Paciente Sin Ventas', 'CC', '1000001003', '3001001003', 'p1003@email.com', 'M', '2000-05-10', 'Calle 1001 #1', 'Ninguna');
CALL sv_pacientes.eliminar(1001);

-- debe devolver 0 filas (el paciente y su persona se borran)
SELECT 1 FROM pacientes WHERE id_paciente = 1001
UNION ALL
SELECT 1 FROM personas WHERE id_persona = 1003;

-- al eliminar el administrador, se borra su registro en administradores y la persona
CALL sv_empleados.eliminar(1001);

-- debe devolver 0 filas
SELECT * FROM administradores WHERE id_admin = 1001;
SELECT * FROM personas WHERE id_persona = 1001;

CALL sv_lotes.eliminar(5000);

-- debe devolver 0 filas
SELECT * FROM lotes WHERE id_lote = 5000;

CALL sv_medicamentos.adicionar(1002, 'Medicamento Componente Tres', 3000.00, 'Antibiotico', 'Oral');
CALL sv_medicamentos.eliminar(1002);
CALL sv_proveedores.adicionar(1001, 'Proveedor Componentes Dos', '900100002-0', '3001001001', 'Calle 1001');
CALL sv_proveedores.eliminar(1001);
CALL sv_farmacias.adicionar(1001, 'Farmacia Componentes Dos', 'Calle 1001', '3101001001');
CALL sv_farmacias.eliminar(1001);

-- debe devolver 0 filas
SELECT 1 FROM medicamentos WHERE id_medicamento = 1002
UNION ALL
SELECT 1 FROM proveedores WHERE id_proveedor = 1001
UNION ALL
SELECT 1 FROM farmacias WHERE id_farmacia = 1001
UNION ALL
SELECT 1 FROM inventarios WHERE id_farmacia = 1001;


-- COMPONENTESNOOK

-- si falla la segunda sentencia, la persona tampoco queda registrada (salario debe ser mayor que 0)
CALL sv_empleados.adicionar(1100, 1100, 'Empleado Nook', 'CC', '1000001100', '3001001100', 'e1100@email.com', 30, 'M', 0, '2025-01-10', 'Farmaceutico');

-- debe devolver 0 filas
SELECT * FROM personas WHERE id_persona = 1100;

-- id_paciente duplicado: la persona nueva no queda registrada
CALL sv_pacientes.adicionar(1, 1101, 'Paciente Nook', 'CC', '1000001101', '3001001101', 'p1101@email.com', 'F', '1996-01-01', 'Calle 1101', 'Ninguna');

-- debe devolver 0 filas
SELECT * FROM personas WHERE id_persona = 1101;

-- fecha de nacimiento futura
CALL sv_pacientes.adicionar(1102, 1102, 'Paciente Futuro', 'CC', '1000001102', '3001001102', 'p1102@email.com', 'F', '2099-01-01', 'Calle 1102', 'Ninguna');

-- cargo fuera del dominio
CALL sv_empleados.adicionar(1103, 1103, 'Empleado Cargo', 'CC', '1000001103', '3001001103', 'e1103@email.com', 30, 'M', 2000000, '2025-01-10', 'Inexistente');

-- documento duplicado
CALL sv_empleados.adicionar(1104, 1104, 'Empleado Duplicado', 'CC', '1000001000', '3001001104', 'e1104@email.com', 30, 'M', 2000000, '2025-01-10', 'Cajero');

-- NIT con formato invalido y NIT duplicado
CALL sv_proveedores.adicionar(1100, 'Proveedor Nook', '123', '3001001100', 'Calle 1100');
CALL sv_proveedores.adicionar(1101, 'Proveedor Nook', '900100001-0', '3001001101', 'Calle 1101');

-- precio no positivo y nombre de medicamento repetido
CALL sv_medicamentos.adicionar(1100, 'Medicamento Precio Cero', 0, 'Analgesico', 'Oral');
CALL sv_medicamentos.adicionar(1101, 'medicamento componente uno', 5000.00, 'Analgesico', 'Oral');

-- no se puede eliminar una farmacia con stock
CALL sv_farmacias.eliminar(1000);

-- no se puede eliminar un empleado que registro ventas
CALL sv_empleados.eliminar(1000);

-- no se puede eliminar un medicamento con ventas
CALL sv_medicamentos.eliminar(1000);

-- no se puede eliminar un proveedor con suministros
CALL sv_proveedores.eliminar(1000);

-- registros inexistentes
CALL sv_empleados.modificar(9999, 1, NULL, NULL, NULL);
CALL sv_pacientes.eliminar(9999);
CALL sv_suministros.cancelar(9999);

-- lote vencido y cantidad negativa
CALL sv_lotes.adicionar(5100, '2020-01-01', 10, 1000, 1000);
CALL sv_lotes.adicionar(5101, '2027-12-31', -5, 1000, 1000);

-- un suministro ya recibido no se puede recibir ni cancelar
CALL sv_suministros.recibir(1000, '2027-12-31');
CALL sv_suministros.cancelar(1000);

-- cantidad en 0: el suministro no queda registrado
CALL sv_suministros.adicionar(1100, '2026-11-03', 1000, 1000, ARRAY[1000], ARRAY[0], ARRAY[3500.00]);

-- arreglos de distinto tamano
CALL sv_suministros.adicionar(1101, '2026-11-03', 1000, 1000, ARRAY[1000, 1001], ARRAY[10], ARRAY[3500.00]);

-- debe devolver 0 filas
SELECT * FROM suministros WHERE id_suministro IN (1100, 1101);

-- stock insuficiente: la venta no queda registrada y el stock no cambia
CALL sv_ventas.adicionar(1100, 1000, 1000, NULL, 'Efectivo', ARRAY[1000, 1001], ARRAY[5, 999]);

-- empleado con cargo no autorizado para vender
CALL sv_ventas.adicionar(1101, 1000, 1, NULL, 'Efectivo', ARRAY[1000], ARRAY[1]);

-- medicamento inexistente y metodo de pago fuera del dominio
CALL sv_ventas.adicionar(1102, 1000, 1000, NULL, 'Efectivo', ARRAY[9999], ARRAY[1]);
CALL sv_ventas.adicionar(1103, 1000, 1000, NULL, 'Bitcoin', ARRAY[1000], ARRAY[1]);

-- debe devolver 0 filas y stock 100 y 48 sin cambios
SELECT * FROM ventas WHERE id_venta IN (1100, 1101, 1102, 1103);
SELECT id_medicamento, cant_dispo FROM lotes WHERE id_farmacia = 1000 ORDER BY id_medicamento;