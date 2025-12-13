/*
  # Add Sample Data

  ## Overview
  Adds sample countries and species data to populate the zoo database with initial content.

  ## New Data

  ### Countries (paises)
  - Multiple countries for each region

  ### Sample Species (especies)
  - African species: Lion, Elephant, Giraffe
  - American species: Jaguar, Bald Eagle
  - Asian species: Tiger, Giant Panda

  ## Important Notes
  This migration adds sample data to demonstrate the system functionality.
*/

-- Add sample countries for each region
DO $$
DECLARE
  region_africa_id uuid;
  region_america_id uuid;
  region_asia_id uuid;
  region_europa_id uuid;
  region_oceania_id uuid;
BEGIN
  -- Get region IDs
  SELECT id INTO region_africa_id FROM regiones WHERE nombre = 'África';
  SELECT id INTO region_america_id FROM regiones WHERE nombre = 'América';
  SELECT id INTO region_asia_id FROM regiones WHERE nombre = 'Asia';
  SELECT id INTO region_europa_id FROM regiones WHERE nombre = 'Europa';
  SELECT id INTO region_oceania_id FROM regiones WHERE nombre = 'Oceanía';

  -- Add African countries
  INSERT INTO paises (nombre, region_id) VALUES
    ('Kenia', region_africa_id),
    ('Tanzania', region_africa_id),
    ('Sudáfrica', region_africa_id),
    ('Madagascar', region_africa_id)
  ON CONFLICT DO NOTHING;

  -- Add American countries
  INSERT INTO paises (nombre, region_id) VALUES
    ('Brasil', region_america_id),
    ('Estados Unidos', region_america_id),
    ('México', region_america_id),
    ('Argentina', region_america_id),
    ('Canadá', region_america_id)
  ON CONFLICT DO NOTHING;

  -- Add Asian countries
  INSERT INTO paises (nombre, region_id) VALUES
    ('China', region_asia_id),
    ('India', region_asia_id),
    ('Indonesia', region_asia_id),
    ('Japón', region_asia_id),
    ('Tailandia', region_asia_id)
  ON CONFLICT DO NOTHING;

  -- Add European countries
  INSERT INTO paises (nombre, region_id) VALUES
    ('España', region_europa_id),
    ('Francia', region_europa_id),
    ('Alemania', region_europa_id),
    ('Italia', region_europa_id)
  ON CONFLICT DO NOTHING;

  -- Add Oceania countries
  INSERT INTO paises (nombre, region_id) VALUES
    ('Australia', region_oceania_id),
    ('Nueva Zelanda', region_oceania_id)
  ON CONFLICT DO NOTHING;
END $$;

-- Add sample species
DO $$
DECLARE
  tipo_mamifero_id uuid;
  tipo_ave_id uuid;
  tipo_reptil_id uuid;
  pais_kenia_id uuid;
  pais_brasil_id uuid;
  pais_china_id uuid;
  pais_usa_id uuid;
  pais_australia_id uuid;
  eco_sabana_id uuid;
  eco_selva_id uuid;
  eco_bosque_id uuid;
  eco_desierto_id uuid;
  estado_vu_id uuid;
  estado_en_id uuid;
  estado_lc_id uuid;
