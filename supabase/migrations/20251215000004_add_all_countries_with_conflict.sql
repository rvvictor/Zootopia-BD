/*
  # Migración: Agregar Todos los Países del Mundo (CON ON CONFLICT)
  
  ## Descripción
  Esta es una versión MEJORADA del script de países que usa ON CONFLICT
  para evitar duplicados automáticamente.
  
  ## REQUISITO PREVIO
  Antes de ejecutar este script, debes agregar la restricción UNIQUE:
  
  ALTER TABLE paises 
  ADD CONSTRAINT paises_nombre_unique UNIQUE (nombre);
  
  O ejecutar: supabase/migrations/20251215000003_add_unique_constraint_paises.sql
  
  ## Beneficios
  - ✅ Seguro ejecutar múltiples veces
  - ✅ No crea duplicados
  - ✅ Solo inserta países nuevos
  
  ## Total de Países: 187
*/

-- ============================================
-- ÁFRICA (54 países) - region_id = 1
-- ============================================
INSERT INTO paises (nombre, region_id) VALUES
  ('Argelia', 1),
  ('Angola', 1),
  ('Benín', 1),
  ('Botsuana', 1),
  ('Burkina Faso', 1),
  ('Burundi', 1),
  ('Camerún', 1),
  ('Cabo Verde', 1),
  ('República Centroafricana', 1),
  ('Chad', 1),
  ('Comoras', 1),
  ('República Democrática del Congo', 1),
  ('República del Congo', 1),
  ('Yibuti', 1),
  ('Egipto', 1),
  ('Guinea Ecuatorial', 1),
  ('Eritrea', 1),
  ('Etiopía', 1),
  ('Gabón', 1),
  ('Gambia', 1),
  ('Ghana', 1),
  ('Guinea', 1),
  ('Guinea-Bisáu', 1),
  ('Costa de Marfil', 1),
  ('Kenia', 1),
  ('Lesoto', 1),
  ('Liberia', 1),
  ('Libia', 1),
  ('Madagascar', 1),
  ('Malaui', 1),
  ('Malí', 1),
  ('Mauritania', 1),
  ('Mauricio', 1),
  ('Marruecos', 1),
  ('Mozambique', 1),
  ('Namibia', 1),
  ('Níger', 1),
  ('Nigeria', 1),
  ('Ruanda', 1),
  ('Santo Tomé y Príncipe', 1),
  ('Senegal', 1),
  ('Seychelles', 1),
  ('Sierra Leona', 1),
  ('Somalia', 1),
  ('Sudáfrica', 1),
  ('Sudán del Sur', 1),
  ('Sudán', 1),
  ('Esuatini', 1),
  ('Tanzania', 1),
  ('Togo', 1),
  ('Túnez', 1),
  ('Uganda', 1),
  ('Zambia', 1),
  ('Zimbabue', 1)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- AMÉRICA DEL NORTE (14 países) - region_id = 2
-- ============================================
INSERT INTO paises (nombre, region_id) VALUES
  ('Estados Unidos', 2),
  ('México', 2),
  ('Canadá', 2),
  ('Guatemala', 2),
  ('Belice', 2),
  ('Honduras', 2),
  ('El Salvador', 2),
  ('Nicaragua', 2),
  ('Costa Rica', 2),
  ('Panamá', 2),
  ('Cuba', 2),
  ('Jamaica', 2),
  ('Haití', 2),
  ('República Dominicana', 2)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- AMÉRICA DEL SUR (13 países) - region_id = 3
-- ============================================
INSERT INTO paises (nombre, region_id) VALUES
  ('Brasil', 3),
  ('Argentina', 3),
  ('Chile', 3),
  ('Perú', 3),
  ('Colombia', 3),
  ('Venezuela', 3),
  ('Ecuador', 3),
  ('Bolivia', 3),
  ('Paraguay', 3),
  ('Uruguay', 3),
  ('Guyana', 3),
  ('Surinam', 3),
  ('Guayana Francesa', 3)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- ASIA (48 países) - region_id = 4
