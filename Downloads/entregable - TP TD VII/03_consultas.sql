-- ============================================================
-- RUAT – Registro Único de Accidentes de Tránsito
-- Consultas de análisis sobre el dominio
-- ============================================================

-- ------------------------------------------------------------
-- 1. Listado general de siniestros con su tramo vial
-- Permite obtener un resumen cronológico de todos los hechos
-- registrados junto con la descripción de la vía donde ocurrieron.
-- ------------------------------------------------------------
SELECT
    s.id_siniestro,
    s.fecha,
    s.hora,
    s.tipo_accidente,
    s.tipo_colision,
    t.descripcion   AS tramo,
    t.tipo_camino,
    t.jurisdiccion
FROM siniestro s
JOIN tramo_vial t ON s.id_tramo = t.id_tramo
ORDER BY s.fecha, s.hora;

-- ------------------------------------------------------------
-- 2. Vehículos involucrados en cada siniestro con aseguradora
-- Útil para cruzar responsabilidades de cobertura por hecho.
-- ------------------------------------------------------------
SELECT
    vi.id_siniestro,
    v.patente,
    v.marca,
    v.modelo,
    v.tipo_vehiculo,
    a.nombre AS aseguradora
FROM vehiculo_involucrado vi
JOIN vehiculo    v ON vi.patente        = v.patente
JOIN aseguradora a ON v.id_aseguradora = a.id_aseguradora
ORDER BY vi.id_siniestro, v.patente;

-- ------------------------------------------------------------
-- 3. Cantidad de siniestros por tipo de camino (GROUP BY)
-- Permite identificar qué tipo de infraestructura concentra
-- más accidentes.
-- ------------------------------------------------------------
SELECT
    t.tipo_camino,
    COUNT(*) AS cantidad_siniestros
FROM siniestro  s
JOIN tramo_vial t ON s.id_tramo = t.id_tramo
GROUP BY t.tipo_camino
ORDER BY cantidad_siniestros DESC, t.tipo_camino;

-- ------------------------------------------------------------
-- 4. Cantidad de siniestros por tipo de vehículo involucrado
-- Muestra qué categorías de vehículos están más presentes
-- en los hechos registrados.
-- ------------------------------------------------------------
SELECT
    v.tipo_vehiculo,
    COUNT(DISTINCT vi.id_siniestro) AS cantidad_siniestros
FROM vehiculo_involucrado vi
JOIN vehiculo v ON vi.patente = v.patente
GROUP BY v.tipo_vehiculo
ORDER BY cantidad_siniestros DESC, v.tipo_vehiculo;

-- ------------------------------------------------------------
-- 5. Cantidad de siniestros por causa probable (GROUP BY + HAVING)
-- Filtra solo las causas que aparecen en más de un informe,
-- para focalizar en las fallas recurrentes del sistema.
-- ------------------------------------------------------------
SELECT
    it.causa_probable,
    COUNT(*) AS cantidad
FROM informe_tecnico it
WHERE it.causa_probable IS NOT NULL
GROUP BY it.causa_probable
HAVING COUNT(*) >= 1          -- ajustar umbral según el conjunto real de datos
ORDER BY cantidad DESC, it.causa_probable;

-- ------------------------------------------------------------
-- 6. Conductores y estado de su licencia al momento del siniestro
-- Versión corregida: para cada conductor se selecciona la
-- licencia vigente más reciente a la fecha del hecho; de no
-- existir ninguna vigente, se toma la más reciente disponible.
-- Esto evita filas duplicadas cuando una persona tiene más de
-- una licencia registrada.
-- ------------------------------------------------------------
WITH licencia_al_hecho AS (
    SELECT DISTINCT ON (pv.id_siniestro, pv.id_persona)
        pv.id_siniestro,
        pv.id_persona,
        pv.patente,
        l.nro_licencia,
        l.estado,
        l.fecha_vencimiento,
        CASE
            WHEN l.estado = 'vigente' AND l.fecha_vencimiento >= s.fecha THEN 'habilitada'
            ELSE 'no_habilitada'
        END AS situacion_al_momento_del_hecho
    FROM participacion_vehicular pv
    JOIN siniestro s ON pv.id_siniestro = s.id_siniestro
    LEFT JOIN licencia l ON pv.id_persona = l.id_persona
    WHERE pv.rol_ocupante = 'conductor'
    ORDER BY
        pv.id_siniestro,
        pv.id_persona,
        -- priorizar: vigente al momento del hecho primero
        (l.estado = 'vigente' AND l.fecha_vencimiento >= s.fecha) DESC,
        l.fecha_vencimiento DESC NULLS LAST
)
SELECT
    lah.id_siniestro,
    p.nombre,
    p.apellido,
    lah.patente,
    lah.nro_licencia,
    lah.estado,
    lah.fecha_vencimiento,
    lah.situacion_al_momento_del_hecho
FROM licencia_al_hecho lah
JOIN persona p ON lah.id_persona = p.id_persona
ORDER BY lah.id_siniestro, p.apellido, p.nombre;

