/*
  # Zoo Database Schema

  ## Overview
  Complete database schema for a zoo management system with regions, species, specimens, and user management.

  ## New Tables

  ### 1. `regiones` (Regions)
  - `id` (uuid, primary key)
  - `nombre` (text) - Region name (África, América, Asia, Europa, Oceanía)
  - `descripcion` (text) - Description of the region
  - `created_at` (timestamptz)

  ### 2. `paises` (Countries)
  - `id` (uuid, primary key)
  - `nombre` (text) - Country name
  - `region_id` (uuid, foreign key to regiones)
  - `created_at` (timestamptz)

  ### 3. `ecosistemas` (Ecosystems)
  - `id` (uuid, primary key)
  - `nombre` (text) - Ecosystem name (bosque templado, tundra, sabana, arrecife, etc.)
  - `descripcion` (text)
  - `created_at` (timestamptz)

  ### 4. `tipos` (Animal Types)
  - `id` (uuid, primary key)
  - `nombre` (text) - Type name (mamífero, ave, reptil, pez, anfibio, insecto)
  - `created_at` (timestamptz)

  ### 5. `estados_conservacion` (Conservation Status)
  - `id` (uuid, primary key)
  - `nombre` (text) - Status name (En peligro crítico, En peligro, Vulnerable, Casi amenazado, Preocupación menor)
  - `codigo` (text) - Status code (CR, EN, VU, NT, LC)
  - `created_at` (timestamptz)

  ### 6. `especies` (Species)
  - `id` (uuid, primary key)
  - `nombre_comun` (text) - Common name
  - `nombre_cientifico` (text) - Scientific name
  - `tipo_id` (uuid, foreign key to tipos)
  - `pais_id` (uuid, foreign key to paises)
  - `ecosistema_id` (uuid, foreign key to ecosistemas)
  - `habitat_natural` (text) - Natural habitat description
  - `dieta` (text) - Diet description
  - `reproduccion` (text) - Reproduction information
  - `longevidad` (text) - Longevity information
  - `comportamiento` (text) - Behavior description
  - `estado_conservacion_id` (uuid, foreign key to estados_conservacion)
  - `descripcion_general` (text) - General description
  - `imagen_url` (text) - Image URL
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 7. `ejemplares` (Specimens)
  - `id` (uuid, primary key)
  - `nombre` (text) - Specimen name
  - `especie_id` (uuid, foreign key to especies)
  - `sexo` (text) - Sex (Macho, Hembra)
  - `fecha_nacimiento` (date) - Birth date
  - `fecha_ingreso` (date) - Entry date
  - `habitat_actual` (text) - Current habitat location
  - `estado_salud` (text) - Health status
  - `observaciones` (text) - Observations
  - `imagen_url` (text) - Image URL
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 8. `profiles` (User Profiles)
  - `id` (uuid, primary key, foreign key to auth.users)
  - `email` (text)
  - `role` (text) - User role (admin, user)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ## Security
  - Enable RLS on all tables
  - Public read access for zoo data (regiones, paises, ecosistemas, tipos, especies, ejemplares, estados_conservacion)
  - Authenticated users can read all data
  - Only admins can insert/update/delete zoo data
  - Users can read their own profile
  - Only users can update their own profile

  ## Important Notes
  1. All tables use UUID for primary keys
  2. Proper foreign key constraints ensure data integrity
  3. Timestamps track creation and updates
  4. RLS policies ensure proper access control based on user roles
*/

-- Create regiones table
CREATE TABLE IF NOT EXISTS regiones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL UNIQUE,
  descripcion text,
  created_at timestamptz DEFAULT now()
);

-- Create paises table
CREATE TABLE IF NOT EXISTS paises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  region_id uuid REFERENCES regiones(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now()
);

-- Create ecosistemas table
CREATE TABLE IF NOT EXISTS ecosistemas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL UNIQUE,
  descripcion text,
  created_at timestamptz DEFAULT now()
);

-- Create tipos table
CREATE TABLE IF NOT EXISTS tipos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

