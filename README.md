# Zootopia - Sistema de Gestión de Biodiversidad

Sistema web completo para la gestión y visualización de especies y ejemplares de un zoológico mundial. Desarrollado con React, TypeScript, Tailwind CSS y Supabase.

## Características Principales

### Para Usuarios Públicos

- **Mapa Mundial Interactivo SVG**: Navegación visual por regiones del mundo con mapa interactivo clickeable
  - América del Norte
  - América del Sur
  - Europa
  - África
  - Asia
  - Australia
- **Catálogo de Especies**: Exploración de todas las especies organizadas por región
- **Filtros Avanzados**:
  - Por tipo de animal (mamífero, ave, reptil, pez, anfibio, insecto)
  - Por país de procedencia
  - Por ecosistema (bosque templado, tundra, sabana, arrecife, etc.)
- **Fichas Técnicas Detalladas**:
  - Información completa de cada especie
  - Hábitat natural, dieta, reproducción, longevidad
  - Comportamiento y descripción general
  - Estado de conservación (peligro de extinción)
- **Visualización de Ejemplares**: Ver todos los ejemplares de cada especie
- **Información Individual**: Detalles completos de cada ejemplar (nombre, sexo, edad, estado de salud, etc.)

### Para Usuarios Registrados

- Sistema de registro y autenticación
- Acceso a todas las funcionalidades públicas
- Perfil de usuario personalizado

### Para Administradores

- **Panel de Administración Completo**
- **Gestión de Especies**:
  - Crear nuevas especies
  - Editar información de especies existentes
  - Eliminar especies
  - Actualizar fichas técnicas
- **Gestión de Ejemplares**:
  - Registrar nuevos ejemplares
  - Actualizar información de ejemplares
  - Eliminar ejemplares
  - Gestionar estado de salud y observaciones

## Estructura de la Base de Datos

### Tablas Principales

1. **regiones**: Continentes y regiones del mundo
2. **paises**: Países asociados a cada región
3. **ecosistemas**: Tipos de ecosistemas (sabana, selva, desierto, etc.)
4. **tipos**: Clasificación de animales (mamífero, ave, reptil, etc.)
5. **estados_conservacion**: Estados de conservación (CR, EN, VU, NT, LC, etc.)
6. **especies**: Información completa de cada especie
7. **ejemplares**: Ejemplares individuales en el zoológico
8. **profiles**: Perfiles de usuario con roles (admin/user)

### Seguridad

- Row Level Security (RLS) habilitado en todas las tablas
- Acceso público de lectura para datos del zoológico
- Solo administradores pueden crear, editar o eliminar datos
- Autenticación segura con Supabase Auth

## Tecnologías Utilizadas

- **Frontend**: React 18 con TypeScript
- **Estilos**: Tailwind CSS
- **Enrutamiento**: React Router DOM
- **Backend**: Supabase (PostgreSQL)
- **Autenticación**: Supabase Auth
- **Iconos**: Lucide React
- **Build Tool**: Vite

## Estructura del Proyecto

```
src/
├── components/
│   └── Navbar.tsx              # Barra de navegación
├── contexts/
│   └── AuthContext.tsx         # Contexto de autenticación
├── lib/
│   └── supabase.ts            # Cliente de Supabase
├── pages/
│   ├── Home.tsx               # Página principal con mapa
│   ├── Login.tsx              # Inicio de sesión
│   ├── Register.tsx           # Registro de usuarios
│   ├── RegionSpecies.tsx      # Especies por región con filtros
│   ├── SpeciesDetail.tsx      # Detalle de especie
│   ├── SpecimenDetail.tsx     # Detalle de ejemplar
│   ├── AdminPanel.tsx         # Panel de administración
│   ├── SpeciesForm.tsx        # Formulario de especies
│   └── SpecimenForm.tsx       # Formulario de ejemplares
├── App.tsx                    # Componente principal
└── main.tsx                   # Punto de entrada
```

## Instalación y Configuración

### Prerrequisitos