-- ------------------------------------------------------------
-- 7. Personas involucradas con cantidad de infracciones y
--    antecedentes penales (GROUP BY)
-- Permite cruzar el perfil de riesgo de cada persona.
-- ------------------------------------------------------------
SELECT
    p.id_persona,
    p.nombre,
    p.apellido,
    COUNT(DISTINCT i.id_infraccion)    AS cantidad_infracciones,
    COUNT(DISTINCT ap.id_antecedente)  AS cantidad_antecedentes_penales
FROM persona p
LEFT JOIN infraccion       i  ON p.id_persona = i.id_persona
LEFT JOIN antecedente_penal ap ON p.id_persona = ap.id_persona
GROUP BY p.id_persona, p.nombre, p.apellido
ORDER BY cantidad_infracciones DESC, cantidad_antecedentes_penales DESC, p.apellido;

-- ------------------------------------------------------------
-- 8. Cantidad de testigos por siniestro (GROUP BY)
-- Indica cuántos testigos declararon en cada hecho, lo que
-- puede influir en la calidad probatoria del expediente.
-- ------------------------------------------------------------
SELECT
    s.id_siniestro,
    s.fecha,
    COUNT(t.id_persona) AS cantidad_testigos
FROM siniestro  s
LEFT JOIN testimonio t ON s.id_siniestro = t.id_siniestro
GROUP BY s.id_siniestro, s.fecha
ORDER BY s.id_siniestro;

-- ------------------------------------------------------------
-- 9. Siniestros con participantes que no usaban cinturón
-- Permite correlacionar el uso del cinturón con la gravedad
-- de los resultados.
-- ------------------------------------------------------------
SELECT DISTINCT
    s.id_siniestro,
    s.fecha,
    p.nombre,
    p.apellido,
    pv.patente,
    pv.rol_ocupante,
    pv.condicion_fisica,
    pv.resultado
FROM siniestro             s
JOIN participacion_vehicular pv ON s.id_siniestro = pv.id_siniestro
JOIN persona               p  ON pv.id_persona   = p.id_persona
WHERE pv.usa_cinturon = FALSE
ORDER BY s.id_siniestro, p.apellido;

-- ------------------------------------------------------------
-- 10. Siniestros con y sin seguridad peatonal (GROUP BY)
-- Muestra la distribución de la variable seguridad_peatonal
-- en los informes técnicos.
-- ------------------------------------------------------------
SELECT
    it.seguridad_peatonal,
    COUNT(*) AS cantidad_siniestros
FROM informe_tecnico it
GROUP BY it.seguridad_peatonal
ORDER BY it.seguridad_peatonal;

-- ------------------------------------------------------------
-- 11. Siniestros donde participó al menos un conductor
--     con licencia no habilitada al momento del hecho
-- Versión corregida: se usa una subconsulta para determinar
-- primero cuál es la licencia aplicable a la fecha del hecho,
-- evitando falsos positivos por múltiples licencias históricas.
-- ------------------------------------------------------------
WITH conductor_sin_habilitacion AS (
    SELECT DISTINCT ON (pv.id_siniestro, pv.id_persona)
        pv.id_siniestro,
        pv.id_persona,
        s.fecha             AS fecha_siniestro,
        l.estado,
        l.fecha_vencimiento,
        CASE
            WHEN l.id_licencia IS NULL THEN 'sin_licencia'
            WHEN l.estado <> 'vigente'          THEN 'licencia_' || l.estado
            WHEN l.fecha_vencimiento < s.fecha  THEN 'vencida_al_momento'
            ELSE 'habilitada'
        END AS situacion
    FROM participacion_vehicular pv
    JOIN siniestro s ON pv.id_siniestro = s.id_siniestro
    LEFT JOIN licencia l ON pv.id_persona = l.id_persona
    WHERE pv.rol_ocupante = 'conductor'
    ORDER BY
        pv.id_siniestro,
        pv.id_persona,
        (l.estado = 'vigente' AND l.fecha_vencimiento >= s.fecha) DESC,
        l.fecha_vencimiento DESC NULLS LAST
)
SELECT
    csh.id_siniestro,
    csh.fecha_siniestro,
    p.nombre,
    p.apellido,
    csh.situacion,
    csh.estado,
    csh.fecha_vencimiento
FROM conductor_sin_habilitacion csh
JOIN persona p ON csh.id_persona = p.id_persona
WHERE csh.situacion <> 'habilitada'
ORDER BY csh.id_siniestro;

-- ------------------------------------------------------------
-- 12. Cantidad de participaciones por persona en siniestros
--     vehiculares, filtrando solo personas con más de una
--     participación (GROUP BY + HAVING)
-- Identifica personas reincidentes en hechos viales.
-- ------------------------------------------------------------
SELECT
    p.id_persona,
    p.nombre,
    p.apellido,
    COUNT(*) AS cantidad_participaciones
FROM participacion_vehicular pv
JOIN persona p ON pv.id_persona = p.id_persona
GROUP BY p.id_persona, p.nombre, p.apellido
HAVING COUNT(*) > 1
ORDER BY cantidad_participaciones DESC, p.apellido, p.nombre;
