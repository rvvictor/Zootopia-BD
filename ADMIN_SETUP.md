# Configuración de Administrador

Este documento explica cómo crear un usuario administrador en el sistema.

## Método 1: Crear Administrador desde Supabase Dashboard

### Opción A: Modificar un usuario existente

1. Regístrate en la aplicación como usuario normal
2. Ve al Dashboard de Supabase
3. Navega a: **Authentication** > **Users**
4. Copia el **User ID** del usuario que quieres convertir en admin
5. Ve a: **Table Editor** > **profiles**
6. Busca el registro con ese User ID
7. Cambia el campo `role` de `user` a `admin`
8. Guarda los cambios

### Opción B: Ejecutar SQL directamente

1. Ve al Dashboard de Supabase
2. Navega a: **SQL Editor**
3. Ejecuta el siguiente comando (reemplaza el email con el correo del usuario):

```sql
UPDATE profiles
SET role = 'admin'
WHERE email = 'tu-email@example.com';
```

## Método 2: Crear Admin mediante Backend

Si tienes acceso al backend, puedes ejecutar este comando SQL después de que un usuario se haya registrado:

```sql
-- Primero, identifica el user ID
SELECT id, email, role FROM profiles WHERE email = 'admin@example.com';

-- Luego, actualiza el rol
UPDATE profiles
SET role = 'admin'
WHERE email = 'admin@example.com';
```

## Verificación

Para verificar que el usuario es administrador:

1. Inicia sesión con las credenciales del usuario
2. Deberías ver el botón "Admin" en la barra de navegación
3. Al hacer clic, deberías acceder al Panel de Administración

## Notas Importantes

- Por defecto, todos los usuarios nuevos se crean con el rol `user`
- Solo los usuarios con rol `admin` pueden:
  - Crear nuevas especies
  - Editar especies existentes
  - Eliminar especies
  - Crear nuevos ejemplares
  - Editar ejemplares existentes
  - Eliminar ejemplares
- Los usuarios normales solo pueden ver la información, no modificarla

## Credenciales de Prueba Sugeridas

Para desarrollo y pruebas, puedes crear un usuario administrador con:

- Email: `admin@zoologico.com`
- Contraseña: Una contraseña segura de tu elección

Luego, sigue los pasos del Método 1 para convertirlo en administrador.
