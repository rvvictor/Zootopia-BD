/*
  # Update Regions for Interactive World Map

  ## Overview
  Updates the regions to match the world map visualization:
  - Splits América into América del Norte and América del Sur
  - Renames Oceanía to Australia
  - Updates related countries and data

  ## Changes
  1. Add new regions: América del Norte, América del Sur
  2. Update region name: Oceanía -> Australia
  3. Update country associations

  ## Important Notes
  This migration preserves existing data while updating the regional structure
*/

-- First, let's get the current region IDs
DO $$
DECLARE
  old_america_id uuid;
  old_oceania_id uuid;
  new_north_america_id uuid;
  new_south_america_id uuid;
  new_australia_id uuid;
BEGIN
  -- Get old region IDs
  SELECT id INTO old_america_id FROM regiones WHERE nombre = 'América';
  SELECT id INTO old_oceania_id FROM regiones WHERE nombre = 'Oceanía';

  -- Update Oceanía to Australia
  UPDATE regiones 
  SET nombre = 'Australia', 
      descripcion = 'Continente australiano con fauna única y endémica'
  WHERE nombre = 'Oceanía';

  -- Create América del Norte if it doesn't exist
  INSERT INTO regiones (nombre, descripcion)
  VALUES (
    'América del Norte',
    'Región que incluye Canadá, Estados Unidos, México y América Central'
  )
  ON CONFLICT (nombre) DO UPDATE 
  SET descripcion = EXCLUDED.descripcion
  RETURNING id INTO new_north_america_id;

  -- Create América del Sur if it doesn't exist
  INSERT INTO regiones (nombre, descripcion)
  VALUES (
    'América del Sur',
    'Subcontinente sudamericano con gran biodiversidad tropical'
  )
  ON CONFLICT (nombre) DO UPDATE 
  SET descripcion = EXCLUDED.descripcion
  RETURNING id INTO new_south_america_id;

  -- Get the new IDs if they already existed
  IF new_north_america_id IS NULL THEN
    SELECT id INTO new_north_america_id FROM regiones WHERE nombre = 'América del Norte';
  END IF;

  IF new_south_america_id IS NULL THEN
    SELECT id INTO new_south_america_id FROM regiones WHERE nombre = 'América del Sur';
  END IF;

  -- Update countries: North American countries
  UPDATE paises 
  SET region_id = new_north_america_id
  WHERE nombre IN ('Estados Unidos', 'Canadá', 'México')
  AND region_id = old_america_id;

  -- Update countries: South American countries
  UPDATE paises 
  SET region_id = new_south_america_id
  WHERE nombre IN ('Brasil', 'Argentina', 'Chile', 'Perú', 'Colombia', 'Venezuela')
  AND region_id = old_america_id;

  -- If there are any remaining countries under old América, move them to North America
  UPDATE paises 
  SET region_id = new_north_america_id
  WHERE region_id = old_america_id;

  -- Delete old América region if it exists and has no countries
  DELETE FROM regiones WHERE nombre = 'América' AND id = old_america_id;

END $$;