- Node.js (v16 o superior)
- npm o yarn
- Cuenta de Supabase

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd project
   ```

2. **Instalar dependencias**
   ```bash
   npm install
   ```

3. **Configurar variables de entorno**

   El archivo `.env` ya está configurado con las credenciales de Supabase:
   ```
   VITE_SUPABASE_URL=<tu-url-de-supabase>
   VITE_SUPABASE_ANON_KEY=<tu-key-anonima>
   ```

4. **Iniciar el servidor de desarrollo**
   ```bash
   npm run dev
   ```

5. **Construir para producción**
   ```bash
   npm run build
   ```

## Uso del Sistema

### Como Usuario Público

1. Visita la página principal
2. Haz clic en cualquier región del mapa mundial
3. Explora las especies usando los filtros disponibles
4. Haz clic en una especie para ver su información completa
5. Visualiza los ejemplares individuales de cada especie

### Como Usuario Registrado

1. Haz clic en "Registrarse" en la barra de navegación
2. Completa el formulario de registro
3. Inicia sesión con tus credenciales
4. Disfruta de todas las funcionalidades públicas

### Como Administrador

1. Inicia sesión con credenciales de administrador
2. Haz clic en el botón "Admin" en la barra de navegación
3. Selecciona la pestaña "Especies" o "Ejemplares"
4. Usa los botones para crear, editar o eliminar registros
5. Completa los formularios con la información requerida

## Características de Diseño

- **Diseño Responsivo**: Funciona perfectamente en dispositivos móviles, tabletas y escritorio
- **Interfaz Moderna**: Uso de gradientes, sombras y animaciones suaves
- **Colores Temáticos**: Paleta de colores naturales (verde esmeralda, teal, cyan)
- **Experiencia de Usuario Fluida**: Navegación intuitiva y transiciones suaves
- **Feedback Visual**: Indicadores de estado, colores de conservación, etiquetas informativas

## Características de Seguridad

- Autenticación segura con email y contraseña
- Tokens JWT para sesiones
- RLS (Row Level Security) en todas las tablas
- Validación de roles en el frontend y backend
- Protección de rutas administrativas

## Rutas de la Aplicación

- `/` - Página principal con mapa mundial
- `/login` - Inicio de sesión
- `/register` - Registro de usuarios
- `/region/:regionId` - Especies de una región específica
- `/species/:speciesId` - Detalle de una especie
- `/specimen/:specimenId` - Detalle de un ejemplar
- `/admin` - Panel de administración (solo admins)
- `/admin/species/new` - Crear nueva especie (solo admins)
- `/admin/species/edit/:speciesId` - Editar especie (solo admins)
- `/admin/specimens/new` - Crear nuevo ejemplar (solo admins)
- `/admin/specimens/edit/:specimenId` - Editar ejemplar (solo admins)

## Datos Iniciales

El sistema incluye datos de ejemplo:

- **Regiones**: África, América, Asia, Europa, Oceanía
- **Tipos de Animales**: Mamífero, Ave, Reptil, Pez, Anfibio, Insecto
- **Estados de Conservación**: CR, EN, VU, NT, LC, DD, EW
- **Ecosistemas**: Bosque templado, Tundra, Sabana, Arrecife, Selva tropical, Desierto, Pradera, Montaña, Manglar, Humedal

## Conexión con Backend Externo

El sistema está diseñado para trabajar con Supabase como backend. Si deseas conectarlo a un backend diferente:

1. Modifica el archivo `src/lib/supabase.ts`
2. Actualiza las URLs de las API calls
3. Ajusta los tipos de datos según tu esquema
4. Mantén la misma estructura de datos para compatibilidad

## Scripts Disponibles

- `npm run dev` - Inicia el servidor de desarrollo
- `npm run build` - Construye la aplicación para producción
- `npm run preview` - Previsualiza la build de producción
- `npm run lint` - Ejecuta el linter
- `npm run typecheck` - Verifica los tipos de TypeScript

## Proyecto Escolar - Base de Datos Completa

Este proyecto incluye una base de datos completamente funcional con 30 registros. Para la documentación académica completa, consulta:

**DOCUMENTACION_COMPLETA.md** - Incluye:
- 3 Procedimientos almacenados con descripción y código SQL
- 3 Vistas con documentación completa
- 5 Consultas SQL con álgebra relacional
- 2 Triggers (BEFORE y AFTER) con ejemplos
- Comandos SELECT * para verificar todas las tablas

### Datos Poblados

- **30 Especies** completas con fichas técnicas
- **30 Ejemplares** individuales
- **30 Países** distribuidos por región
- **30 Usuarios** en el sistema
- Catálogos completos (6 regiones, 6 tipos, 10 ecosistemas, 7 estados de conservación)

### Para Obtener Capturas de Pantalla

Ejecuta en Supabase SQL Editor:

```sql
-- Ver todas las tablas
SELECT * FROM especies;
SELECT * FROM ejemplares;
SELECT * FROM paises;

-- Ejecutar procedimientos
SELECT * FROM obtener_especies_por_estado_conservacion('Vulnerable');
SELECT * FROM calcular_estadisticas_zoo();

-- Ver vistas
SELECT * FROM vista_especies_completa;
SELECT * FROM vista_ejemplares_detalle;
SELECT * FROM vista_estadisticas_regiones;
```

Consulta **DOCUMENTACION_COMPLETA.md** para todos los detalles.

---

Desarrollado con React, TypeScript, Tailwind CSS y Supabase
