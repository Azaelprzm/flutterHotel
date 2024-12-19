import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/hoteles_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/habitaciones_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Gestión Hotelera',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/hoteles': (context) => HotelesScreen(),
          '/habitaciones': (context) => HabitacionesScreen(),
          '/clientes': (context) => ClientesScreen(),
          '/reservas': (context) => ReservasScreen(),
        },
      ),
    );
  }
}
