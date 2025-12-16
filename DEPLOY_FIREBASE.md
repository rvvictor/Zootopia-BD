# Guía de Despliegue a Firebase Hosting

Esta guía te ayudará a desplegar tu proyecto Zootopia-BD en Firebase Hosting.

## Requisitos Previos

- ✅ Proyecto funcionando localmente
- ✅ Cuenta de Google
- ✅ Node.js instalado

## Paso 1: Instalar Firebase CLI

```bash
npm install -g firebase-tools
```

## Paso 2: Iniciar Sesión en Firebase

```bash
firebase login
```

Esto abrirá tu navegador para que inicies sesión con tu cuenta de Google.

## Paso 3: Inicializar Firebase en tu Proyecto

Desde la raíz de tu proyecto (`c:\Users\javis\Desktop\Zootopia-BD`), ejecuta:

```bash
firebase init
```

### Configuración Interactiva:

1. **¿Qué características quieres configurar?**
   - Selecciona: `Hosting` (usa las flechas y espacio para seleccionar)

2. **¿Quieres usar un proyecto existente o crear uno nuevo?**
   - Selecciona: `Create a new project` (o usa uno existente si ya tienes)

3. **¿Cuál es tu directorio público?**
   - Escribe: `dist` (este es el directorio donde Vite genera los archivos de producción)

4. **¿Configurar como aplicación de una sola página (SPA)?**
   - Responde: `Yes` (y)

5. **¿Configurar builds y deploys automáticos con GitHub?**
   - Responde: `No` (n) por ahora

6. **¿Sobrescribir index.html?**
   - Responde: `No` (n)

## Paso 4: Construir el Proyecto para Producción

```bash
npm run build
```

Este comando creará una carpeta `dist` con todos los archivos optimizados para producción.

## Paso 5: Configurar Variables de Entorno

> [!IMPORTANT]
> **Antes de desplegar**, asegúrate de que tu aplicación use las variables de entorno correctas de Supabase en producción.

Las variables de entorno en Vite deben estar en un archivo `.env` y comenzar con `VITE_`:

```env
VITE_SUPABASE_URL=tu_url_de_supabase
VITE_SUPABASE_ANON_KEY=tu_clave_anonima
```

> [!WARNING]
> **No subas el archivo `.env` a Git**. Ya está en `.gitignore`, pero verifica que no se suba accidentalmente.

## Paso 6: Desplegar a Firebase

```bash
firebase deploy
```

Este comando:
1. Sube los archivos de la carpeta `dist` a Firebase Hosting
2. Te dará una URL pública donde tu aplicación estará disponible

Ejemplo de URL: `https://tu-proyecto.web.app`

## Paso 7: Verificar el Despliegue

1. Abre la URL que te dio Firebase
2. Verifica que todo funcione correctamente
3. Prueba el login, las especies, y los modelos 3D

---

## Comandos Útiles

### Ver el proyecto localmente antes de desplegar
```bash
npm run build
firebase serve
```

### Desplegar solo Hosting
```bash
firebase deploy --only hosting
```

### Ver logs de despliegue
```bash
firebase hosting:channel:list
```

---

## Solución de Problemas

### Error: "No se encuentra el directorio dist"

**Solución**: Asegúrate de ejecutar `npm run build` antes de `firebase deploy`.

### Error: "Variables de entorno no definidas"

**Solución**: Verifica que tu archivo `.env` tenga las variables con el prefijo `VITE_`:
```env
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
```

### La aplicación no carga correctamente

**Solución**: 
1. Verifica que `firebase.json` tenga configurado `"rewrites"` para SPA
2. Limpia la caché: `firebase hosting:channel:delete preview`
3. Vuelve a desplegar: `firebase deploy`

### Modelos 3D no cargan

**Solución**:
- Verifica que las URLs de Sketchfab sean públicas
- Si usas archivos GLB, asegúrate de que Supabase Storage esté configurado como público

---

## Actualizar el Despliegue

Cada vez que hagas cambios:

```bash
# 1. Construir nueva versión
npm run build

# 2. Desplegar
firebase deploy
```

---

## Configuración Avanzada (Opcional)

### Dominios Personalizados

1. Ve a Firebase Console → Hosting
2. Haz clic en "Agregar dominio personalizado"
3. Sigue las instrucciones para configurar DNS

### CI/CD con GitHub Actions

Si quieres despliegues automáticos cuando hagas push a GitHub, puedes configurar GitHub Actions:

```bash
firebase init hosting:github
```

---

## Resumen de Archivos Importantes

- **`firebase.json`** - Configuración de Firebase
- **`.firebaserc`** - Proyecto de Firebase activo
- **`dist/`** - Archivos de producción (generados con `npm run build`)
- **`.env`** - Variables de entorno (NO subir a Git)

---

## Checklist de Despliegue

- [ ] Firebase CLI instalado
- [ ] Sesión iniciada en Firebase
- [ ] Proyecto inicializado con `firebase init`
- [ ] Variables de entorno configuradas
- [ ] Proyecto construido con `npm run build`
- [ ] Primera vez desplegado con `firebase deploy`
- [ ] URL verificada y funcionando
- [ ] Supabase conectado correctamente
- [ ] Modelos 3D cargando correctamente

¡Tu proyecto estará en línea y accesible desde cualquier lugar! 🚀
