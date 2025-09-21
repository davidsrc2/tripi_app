import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tripi_api.dart';
import '../auth/auth_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? me;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = TripiApi();
      final data = await api.me();
      setState(() => me = data);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripi'),
        actions: [
          IconButton(onPressed: () => auth.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: error != null
              ? Text('Error: $error', style: const TextStyle(color: Colors.red))
              : me == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('¡Hola ${me!['username'] ?? 'usuario'}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Email: ${me!['email'] ?? '-'}'),
                        const SizedBox(height: 24),
                        const Text('Aquí irán el feed, seguir/unfollow, etc.'),
                      ],
                    ),
        ),
      ),
    );
  }
}
