import 'package:flutter/material.dart';

/// ============================================================================
/// APP THEME - Tema completo para Hop Hop (Colectivos Universitarios)
/// ============================================================================
/// 
/// Este archivo define la identidad visual de la aplicación con soporte
/// completo para modo claro y oscuro. Los colores están optimizados para
/// transmitir confianza, dinamismo y accesibilidad para estudiantes.
///
/// PALETA DE COLORES:
/// - Primario: Azul vibrante (#0066FF) - Confianza y profesionalismo
/// - Secundario: Verde dinámico (#00D084) - Energía y movimiento
/// - Terciario: Naranja cálido (#FF6B35) - Juventud y dinamismo
/// - Neutros: Grises adaptables para ambos modos
///
/// ============================================================================

class AppTheme {
  // ============================================================================
  // COLORES BASE - Definición de la paleta principal
  // ============================================================================
  
  /// Color primario: Azul vibrante
  /// Usado en: botones principales, AppBar, elementos destacados
  /// Transmite: confianza, profesionalismo, seguridad
  static const Color _primaryColor = Color(0xFF0066FF); // Azul vibrante
  
  /// Color secundario: Verde dinámico
  /// Usado en: estados positivos, confirmaciones, elementos secundarios
  /// Transmite: movimiento, energía, éxito
  static const Color _secondaryColor = Color(0xFF00D084); // Verde dinámico
  
  /// Color terciario: Naranja cálido
  /// Usado en: alertas, llamadas a la acción, acentos
  /// Transmite: juventud, dinamismo, urgencia positiva
  static const Color _tertiaryColor = Color(0xFFFF6B35); // Naranja cálido

  // ============================================================================
  // MÉTODOS RESPONSIVOS - Adaptación a diferentes tamaños de pantalla
  // ============================================================================

