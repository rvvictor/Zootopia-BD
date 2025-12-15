/*
  # Procedimientos Almacenados, Vistas y Triggers - Compatible con Frontend
  
  ## Contenido
  1. Tres Procedimientos Almacenados (FUNCTIONS en PostgreSQL)
  2. Tres Vistas (VIEWS)
  3. Dos Triggers (BEFORE y AFTER)
  
  ## IMPORTANTE
  Esta versión usa nombres snake_case para ser compatible con el esquema frontend.
  
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
  
  ### 1. BEFORE - validar_fechas_ejemplar
  Valida que la fecha de nacimiento no sea futura
  
  ### 2. AFTER - registrar_auditoria_ejemplar
  Registra cambios en la tabla ejemplares
*/

-- ============================================
-- PROCEDIMIENTO 1: Obtener Especies por Estado de Conservación
-- ============================================

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
    e.id,
    e.nombre_cientifico,
    e.nombre_comun,
    t.nombre,
    p.nombre,
    r.nombre as region_nombre,
    ec.nombre,
    est.nombre
  FROM especies e
  INNER JOIN tipos t ON e.tipo_id = t.id
  INNER JOIN paises p ON e.pais_id = p.id
  INNER JOIN regiones r ON p.region_id = r.id
  INNER JOIN ecosistemas ec ON e.ecosistema_id = ec.id
  INNER JOIN estados_conservacion est ON e.estado_conservacion_id = est.id
  WHERE est.nombre = p_estado
  ORDER BY e.nombre_comun;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PROCEDIMIENTO 2: Calcular Estadísticas del Zoo
-- ============================================

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
    (SELECT COUNT(*) FROM especies)::BIGINT,
    (SELECT COUNT(*) FROM ejemplares)::BIGINT,
    (SELECT COUNT(*) FROM paises)::BIGINT,
    (SELECT COUNT(*) FROM regiones)::BIGINT,
    (SELECT COUNT(*) FROM ejemplares WHERE estado_salud = 'Saludable')::BIGINT,
    (SELECT COUNT(*) FROM ejemplares WHERE estado_salud LIKE '%tratamiento%')::BIGINT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PROCEDIMIENTO 3: Registrar Nuevo Ejemplar con Auditoría
-- ============================================

CREATE OR REPLACE FUNCTION registrar_nuevo_ejemplar(
  p_nombre VARCHAR,
  p_sexo VARCHAR,
  p_fecha_nacimiento DATE,
  p_fecha_ingreso DATE,
  p_estado_salud VARCHAR,
  p_especie_id INT,
  p_usuario_id INT
)
RETURNS INT AS $$
DECLARE
  v_id_ejemplar INT;
  v_nombre_especie VARCHAR;
BEGIN
  -- Insertar el ejemplar
  INSERT INTO ejemplares (nombre, sexo, fecha_nacimiento, fecha_ingreso, estado_salud, especie_id)
  VALUES (p_nombre, p_sexo, p_fecha_nacimiento, p_fecha_ingreso, p_estado_salud, p_especie_id)
  RETURNING id INTO v_id_ejemplar;
  
  -- Obtener nombre de la especie
  SELECT nombre_comun INTO v_nombre_especie
  FROM especies WHERE id = p_especie_id;
  
  -- Registrar en auditoría
  INSERT INTO auditorias (usuario_id, accion, tabla_afectada, descripcion)
  VALUES (
    p_usuario_id,
    'INSERT',
    'ejemplares',
    'Nuevo ejemplar registrado: ' || p_nombre || ' de especie ' || v_nombre_especie
  );
  
  RETURN v_id_ejemplar;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VISTA 1: Vista Especies Completa
-- ============================================

CREATE OR REPLACE VIEW vista_especies_completa AS
SELECT 
  e.id,
  e.nombre_cientifico,
  e.nombre_comun,
  e.descripcion,
  t.nombre AS tipo,
  p.nombre AS pais,
  r.nombre AS region,
  ec.nombre AS ecosistema,
  est.nombre AS estado_conservacion,
  ft.habitat,
  ft.dieta,
  ft.reproduccion,
  ft.longevidad,
  ft.comportamiento,
  (SELECT COUNT(*) FROM ejemplares WHERE especie_id = e.id) AS total_ejemplares
FROM especies e
LEFT JOIN tipos t ON e.tipo_id = t.id
LEFT JOIN paises p ON e.pais_id = p.id
LEFT JOIN regiones r ON p.region_id = r.id
LEFT JOIN ecosistemas ec ON e.ecosistema_id = ec.id
LEFT JOIN estados_conservacion est ON e.estado_conservacion_id = est.id
LEFT JOIN fichas_tecnicas ft ON e.id = ft.especie_id
ORDER BY e.nombre_comun;

