# Safe Car Automotive — Flutter App v4.0

App Android nativa para Safe Car Automotive, Chicago.
Conectada a: https://safecar-backend.onrender.com

## Stack
- Flutter 3.x
- Provider (estado del carrito)
- Google Fonts: Barlow + IBM Plex Mono + Inter
- flutter_animate (animaciones)
- cached_network_image (imágenes del backend)

## Pantallas
| Pantalla | Descripción |
|---|---|
| Home | Hero animado, stats, categorías, featured parts |
| Shop | Catálogo con búsqueda, filtros por categoría, scroll infinito |
| Training | Cursos del backend |
| Cart | Carrito con swipe-to-delete, checkout con quote request |
| Contact | Info, horarios, about |
| Part Detail | Hero image, stock, descripción, add to cart |

## Setup inicial

```bash
# 1. Crear proyecto Flutter base
flutter create --org com.safecar --project-name safecar_app .

# 2. Reemplazar lib/ y pubspec.yaml con los archivos de este zip

# 3. Instalar dependencias
flutter pub get

# 4. Correr en debug
flutter run

# 5. Generar APK release
flutter build apk --release --split-per-abi
```

El APK estará en:
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

## Cambiar URL del backend
En lib/theme/app_theme.dart:
static const String apiBase = 'https://safecar-backend.onrender.com';

## Endpoints que usa la app
- GET /health
- GET /parts/?category=X&search=Y&skip=N&limit=M
- GET /parts/{id}
- GET /training/
- POST /quotes/
