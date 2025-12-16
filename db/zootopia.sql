DROP DATABASE IF EXISTS zootopia;
CREATE DATABASE zootopia;
USE zootopia;

-- =======================================================
-- 1. CREACIÓN DE TABLAS
-- =======================================================

CREATE TABLE regiones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE paises (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL,
  region_id INT,
  FOREIGN KEY (region_id) REFERENCES regiones(id) ON DELETE CASCADE
);

CREATE TABLE tipos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE ecosistemas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE estados_conservacion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(15) NOT NULL UNIQUE,
  codigo VARCHAR(5) NOT NULL UNIQUE
);

CREATE TABLE especies (
  id INT AUTO_INCREMENT PRIMARY KEY,
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

CREATE TABLE fichas_tecnicas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  especie_id INT UNIQUE,
  habitat VARCHAR(70),
  dieta VARCHAR(70),
  reproduccion VARCHAR(70),
  longevidad VARCHAR(70),
  comportamiento VARCHAR(100),
  FOREIGN KEY (especie_id) REFERENCES especies(id) ON DELETE CASCADE
);

CREATE TABLE ejemplares (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50),
  sexo VARCHAR(1) CHECK (sexo IN ('M', 'F')),
  fecha_nacimiento DATE,
  fecha_ingreso DATE DEFAULT (CURRENT_DATE),
  habitat_actual VARCHAR(70),
  estado_salud VARCHAR(70) DEFAULT 'Saludable',
  observaciones TEXT,
  especie_id INT,
  imagen_url TEXT,
  FOREIGN KEY (especie_id) REFERENCES especies(id) ON DELETE CASCADE
);

CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  correo VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  rol_id INT,
  FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE SET NULL
);

CREATE TABLE auditorias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  accion VARCHAR(50),
  tabla_afectada VARCHAR(40),
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  descripcion TEXT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- =======================================================
-- 2. ÍNDICES
-- =======================================================

CREATE INDEX idx_paises_region ON paises(region_id);
CREATE INDEX idx_especies_tipo ON especies(tipo_id);
CREATE INDEX idx_especies_pais ON especies(pais_id);
CREATE INDEX idx_especies_ecosistema ON especies(ecosistema_id);
CREATE INDEX idx_ejemplares_especie ON ejemplares(especie_id);
CREATE INDEX idx_auditorias_usuario ON auditorias(usuario_id);
CREATE INDEX idx_auditorias_fecha ON auditorias(fecha);

-- =======================================================
-- 3. POBLAR DATOS (INSERTS)
-- =======================================================

INSERT INTO regiones (nombre) VALUES
  ('África'), ('América del Norte'), ('América del Sur'), ('Asia'), ('Europa'), ('Australia');

INSERT INTO tipos (nombre) VALUES
  ('Mamífero'), ('Ave'), ('Reptil'), ('Pez'), ('Anfibio'), ('Insecto');

INSERT INTO estados_conservacion (nombre, codigo) VALUES
  ('Crítico', 'CR'), ('En Peligro', 'EN'), ('Vulnerable', 'VU'), ('Casi Amenazado', 'NT'),
  ('Preoc. Menor', 'LC'), ('Datos Insuf.', 'DD'), ('Extinto', 'EX');

INSERT INTO ecosistemas (nombre) VALUES
  ('Bosque Templado'), ('Tundra'), ('Sabana'), ('Arrecife Coral'), ('Selva Tropical'),
  ('Desierto'), ('Pradera'), ('Montaña'), ('Manglar'), ('Humedal');

INSERT INTO roles (nombre) VALUES ('admin'), ('user');

INSERT INTO paises (nombre, region_id) VALUES
  ('Kenia', 1), ('Tanzania', 1), ('Sudáfrica', 1), ('Madagascar', 1), ('Egipto', 1),
  ('Nigeria', 1), ('Marruecos', 1), ('Etiopía', 1), ('Ghana', 1), ('Zambia', 1),
  ('Estados Unidos', 2), ('Canadá', 2), ('México', 2), ('Guatemala', 2), ('Costa Rica', 2),
  ('Brasil', 3), ('Argentina', 3), ('Chile', 3), ('Perú', 3), ('Colombia', 3),
  ('Venezuela', 3), ('Ecuador', 3), ('Bolivia', 3), ('Uruguay', 3), ('Paraguay', 3),
  ('China', 4), ('India', 4), ('Japón', 4), ('Tailandia', 4), ('Indonesia', 4);

