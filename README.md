# Detección de pose

Aplicación Flutter para detectar y analizar la postura corporal usando la
cámara del dispositivo y herramientas de Google ML Kit.

## Requisitos

- Flutter 3.7.1 (gestionado con FVM).
- Dart 2.19.1 (incluido con Flutter).
- Java JDK 17.
- Android SDK con `minSdkVersion 21` o superior.
- Un dispositivo físico o emulador con acceso a la cámara.

El proyecto mantiene compatibilidad de compilación con Java 8 y utiliza Gradle
7.5 con Android Gradle Plugin 7.2.0.

## Instalación

Clona el repositorio y ejecuta:

```bash
flutter pub get
flutter run
```

Para generar una APK de depuración:

```bash
flutter build apk --debug
```

## Tecnologías

- Flutter y Dart
- Cámara del dispositivo
- Google ML Kit
