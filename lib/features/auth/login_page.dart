import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



enum _AuthView { welcome, signIn, signUp }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _AuthView _view = _AuthView.welcome;

  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _username = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();
    return Scaffold(
      body: Stack(
        children: [
          _BlueCloudBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _TripiTitle(),
                      const SizedBox(height: 8),
                      Text(
                        _view == _AuthView.welcome
                            ? '¡Bienvenido a Tripi!'
                            : (_view == _AuthView.signIn
                                ? '¡Qué alegría tenerte de vuelta!'
                                : '¡Crea tu cuenta y despega!'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_view == _AuthView.welcome) ...[
                        // Botón "Ya tengo cuenta ✌️"
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0d6efd),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () => setState(() => _view = _AuthView.signIn),
                            child: const Text('Ya tengo cuenta ✌️',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Botón "Únete a Tripi 🚀"
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70, width: 1.2),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => setState(() => _view = _AuthView.signUp),
                            child: const Text('¡Únete a Tripi 🚀!',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Social buttons
                        _SocialButtons(
                          onGoogle: ctrl.loading ? null : () => context.read<AuthController>().signInGoogle(),
                          onApple: ctrl.loading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Inicio con Apple próximamente 👀')),
                                  );
                                },
                        ),
                      ] else ...[
                        // FORM (login o registro)
                        if (_view == _AuthView.signUp) ...[
                          _Field(
                            controller: _username,
                            label: 'Usuario',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _Field(
                          controller: _email,
                          label: 'Email',
                          icon: Icons.mail,
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _pass,
                          label: 'Contraseña',
                          icon: Icons.lock,
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.blue.shade50),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (ctrl.error != null) ...[
                          Text(ctrl.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.yellowAccent)),
                          const SizedBox(height: 8),
                        ],

                        // Botón principal
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0d6efd),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: ctrl.loading
                                ? null
                                : () async {
                                    if (_view == _AuthView.signIn) {
                                      await context.read<AuthController>()
                                          .signInEmail(_email.text.trim(), _pass.text);
                                    } else {
                                      final uname = _username.text.trim().isEmpty
                                          ? (_email.text.contains('@')
                                              ? _email.text.split('@').first
                                              : _email.text)
                                          : _username.text.trim();
                                      await context.read<AuthController>().signUpAndRegisterBO(
                                            email: _email.text.trim(),
                                            password: _pass.text,
                                            username: uname,
                                          );
                                    }
                                  },
                            child: Text(
                              _view == _AuthView.signIn ? 'Iniciar sesión 🚀' : 'Crear cuenta 🚀',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Enlaces inferiores
                        if (_view == _AuthView.signIn)
                          TextButton(
                            onPressed: ctrl.loading ? null : () {},
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        TextButton(
                          onPressed: ctrl.loading
                              ? null
                              : () => setState(() => _view = _AuthView.welcome),
                          child: Text(
                            _view == _AuthView.signIn
                                ? '¿Aún no tienes cuenta? Crea una aquí'
                                : '¿Ya tienes cuenta? Inicia sesión',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),

                        const SizedBox(height: 18),
                        _SocialButtons(
                          onGoogle: ctrl.loading ? null : () => context.read<AuthController>().signInGoogle(),
                          onApple: ctrl.loading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Inicio con Apple próximamente 👀')),
                                  );
                                },
                        ),
                      ],

                      if (ctrl.loading) ...[
                        const SizedBox(height: 22),
                        const CircularProgressIndicator(color: Colors.white),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fondo azul con “nubes”
class _BlueCloudBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const blueTop = Color(0xFF2F7BFF);
    const blueBottom = Color(0xFF0d6efd);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [blueTop, blueBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: const [
          Positioned(left: 8, top: 60, child: _Cloud(size: 38, opacity: .95)),
          Positioned(right: 20, top: 120, child: _Cloud(size: 26, opacity: .9)),
          Positioned(left: 24, bottom: 110, child: _Cloud(size: 22, opacity: .9)),
          Positioned(right: 16, bottom: 40, child: _Cloud(size: 30, opacity: .95)),
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double size;
  final double opacity;
  const _Cloud({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(CupertinoIcons.cloud_fill, size: size, color: Colors.white),
    );
  }
}

class _TripiTitle extends StatelessWidget {
  const _TripiTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tripi',
      style: TextStyle(
        color: Colors.white,
        fontSize: 42,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        shadows: [
          Shadow(color: Colors.black.withOpacity(.25), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
    );
  }
}

/// Campo redondeado blanco con icono
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboard;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        prefixIcon: Icon(icon, color: const Color(0xFF0d6efd)),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

/// Botones sociales estilo pill
class _SocialButtons extends StatelessWidget {
  final VoidCallback? onApple;
  final VoidCallback? onGoogle;

  const _SocialButtons({this.onApple, this.onGoogle});

          @override
          Widget build(BuildContext context) {
            return Column(
              children: [
        _SocialButton(
          label: 'Inicia sesión con Apple',
          leading: const FaIcon(FontAwesomeIcons.apple, color: Colors.black),
          background: Colors.white,
          foreground: Colors.black87,
          onPressed: onApple,
        ),
        const SizedBox(height: 10),
        _SocialButton(
          label: 'Inicia sesión con Google',
          leading: const _GoogleG(),
          background: Colors.white,
          foreground: Colors.black87,
          onPressed: onGoogle,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget leading;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.leading,
    required this.background,
    required this.foreground,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        ),
        onPressed: onPressed,
        icon: leading,
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// “G” simple para evitar assets
class _GoogleG extends StatelessWidget {
  const _GoogleG();
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 10,
      backgroundColor: Colors.transparent,
      child: Text('G', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w800)),
    );
  }
}

