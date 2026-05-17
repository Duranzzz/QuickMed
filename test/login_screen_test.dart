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

      await tester.enterText(find.byType(TextFormField), '7123456'); // 7 dígitos
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('El número debe tener exactamente 8 dígitos'), findsOneWidget);
    });

    testWidgets('Muestra error si el número no empieza con 6 o 7', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField), '12345678'); // empieza con 1
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('El número debe empezar con 6 o 7'), findsOneWidget);
    });

    testWidgets('Acepta número válido boliviano que empieza con 7', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField), '70000000');
      await tester.tap(find.byType(ElevatedButton));

      await tester.pumpAndSettle();

      expect(find.text('Por favor, ingresa tu número'), findsNothing);
      expect(find.text('El número debe tener exactamente 8 dígitos'), findsNothing);
      expect(find.text('El número debe empezar con 6 o 7'), findsNothing);
    });

    testWidgets('Acepta número válido boliviano que empieza con 6', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.enterText(find.byType(TextFormField), '61234567');
      await tester.tap(find.byType(ElevatedButton));

      await tester.pumpAndSettle();

      expect(find.text('El número debe empezar con 6 o 7'), findsNothing);
    });
  });
}
