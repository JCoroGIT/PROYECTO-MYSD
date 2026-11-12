"""
Generador de datos de prueba para el sistema de gestión de farmacia.
Genera un archivo .sql con sentencias INSERT para PostgreSQL.
"""

import argparse
import random
import sys
import unicodedata
from dataclasses import dataclass
from datetime import date, timedelta
from typing import Dict, List, Sequence, Set, Tuple


@dataclass
class DatabaseConfig:
    """Configuración para la generación de datos"""
    num_personas: int

    @property
    def num_farmacias(self) -> int:
        return max(3, self.num_personas // 1000)

    @property
    def num_proveedores(self) -> int:
        return max(5, self.num_personas // 200)

    @property
    def num_empleados(self) -> int:
        return max(2, self.num_personas // 10)

    @property
    def num_administradores(self) -> int:
        return min(self.num_empleados - 1,
                   max(self.num_farmacias, self.num_empleados // 20))

    @property
    def num_pacientes(self) -> int:
        return self.num_personas - self.num_empleados

    @property
    def num_medicamentos(self) -> int:
        return max(10, self.num_personas // 100)

    @property
    def num_suministros(self) -> int:
        return self.num_personas // 5

    @property
    def num_ventas(self) -> int:
        return self.num_personas


def sin_acentos(texto: str) -> str:
    normalizado = unicodedata.normalize("NFKD", texto)
    return normalizado.encode("ascii", "ignore").decode("ascii")


def calcular_edad(nacimiento: date, hoy: date) -> int:
    return hoy.year - nacimiento.year - ((hoy.month, hoy.day) < (nacimiento.month, nacimiento.day))


def repartir(total: int, partes: int) -> List[int]:
    cortes = sorted(random.randint(0, total) for _ in range(partes - 1))
    limites = [0] + cortes + [total]
    return [limites[i + 1] - limites[i] for i in range(partes)]


def lit(valor) -> str:
    """Convierte un valor de Python en un literal SQL"""
    if valor is None:
        return "NULL"
    if isinstance(valor, (int, float)):
        return str(valor)
    if isinstance(valor, date):
        return f"'{valor.isoformat()}'"
    return "'" + str(valor).replace("'", "''") + "'"


class DataGenerator:
    """Generador de datos aleatorios para la base de datos"""

    NOMBRES_F = [
        "Carmen", "Daniela", "Paula", "Sofia", "Alba", "Juliana", "Marta", "María",
        "Helena", "Adriana", "Ana", "Ivanna", "Laura", "Lara", "Lorena", "Patricia",
        "Noa", "Mia"
    ]

    NOMBRES_M = [
        "Martin", "Juan", "Sebastian", "Roberto", "Jose", "Nacho", "Miguel", "Diego",
        "Carlos", "Gustavo", "Hector", "Marcos", "Alfonso", "Oscar", "Fernando",
        "Ricardo", "Agustin", "German", "Nestor", "Alvaro", "Alfredo", "Ruben",
        "Vicente", "Rafael", "Victor", "Silvestre", "Berto", "Enrique", "Luis",
        "Elias", "Bruno", "Javier", "Darío", "Daniel", "Santiago", "Rodrigo",
        "Guillermo", "Cristian", "Jorge", "Arturo", "Pablo", "Borja", "Ivan", "Pedro"
    ]

    APELLIDOS = [
        "Rodriguez", "Gomez", "Lopez", "Gonzalez", "Garcia", "Galeano", "Martinez",
        "Villamil", "Bermudez", "Rubio", "Pinto", "Ramirez", "Marín", "Sanchez",
        "Hernandez", "Diaz", "Perez", "Torres", "Rojas", "Vargas", "Moreno",
        "Gutierrez", "Jimenez", "Muñoz", "Castro", "Ortiz", "Alvarez", "Ruiz",
        "Suarez", "Romero", "Herrera", "Valencia", "Quintero", "Restrepo", "Giraldo",
        "Morales", "Mejia", "Arias", "Parra", "Jaramillo", "Cardenas", "Osorio",
        "Castillo", "Salazar", "Cardona", "Florez", "Medina", "Rivera", "Montoya",
        "Cortes", "Correa", "Marin", "Rincon", "Zapata", "Escobar", "Velasquez"
    ]

    DOMINIOS = ["gmail.com", "hotmail.com", "yahoo.com", "outlook.com"]

    EMPRESAS = [
        "Distrimedica", "Farmaplus", "Medisur", "Biofarma", "Vitalmed", "Droguinter",
        "Pharmaser", "Salufarma", "Medilab", "Novafarma", "Laboralis", "Prodisalud",
        "Medicorp", "Farmanorte", "Drogacentro", "Interfarma", "Medicaribe",
        "Saludvital", "Biomedica", "Farmaandes"
    ]
    SUFIJOS = ["SAS", "Ltda", "S.A."]

    SEDES = [
        "Central", "Norte", "Sur", "Oriente", "Occidente", "Chapinero", "Usaquen",
        "Kennedy", "Suba", "Fontibon", "Teusaquillo", "Engativa", "Bosa", "Centro",
        "Salitre"
    ]

    RESTRICCIONES = ["Ninguna", "Alergia", "Especial", "Diabetes", "Hipertension",
                     "Cardiaca", "Renal", "Hepatica", "Respiratoria", "Neurologica"]
    PESOS_RESTRICCIONES = [55, 12, 4, 7, 8, 4, 3, 2, 3, 2]

    CARGOS_NO_ADMIN = ["Farmaceutico", "Cajero", "Auxiliar"]
    PESOS_CARGOS = [40, 40, 20]
    CARGOS_VENDEDORES = ("Farmaceutico", "Cajero")

    METODOS_PAGO = ["Efectivo", "Tarjeta", "Transferencia"]
    PESOS_METODOS = [50, 35, 15]

    CATALOGO = [
        ("Acetaminofen", "Analgesico", "Oral", ["500mg", "1g"]),
        ("Tramadol", "Analgesico", "Oral", ["50mg", "100mg"]),
        ("Ketorolaco", "Analgesico", "Inyectable", ["30mg"]),
        ("Fentanilo", "Analgesico", "Transdermico", ["25mcg"]),
        ("Ibuprofeno", "Antiinflamatorio", "Oral", ["400mg", "600mg"]),
        ("Naproxeno", "Antiinflamatorio", "Oral", ["250mg", "500mg"]),
        ("Diclofenaco", "Antiinflamatorio", "Oral", ["50mg"]),
        ("Diclofenaco", "Antiinflamatorio", "Inyectable", ["75mg"]),
        ("Dexametasona", "Antiinflamatorio", "Inyectable", ["4mg", "8mg"]),
        ("Dipirona", "Antipiretico", "Oral", ["500mg"]),
        ("Amoxicilina", "Antibiotico", "Oral", ["500mg", "875mg"]),
        ("Azitromicina", "Antibiotico", "Oral", ["500mg"]),
        ("Ciprofloxacino", "Antibiotico", "Oral", ["500mg"]),
        ("Cefalexina", "Antibiotico", "Oral", ["500mg"]),
        ("Ceftriaxona", "Antibiotico", "Inyectable", ["1g"]),
        ("Loratadina", "Antihistaminico", "Oral", ["10mg"]),
        ("Clorfeniramina", "Antihistaminico", "Oral", ["4mg"]),
        ("Cetirizina", "Antialergico", "Oral", ["10mg"]),
        ("Hioscina", "Antiespasmodico", "Oral", ["10mg"]),
        ("Fluoxetina", "Antidepresivo", "Oral", ["20mg"]),
        ("Sertralina", "Antidepresivo", "Oral", ["50mg", "100mg"]),
        ("Carbamazepina", "Anticonvulsivo", "Oral", ["200mg", "400mg"]),
        ("Fenitoina", "Anticonvulsivo", "Oral", ["100mg"]),
        ("Fluconazol", "Antimicotico", "Oral", ["150mg"]),
        ("Clotrimazol", "Antimicotico", "Topico", ["1%"]),
        ("Aciclovir", "Antiviral", "Oral", ["400mg"]),
        ("Oseltamivir", "Antiviral", "Oral", ["75mg"]),
        ("Albendazol", "Antiparasitario", "Oral", ["400mg"]),
        ("Ivermectina", "Antiparasitario", "Oral", ["6mg"]),
        ("Lidocaina", "Anestesia", "Inyectable", ["2%"]),
        ("Lidocaina gel", "Anestesia", "Topico", ["2%"]),
        ("Losartan", "Cardiovascular", "Oral", ["50mg", "100mg"]),
        ("Enalapril", "Cardiovascular", "Oral", ["10mg", "20mg"]),
        ("Atenolol", "Cardiovascular", "Oral", ["50mg"]),
        ("Nitroglicerina", "Cardiovascular", "Transdermico", ["5mg"]),
        ("Salbutamol", "Respiratorio", "Inhalatoria", ["100mcg"]),
        ("Budesonida", "Respiratorio", "Inhalatoria", ["200mcg"]),
        ("Omeprazol", "Gastrointestinal", "Oral", ["20mg", "40mg"]),
        ("Pantoprazol", "Gastrointestinal", "Oral", ["40mg"]),
        ("Metoclopramida", "Gastrointestinal", "Oral", ["10mg"]),
        ("Metformina", "Endocrino", "Oral", ["500mg", "850mg"]),
        ("Glibenclamida", "Endocrino", "Oral", ["5mg"]),
        ("Levotiroxina", "Endocrino", "Oral", ["50mcg", "100mcg"]),
        ("Insulina NPH", "Endocrino", "Inyectable", ["100UI"]),
        ("Hidrocortisona", "Dermatologico", "Topico", ["1%"]),
        ("Betametasona", "Dermatologico", "Topico", ["0.05%"]),
        ("Cloranfenicol", "Oftalmologico", "Topico", ["0.5%"]),
        ("Tobramicina", "Oftalmologico", "Topico", ["0.3%"]),
    ]

    RANGO_PRECIO = {
        "Oral": (800, 25000),
        "Inyectable": (2500, 30000),
        "Topico": (4000, 35000),
        "Transdermico": (15000, 90000),
        "Inhalatoria": (18000, 85000),
    }

    @classmethod
    def productos(cls) -> List[Tuple[str, str, str]]:
        """Combina nombre y presentación; el nombre debe ser único sin importar mayúsculas"""
        resultado = []
        vistos = set()
        for base, tipo, via, presentaciones in cls.CATALOGO:
            for presentacion in presentaciones:
                nombre = f"{base} {presentacion}"
                if nombre.lower() not in vistos:
                    vistos.add(nombre.lower())
                    resultado.append((nombre, tipo, via))
        return resultado

    @classmethod
    def generar_nombre(cls, sexo: str) -> str:
        if sexo == "M":
            return random.choice(cls.NOMBRES_M)
        if sexo == "F":
            return random.choice(cls.NOMBRES_F)
        return random.choice(cls.NOMBRES_M + cls.NOMBRES_F)

    @staticmethod
    def generar_cedula() -> int:
        return random.randint(1000000000, 9999999999)

    @staticmethod
    def generar_telefono_movil() -> str:
        return f"3{random.randint(0, 2)}{random.randint(10000000, 99999999)}"

    @staticmethod
    def generar_telefono_fijo() -> str:
        return f"60{random.randint(1, 8)}{random.randint(1000000, 9999999)}"

    @staticmethod
    def generar_direccion() -> str:
        inicio = random.choice(["Calle", "Carrera", "Avenida"])
        return f"{inicio} {random.randint(1, 205)}#{random.randint(1, 25)}-{random.randint(1, 25)}"

    @staticmethod
    def generar_correo(nombre: str, apellido: str, id_persona: int) -> str:
        dominio = random.choice(DataGenerator.DOMINIOS)
        return f"{sin_acentos(nombre).lower()}.{sin_acentos(apellido).lower()}{id_persona}@{dominio}"

    @staticmethod
    def generar_fecha_nacimiento(hoy: date, edad: int) -> date:
        return hoy - timedelta(days=int(edad * 365.25) + random.randint(1, 364))

    @staticmethod
    def generar_tipo_documento(edad: int) -> str:
        if edad < 18:
            return "TI"
        return random.choices(["CC", "CE", "PPT"], weights=[85, 10, 5])[0]


class FarmaciaDBPopulator:
    """Clase principal para poblar la base de datos de farmacia"""

    def __init__(self, config: DatabaseConfig, salida):
        self.config = config
        self.generator = DataGenerator()
        self.salida = salida
        self.hoy = date.today()

        self.documentos_usados: Set[int] = set()
        self.nits_usados: Set[str] = set()
        self.personas: List[Tuple[int, str, date, int]] = []
        self.ids_empleados: List[int] = []
        self.cargo_empleado: Dict[int, str] = {}
        self.contratacion: Dict[int, date] = {}
        self.ids_pacientes: List[int] = []
        self.ids_proveedores: List[int] = []
        self.ids_farmacias: List[int] = []
        self.precios_medicamento: Dict[int, int] = {}
        self.ventas: List[Tuple] = []
        self.detalles_venta: List[Tuple] = []
        self.demanda: Dict[Tuple[int, int], int] = {}
        self.conteo: Dict[str, int] = {}

    def seccion(self, titulo: str):
        self.salida.write(f"\n-- {titulo}\n")

    def insertar(self, tabla: str, columnas: Sequence[str], valores: Sequence, ignorar_duplicado: bool = False):
        cols = ", ".join(columnas)
        vals = ", ".join(lit(v) for v in valores)
        sufijo = " ON CONFLICT DO NOTHING" if ignorar_duplicado else ""
        self.salida.write(f"INSERT INTO {tabla} ({cols}) VALUES ({vals}){sufijo};\n")
        self.conteo[tabla] = self.conteo.get(tabla, 0) + 1

    def documento_unico(self) -> str:
        while True:
            cedula = self.generator.generar_cedula()
            if cedula not in self.documentos_usados:
                self.documentos_usados.add(cedula)
                return str(cedula)

    def generar_personas(self):
        self.seccion("PERSONA")
        roles = ["E"] * self.config.num_empleados + ["P"] * self.config.num_pacientes
        random.shuffle(roles)

        for id_persona, rol in enumerate(roles, start=1):
            sexo = random.choices(["M", "F", "O"], weights=[48, 48, 4])[0]
            nombre = self.generator.generar_nombre(sexo)
            apellido = random.choice(self.generator.APELLIDOS)
            edad_objetivo = random.randint(20, 65) if rol == "E" else random.randint(7, 90)
            nacimiento = self.generator.generar_fecha_nacimiento(self.hoy, edad_objetivo)
            edad = calcular_edad(nacimiento, self.hoy)

            self.personas.append((id_persona, rol, nacimiento, edad))
            self.insertar(
                "personas",
                ["id_persona", "nombre", "tipo_documento", "documento", "telefono", "email", "edad", "sexo"],
                [id_persona, f"{nombre} {apellido}",
                 self.generator.generar_tipo_documento(edad),
                 self.documento_unico(),
                 self.generator.generar_telefono_movil(),
                 self.generator.generar_correo(nombre, apellido, id_persona),
                 edad, sexo],
            )

    def generar_empleados(self):
        self.seccion("EMPLEADO")
        personas_empleado = [p for p in self.personas if p[1] == "E"]
        primer_no_admin = self.config.num_administradores + 1

        for id_empleado, (id_persona, _, _, edad) in enumerate(personas_empleado, start=1):
            if id_empleado < primer_no_admin:
                cargo = "Administrador"
                salario = random.randrange(3500000, 7000001, 50000)
            else:
                if id_empleado == primer_no_admin:
                    cargo = "Farmaceutico"
                else:
                    cargo = random.choices(self.generator.CARGOS_NO_ADMIN,
                                           weights=self.generator.PESOS_CARGOS)[0]
                salario = random.randrange(1500000, 3500001, 50000)

            max_anios = min(edad - 19, 20)
            dias = random.randint(30, max(31, max_anios * 365))
            contratacion = self.hoy - timedelta(days=dias)

            self.ids_empleados.append(id_empleado)
            self.cargo_empleado[id_empleado] = cargo
            self.contratacion[id_empleado] = contratacion
            self.insertar(
                "empleados",
                ["id_empleado", "salario", "fecha_contratacion", "cargo", "id_persona"],
                [id_empleado, salario, contratacion, cargo, id_persona],
            )

    def generar_administradores(self):
        self.seccion("ADMINISTRADOR")
        for id_empleado in self.ids_empleados:
            if self.cargo_empleado[id_empleado] == "Administrador":
                self.insertar("administradores", ["id_admin"], [id_empleado], ignorar_duplicado=True)

    def generar_pacientes(self):
        self.seccion("PACIENTE")
        personas_paciente = [p for p in self.personas if p[1] == "P"]

        for id_paciente, (id_persona, _, nacimiento, _) in enumerate(personas_paciente, start=1):
            restriccion = random.choices(self.generator.RESTRICCIONES,
                                         weights=self.generator.PESOS_RESTRICCIONES)[0]
            self.ids_pacientes.append(id_paciente)
            self.insertar(
                "pacientes",
                ["id_paciente", "fecha_nac", "direccion", "restricciones", "id_persona"],
                [id_paciente, nacimiento, self.generator.generar_direccion(),
                 restriccion, id_persona],
            )

    def generar_proveedores(self):
        self.seccion("PROVEEDOR")
        combinaciones = [f"{e} {s}" for e in self.generator.EMPRESAS for s in self.generator.SUFIJOS]
        k = self.config.num_proveedores
        nombres = random.sample(combinaciones, min(k, len(combinaciones)))
        nombres += [random.choice(combinaciones) for _ in range(k - len(nombres))]

        for id_proveedor, nombre in enumerate(nombres, start=1):
            while True:
                nit = f"{random.randint(800000000, 999999999)}-{random.randint(0, 9)}"
                if nit not in self.nits_usados:
                    self.nits_usados.add(nit)
                    break
            self.ids_proveedores.append(id_proveedor)
            self.insertar(
                "proveedores",
                ["id_proveedor", "nombre", "nit", "telefono", "direccion"],
                [id_proveedor, nombre, nit, self.generator.generar_telefono_fijo(),
                self.generator.generar_direccion()],
            )

    def generar_farmacias(self):
        self.seccion("FARMACIA")
        sedes = self.generator.SEDES
        for i in range(self.config.num_farmacias):
            id_farmacia = i + 1
            nombre = f"Farmacia {sedes[i]}" if i < len(sedes) else f"Farmacia {id_farmacia}"
            self.ids_farmacias.append(id_farmacia)
            self.insertar(
                "farmacias",
                ["id_farmacia", "nombre", "direccion", "telefono"],
                [id_farmacia, nombre, self.generator.generar_direccion(),
                 self.generator.generar_telefono_fijo()],
            )

    def generar_inventarios(self):
        self.seccion("INVENTARIO")
        for id_farmacia in self.ids_farmacias:
            actualizacion = self.hoy - timedelta(days=random.randint(0, 30))
            self.insertar(
                "inventarios",
                ["id_inventario", "fecha_actualizacion", "id_farmacia"],
                [id_farmacia, actualizacion, id_farmacia],
                ignorar_duplicado=True,
            )

    def generar_medicamentos(self):
        self.seccion("MEDICAMENTO")
        productos = self.generator.productos()
        seleccion = random.sample(productos, min(self.config.num_medicamentos, len(productos)))

        for id_medicamento, (nombre, tipo, via) in enumerate(seleccion, start=1):
            minimo, maximo = self.generator.RANGO_PRECIO[via]
            precio = random.randrange(minimo, maximo + 1, 100)
            self.precios_medicamento[id_medicamento] = precio
            self.insertar(
                "medicamentos",
                ["id_medicamento", "nombre", "precio_unitario", "tipo_medicamento", "via_uso"],
                [id_medicamento, nombre, precio, tipo, via],
            )

    def planear_ventas(self):
        vendedores = [e for e in self.ids_empleados
                      if self.cargo_empleado[e] in self.generator.CARGOS_VENDEDORES]
        ids_medicamentos = list(self.precios_medicamento)

        for id_venta in range(1, self.config.num_ventas + 1):
            id_empleado = random.choice(vendedores)
            inicio = max(self.contratacion[id_empleado], self.hoy - timedelta(days=730))
            fecha = inicio + timedelta(days=random.randint(0, (self.hoy - inicio).days))
            metodo = random.choices(self.generator.METODOS_PAGO,
                                    weights=self.generator.PESOS_METODOS)[0]
            id_paciente = random.choice(self.ids_pacientes) if random.random() < 0.7 else None
            id_farmacia = random.choice(self.ids_farmacias)

            total = 0
            for id_medicamento in random.sample(ids_medicamentos, random.randint(1, 5)):
                cantidad = random.randint(1, 5)
                precio = self.precios_medicamento[id_medicamento]
                total += cantidad * precio
                self.detalles_venta.append((id_venta, id_medicamento, cantidad, precio))
                clave = (id_farmacia, id_medicamento)
                self.demanda[clave] = self.demanda.get(clave, 0) + cantidad

            self.ventas.append((id_venta, fecha, total, metodo,
                                id_farmacia, id_paciente, id_empleado))

    def generar_lotes(self):
        self.seccion("LOTE")
        id_lote = 0
        for id_farmacia in self.ids_farmacias:
            for id_medicamento in self.precios_medicamento:
                vendido = self.demanda.get((id_farmacia, id_medicamento), 0)
                stock_final = random.randint(0, 300)
                num_lotes = random.randint(1, 3)
                for cantidad in repartir(vendido + stock_final, num_lotes):
                    id_lote += 1
                    vencimiento = self.hoy + timedelta(days=random.randint(10, 1100))
                    self.insertar(
                        "lotes",
                        ["id_lote", "fecha_ven", "cant_dispo", "id_medicamento", "id_farmacia"],
                        [id_lote, vencimiento, cantidad, id_medicamento, id_farmacia],
                    )

    def generar_suministros(self):
        self.seccion("SUMINISTRO")
        ids_medicamentos = list(self.precios_medicamento)
        suministros = []
        detalles = []
        estados_finales: Dict[str, List[int]] = {"Recibido": [], "Cancelado": []}

        for id_suministro in range(1, self.config.num_suministros + 1):
            estado = random.choices(["Recibido", "Pendiente", "Cancelado"], weights=[75, 15, 10])[0]
            dias = random.randint(0, 30) if estado == "Pendiente" else random.randint(0, 1095)
            fecha = self.hoy - timedelta(days=dias)

            cantidad_total = 0
            for id_medicamento in random.sample(ids_medicamentos, random.randint(2, 6)):
                cantidad = random.randint(10, 200)
                costo = max(100, int(self.precios_medicamento[id_medicamento]
                                     * random.uniform(0.55, 0.8) // 100) * 100)
                detalles.append((id_suministro, id_medicamento, cantidad, costo))
                cantidad_total += cantidad

            suministros.append((id_suministro, fecha, cantidad_total, "Pendiente",
                                random.choice(self.ids_proveedores),
                                random.choice(self.ids_farmacias)))
            if estado != "Pendiente":
                estados_finales[estado].append(id_suministro)

        for fila in suministros:
            self.insertar(
                "suministros",
                ["id_suministro", "fecha", "cantidad", "estado", "id_proveedor", "id_farmacia"],
                fila,
            )

        self.seccion("SUMINISTRO_MEDICAMENTO")
        for fila in detalles:
            self.insertar(
                "suministros_medicamentos",
                ["id_suministro", "id_medicamento", "cantidad_med", "precio_suministro"],
                fila,
            )

        self.seccion("ESTADO FINAL DE SUMINISTROS")
        for estado, ids in estados_finales.items():
            for i in range(0, len(ids), 500):
                bloque = ", ".join(str(x) for x in ids[i:i + 500])
                self.salida.write(
                    f"UPDATE suministros SET estado = {lit(estado)} WHERE id_suministro IN ({bloque});\n")

    def generar_ventas(self):
        self.seccion("VENTA")
        for fila in self.ventas:
            self.insertar(
                "ventas",
                ["id_venta", "fecha", "total", "metodo_pago", "id_farmacia", "id_paciente", "id_empleado"],
                fila,
            )

        self.seccion("VENTA_MEDICAMENTO")
        for fila in self.detalles_venta:
            self.insertar(
                "ventas_medicamentos",
                ["id_venta", "id_medicamento", "cantidad", "precio_unitario"],
                fila,
            )

    def poblar_base_datos(self):
        self.salida.write("-- Script de población de base de datos de farmacia\n")
        self.salida.write(f"-- Generando {self.config.num_personas} personas como registros base\n")
        self.salida.write("SET client_encoding = 'UTF8';\nBEGIN;\n")

        self.generar_personas()
        self.generar_empleados()
        self.generar_administradores()
        self.generar_pacientes()
        self.generar_proveedores()
        self.generar_farmacias()
        self.generar_inventarios()
        self.generar_medicamentos()
        self.planear_ventas()
        self.generar_lotes()
        self.generar_suministros()
        self.generar_ventas()

        self.salida.write("\nCOMMIT;\n")
        self.salida.write("-- Población completada exitosamente\n")


def main():
    parser = argparse.ArgumentParser(description="Genera INSERTs para poblar la base de datos de farmacia")
    parser.add_argument("registros", nargs="?", type=int,
                        help="cantidad de personas base; el resto de tablas se escala a partir de ella")
    parser.add_argument("-o", "--salida", default="poblar_farmacia.sql",
                        help="archivo SQL de salida (por defecto poblar_farmacia.sql)")
    parser.add_argument("--semilla", type=int, default=None,
                        help="semilla para obtener siempre los mismos datos")
    args = parser.parse_args()

    try:
        n = args.registros if args.registros is not None else int(input("Cantidad de registros a generar: "))
        if n < 10:
            raise ValueError
    except ValueError:
        print("Error: debe ingresar un número entero mayor o igual a 10", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nOperación cancelada por el usuario", file=sys.stderr)
        sys.exit(1)

    if args.semilla is not None:
        random.seed(args.semilla)

    with open(args.salida, "w", encoding="utf-8") as archivo:
        populator = FarmaciaDBPopulator(DatabaseConfig(num_personas=n), archivo)
        populator.poblar_base_datos()

    print(f"Archivo generado: {args.salida}", file=sys.stderr)
    for tabla, cantidad in populator.conteo.items():
        print(f"  {tabla}: {cantidad}", file=sys.stderr)
    print(f"  TOTAL: {sum(populator.conteo.values())}", file=sys.stderr)


if __name__ == "__main__":
    main()