-- ============================================
-- VISTA 2: Vista Ejemplares Detalle
-- ============================================

CREATE OR REPLACE VIEW vista_ejemplares_detalle AS
SELECT 
  ej.id,
  ej.nombre AS nombre_ejemplar,
  ej.sexo,
  ej.fecha_nacimiento,
  ej.fecha_ingreso,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, ej.fecha_nacimiento)) AS edad_años,
  ej.estado_salud,
  e.nombre_comun AS especie,
  e.nombre_cientifico,
  t.nombre AS tipo,
  p.nombre AS pais_origen,
  r.nombre AS region,
  est.nombre AS estado_conservacion
FROM ejemplares ej
INNER JOIN especies e ON ej.especie_id = e.id
INNER JOIN tipos t ON e.tipo_id = t.id
INNER JOIN paises p ON e.pais_id = p.id
INNER JOIN regiones r ON p.region_id = r.id
INNER JOIN estados_conservacion est ON e.estado_conservacion_id = est.id
ORDER BY ej.nombre;

-- ============================================
-- VISTA 3: Vista Estadísticas por Región
-- ============================================

CREATE OR REPLACE VIEW vista_estadisticas_regiones AS
SELECT 
  r.nombre AS region,
  COUNT(DISTINCT p.id) AS total_paises,
  COUNT(DISTINCT e.id) AS total_especies,
  COUNT(DISTINCT ej.id) AS total_ejemplares,
  COUNT(DISTINCT CASE WHEN est.nombre IN ('Crítico', 'En Peligro') 
                 THEN e.id END) AS especies_en_peligro
FROM regiones r
LEFT JOIN paises p ON r.id = p.region_id
LEFT JOIN especies e ON p.id = e.pais_id
LEFT JOIN ejemplares ej ON e.id = ej.especie_id
LEFT JOIN estados_conservacion est ON e.estado_conservacion_id = est.id
GROUP BY r.id, r.nombre
ORDER BY total_especies DESC;

-- ============================================
-- TRIGGER 1: BEFORE INSERT - Validar Fechas Ejemplar
-- ============================================

CREATE OR REPLACE FUNCTION validar_fechas_ejemplar()
RETURNS TRIGGER AS $$
BEGIN
  -- Validar que fecha de nacimiento no sea futura
  IF NEW.fecha_nacimiento > CURRENT_DATE THEN
    RAISE EXCEPTION 'La fecha de nacimiento no puede ser futura';
  END IF;
  
  -- Validar que fecha de ingreso no sea anterior a fecha de nacimiento
  IF NEW.fecha_ingreso < NEW.fecha_nacimiento THEN
    RAISE EXCEPTION 'La fecha de ingreso no puede ser anterior a la fecha de nacimiento';
  END IF;
  
  -- Si el ejemplar tiene más de 100 años, advertir (pero permitir)
  IF EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.fecha_nacimiento)) > 100 THEN
    RAISE WARNING 'El ejemplar tiene más de 100 años de edad';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_fechas_ejemplar
BEFORE INSERT OR UPDATE ON ejemplares
FOR EACH ROW
EXECUTE FUNCTION validar_fechas_ejemplar();

-- ============================================
-- TRIGGER 2: AFTER INSERT/UPDATE/DELETE - Auditoría Ejemplar
-- ============================================

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
    SELECT nombre_comun INTO v_nombre_especie
    FROM especies WHERE id = NEW.especie_id;
    v_descripcion := 'Nuevo ejemplar: ' || NEW.nombre || 
                     ' (Especie: ' || v_nombre_especie || ')';
  ELSIF TG_OP = 'UPDATE' THEN
    v_accion := 'UPDATE';
    SELECT nombre_comun INTO v_nombre_especie
    FROM especies WHERE id = NEW.especie_id;
    v_descripcion := 'Actualización ejemplar: ' || NEW.nombre || 
                     ' (ID: ' || NEW.id || ')';
  ELSIF TG_OP = 'DELETE' THEN
    v_accion := 'DELETE';
    SELECT nombre_comun INTO v_nombre_especie
    FROM especies WHERE id = OLD.especie_id;
    v_descripcion := 'Eliminado ejemplar: ' || OLD.nombre || 
                     ' (ID: ' || OLD.id || ')';
  END IF;
  
  -- Insertar en auditoría (sin usuario_id por ahora, se puede mejorar con session)
  INSERT INTO auditorias (usuario_id, accion, tabla_afectada, descripcion)
  VALUES (NULL, v_accion, 'ejemplares', v_descripcion);
  
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auditoria_ejemplar
AFTER INSERT OR UPDATE OR DELETE ON ejemplares
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
