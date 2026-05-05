import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quickmed/providers/auth_provider.dart';
import 'package:quickmed/ui/screens/login_screen.dart';

void main() {
  Widget createLoginScreen() {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('Muestra error si el campo está vacío', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Por favor, ingresa tu número'), findsOneWidget);
    });

    testWidgets('Muestra error si el número tiene menos de 8 dígitos', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField), '1234567');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('El número debe tener al menos 8 dígitos'), findsOneWidget);
    });

    testWidgets('No muestra error con un número válido', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField), '70000000');
      await tester.tap(find.byType(ElevatedButton));
      
      // Esperar a que el Future.delayed de 1.5s termine
      await tester.pumpAndSettle();

      expect(find.text('Por favor, ingresa tu número'), findsNothing);
      expect(find.text('El número debe tener al menos 8 dígitos'), findsNothing);
      expect(find.text('Número validado. (Próximamente: OTP)'), findsOneWidget);
    });
  });
}
