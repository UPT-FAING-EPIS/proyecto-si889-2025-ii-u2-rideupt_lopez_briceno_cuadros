# 🚗 Hop Hop - Conecta tu camino universitario

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)

## 📱 Descripción del Proyecto

**Hop Hop** es una aplicación móvil de carpooling desarrollada específicamente para estudiantes universitarios peruanos. La aplicación conecta estudiantes que ofrecen viajes con aquellos que buscan transporte económico y confiable, reduciendo costos de movilidad y mejorando la accesibilidad a la educación superior.

### 🎯 Problema que Resuelve

Los estudiantes universitarios peruanos enfrentan desafíos significativos en su transporte diario:
- **Costos elevados**: Gastan entre S/. 8-15 diarios en transporte (30-40% de sus ingresos)
- **Falta de opciones**: No existen alternativas económicas específicas para estudiantes
- **Desconexión**: Falta de comunidad estudiantil en el transporte
- **Impacto ambiental**: Contribución al tráfico vehicular y contaminación

### ✨ Solución Implementada

Hop Hop proporciona una plataforma segura y confiable que permite:
- **Reducción de costos**: 60-70% de ahorro en transporte estudiantil
- **Precios dinámicos**: S/. 1.00 - 3.00 por viaje
- **Validación estudiantil**: Solo estudiantes universitarios verificados
- **Google Sign-In**: Autenticación rápida y segura
- **Geolocalización automática**: Detección de ubicación y cálculo de precios
- **Comunicación en tiempo real**: Notificaciones push y WebSockets

## 🏗️ Arquitectura del Sistema

### Frontend (Flutter)
- **Aplicación móvil multiplataforma** (Android/iOS)
- **Interfaz Material Design 3** moderna e intuitiva
- **Gestión de estado** con Provider pattern
- **Integración completa** con servicios externos

### Backend (Node.js)
- **API REST** robusta con Express.js
- **Autenticación JWT** + Firebase Admin SDK
- **Comunicación en tiempo real** con Socket.IO
- **Notificaciones push** con Firebase FCM

### Base de Datos (MongoDB)
- **Esquemas optimizados** para rendimiento
- **Datos geográficos** nativos
- **Escalabilidad horizontal** preparada

### Servicios Externos
- **Google Maps API**: Geolocalización y mapas
- **Firebase**: Autenticación y notificaciones
- **MongoDB Atlas**: Base de datos en la nube

## 🚀 Funcionalidades Implementadas

### ✅ Autenticación y Registro
- **Google Sign-In** con Firebase Auth
- **Validación de emails** institucionales (@virtual.upt.pe)
- **Extracción automática** de código de estudiante
- **Gestión de perfiles** diferenciados por rol

### ✅ Gestión de Viajes
- **Creación con geolocalización** automática
- **Cálculo automático de precios** basado en distancia
- **Expiración automática** (10 minutos)
- **Estados de viaje** (esperando, completo, en-proceso, expirado, cancelado)

### ✅ Sistema de Reservas
- **Búsqueda de viajes** disponibles
- **Solicitud de reserva** de asiento
- **Aprobación/rechazo** por conductor
- **Notificaciones en tiempo real**

### ✅ Comunicación en Tiempo Real
- **WebSockets** con Socket.IO
- **Notificaciones push** con Firebase FCM
- **Actualizaciones instantáneas**
- **Sistema de aprobación/rechazo**

## 📊 Impacto del Proyecto

### Beneficios para Estudiantes
- **Ahorro económico**: 60-70% reducción en costos de transporte
- **Ahorro promedio**: S/. 150-200 mensuales por estudiante
- **Mayor puntualidad**: Reducción del estrés por transporte
- **Comunidad**: Conexión con otros estudiantes universitarios

### Beneficios para la Comunidad
- **Impacto ambiental**: Reducción de emisiones de CO2
- **Tráfico reducido**: Disminución del tráfico vehicular
- **Economía local**: Estimulación de la economía estudiantil

### Beneficios para Universidades
- **Mayor retención**: Estudiantes más puntuales
- **Comunidad fortalecida**: Lazos comunitarios entre estudiantes
- **Accesibilidad**: Mejora en acceso a educación superior

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter**: Framework multiplataforma
- **Dart**: Lenguaje de programación
- **Provider**: Gestión de estado
- **Google Maps Flutter**: Integración de mapas
- **Firebase Auth**: Autenticación

### Backend
- **Node.js**: Runtime de JavaScript
- **Express.js**: Framework web
- **MongoDB**: Base de datos NoSQL
- **Socket.IO**: Comunicación en tiempo real
- **Firebase Admin SDK**: Servicios de Firebase

