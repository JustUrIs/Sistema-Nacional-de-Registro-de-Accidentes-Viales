INSERT INTO tramo_vial (id_tramo, descripcion, tipo_camino, jurisdiccion, longitud_km) VALUES
(1, 'Autopista Buenos Aires - La Plata', 'autopista', 'Buenos Aires', 50.00),
(2, 'Avenida Rivadavia', 'avenida', 'CABA', 18.00),
(3, 'Ruta Nacional 9 - Tramo Rosario', 'ruta', 'Santa Fe', 120.00),
(4, 'Calle 50 entre 7 y 8', 'calle', 'La Plata', 2.00);

INSERT INTO persona (id_persona, tipo_doc, nro_doc, nombre, apellido, fecha_nacimiento, domicilio, telefono) VALUES
(1, 'DNI', '30111222', 'Juan', 'Perez', '1988-04-12', 'Calle 10 123, La Plata', '2214001001'),
(2, 'DNI', '28999111', 'Ana', 'Gomez', '1985-08-22', 'Av 44 456, La Plata', '2214001002'),
(3, 'DNI', '33444555', 'Luis', 'Diaz', '1990-01-10', 'San Martin 222, Rosario', '3415001003'),
(4, 'DNI', '27777888', 'Marta', 'Lopez', '1979-06-03', 'Belgrano 100, Rosario', '3415001004'),
(5, 'DNI', '35555666', 'Carla', 'Ruiz', '1995-09-14', 'Calle 60 789, Quilmes', '1145001005'),
(6, 'DNI', '36666777', 'Diego', 'Fernandez', '1987-12-19', 'Av Mitre 1200, Avellaneda', '1145001006'),
(7, 'DNI', '37777889', 'Sofia', 'Alvarez', '1992-07-01', 'Rivadavia 3500, CABA', '1145001007'),
(8, 'DNI', '38888990', 'Pedro', 'Molina', '2001-11-11', 'Moreno 777, CABA', '1145001008'),
(9, 'DNI', '39999001', 'Valeria', 'Castro', '1993-03-30', 'Diag 74 250, La Plata', '2214001009');

INSERT INTO aseguradora (id_aseguradora, nombre, telefono, domicilio) VALUES
(1, 'Seguros del Plata', '0800-111-1111', 'CABA 100'),
(2, 'Proteccion Federal', '0800-222-2222', 'Rosario 200');

INSERT INTO vehiculo (patente, vin, marca, modelo, anio_modelo, tipo_vehiculo, categoria, tipo_cobertura, id_aseguradora) VALUES
('AA111AA', 'VIN0001AA111AA', 'Toyota', 'Corolla', 2018, 'auto', 'gama_media', 'amplia', 1),
('AB222BB', 'VIN0002AB222BB', 'Ford', 'Ranger', 2020, 'camioneta', 'utilitario', 'terceros', 2),
('AC333CC', 'VIN0003AC333CC', 'Honda', 'CG150', 2022, 'moto', 'utilitario', 'responsabilidad_civil', 1),
('AD444DD', 'VIN0004AD444DD', 'Iveco', 'Tector', 2016, 'camion', 'carga', 'terceros', 2);

INSERT INTO siniestro (id_siniestro, fecha, hora, id_tramo, referencia_lugar, nro_denuncia_policial, tipo_accidente, tipo_colision) VALUES
(101, '2025-03-10', '08:30:00', 1, 'Km 15 mano a CABA', 'DP-1001', 'colision_multiple', 'vehiculo'),
(102, '2025-03-15', '19:45:00', 2, 'Altura 5200', 'DP-1002', 'atropello', 'peaton'),
(103, '2025-04-01', '23:10:00', 3, 'Km 278', 'DP-1003', 'despiste', 'edificio'),
(104, '2025-04-20', '14:20:00', 4, 'Entre calles 7 y 8', 'DP-1004', 'colision_lateral', 'vehiculo');

INSERT INTO informe_tecnico (
id_informe, id_siniestro, fecha_informe, organismo_emisor, funcionario_responsable,
hipotesis_hecho, causa_probable, falla_humana_probable, tipo_pavimento, estado_via,
iluminacion, condicion_climatica, seguridad_peatonal
) VALUES
(1001, 101, '2025-03-12', 'Agencia Vial Provincial', 'Ing. Roberto Sosa',
'Alcance entre dos vehiculos por frenado brusco', 'distancia_insuficiente', 'distraccion',
'asfalto', 'seca', 'diurna', 'despejado', TRUE),
(1002, 102, '2025-03-17', 'Pericia Urbana CABA', 'Lic. Mariana Gil',
'Motocicleta impacta a peaton en cruce no protegido', 'exceso_velocidad', 'imprudencia',
'asfalto', 'seca', 'artificial', 'despejado', FALSE),
(1003, 103, '2025-04-03', 'Policia Cientifica Santa Fe', 'Com. Diego Roldan',
'Camion pierde control y termina impactando contra estructura', 'fatiga', 'somnolencia',
'hormigon', 'humeda', 'artificial', 'lluvia', FALSE),
(1004, 104, '2025-04-22', 'Agencia Vial Municipal', 'Lic. Paula Ibarra',
'Choque lateral en interseccion urbana', 'prioridad_paso', 'maniobra_indebida',
'asfalto', 'seca', 'diurna', 'despejado', TRUE);

