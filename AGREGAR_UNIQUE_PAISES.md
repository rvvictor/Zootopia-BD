# Guía: Agregar Restricción UNIQUE a la Tabla de Países

## 📋 ¿Qué hace esto?

Agrega una restricción `UNIQUE` a la columna `nombre` de la tabla `paises` para:
- ✅ Prevenir países duplicados
- ✅ Permitir usar `ON CONFLICT (nombre) DO NOTHING` en inserts
- ✅ Mejorar la integridad de los datos

## ⚠️ IMPORTANTE: Verificar Duplicados Primero

Antes de agregar la restricción UNIQUE, **debes verificar que no tengas países duplicados**.

### 1. Verificar si hay duplicados

Ejecuta esta consulta en Supabase SQL Editor:

```sql
SELECT nombre, COUNT(*) as cantidad
FROM paises
GROUP BY nombre
HAVING COUNT(*) > 1;
```

**Resultados posibles:**
- ✅ **Sin resultados**: No hay duplicados, puedes continuar
- ❌ **Con resultados**: Tienes duplicados, debes eliminarlos primero

### 2. Eliminar duplicados (si es necesario)

Si encontraste duplicados, elimínalos con este script:

```sql
-- Ver los duplicados con sus IDs
SELECT nombre, COUNT(*) as cantidad, array_agg(id) as ids
FROM paises
GROUP BY nombre
HAVING COUNT(*) > 1;

-- Eliminar duplicados (mantiene el primero, elimina los demás)
DELETE FROM paises
WHERE id IN (
  SELECT id
  FROM (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY nombre ORDER BY id) AS rn
    FROM paises
  ) t
  WHERE t.rn > 1
);
```

### 3. Agregar la restricción UNIQUE

Una vez que no tengas duplicados, ejecuta:

```sql
ALTER TABLE paises 
ADD CONSTRAINT paises_nombre_unique UNIQUE (nombre);
```

O ejecuta el archivo completo:
```
supabase/migrations/20251215000003_add_unique_constraint_paises.sql
```

## ✅ Verificar que funcionó

Después de agregar la restricción, verifica que se creó correctamente:

```sql
SELECT 
  conname AS constraint_name,
  contype AS constraint_type
FROM pg_constraint
WHERE conrelid = 'paises'::regclass
  AND conname = 'paises_nombre_unique';
```

**Resultado esperado:**
```
| constraint_name        | constraint_type |
|------------------------|-----------------|
| paises_nombre_unique   | u               |
```

## 🎯 Beneficios

Después de agregar la restricción UNIQUE, puedes:

### 1. Usar ON CONFLICT en tus inserts

```sql
INSERT INTO paises (nombre, region_id) VALUES
  ('México', 2),
  ('Brasil', 3)
ON CONFLICT (nombre) DO NOTHING;
```

### 2. Actualizar en caso de conflicto

```sql
INSERT INTO paises (nombre, region_id) VALUES
  ('México', 2)
ON CONFLICT (nombre) 
DO UPDATE SET region_id = EXCLUDED.region_id;
```

### 3. Protección automática contra duplicados

Si intentas insertar un país que ya existe, PostgreSQL lo rechazará automáticamente:

```sql
INSERT INTO paises (nombre, region_id) VALUES ('México', 2);
-- ERROR: duplicate key value violates unique constraint "paises_nombre_unique"
```

## 🔄 Actualizar el Script de Países

Después de agregar la restricción UNIQUE, puedes actualizar el script `20251215000002_add_all_countries.sql` para usar `ON CONFLICT`:

```sql
INSERT INTO paises (nombre, region_id) VALUES
  ('Egipto', 1),
  ('Kenia', 1),
  ('Tanzania', 1)
ON CONFLICT (nombre) DO NOTHING;
```

Esto hará que el script sea **seguro de ejecutar múltiples veces** sin crear duplicados.

## 📁 Archivos

- **Script de migración**: [`supabase/migrations/20251215000003_add_unique_constraint_paises.sql`](file:///c:/Users/L13Yoga/Desktop/Zootopia-BD/supabase/migrations/20251215000003_add_unique_constraint_paises.sql)
- **Script de países**: [`supabase/migrations/20251215000002_add_all_countries.sql`](file:///c:/Users/L13Yoga/Desktop/Zootopia-BD/supabase/migrations/20251215000002_add_all_countries.sql)

## 🔧 Troubleshooting

### Error: "could not create unique index"
- **Causa**: Tienes países duplicados en la base de datos
- **Solución**: Ejecuta el script de eliminación de duplicados (paso 2)

### Error: "constraint already exists"
- **Causa**: La restricción UNIQUE ya existe
- **Solución**: No necesitas hacer nada, ya está configurado

---

**Orden recomendado de ejecución:**

1. ✅ `20251215000001_fix_paises_column_length.sql` (aumentar VARCHAR)
2. ✅ `20251215000003_add_unique_constraint_paises.sql` (agregar UNIQUE)
3. ✅ `20251215000002_add_all_countries.sql` (agregar países)
