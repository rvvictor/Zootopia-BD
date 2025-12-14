/*
  # Poblar Esquema del Frontend con 30 Registros
  
  Esta migración transfiere los datos del esquema escolar al esquema del frontend
  para que la aplicación web muestre los 30 registros completos.
  
  ## Tablas Afectadas
  - especies (schema frontend con UUID)
  - ejemplares (schema frontend con UUID)
  
  ## Estrategia
  1. Insertar las 30 especies adaptando del esquema escolar
  2. Insertar los 30 ejemplares adaptando del esquema escolar
*/

-- Primero limpiar las tablas existentes
DELETE FROM ejemplares;
DELETE FROM especies;

-- Insertar 30 especies del esquema escolar al esquema frontend
INSERT INTO especies (
  nombre_comun,
  nombre_cientifico,
  tipo_id,
  pais_id,
  ecosistema_id,
  habitat_natural,
  dieta,
  reproduccion,
  longevidad,
  comportamiento,
  estado_conservacion_id,
  descripcion_general
)
SELECT 
  e.nombrecomun,
  e.nombrecientifico,
  (SELECT t2.id FROM tipos t2 WHERE t2.nombre = t.nombretipo LIMIT 1),
  (SELECT p2.id FROM paises p2 WHERE p2.nombre = p.nombrepais LIMIT 1),
  (SELECT ec2.id FROM ecosistemas ec2 WHERE ec2.nombre = ec.nombreecosistema LIMIT 1),
  ft.habitat,
  ft.dieta,
  ft.reproduccion,
  ft.longevidad,
  ft.comportamiento,
  (SELECT est2.id FROM estados_conservacion est2 WHERE est2.nombre = est.nombreconservacion LIMIT 1),
  e.descripcion
FROM especie e
LEFT JOIN tipo t ON e.idtipo = t.idtipo
LEFT JOIN pais p ON e.idpais = p.idpais
LEFT JOIN ecosistema ec ON e.idecosistema = ec.idecosistema
LEFT JOIN estadoconservacion est ON e.idconservacion = est.idconservacion
LEFT JOIN fichatecnica ft ON e.idespecie = ft.idespecie
ORDER BY e.idespecie;

-- Insertar 30 ejemplares del esquema escolar al esquema frontend
INSERT INTO ejemplares (
  nombre,
  especie_id,
  sexo,
  fecha_nacimiento,
  fecha_ingreso,
  estado_salud
)
SELECT 
  ej.nombre,
  (SELECT esp.id FROM especies esp 
   WHERE esp.nombre_comun = e.nombrecomun 
   LIMIT 1),
  CASE 
    WHEN ej.sexo = 'M' THEN 'Macho'
    WHEN ej.sexo = 'F' THEN 'Hembra'
    ELSE 'Macho'
  END,
  ej.fechanacimiento,
  ej.fechaingreso,
  ej.estadosalud
FROM ejemplar ej
LEFT JOIN especie e ON ej.idespecie = e.idespecie
WHERE ej.idejemplar <= 30
ORDER BY ej.idejemplar;