INSERT INTO licencia (id_licencia, id_persona, nro_licencia, clase, fecha_emision, fecha_vencimiento, estado) VALUES
(1, 1, 'LIC-0001', 'B1', '2022-01-10', '2027-01-10', 'vigente'),
(2, 2, 'LIC-0002', 'B1', '2021-05-15', '2026-05-15', 'vigente'),
(3, 3, 'LIC-0003', 'A1', '2019-02-20', '2024-02-20', 'vencida'),
(4, 4, 'LIC-0004', 'C1', '2023-06-01', '2028-06-01', 'vigente'),
(5, 5, 'LIC-0005', 'B1', '2024-03-05', '2029-03-05', 'vigente');

INSERT INTO infraccion (id_infraccion, id_persona, fecha, tipo_infraccion, descripcion, jurisdiccion, monto, estado) VALUES
(1, 1, '2024-10-10', 'exceso_velocidad', 'Exceso de velocidad en autopista', 'Buenos Aires', 45000, 'pagada'),
(2, 3, '2024-11-02', 'sin_casco', 'Circulacion sin casco reglamentario', 'CABA', 18000, 'pagada'),
(3, 3, '2025-01-18', 'luz_roja', 'Cruce con semaforo en rojo', 'CABA', 52000, 'pendiente'),
(4, 5, '2024-07-07', 'estacionamiento_indebido', 'Estacionamiento prohibido', 'La Plata', 12000, 'pagada');

INSERT INTO antecedente_penal (id_antecedente, id_persona, fecha, caratula, organismo, observaciones) VALUES
(1, 3, '2023-08-18', 'Lesiones culposas en accidente vial', 'Juzgado Correccional 3', 'Causa en tramite'),
(2, 5, '2022-04-10', 'Resistencia a la autoridad', 'Fiscalia 2', 'Antecedente registrado');

INSERT INTO habilitacion_conduccion (id_persona, patente, fecha_desde, fecha_hasta) VALUES
(1, 'AA111AA', '2024-01-01', NULL),
(2, 'AB222BB', '2024-01-01', NULL),
(3, 'AC333CC', '2024-01-01', NULL),
(4, 'AD444DD', '2024-01-01', NULL),
(5, 'AA111AA', '2025-01-01', NULL);

INSERT INTO vehiculo_involucrado (id_siniestro, patente, danio_material, observaciones) VALUES
(101, 'AA111AA', 'frontal_leve', 'Impacto delantero'),
(101, 'AB222BB', 'trasero_moderado', 'Impacto trasero'),
(102, 'AC333CC', 'lateral_moderado', 'Caida posterior al impacto'),
(103, 'AD444DD', 'frontal_grave', 'Danio estructural'),
(104, 'AA111AA', 'lateral_leve', 'Rayon y abolladura'),
(104, 'AC333CC', 'lateral_moderado', 'Moto con rotura de carenado');

INSERT INTO participacion_vehicular (
id_siniestro, id_persona, patente, rol_ocupante, usa_cinturon, condicion_fisica, resultado
) VALUES
(101, 1, 'AA111AA', 'conductor', TRUE, 'lesiones_leves', 'ambulatorio'),
(101, 5, 'AA111AA', 'acompaniante', TRUE, 'ileso', 'sin_internacion'),
(101, 2, 'AB222BB', 'conductor', FALSE, 'lesiones_graves', 'internacion'),
(102, 3, 'AC333CC', 'conductor', FALSE, 'lesiones_leves', 'ambulatorio'),
(103, 4, 'AD444DD', 'conductor', TRUE, 'ileso', 'sin_internacion'),
(104, 1, 'AA111AA', 'conductor', TRUE, 'ileso', 'sin_internacion'),
(104, 3, 'AC333CC', 'conductor', FALSE, 'lesiones_leves', 'ambulatorio');

INSERT INTO testimonio (id_siniestro, id_persona, declaracion, medio_contacto) VALUES
(101, 6, 'Observa frenada brusca y posterior choque', 'telefono'),
(102, 7, 'Declara que la moto circulaba rapido', 'email'),
(104, 9, 'Observa choque en bocacalle', 'telefono');

INSERT INTO victima_no_vehicular (id_siniestro, id_persona, tipo_victima, condicion_fisica, observaciones) VALUES
(102, 8, 'peaton', 'lesiones_graves', 'Peaton embestido al cruzar');