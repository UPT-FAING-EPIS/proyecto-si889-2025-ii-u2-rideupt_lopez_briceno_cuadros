// lib/widgets/google_signin_button.dart
import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GoogleSignInButton extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSuccess;
  final Function(String)? onError;
  final String? customText;
  final bool isCompact;
  final GoogleSignInStyle style;

  const GoogleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
    this.customText,
    this.isCompact = false,
    this.style = GoogleSignInStyle.standard,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    // Animación de press
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _googleAuthService.signInWithGoogle();

      if (result == null) {
        // Usuario canceló
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Guardar el token en storage seguro
      if (result['token'] != null) {
        await _storage.write(key: 'token', value: result['token']);
        await _storage.write(key: 'userId', value: result['_id']);
        await _storage.write(key: 'userRole', value: result['role']);
      }

      // Feedback haptic (si está disponible)
      // HapticFeedback.lightImpact();

      if (widget.onSuccess != null && mounted) {
        widget.onSuccess!(result);
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      if (widget.onError != null && mounted) {
        widget.onError!(errorMessage);
      } else {
        if (mounted) {
          _showErrorSnackBar(errorMessage);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.style) {
      case GoogleSignInStyle.outlined:
        return _buildOutlinedButton(theme);
      case GoogleSignInStyle.filled:
        return _buildFilledButton(theme);
      case GoogleSignInStyle.icon:
        return _buildIconButton(theme);
      case GoogleSignInStyle.standard:
      return _buildStandardButton(theme);
    }
  }

  Widget _buildStandardButton(ThemeData theme) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: widget.isCompact ? 48 : 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : Colors.grey.shade300,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 12 : 4,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _handleGoogleSignIn,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? _buildLoadingIndicator()
                    : _buildButtonContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: widget.isCompact ? 48 : 56,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: theme.colorScheme.outline,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
      ),
    );
  }

  Widget _buildFilledButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: widget.isCompact ? 48 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _isLoading
                ? _buildLoadingIndicator(isLight: true)
                : _buildButtonContent(isLight: true),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGoogleSignIn,
          customBorder: const CircleBorder(),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : _buildGoogleLogo(32),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent({bool isLight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGoogleLogo(24),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            widget.customText ?? 'Continuar con Google',
            style: TextStyle(
              fontSize: widget.isCompact ? 15 : 16,
              fontWeight: FontWeight.w600,
              color: isLight ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator({bool isLight = false}) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLight ? Colors.white : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Conectando...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isLight ? Colors.white.withOpacity(0.9) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleLogo(double size) {
    return Image.asset(
      'assets/google_logo.png',
      height: size,
      width: size,
      errorBuilder: (context, error, stackTrace) {
        // SVG alternativo con colores de Google
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4285F4), // Google Blue
                Color(0xFFEA4335), // Google Red
                Color(0xFFFBBC05), // Google Yellow
                Color(0xFF34A853), // Google Green
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'G',
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Estilos disponibles para el botón de Google Sign-In
enum GoogleSignInStyle {
  /// Botón estándar blanco con borde (recomendado por Google)
  standard,

  /// Botón con borde pero sin relleno
  outlined,

  /// Botón con gradiente de color
  filled,

  /// Solo ícono circular (ideal para espacios reducidos)
  icon,
}
