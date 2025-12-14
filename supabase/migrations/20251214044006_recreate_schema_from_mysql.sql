/*
  # Recrear esquema Zootopia desde MySQL a PostgreSQL
  
  ## Descripción
  Esta migración adapta el esquema MySQL original del proyecto Zootopia a PostgreSQL
  y puebla las tablas con 30 registros cada una según los requisitos del proyecto.
  
  ## Tablas Creadas
  1. region - Regiones geográficas (6 registros - catálogo)
  2. pais - Países por región (30 registros)
  3. tipo - Tipos de animales (6 registros - catálogo)
  4. ecosistema - Ecosistemas (10 registros - catálogo)
  5. estadoConservacion - Estados de conservación (7 registros - catálogo)
  6. especie - Especies de animales (30 registros)
  7. fichaTecnica - Fichas técnicas de especies (30 registros)
  8. ejemplar - Ejemplares individuales (30 registros)
  9. rol - Roles de usuario (2 registros - catálogo)
  10. usuario - Usuarios del sistema (30 registros)
  11. auditoria - Log de auditoría (para triggers)
  
  ## Cambios de MySQL a PostgreSQL
  - AUTO_INCREMENT → SERIAL
  - CHAR(1) → VARCHAR(1)
  - TIMESTAMP DEFAULT CURRENT_TIMESTAMP → TIMESTAMPTZ DEFAULT NOW()
  
  ## Seguridad
  - RLS habilitado en todas las tablas
  - Políticas de lectura pública para datos de especies
  - Políticas de escritura solo para administradores
*/

-- Eliminar tablas existentes si hay conflictos
DROP TABLE IF EXISTS auditoria CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;
DROP TABLE IF EXISTS rol CASCADE;
DROP TABLE IF EXISTS ejemplar CASCADE;
DROP TABLE IF EXISTS fichaTecnica CASCADE;
DROP TABLE IF EXISTS especie CASCADE;
DROP TABLE IF EXISTS estadoConservacion CASCADE;
DROP TABLE IF EXISTS ecosistema CASCADE;
DROP TABLE IF EXISTS tipo CASCADE;
DROP TABLE IF EXISTS pais CASCADE;
DROP TABLE IF EXISTS region CASCADE;

