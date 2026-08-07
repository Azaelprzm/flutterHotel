import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movil_hotel/main.dart';
import 'package:movil_hotel/providers/auth_provider.dart';

void main() {
  testWidgets('muestra el formulario de inicio de sesión', (tester) async {
    await tester.pumpWidget(MyApp(authProvider: AuthProvider()));

    expect(find.text('Hotel Lux'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('valida los campos obligatorios del inicio de sesión',
      (tester) async {
    await tester.pumpWidget(MyApp(authProvider: AuthProvider()));

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });
}