  /// Obtiene el padding responsivo según el tamaño de la pantalla
  /// - Desktop (>1200px): 48px
  /// - Tablet (600-1200px): 24px
  /// - Mobile (<600px): 16px
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 48; // Desktop
    if (width > 600) return 24;  // Tablet
    return 16; // Mobile
  }

  /// Escala el tamaño de fuente según el dispositivo
  /// Mejora la legibilidad en tablets sin afectar mobile
  static TextTheme getResponsiveTextTheme(BuildContext context, TextTheme base) {
    final width = MediaQuery.of(context).size.width;
    final scaleFactor = width > 600 ? 1.1 : 1.0;
    
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: (base.displayLarge?.fontSize ?? 57) * scaleFactor,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: (base.displayMedium?.fontSize ?? 45) * scaleFactor,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: (base.displaySmall?.fontSize ?? 36) * scaleFactor,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: (base.headlineLarge?.fontSize ?? 32) * scaleFactor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: (base.headlineMedium?.fontSize ?? 28) * scaleFactor,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: (base.headlineSmall?.fontSize ?? 24) * scaleFactor,
      ),
    );
  }

  // ============================================================================
  // TEMA CLARO - Optimizado para luz natural
  // ============================================================================
  
  /// Tema claro con colores vibrantes y contraste óptimo
  /// Ideal para uso diurno y espacios bien iluminados
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      
      // ========================================================================
      // TIPOGRAFÍA - Fuentes y estilos de texto
      // ========================================================================
      fontFamily: 'Roboto', // Fuente moderna y legible
      textTheme: const TextTheme(
        // Títulos grandes - Para encabezados principales
        displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.3),
        displaySmall: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.2),
        
        // Encabezados - Para secciones y subtítulos
        headlineLarge: TextStyle(fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600),
        
        // Títulos - Para elementos de lista y cards
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontWeight: FontWeight.w500),
      ),
      
      // ========================================================================
      // APP BAR - Barra superior de la aplicación
      // ========================================================================
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0, // Sin sombra para diseño moderno
        scrolledUnderElevation: 2, // Sombra al hacer scroll
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.3,
        ),
      ),
      
      // ========================================================================
      // CARDS - Contenedores de contenido
      // ========================================================================
      cardTheme: CardTheme(
        elevation: 0, // Diseño plano moderno
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Bordes redondeados
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      
      // ========================================================================
      // BOTONES - Estilos para diferentes tipos de botones
      // ========================================================================
      
      /// Botones elevados - Acción principal
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      /// Botones con borde - Acciones secundarias
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      /// Botones rellenos - Acciones destacadas
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      /// Botones de texto - Acciones terciarias
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // ========================================================================
      // CAMPOS DE ENTRADA - Estilos para inputs y formularios
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
      
      // ========================================================================
      // CHIPS - Etiquetas y filtros
      // ========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.3),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // ========================================================================
      // DIVISORES - Líneas separadoras
      // ========================================================================
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),
      
      // ========================================================================
      // BARRA DE NAVEGACIÓN INFERIOR - Navegación principal
      // ========================================================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // ========================================================================
      // BOTÓN FLOTANTE - Acción principal flotante
      // ========================================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // ========================================================================
      // DIÁLOGOS - Ventanas modales
      // ========================================================================
      dialogTheme: DialogTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      
      // ========================================================================
      // SNACKBARS - Notificaciones flotantes
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // ========================================================================
      // LIST TILES - Elementos de lista
      // ========================================================================
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================================
  // TEMA OSCURO - Optimizado para uso nocturno
  // ============================================================================
  
  /// Tema oscuro con colores adaptados para reducir fatiga visual
  /// Ideal para uso nocturno y espacios con poca luz
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      
      // ========================================================================
      // TIPOGRAFÍA - Fuentes y estilos de texto (igual que tema claro)
      // ========================================================================
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.3),
        displaySmall: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.2),
        headlineLarge: TextStyle(fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontWeight: FontWeight.w500),
      ),
      
      // ========================================================================
      // APP BAR - Barra superior (adaptada para modo oscuro)
      // ========================================================================
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.3,
        ),
      ),
      
      // ========================================================================
      // CARDS - Contenedores (adaptados para modo oscuro)
      // ========================================================================
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      
      // ========================================================================
      // BOTONES - Estilos para modo oscuro
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(64, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // ========================================================================
      // CAMPOS DE ENTRADA - Inputs para modo oscuro
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
      
      // ========================================================================
      // CHIPS - Etiquetas para modo oscuro
      // ========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // ========================================================================
      // DIVISORES - Líneas para modo oscuro
      // ========================================================================
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      
      // ========================================================================
      // BARRA DE NAVEGACIÓN INFERIOR - Para modo oscuro
      // ========================================================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // ========================================================================
      // BOTÓN FLOTANTE - Para modo oscuro
      // ========================================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // ========================================================================
      // DIÁLOGOS - Para modo oscuro
      // ========================================================================
      dialogTheme: DialogTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      
      // ========================================================================
      // SNACKBARS - Para modo oscuro
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // ========================================================================
      // LIST TILES - Para modo oscuro
      // ========================================================================
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================================
  // UTILIDADES RESPONSIVAS - Helpers para breakpoints
  // ============================================================================

  /// Verifica si el dispositivo es móvil (<600px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Verifica si el dispositivo es tablet (600-1200px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Verifica si el dispositivo es desktop (>1200px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Obtiene el número de columnas para grids responsivos
  /// - Desktop: 3 columnas
  /// - Tablet: 2 columnas
  /// - Mobile: 1 columna
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 3;  // Desktop
    if (width >= 600) return 2;   // Tablet
    return 1;                      // Mobile
  }

  /// Obtiene el padding de pantalla según el dispositivo
  /// Asegura márgenes consistentes en todos los tamaños
  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
    if (width >= 600) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  /// Obtiene el ancho máximo del contenedor para centrar en pantallas grandes
  /// Previene que el contenido sea demasiado ancho en desktop
  static double getMaxContentWidth(BuildContext context) {
    return isDesktop(context) ? 1200 : double.infinity;
  }
}

