/*
  # Procedimientos Almacenados, Vistas y Triggers
  
  ## Contenido
  1. Tres Procedimientos Almacenados (FUNCTIONS en PostgreSQL)
  2. Tres Vistas (VIEWS)
  3. Dos Triggers (BEFORE y AFTER)
  
  ## Procedimientos Almacenados
  
  ### 1. obtener_especies_por_estado_conservacion
  Obtiene todas las especies filtradas por estado de conservación
  
  ### 2. calcular_estadisticas_zoo
  Calcula estadísticas generales del zoológico
  
  ### 3. registrar_nuevo_ejemplar
  Registra un nuevo ejemplar y crea una entrada en auditoría
  
  ## Vistas
  
  ### 1. vista_especies_completa
  Vista completa de especies con toda su información relacionada
  
  ### 2. vista_ejemplares_detalle
  Vista de ejemplares con información de su especie
  
  ### 3. vista_estadisticas_regiones
  Vista con estadísticas por región
  
  ## Triggers
  
  ### 1. BEFORE - validar_edad_ejemplar
  Valida que la fecha de nacimiento no sea futura
  
  ### 2. AFTER - registrar_auditoria_ejemplar
  Registra cambios en la tabla ejemplar
*/

-- ============================================
-- PROCEDIMIENTO 1: Obtener Especies por Estado de Conservación
-- ============================================
-- Descripción: Obtiene todas las especies de un estado de conservación específico
-- con su información completa
-- Parámetros: nombre del estado de conservación
-- Retorna: Tabla con información de especies

CREATE OR REPLACE FUNCTION obtener_especies_por_estado_conservacion(
  p_estado VARCHAR
)
RETURNS TABLE (
  id INT,
  nombre_cientifico VARCHAR,
  nombre_comun VARCHAR,
  tipo VARCHAR,
  pais VARCHAR,
  region VARCHAR,
  ecosistema VARCHAR,
  estado_conservacion VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.idEspecie,
    e.nombreCientifico,
    e.nombreComun,
    t.nombreTipo,
    p.nombrePais,
    r.nombre as region_nombre,
    ec.nombreEcosistema,
    est.nombreConservacion
  FROM especie e
  INNER JOIN tipo t ON e.idTipo = t.idTipo
  INNER JOIN pais p ON e.idPais = p.idPais
  INNER JOIN region r ON p.idRegion = r.idRegion
  INNER JOIN ecosistema ec ON e.idEcosistema = ec.idEcosistema
  INNER JOIN estadoConservacion est ON e.idConservacion = est.idConservacion
  WHERE est.nombreConservacion = p_estado
  ORDER BY e.nombreComun;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PROCEDIMIENTO 2: Calcular Estadísticas del Zoo
-- ============================================
-- Descripción: Calcula estadísticas generales del zoológico
-- Retorna: Total de especies, ejemplares, países y regiones

CREATE OR REPLACE FUNCTION calcular_estadisticas_zoo()
RETURNS TABLE (
  total_especies BIGINT,
  total_ejemplares BIGINT,
  total_paises BIGINT,
  total_regiones BIGINT,
  ejemplares_saludables BIGINT,
  ejemplares_tratamiento BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*) FROM especie)::BIGINT,
    (SELECT COUNT(*) FROM ejemplar)::BIGINT,
    (SELECT COUNT(*) FROM pais)::BIGINT,
    (SELECT COUNT(*) FROM region)::BIGINT,
    (SELECT COUNT(*) FROM ejemplar WHERE estadoSalud = 'Saludable')::BIGINT,
    (SELECT COUNT(*) FROM ejemplar WHERE estadoSalud LIKE '%tratamiento%')::BIGINT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PROCEDIMIENTO 3: Registrar Nuevo Ejemplar con Auditoría
-- ============================================
-- Descripción: Registra un nuevo ejemplar y crea automáticamente
-- una entrada en la tabla de auditoría
-- Parámetros: datos del ejemplar y ID del usuario que registra

CREATE OR REPLACE FUNCTION registrar_nuevo_ejemplar(
  p_nombre VARCHAR,
  p_sexo VARCHAR,
  p_fecha_nacimiento DATE,
  p_fecha_ingreso DATE,
  p_estado_salud VARCHAR,
  p_id_especie INT,
  p_id_usuario INT
)
RETURNS INT AS $$
DECLARE
  v_id_ejemplar INT;
  v_nombre_especie VARCHAR;
