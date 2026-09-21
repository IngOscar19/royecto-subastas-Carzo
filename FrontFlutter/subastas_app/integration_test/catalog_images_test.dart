import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:subastas_app/main.dart' as app;

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required Duration timeout,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (condition()) return;
  }
  fail('Timeout esperando condición: $timeout');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const email = 'it_probe@example.com';
  const password = 'probe1234';

  testWidgets(
    'catálogo carga las imágenes del backend en iOS',
    (tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      await _pumpUntil(
        tester,
        () =>
            find.byType(TextFormField).evaluate().isNotEmpty ||
            find.text('Catálogo de Subastas').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 20),
      );

      if (find.text('Catálogo de Subastas').evaluate().isEmpty) {
        await tester.enterText(find.byType(TextFormField).at(0), email);
        await tester.enterText(find.byType(TextFormField).at(1), password);
        await tester.tap(find.text('Iniciar sesión'));
        await _pumpUntil(
          tester,
          () => find.text('Catálogo de Subastas').evaluate().isNotEmpty,
          timeout: const Duration(seconds: 30),
        );
      }

      expect(
        find.text('Catálogo de Subastas'),
        findsOneWidget,
        reason: 'No se llegó al catálogo',
      );

      await _pumpUntil(
        tester,
        () => tester
            .widgetList<RawImage>(find.byType(RawImage))
            .any((r) => r.image != null),
        timeout: const Duration(seconds: 45),
      );

      final decoded = tester
          .widgetList<RawImage>(find.byType(RawImage))
          .where((r) => r.image != null)
          .length;
      final fallbacks = find.byIcon(Icons.directions_car).evaluate().length;
      debugPrint('IMAGES_DECODED=$decoded FALLBACKS=$fallbacks');
      expect(decoded, greaterThan(0),
          reason: 'Ninguna imagen del catálogo se descodificó');
      expect(fallbacks, 0,
          reason: 'Hay tarjetas mostrando el fallback en vez de la imagen');
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}