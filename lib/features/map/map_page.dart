// lib/features/map/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  final LatLng _initialCenter = const LatLng(40.4168, -3.7038); // Madrid

  // Estilos (teselas)
  final List<_TileStyle> _styles = const [
    _TileStyle(
      name: 'OSM Standard',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      attribution: '© OpenStreetMap contributors',
      subdomains: [],
      maxZoom: 19,
    ),
    _TileStyle(
      name: 'CyclOSM',
      urlTemplate: 'https://c.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
      attribution: '© CyclOSM & OpenStreetMap contributors',
      subdomains: [],
      maxZoom: 20,
    ),
    _TileStyle(
      name: 'OpenTopoMap',
      urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      attribution: '© OpenTopoMap (SRTM) & OpenStreetMap contributors',
      subdomains: ['a', 'b', 'c'],
      maxZoom: 17,
    ),
    // Si luego usas MapTiler (requiere key):
    // _TileStyle(
    //   name: 'MapTiler Streets',
    //   urlTemplate: 'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=TU_KEY',
    //   attribution: '© MapTiler © OpenStreetMap contributors',
    //   subdomains: [],
    //   maxZoom: 20,
    // ),
  ];
  int _styleIndex = 0;

  // Datos de sitios (para popups)
  final List<_Place> _places = [];
  final Map<Marker, _Place> _markerData = {};

  // Genera un marker y lo asocia a su _Place
  Marker _buildMarkerFor(_Place place) {
    final marker = Marker(
      point: place.point,
      width: 36,
      height: 36,
      child: const Icon(Icons.location_on, size: 36, color: Colors.red),
      rotate: false,
    );
    _markerData[marker] = place;
    return marker;
  }

  void _addPlaceAt(LatLng latlng) {
    final p = _Place(
      title: 'Punto ${_places.length + 1}',
      description: 'Lat: ${latlng.latitude.toStringAsFixed(5)}, '
          'Lng: ${latlng.longitude.toStringAsFixed(5)}',
      point: latlng,
    );
    setState(() {
      _places.add(p);
      _markerData[_buildMarkerFor(p)] = p; // el builder ya los vincula
    });
  }

  void _zoomIn() {
    final c = _mapController.camera;
    _mapController.move(c.center, c.zoom + 1);
  }

  void _zoomOut() {
    final c = _mapController.camera;
    _mapController.move(c.center, c.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    // markers actuales (derivados de _markerData)
    final markers = _markerData.keys.toList(growable: false);
    final style = _styles[_styleIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        actions: [
          // Selector de estilo
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _styleIndex,
                icon: const Icon(Icons.map),
                items: [
                  for (int i = 0; i < _styles.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(_styles[i].name),
                    ),
                ],
                onChanged: (i) {
                  if (i == null) return;
                  setState(() => _styleIndex = i);
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (tapPos, latlng) {
                _popupController.hideAllPopups();
                _addPlaceAt(latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: style.urlTemplate,
                userAgentPackageName: 'com.tripi.app', // cambia a tu id
                subdomains: style.subdomains,
              ),

              // Capa de marcadores + popups
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  popupController: _popupController,
                  markers: markers,
                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                  popupDisplayOptions: PopupDisplayOptions(
                    // Cerrar popup tocando fuera
                    snap: PopupSnap.mapCenter, // centra el mapa en el popup
                    builder: (BuildContext ctx, Marker marker) {
                      final place = _markerData[marker];
                      if (place == null) return const SizedBox.shrink();
                      return _PlacePopup(
                        place: place,
                        onDelete: () {
                          setState(() {
                            // quitar marker y place vinculados
                            _markerData.remove(marker);
                            _places.remove(place);
                          });
                          _popupController.hideAllPopups();
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Controles de zoom
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                _MapFab(icon: Icons.add, onPressed: _zoomIn),
                const SizedBox(height: 8),
                _MapFab(icon: Icons.remove, onPressed: _zoomOut),
              ],
            ),
          ),

          // Atribución (según estilo actual)
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(style.attribution, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ======= Modelos y widgets de apoyo =======

class _TileStyle {
  final String name;
  final String urlTemplate;
  final String attribution;
  final List<String> subdomains;
  final int maxZoom;

  const _TileStyle({
    required this.name,
    required this.urlTemplate,
    required this.attribution,
    required this.subdomains,
    required this.maxZoom,
  });
}

class _Place {
  final String title;
  final String description;
  final LatLng point;

  const _Place({
    required this.title,
    required this.description,
    required this.point,
  });
}

class _PlacePopup extends StatelessWidget {
  final _Place place;
  final VoidCallback onDelete;

  const _PlacePopup({required this.place, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text(place.description, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Aquí podrías navegar a un detalle, compartir, etc.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Acción de ejemplo')),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Abrir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _MapFab({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}