-- Create estados_conservacion table
CREATE TABLE IF NOT EXISTS estados_conservacion (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL UNIQUE,
  codigo text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

-- Create especies table
CREATE TABLE IF NOT EXISTS especies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_comun text NOT NULL,
  nombre_cientifico text NOT NULL,
  tipo_id uuid REFERENCES tipos(id) ON DELETE RESTRICT,
  pais_id uuid REFERENCES paises(id) ON DELETE RESTRICT,
  ecosistema_id uuid REFERENCES ecosistemas(id) ON DELETE RESTRICT,
  habitat_natural text,
  dieta text,
  reproduccion text,
  longevidad text,
  comportamiento text,
  estado_conservacion_id uuid REFERENCES estados_conservacion(id) ON DELETE RESTRICT,
  descripcion_general text,
  imagen_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create ejemplares table
CREATE TABLE IF NOT EXISTS ejemplares (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  especie_id uuid REFERENCES especies(id) ON DELETE CASCADE,
  sexo text NOT NULL CHECK (sexo IN ('Macho', 'Hembra')),
  fecha_nacimiento date,
  fecha_ingreso date NOT NULL DEFAULT CURRENT_DATE,
  habitat_actual text,
  estado_salud text DEFAULT 'Saludable',
  observaciones text,
  imagen_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  role text NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_paises_region ON paises(region_id);
CREATE INDEX IF NOT EXISTS idx_especies_tipo ON especies(tipo_id);
CREATE INDEX IF NOT EXISTS idx_especies_pais ON especies(pais_id);
CREATE INDEX IF NOT EXISTS idx_especies_ecosistema ON especies(ecosistema_id);
CREATE INDEX IF NOT EXISTS idx_ejemplares_especie ON ejemplares(especie_id);

-- Enable Row Level Security
ALTER TABLE regiones ENABLE ROW LEVEL SECURITY;
ALTER TABLE paises ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecosistemas ENABLE ROW LEVEL SECURITY;
ALTER TABLE tipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE estados_conservacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE especies ENABLE ROW LEVEL SECURITY;
ALTER TABLE ejemplares ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for regiones (public read, admin write)
CREATE POLICY "Anyone can view regions"
  ON regiones FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert regions"
  ON regiones FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update regions"
  ON regiones FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete regions"
  ON regiones FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for paises (public read, admin write)
CREATE POLICY "Anyone can view countries"
  ON paises FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert countries"
  ON paises FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update countries"
  ON paises FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete countries"
  ON paises FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for ecosistemas (public read, admin write)
CREATE POLICY "Anyone can view ecosystems"
  ON ecosistemas FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert ecosystems"
  ON ecosistemas FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update ecosystems"
  ON ecosistemas FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete ecosystems"
  ON ecosistemas FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for tipos (public read, admin write)
CREATE POLICY "Anyone can view types"
  ON tipos FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert types"
  ON tipos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update types"
  ON tipos FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete types"
  ON tipos FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for estados_conservacion (public read, admin write)
CREATE POLICY "Anyone can view conservation status"
  ON estados_conservacion FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert conservation status"
  ON estados_conservacion FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update conservation status"
  ON estados_conservacion FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete conservation status"
  ON estados_conservacion FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for especies (public read, admin write)
CREATE POLICY "Anyone can view species"
  ON especies FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert species"
  ON especies FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update species"
  ON especies FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete species"
  ON especies FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for ejemplares (public read, admin write)
CREATE POLICY "Anyone can view specimens"
  ON ejemplares FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert specimens"
  ON ejemplares FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update specimens"
  ON ejemplares FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete specimens"
  ON ejemplares FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for profiles
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role)
  VALUES (new.id, new.email, 'user');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Insert initial data for regiones
INSERT INTO regiones (nombre, descripcion) VALUES
  ('África', 'Continente africano con diversa fauna y ecosistemas'),
  ('América', 'Continente americano desde Alaska hasta Argentina'),
  ('Asia', 'El continente más grande con gran biodiversidad'),
  ('Europa', 'Continente europeo con fauna adaptada a climas templados'),
  ('Oceanía', 'Región que incluye Australia, Nueva Zelanda y las islas del Pacífico')
ON CONFLICT (nombre) DO NOTHING;

-- Insert initial data for tipos
INSERT INTO tipos (nombre) VALUES
  ('Mamífero'),
  ('Ave'),
  ('Reptil'),
  ('Pez'),
  ('Anfibio'),
  ('Insecto')
ON CONFLICT (nombre) DO NOTHING;

-- Insert initial data for estados_conservacion
INSERT INTO estados_conservacion (nombre, codigo) VALUES
  ('En peligro crítico', 'CR'),
  ('En peligro', 'EN'),
  ('Vulnerable', 'VU'),
  ('Casi amenazado', 'NT'),
  ('Preocupación menor', 'LC'),
  ('Datos insuficientes', 'DD'),
  ('Extinto en estado silvestre', 'EW')
ON CONFLICT (nombre) DO NOTHING;

-- Insert initial data for ecosistemas
INSERT INTO ecosistemas (nombre, descripcion) VALUES
  ('Bosque templado', 'Bosques de zonas templadas con estaciones marcadas'),
  ('Tundra', 'Regiones frías con vegetación escasa'),
  ('Sabana', 'Praderas tropicales con árboles dispersos'),
  ('Arrecife de coral', 'Ecosistemas marinos con gran biodiversidad'),
  ('Selva tropical', 'Bosques húmedos con gran diversidad de especies'),
  ('Desierto', 'Regiones áridas con poca precipitación'),
  ('Pradera', 'Extensas llanuras con vegetación herbácea'),
  ('Montaña', 'Regiones de alta altitud con condiciones extremas'),
  ('Manglar', 'Bosques costeros en zonas de transición tierra-mar'),
  ('Humedal', 'Áreas inundadas permanente o temporalmente')
ON CONFLICT (nombre) DO NOTHING;