BEGIN
  -- Get IDs
  SELECT id INTO tipo_mamifero_id FROM tipos WHERE nombre = 'Mamífero';
  SELECT id INTO tipo_ave_id FROM tipos WHERE nombre = 'Ave';
  SELECT id INTO tipo_reptil_id FROM tipos WHERE nombre = 'Reptil';
  
  SELECT id INTO pais_kenia_id FROM paises WHERE nombre = 'Kenia';
  SELECT id INTO pais_brasil_id FROM paises WHERE nombre = 'Brasil';
  SELECT id INTO pais_china_id FROM paises WHERE nombre = 'China';
  SELECT id INTO pais_usa_id FROM paises WHERE nombre = 'Estados Unidos';
  SELECT id INTO pais_australia_id FROM paises WHERE nombre = 'Australia';
  
  SELECT id INTO eco_sabana_id FROM ecosistemas WHERE nombre = 'Sabana';
  SELECT id INTO eco_selva_id FROM ecosistemas WHERE nombre = 'Selva tropical';
  SELECT id INTO eco_bosque_id FROM ecosistemas WHERE nombre = 'Bosque templado';
  SELECT id INTO eco_desierto_id FROM ecosistemas WHERE nombre = 'Desierto';
  
  SELECT id INTO estado_vu_id FROM estados_conservacion WHERE codigo = 'VU';
  SELECT id INTO estado_en_id FROM estados_conservacion WHERE codigo = 'EN';
  SELECT id INTO estado_lc_id FROM estados_conservacion WHERE codigo = 'LC';

  -- African Lion
  INSERT INTO especies (
    nombre_comun, nombre_cientifico, tipo_id, pais_id, ecosistema_id,
    habitat_natural, dieta, reproduccion, longevidad, comportamiento,
    estado_conservacion_id, descripcion_general, imagen_url
  ) VALUES (
    'León Africano',
    'Panthera leo',
    tipo_mamifero_id,
    pais_kenia_id,
    eco_sabana_id,
    'Praderas y sabanas del África subsahariana',
    'Carnívoro. Se alimenta principalmente de grandes ungulados como cebras, ñus y búfalos.',
    'Las leonas dan a luz camadas de 1-4 cachorros después de una gestación de 110 días.',
    '10-14 años en estado salvaje, hasta 20 años en cautiverio',
    'Animal social que vive en manadas de hasta 30 individuos. Los machos defienden el territorio mientras las hembras cazan.',
    estado_vu_id,
    'El león es uno de los grandes felinos más emblemáticos de África, conocido como el "rey de la selva" aunque habita principalmente en sabanas.',
    'https://images.pexels.com/photos/36843/lion-panthera-leo-lioness-animal-world.jpg'
  ) ON CONFLICT DO NOTHING;

  -- Jaguar
  INSERT INTO especies (
    nombre_comun, nombre_cientifico, tipo_id, pais_id, ecosistema_id,
    habitat_natural, dieta, reproduccion, longevidad, comportamiento,
    estado_conservacion_id, descripcion_general, imagen_url
  ) VALUES (
    'Jaguar',
    'Panthera onca',
    tipo_mamifero_id,
    pais_brasil_id,
    eco_selva_id,
    'Selvas tropicales y bosques húmedos de América Central y del Sur',
    'Carnívoro. Caza pecaríes, capibaras, ciervos y caimanes.',
    'Las hembras dan a luz 1-4 cachorros después de 90-110 días de gestación.',
    '12-15 años en estado salvaje',
    'Solitario y territorial. Excelente nadador, es el único gran felino que no rehúye el agua.',
    estado_vu_id,
    'El jaguar es el felino más grande de América y el tercero del mundo. Se caracteriza por su poderosa mordida, la más fuerte entre los felinos.',
    'https://images.pexels.com/photos/792381/pexels-photo-792381.jpeg'
  ) ON CONFLICT DO NOTHING;

  -- Giant Panda
  INSERT INTO especies (
    nombre_comun, nombre_cientifico, tipo_id, pais_id, ecosistema_id,
    habitat_natural, dieta, reproduccion, longevidad, comportamiento,
    estado_conservacion_id, descripcion_general, imagen_url
  ) VALUES (
    'Oso Panda Gigante',
    'Ailuropoda melanoleuca',
    tipo_mamifero_id,
    pais_china_id,
    eco_bosque_id,
    'Bosques montañosos de bambú en el centro de China',
    'Herbívoro. Se alimenta principalmente de bambú, consumiendo hasta 38 kg diarios.',
    'Las hembras dan a luz 1-2 crías, pero generalmente solo sobrevive una.',
    '20 años en estado salvaje, hasta 30 en cautiverio',
    'Solitario y principalmente terrestre. Pasa la mayor parte del día alimentándose.',
    estado_vu_id,
    'El panda gigante es un símbolo de conservación mundial. Aunque es carnívoro por naturaleza, el 99% de su dieta consiste en bambú.',
    'https://images.pexels.com/photos/3608263/pexels-photo-3608263.jpeg'
  ) ON CONFLICT DO NOTHING;

  -- Bald Eagle
  INSERT INTO especies (
    nombre_comun, nombre_cientifico, tipo_id, pais_id, ecosistema_id,
    habitat_natural, dieta, reproduccion, longevidad, comportamiento,
    estado_conservacion_id, descripcion_general, imagen_url
  ) VALUES (
    'Águila Calva',
    'Haliaeetus leucocephalus',
    tipo_ave_id,
    pais_usa_id,
    eco_bosque_id,
    'Cerca de grandes cuerpos de agua en América del Norte',
    'Carnívoro. Se alimenta principalmente de peces, también de aves acuáticas y pequeños mamíferos.',
    'Monógamas. Construyen nidos enormes y ponen 1-3 huevos por temporada.',
    '20-30 años en estado salvaje',
    'Territorial. Forma parejas de por vida y regresa al mismo nido cada año.',
    estado_lc_id,
    'El águila calva es el ave nacional de Estados Unidos. Estuvo al borde de la extinción pero se recuperó gracias a los esfuerzos de conservación.',
    'https://images.pexels.com/photos/792910/pexels-photo-792910.jpeg'
  ) ON CONFLICT DO NOTHING;

  -- African Elephant
  INSERT INTO especies (
    nombre_comun, nombre_cientifico, tipo_id, pais_id, ecosistema_id,
    habitat_natural, dieta, reproduccion, longevidad, comportamiento,
    estado_conservacion_id, descripcion_general, imagen_url
  ) VALUES (
    'Elefante Africano',
    'Loxodonta africana',
    tipo_mamifero_id,
    pais_kenia_id,
    eco_sabana_id,
    'Sabanas, bosques y desiertos del África subsahariana',
    'Herbívoro. Consume hasta 150 kg de vegetación diariamente.',
    'Gestación de 22 meses, la más larga entre mamíferos. Dan a luz una sola cría.',
    '60-70 años en estado salvaje',
    'Muy social, vive en manadas matriarcales. Tienen excelente memoria y muestran comportamientos de duelo.',
    estado_en_id,
    'El elefante africano es el animal terrestre más grande del mundo. Es conocido por su inteligencia, memoria y complejas estructuras sociales.',
    'https://images.pexels.com/photos/66898/elephant-cub-tsavo-kenya-66898.jpeg'
  ) ON CONFLICT DO NOTHING;

  -- Kangaroo
  INSERT INTO especies (
    nombre_comun, nombre_cientifico, tipo_id, pais_id, ecosistema_id,
    habitat_natural, dieta, reproduccion, longevidad, comportamiento,
    estado_conservacion_id, descripcion_general, imagen_url
  ) VALUES (
    'Canguro Rojo',
    'Macropus rufus',
    tipo_mamifero_id,
    pais_australia_id,
    eco_desierto_id,
    'Zonas áridas y semiáridas de Australia',
    'Herbívoro. Se alimenta de pastos y plantas del desierto.',
    'Reproducción continua. La cría nace muy prematura y completa desarrollo en la bolsa marsupial.',
    '12-18 años en estado salvaje',
    'Nocturno y crepuscular. Vive en grupos llamados "mobs". Se desplaza saltando.',
    estado_lc_id,
    'El canguro rojo es el marsupial más grande del mundo y un símbolo icónico de Australia. Puede saltar hasta 3 metros de altura y 9 metros de distancia.',
    'https://images.pexels.com/photos/140143/pexels-photo-140143.jpeg'
  ) ON CONFLICT DO NOTHING;

END $$;
