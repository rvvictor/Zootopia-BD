# Integración con Backend Externo

Este documento explica cómo conectar el frontend con un backend personalizado.

## Estado Actual

Actualmente, la aplicación está configurada para usar **Supabase** como backend, que proporciona:
- Base de datos PostgreSQL
- Autenticación
- APIs REST automáticas
- Row Level Security (RLS)

## Opción 1: Continuar con Supabase (Recomendado)

Si tu backend existente es compatible con Supabase o puedes migrarlo:

1. Ya está todo configurado
2. Solo necesitas asegurarte de que las tablas coincidan con el esquema definido
3. Las migraciones en el proyecto ya crearon toda la estructura necesaria

## Opción 2: Conectar con Backend Personalizado

Si deseas usar tu propio backend, sigue estos pasos:

### 1. Actualizar el Cliente de API

Edita el archivo `src/lib/supabase.ts` para apuntar a tu backend:

```typescript
// Ejemplo con fetch personalizado
const API_URL = 'https://tu-backend.com/api';

export const api = {
  // Regiones
  getRegiones: () => fetch(`${API_URL}/regiones`).then(r => r.json()),

  // Especies
  getEspecies: (regionId: string) =>
    fetch(`${API_URL}/especies?region=${regionId}`).then(r => r.json()),

  getEspecie: (id: string) =>
    fetch(`${API_URL}/especies/${id}`).then(r => r.json()),

  // ... más endpoints
};
```

### 2. Estructura de Datos Requerida

Tu backend debe proporcionar las siguientes entidades con esta estructura:

#### Regiones
```json
{
  "id": "uuid",
  "nombre": "África",
  "descripcion": "Continente africano..."
}
```

#### Países
```json
{
  "id": "uuid",
  "nombre": "Kenia",
  "region_id": "uuid"
}
```

#### Ecosistemas
```json
{
  "id": "uuid",
  "nombre": "Sabana",
  "descripcion": "Praderas tropicales..."
}
```

#### Tipos
```json
{
  "id": "uuid",
  "nombre": "Mamífero"
}
```

#### Estados de Conservación
```json
{
  "id": "uuid",
  "nombre": "En peligro",
  "codigo": "EN"
}
```

#### Especies
```json
{
  "id": "uuid",
  "nombre_comun": "León Africano",
  "nombre_cientifico": "Panthera leo",
  "tipo_id": "uuid",
  "pais_id": "uuid",
  "ecosistema_id": "uuid",
  "habitat_natural": "Praderas y sabanas...",
  "dieta": "Carnívoro...",
  "reproduccion": "Las leonas dan a luz...",
  "longevidad": "10-14 años...",
  "comportamiento": "Animal social...",
  "estado_conservacion_id": "uuid",
  "descripcion_general": "El león es...",
  "imagen_url": "https://..."
}
```

#### Ejemplares
```json
{
  "id": "uuid",
  "nombre": "Simba",
  "especie_id": "uuid",
  "sexo": "Macho",
  "fecha_nacimiento": "2020-01-15",
  "fecha_ingreso": "2020-03-10",
  "habitat_actual": "Zona Africana 1",
  "estado_salud": "Saludable",
  "observaciones": "Adaptación exitosa",
  "imagen_url": "https://..."
}
```

### 3. Endpoints Requeridos

Tu backend debe implementar estos endpoints:

#### Públicos (sin autenticación)
- `GET /regiones` - Listar todas las regiones
- `GET /especies` - Listar especies (con filtros opcionales)
- `GET /especies/:id` - Obtener detalle de especie
- `GET /ejemplares` - Listar ejemplares por especie
- `GET /ejemplares/:id` - Obtener detalle de ejemplar
- `GET /paises` - Listar países
- `GET /ecosistemas` - Listar ecosistemas
- `GET /tipos` - Listar tipos de animales
- `GET /estados-conservacion` - Listar estados de conservación

#### Protegidos (requieren autenticación de admin)
- `POST /especies` - Crear especie
- `PUT /especies/:id` - Actualizar especie
- `DELETE /especies/:id` - Eliminar especie
- `POST /ejemplares` - Crear ejemplar
- `PUT /ejemplares/:id` - Actualizar ejemplar
- `DELETE /ejemplares/:id` - Eliminar ejemplar

#### Autenticación
- `POST /auth/register` - Registro de usuario
- `POST /auth/login` - Login de usuario
- `POST /auth/logout` - Cerrar sesión
- `GET /auth/profile` - Obtener perfil del usuario actual

### 4. Actualizar las Páginas

Una vez que tengas el nuevo cliente de API, actualiza las importaciones en todas las páginas:

```typescript
// Antes
import { supabase } from '../lib/supabase';

// Después
import { api } from '../lib/api';
```

Y reemplaza las llamadas a Supabase:

```typescript
// Antes
const { data } = await supabase.from('especies').select('*');

// Después
const data = await api.getEspecies();
```

### 5. Autenticación

Para la autenticación, actualiza el `AuthContext.tsx` para usar tu sistema de auth:

```typescript
const signIn = async (email: string, password: string) => {
  const response = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });

  if (!response.ok) throw new Error('Login failed');

  const { token, user } = await response.json();
  localStorage.setItem('token', token);
  setUser(user);
};
```

### 6. Variables de Entorno

Actualiza el archivo `.env` con la URL de tu backend:

```env
VITE_API_URL=https://tu-backend.com/api
```

## Opción 3: Backend Híbrido

Puedes usar Supabase para algunas funciones y tu backend para otras:

- Supabase: Autenticación y base de datos
- Tu backend: Lógica de negocio personalizada, integraciones externas, etc.

En este caso, mantén la configuración actual y agrega endpoints adicionales según necesites.

## Consideraciones Importantes

1. **CORS**: Asegúrate de que tu backend tenga CORS configurado correctamente
2. **Autenticación**: Implementa JWT u otro sistema de tokens
3. **Validación**: Valida todos los datos en el backend
4. **Rate Limiting**: Implementa límites de peticiones
5. **Paginación**: Para listas grandes, implementa paginación
6. **Filtros**: Soporta filtros por tipo, país, ecosistema, etc.
7. **Búsqueda**: Implementa búsqueda por nombre de especie

## Esquema de Base de Datos

Si necesitas recrear la base de datos en tu backend, usa las migraciones incluidas en:
- `supabase/migrations/` (si usas el CLI de Supabase)
- O consulta el archivo de migración inicial en el proyecto

## Testing

Para probar la integración:

1. Inicia tu backend
2. Actualiza las URLs en el código
3. Ejecuta `npm run dev`
4. Verifica que todas las páginas carguen correctamente
5. Prueba las operaciones CRUD como administrador

## Soporte

Si encuentras problemas durante la integración, verifica:
- Que el backend esté corriendo
- Que las URLs sean correctas
- Que CORS esté configurado
- Que la estructura de datos coincida
- Que la autenticación funcione
