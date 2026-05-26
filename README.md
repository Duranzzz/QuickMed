# 🏥 QuickMed: Salud al alcance de tu mano

**QuickMed** es una plataforma de telemedicina integral diseñada específicamente para acercar la atención médica a las zonas rurales y áreas de difícil acceso en Bolivia. Nuestra misión es simplificar todo el ecosistema de consulta médica: desde el triaje inicial hasta la videoconsulta y la entrega de recetas digitales verificables en farmacias.

---

## ✨ Características Principales

Diseñamos QuickMed pensando en la accesibilidad, la eficiencia y el bajo consumo de recursos, dividiendo la experiencia para 3 roles clave: **Paciente, Médico y Farmacéutico**.

### 📱 Para el Paciente
- **Acceso Simplificado (Sin Contraseñas):** Ingresa solo con tu número de celular. La identidad se verifica de forma rápida mediante un código SMS (OTP).
- **Triaje Visual e Intuitivo:** Selección de síntomas basada en **iconos amigables** (ej. Dolor de cabeza 👤, Problemas de estómago 🤢).
- **Semáforo de Dolor:** Escala de 5 niveles por síntoma basada en colores (del verde al rojo oscuro) para indicar la gravedad del malestar.
- **Consultorio Virtual a un Toque:** Botón gigante de acceso directo para entrar a la videoconsulta sin menús complejos.
- **Sala de Espera Relajante:** Reloj de arena animado e indicador del número de turno en tiempo real para mitigar la ansiedad.
- **Recetas Digitales Propias:** El paciente recibe sus recetas médicas directamente en la app. Puede **descargarlas a la galería de fotos** (para uso sin internet) o **compartirlas por WhatsApp/SMS** con sus familiares.

### 🩺 Para el Médico
- **Dashboard Priorizado:** Panel en tiempo real que lista a los pacientes en la sala de espera. Un algoritmo ordena automáticamente la cola, resaltando en rojo a los casos urgentes.
- **Telemedicina Optimizada:** Videollamadas integradas que se adaptan a la conexión. Si el internet del paciente falla, el sistema realiza una **degradación automática a "solo audio"** para no perder la consulta.
- **Emisión de Recetas Inteligente:** Al terminar la llamada, el médico llena un formulario dinámico de medicamentos. El sistema genera instantáneamente una **firma electrónica mediante Código QR**.

### 💊 Para el Farmacéutico
- **Escáner Óptico de Validación:** Interfaz tipo "radar" que utiliza la cámara del celular para leer el Código QR de la receta del paciente.
- **Verificación Offline:** La receta completa (medicamentos, dosis, firma) está encriptada dentro del Código QR. La farmacia puede validar la autenticidad instantáneamente con respuestas de color:
  - 🟢 **Verde:** Receta válida para entrega.
  - 🟠 **Naranja:** Receta ya dispensada (previene entrega duplicada).
  - 🔴 **Rojo:** Receta expirada.

---

## 🚀 Estado del Proyecto (Roadmap Completado)

### Epic 1: Acceso y Triaje MVP ✅
- [x] Autenticación sin barreras (Login con teléfono + OTP).
- [x] Interfaz de triaje basada en iconografía y medidor gráfico de dolor.
- [x] Dashboard de triaje priorizado para médicos.

### Epic 2: Consultorio Virtual Optimizado ✅
- [x] Videollamadas integradas (WebRTC/Agora).
- [x] Monitoreo inteligente de conexión y degradación automática a modo audio.
- [x] Sala de espera virtual con actualización de turnos en tiempo real.
- [x] Panel médico con botones de "Admisión Directa" al consultorio virtual.

### Epic 3: Emisión y Control de Recetas Digitales ✅
- [x] Formularios de prescripción médica post-consulta.
- [x] Generación automática de firmas vía Código QR.
- [x] Distribución de recetas por WhatsApp/SMS nativo.
- [x] Guardado de receta en galería local (modo Offline).
- [x] Lector de QR para farmacéuticos con verificación de estado e historial.

---

## 🇧🇴 Desarrollado para Bolivia
QuickMed está adaptado a la realidad de conectividad del país. Optimizado para funcionar en redes inestables gracias a su degradación dinámica de video, y con un diseño de interfaz altamente visual que no requiere amplias habilidades tecnológicas. Todo el flujo ha sido testeado bajo altos estándares de aseguramiento de calidad (QA).

---
*QuickMed: Tecnología de vanguardia para humanizar el acceso a la salud.*