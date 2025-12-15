/*
  # Migración Compatible con Frontend - Esquema Zootopia
  
  ## Descripción
  Esta migración crea el esquema completo usando snake_case para ser compatible
  con el frontend existente. Incluye:
  - Todas las tablas con nombres snake_case
  - 30 registros en cada tabla principal
  - RLS y políticas de seguridad
  - Compatible con procedimientos, vistas y triggers
  
  ## Diferencias con migración MySQL original
  - Nombres de tablas: plural y snake_case (regiones, paises, especies, ejemplares)
  - Nombres de columnas: snake_case (nombre_comun, pais_id, fecha_nacimiento)
  - IDs: simples (id en lugar de idRegion, idPais, etc.)
  - Foreign keys: snake_case con _id (region_id, pais_id, tipo_id)
*/

-- ============================================
-- ELIMINAR TABLAS EXISTENTES
-- ============================================
DROP TABLE IF EXISTS auditorias CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS ejemplares CASCADE;
DROP TABLE IF EXISTS fichas_tecnicas CASCADE;
DROP TABLE IF EXISTS especies CASCADE;
DROP TABLE IF EXISTS estados_conservacion CASCADE;
DROP TABLE IF EXISTS ecosistemas CASCADE;
DROP TABLE IF EXISTS tipos CASCADE;
DROP TABLE IF EXISTS paises CASCADE;
DROP TABLE IF EXISTS regiones CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- ============================================
-- TABLA: regiones
-- ============================================
CREATE TABLE regiones (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: paises
-- ============================================
CREATE TABLE paises (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL,
  region_id INT,
  FOREIGN KEY (region_id) REFERENCES regiones(id) ON DELETE CASCADE
);

-- ============================================
-- TABLA: tipos
-- ============================================
CREATE TABLE tipos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: ecosistemas
-- ============================================
CREATE TABLE ecosistemas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: estados_conservacion
-- ============================================
CREATE TABLE estados_conservacion (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(15) NOT NULL UNIQUE,
  codigo VARCHAR(5) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: especies
-- ============================================
CREATE TABLE especies (
  id SERIAL PRIMARY KEY,
  nombre_cientifico VARCHAR(50),
  nombre_comun VARCHAR(50),
  descripcion TEXT,
  tipo_id INT,
  pais_id INT,
  ecosistema_id INT,
  estado_conservacion_id INT,
  imagen_url TEXT,
  habitat_natural VARCHAR(70),
  dieta VARCHAR(70),
  reproduccion VARCHAR(70),
  longevidad VARCHAR(70),
  comportamiento VARCHAR(100),
  descripcion_general TEXT,
  FOREIGN KEY (tipo_id) REFERENCES tipos(id) ON DELETE RESTRICT,
  FOREIGN KEY (pais_id) REFERENCES paises(id) ON DELETE RESTRICT,
  FOREIGN KEY (ecosistema_id) REFERENCES ecosistemas(id) ON DELETE RESTRICT,
  FOREIGN KEY (estado_conservacion_id) REFERENCES estados_conservacion(id) ON DELETE RESTRICT
);

-- ============================================
-- TABLA: fichas_tecnicas
-- ============================================
CREATE TABLE fichas_tecnicas (
  id SERIAL PRIMARY KEY,
  especie_id INT UNIQUE,
  habitat VARCHAR(70),
  dieta VARCHAR(70),
  reproduccion VARCHAR(70),
  longevidad VARCHAR(70),
  comportamiento VARCHAR(100),
  FOREIGN KEY (especie_id) REFERENCES especies(id) ON DELETE CASCADE
);

-- ============================================
-- TABLA: ejemplares
-- ============================================
CREATE TABLE ejemplares (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50),
  sexo VARCHAR(1) CHECK (sexo IN ('M', 'F')),
  fecha_nacimiento DATE,
  fecha_ingreso DATE DEFAULT CURRENT_DATE,
  habitat_actual VARCHAR(70),
  estado_salud VARCHAR(70) DEFAULT 'Saludable',
  observaciones TEXT,
  especie_id INT,
  imagen_url TEXT,
  FOREIGN KEY (especie_id) REFERENCES especies(id) ON DELETE CASCADE
);

-- ============================================
-- TABLA: roles
-- ============================================
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: usuarios
-- ============================================
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  correo VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  rol_id INT,
  FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE SET NULL
);

