import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/database.dart';
import 'package:gestor_tareas_local/data/validacion.dart';
import 'package:gestor_tareas_local/main.dart';

void main() {
  group('validarTitulo', () {
    test('quita espacios sobrantes', () {
      expect(validarTitulo('  Comprar pan  '), 'Comprar pan');
    });

    test('rechaza vacío, solo espacios y null', () {
      for (final entrada in ['', '   ', '\t\n', null]) {
        expect(() => validarTitulo(entrada), throwsArgumentError);
      }
    });

    test('rechaza títulos de más de $maxLongitudTitulo caracteres', () {
      expect(() => validarTitulo('a' * (maxLongitudTitulo + 1)),
          throwsArgumentError);
    });
  });

  testWidgets('P5: un título con solo espacios no se registra', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '    ');
    await tester.tap(find.text('Agregar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('El título no puede estar vacío.'), findsOneWidget);
    expect(await tester.runAsync(db.obtenerTareas), isEmpty);

    await tester.runAsync(db.close);
  });

  testWidgets('Agregar desde la interfaz muestra la tarea en la lista',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Entregar práctica');
    await tester.tap(find.text('Agregar tarea'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('Entregar práctica'), findsOneWidget);
    expect(find.text('Todavía no hay tareas guardadas'), findsNothing);

    await tester.runAsync(db.close);
  });
}