-- Insertar Especies (Actualizado con las nuevas columnas)
INSERT INTO especies (nombre_cientifico, nombre_comun, descripcion, tipo_id, pais_id, ecosistema_id, estado_conservacion_id, habitat_natural, dieta, reproduccion, longevidad, comportamiento) VALUES
  ('Panthera leo', 'León Africano', 'Gran felino rey de la sabana', 1, 1, 3, 3, 'Sabanas africanas', 'Carnívoro', 'Camadas 1-4 cachorros', '10-14 años', 'Social, vive en manadas'),
  ('Loxodonta africana', 'Elefante Africano', 'Mamífero terrestre más grande', 1, 1, 3, 2, 'Sabanas y bosques', 'Herbívoro', 'Gestación 22 meses', '60-70 años', 'Matriarcal'),
  ('Panthera onca', 'Jaguar', 'Felino más grande de América', 1, 16, 5, 3, 'Selvas tropicales', 'Carnívoro', 'Camadas 1-4 cachorros', '12-15 años', 'Solitario'),
  ('Ailuropoda melanoleuca', 'Oso Panda', 'Oso asiático comedor de bambú', 1, 26, 1, 3, 'Bosques de bambú', 'Herbívoro', 'Cría única', '20 años', 'Solitario'),
  ('Ursus maritimus', 'Oso Polar', 'Gran depredador del Ártico', 1, 12, 2, 3, 'Hielo ártico', 'Carnívoro', 'Camadas 1-3', '25-30 años', 'Solitario'),
  ('Gorilla beringei', 'Gorila de Montaña', 'Gran simio africano', 1, 1, 1, 1, 'Montañas boscosas', 'Herbívoro', 'Cría única', '35-40 años', 'Social'),
  ('Pongo pygmaeus', 'Orangután', 'Gran simio de Borneo', 1, 30, 5, 1, 'Selvas de Borneo', 'Frugívoro', 'Cría única', '35-45 años', 'Arbóreo'),
  ('Pan troglodytes', 'Chimpancé', 'Simio más cercano al humano', 1, 1, 5, 2, 'Bosques tropicales', 'Omnívoro', 'Camadas 1-2', '40-50 años', 'Social'),
  ('Giraffa camelopardalis', 'Jirafa', 'Mamífero terrestre más alto', 1, 1, 3, 3, 'Sabanas africanas', 'Herbívoro', 'Cría única', '25 años', 'Gregario'),
  ('Hippopotamus amphibius', 'Hipopótamo', 'Gran mamífero semiacuático', 1, 2, 10, 3, 'Ríos y lagos', 'Herbívoro', 'Cría única', '40-50 años', 'Territorial'),
  ('Haliaeetus leucocephalus', 'Águila Calva', 'Ave nacional de EE.UU.', 2, 11, 1, 5, 'Cerca de agua', 'Carnívoro', '2-3 huevos', '20-30 años', 'Monógamo'),
  ('Spheniscus humboldti', 'Pingüino de Humboldt', 'Ave marina no voladora', 2, 19, 4, 3, 'Costas rocosas', 'Piscívoro', '2 huevos', '15-20 años', 'Colonial'),
  ('Ara ararauna', 'Guacamayo Azul', 'Gran loro amazónico', 2, 16, 5, 5, 'Selva amazónica', 'Frugívoro', '2-3 huevos', '50 años', 'Social'),
  ('Struthio camelus', 'Avestruz', 'Ave más grande del mundo', 2, 3, 3, 5, 'Sabanas', 'Omnívoro', 'Huevos grandes', '40 años', 'Gregario'),
  ('Aquila chrysaetos', 'Águila Real', 'Majestuosa rapaz', 2, 11, 8, 5, 'Montañas', 'Carnívoro', '2 huevos', '30 años', 'Territorial'),
  ('Crocodylus niloticus', 'Cocodrilo del Nilo', 'Gran reptil africano', 3, 1, 10, 3, 'Ríos', 'Carnívoro', '40-60 huevos', '70-100 años', 'Acuático'),
  ('Varanus komodoensis', 'Dragón de Komodo', 'Lagarto más grande', 3, 30, 3, 2, 'Islas', 'Carnívoro', '20 huevos', '30 años', 'Solitario'),
  ('Python molurus', 'Pitón Birmana', 'Gran serpiente constrictora', 3, 27, 5, 3, 'Selvas', 'Carnívoro', '30-100 huevos', '20 años', 'Nocturno'),
  ('Chelonia mydas', 'Tortuga Verde', 'Gran tortuga marina', 3, 14, 4, 2, 'Océanos', 'Herbívoro', '100+ huevos', '80 años', 'Migratoria'),
  ('Iguana iguana', 'Iguana Verde', 'Gran lagarto herbívoro', 3, 14, 5, 5, 'Selvas', 'Herbívoro', '20-70 huevos', '20 años', 'Arbóreo'),
  ('Carcharodon carcharias', 'Tiburón Blanco', 'Gran depredador marino', 4, 3, 4, 3, 'Océanos', 'Carnívoro', 'Crías vivas', '70 años', 'Solitario'),
  ('Hippocampus kuda', 'Caballito de Mar', 'Pequeño pez único', 4, 30, 4, 3, 'Arrecifes', 'Plancton', 'Macho gesta', '1-5 años', 'Monógamo'),
  ('Manta birostris', 'Mantarraya Gigante', 'Gran raya pelágica', 4, 30, 4, 3, 'Océanos', 'Plancton', '1 cría', '20 años', 'Pacífico'),
  ('Thunnus thynnus', 'Atún Rojo', 'Gran pez migratorio', 4, 28, 4, 2, 'Océanos', 'Carnívoro', 'Huevos', '15-30 años', 'Veloz'),
  ('Pterophyllum scalare', 'Pez Ángel', 'Pez tropical', 4, 16, 10, 5, 'Ríos', 'Omnívoro', 'Huevos', '8 años', 'Cardumen'),
  ('Dendrobates tinctorius', 'Rana Venenosa', 'Anfibio tóxico', 5, 16, 5, 3, 'Selvas', 'Insectívoro', 'Huevos', '5 años', 'Tóxico'),
  ('Ambystoma mexicanum', 'Ajolote', 'Anfibio mexicano único', 5, 13, 10, 1, 'Lagos', 'Carnívoro', 'Huevos', '15 años', 'Acuático'),
  ('Bufo bufo', 'Sapo Común', 'Anfibio europeo', 5, 11, 1, 5, 'Bosques', 'Insectívoro', 'Huevos', '10 años', 'Nocturno'),
  ('Danaus plexippus', 'Mariposa Monarca', 'Insecto migratorio', 6, 11, 1, 5, 'Bosques', 'Néctar', 'Huevos', 'Breve', 'Migratoria'),
  ('Apis mellifera', 'Abeja Melífera', 'Insecto polinizador', 6, 11, 1, 3, 'Colmenas', 'Polen', 'Huevos', 'Breve', 'Eusocial');

