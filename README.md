# Zootopia - Sistema de Gestión de Biodiversidad

Sistema web completo para la gestión y visualización de especies y ejemplares de un zoológico mundial. Desarrollado con React, TypeScript, Tailwind CSS y Supabase.

## 🌟 Características Principales

### Para Usuarios Públicos

- **Mapa Mundial Interactivo**: Navegación visual por regiones con países coloreados según tengan especies registradas
  - América del Norte
  - América del Sur  
  - Europa
  - África
  - Asia
  - Australia
- **Catálogo de Especies**: Exploración de todas las especies organizadas por región
- **Filtros Inteligentes**:
  - Por tipo de animal (mamífero, ave, reptil, pez, anfibio, insecto)
  - Por país de procedencia (solo muestra países con especies)
  - Por ecosistema (bosque templado, tundra, sabana, arrecife, etc.)
  - Búsqueda por nombre común o científico
- **Fichas Técnicas Completas**:
  - Información detallada de cada especie
  - Hábitat natural, dieta, reproducción, longevidad
  - Comportamiento y descripción general
  - Estado de conservación con código IUCN
- **Visualización de Ejemplares**: Ver todos los ejemplares de cada especie
- **Información Individual**: Detalles completos de cada ejemplar

### Para Usuarios Registrados

- Sistema de registro y autenticación con Supabase Auth
- Acceso a todas las funcionalidades públicas
- Perfil de usuario personalizado

### Para Administradores

- **Panel de Administración Completo**
- **Gestión de Especies**:
  - Crear nuevas especies con ficha técnica integrada
  - Editar información de especies existentes
  - Eliminar especies
- **Gestión de Ejemplares**:
  - Registrar nuevos ejemplares
  - Actualizar información (estado de salud, hábitat actual, observaciones)
  - Eliminar ejemplares

## 🗄️ Estructura de la Base de Datos

### Tablas Principales (snake_case)

1. **regiones**: 6 regiones geográficas del mundo
2. **paises**: 30 países asociados a cada región
3. **tipos**: 6 clasificaciones de animales
4. **ecosistemas**: 10 tipos de ecosistemas
5. **estados_conservacion**: 7 estados de conservación (con código IUCN)
6. **especies**: 30 especies con ficha técnica integrada
7. **fichas_tecnicas**: Fichas técnicas (legacy, opcional)
8. **ejemplares**: 30 ejemplares individuales
9. **usuarios**: Usuarios del sistema con roles
10. **roles**: 2 roles (admin, user)
11. **profiles**: Tabla requerida por Supabase Auth
12. **auditorias**: Log de auditoría

### Seguridad

- Row Level Security (RLS) habilitado en todas las tablas
- Acceso público de lectura para datos del zoológico
- Solo administradores pueden crear, editar o eliminar datos
- Autenticación segura con Supabase Auth

## 🚀 Tecnologías Utilizadas

- **Frontend**: React 18 con TypeScript
- **Estilos**: Tailwind CSS
- **Enrutamiento**: React Router DOM
- **Mapas**: react-simple-maps
- **Backend**: Supabase (PostgreSQL)
- **Autenticación**: Supabase Auth
- **Iconos**: Lucide React
- **Build Tool**: Vite

## 📁 Estructura del Proyecto

```
src/
├── components/
│   ├── Navbar.tsx              # Barra de navegación con auth
│   └── WorldMap.tsx            # Mapa mundial interactivo SVG
├── contexts/
│   └── AuthContext.tsx         # Contexto de autenticación (usuarios table)
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

supabase/
└── migrations/
    ├── 20251215000000_create_frontend_compatible_schema.sql
    └── 20251215000001_create_procedures_views_triggers_frontend.sql
```

## ⚙️ Instalación y Configuración

### Prerrequisitos