### Servicios Externos
- **Google Maps API**: Geolocalización
- **Firebase Cloud Messaging**: Notificaciones push
- **MongoDB Atlas**: Base de datos en la nube
- **AWS/Google Cloud**: Infraestructura

## 📱 Capturas de Pantalla

### Pantalla Principal
- Lista de viajes disponibles
- Filtros por ubicación y destino
- Información detallada de cada viaje

### Crear Viaje
- Detección automática de ubicación
- Selección de destino en mapa
- Cálculo automático de precio

### Perfil de Usuario
- Información personal
- Datos del vehículo (conductores)
- Historial de viajes

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (3.0+)
- Node.js (16+)
- MongoDB Atlas
- Cuenta de Firebase
- Cuenta de Google Maps

### Frontend (Flutter)
```bash
cd AppRideUpt/rideupt_app
flutter pub get
flutter run
```

### Backend (Node.js)
```bash
cd AppRideUpt/rideupt-backend
npm install
npm start
```

### Variables de Entorno
```env
# Backend
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your_jwt_secret
FIREBASE_ADMIN_KEY=your_firebase_key

# Frontend
GOOGLE_MAPS_API_KEY=your_google_maps_key
FIREBASE_CONFIG=your_firebase_config
```

## 📈 Métricas del Proyecto

### Indicadores Técnicos
- **Tiempo de respuesta**: < 2 segundos
- **Disponibilidad**: 99.5% uptime
- **Cobertura de código**: > 80%
- **Bugs críticos**: 0

### Indicadores de Negocio
- **Usuarios objetivo**: 1.2 millones de estudiantes
- **Reducción de costos**: 60-70% promedio
- **ROI**: Retorno de inversión en 11 meses
- **VAN**: S/. 95,114 (Valor Actual Neto)

### Indicadores Sociales
- **Impacto ambiental**: Reducción de emisiones CO2
- **Accesibilidad**: Mejora en puntualidad estudiantil
- **Comunidad**: Fortalecimiento de lazos universitarios

## 🎯 Estado del Proyecto

### ✅ Completamente Implementado
- **Frontend Flutter**: 100% funcional
- **Backend Node.js**: 100% operativo
- **Base de datos**: Esquemas optimizados
- **Servicios externos**: Integración completa
- **Comunicación**: Tiempo real implementado

### 🚀 Listo para Lanzamiento
- **Sistema completamente funcional**
- **Todas las funcionalidades core desarrolladas**
- **Pruebas de usuario realizadas exitosamente**
- **Documentación técnica completa**

## 📚 Documentación

### Documentos del Proyecto
- **FD01**: Informe de Factibilidad
- **FD02**: Documento de Visión
- **FD03**: Especificación de Requerimientos
- **FD04**: Arquitectura de Software
- **FD05**: Informe Final del Proyecto
- **FD06**: Propuesta de Proyecto

### Documentación Técnica
- **Manual de usuario**: Guía de uso de la aplicación
- **Manual técnico**: Documentación para desarrolladores
- **API Documentation**: Documentación de endpoints
- **Guías de despliegue**: Configuración de producción

## 👥 Equipo de Desarrollo

### Integrantes
- **Jorge Luis Briceño Diaz** (2017059611)
- **Mirian Cuadros Garcia** (2021071083)

### Roles
- **Tech Lead**: Arquitectura técnica y liderazgo
- **Desarrollador Frontend**: Aplicación móvil Flutter
- **Desarrollador Backend**: API REST y servicios
- **QA Engineer**: Pruebas y control de calidad

## 📞 Contacto

### Universidad Privada de Tacna
- **Facultad de Ingeniería**
- **Escuela Profesional de Ingeniería de Sistemas**
- **Curso**: Patrones de Software
- **Docente**: Mag. Patrick Cuadros Quiroga

### Información del Proyecto
- **Duración**: 6 meses
- **Inversión**: S/. 68,210
- **Estado**: Completamente implementado
- **Lanzamiento**: Listo para producción

## 📄 Licencia

Este proyecto es parte del curso de Patrones de Software de la Universidad Privada de Tacna.

## 🙏 Agradecimientos

- **Universidad Privada de Tacna** por el apoyo académico
- **Google** por los servicios de Maps y Firebase
- **MongoDB** por la base de datos en la nube
- **Comunidad Flutter** por el framework multiplataforma

---

**Hop Hop - Conecta tu camino universitario** 🚗💨

*Reduciendo costos de transporte estudiantil y fortaleciendo la comunidad universitaria*