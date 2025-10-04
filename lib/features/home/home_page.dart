// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import '../map/map_page.dart'; // Requiere lib/features/map/map_page.dart (flutter_map / OSM)

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Controlador del buscador
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Redibujar para mostrar/ocultar el botón de limpiar según haya texto
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Estrellas de fondo
              const _StarsLayer(),

              // Cabecera Tripi
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

              // Search bar
              Align(
                alignment: const Alignment(0, -0.78),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchBar(
                    controller: _searchCtrl,
                    onSubmitted: (q) {
                      // TODO: navegar a resultados
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Buscando: $q')),
                      );
                    },
                  ),
                ),
              ),

              // Planeta central clicable -> abre mapa
              Align(
                alignment: const Alignment(0, 0.05),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: _openMap,
                      child: const _Planet(),
                    ),
                    // Etiqueta "Explorar" para dar pista
                    Positioned(
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Explorar 🌍',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Barra de navegación inferior
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
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;

  const _SearchBar({this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        readOnly: false,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
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
          // botón de limpiar texto
          suffixIcon: (controller?.text.isNotEmpty ?? false)
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller?.clear(),
                )
              : null,
        ),
      ),
    );
  }
}

class _Planet extends StatelessWidget {
  const _Planet();

  @override
  Widget build(BuildContext context) {
    final d = MediaQuery.of(context).size.width * 0.78;
    return Image.asset(
      'assets/icons/globe.png',
      width: d,
      height: d,
      fit: BoxFit.contain,
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




