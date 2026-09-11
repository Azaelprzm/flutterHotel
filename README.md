# Hotel Lux — Gestión Hotelera

Aplicación multiplataforma desarrollada con Flutter para administrar la operación básica de un hotel. Permite iniciar sesión y gestionar hoteles, habitaciones, clientes y reservas desde una interfaz adaptable a dispositivos móviles, web y escritorio.

El proyecto consume la API REST de [`APIHotel_NodeJS`](https://github.com/Azaelprzm/APIHotel_NodeJS).

## Funcionalidades

- Inicio y cierre de sesión mediante JWT.
- Persistencia segura de la sesión en el dispositivo.
- Alta, consulta, edición y eliminación de hoteles.
- Gestión de habitaciones y tarifas por noche.
- Administración de clientes.
- Creación y seguimiento de reservas.
- Selección de habitaciones correspondientes al hotel elegido.
- Validación de formularios y mensajes de error legibles.
- Interfaz adaptable a distintos tamaños de pantalla.

## Tecnologías

- Flutter 3.24.5 y Dart 3.5.
- `provider` para el estado de autenticación.
- `http` para la comunicación con la API REST.
- `flutter_secure_storage` para proteger el token de sesión.
- GitHub Actions para análisis y pruebas automáticas.

## Estructura principal

```text
lib/
├── config/       # Configuración de la aplicación y URL de la API
├── providers/    # Estado global de autenticación
├── screens/      # Pantallas y formularios
├── services/     # Cliente HTTP, autenticación y operaciones CRUD
└── main.dart     # Inicialización, tema y navegación
```

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.24.5 o compatible.
- Una instancia disponible de `APIHotel_NodeJS`.
- Android Studio, Xcode, un navegador o las herramientas de la plataforma donde se ejecutará la aplicación.

## Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/Azaelprzm/flutterHotel.git
   cd flutterHotel
   ```

2. Instala las dependencias:

   ```bash
   flutter pub get
   ```

3. Ejecuta la aplicación:

   ```bash
   flutter run
   ```

De forma predeterminada se utiliza la API desplegada en Render:

```text
https://apihotel-nodejs.onrender.com/api
```

La primera petición puede tardar unos segundos si el servicio se encontraba inactivo.

## Configurar otro servidor

La URL puede cambiarse sin modificar el código mediante `API_BASE_URL`:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

Para una compilación de producción:

```bash
flutter build apk --dart-define=API_BASE_URL=https://tu-servidor.com/api
```

## Calidad del código

Ejecuta las mismas comprobaciones utilizadas por la integración continua:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Las pruebas cubren el formulario de acceso y el comportamiento esencial del cliente HTTP, incluidos el token de autorización y los errores del servidor.

## Seguridad

- No se almacenan credenciales dentro del repositorio.
- El token JWT se conserva mediante almacenamiento seguro y se elimina al cerrar sesión.
- Las solicitudes usan HTTPS en la configuración publicada.
- Para producción se recomienda configurar firma propia para Android y administrar la URL del servidor mediante `--dart-define`.