-- Insertar Fichas Técnicas (Mantenemos los datos aunque ahora sean redundantes con especies)
INSERT INTO fichas_tecnicas (especie_id, habitat, dieta, reproduccion, longevidad, comportamiento)
SELECT id, habitat_natural, dieta, reproduccion, longevidad, comportamiento FROM especies;

INSERT INTO ejemplares (nombre, sexo, fecha_nacimiento, fecha_ingreso, estado_salud, especie_id) VALUES
  ('Simba', 'M', '2018-05-12', '2018-07-20', 'Saludable', 1),
  ('Nala', 'F', '2018-05-15', '2018-07-20', 'Saludable', 1),
  ('Dumbo', 'M', '2015-03-10', '2016-01-15', 'Saludable', 2),
  ('Jaggy', 'M', '2019-08-22', '2019-10-01', 'Saludable', 3),
  ('Bao Bao', 'F', '2020-01-05', '2020-03-12', 'Saludable', 4),
  ('Frost', 'M', '2017-11-20', '2018-02-14', 'Saludable', 5), -- Quitamos tratamiento para evitar error de check si hubiera
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
  ('Danaus', 'F', '2021-05-15', '2021-06-01', 'Saludable', 29);

INSERT INTO usuarios (correo, password, rol_id) VALUES
  ('admin@zootopia.com', 'hash123', 1),
  ('vet@zootopia.com', 'hash123', 2);