BEGIN
  -- Insertar el ejemplar
  INSERT INTO ejemplar (nombre, sexo, fechaNacimiento, fechaIngreso, estadoSalud, idEspecie)
  VALUES (p_nombre, p_sexo, p_fecha_nacimiento, p_fecha_ingreso, p_estado_salud, p_id_especie)
  RETURNING idEjemplar INTO v_id_ejemplar;
  
  -- Obtener nombre de la especie
  SELECT nombreComun INTO v_nombre_especie
  FROM especie WHERE idEspecie = p_id_especie;
  
  -- Registrar en auditoría
  INSERT INTO auditoria (idUsuario, accion, tablaAfectada, descripcionAuditoria)
  VALUES (
    p_id_usuario,
    'INSERT',
    'ejemplar',
    'Nuevo ejemplar registrado: ' || p_nombre || ' de especie ' || v_nombre_especie
  );
  
  RETURN v_id_ejemplar;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VISTA 1: Vista Especies Completa
-- ============================================
-- Descripción: Muestra información completa de todas las especies
-- incluyendo sus relaciones con otras tablas

CREATE OR REPLACE VIEW vista_especies_completa AS
SELECT 
  e.idEspecie,
  e.nombreCientifico,
  e.nombreComun,
  e.descripcion,
  t.nombreTipo AS tipo,
  p.nombrePais AS pais,
  r.nombre AS region,
  ec.nombreEcosistema AS ecosistema,
  est.nombreConservacion AS estadoConservacion,
  ft.habitat,
  ft.dieta,
  ft.reproduccion,
  ft.longevidad,
  ft.comportamiento,
  (SELECT COUNT(*) FROM ejemplar WHERE idEspecie = e.idEspecie) AS total_ejemplares
FROM especie e
LEFT JOIN tipo t ON e.idTipo = t.idTipo
LEFT JOIN pais p ON e.idPais = p.idPais
LEFT JOIN region r ON p.idRegion = r.idRegion
LEFT JOIN ecosistema ec ON e.idEcosistema = ec.idEcosistema
LEFT JOIN estadoConservacion est ON e.idConservacion = est.idConservacion
LEFT JOIN fichaTecnica ft ON e.idEspecie = ft.idEspecie
ORDER BY e.nombreComun;

-- ============================================
-- VISTA 2: Vista Ejemplares Detalle
-- ============================================
-- Descripción: Muestra información detallada de todos los ejemplares
-- junto con información de su especie

CREATE OR REPLACE VIEW vista_ejemplares_detalle AS
SELECT 
  ej.idEjemplar,
  ej.nombre AS nombre_ejemplar,
  ej.sexo,
  ej.fechaNacimiento,
  ej.fechaIngreso,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, ej.fechaNacimiento)) AS edad_años,
  ej.estadoSalud,
  e.nombreComun AS especie,
  e.nombreCientifico,
  t.nombreTipo AS tipo,
  p.nombrePais AS pais_origen,
  r.nombre AS region,
  est.nombreConservacion AS estado_conservacion
FROM ejemplar ej
INNER JOIN especie e ON ej.idEspecie = e.idEspecie
INNER JOIN tipo t ON e.idTipo = t.idTipo
INNER JOIN pais p ON e.idPais = p.idPais
INNER JOIN region r ON p.idRegion = r.idRegion
INNER JOIN estadoConservacion est ON e.idConservacion = est.idConservacion
ORDER BY ej.nombre;

-- ============================================
-- VISTA 3: Vista Estadísticas por Región
-- ============================================
-- Descripción: Muestra estadísticas agrupadas por región geográfica

CREATE OR REPLACE VIEW vista_estadisticas_regiones AS
SELECT 
  r.nombre AS region,
  COUNT(DISTINCT p.idPais) AS total_paises,
  COUNT(DISTINCT e.idEspecie) AS total_especies,
  COUNT(DISTINCT ej.idEjemplar) AS total_ejemplares,
  COUNT(DISTINCT CASE WHEN est.nombreConservacion IN ('Crítico', 'En Peligro') 
                 THEN e.idEspecie END) AS especies_en_peligro
FROM region r
LEFT JOIN pais p ON r.idRegion = p.idRegion
LEFT JOIN especie e ON p.idPais = e.idPais
LEFT JOIN ejemplar ej ON e.idEspecie = ej.idEspecie
LEFT JOIN estadoConservacion est ON e.idConservacion = est.idConservacion
GROUP BY r.idRegion, r.nombre
ORDER BY total_especies DESC;

