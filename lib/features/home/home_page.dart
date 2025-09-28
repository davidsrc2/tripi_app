// lib/features/home/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A3D98), // azul noche
              Color(0xFF0B2E78),
              Color(0xFF0A2566),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // --- Estrellas de fondo (ligeras, fijas) ---
              const _StarsLayer(),

              // --- Cabecera Tripi ---
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Tripi',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Search bar ---
              Align(
                alignment: const Alignment(0, -0.78),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchBar(),
                ),
              ),

              // --- Planeta central ---
              Align(
                alignment: const Alignment(0, 0.05),
                child: _Planet(),
              ),
            ],
          ),
        ),
      ),

      // --- Barra de navegación inferior ---
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white.withOpacity(0.12),
          indicatorColor: Colors.white.withOpacity(0.25),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_filled), label: 'Inicio'),
            NavigationDestination(icon: Icon(Icons.group_rounded), label: 'Gente'),
            NavigationDestination(icon: Icon(Icons.celebration_rounded), label: 'Explora'),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

// ---------------- Widgets de la pantalla ----------------

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: TextField(
        readOnly: true, // de momento solo estilo
        onTap: () {
          // TODO: Navegar a pantalla de búsqueda si procede
        },
        decoration: InputDecoration(
          hintText: '¿Dónde vamos?',
          prefixIcon: const Icon(Icons.travel_explore_rounded),
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _Planet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tamaño del planeta adaptado a pantalla
    final size = MediaQuery.of(context).size;
    final diameter = size.width * 0.78; // aprox. como el mock

    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.2, -0.2),
          radius: 1.0,
          colors: [Color(0xFF2F6CF8), Color(0xFF1546C8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Brillo sutil
          Positioned(
            left: diameter * 0.14,
            top: diameter * 0.16,
            child: Container(
              width: diameter * 0.42,
              height: diameter * 0.42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          // Continentes estilizados (simplificados para no depender de assets)
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _ContinentsPainter(),
          ),
        ],
      ),
    );
  }
}

class _StarsLayer extends StatelessWidget {
  const _StarsLayer();

  @override
  Widget build(BuildContext context) {
    final stars = <Offset>[
      const Offset(24, 80),
      const Offset(120, 140),
      const Offset(200, 60),
      const Offset(300, 120),
      const Offset(40, 260),
      const Offset(260, 230),
      const Offset(90, 380),
      const Offset(320, 420),
      const Offset(30, 500),
      const Offset(220, 540),
    ];

    return LayoutBuilder(
      builder: (_, box) => Stack(
        children: [
          for (final p in stars)
            Positioned(
              left: (p.dx / 360) * box.maxWidth,
              top: (p.dy / 640) * box.maxHeight,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------- Painters (continentes simplificados) ----------------

class _ContinentsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Estas formas son abstractas para simular masas terrestres
    final w = size.width;
    final h = size.height;

    // Masa 1 (tipo África/Europa)
    final p1 = Path()
      ..moveTo(w * 0.58, h * 0.18)
      ..quadraticBezierTo(w * 0.75, h * 0.22, w * 0.70, h * 0.36)
      ..quadraticBezierTo(w * 0.62, h * 0.44, w * 0.58, h * 0.52)
      ..quadraticBezierTo(w * 0.50, h * 0.56, w * 0.45, h * 0.48)
      ..quadraticBezierTo(w * 0.48, h * 0.36, w * 0.58, h * 0.18)
      ..close();

    // Masa 2 (tipo América)
    final p2 = Path()
      ..moveTo(w * 0.22, h * 0.35)
      ..quadraticBezierTo(w * 0.28, h * 0.25, w * 0.38, h * 0.28)
      ..quadraticBezierTo(w * 0.35, h * 0.40, w * 0.28, h * 0.44)
      ..quadraticBezierTo(w * 0.22, h * 0.46, w * 0.22, h * 0.35)
      ..close();

    // Masa 3 (islas)
    final p3 = Path()
      ..addOval(Rect.fromCircle(center: Offset(w * 0.68, h * 0.64), radius: w * 0.06))
      ..addOval(Rect.fromCircle(center: Offset(w * 0.76, h * 0.70), radius: w * 0.035))
      ..addOval(Rect.fromCircle(center: Offset(w * 0.60, h * 0.68), radius: w * 0.03));

    canvas.drawPath(p1, paint);
    canvas.drawPath(p2, paint);
    canvas.drawPath(p3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