-- =======================================================
-- 4. PROCEDIMIENTOS ALMACENADOS
-- =======================================================

DROP PROCEDURE IF EXISTS obtener_especies_por_estado_conservacion;

DELIMITER //
CREATE PROCEDURE obtener_especies_por_estado_conservacion(
  IN p_estado VARCHAR(255)
)
BEGIN
  SELECT 
    e.id,
    e.nombre_cientifico,
    e.nombre_comun,
    t.nombre as tipo,
    p.nombre as pais,
    r.nombre as region_nombre,
    ec.nombre as ecosistema,
    est.nombre as estado_conservacion
  FROM especies e
  INNER JOIN tipos t ON e.tipo_id = t.id
  INNER JOIN paises p ON e.pais_id = p.id
  INNER JOIN regiones r ON p.region_id = r.id
  INNER JOIN ecosistemas ec ON e.ecosistema_id = ec.id
  INNER JOIN estados_conservacion est ON e.estado_conservacion_id = est.id
  WHERE est.nombre = p_estado
  ORDER BY e.nombre_comun;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS calcular_estadisticas_zoo;

DELIMITER //
CREATE PROCEDURE calcular_estadisticas_zoo()
BEGIN
  SELECT 
    (SELECT COUNT(*) FROM especies) AS total_especies,
    (SELECT COUNT(*) FROM ejemplares) AS total_ejemplares,
    (SELECT COUNT(*) FROM paises) AS total_paises,
    (SELECT COUNT(*) FROM regiones) AS total_regiones,
    (SELECT COUNT(*) FROM ejemplares WHERE estado_salud = 'Saludable') AS ejemplares_saludables,
    (SELECT COUNT(*) FROM ejemplares WHERE estado_salud LIKE '%tratamiento%') AS ejemplares_tratamiento;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS registrar_nuevo_ejemplar;

DELIMITER //
CREATE PROCEDURE registrar_nuevo_ejemplar(
  IN p_nombre VARCHAR(100),
  IN p_sexo VARCHAR(50),
  IN p_fecha_nacimiento DATE,
  IN p_fecha_ingreso DATE,
  IN p_estado_salud VARCHAR(100),
  IN p_especie_id INT,
  IN p_usuario_id INT
)
BEGIN
  DECLARE v_id_ejemplar INT;
  DECLARE v_nombre_especie VARCHAR(255);

  INSERT INTO ejemplares (nombre, sexo, fecha_nacimiento, fecha_ingreso, estado_salud, especie_id)
  VALUES (p_nombre, p_sexo, p_fecha_nacimiento, p_fecha_ingreso, p_estado_salud, p_especie_id);
  
  SET v_id_ejemplar = LAST_INSERT_ID();
  
  SELECT nombre_comun INTO v_nombre_especie
  FROM especies WHERE id = p_especie_id LIMIT 1;
  
  INSERT INTO auditorias (usuario_id, accion, tabla_afectada, descripcion)
  VALUES (
    p_usuario_id,
    'INSERT_PROC',
    'ejemplares',
    CONCAT('Nuevo ejemplar registrado vía SP: ', p_nombre, ' de especie ', v_nombre_especie)
  );
  
  SELECT v_id_ejemplar AS id;
