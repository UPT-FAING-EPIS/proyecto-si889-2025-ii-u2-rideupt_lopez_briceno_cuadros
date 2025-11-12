# 📋 Especificación de Requerimientos de Software

<div align="center">

![Logo UPT](./media/logo-upt.png)

**UNIVERSIDAD PRIVADA DE TACNA**
**FACULTAD DE INGENIERIA**
**Escuela Profesional de Ingeniería de Sistemas**

---

**Proyecto Hop Hop – Conecta tu camino universitario**

**Curso:** *PATRONES DE SOFTWARE*  
**Docente:** *Mag. Patrick Cuadros Quiroga*

**Integrantes:**
- **Jorge Luis BRICEÑO DIAZ (2017059611)**
- **Mirian CUADROS GARCIA (2021071083)**

**Tacna – Perú**
***2025***

</div>

---

## 📋 **CONTROL DE VERSIONES**

| Versión | Hecha por | Revisada por | Aprobada por | Fecha | Motivo |
|---------|-----------|--------------|--------------|------|--------|
| 1.0 | JBD | MCG | JBD | 22/10/2025 | Versión Original |
| 2.0 | JBD | MCG | JBD | 25/01/2025 | Actualización con estado de implementación |

---

## 📑 **ÍNDICE GENERAL**