-- ============================================
-- TABLA: auditorias
-- ============================================
CREATE TABLE auditorias (
  id SERIAL PRIMARY KEY,
  usuario_id INT,
  accion VARCHAR(50),
  tabla_afectada VARCHAR(40),
  fecha TIMESTAMPTZ DEFAULT NOW(),
  descripcion TEXT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- ============================================
-- TABLA: profiles (requerida por Supabase Auth)
-- Nota: Esta tabla es necesaria para Supabase Auth pero NO se usa en el frontend
-- El frontend usa la tabla 'usuarios' para los datos reales
-- ============================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ÍNDICES
-- ============================================
CREATE INDEX idx_paises_region ON paises(region_id);
CREATE INDEX idx_especies_tipo ON especies(tipo_id);
CREATE INDEX idx_especies_pais ON especies(pais_id);
CREATE INDEX idx_especies_ecosistema ON especies(ecosistema_id);
CREATE INDEX idx_ejemplares_especie ON ejemplares(especie_id);
CREATE INDEX idx_auditorias_usuario ON auditorias(usuario_id);
CREATE INDEX idx_auditorias_fecha ON auditorias(fecha);

-- ============================================
-- POBLAR DATOS - CATÁLOGOS
-- ============================================

-- Regiones (6 registros)
INSERT INTO regiones (nombre) VALUES
  ('África'),
  ('América del Norte'),
  ('América del Sur'),
  ('Asia'),
  ('Europa'),
  ('Australia');

-- Tipos (6 registros)
INSERT INTO tipos (nombre) VALUES
  ('Mamífero'),
  ('Ave'),
  ('Reptil'),
  ('Pez'),
  ('Anfibio'),
  ('Insecto');

-- Estados de Conservación (7 registros)
INSERT INTO estados_conservacion (nombre, codigo) VALUES
  ('Crítico', 'CR'),
  ('En Peligro', 'EN'),
  ('Vulnerable', 'VU'),
  ('Casi Amenazado', 'NT'),
  ('Preoc. Menor', 'LC'),
  ('Datos Insuf.', 'DD'),
  ('Extinto', 'EX');

-- Ecosistemas (10 registros)
INSERT INTO ecosistemas (nombre) VALUES
  ('Bosque Templado'),
  ('Tundra'),
  ('Sabana'),
  ('Arrecife Coral'),
  ('Selva Tropical'),
  ('Desierto'),
  ('Pradera'),
  ('Montaña'),
  ('Manglar'),
  ('Humedal');

-- Roles (2 registros)
INSERT INTO roles (nombre) VALUES
  ('admin'),
  ('user');

-- ============================================
-- POBLAR DATOS - 30 REGISTROS POR TABLA
-- ============================================

-- 30 Países
INSERT INTO paises (nombre, region_id) VALUES
  ('Kenia', 1), ('Tanzania', 1), ('Sudáfrica', 1), ('Madagascar', 1), ('Egipto', 1),
  ('Nigeria', 1), ('Marruecos', 1), ('Etiopía', 1), ('Ghana', 1), ('Zambia', 1),
  ('Estados Unidos', 2), ('Canadá', 2), ('México', 2), ('Guatemala', 2), ('Costa Rica', 2),
  ('Brasil', 3), ('Argentina', 3), ('Chile', 3), ('Perú', 3), ('Colombia', 3),
  ('Venezuela', 3), ('Ecuador', 3), ('Bolivia', 3), ('Uruguay', 3), ('Paraguay', 3),
  ('China', 4), ('India', 4), ('Japón', 4), ('Tailandia', 4), ('Indonesia', 4);

-- 30 Especies
INSERT INTO especies (nombre_cientifico, nombre_comun, descripcion, tipo_id, pais_id, ecosistema_id, estado_conservacion_id, habitat_natural, dieta, reproduccion, longevidad, comportamiento) VALUES
  ('Panthera leo', 'León Africano', 'Gran felino rey de la sabana', 1, 1, 3, 3, 'Sabanas africanas', 'Carnívoro - caza grandes ungulados', 'Camadas 1-4 cachorros', '10-14 años', 'Social, vive en manadas'),
  ('Loxodonta africana', 'Elefante Africano', 'Mamífero terrestre más grande', 1, 1, 3, 2, 'Sabanas y bosques', 'Herbívoro - 150kg vegetación diaria', 'Gestación 22 meses', '60-70 años', 'Matriarcal, muy inteligente'),
  ('Panthera onca', 'Jaguar', 'Felino más grande de América', 1, 16, 5, 3, 'Selvas tropicales', 'Carnívoro - caza mamíferos', 'Camadas 1-4 cachorros', '12-15 años', 'Solitario, territorial'),
  ('Ailuropoda melanoleuca', 'Oso Panda', 'Oso asiático comedor de bambú', 1, 26, 1, 3, 'Bosques de bambú', 'Herbívoro - 99% bambú', 'Cría única cada 2 años', '20-30 años', 'Solitario, pacífico'),
  ('Ursus maritimus', 'Oso Polar', 'Gran depredador del Ártico', 1, 12, 2, 3, 'Hielo ártico', 'Carnívoro - focas principalmente', 'Camadas 1-3 cachorros', '25-30 años', 'Solitario, excelente nadador'),
  ('Gorilla beringei', 'Gorila de Montaña', 'Gran simio africano', 1, 1, 1, 1, 'Montañas boscosas', 'Herbívoro - hojas y frutas', 'Cría única cada 4 años', '35-40 años', 'Social, grupos familiares'),
  ('Pongo pygmaeus', 'Orangután', 'Gran simio de Borneo', 1, 30, 5, 1, 'Selvas de Borneo', 'Frugívoro - principalmente frutas', 'Cría única cada 8 años', '35-45 años', 'Arbóreo, solitario'),
  ('Pan troglodytes', 'Chimpancé', 'Simio más cercano al humano', 1, 1, 5, 2, 'Bosques tropicales', 'Omnívoro - frutas e insectos', 'Camadas 1-2 crías', '40-50 años', 'Social, muy inteligente'),
  ('Giraffa camelopardalis', 'Jirafa', 'Mamífero terrestre más alto', 1, 1, 3, 3, 'Sabanas africanas', 'Herbívoro - hojas de acacia', 'Cría única', '20-25 años', 'Gregario, manadas mixtas'),
  ('Hippopotamus amphibius', 'Hipopótamo', 'Gran mamífero semiacuático', 1, 2, 10, 3, 'Ríos y lagos', 'Herbívoro - pasto acuático', 'Cría única', '40-50 años', 'Territorial, agresivo'),
  ('Haliaeetus leucocephalus', 'Águila Calva', 'Ave nacional de EE.UU.', 2, 11, 1, 5, 'Cerca de agua', 'Carnívoro - principalmente peces', 'Nidadas 1-3 huevos', '20-30 años', 'Monógamo, territorial'),
  ('Spheniscus humboldti', 'Pingüino de Humboldt', 'Ave marina no voladora', 2, 19, 4, 3, 'Costas rocosas', 'Piscívoro - peces pequeños', 'Nidadas 2-3 huevos', '15-20 años', 'Colonial, buceador'),
  ('Ara ararauna', 'Guacamayo Azul', 'Gran loro amazónico', 2, 16, 5, 5, 'Selva amazónica', 'Frugívoro - frutas y nueces', 'Nidadas 2-3 huevos', '30-50 años', 'Social, ruidoso'),
  ('Struthio camelus', 'Avestruz', 'Ave más grande del mundo', 2, 3, 3, 5, 'Sabanas y desiertos', 'Herbívoro - semillas y plantas', 'Nidadas 2-4 huevos', '40-45 años', 'Gregario, rápido corredor'),
  ('Aquila chrysaetos', 'Águila Real', 'Majestuosa rapaz', 2, 11, 8, 5, 'Montañas y campos', 'Carnívoro - mamíferos pequeños', 'Nidadas 1-3 huevos', '30 años', 'Territorial, excelente cazador'),
  ('Crocodylus niloticus', 'Cocodrilo del Nilo', 'Gran reptil africano', 3, 1, 10, 3, 'Ríos y pantanos', 'Carnívoro - peces y mamíferos', 'Nidadas 40-60 huevos', '70-100 años', 'Acuático, emboscador'),
  ('Varanus komodoensis', 'Dragón de Komodo', 'Lagarto más grande', 3, 30, 3, 2, 'Islas de Indonesia', 'Carnívoro - carroña y presas vivas', 'Nidadas 20 huevos', '30 años', 'Solitario, depredador ápice'),
  ('Python molurus', 'Pitón Birmana', 'Gran serpiente constrictora', 3, 27, 5, 3, 'Selvas y pantanos', 'Carnívoro - mamíferos', 'Nidadas 30-100 huevos', '20-25 años', 'Nocturno, constrictor'),
  ('Chelonia mydas', 'Tortuga Verde', 'Gran tortuga marina', 3, 14, 4, 2, 'Océanos tropicales', 'Herbívoro - algas marinas', 'Nidadas 100-200 huevos', '80 años', 'Migratoria, pacífica'),
  ('Iguana iguana', 'Iguana Verde', 'Gran lagarto herbívoro', 3, 14, 5, 5, 'Selvas tropicales', 'Herbívoro - hojas y frutas', 'Nidadas 20-70 huevos', '15-20 años', 'Arbóreo, territorial'),
  ('Carcharodon carcharias', 'Tiburón Blanco', 'Gran depredador marino', 4, 3, 4, 3, 'Océanos templados', 'Carnívoro - peces y focas', 'Camadas 2-10 crías', '70 años', 'Solitario, migra grandes distancias'),
  ('Hippocampus kuda', 'Caballito de Mar', 'Pequeño pez único', 4, 30, 4, 3, 'Arrecifes coralinos', 'Omnívoro - plancton', 'Gestación en macho', '1-5 años', 'Monógamo, único'),
  ('Manta birostris', 'Mantarraya Gigante', 'Gran raya pelágica', 4, 30, 4, 3, 'Océanos tropicales', 'Planctívoro', 'Camadas 1 cría', '20 años', 'Pacífico, elegante nadador'),
  ('Thunnus thynnus', 'Atún Rojo', 'Gran pez migratorio', 4, 28, 4, 2, 'Océanos mundial', 'Carnívoro - peces', 'Grandes migraciones', '15-30 años', 'Veloz, gran migrador'),
  ('Pterophyllum scalare', 'Pez Ángel', 'Pez tropical de agua dulce', 4, 16, 10, 5, 'Ríos amazónicos', 'Omnívoro - larvas', 'Desove continuo', '5-8 años', 'Pacífico, cardumen'),
  ('Dendrobates tinctorius', 'Rana Venenosa', 'Anfibio tóxico colorido', 5, 16, 5, 3, 'Suelo de selva', 'Insectívoro', 'Renacuajos en agua', '3-5 años', 'Territorial, tóxico'),
  ('Ambystoma mexicanum', 'Ajolote', 'Anfibio mexicano único', 5, 13, 10, 1, 'Lagos y canales', 'Carnívoro - gusanos', 'Neotenia permanente', '10-15 años', 'Acuático, regeneración'),
  ('Bufo bufo', 'Sapo Común', 'Anfibio europeo', 5, 11, 1, 5, 'Bosques y jardines', 'Insectívoro', 'Huevos en agua', '10-12 años', 'Nocturno, solitario'),
  ('Danaus plexippus', 'Mariposa Monarca', 'Insecto migratorio', 6, 11, 1, 5, 'Campos y bosques', 'Nectarívoro', 'Metamorfosis completa', '2-6 semanas', 'Migra miles de km'),
  ('Apis mellifera', 'Abeja Melífera', 'Insecto polinizador', 6, 11, 1, 3, 'Colmenas', 'Nectarívoro y polen', 'Reina pone miles', '1 temporada', 'Eusocial, danza comunicativa');

-- 30 Fichas Técnicas (una por especie)
INSERT INTO fichas_tecnicas (especie_id, habitat, dieta, reproduccion, longevidad, comportamiento) VALUES
  (1, 'Sabanas africanas', 'Carnívoro - caza grandes ungulados', 'Camadas 1-4 cachorros', '10-14 años', 'Social, vive en manadas'),
  (2, 'Sabanas y bosques', 'Herbívoro - 150kg vegetación diaria', 'Gestación 22 meses', '60-70 años', 'Matriarcal, muy inteligente'),
  (3, 'Selvas tropicales', 'Carnívoro - caza mamíferos', 'Camadas 1-4 cachorros', '12-15 años', 'Solitario, territorial'),
  (4, 'Bosques de bambú', 'Herbívoro - 99% bambú', 'Cría única cada 2 años', '20-30 años', 'Solitario, pacífico'),
  (5, 'Hielo ártico', 'Carnívoro - focas principalmente', 'Camadas 1-3 cachorros', '25-30 años', 'Solitario, excelente nadador'),
  (6, 'Montañas boscosas', 'Herbívoro - hojas y frutas', 'Cría única cada 4 años', '35-40 años', 'Social, grupos familiares'),
  (7, 'Selvas de Borneo', 'Frugívoro - principalmente frutas', 'Cría única cada 8 años', '35-45 años', 'Arbóreo, solitario'),
  (8, 'Bosques tropicales', 'Omnívoro - frutas e insectos', 'Camadas 1-2 crías', '40-50 años', 'Social, muy inteligente'),
  (9, 'Sabanas africanas', 'Herbívoro - hojas de acacia', 'Cría única', '20-25 años', 'Gregario, manadas mixtas'),
  (10, 'Ríos y lagos', 'Herbívoro - pasto acuático', 'Cría única', '40-50 años', 'Territorial, agresivo'),
  (11, 'Cerca de agua', 'Carnívoro - principalmente peces', 'Nidadas 1-3 huevos', '20-30 años', 'Monógamo, territorial'),
  (12, 'Costas rocosas', 'Piscívoro - peces pequeños', 'Nidadas 2-3 huevos', '15-20 años', 'Colonial, buceador'),
  (13, 'Selva amazónica', 'Frugívoro - frutas y nueces', 'Nidadas 2-3 huevos', '30-50 años', 'Social, ruidoso'),
  (14, 'Sabanas y desiertos', 'Herbívoro - semillas y plantas', 'Nidadas 2-4 huevos', '40-45 años', 'Gregario, rápido corredor'),
  (15, 'Montañas y campos', 'Carnívoro - mamíferos pequeños', 'Nidadas 1-3 huevos', '30 años', 'Territorial, excelente cazador'),
  (16, 'Ríos y pantanos', 'Carnívoro - peces y mamíferos', 'Nidadas 40-60 huevos', '70-100 años', 'Acuático, emboscador'),
  (17, 'Islas de Indonesia', 'Carnívoro - carroña y presas vivas', 'Nidadas 20 huevos', '30 años', 'Solitario, depredador ápice'),
  (18, 'Selvas y pantanos', 'Carnívoro - mamíferos', 'Nidadas 30-100 huevos', '20-25 años', 'Nocturno, constrictor'),
  (19, 'Océanos tropicales', 'Herbívoro - algas marinas', 'Nidadas 100-200 huevos', '80 años', 'Migratoria, pacífica'),
  (20, 'Selvas tropicales', 'Herbívoro - hojas y frutas', 'Nidadas 20-70 huevos', '15-20 años', 'Arbóreo, territorial'),
  (21, 'Océanos templados', 'Carnívoro - peces y focas', 'Camadas 2-10 crías', '70 años', 'Solitario, migra grandes distancias'),
  (22, 'Arrecifes coralinos', 'Omnívoro - plancton', 'Gestación en macho', '1-5 años', 'Monógamo, único'),
  (23, 'Océanos tropicales', 'Planctívoro', 'Camadas 1 cría', '20 años', 'Pacífico, elegante nadador'),
  (24, 'Océanos mundial', 'Carnívoro - peces', 'Grandes migraciones', '15-30 años', 'Veloz, gran migrador'),
  (25, 'Ríos amazónicos', 'Omnívoro - larvas', 'Desove continuo', '5-8 años', 'Pacífico, cardumen'),
  (26, 'Suelo de selva', 'Insectívoro', 'Renacuajos en agua', '3-5 años', 'Territorial, tóxico'),
  (27, 'Lagos y canales', 'Carnívoro - gusanos', 'Neotenia permanente', '10-15 años', 'Acuático, regeneración'),
  (28, 'Bosques y jardines', 'Insectívoro', 'Huevos en agua', '10-12 años', 'Nocturno, solitario'),
  (29, 'Campos y bosques', 'Nectarívoro', 'Metamorfosis completa', '2-6 semanas', 'Migra miles de km'),
  (30, 'Colmenas', 'Nectarívoro y polen', 'Reina pone miles', '1 temporada', 'Eusocial, danza comunicativa');

-- 30 Ejemplares
INSERT INTO ejemplares (nombre, sexo, fecha_nacimiento, fecha_ingreso, estado_salud, especie_id) VALUES
  ('Simba', 'M', '2018-05-12', '2018-07-20', 'Saludable', 1),
  ('Nala', 'F', '2018-05-15', '2018-07-20', 'Saludable', 1),
  ('Dumbo', 'M', '2015-03-10', '2016-01-15', 'Saludable', 2),
  ('Jaggy', 'M', '2019-08-22', '2019-10-01', 'Saludable', 3),
  ('Bao Bao', 'F', '2020-01-05', '2020-03-12', 'Saludable', 4),
  ('Frost', 'M', '2017-11-20', '2018-02-14', 'En tratamiento', 5),
  ('Kong', 'M', '2016-06-18', '2017-01-10', 'Saludable', 6),
  ('Raja', 'F', '2019-04-25', '2019-08-15', 'Saludable', 7),
  ('Charlie', 'M', '2018-09-10', '2019-02-20', 'Saludable', 8),
  ('Melman', 'M', '2017-07-14', '2018-01-10', 'Saludable', 9),
  ('Gloria', 'F', '2016-12-05', '2017-06-15', 'Saludable', 10),
  ('Freedom', 'F', '2019-03-22', '2019-05-30', 'Saludable', 11),
  ('Pablo', 'M', '2020-08-15', '2020-11-10', 'Saludable', 12),
  ('Blu', 'M', '2018-06-20', '2018-09-01', 'Saludable', 13),
  ('Kalahari', 'F', '2017-04-10', '2017-08-20', 'Saludable', 14),
  ('Golden', 'M', '2019-02-28', '2019-06-15', 'Saludable', 15),
  ('Sobek', 'M', '2014-11-12', '2015-05-20', 'Saludable', 16),
  ('Komodo', 'F', '2016-07-30', '2017-03-10', 'Saludable', 17),
  ('Kaa', 'F', '2018-01-15', '2018-04-22', 'Saludable', 18),
  ('Marina', 'F', '2015-05-20', '2016-02-10', 'En recuperación', 19),
  ('Verde', 'M', '2019-09-08', '2020-01-15', 'Saludable', 20),
  ('Jaws', 'M', '2012-03-14', '2013-11-20', 'Saludable', 21),
  ('Poseidón', 'M', '2020-06-10', '2020-08-25', 'Saludable', 22),
  ('Manta', 'F', '2017-10-05', '2018-03-15', 'Saludable', 23),
  ('Atún', 'M', '2019-12-20', '2020-04-10', 'Saludable', 24),
  ('Ángel', 'F', '2021-02-14', '2021-05-20', 'Saludable', 25),
  ('Tinto', 'M', '2020-07-22', '2020-10-05', 'Saludable', 26),
  ('Xolotl', 'M', '2019-11-30', '2020-02-18', 'En tratamiento', 27),
  ('Sapo', 'M', '2020-04-05', '2020-07-12', 'Saludable', 28),
  ('Danaus', 'F', '2021-05-15', '2021-06-01', 'Saludable', 29),
  ('Reina', 'F', '2021-04-20', '2021-05-10', 'Saludable', 30);

-- 30 Usuarios
INSERT INTO usuarios (correo, password, rol_id) VALUES
  ('admin@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 1),
  ('user1@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user2@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user3@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user4@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user5@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user6@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user7@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user8@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user9@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user10@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user11@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user12@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user13@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user14@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user15@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user16@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user17@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user18@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user19@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user20@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user21@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user22@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user23@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user24@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user25@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user26@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user27@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('user28@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 2),
  ('veterinario@zootopia.com', '$2a$10$abcdefghijklmnopqrstuv', 1);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE regiones ENABLE ROW LEVEL SECURITY;
ALTER TABLE paises ENABLE ROW LEVEL SECURITY;
ALTER TABLE tipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecosistemas ENABLE ROW LEVEL SECURITY;
ALTER TABLE estados_conservacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE especies ENABLE ROW LEVEL SECURITY;
ALTER TABLE fichas_tecnicas ENABLE ROW LEVEL SECURITY;
ALTER TABLE ejemplares ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Políticas de lectura pública para catálogos y datos de especies
CREATE POLICY "Lectura pública regiones" ON regiones FOR SELECT USING (true);
CREATE POLICY "Lectura pública paises" ON paises FOR SELECT USING (true);
CREATE POLICY "Lectura pública tipos" ON tipos FOR SELECT USING (true);
CREATE POLICY "Lectura pública ecosistemas" ON ecosistemas FOR SELECT USING (true);
CREATE POLICY "Lectura pública estados_conservacion" ON estados_conservacion FOR SELECT USING (true);
CREATE POLICY "Lectura pública especies" ON especies FOR SELECT USING (true);
CREATE POLICY "Lectura pública fichas_tecnicas" ON fichas_tecnicas FOR SELECT USING (true);
CREATE POLICY "Lectura pública ejemplares" ON ejemplares FOR SELECT USING (true);

-- Políticas para profiles (requerido por Supabase Auth)
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);

-- Políticas para usuarios (permitir registro)
CREATE POLICY "Usuarios pueden registrarse" ON usuarios FOR INSERT WITH CHECK (true);
CREATE POLICY "Usuarios pueden ver su propio registro" ON usuarios FOR SELECT USING (correo = auth.jwt()->>'email');

-- Políticas para especies (admins pueden editar)
CREATE POLICY "Admins pueden insertar especies" ON especies 
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios 
      WHERE correo = auth.jwt()->>'email' 
      AND rol_id = 1
    )
  );

CREATE POLICY "Admins pueden actualizar especies" ON especies 
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM usuarios 
      WHERE correo = auth.jwt()->>'email' 
      AND rol_id = 1
    )
  );

CREATE POLICY "Admins pueden eliminar especies" ON especies 
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM usuarios 
      WHERE correo = auth.jwt()->>'email' 
      AND rol_id = 1
    )
  );

-- Políticas para ejemplares (admins pueden editar)
CREATE POLICY "Admins pueden insertar ejemplares" ON ejemplares 
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios 
      WHERE correo = auth.jwt()->>'email' 
      AND rol_id = 1
    )
  );

CREATE POLICY "Admins pueden actualizar ejemplares" ON ejemplares 
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM usuarios 
      WHERE correo = auth.jwt()->>'email' 
      AND rol_id = 1
    )
  );

CREATE POLICY "Admins pueden eliminar ejemplares" ON ejemplares 
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM usuarios 
      WHERE correo = auth.jwt()->>'email' 
      AND rol_id = 1
    )
  );

-- Nota: Las políticas de escritura y para usuarios/auditoria se configurarán según necesidades específicas

-- ============================================
-- TRIGGER: Auto-crear profile al registrarse (requerido por Supabase Auth)
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