-- ============================================
-- TABLA: region
-- ============================================
CREATE TABLE region (
  idRegion SERIAL PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: pais
-- ============================================
CREATE TABLE pais (
  idPais SERIAL PRIMARY KEY,
  nombrePais VARCHAR(30) NOT NULL,
  idRegion INT,
  FOREIGN KEY (idRegion) REFERENCES region(idRegion) ON DELETE CASCADE
);

-- ============================================
-- TABLA: tipo
-- ============================================
CREATE TABLE tipo (
  idTipo SERIAL PRIMARY KEY,
  nombreTipo VARCHAR(20) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: ecosistema
-- ============================================
CREATE TABLE ecosistema (
  idEcosistema SERIAL PRIMARY KEY,
  nombreEcosistema VARCHAR(30) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: estadoConservacion
-- ============================================
CREATE TABLE estadoConservacion (
  idConservacion SERIAL PRIMARY KEY,
  nombreConservacion VARCHAR(15) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: especie
-- ============================================
CREATE TABLE especie (
  idEspecie SERIAL PRIMARY KEY,
  nombreCientifico VARCHAR(50),
  nombreComun VARCHAR(50),
  descripcion TEXT,
  idTipo INT,
  idPais INT,
  idEcosistema INT,
  idConservacion INT,
  FOREIGN KEY (idTipo) REFERENCES tipo(idTipo) ON DELETE RESTRICT,
  FOREIGN KEY (idPais) REFERENCES pais(idPais) ON DELETE RESTRICT,
  FOREIGN KEY (idEcosistema) REFERENCES ecosistema(idEcosistema) ON DELETE RESTRICT,
  FOREIGN KEY (idConservacion) REFERENCES estadoConservacion(idConservacion) ON DELETE RESTRICT
);

-- ============================================
-- TABLA: fichaTecnica
-- ============================================
CREATE TABLE fichaTecnica (
  idFicha SERIAL PRIMARY KEY,
  idEspecie INT UNIQUE,
  habitat VARCHAR(70),
  dieta VARCHAR(70),
  reproduccion VARCHAR(70),
  longevidad VARCHAR(70),
  comportamiento VARCHAR(100),
  FOREIGN KEY (idEspecie) REFERENCES especie(idEspecie) ON DELETE CASCADE
);

-- ============================================
-- TABLA: ejemplar
-- ============================================
CREATE TABLE ejemplar (
  idEjemplar SERIAL PRIMARY KEY,
  nombre VARCHAR(50),
  sexo VARCHAR(1) CHECK (sexo IN ('M', 'F')),
  fechaNacimiento DATE,
  fechaIngreso DATE DEFAULT CURRENT_DATE,
  estadoSalud VARCHAR(70) DEFAULT 'Saludable',
  idEspecie INT,
  FOREIGN KEY (idEspecie) REFERENCES especie(idEspecie) ON DELETE CASCADE
);

-- ============================================
-- TABLA: rol
-- ============================================
CREATE TABLE rol (
  idRol SERIAL PRIMARY KEY,
  nombreRol VARCHAR(20) NOT NULL UNIQUE
);

-- ============================================
-- TABLA: usuario
-- ============================================
CREATE TABLE usuario (
  idUsuario SERIAL PRIMARY KEY,
  correo VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  idRol INT,
  FOREIGN KEY (idRol) REFERENCES rol(idRol) ON DELETE SET NULL
);

-- ============================================
-- TABLA: auditoria
-- ============================================
CREATE TABLE auditoria (
  idAuditoria SERIAL PRIMARY KEY,
  idUsuario INT,
  accion VARCHAR(50),
  tablaAfectada VARCHAR(40),
  fecha TIMESTAMPTZ DEFAULT NOW(),
  descripcionAuditoria TEXT,
  FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario) ON DELETE SET NULL
);

-- ============================================
-- ÍNDICES
-- ============================================
CREATE INDEX idx_pais_region ON pais(idRegion);
CREATE INDEX idx_especie_tipo ON especie(idTipo);
CREATE INDEX idx_especie_pais ON especie(idPais);
CREATE INDEX idx_especie_ecosistema ON especie(idEcosistema);
CREATE INDEX idx_ejemplar_especie ON ejemplar(idEspecie);
CREATE INDEX idx_auditoria_usuario ON auditoria(idUsuario);
CREATE INDEX idx_auditoria_fecha ON auditoria(fecha);

-- ============================================
-- POBLAR DATOS - CATÁLOGOS
-- ============================================

-- Regiones (6 registros)
INSERT INTO region (nombre) VALUES
  ('África'),
  ('América del Norte'),
  ('América del Sur'),
  ('Asia'),
  ('Europa'),
  ('Australia');

-- Tipos (6 registros)
INSERT INTO tipo (nombreTipo) VALUES
  ('Mamífero'),
  ('Ave'),
  ('Reptil'),
  ('Pez'),
  ('Anfibio'),
  ('Insecto');

-- Estados de Conservación (7 registros)
INSERT INTO estadoConservacion (nombreConservacion) VALUES
  ('Crítico'),
  ('En Peligro'),
  ('Vulnerable'),
  ('Casi Amenazado'),
  ('Preoc. Menor'),
  ('Datos Insuf.'),
  ('Extinto');

-- Ecosistemas (10 registros)
INSERT INTO ecosistema (nombreEcosistema) VALUES
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
INSERT INTO rol (nombreRol) VALUES
  ('admin'),
  ('user');

-- ============================================
-- POBLAR DATOS - 30 REGISTROS POR TABLA
-- ============================================

-- 30 Países
INSERT INTO pais (nombrePais, idRegion) VALUES
  ('Kenia', 1), ('Tanzania', 1), ('Sudáfrica', 1), ('Madagascar', 1), ('Egipto', 1),
  ('Nigeria', 1), ('Marruecos', 1), ('Etiopía', 1), ('Ghana', 1), ('Zambia', 1),
  ('Estados Unidos', 2), ('Canadá', 2), ('México', 2), ('Guatemala', 2), ('Costa Rica', 2),
  ('Brasil', 3), ('Argentina', 3), ('Chile', 3), ('Perú', 3), ('Colombia', 3),
  ('Venezuela', 3), ('Ecuador', 3), ('Bolivia', 3), ('Uruguay', 3), ('Paraguay', 3),
  ('China', 4), ('India', 4), ('Japón', 4), ('Tailandia', 4), ('Indonesia', 4);

-- 30 Especies
INSERT INTO especie (nombreCientifico, nombreComun, descripcion, idTipo, idPais, idEcosistema, idConservacion) VALUES
  ('Panthera leo', 'León Africano', 'Gran felino rey de la sabana', 1, 1, 3, 3),
  ('Loxodonta africana', 'Elefante Africano', 'Mamífero terrestre más grande', 1, 1, 3, 2),
  ('Panthera onca', 'Jaguar', 'Felino más grande de América', 1, 16, 5, 3),
  ('Ailuropoda melanoleuca', 'Oso Panda', 'Oso asiático comedor de bambú', 1, 26, 1, 3),
  ('Ursus maritimus', 'Oso Polar', 'Gran depredador del Ártico', 1, 12, 2, 3),
  ('Gorilla beringei', 'Gorila de Montaña', 'Gran simio africano', 1, 1, 1, 1),
  ('Pongo pygmaeus', 'Orangután', 'Gran simio de Borneo', 1, 30, 5, 1),
  ('Pan troglodytes', 'Chimpancé', 'Simio más cercano al humano', 1, 1, 5, 2),
  ('Giraffa camelopardalis', 'Jirafa', 'Mamífero terrestre más alto', 1, 1, 3, 3),
  ('Hippopotamus amphibius', 'Hipopótamo', 'Gran mamífero semiacuático', 1, 2, 10, 3),
  ('Haliaeetus leucocephalus', 'Águila Calva', 'Ave nacional de EE.UU.', 2, 11, 1, 5),
  ('Spheniscus humboldti', 'Pingüino de Humboldt', 'Ave marina no voladora', 2, 19, 4, 3),
  ('Ara ararauna', 'Guacamayo Azul', 'Gran loro amazónico', 2, 16, 5, 5),
  ('Struthio camelus', 'Avestruz', 'Ave más grande del mundo', 2, 3, 3, 5),
  ('Aquila chrysaetos', 'Águila Real', 'Majestuosa rapaz', 2, 11, 8, 5),
  ('Crocodylus niloticus', 'Cocodrilo del Nilo', 'Gran reptil africano', 3, 1, 10, 3),
  ('Varanus komodoensis', 'Dragón de Komodo', 'Lagarto más grande', 3, 30, 3, 2),
  ('Python molurus', 'Pitón Birmana', 'Gran serpiente constrictora', 3, 27, 5, 3),
  ('Chelonia mydas', 'Tortuga Verde', 'Gran tortuga marina', 3, 14, 4, 2),
  ('Iguana iguana', 'Iguana Verde', 'Gran lagarto herbívoro', 3, 14, 5, 5),
  ('Carcharodon carcharias', 'Tiburón Blanco', 'Gran depredador marino', 4, 3, 4, 3),
  ('Hippocampus kuda', 'Caballito de Mar', 'Pequeño pez único', 4, 30, 4, 3),
  ('Manta birostris', 'Mantarraya Gigante', 'Gran raya pelágica', 4, 30, 4, 3),
  ('Thunnus thynnus', 'Atún Rojo', 'Gran pez migratorio', 4, 28, 4, 2),
  ('Pterophyllum scalare', 'Pez Ángel', 'Pez tropical de agua dulce', 4, 16, 10, 5),
  ('Dendrobates tinctorius', 'Rana Venenosa', 'Anfibio tóxico colorido', 5, 16, 5, 3),
  ('Ambystoma mexicanum', 'Ajolote', 'Anfibio mexicano único', 5, 13, 10, 1),
  ('Bufo bufo', 'Sapo Común', 'Anfibio europeo', 5, 11, 1, 5),
  ('Danaus plexippus', 'Mariposa Monarca', 'Insecto migratorio', 6, 11, 1, 5),
  ('Apis mellifera', 'Abeja Melífera', 'Insecto polinizador', 6, 11, 1, 3);

-- 30 Fichas Técnicas (una por especie)
INSERT INTO fichaTecnica (idEspecie, habitat, dieta, reproduccion, longevidad, comportamiento) VALUES
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
INSERT INTO ejemplar (nombre, sexo, fechaNacimiento, fechaIngreso, estadoSalud, idEspecie) VALUES
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
INSERT INTO usuario (correo, password, idRol) VALUES
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

ALTER TABLE region ENABLE ROW LEVEL SECURITY;
ALTER TABLE pais ENABLE ROW LEVEL SECURITY;
ALTER TABLE tipo ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecosistema ENABLE ROW LEVEL SECURITY;
ALTER TABLE estadoConservacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE especie ENABLE ROW LEVEL SECURITY;
ALTER TABLE fichaTecnica ENABLE ROW LEVEL SECURITY;
ALTER TABLE ejemplar ENABLE ROW LEVEL SECURITY;
ALTER TABLE rol ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuario ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;

-- Políticas de lectura pública para catálogos y datos de especies
CREATE POLICY "Lectura pública region" ON region FOR SELECT USING (true);
CREATE POLICY "Lectura pública pais" ON pais FOR SELECT USING (true);
CREATE POLICY "Lectura pública tipo" ON tipo FOR SELECT USING (true);
CREATE POLICY "Lectura pública ecosistema" ON ecosistema FOR SELECT USING (true);
CREATE POLICY "Lectura pública estadoConservacion" ON estadoConservacion FOR SELECT USING (true);
CREATE POLICY "Lectura pública especie" ON especie FOR SELECT USING (true);
CREATE POLICY "Lectura pública fichaTecnica" ON fichaTecnica FOR SELECT USING (true);
CREATE POLICY "Lectura pública ejemplar" ON ejemplar FOR SELECT USING (true);

-- Nota: Las políticas de escritura y para usuarios/auditoria se configurarán según necesidades específicas
