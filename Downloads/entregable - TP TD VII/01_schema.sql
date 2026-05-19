-- ============================================================
-- RUAT – Registro Único de Accidentes de Tránsito
-- Script de creación de tablas y restricciones
-- ============================================================

DROP TABLE IF EXISTS participacion_vehicular CASCADE;
DROP TABLE IF EXISTS victima_no_vehicular CASCADE;
DROP TABLE IF EXISTS testimonio CASCADE;
DROP TABLE IF EXISTS vehiculo_involucrado CASCADE;
DROP TABLE IF EXISTS habilitacion_conduccion CASCADE;
DROP TABLE IF EXISTS informe_tecnico CASCADE;
DROP TABLE IF EXISTS infraccion CASCADE;
DROP TABLE IF EXISTS antecedente_penal CASCADE;
DROP TABLE IF EXISTS licencia CASCADE;
DROP TABLE IF EXISTS siniestro CASCADE;
DROP TABLE IF EXISTS vehiculo CASCADE;
DROP TABLE IF EXISTS aseguradora CASCADE;
DROP TABLE IF EXISTS persona CASCADE;
DROP TABLE IF EXISTS tramo_vial CASCADE;

-- ------------------------------------------------------------
-- TRAMO_VIAL
-- Representa los tramos de infraestructura vial del sistema.
-- longitud_km debe ser positiva; tipo_camino restringido a
-- los valores del dominio conocido.
-- ------------------------------------------------------------
CREATE TABLE tramo_vial (
    id_tramo    SERIAL PRIMARY KEY,
    descripcion VARCHAR(120) NOT NULL,
    tipo_camino VARCHAR(30)  NOT NULL,
    jurisdiccion VARCHAR(80) NOT NULL,
    longitud_km  NUMERIC(8,2) NOT NULL CHECK (longitud_km > 0),
    CHECK (tipo_camino IN ('autopista','avenida','calle','ruta','camino_rural'))
);

-- ------------------------------------------------------------
-- PERSONA
-- Identificada de forma única por su documento.
-- ------------------------------------------------------------
CREATE TABLE persona (
    id_persona      SERIAL PRIMARY KEY,
    tipo_doc        VARCHAR(20)  NOT NULL,
    nro_doc         VARCHAR(20)  NOT NULL UNIQUE,
    nombre          VARCHAR(60)  NOT NULL,
    apellido        VARCHAR(60)  NOT NULL,
    fecha_nacimiento DATE,
    domicilio       VARCHAR(150),
    telefono        VARCHAR(30)
);

-- ------------------------------------------------------------
-- ASEGURADORA
-- Nombre único por compañía.
-- ------------------------------------------------------------
CREATE TABLE aseguradora (
    id_aseguradora SERIAL PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL UNIQUE,
    telefono       VARCHAR(30),
    domicilio      VARCHAR(150)
);

-- ------------------------------------------------------------
-- VEHICULO
-- Identificado por patente; vin único cuando está disponible.
-- categoria refleja los segmentos de mercado conocidos.
-- tipo_vehiculo y tipo_cobertura restringidos por CHECK.
-- ------------------------------------------------------------
CREATE TABLE vehiculo (
    patente         VARCHAR(10) PRIMARY KEY,
    vin             VARCHAR(30) UNIQUE,
    marca           VARCHAR(50) NOT NULL,
    modelo          VARCHAR(50) NOT NULL,
    anio_modelo     INTEGER     NOT NULL CHECK (anio_modelo BETWEEN 1950 AND 2035),
    tipo_vehiculo   VARCHAR(30) NOT NULL,
    categoria       VARCHAR(30) NOT NULL,
    tipo_cobertura  VARCHAR(30) NOT NULL,
    id_aseguradora  INTEGER     NOT NULL,
    FOREIGN KEY (id_aseguradora) REFERENCES aseguradora(id_aseguradora),
    CHECK (tipo_vehiculo   IN ('auto','moto','camioneta','camion','colectivo','bicicleta')),
    CHECK (tipo_cobertura  IN ('amplia','terceros','responsabilidad_civil')),
    CHECK (categoria       IN ('gama_baja','gama_media','gama_alta','utilitario','carga','otro'))
);

