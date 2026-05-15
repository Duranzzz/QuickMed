import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickmed/ui/screens/patient_call_setup_screen.dart';

void main() {
  Widget createTestableWidget() {
    return const MaterialApp(
      home: PatientCallSetupScreen(),
    );
  }

  group('PatientCallSetupScreen Widget Tests', () {
    testWidgets('Muestra el título de Sala de Consulta y el botón verde gigante', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());

      expect(find.text('Sala de Consulta'), findsOneWidget);
      expect(find.text('El médico está listo'), findsOneWidget);
      
      // Encontrar el botón por su texto
      final buttonTextFinder = find.text('ENTRAR A CONSULTA');
      expect(buttonTextFinder, findsOneWidget);

      // Verificar que el botón es un ElevatedButton
      final buttonFinder = find.ancestor(
        of: buttonTextFinder,
        matching: find.byType(ElevatedButton),
      );
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('Muestra indicador de carga al presionar el botón', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());

      final buttonFinder = find.byType(ElevatedButton);
      await tester.tap(buttonFinder);
      
      // Re-renderizamos para que inicie la animación (setState => _isLoading = true)
      await tester.pump();

      // Debería mostrar CircularProgressIndicator mientras carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Simulamos que el future termina (aunque en un test real sin mock de permisos se quedará colgado o lanzará error de platform channel)
      // Nota: Probar plugins nativos como permission_handler en testWidgets suele fallar por MissingPluginException 
      // si no se mockea el channel, así que no avanzamos el tiempo hasta el final del Future de permisos para este test básico de UI.
    });
  });
}