END //
DELIMITER ;

-- =======================================================
-- 5. VISTAS
-- =======================================================

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
  e.habitat_natural,
  e.dieta,
  e.reproduccion,
  e.longevidad,
  e.comportamiento,
  (SELECT COUNT(*) FROM ejemplares WHERE especie_id = e.id) AS total_ejemplares
FROM especies e
LEFT JOIN tipos t ON e.tipo_id = t.id
LEFT JOIN paises p ON e.pais_id = p.id
LEFT JOIN regiones r ON p.region_id = r.id
LEFT JOIN ecosistemas ec ON e.ecosistema_id = ec.id
LEFT JOIN estados_conservacion est ON e.estado_conservacion_id = est.id
ORDER BY e.nombre_comun;

CREATE OR REPLACE VIEW vista_ejemplares_detalle AS
SELECT 
  ej.id,
  ej.nombre AS nombre_ejemplar,
  ej.sexo,
  ej.fecha_nacimiento,
  ej.fecha_ingreso,
  TIMESTAMPDIFF(YEAR, ej.fecha_nacimiento, CURDATE()) AS edad_anios,
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

-- =======================================================
-- 6. TRIGGERS
-- =======================================================

DROP TRIGGER IF EXISTS trigger_validar_fechas_ejemplar_insert;
DROP TRIGGER IF EXISTS trigger_validar_fechas_ejemplar_update;

DELIMITER //

CREATE TRIGGER trigger_validar_fechas_ejemplar_insert
BEFORE INSERT ON ejemplares
FOR EACH ROW
BEGIN
  IF NEW.fecha_nacimiento > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de nacimiento no puede ser futura';
  END IF;
  
  IF NEW.fecha_ingreso < NEW.fecha_nacimiento THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de ingreso no puede ser anterior a la fecha de nacimiento';
  END IF;
END //

CREATE TRIGGER trigger_validar_fechas_ejemplar_update
BEFORE UPDATE ON ejemplares
FOR EACH ROW
BEGIN
  IF NEW.fecha_nacimiento > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de nacimiento no puede ser futura';
  END IF;
  
  IF NEW.fecha_ingreso < NEW.fecha_nacimiento THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de ingreso no puede ser anterior a la fecha de nacimiento';
  END IF;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS trigger_auditoria_ejemplar_insert;
DROP TRIGGER IF EXISTS trigger_auditoria_ejemplar_update;
DROP TRIGGER IF EXISTS trigger_auditoria_ejemplar_delete;

DELIMITER //

CREATE TRIGGER trigger_auditoria_ejemplar_insert
AFTER INSERT ON ejemplares
FOR EACH ROW
BEGIN
  DECLARE v_nombre_especie VARCHAR(255);
  SELECT nombre_comun INTO v_nombre_especie FROM especies WHERE id = NEW.especie_id;
  INSERT INTO auditorias (usuario_id, accion, tabla_afectada, descripcion)
  VALUES (NULL, 'INSERT', 'ejemplares', CONCAT('Nuevo ejemplar: ', NEW.nombre, ' (Especie: ', IFNULL(v_nombre_especie, 'Desconocida'), ')'));
END //

CREATE TRIGGER trigger_auditoria_ejemplar_update
AFTER UPDATE ON ejemplares
FOR EACH ROW
BEGIN
  INSERT INTO auditorias (usuario_id, accion, tabla_afectada, descripcion)
  VALUES (NULL, 'UPDATE', 'ejemplares', CONCAT('Actualización ejemplar: ', NEW.nombre, ' (ID: ', NEW.id, ')'));
END //

CREATE TRIGGER trigger_auditoria_ejemplar_delete
AFTER DELETE ON ejemplares
FOR EACH ROW
BEGIN
  INSERT INTO auditorias (usuario_id, accion, tabla_afectada, descripcion)
  VALUES (NULL, 'DELETE', 'ejemplares', CONCAT('Eliminado ejemplar: ', OLD.nombre, ' (ID: ', OLD.id, ')'));
END //

DELIMITER ;