-- ------------------------------------------------------------
-- SINIESTRO
-- Hecho central del modelo; referencia a un tramo vial.
-- tipo_accidente y tipo_colision restringidos por CHECK para
-- evitar valores libres inconsistentes.
-- ------------------------------------------------------------
CREATE TABLE siniestro (
    id_siniestro        SERIAL PRIMARY KEY,
    fecha               DATE        NOT NULL,
    hora                TIME        NOT NULL,
    id_tramo            INTEGER     NOT NULL,
    referencia_lugar    VARCHAR(150) NOT NULL,
    nro_denuncia_policial VARCHAR(40),
    tipo_accidente      VARCHAR(40) NOT NULL,
    tipo_colision       VARCHAR(40) NOT NULL,
    FOREIGN KEY (id_tramo) REFERENCES tramo_vial(id_tramo),
    CHECK (tipo_accidente IN ('colision_multiple','atropello','despiste','colision_lateral',
                              'colision_frontal','vuelco','incendio','otro')),
    CHECK (tipo_colision  IN ('vehiculo','peaton','edificio','poste','guardarail',
                              'animal','otro'))
);

-- ------------------------------------------------------------
-- INFORME_TECNICO
-- Un siniestro puede generar cero o varios informes.
-- Las condiciones contextuales del hecho se almacenan acá.
-- ------------------------------------------------------------
CREATE TABLE informe_tecnico (
    id_informe              SERIAL PRIMARY KEY,
    id_siniestro            INTEGER      NOT NULL,
    fecha_informe           DATE         NOT NULL,
    organismo_emisor        VARCHAR(100) NOT NULL,
    funcionario_responsable VARCHAR(100) NOT NULL,
    hipotesis_hecho         TEXT,
    causa_probable          VARCHAR(100),
    falla_humana_probable   VARCHAR(100),
    tipo_pavimento          VARCHAR(40),
    estado_via              VARCHAR(40),
    iluminacion             VARCHAR(40),
    condicion_climatica     VARCHAR(40),
    seguridad_peatonal      BOOLEAN,
    FOREIGN KEY (id_siniestro) REFERENCES siniestro(id_siniestro)
);

-- ------------------------------------------------------------
-- LICENCIA
-- Pertenece a una persona; estado restringido por CHECK.
-- Se valida que fecha_vencimiento sea posterior a fecha_emision.
-- ------------------------------------------------------------
CREATE TABLE licencia (
    id_licencia       SERIAL PRIMARY KEY,
    id_persona        INTEGER     NOT NULL,
    nro_licencia      VARCHAR(40) NOT NULL UNIQUE,
    clase             VARCHAR(20) NOT NULL,
    fecha_emision     DATE        NOT NULL,
    fecha_vencimiento DATE        NOT NULL,
    estado            VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona),
    CHECK (estado IN ('vigente','vencida','suspendida')),
    CHECK (fecha_vencimiento > fecha_emision)
);

-- ------------------------------------------------------------
-- INFRACCION
-- Antecedente de tránsito de una persona.
-- estado restringido por CHECK; monto no puede ser negativo.
-- ------------------------------------------------------------
CREATE TABLE infraccion (
    id_infraccion  SERIAL PRIMARY KEY,
    id_persona     INTEGER      NOT NULL,
    fecha          DATE         NOT NULL,
    tipo_infraccion VARCHAR(60) NOT NULL,
    descripcion    VARCHAR(200),
    jurisdiccion   VARCHAR(80),
    monto          NUMERIC(10,2) CHECK (monto >= 0),
    estado         VARCHAR(20)  NOT NULL,
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona),
    CHECK (estado IN ('pendiente','pagada','apelada'))
);

-- ------------------------------------------------------------
-- ANTECEDENTE_PENAL
-- Registro judicial asociado a una persona.
-- ------------------------------------------------------------
CREATE TABLE antecedente_penal (
    id_antecedente SERIAL PRIMARY KEY,
    id_persona     INTEGER      NOT NULL,
    fecha          DATE         NOT NULL,
    caratula       VARCHAR(120) NOT NULL,
    organismo      VARCHAR(120),
    observaciones  VARCHAR(200),
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona)
);

-- ------------------------------------------------------------
-- HABILITACION_CONDUCCION
-- Relación N:M temporal entre persona y vehículo.
-- Se valida que fecha_hasta, cuando está presente, sea
-- posterior a fecha_desde.
-- NOTA: La existencia de esta habilitación no implica que la
-- persona haya conducido el vehículo en un siniestro concreto
-- (eso se modela en PARTICIPACION_VEHICULAR).
-- ------------------------------------------------------------
CREATE TABLE habilitacion_conduccion (
    id_persona   INTEGER NOT NULL,
    patente      VARCHAR(10) NOT NULL,
    fecha_desde  DATE NOT NULL,
    fecha_hasta  DATE,
    PRIMARY KEY (id_persona, patente, fecha_desde),
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona),
    FOREIGN KEY (patente)    REFERENCES vehiculo(patente),
    CHECK (fecha_hasta IS NULL OR fecha_hasta > fecha_desde)
);

