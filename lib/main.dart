import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'data/auth_repository.dart';
import 'data/tripi_api.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart'; // <- puedes dejarlo importado para navegar tras login
import 'features/users/users_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TripiApp());
}

class TripiApp extends StatelessWidget {
  const TripiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => TripiApi()),
        ChangeNotifierProvider(
          create: (ctx) => AuthController(ctx.read<AuthRepository>(), ctx.read<TripiApi>()),
        ),
        ChangeNotifierProvider(create: (ctx) => UsersController(ctx.read<TripiApi>())),
      ],
      child: MaterialApp(
        title: 'Tripi',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0d6efd)),
        // 🔹 Siempre arranca en Login
        home: const LoginPage(),
      ),
    );
  }
}


