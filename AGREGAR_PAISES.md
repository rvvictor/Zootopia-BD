# Guía: Agregar Todos los Países a la Base de Datos

## 📋 Descripción

Este script SQL agrega **187 países del mundo** a tu base de datos Zootopia, organizados por las 6 regiones existentes. Los nombres están en **español** y coinciden exactamente con el diccionario `countryNameMap` de `WorldMap.tsx`.

## 🌍 Distribución de Países

| Región              | Cantidad | Ejemplos                                    |
|---------------------|----------|---------------------------------------------|
| **África**          | 54       | Egipto, Kenia, Sudáfrica, Madagascar        |
| **América del Norte**| 14      | Estados Unidos, México, Canadá, Costa Rica  |
| **América del Sur** | 13       | Brasil, Argentina, Chile, Perú              |
| **Asia**            | 48       | China, Japón, India, Tailandia              |
| **Europa**          | 44       | España, Francia, Alemania, Reino Unido      |
| **Australia/Oceanía**| 14      | Australia, Nueva Zelanda, Fiyi              |
| **TOTAL**           | **187**  |                                             |

## 🚀 Cómo Ejecutar el Script

> **⚠️ IMPORTANTE**: Antes de ejecutar el script de países, debes aumentar el tamaño de la columna `nombre` en la tabla `paises`.

### Paso 1: Aumentar Tamaño de Columna (REQUERIDO)

Primero ejecuta este script para evitar el error `value too long for type character varying(30)`:

```sql
-- Ejecutar primero en Supabase SQL Editor
ALTER TABLE paises 
ALTER COLUMN nombre TYPE VARCHAR(50);
```

O ejecuta el archivo completo:
```
supabase/migrations/20251215000001_fix_paises_column_length.sql
```

### Paso 2: Agregar Países

Después de aumentar el tamaño de la columna, ejecuta el script de países:

#### Opción 1: Desde Supabase Dashboard (Recomendado)