-- ============================================
-- TRIGGER 1: BEFORE INSERT - Validar Edad Ejemplar
-- ============================================
-- Descripción: Valida que la fecha de nacimiento no sea futura
-- y que la fecha de ingreso no sea anterior a la de nacimiento

CREATE OR REPLACE FUNCTION validar_fechas_ejemplar()
RETURNS TRIGGER AS $$
BEGIN
  -- Validar que fecha de nacimiento no sea futura
  IF NEW.fechaNacimiento > CURRENT_DATE THEN
    RAISE EXCEPTION 'La fecha de nacimiento no puede ser futura';
  END IF;
  
  -- Validar que fecha de ingreso no sea anterior a fecha de nacimiento
  IF NEW.fechaIngreso < NEW.fechaNacimiento THEN
    RAISE EXCEPTION 'La fecha de ingreso no puede ser anterior a la fecha de nacimiento';
  END IF;
  
  -- Si el ejemplar tiene más de 100 años, advertir (pero permitir)
  IF EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.fechaNacimiento)) > 100 THEN
    RAISE WARNING 'El ejemplar tiene más de 100 años de edad';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_fechas_ejemplar
BEFORE INSERT OR UPDATE ON ejemplar
FOR EACH ROW
EXECUTE FUNCTION validar_fechas_ejemplar();

-- ============================================
-- TRIGGER 2: AFTER INSERT/UPDATE/DELETE - Auditoría Ejemplar
-- ============================================
-- Descripción: Registra automáticamente en la tabla de auditoría
-- cualquier cambio en la tabla ejemplar

CREATE OR REPLACE FUNCTION registrar_auditoria_ejemplar()
RETURNS TRIGGER AS $$
DECLARE
  v_accion VARCHAR(10);
  v_descripcion TEXT;
  v_nombre_especie VARCHAR(50);
BEGIN
  -- Determinar la acción
  IF TG_OP = 'INSERT' THEN
    v_accion := 'INSERT';
    SELECT nombreComun INTO v_nombre_especie
    FROM especie WHERE idEspecie = NEW.idEspecie;
    v_descripcion := 'Nuevo ejemplar: ' || NEW.nombre || 
                     ' (Especie: ' || v_nombre_especie || ')';
  ELSIF TG_OP = 'UPDATE' THEN
    v_accion := 'UPDATE';
    SELECT nombreComun INTO v_nombre_especie
    FROM especie WHERE idEspecie = NEW.idEspecie;
    v_descripcion := 'Actualización ejemplar: ' || NEW.nombre || 
                     ' (ID: ' || NEW.idEjemplar || ')';
  ELSIF TG_OP = 'DELETE' THEN
    v_accion := 'DELETE';
    SELECT nombreComun INTO v_nombre_especie
    FROM especie WHERE idEspecie = OLD.idEspecie;
    v_descripcion := 'Eliminado ejemplar: ' || OLD.nombre || 
                     ' (ID: ' || OLD.idEjemplar || ')';
  END IF;
  
  -- Insertar en auditoría (sin idUsuario por ahora, se puede mejorar con session)
  INSERT INTO auditoria (idUsuario, accion, tablaAfectada, descripcionAuditoria)
  VALUES (NULL, v_accion, 'ejemplar', v_descripcion);
  
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auditoria_ejemplar
AFTER INSERT OR UPDATE OR DELETE ON ejemplar
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_ejemplar();

-- ============================================
-- COMENTARIOS EN LAS FUNCIONES Y VISTAS
-- ============================================

COMMENT ON FUNCTION obtener_especies_por_estado_conservacion IS 
'Obtiene especies filtradas por estado de conservación con información completa';

COMMENT ON FUNCTION calcular_estadisticas_zoo IS 
'Calcula estadísticas generales del zoológico';

COMMENT ON FUNCTION registrar_nuevo_ejemplar IS 
'Registra un nuevo ejemplar y crea entrada automática en auditoría';

COMMENT ON VIEW vista_especies_completa IS 
'Vista completa de especies con toda su información relacionada';

COMMENT ON VIEW vista_ejemplares_detalle IS 
'Vista de ejemplares con información detallada incluyendo edad calculada';

COMMENT ON VIEW vista_estadisticas_regiones IS 
'Estadísticas agrupadas por región geográfica';
