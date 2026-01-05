# ⚖️ LegalTech Analista - Gemini 2.0

Aplicación profesional desarrollada en **Flutter** que utiliza la potencia de **Gemini 2.0 Flash** para analizar contratos y documentos legales extensos. Gracias a su ventana de contexto de hasta 2 millones de tokens, permite procesar archivos PDF completos sin fragmentar la información.

## 🚀 Características

* **Análisis de Contexto Largo:** Sube PDFs de cientos de páginas y realiza preguntas complejas.
* **Citas Textuales Inteligentes:** Gemini identifica la cláusula exacta y la aplicación resalta el texto automáticamente en el visor.
* **Interfaz Moderna:** Diseño optimizado para sectores profesionales con panel de chat flotante y visor de PDF integrado.
* **Gestión de Estado:** Implementado con `Provider` para una arquitectura limpia y reactiva.

## 🛠️ Instalación y Configuración

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/tu-usuario/tu-proyecto.git](https://github.com/tu-usuario/tu-proyecto.git)
    cd tu-proyecto
    ```

2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Configurar Variables de Entorno:**
    * Crea un archivo llamado `.env` en la raíz del proyecto.
    * Añade tu clave de Google AI Studio:
        ```text
        GEMINI_API_KEY=AIzaSy...tu_clave_aqui
        ```

4.  **Permisos:**
    * **Android:** Asegúrate de que `AndroidManifest.xml` tenga el permiso de Internet.
    * **macOS:** Habilita el "App Sandbox" (Network Client) en los archivos `.entitlements`.

5.  **Ejecutar:**
    ```bash
    flutter run
    ```

## 📦 Librerías Principales

* `google_generative_ai`: Integración oficial con Gemini.
* `syncfusion_flutter_pdfviewer`: Visor de PDF con motor de búsqueda y resaltado.
* `provider`: Gestión de estado.
* `flutter_dotenv`: Manejo seguro de API Keys.
* `file_picker`: Selección de archivos multiplataforma.

## 📄 Licencia
Este proyecto es de uso educativo/profesional. Consulta los términos de uso de la API de Google Gemini para despliegues comerciales.