# Documentación Completa - Proyecto Zootopia

## Índice
1. [Procedimientos Almacenados](#procedimientos-almacenados)
2. [Vistas](#vistas)
3. [Consultas SQL con Álgebra Relacional](#consultas-sql)
4. [Triggers](#triggers)
5. [Comandos de Verificación](#comandos-verificacion)

---

## 1. PROCEDIMIENTOS ALMACENADOS {#procedimientos-almacenados}

### Procedimiento 1: obtener_especies_por_estado_conservacion

**Descripción**: Obtiene todas las especies filtradas por estado de conservación con información completa de tipo, país, región y ecosistema.

**Parámetros**:
- `p_estado` (VARCHAR): Nombre del estado de conservación

**Código SQL**:
```sql
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
```

**Ejecución**:
```sql
SELECT * FROM obtener_especies_por_estado_conservacion('Vulnerable');
```

**Resultado esperado**: Retorna todas las especies en estado "Vulnerable" con su información completa (nombre científico, común, tipo, país, región, ecosistema y estado de conservación).

---

### Procedimiento 2: calcular_estadisticas_zoo

**Descripción**: Calcula estadísticas generales del zoológico incluyendo totales de especies, ejemplares, países, regiones, y el estado de salud de los ejemplares.

**Parámetros**: Ninguno

**Código SQL**:
```sql
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
```

**Ejecución**:
```sql
SELECT * FROM calcular_estadisticas_zoo();
```

**Resultado esperado**: Una fila con 6 columnas mostrando: 30 especies, 30 ejemplares, 30 países, 6 regiones, ejemplares saludables y ejemplares en tratamiento.

---

### Procedimiento 3: registrar_nuevo_ejemplar

**Descripción**: Registra un nuevo ejemplar en la base de datos y automáticamente crea una entrada en la tabla de auditoría para mantener un registro de la acción.

**Parámetros**:
- `p_nombre` (VARCHAR): Nombre del ejemplar
- `p_sexo` (VARCHAR): Sexo ('M' o 'F')
- `p_fecha_nacimiento` (DATE): Fecha de nacimiento
- `p_fecha_ingreso` (DATE): Fecha de ingreso al zoo
- `p_estado_salud` (VARCHAR): Estado de salud actual
- `p_id_especie` (INT): ID de la especie
- `p_id_usuario` (INT): ID del usuario que registra

**Código SQL**:
```sql
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
  INSERT INTO ejemplar (nombre, sexo, fechaNacimiento, fechaIngreso, estadoSalud, idEspecie)
  VALUES (p_nombre, p_sexo, p_fecha_nacimiento, p_fecha_ingreso, p_estado_salud, p_id_especie)
  RETURNING idEjemplar INTO v_id_ejemplar;

  SELECT nombreComun INTO v_nombre_especie
  FROM especie WHERE idEspecie = p_id_especie;

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
```

**Ejecución**:
```sql
SELECT registrar_nuevo_ejemplar(
  'Luna', 'F', '2023-01-15', '2023-03-20', 'Saludable', 1, 1
);
```

**Resultado esperado**: Retorna el ID del nuevo ejemplar (ejemplo: 31) y genera automáticamente una entrada en la tabla de auditoría con la descripción "Nuevo ejemplar registrado: Luna de especie León Africano".

---

## 2. VISTAS {#vistas}

### Vista 1: vista_especies_completa

**Descripción**: Muestra información completa de todas las especies incluyendo todas sus relaciones con otras tablas y el conteo de ejemplares.

**Código SQL**:
```sql
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
```

**Consulta**:
```sql
SELECT * FROM vista_especies_completa LIMIT 10;
```

**Contenido**: Retorna las 30 especies con toda su información (científica, común, tipo, país, región, ecosistema, estado de conservación, habitat, dieta, reproducción, longevidad, comportamiento y total de ejemplares).

---

### Vista 2: vista_ejemplares_detalle

**Descripción**: Muestra información detallada de todos los ejemplares junto con información de su especie y calcula automáticamente la edad en años.

**Código SQL**:
```sql
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
```

**Consulta**:
```sql
SELECT * FROM vista_ejemplares_detalle;
```

**Contenido**: Retorna los 30 ejemplares con su nombre, sexo, fechas, edad calculada, estado de salud, especie, tipo, país de origen, región y estado de conservación.

---

### Vista 3: vista_estadisticas_regiones

**Descripción**: Muestra estadísticas agrupadas por región geográfica incluyendo totales de países, especies, ejemplares y especies en peligro.

**Código SQL**:
```sql
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
```

**Consulta**:
```sql
SELECT * FROM vista_estadisticas_regiones;
```

**Contenido**: Retorna 6 filas (una por región) con estadísticas: nombre de región, total de países, total de especies, total de ejemplares y especies en peligro.

---

## 3. CONSULTAS SQL CON ÁLGEBRA RELACIONAL {#consultas-sql}

### Consulta 1: Total de ejemplares por tipo de animal (CON AGREGACIÓN)

**Descripción**: Cuenta cuántos ejemplares hay de cada tipo de animal (mamíferos, aves, reptiles, etc.) ordenados de mayor a menor.

**Código SQL**:
```sql
SELECT
  t.nombreTipo AS tipo_animal,
  COUNT(ej.idEjemplar) AS total_ejemplares,
  COUNT(DISTINCT e.idEspecie) AS total_especies
FROM tipo t
LEFT JOIN especie e ON t.idTipo = e.idTipo
LEFT JOIN ejemplar ej ON e.idEspecie = ej.idEspecie
GROUP BY t.idTipo, t.nombreTipo
ORDER BY total_ejemplares DESC;
```

**Álgebra Relacional**:
```
γ nombreTipo; COUNT(idEjemplar)→total_ejemplares, COUNT(DISTINCT idEspecie)→total_especies (
  tipo ⟕ (tipo.idTipo = especie.idTipo) especie
       ⟕ (especie.idEspecie = ejemplar.idEspecie) ejemplar
)
```

**Funciones de Agregación usadas**:
- `COUNT()` - Cuenta el número de ejemplares
- `COUNT(DISTINCT)` - Cuenta especies únicas
- `GROUP BY` - Agrupa por tipo de animal

**Resultado esperado**:
```
| tipo_animal | total_ejemplares | total_especies |
|-------------|------------------|----------------|
| Mamífero    | 20               | 20             |
| Ave         | 5                | 5              |
| Reptil      | 5                | 5              |
```

---

### Consulta 2: Promedio de ejemplares por región y estado de conservación (CON AGREGACIÓN)

**Descripción**: Calcula estadísticas de ejemplares agrupados por región y estado de conservación.

**Código SQL**:
```sql
SELECT
  r.nombre AS region,
  est.nombreConservacion AS estado_conservacion,
  COUNT(ej.idEjemplar) AS total_ejemplares,
  COUNT(DISTINCT e.idEspecie) AS especies_diferentes,
  ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, ej.fechaNacimiento))), 2) AS edad_promedio
FROM region r
INNER JOIN pais p ON r.idRegion = p.idRegion
INNER JOIN especie e ON p.idPais = e.idPais
INNER JOIN estadoConservacion est ON e.idConservacion = est.idConservacion
LEFT JOIN ejemplar ej ON e.idEspecie = ej.idEspecie
GROUP BY r.idRegion, r.nombre, est.idConservacion, est.nombreConservacion
HAVING COUNT(ej.idEjemplar) > 0
ORDER BY r.nombre, total_ejemplares DESC;
```

**Álgebra Relacional**:
```
σ total_ejemplares > 0 (
  γ nombre, nombreConservacion; COUNT(idEjemplar)→total_ejemplares,
    COUNT(DISTINCT idEspecie)→especies_diferentes,
    AVG(edad)→edad_promedio (
    region ⋈ pais ⋈ especie ⋈ estadoConservacion ⟕ ejemplar
  )
)
```

**Funciones de Agregación usadas**:
- `COUNT()` - Cuenta ejemplares
- `COUNT(DISTINCT)` - Cuenta especies únicas
- `AVG()` - Calcula edad promedio
- `GROUP BY` - Agrupa por región y estado
- `HAVING` - Filtra grupos con ejemplares

**Resultado esperado**: Múltiples filas mostrando estadísticas por combinación de región y estado de conservación.

---

### Consulta 3: Especies con sus ecosistemas, países y total de ejemplares (3+ TABLAS)

**Descripción**: Lista todas las especies con información de su ecosistema, país de origen y cuántos ejemplares tienen.

**Código SQL**:
```sql
SELECT
  e.nombreComun AS especie,
  e.nombreCientifico,
  ec.nombreEcosistema AS ecosistema,
  p.nombrePais AS pais,
  r.nombre AS region,
  COUNT(ej.idEjemplar) AS total_ejemplares
FROM especie e
INNER JOIN ecosistema ec ON e.idEcosistema = ec.idEcosistema
INNER JOIN pais p ON e.idPais = p.idPais
INNER JOIN region r ON p.idRegion = r.idRegion
LEFT JOIN ejemplar ej ON e.idEspecie = ej.idEspecie
GROUP BY e.idEspecie, e.nombreComun, e.nombreCientifico,
         ec.nombreEcosistema, p.nombrePais, r.nombre
ORDER BY total_ejemplares DESC, e.nombreComun;
```

**Álgebra Relacional**:
```
γ nombreComun, nombreCientifico, nombreEcosistema, nombrePais, nombre;
  COUNT(idEjemplar)→total_ejemplares (
  especie ⋈ (especie.idEcosistema = ecosistema.idEcosistema) ecosistema
          ⋈ (especie.idPais = pais.idPais) pais
          ⋈ (pais.idRegion = region.idRegion) region
          ⟕ (especie.idEspecie = ejemplar.idEspecie) ejemplar
)
```

**Tablas involucradas**: especie, ecosistema, pais, region, ejemplar (5 tablas)

**Resultado esperado**: 30 filas (una por especie) mostrando nombre común, científico, ecosistema, país, región y total de ejemplares.

---

### Consulta 4: Ejemplares con información completa de especie y ubicación (4+ TABLAS)

**Descripción**: Muestra todos los ejemplares con información completa de su especie, tipo, país y región de origen.

**Código SQL**:
```sql
SELECT
  ej.nombre AS nombre_ejemplar,
  ej.sexo,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, ej.fechaNacimiento)) AS edad,
  ej.estadoSalud,
  e.nombreComun AS especie,
  t.nombreTipo AS tipo,
  p.nombrePais AS pais_origen,
  r.nombre AS region_origen
FROM ejemplar ej
INNER JOIN especie e ON ej.idEspecie = e.idEspecie
INNER JOIN tipo t ON e.idTipo = t.idTipo
INNER JOIN pais p ON e.idPais = p.idPais
INNER JOIN region r ON p.idRegion = r.idRegion
ORDER BY ej.nombre;
```

**Álgebra Relacional**:
```
π nombre, sexo, edad, estadoSalud, nombreComun, nombreTipo, nombrePais, nombre_region (
  ejemplar ⋈ (ejemplar.idEspecie = especie.idEspecie) especie
           ⋈ (especie.idTipo = tipo.idTipo) tipo
           ⋈ (especie.idPais = pais.idPais) pais
           ⋈ (pais.idRegion = region.idRegion) region
)
```

**Tablas involucradas**: ejemplar, especie, tipo, pais, region (5 tablas)

**Resultado esperado**: 30 filas (una por ejemplar) con nombre, sexo, edad, estado de salud, especie, tipo, país y región de origen.

---

### Consulta 5: Especies en peligro con fichas técnicas completas (5+ TABLAS)

**Descripción**: Lista especies en estado crítico o en peligro con toda su información técnica.

**Código SQL**:
```sql
SELECT
  e.nombreComun AS especie,
  e.nombreCientifico,
  t.nombreTipo AS tipo,
  p.nombrePais AS pais,
  r.nombre AS region,
  est.nombreConservacion AS estado,
  ft.habitat,
  ft.dieta,
  ft.longevidad,
  COUNT(ej.idEjemplar) AS ejemplares_en_zoo
FROM especie e
INNER JOIN tipo t ON e.idTipo = t.idTipo
INNER JOIN pais p ON e.idPais = p.idPais
INNER JOIN region r ON p.idRegion = r.idRegion
INNER JOIN estadoConservacion est ON e.idConservacion = est.idConservacion
LEFT JOIN fichaTecnica ft ON e.idEspecie = ft.idEspecie
LEFT JOIN ejemplar ej ON e.idEspecie = ej.idEspecie
WHERE est.nombreConservacion IN ('Crítico', 'En Peligro')
GROUP BY e.idEspecie, e.nombreComun, e.nombreCientifico, t.nombreTipo,
         p.nombrePais, r.nombre, est.nombreConservacion,
         ft.habitat, ft.dieta, ft.longevidad
ORDER BY est.nombreConservacion, e.nombreComun;
```

**Álgebra Relacional**:
```
γ nombreComun, nombreCientifico, ...; COUNT(idEjemplar)→ejemplares_en_zoo (
  σ nombreConservacion IN ('Crítico', 'En Peligro') (
    especie ⋈ tipo ⋈ pais ⋈ region ⋈ estadoConservacion ⟕ fichaTecnica ⟕ ejemplar
  )
)
```

**Tablas involucradas**: especie, tipo, pais, region, estadoConservacion, fichaTecnica, ejemplar (7 tablas)

**Resultado esperado**: Especies en peligro con toda su información técnica y conteo de ejemplares en el zoológico.

---

## 4. TRIGGERS (DISPARADORES) {#triggers}

### Trigger 1: BEFORE INSERT - validar_fechas_ejemplar

**Descripción**: Trigger que se ejecuta ANTES de insertar o actualizar un ejemplar. Valida que:
- La fecha de nacimiento no sea futura
- La fecha de ingreso no sea anterior a la fecha de nacimiento
- Advierte si el ejemplar tiene más de 100 años

**Código SQL**:
```sql
CREATE OR REPLACE FUNCTION validar_fechas_ejemplar()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fechaNacimiento > CURRENT_DATE THEN
    RAISE EXCEPTION 'La fecha de nacimiento no puede ser futura';
  END IF;

  IF NEW.fechaIngreso < NEW.fechaNacimiento THEN
    RAISE EXCEPTION 'La fecha de ingreso no puede ser anterior a la fecha de nacimiento';
  END IF;

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
```

**Prueba del Trigger**:
```sql
-- Esta inserción FALLARÁ (fecha futura)
INSERT INTO ejemplar (nombre, sexo, fechaNacimiento, fechaIngreso, estadoSalud, idEspecie)
VALUES ('Test Futuro', 'M', '2025-12-31', '2025-12-31', 'Saludable', 1);
-- ERROR: La fecha de nacimiento no puede ser futura

-- Esta inserción FALLARÁ (fecha ingreso anterior a nacimiento)
INSERT INTO ejemplar (nombre, sexo, fechaNacimiento, fechaIngreso, estadoSalud, idEspecie)
VALUES ('Test Orden', 'M', '2020-06-01', '2020-01-01', 'Saludable', 1);
-- ERROR: La fecha de ingreso no puede ser anterior a la fecha de nacimiento

-- Esta inserción será EXITOSA
INSERT INTO ejemplar (nombre, sexo, fechaNacimiento, fechaIngreso, estadoSalud, idEspecie)
VALUES ('Test Correcto', 'M', '2020-01-15', '2020-03-20', 'Saludable', 1);
-- SUCCESS: Ejemplar insertado correctamente
```

**Resultado**:
- Primeros dos INSERT fallan con mensajes de error específicos
- Tercer INSERT se ejecuta correctamente
- El trigger previene datos inválidos en la base de datos

---

### Trigger 2: AFTER INSERT/UPDATE/DELETE - registrar_auditoria_ejemplar

**Descripción**: Trigger que se ejecuta DESPUÉS de cualquier operación (INSERT, UPDATE, DELETE) en la tabla ejemplar. Registra automáticamente la acción en la tabla de auditoría.

**Código SQL**:
```sql
CREATE OR REPLACE FUNCTION registrar_auditoria_ejemplar()
RETURNS TRIGGER AS $$
DECLARE
  v_accion VARCHAR(10);
  v_descripcion TEXT;
  v_nombre_especie VARCHAR(50);
BEGIN
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
```

**Prueba del Trigger**:
```sql
-- 1. Insertar un ejemplar (generará entrada en auditoría)
INSERT INTO ejemplar (nombre, sexo, fechaNacimiento, fechaIngreso, estadoSalud, idEspecie)
VALUES ('Trigger Test', 'F', '2021-01-01', '2021-02-01', 'Saludable', 1);

-- Ver la auditoría generada
SELECT * FROM auditoria ORDER BY fecha DESC LIMIT 1;
-- Resultado: idAuditoria | idUsuario | accion  | tablaAfectada | fecha | descripcionAuditoria
--            XX          | NULL      | INSERT  | ejemplar      | now() | Nuevo ejemplar: Trigger Test (Especie: León Africano)

-- 2. Actualizar el ejemplar (generará otra entrada)
UPDATE ejemplar SET estadoSalud = 'En tratamiento' WHERE nombre = 'Trigger Test';

-- Ver la nueva entrada de auditoría
SELECT * FROM auditoria ORDER BY fecha DESC LIMIT 1;
-- Resultado: idAuditoria | idUsuario | accion | tablaAfectada | fecha | descripcionAuditoria
--            XX+1        | NULL      | UPDATE | ejemplar      | now() | Actualización ejemplar: Trigger Test (ID: XX)

-- 3. Eliminar el ejemplar (generará otra entrada)
DELETE FROM ejemplar WHERE nombre = 'Trigger Test';

-- Ver la entrada de eliminación en auditoría
SELECT * FROM auditoria ORDER BY fecha DESC LIMIT 1;
-- Resultado: idAuditoria | idUsuario | accion | tablaAfectada | fecha | descripcionAuditoria
--            XX+2        | NULL      | DELETE | ejemplar      | now() | Eliminado ejemplar: Trigger Test (ID: XX)
```

**Resultado**:
- Cada operación (INSERT, UPDATE, DELETE) genera automáticamente una entrada en la tabla auditoria
- La descripción incluye detalles de la operación realizada
- Sistema de auditoría completo y automático

---

## 5. COMANDOS DE VERIFICACIÓN {#comandos-verificacion}

### Verificar Contenido de Tablas (SELECT * FROM)

```sql
-- CATÁLOGOS (datos necesarios)
SELECT * FROM region;           -- 6 registros
SELECT * FROM tipo;             -- 6 registros
SELECT * FROM ecosistema;       -- 10 registros
SELECT * FROM estadoConservacion; -- 7 registros
SELECT * FROM rol;              -- 2 registros

-- TABLAS PRINCIPALES (30 registros cada una)
SELECT * FROM pais;             -- 30 registros
SELECT * FROM especie;          -- 30 registros
SELECT * FROM fichaTecnica;     -- 30 registros
SELECT * FROM ejemplar;         -- 30 registros
SELECT * FROM usuario;          -- 30 registros

-- TABLA DE AUDITORÍA (registros generados por triggers)
SELECT * FROM auditoria ORDER BY fecha DESC;

-- VISTAS
SELECT * FROM vista_especies_completa;
SELECT * FROM vista_ejemplares_detalle;
SELECT * FROM vista_estadisticas_regiones;
```

### Verificar Conteo de Registros

```sql
SELECT 'region' as tabla, COUNT(*) as registros FROM region
UNION ALL
SELECT 'pais', COUNT(*) FROM pais
UNION ALL
SELECT 'tipo', COUNT(*) FROM tipo
UNION ALL
SELECT 'ecosistema', COUNT(*) FROM ecosistema
UNION ALL
SELECT 'estadoConservacion', COUNT(*) FROM estadoConservacion
UNION ALL
SELECT 'especie', COUNT(*) FROM especie
UNION ALL
SELECT 'fichaTecnica', COUNT(*) FROM fichaTecnica
UNION ALL
SELECT 'ejemplar', COUNT(*) FROM ejemplar
UNION ALL
SELECT 'rol', COUNT(*) FROM rol
UNION ALL
SELECT 'usuario', COUNT(*) FROM usuario
UNION ALL
SELECT 'auditoria', COUNT(*) FROM auditoria;
```

### Ejecutar Procedimientos Almacenados

```sql
-- Procedimiento 1
SELECT * FROM obtener_especies_por_estado_conservacion('Vulnerable');
SELECT * FROM obtener_especies_por_estado_conservacion('En Peligro');
SELECT * FROM obtener_especies_por_estado_conservacion('Crítico');

-- Procedimiento 2
SELECT * FROM calcular_estadisticas_zoo();

-- Procedimiento 3 (registra nuevo ejemplar)
SELECT registrar_nuevo_ejemplar(
  'Prueba Procedimiento', 'M', '2022-05-10', '2022-08-15', 'Saludable', 1, 1
);
```

---

## 6. RESUMEN DE CUMPLIMIENTO

### Requisitos del Proyecto

✅ **Base de datos poblada**:
- 30 registros en tablas principales (pais, especie, fichaTecnica, ejemplar, usuario)
- Registros necesarios en catálogos (region: 6, tipo: 6, ecosistema: 10, estadoConservacion: 7, rol: 2)

✅ **3 Procedimientos almacenados**:
1. obtener_especies_por_estado_conservacion - Filtrado de especies
2. calcular_estadisticas_zoo - Estadísticas generales
3. registrar_nuevo_ejemplar - Registro con auditoría automática

✅ **3 Vistas**:
1. vista_especies_completa - Información completa de especies
2. vista_ejemplares_detalle - Detalle de ejemplares con edad
3. vista_estadisticas_regiones - Estadísticas por región

✅ **5 Consultas SQL**:
- 2 con funciones de agregación (SUM, COUNT, AVG, GROUP BY)
- 3 que involucran 3 o más tablas
- Todas con álgebra relacional incluida

✅ **2 Triggers**:
1. BEFORE - validar_fechas_ejemplar (validaciones previas)
2. AFTER - registrar_auditoria_ejemplar (auditoría automática)

✅ **Documentación completa**:
- Descripción de cada elemento
- Código SQL de cada elemento
- Resultados esperados de cada consulta
- Álgebra relacional de consultas

---

## Notas Finales

- **Base de datos**: PostgreSQL (compatible con Supabase)
- **Origen**: Adaptado de MySQL
- **Seguridad**: Row Level Security (RLS) habilitado
- **Optimización**: Índices creados en claves foráneas
- **Integridad**: Validaciones mediante triggers
- **Auditoría**: Sistema automático de registro de cambios
- **Listo para entregar**: Toda la documentación y código incluidos

---

**Proyecto**: Zootopia - Sistema de Gestión de Biodiversidad
**Tecnología**: PostgreSQL / Supabase
**Frontend**: React + TypeScript
**Fecha**: Diciembre 2024
