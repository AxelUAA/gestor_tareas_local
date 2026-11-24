import 'dart:io';

import 'package:drift/drift.dart' show InvalidDataException;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/database.dart';

void main() {
  group('CRUD sobre SQLite (base en memoria)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('INSERT y SELECT: la tarea se guarda pendiente y con id', () async {
      final id = await db.agregarTarea('Estudiar Drift');
      final tareas = await db.obtenerTareas();
      expect(tareas, hasLength(1));
      expect(tareas.first.id, id);
      expect(tareas.first.titulo, 'Estudiar Drift');
      expect(tareas.first.completada, isFalse);
    });

    test('UPDATE de título y de estado', () async {
      final id = await db.agregarTarea('Original');
      await db.actualizarTitulo(id, 'Editado');
      await db.cambiarEstado(id, true);
      final tarea = (await db.obtenerTareas()).single;
      expect(tarea.titulo, 'Editado');
      expect(tarea.completada, isTrue);
    });

    test('DELETE por id solo borra esa tarea', () async {
      final a = await db.agregarTarea('A');
      await db.agregarTarea('B');
      await db.eliminarTarea(a);
      final titulos = (await db.obtenerTareas()).map((t) => t.titulo);
      expect(titulos, ['B']);
    });

    test('La tabla rechaza un título vacío', () async {
      expect(() => db.agregarTarea(''), throwsA(isA<InvalidDataException>()));
    });
  });

  test('Persistencia: los datos sobreviven a cerrar y reabrir el archivo',
      () async {
    final dir = await Directory.systemTemp.createTemp('tareas_test');
    final archivo = File('${dir.path}/tareas.sqlite');

    // Primera "ejecución": se agregan 3 tareas, se modifica y se borra.
    var db = AppDatabase(NativeDatabase(archivo));
    final id1 = await db.agregarTarea('Uno');
    final id2 = await db.agregarTarea('Dos');
    await db.agregarTarea('Tres');
    await db.cambiarEstado(id1, true);
    await db.actualizarTitulo(id2, 'Dos editada');
    await db.close();

    // Segunda "ejecución": se reabre el mismo archivo.
    db = AppDatabase(NativeDatabase(archivo));
    var tareas = await db.obtenerTareas();
    expect(tareas.map((t) => t.titulo), ['Uno', 'Dos editada', 'Tres']);
    expect(tareas.first.completada, isTrue);
    await db.eliminarTarea(id1);
    await db.close();

    // Tercera "ejecución": la tarea eliminada no reaparece.
    db = AppDatabase(NativeDatabase(archivo));
    tareas = await db.obtenerTareas();
    expect(tareas.map((t) => t.titulo), ['Dos editada', 'Tres']);
    await db.close();

    await dir.delete(recursive: true);
  });
}