-- ------------------------------------------------------------
-- VEHICULO_INVOLUCRADO
-- Registra qué vehículos participaron en cada siniestro.
-- ------------------------------------------------------------
CREATE TABLE vehiculo_involucrado (
    id_siniestro   INTEGER     NOT NULL,
    patente        VARCHAR(10) NOT NULL,
    danio_material VARCHAR(100),
    observaciones  VARCHAR(200),
    PRIMARY KEY (id_siniestro, patente),
    FOREIGN KEY (id_siniestro) REFERENCES siniestro(id_siniestro),
    FOREIGN KEY (patente)      REFERENCES vehiculo(patente)
);

-- ------------------------------------------------------------
-- PARTICIPACION_VEHICULAR
-- Relación ternaria SINIESTRO–PERSONA–VEHICULO.
-- Representa a una persona dentro de un vehículo en un hecho
-- concreto. rol_ocupante, condicion_fisica y resultado
-- restringidos por CHECK.
-- Restricción de aplicación: por siniestro y vehículo debe
-- haber a lo sumo un conductor (no implementable solo con DDL).
-- ------------------------------------------------------------
CREATE TABLE participacion_vehicular (
    id_siniestro   INTEGER     NOT NULL,
    id_persona     INTEGER     NOT NULL,
    patente        VARCHAR(10) NOT NULL,
    rol_ocupante   VARCHAR(20) NOT NULL,
    usa_cinturon   BOOLEAN,
    condicion_fisica VARCHAR(40),
    resultado      VARCHAR(40),
    PRIMARY KEY (id_siniestro, id_persona, patente),
    FOREIGN KEY (id_persona)                  REFERENCES persona(id_persona),
    FOREIGN KEY (id_siniestro, patente)       REFERENCES vehiculo_involucrado(id_siniestro, patente),
    CHECK (rol_ocupante    IN ('conductor','acompaniante')),
    CHECK (condicion_fisica IN ('ileso','lesiones_leves','lesiones_graves','fallecido') OR condicion_fisica IS NULL),
    CHECK (resultado       IN ('sin_internacion','ambulatorio','internacion','fallecido') OR resultado IS NULL)
);

-- ------------------------------------------------------------
-- TESTIMONIO
-- Declaración de una persona sobre un siniestro en el que
-- no participó como ocupante de vehículo.
-- Restricción de aplicación: una persona no debería aparecer
-- simultáneamente en TESTIMONIO y PARTICIPACION_VEHICULAR para
-- el mismo siniestro, salvo excepción fundada. Esta restricción
-- no es implementable únicamente con DDL y debe controlarse
-- a nivel de aplicación o mediante un trigger.
-- ------------------------------------------------------------
CREATE TABLE testimonio (
    id_siniestro   INTEGER NOT NULL,
    id_persona     INTEGER NOT NULL,
    declaracion    VARCHAR(250),
    medio_contacto VARCHAR(100),
    PRIMARY KEY (id_siniestro, id_persona),
    FOREIGN KEY (id_siniestro) REFERENCES siniestro(id_siniestro),
    FOREIGN KEY (id_persona)   REFERENCES persona(id_persona)
);

-- ------------------------------------------------------------
-- VICTIMA_NO_VEHICULAR
-- Personas afectadas que no viajaban en ningún vehículo
-- (peatones, ciclistas, etc.).
-- ------------------------------------------------------------
CREATE TABLE victima_no_vehicular (
    id_siniestro   INTEGER     NOT NULL,
    id_persona     INTEGER     NOT NULL,
    tipo_victima   VARCHAR(30) NOT NULL,
    condicion_fisica VARCHAR(40),
    observaciones  VARCHAR(200),
    PRIMARY KEY (id_siniestro, id_persona),
    FOREIGN KEY (id_siniestro) REFERENCES siniestro(id_siniestro),
    FOREIGN KEY (id_persona)   REFERENCES persona(id_persona),
    CHECK (tipo_victima    IN ('peaton','ciclista','otro')),
    CHECK (condicion_fisica IN ('ileso','lesiones_leves','lesiones_graves','fallecido') OR condicion_fisica IS NULL)
);