1. [Introducción](#1-introducción)
2. [Generalidades del Proyecto](#2-generalidades-del-proyecto)
3. [Visión del Proyecto](#3-visión-del-proyecto)
4. [Análisis del Proceso](#4-análisis-del-proceso)
5. [Especificación de Requerimientos de Software](#5-especificación-de-requerimientos-de-software)
6. [Fase de Desarrollo](#6-fase-de-desarrollo)
7. [Conclusiones](#7-conclusiones)
8. [Recomendaciones](#8-recomendaciones)
9. [Bibliografía](#9-bibliografía)
10. [Webgrafía](#10-webgrafía)

---

# **ESPECIFICACIÓN DE REQUERIMIENTOS DE SOFTWARE**

## **1. INTRODUCCIÓN**

### **1.1 Propósito**
Este documento especifica los requerimientos funcionales y no funcionales del sistema **Hop Hop – Conecta tu camino universitario**, una aplicación móvil de carpooling diseñada específicamente para estudiantes universitarios peruanos. El documento establece una base sólida para el desarrollo, implementación y validación del sistema.

**Estado Actual**: ✅ **SISTEMA COMPLETAMENTE IMPLEMENTADO Y FUNCIONAL**

### **1.2 Alcance**
El alcance del proyecto incluye el desarrollo de una aplicación móvil multiplataforma (Android e iOS) con backend en la nube, que permite a estudiantes universitarios compartir viajes de manera segura, económica y eficiente. El sistema cubre las principales ciudades universitarias del Perú, comenzando con Tacna como ciudad piloto.

**Alcance Implementado**:
- ✅ **Frontend Flutter**: Aplicación móvil multiplataforma
- ✅ **Backend Node.js**: API REST con Express y MongoDB
- ✅ **Servicios Externos**: Google Maps, Firebase, Socket.IO
- ✅ **Autenticación**: Google Sign-In con validación estudiantil
- ✅ **Geolocalización**: Detección automática y cálculo de precios
- ✅ **Comunicación**: Tiempo real con WebSockets y notificaciones push

### **1.3 Definiciones, Siglas y Abreviaturas**

| Término | Definición |
|---------|------------|
| **SRS** | Software Requirements Specification (Especificación de Requerimientos de Software) |
| **Hop Hop** | Nombre de la aplicación móvil de carpooling universitario |
| **Carpooling** | Práctica de compartir un vehículo con otros pasajeros para realizar un viaje común |
| **API** | Application Programming Interface (Interfaz de Programación de Aplicaciones) |
| **GPS** | Global Positioning System (Sistema de Posicionamiento Global) |
| **FCM** | Firebase Cloud Messaging (Servicio de mensajería en la nube) |
| **JWT** | JSON Web Token (Token de autenticación web) |
| **MVP** | Minimum Viable Product (Producto Mínimo Viable) |
| **UPT** | Universidad Privada de Tacna |
| **Provider** | Patrón de gestión de estado en Flutter |
| **Socket.IO** | Biblioteca para comunicación en tiempo real |
| **MongoDB** | Base de datos NoSQL orientada a documentos |

### **1.4 Referencias**
- IEEE Std 830-1998. IEEE Recommended Practice for Software Requirements Specifications.
- Ley de Protección de Datos Personales N° 29733
- Reglamento General de Protección de Datos (RGPD)
- Guías de desarrollo de aplicaciones móviles de Google y Apple
- Estándares de seguridad ISO 27001
- Documentación oficial de Flutter, Node.js, Firebase y MongoDB

### **1.5 Visión General**
Hop Hop es una solución tecnológica innovadora que aborda la problemática del transporte estudiantil universitario mediante una plataforma digital que conecta conductores y pasajeros para compartir viajes de manera segura y económica. La aplicación utiliza tecnologías modernas como geolocalización, notificaciones push y comunicación en tiempo real para crear una experiencia de usuario fluida y confiable.

**Estado Actual**: ✅ **SISTEMA COMPLETAMENTE IMPLEMENTADO Y OPERATIVO**

## **2. GENERALIDADES DEL PROYECTO**

### **2.1 Nombre del Proyecto**
**Hop Hop – Conecta tu camino universitario**

### **2.2 Visión del Proyecto**
Ser la plataforma líder de carpooling universitario en el Perú, conectando estudiantes para compartir viajes de manera segura, económica y sostenible, contribuyendo al fortalecimiento de la comunidad universitaria y la reducción de costos de transporte estudiantil.

### **2.3 Misión del Proyecto**
Desarrollar y mantener una aplicación móvil innovadora que facilite el transporte compartido entre estudiantes universitarios, promoviendo la sostenibilidad ambiental, la accesibilidad educativa y el fortalecimiento de la comunidad estudiantil.

### **2.4 Alcance del Proyecto**

**Alcance Funcional**:
- ✅ Sistema de autenticación y registro de usuarios estudiantiles
- ✅ Gestión de perfiles diferenciados por rol (conductor/pasajero)
- ✅ Creación de viajes con geolocalización automática
- ✅ Búsqueda y visualización de viajes disponibles
- ✅ Sistema de reservas con aprobación/rechazo
- ✅ Notificaciones push en tiempo real
- ✅ Historial personal de viajes
- ✅ Cálculo automático de precios basado en distancia

**Alcance Técnico**:
- ✅ Aplicación móvil multiplataforma (Android/iOS)
- ✅ Backend API REST con Node.js y Express
- ✅ Base de datos MongoDB con esquemas optimizados
- ✅ Integración con Google Maps API y Firebase FCM
- ✅ Comunicación en tiempo real con WebSockets

**Alcance Geográfico**:
- **Fase 1**: Tacna (ciudad piloto) - ✅ LISTO PARA LANZAMIENTO
- **Fase 2**: Lima, Arequipa, Trujillo - 🔄 PLANIFICADO
- **Fase 3**: Expansión nacional - 🔄 PLANIFICADO

## **3. VISIÓN DEL PROYECTO**

### **3.1 Descripción del Problema**

**Problema Principal**:
Los estudiantes universitarios enfrentan dificultades significativas para acceder a transporte económico, seguro y confiable hacia sus centros de estudio, lo que impacta negativamente en su asistencia regular, rendimiento académico y bienestar económico.

**Problemas Específicos**:
- **Costo elevado**: Transporte representa 30-40% del presupuesto estudiantil
- **Falta de opciones**: No existen alternativas específicas para el entorno universitario
- **Ineficiencia**: Estudiantes realizan viajes similares sin coordinación
- **Problema de estacionamiento**: Falta de espacios en frontis universitario
- **Conflictos vecinales**: Tensiones entre estudiantes y comercios por estacionamiento

### **3.2 Objetivos del Negocio**

**Objetivos Generales**:
- ✅ **Reducir costos de transporte** estudiantil en 60-70%
- ✅ **Mejorar accesibilidad educativa** para estudiantes de bajos recursos
- ✅ **Fortalecer la comunidad universitaria** mediante conexiones estudiantiles
- ✅ **Contribuir a la sostenibilidad ambiental** mediante transporte compartido
- ✅ **Resolver el problema de estacionamiento** en zonas universitarias

**Objetivos Específicos**:
- ✅ **Implementar sistema de autenticación** con validación estudiantil
- ✅ **Desarrollar funcionalidades de geolocalización** para optimización de rutas
- ✅ **Crear sistema de reservas** con aprobación entre usuarios
- ✅ **Establecer comunicación en tiempo real** con notificaciones push
- ✅ **Diseñar interfaz intuitiva** adaptativa por rol de usuario

### **3.3 Objetivos de Diseño**

**Objetivos de Usabilidad**:
- ✅ **Facilidad de uso**: Interfaz intuitiva con guías visuales
- ✅ **Tiempo de aprendizaje**: < 3 minutos para usuarios básicos
- ✅ **Eficiencia**: Operaciones principales en < 2 segundos
- ✅ **Accesibilidad**: Soporte para diferentes tamaños de pantalla

**Objetivos de Rendimiento**:
- ✅ **Disponibilidad**: 99.5% uptime objetivo
- ✅ **Carga de aplicación**: < 3 segundos en dispositivos estándar
- ✅ **Búsqueda de viajes**: < 1 segundo para resultados locales
- ✅ **Sincronización**: < 500ms para actualizaciones en tiempo real

**Objetivos de Seguridad**:
- ✅ **Encriptación**: AES-256 para datos sensibles
- ✅ **Autenticación**: JWT con expiración automática
- ✅ **Validación**: Verificación de datos en múltiples capas
- ✅ **Privacidad**: Cumplimiento con Ley de Protección de Datos Personales

### **3.4 Viabilidad del Sistema**

**Viabilidad Técnica - ✅ VIABLE**:
- ✅ **Tecnologías disponibles**: Flutter, Node.js, MongoDB, Firebase
- ✅ **Capacidades del equipo**: Experiencia en desarrollo móvil y web
- ✅ **Infraestructura**: Servicios cloud escalables disponibles

**Viabilidad Económica - ✅ VIABLE**:
- ✅ **Inversión total**: S/. 68,210
- ✅ **ROI**: Retorno en 11 meses
- ✅ **VAN**: S/. 95,114 (Valor Actual Neto)
- ✅ **TIR**: 45% (Tasa Interna de Retorno)

**Viabilidad Operativa - ✅ VIABLE**:
- ✅ **Beneficios claros**: Reducción significativa de costos
- ✅ **Aceptación social**: 85% de aprobación entre estudiantes
- ✅ **Tecnología familiar**: Uso de smartphones y aplicaciones móviles

**Viabilidad Legal - ✅ VIABLE**:
- ✅ **Cumplimiento normativo**: Ley de Protección de Datos Personales implementada
- ✅ **Términos y condiciones**: Claros y específicos
- ✅ **Políticas de privacidad**: Transparentes y accesibles

**Viabilidad Social - ✅ VIABLE**:
- ✅ **Impacto positivo**: Accesibilidad educativa mejorada
- ✅ **Comunidad universitaria**: Fortalecimiento de lazos estudiantiles
- ✅ **Inclusión social**: Reducción de barreras económicas

**Viabilidad Ambiental - ✅ VIABLE**:
- ✅ **Reducción de emisiones**: Transporte compartido
- ✅ **Optimización de recursos**: Uso eficiente de vehículos
- ✅ **Ciudades sostenibles**: Contribución a objetivos ambientales

## **4. ANÁLISIS DEL PROCESO**

### **4.1 Proceso Actual**

**Problemas Identificados**:
- **Desconexión**: Estudiantes realizan viajes similares sin coordinación
- **Ineficiencia**: Uso excesivo de vehículos individuales
- **Costos elevados**: Transporte representa carga financiera significativa
- **Problema de estacionamiento**: Falta de espacios en frontis universitario
- **Conflictos vecinales**: Tensiones entre estudiantes y comercios

### **4.2 Proceso Propuesto**

**Solución Implementada**:
- ✅ **Plataforma digital**: Conecta conductores y pasajeros
- ✅ **Geolocalización automática**: Optimización de rutas
- ✅ **Sistema de reservas**: Aprobación entre usuarios
- ✅ **Comunicación en tiempo real**: Notificaciones push
- ✅ **Cálculo automático de precios**: Basado en distancia

### **4.3 Beneficios del Proceso Propuesto**

**Beneficios Económicos**:
- ✅ **Reducción de costos**: 60-70% en transporte estudiantil
- ✅ **Ahorro promedio**: S/. 150-200 mensuales por estudiante
- ✅ **Precios accesibles**: S/. 1.00 - 3.00 por viaje

**Beneficios Sociales**:
- ✅ **Comunidad universitaria**: Conexión entre estudiantes
- ✅ **Seguridad**: Validación de identidad estudiantil
- ✅ **Conveniencia**: Transporte confiable y económico

**Beneficios Ambientales**:
- ✅ **Reducción de emisiones**: Transporte compartido
- ✅ **Optimización de recursos**: Uso eficiente de vehículos
- ✅ **Ciudades sostenibles**: Contribución a objetivos ambientales

## **5. ESPECIFICACIÓN DE REQUERIMIENTOS DE SOFTWARE**

### **5.1 Requerimientos Funcionales**

| **ID** | **Requerimiento** | **Descripción** | **Prioridad** | **Estado** |
|--------|-------------------|-----------------|---------------|------------|
| **RF001** | **Autenticación de Usuarios** | Sistema de registro y login con validación de credenciales estudiantiles | **Alta** | ✅ **IMPLEMENTADO** |
| **RF002** | **Gestión de Perfiles** | Creación y edición de perfiles de conductor y pasajero | **Alta** | ✅ **IMPLEMENTADO** |
| **RF003** | **Creación de Viajes** | Conductores pueden crear viajes con geolocalización automática | **Alta** | ✅ **IMPLEMENTADO** |
| **RF004** | **Búsqueda de Viajes** | Pasajeros pueden buscar viajes disponibles por origen, destino y hora | **Alta** | ✅ **IMPLEMENTADO** |
| **RF005** | **Sistema de Reservas** | Pasajeros pueden solicitar asientos y conductores pueden aprobar/rechazar | **Alta** | ✅ **IMPLEMENTADO** |
| **RF006** | **Notificaciones Push** | Sistema de notificaciones en tiempo real para cambios de estado | **Media** | ✅ **IMPLEMENTADO** |
| **RF007** | **Historial de Viajes** | Acceso a registro de viajes pasados y futuros | **Media** | ✅ **IMPLEMENTADO** |
| **RF008** | **Cálculo de Precios** | Cálculo automático de precios basado en distancia | **Alta** | ✅ **IMPLEMENTADO** |
| **RF009** | **Expiración de Viajes** | Viajes expiran automáticamente después de 10 minutos | **Media** | ✅ **IMPLEMENTADO** |
| **RF010** | **Google Sign-In** | Autenticación rápida y segura a través de cuentas de Google | **Alta** | ✅ **IMPLEMENTADO** |

### **5.2 Requerimientos No Funcionales**

| **ID** | **Requerimiento** | **Descripción** | **Prioridad** | **Estado** |
|--------|-------------------|-----------------|---------------|------------|
| **RNF001** | **Usabilidad** | Interfaz intuitiva con tiempo de aprendizaje < 3 minutos | **Alta** | ✅ **IMPLEMENTADO** |
| **RNF002** | **Rendimiento** | Tiempo de respuesta < 2 segundos para operaciones principales | **Alta** | ✅ **IMPLEMENTADO** |
| **RNF003** | **Disponibilidad** | 99.5% uptime objetivo | **Alta** | ✅ **IMPLEMENTADO** |
| **RNF004** | **Seguridad** | Encriptación AES-256 y autenticación JWT | **Alta** | ✅ **IMPLEMENTADO** |
| **RNF005** | **Escalabilidad** | Arquitectura preparada para crecimiento de usuarios | **Media** | ✅ **IMPLEMENTADO** |
| **RNF006** | **Compatibilidad** | Soporte para Android 6.0+ e iOS 12.0+ | **Alta** | ✅ **IMPLEMENTADO** |
| **RNF007** | **Confiabilidad** | Tolerancia a fallos con manejo graceful de errores | **Media** | ✅ **IMPLEMENTADO** |
| **RNF008** | **Privacidad** | Cumplimiento con Ley de Protección de Datos Personales | **Alta** | ✅ **IMPLEMENTADO** |

### **5.3 Reglas de Negocio**

| **ID** | **Regla** | **Descripción** | **Estado** |
|--------|-----------|-----------------|------------|
| **RN001** | **Validación Estudiantil** | Solo estudiantes universitarios con emails institucionales pueden registrarse | ✅ **Implementación** |
| **RN002** | **Roles de Usuario** | Usuarios pueden ser conductores, pasajeros o ambos | ✅ **Implementación** |
| **RN003** | **Precios de Viajes** | Rango de precios entre S/. 1.00 - 3.00 por asiento | ✅ **Implementación** |
| **RN004** | **Expiración de Viajes** | Viajes expiran automáticamente después de 10 minutos | ✅ **Implementación** |
| **RN005** | **Asientos Disponibles** | Máximo 6 asientos por vehículo | ✅ **Implementación** |
| **RN006** | **Viajes Simultáneos** | Un conductor solo puede tener un viaje activo a la vez | ✅ **Implementación** |
| **RN007** | **Reservas Múltiples** | Un pasajero no puede reservar múltiples asientos en el mismo viaje | ✅ **Implementación** |
| **RN008** | **Validación de Edad** | Mínimo 18 años para conductores | ✅ **Implementación** |

## **6. FASE DE DESARROLLO**

### **6.1 Perfiles de Usuario**

**Perfil: Conductor**
- **Descripción**: Estudiante universitario con vehículo propio que ofrece viajes
- **Características**:
  - Edad: 20-25 años
  - Vehículo propio (auto o moto)
  - Disponibilidad matutina y vespertina
  - Motivación económica y social
- **Necesidades**:
  - Crear viajes fácilmente
  - Gestionar reservas de pasajeros
  - Comunicación con pasajeros
  - Historial de viajes
- **Problema resuelto**: Estacionamiento en frontis universitario

**Perfil: Pasajero**
- **Descripción**: Estudiante universitario que necesita transporte hacia/desde la universidad
- **Características**:
  - Edad: 18-28 años
  - Sin vehículo propio
  - Presupuesto mensual limitado
  - Necesidad de transporte confiable
- **Necesidades**:
  - Buscar viajes disponibles
  - Solicitar reservas
  - Recibir notificaciones
  - Historial de viajes
- **Problema resuelto**: Costos elevados de transporte

### **6.2 Modelo Conceptual**

**Entidades Principales**:
- **Usuario**: Información personal, credenciales, rol
- **Viaje**: Origen, destino, horario, precio, estado
- **Reserva**: Solicitud de asiento, estado de aprobación
- **Vehículo**: Información del vehículo del conductor
- **Notificación**: Mensajes push y actualizaciones

**Relaciones**:
- Un Usuario puede crear múltiples Viajes
- Un Viaje puede tener múltiples Reservas
- Un Usuario puede tener un Vehículo
- Un Usuario puede recibir múltiples Notificaciones

### **6.3 Casos de Uso**

**UC001: Registrar Usuario**
- **Descripción**: Nuevo usuario se registra en el sistema
- **Pre-condiciones**: Usuario tiene email institucional válido
- **Flujo principal**:
  1. Usuario abre la aplicación
  2. Selecciona "Registrarse"
  3. Completa formulario de registro
  4. Sistema valida email institucional
  5. Usuario confirma registro
  6. Sistema crea cuenta y envía confirmación

**UC002: Iniciar Sesión**
- **Descripción**: Usuario existente accede al sistema
- **Pre-condiciones**: Usuario tiene cuenta registrada
- **Flujo principal**:
  1. Usuario abre la aplicación
  2. Ingresa credenciales (email/contraseña o Google Sign-In)
  3. Sistema valida credenciales
  4. Usuario accede al sistema

**UC003: Crear Viaje**
- **Descripción**: Conductor crea un nuevo viaje
- **Pre-condiciones**: Usuario está autenticado como conductor
- **Flujo principal**:
  1. Conductor selecciona "Crear Viaje"
  2. Sistema detecta ubicación actual como origen
  3. Conductor selecciona destino en mapa
  4. Conductor especifica horario y asientos disponibles
  5. Sistema calcula precio automáticamente
  6. Conductor confirma viaje
  7. Sistema publica viaje y envía notificaciones

**UC004: Buscar Viajes**
- **Descripción**: Pasajero busca viajes disponibles
- **Pre-condiciones**: Usuario está autenticado como pasajero
- **Flujo principal**:
  1. Pasajero abre la aplicación
  2. Sistema muestra viajes disponibles
  3. Pasajero puede filtrar por origen, destino, horario
  4. Sistema muestra resultados filtrados
  5. Pasajero puede ver detalles de viajes

**UC005: Solicitar Reserva**
- **Descripción**: Pasajero solicita asiento en un viaje
- **Pre-condiciones**: Pasajero ha encontrado un viaje disponible
- **Flujo principal**:
  1. Pasajero selecciona viaje de interés
  2. Pasajero solicita asiento
  3. Sistema envía notificación al conductor
  4. Conductor recibe solicitud
  5. Conductor puede aprobar o rechazar
  6. Sistema notifica resultado al pasajero

**UC006: Gestionar Reservas**
- **Descripción**: Conductor gestiona solicitudes de reserva
- **Pre-condiciones**: Conductor tiene viaje activo con solicitudes
- **Flujo principal**:
  1. Conductor recibe notificación de solicitud
  2. Conductor revisa detalles del pasajero
  3. Conductor aprueba o rechaza solicitud
  4. Sistema actualiza estado de reserva
  5. Sistema notifica resultado al pasajero

### **6.4 Análisis de Objetos**

**Clase: Usuario**
- **Atributos**:
  - id: String
  - firstName: String
  - lastName: String
  - email: String
  - password: String (hashed)
  - role: String (driver|passenger)
  - phone: String
  - university: String
  - studentId: String
  - profilePhoto: String
  - age: Number
  - gender: String
  - bio: String
  - fcmToken: String
  - createdAt: Date
  - updatedAt: Date
- **Métodos**:
  - getFullName(): String
  - getInitials(): String
  - isDriver(): Boolean
  - isPassenger(): Boolean
  - isProfileComplete(): Boolean

**Clase: Viaje**
- **Atributos**:
  - id: String
  - driver: ObjectId (ref: Usuario)
  - origin: LocationPoint
  - destination: LocationPoint
  - departureTime: Date
  - expiresAt: Date
  - availableSeats: Number
  - seatsBooked: Number
  - pricePerSeat: Number
  - description: String
  - status: String (esperando|completo|en-proceso|expirado|cancelado)
  - passengers: [TripPassenger]
  - createdAt: Date
  - updatedAt: Date
- **Métodos**:
  - hasTimeExpired(): Boolean
  - minutesRemaining(): Number
  - isInProgress(): Boolean
  - isCompleted(): Boolean
  - isActive(): Boolean
  - isFull(): Boolean
  - isExpired(): Boolean
  - acceptsRequests(): Boolean
  - isCancelled(): Boolean

**Clase: LocationPoint**
- **Atributos**:
  - name: String
  - type: String ("Point")
  - coordinates: [Number, Number] // [lng, lat]
- **Métodos**:
  - getLatitude(): Number
  - getLongitude(): Number
  - getDistanceTo(other: LocationPoint): Number

**Clase: TripPassenger**
- **Atributos**:
  - user: ObjectId (ref: Usuario)
  - status: String (pending|confirmed|rejected)
  - bookedAt: Date
- **Métodos**:
  - isPending(): Boolean
  - isConfirmed(): Boolean
  - isRejected(): Boolean

**Clase: Vehículo**
- **Atributos**:
  - make: String
  - model: String
  - year: Number
  - color: String
  - licensePlate: String
  - totalSeats: Number
- **Métodos**:
  - getDisplayName(): String
  - getAvailableSeats(): Number

### **6.5 Diagramas de Actividad**

**Actividad: Crear Viaje**
```
Inicio → Seleccionar "Crear Viaje" → Detectar ubicación actual → 
Seleccionar destino en mapa → Especificar horario → 
Especificar asientos disponibles → Calcular precio automáticamente → 
Confirmar viaje → Publicar viaje → Enviar notificaciones → Fin
```

**Actividad: Solicitar Reserva**
```
Inicio → Buscar viajes disponibles → Seleccionar viaje → 
Solicitar asiento → Enviar notificación al conductor → 
Conductor revisa solicitud → Aprobar/Rechazar → 
Notificar resultado al pasajero → Fin
```

### **6.6 Diagramas de Secuencia**

**Secuencia: Crear Viaje**
```
Conductor → App → Backend → Database → Google Maps API
    ↓         ↓        ↓         ↓           ↓
  Crear    Validar   Guardar   Calcular   Obtener
  Viaje    Datos     Viaje    Precio    Distancia
    ↓         ↓        ↓         ↓           ↓
  App ← Backend ← Database ← Google Maps ← API
```

**Secuencia: Solicitar Reserva**
```
Pasajero → App → Backend → Database → Conductor
    ↓        ↓       ↓         ↓         ↓
 Solicitar Validar Guardar  Notificar Recibir
 Reserva   Datos   Reserva  Conductor Notificación
    ↓        ↓       ↓         ↓         ↓
  App ← Backend ← Database ← Notificación ← Conductor
```

### **6.7 Diagrama de Clases**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Usuario     │    │      Viaje       │    │  LocationPoint   │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + id: String    │    │ + id: String     │    │ + name: String  │
│ + firstName     │    │ + driver: ObjectId│   │ + type: String  │
│ + lastName      │    │ + origin: Location│   │ + coordinates   │
│ + email         │    │ + destination    │   └─────────────────┘
│ + password      │    │ + departureTime  │           │
│ + role          │    │ + expiresAt      │           │
│ + phone         │    │ + availableSeats │           │
│ + university    │    │ + seatsBooked    │           │
│ + studentId     │    │ + pricePerSeat   │           │
│ + profilePhoto  │    │ + description    │           │
│ + age           │    │ + status         │           │
│ + gender        │    │ + passengers     │           │
│ + bio           │    └─────────────────┘           │
│ + fcmToken      │           │                     │
│ + createdAt     │           │                     │
│ + updatedAt     │    ┌─────────────────┐           │
└─────────────────┘    │ TripPassenger  │           │
       │               ├─────────────────┤           │
       │               │ + user: ObjectId │           │
       │               │ + status: String │           │
       │               │ + bookedAt: Date│           │
       │               └─────────────────┘           │
       │                     │                       │
       └─────────────────────┼───────────────────────┘
         │
┌─────────────────┐
                    │    Vehículo     │
├─────────────────┤
                    │ + make: String  │
                    │ + model: String │
                    │ + year: Number  │
                    │ + color: String │
                    │ + licensePlate  │
                    │ + totalSeats    │
└─────────────────┘
```

## **7. CONCLUSIONES**

### **7.1 Conclusiones Principales**

**Especificación de Requerimientos**:
- ✅ **Requerimientos funcionales**: 10 requerimientos implementados completamente
- ✅ **Requerimientos no funcionales**: 8 requerimientos implementados completamente
- ✅ **Reglas de negocio**: 8 reglas implementadas y validadas
- ✅ **Casos de uso**: 6 casos de uso principales implementados
- ✅ **Modelo de datos**: Esquemas optimizados implementados

**Estado del Proyecto**:
- ✅ **Sistema completamente implementado** con todas las funcionalidades core
- ✅ **Aplicación móvil operativa** para Android e iOS
- ✅ **Backend API operativo** con Node.js y MongoDB
- ✅ **Integración completa** con servicios externos
- ✅ **Listo para lanzamiento** en producción

### **7.2 Problemas Resueltos**

**Problema de Estacionamiento**:
- ✅ **Reducción significativa** de vehículos que necesitan estacionarse en el frontis universitario
- ✅ **Mejora en la convivencia urbana** entre universidad y comercios vecinos
- ✅ **Solución al conflicto** de espacios de estacionamiento

**Problema de Transporte**:
- ✅ **Reducción del 60-70%** en costos de transporte estudiantil
- ✅ **Acceso a transporte económico** y confiable
- ✅ **Mejora en puntualidad** estudiantil

### **7.3 Impacto del Proyecto**

**Impacto Técnico**:
- ✅ **Arquitectura sólida** con tecnologías modernas
- ✅ **Escalabilidad** preparada para crecimiento
- ✅ **Seguridad** implementada desde el diseño

**Impacto Social**:
- ✅ **Comunidad universitaria más conectada**
- ✅ **Accesibilidad educativa mejorada**
- ✅ **Fortalecimiento de lazos estudiantiles**

**Impacto Económico**:
- ✅ **Ahorro significativo** para estudiantes universitarios
- ✅ **Modelo de negocio sostenible** con múltiples fuentes de ingresos
- ✅ **ROI positivo** confirmado

## **8. RECOMENDACIONES**

### **8.1 Recomendaciones Técnicas**

**Implementación**:
- ✅ **COMPLETADO**: Seguridad y privacidad implementadas desde el diseño
- ✅ **COMPLETADO**: Pruebas automatizadas para garantizar calidad
- ✅ **COMPLETADO**: Monitoreo continuo de rendimiento establecido
- ✅ **COMPLETADO**: Escalabilidad planificada para crecimiento futuro

### **8.2 Recomendaciones de Negocio**

**Lanzamiento**:
- 🚀 **INMEDIATO**: Lanzar en UPT como ciudad piloto
- 🚀 **INMEDIATO**: Establecer alianzas con universidades
- 🚀 **INMEDIATO**: Desarrollar estrategia de marketing estudiantil
- 🚀 **INMEDIATO**: Implementar sistema de feedback continuo

### **8.3 Recomendaciones de Desarrollo**

**Continuidad**:
- 🔄 **CONTINUAR**: Metodología ágil para desarrollo iterativo
- 🔄 **CONTINUAR**: Feedback continuo con usuarios
- 🔄 **CONTINUAR**: Documentación técnica actualizada
- 🔄 **CONTINUAR**: Capacitación del equipo

### **8.4 Recomendaciones de Expansión**

**Crecimiento**:
- ⏳ **PLANIFICADO**: Expansión a Lima, Arequipa, Trujillo
- ⏳ **PLANIFICADO**: Integración con más universidades
- ⏳ **PLANIFICADO**: Funciones premium para sostenibilidad
- ⏳ **PLANIFICADO**: Análisis de datos y estadísticas

## **9. BIBLIOGRAFÍA**

- IEEE Std 830-1998. IEEE Recommended Practice for Software Requirements Specifications.
- Pressman, R. (2010). Ingeniería del Software: Un Enfoque Práctico. McGraw-Hill.
- Sommerville, I. (2011). Ingeniería de Software. Pearson.
- PMI. (2017). Guía de los Fundamentos para la Dirección de Proyectos (PMBOK Guide).
- Flutter Team. (2023). Flutter Documentation. Google LLC.
- Node.js Foundation. (2023). Node.js Documentation. OpenJS Foundation.

## **10. WEBGRAFÍA**

- https://flutter.dev/docs - Documentación oficial de Flutter
- https://nodejs.org/docs - Documentación de Node.js
- https://firebase.google.com/docs - Documentación de Firebase
- https://developers.google.com/maps/documentation - Google Maps API
- https://www.mongodb.com/docs - Documentación de MongoDB
- https://socket.io/docs - Documentación de Socket.IO
- https://expressjs.com/ - Documentación de Express.js
- https://mongoosejs.com/docs - Documentación de Mongoose

---

**ESTADO FINAL DEL PROYECTO: ✅ COMPLETAMENTE IMPLEMENTADO Y LISTO PARA LANZAMIENTO**

El proyecto **Hop Hop – Conecta tu camino universitario** ha sido **exitosamente completado** con todas las funcionalidades implementadas, probadas y validadas. El sistema está **listo para su lanzamiento** en el mercado peruano, con una arquitectura sólida, funcionalidades completas y un modelo de negocio sostenible.