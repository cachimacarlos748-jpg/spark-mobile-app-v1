# Guía: Publicar SparkIA en Google Play Store

## Paso 1: Compilar APK con Codemagic

### 1.1 Crear cuenta en Codemagic
- Ve a https://codemagic.io
- Haz clic en "Sign Up"
- Elige "Sign up with GitHub" o "Sign up with Google"

### 1.2 Conectar repositorio
- En Codemagic, haz clic en "Add app"
- Selecciona "Flutter"
- Autoriza Codemagic para acceder a tu repositorio
- Selecciona el repositorio `spark_mobile_app`

### 1.3 Configurar compilación
- Codemagic detectará automáticamente `codemagic.yaml`
- Haz clic en "Start new build"
- Espera a que se compile (5-10 minutos)
- Descarga el APK desde "Artifacts"

## Paso 2: Crear cuenta en Google Play Console

### 2.1 Registrarse
- Ve a https://play.google.com/console
- Haz clic en "Create account"
- Completa el formulario
- Paga la tarifa única de $25 USD

### 2.2 Crear aplicación
- Haz clic en "Create app"
- Nombre: "SparkIA"
- Idioma: Español
- Categoría: "Productividad"
- Tipo: "Aplicación"

## Paso 3: Preparar información de la app

### 3.1 Detalles de la aplicación
- **Descripción corta:** "Asistente de IA con Spark - Chat inteligente"
- **Descripción completa:** 
  "SparkIA es un asistente de inteligencia artificial potente y elegante. Chatea con Spark, genera imágenes, accede a información en profundidad y mucho más.
  
  Características:
  - Chat con Spark (IA avanzada)
  - Múltiples modelos: Flash, Flash-Lite, Pro
  - Modo razonamiento avanzado
  - Generación de imágenes
  - Modo offline
  - Tema oscuro/claro
  - Sincronización en la nube"

### 3.2 Categoría y contenido
- Categoría: Productividad
- Clasificación de contenido: Completar cuestionario
- Privacidad: Aceptar términos

### 3.3 Imágenes y video
- **Icono de app:** 512x512 px (logo Spark)
- **Screenshots:** Mínimo 2 (máximo 8)
  - Pantalla de login
  - Pantalla de chat
  - Selector de modelos
  - Menú de opciones
- **Video promocional:** Opcional

## Paso 4: Subir APK

### 4.1 Crear versión de prueba
- Ve a "Testing" → "Internal testing"
- Haz clic en "Create new release"
- Sube el APK descargado de Codemagic
- Completa las notas de la versión

### 4.2 Versión de producción
- Ve a "Release" → "Production"
- Haz clic en "Create new release"
- Sube el APK
- Completa las notas de la versión
- Haz clic en "Review release"

## Paso 5: Completar información legal

### 5.1 Política de privacidad
- Ve a "Policy" → "App content"
- Completa el cuestionario de privacidad
- Acepta los términos

### 5.2 Clasificación de contenido
- Ve a "Policy" → "Content rating"
- Completa el cuestionario IARC
- Obtén la clasificación

## Paso 6: Enviar para revisión

- Ve a "Release" → "Production"
- Haz clic en "Send for review"
- Espera la revisión (24-48 horas)
- Una vez aprobada, la app aparecerá en Google Play Store

## Notas importantes

- **Versión mínima de Android:** 21 (Android 5.0)
- **Versión objetivo:** 35 (Android 15)
- **Tamaño del APK:** ~50-100 MB
- **API Key de Gemini:** Asegúrate de que esté configurada en el servidor backend

## Troubleshooting

### Si Codemagic falla:
1. Verifica que `codemagic.yaml` esté en la raíz del proyecto
2. Asegúrate de que el repositorio sea público
3. Revisa los logs de compilación en Codemagic

### Si Google Play rechaza la app:
1. Revisa el motivo del rechazo
2. Corrige el problema
3. Envía nuevamente

## Contacto de soporte

- **Codemagic:** support@codemagic.io
- **Google Play:** Desde Google Play Console → Help
