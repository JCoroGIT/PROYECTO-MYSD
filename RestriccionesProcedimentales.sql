
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
SELECT id_lote FROM lotes WHERE id_farmacia = 310;

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


INSERT INTO farmacias VALUES (800, 'Farmacia Total', 'Calle 800', '3100000800');

INSERT INTO personas VALUES (800, 'Persona Total', 'CC', '1000000800', '3000000800', 'p800@email.com', 30, 'M');

INSERT INTO empleados VALUES (800, 2000000, '2025-01-10', 'Farmaceutico', 800);

INSERT INTO medicamentos VALUES
(800, 'Medicamento Total Uno', 5000.00, 'Analgesico', 'Oral'),
(801, 'Medicamento Total Dos', 8000.00, 'Antialergico', 'Oral');

INSERT INTO lotes VALUES
(800, '2027-12-31', 100, 800, 800),
(801, '2027-12-31', 100, 801, 800);

INSERT INTO ventas VALUES (800, CURRENT_DATE, 0, 'Efectivo', 800, NULL, 800);

-- al agregar lineas, el total es la suma del detalle
INSERT INTO ventas_medicamentos VALUES (800, 800, 2, 5000.00);
INSERT INTO ventas_medicamentos VALUES (800, 801, 1, 8000.00);

-- debe devolver 18000
SELECT id_venta, total FROM ventas WHERE id_venta = 800;

-- al cambiar una linea, el total se recalcula
UPDATE ventas_medicamentos SET cantidad = 3 WHERE id_venta = 800 AND id_medicamento = 800;

-- debe devolver 23000
SELECT id_venta, total FROM ventas WHERE id_venta = 800;

-- al borrar una linea, el total se recalcula
DELETE FROM ventas_medicamentos WHERE id_venta = 800 AND id_medicamento = 801;

-- debe devolver 15000
SELECT id_venta, total FROM ventas WHERE id_venta = 800;

-- al cambiar el id de la venta, el total se conserva
UPDATE ventas SET id_venta = 810 WHERE id_venta = 800;

-- debe devolver 15000
SELECT id_venta, total FROM ventas WHERE id_venta = 810;

-- una venta sin detalle conserva total 0
INSERT INTO ventas VALUES (811, CURRENT_DATE, 0, 'Efectivo', 800, NULL, 800);

-- debe devolver 0
SELECT id_venta, total FROM ventas WHERE id_venta = 811;

-- al borrar la venta, su detalle se borra sin error
DELETE FROM ventas WHERE id_venta = 810;

-- debe devolver 0 filas
SELECT * FROM ventas_medicamentos WHERE id_venta = 810;

-- DISPARADORESNOOK

INSERT INTO ventas VALUES (820, CURRENT_DATE, 0, 'Efectivo', 800, NULL, 800);

INSERT INTO ventas_medicamentos VALUES (820, 800, 2, 5000.00);

-- no se puede poner a mano un total distinto al del detalle
UPDATE ventas SET total = 1 WHERE id_venta = 820;

-- no se puede poner un total a una venta sin detalle
UPDATE ventas SET total = 5000 WHERE id_venta = 811;

-- debe seguir en 10000
SELECT id_venta, total FROM ventas WHERE id_venta = 820;