- Node.js (v16 o superior)
- npm o yarn
- Cuenta de Supabase

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd Zootopia-BD
   ```

2. **Instalar dependencias**
   ```bash
   npm install
   ```

3. **Configurar variables de entorno**
   
   Crea un archivo `.env` en la raíz del proyecto:
   ```env
   VITE_SUPABASE_URL=tu-url-de-supabase
   VITE_SUPABASE_ANON_KEY=tu-key-anonima
   ```

4. **Ejecutar migraciones en Supabase**
   
   Ve a **Supabase Dashboard → SQL Editor** y ejecuta en orden:
   
   a. `supabase/migrations/20251215000000_create_frontend_compatible_schema.sql`
   
   b. `supabase/migrations/20251215000001_create_procedures_views_triggers_frontend.sql`
   
   Para más detalles, consulta la [Guía de Migraciones](./brain/guia_migraciones.md)

5. **Iniciar el servidor de desarrollo**
   ```bash
   npm run dev
   ```

6. **Construir para producción**
   ```bash
   npm run build
   ```

## 👤 Uso del Sistema

### Como Usuario Público

1. Visita la página principal
2. Haz clic en cualquier país del mapa (los países con especies están coloreados)
3. Explora las especies usando los filtros disponibles
4. Haz clic en una especie para ver su información completa
5. Visualiza los ejemplares individuales de cada especie

### Como Usuario Registrado

1. Haz clic en "Registrarse" en la barra de navegación
2. Completa el formulario de registro
3. Inicia sesión con tus credenciales
4. Disfruta de todas las funcionalidades públicas

### Como Administrador

1. **Hacerte Administrador**:
   - Regístrate normalmente
   - Ve a Supabase Dashboard → Table Editor → `usuarios`
   - Cambia tu `rol_id` de `2` a `1`
   - Cierra sesión y vuelve a iniciar sesión

2. **Usar el Panel de Admin**:
   - Haz clic en "Admin" en la barra de navegación
   - Selecciona la pestaña "Especies" o "Ejemplares"
   - Usa los botones para crear, editar o eliminar registros

Para más detalles, consulta [ADMIN_SETUP.md](./ADMIN_SETUP.md)

## 🎨 Características de Diseño

- **Diseño Responsivo**: Funciona en móviles, tabletas y escritorio
- **Interfaz Moderna**: Gradientes, sombras y animaciones suaves
- **Colores Temáticos**: Paleta natural (verde esmeralda, teal, cyan)
- **Experiencia Fluida**: Navegación intuitiva y transiciones suaves
- **Feedback Visual**: Estados de conservación con colores, etiquetas informativas

## 🔒 Características de Seguridad

- Autenticación segura con Supabase Auth
- Tokens JWT para sesiones
- RLS (Row Level Security) en todas las tablas
- Validación de roles (rol_id: 1=admin, 2=user)
- Protección de rutas administrativas
- Políticas de INSERT para registro de usuarios

## 🛣️ Rutas de la Aplicación

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

## 📊 Datos Iniciales

El sistema incluye 30 registros en cada tabla principal:

- **6 Regiones**: África, América del Norte, América del Sur, Asia, Europa, Australia
- **30 Países**: Distribuidos por región
- **6 Tipos**: Mamífero, Ave, Reptil, Pez, Anfibio, Insecto
- **7 Estados de Conservación**: CR, EN, VU, NT, LC, DD, EX (con códigos IUCN)
- **10 Ecosistemas**: Bosque templado, Tundra, Sabana, Arrecife, Selva tropical, Desierto, Pradera, Montaña, Manglar, Humedal
- **30 Especies**: Con fichas técnicas completas integradas
- **30 Ejemplares**: Con información individual detallada
- **30 Usuarios**: Datos de prueba (2 admins, 28 users)

## 📚 Documentación Adicional

- **[DOCUMENTACION_COMPLETA.md](./DOCUMENTACION_COMPLETA.md)** - Documentación académica completa:
  - 3 Procedimientos almacenados
  - 3 Vistas
  - 5 Consultas SQL con álgebra relacional
  - 2 Triggers (BEFORE y AFTER)
  
- **[ADMIN_SETUP.md](./ADMIN_SETUP.md)** - Guía para configurar administradores

- **[Guía de Migraciones](./brain/guia_migraciones.md)** - Instrucciones detalladas para ejecutar migraciones

## 🔧 Scripts Disponibles

- `npm run dev` - Inicia el servidor de desarrollo
- `npm run build` - Construye la aplicación para producción
- `npm run preview` - Previsualiza la build de producción
- `npm run lint` - Ejecuta el linter
- `npm run typecheck` - Verifica los tipos de TypeScript

## 🗃️ Arquitectura de Autenticación

El sistema usa una arquitectura dual de tablas:

- **`profiles`**: Tabla requerida por Supabase Auth (creada automáticamente al registrarse)
- **`usuarios`**: Tabla principal del frontend con roles y datos del usuario

Cuando un usuario se registra:
1. Supabase Auth crea el usuario en `auth.users`
2. Un trigger automático crea un registro en `profiles`
3. El código del frontend crea un registro en `usuarios` con `rol_id = 2` (user)

El frontend usa la tabla `usuarios` para determinar roles y permisos.

## 🌍 Características del Mapa

- Mapa SVG interactivo con países clickeables
- Países con especies se muestran en color
- Países sin especies se muestran en gris
- Hover muestra el nombre del país
- Click navega a las especies de esa región
- Responsive y optimizado para rendimiento

---

**Desarrollado con ❤️ usando React, TypeScript, Tailwind CSS y Supabase**
