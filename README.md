# adultech_launcher

## AdulTech Launcher
AdulTech Launcher es una aplicación Flutter diseñada específicamente como un launcher accesible para adultos mayores. La aplicación está orientada a simplificar el uso de dispositivos Android para este grupo demográfico.

### 🎯 Propósito Principal
Es un launcher personalizado que reemplaza la interfaz estándar de Android con una versión simplificada y más accesible, diseñada específicamente para adultos mayores.

### 🔧 Funcionalidades Principales 1. Configuración Inicial Guiada
- Proceso de configuración paso a paso al primer uso
- Selección de tema (claro/oscuro)
- Ajuste de tamaño de fuente
- Configuración de nombre de usuario
- Configuración de contacto de emergencia 2. Interfaz Principal Simplificada
- Pantalla principal con aplicaciones esenciales:
  - WhatsApp (mensajería)
  - Cámara (fotos y videos)
  - Contactos (gestión de contactos)
  - Teléfono (llamadas)
  - Galería (visualización de fotos)
  - Módulo de aprendizaje
- Segunda pantalla con todas las aplicaciones instaladas en el dispositivo 3. Sistema de Emergencia
- Botón de emergencia prominente en la pantalla principal
- Gestión de contactos de emergencia múltiples
- Validación de números telefónicos
- Llamada rápida en situaciones de emergencia 4. Configuración de Accesibilidad
- Modo oscuro/claro
- Ajuste de tamaño de fuente (14-24px)
- Integración con lector de pantalla (TalkBack)
- Interfaz con iconos grandes y texto legible 5. Gestión de Aplicaciones
- Detección automática de aplicaciones instaladas
- Cache de iconos para mejor rendimiento
- Búsqueda y filtrado de aplicaciones
- Lanzamiento directo de aplicaciones
### 🛠 Tecnologías Utilizadas
Framework: Flutter 3.8.1+

Dependencias principales:

- shared_preferences : Almacenamiento local de configuraciones
- installed_apps : Detección de aplicaciones instaladas
- url_launcher : Apertura de URLs y aplicaciones
- flutter_tts : Text-to-speech (preparado para futuras funciones)
- android_intent_plus : Integración con intents de Android
### 📱 Características de Diseño UX/UI Accesible:
- Botones grandes y espaciados
- Colores contrastantes
- Tipografía clara y ajustable
- Navegación simplificada por gestos de deslizamiento
- Iconos descriptivos con texto explicativo Gestión de Estado:
- Uso de StatefulWidget para manejo de estado local
- SharedPreferences para persistencia de datos
- Validación robusta de entrada de datos
### 🔒 Características de Seguridad
- Validación de números telefónicos con regex
- Manejo seguro de contactos de emergencia
- Gestión de errores y excepciones
### 🎨 Personalización
- Temas adaptativos (claro/oscuro)
- Gradientes personalizados con colores de marca
- Interfaz responsive que se adapta al contenido
- Sistema de iconos coherente
### 📊 Arquitectura del Código
La aplicación está estructurada en clases especializadas:

- PhoneValidator : Validación de números telefónicos
- EmergencyContactsManager : Gestión de contactos de emergencia
- AppIconCache : Optimización de rendimiento para iconos
- Múltiples pantallas modulares ( InitialSetupScreen , LauncherScreen , SettingsScreen , EmergencyContactsScreen )