-- ============================================
INSERT INTO paises (nombre, region_id) VALUES
  ('Afganistán', 4),
  ('Armenia', 4),
  ('Azerbaiyán', 4),
  ('Baréin', 4),
  ('Bangladés', 4),
  ('Bután', 4),
  ('Brunéi', 4),
  ('Camboya', 4),
  ('China', 4),
  ('Chipre', 4),
  ('Georgia', 4),
  ('India', 4),
  ('Indonesia', 4),
  ('Irán', 4),
  ('Irak', 4),
  ('Israel', 4),
  ('Japón', 4),
  ('Jordania', 4),
  ('Kazajistán', 4),
  ('Kuwait', 4),
  ('Kirguistán', 4),
  ('Laos', 4),
  ('Líbano', 4),
  ('Malasia', 4),
  ('Maldivas', 4),
  ('Mongolia', 4),
  ('Birmania', 4),
  ('Nepal', 4),
  ('Corea del Norte', 4),
  ('Omán', 4),
  ('Pakistán', 4),
  ('Palestina', 4),
  ('Filipinas', 4),
  ('Catar', 4),
  ('Arabia Saudita', 4),
  ('Singapur', 4),
  ('Corea del Sur', 4),
  ('Sri Lanka', 4),
  ('Siria', 4),
  ('Taiwán', 4),
  ('Tayikistán', 4),
  ('Tailandia', 4),
  ('Timor Oriental', 4),
  ('Turquía', 4),
  ('Turkmenistán', 4),
  ('Emiratos Árabes Unidos', 4),
  ('Uzbekistán', 4),
  ('Vietnam', 4),
  ('Yemen', 4)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- EUROPA (44 países) - region_id = 5
-- ============================================
INSERT INTO paises (nombre, region_id) VALUES
  ('Albania', 5),
  ('Andorra', 5),
  ('Austria', 5),
  ('Bielorrusia', 5),
  ('Bélgica', 5),
  ('Bosnia y Herzegovina', 5),
  ('Bulgaria', 5),
  ('Croacia', 5),
  ('República Checa', 5),
  ('Dinamarca', 5),
  ('Estonia', 5),
  ('Finlandia', 5),
  ('Francia', 5),
  ('Alemania', 5),
  ('Grecia', 5),
  ('Hungría', 5),
  ('Islandia', 5),
  ('Irlanda', 5),
  ('Italia', 5),
  ('Letonia', 5),
  ('Liechtenstein', 5),
  ('Lituania', 5),
  ('Luxemburgo', 5),
  ('Macedonia del Norte', 5),
  ('Malta', 5),
  ('Moldavia', 5),
  ('Mónaco', 5),
  ('Montenegro', 5),
  ('Países Bajos', 5),
  ('Noruega', 5),
  ('Polonia', 5),
  ('Portugal', 5),
  ('Rumania', 5),
  ('Rusia', 5),
  ('San Marino', 5),
  ('Serbia', 5),
  ('Eslovaquia', 5),
  ('Eslovenia', 5),
  ('España', 5),
  ('Suecia', 5),
  ('Suiza', 5),
  ('Ucrania', 5),
  ('Reino Unido', 5),
  ('Vaticano', 5)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- AUSTRALIA/OCEANÍA (14 países) - region_id = 6
-- ============================================
INSERT INTO paises (nombre, region_id) VALUES
  ('Australia', 6),
  ('Nueva Zelanda', 6),
  ('Fiyi', 6),
  ('Papúa Nueva Guinea', 6),
  ('Islas Salomón', 6),
  ('Vanuatu', 6),
  ('Samoa', 6),
  ('Kiribati', 6),
  ('Tonga', 6),
  ('Micronesia', 6),
  ('Palaos', 6),
  ('Islas Marshall', 6),
  ('Nauru', 6),
  ('Tuvalu', 6)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT 
  r.nombre AS region,
  COUNT(p.id) AS total_paises
FROM regiones r
LEFT JOIN paises p ON r.id = p.region_id
GROUP BY r.id, r.nombre
ORDER BY r.nombre;

SELECT COUNT(*) AS total_paises_mundial FROM paises;