1. Ve a tu proyecto en [Supabase Dashboard](https://supabase.com/dashboard)
2. Navega a **SQL Editor** en el menú lateral
3. Haz clic en **New Query**
4. Copia y pega el contenido completo de:
   ```
   supabase/migrations/20251215000002_add_all_countries.sql
   ```
5. Haz clic en **Run** (o presiona `Ctrl + Enter`)
6. Verifica los resultados en la sección de resultados

### Opción 2: Desde la Terminal (Supabase CLI)

```bash
# Asegúrate de estar en el directorio del proyecto
cd c:\Users\L13Yoga\Desktop\Zootopia-BD

# Ejecuta la migración
npx supabase db execute -f supabase/migrations/20251215000002_add_all_countries.sql
```

## ✅ Verificación

Después de ejecutar el script, verás dos tablas de resultados:

### 1. Países por Región
```
| region              | total_paises |
|---------------------|--------------|
| África              | 54           |
| América del Norte   | 14           |
| América del Sur     | 13           |
| Asia                | 48           |
| Australia           | 14           |
| Europa              | 44           |
```

### 2. Total de Países
```
| total_paises_mundial |
|----------------------|
| 187                  |
```

## 🔄 Importante: Evitar Duplicados

> **⚠️ ADVERTENCIA**: Este script **NO** maneja duplicados automáticamente. Si ejecutas el script múltiples veces, se crearán países duplicados.

### Recomendaciones

1. **Ejecuta el script solo UNA VEZ** después de crear la base de datos
2. **Si ya tienes países**, puedes:
   - Eliminar todos los países existentes primero:
     ```sql
     DELETE FROM ejemplares;
     DELETE FROM especies;
     DELETE FROM paises;
     ```
   - O agregar manualmente solo los países que faltan

3. **Para verificar si ya tienes países**:
   ```sql
   SELECT COUNT(*) FROM paises;
   ```

### ¿Por qué no usa ON CONFLICT?

La tabla `paises` no tiene una restricción `UNIQUE` en la columna `nombre`, por lo que no podemos usar `ON CONFLICT (nombre) DO NOTHING`. Si necesitas esta funcionalidad, primero agrega la restricción:

```sql
-- Agregar restricción UNIQUE (opcional)
ALTER TABLE paises ADD CONSTRAINT paises_nombre_unique UNIQUE (nombre);
```

## 📝 Notas Importantes

### Países que ya existen en la migración original

La migración original (`20251215000000_create_frontend_compatible_schema.sql`) ya incluye 30 países:

```sql
-- Estos 30 países YA EXISTEN:
Kenia, Tanzania, Sudáfrica, Madagascar, Egipto,
Nigeria, Marruecos, Etiopía, Ghana, Zambia,
Estados Unidos, Canadá, México, Guatemala, Costa Rica,
Brasil, Argentina, Chile, Perú, Colombia,
Venezuela, Ecuador, Bolivia, Uruguay, Paraguay,
China, India, Japón, Tailandia, Indonesia
```

El nuevo script **NO los duplicará** gracias a `ON CONFLICT DO NOTHING`.

### Compatibilidad con el Mapa

Todos los nombres de países en este script coinciden **exactamente** con las traducciones en `WorldMap.tsx`:

```typescript
// Ejemplo de coincidencia:
'Egypt': 'Egipto'        ✅ En el script: 'Egipto'
'South Africa': 'Sudáfrica'  ✅ En el script: 'Sudáfrica'
'United Kingdom': 'Reino Unido'  ✅ En el script: 'Reino Unido'
```

## 🎯 Beneficios

1. **Compatibilidad Total**: El mapa ahora puede mostrar cualquier país que agregues
2. **Escalabilidad**: Puedes agregar especies de cualquier país del mundo
3. **Organización**: Países agrupados por región para fácil navegación
4. **Mantenibilidad**: Nombres estandarizados en español

## 📊 Próximos Pasos

Después de agregar los países, puedes:

1. **Agregar especies** de cualquier país usando el panel de administración
2. **Ver el mapa** actualizado con todos los países coloreados según tengan especies
3. **Filtrar especies** por cualquier país del mundo

## 🔧 Troubleshooting

### Error: "value too long for type character varying(30)"
- **Causa**: Algunos nombres de países exceden 30 caracteres (ej: "República Democrática del Congo")
- **Solución**: Ejecuta primero el script de migración:
  ```sql
  ALTER TABLE paises ALTER COLUMN nombre TYPE VARCHAR(50);
  ```
  O ejecuta: `supabase/migrations/20251215000001_fix_paises_column_length.sql`

### Error: "relation paises does not exist"
- **Solución**: Primero ejecuta la migración principal:
  ```
  supabase/migrations/20251215000000_create_frontend_compatible_schema.sql
  ```

### Error: "duplicate key value violates unique constraint"
- **Solución**: Esto es normal si algunos países ya existen. El script los ignorará automáticamente.

### No veo los países en el mapa
- **Solución**: Refresca la página del navegador (`Ctrl + F5`)

## 📁 Archivos Relacionados

- **Script SQL**: [`supabase/migrations/20251215000002_add_all_countries.sql`](file:///c:/Users/L13Yoga/Desktop/Zootopia-BD/supabase/migrations/20251215000002_add_all_countries.sql)
- **Mapa Frontend**: [`src/components/WorldMap.tsx`](file:///c:/Users/L13Yoga/Desktop/Zootopia-BD/src/components/WorldMap.tsx)
- **Migración Principal**: [`supabase/migrations/20251215000000_create_frontend_compatible_schema.sql`](file:///c:/Users/L13Yoga/Desktop/Zootopia-BD/supabase/migrations/20251215000000_create_frontend_compatible_schema.sql)

---

**¿Necesitas ayuda?** Revisa la [documentación completa](file:///c:/Users/L13Yoga/Desktop/Zootopia-BD/README.md) del proyecto.
