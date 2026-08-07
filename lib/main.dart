import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/clientes_screen.dart';
import 'screens/habitaciones_screen.dart';
import 'screens/home_screen.dart';
import 'screens/hoteles_screen.dart';
import 'screens/login_screen.dart';
import 'screens/reservas_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.restoreSession();
  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp(
        title: 'Gestión Hotelera',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const _SessionGate(),
          '/home': (context) => const _ProtectedScreen(child: HomeScreen()),
          '/hoteles': (context) =>
              const _ProtectedScreen(child: HotelesScreen()),
          '/habitaciones': (context) =>
              const _ProtectedScreen(child: HabitacionesScreen()),
          '/clientes': (context) =>
              const _ProtectedScreen(child: ClientesScreen()),
          '/reservas': (context) =>
              const _ProtectedScreen(child: ReservasScreen()),
        },
      ),
    );
  }
}

class _ProtectedScreen extends StatelessWidget {
  const _ProtectedScreen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return context.watch<AuthProvider>().isAuthenticated
        ? child
        : const LoginScreen();
  }
}

class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return context.watch<AuthProvider>().isAuthenticated
        ? const HomeScreen()
        : const LoginScreen();
  }
}
