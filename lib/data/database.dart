import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/tarea.dart';

part 'database.g.dart';

/// Tabla "tareas" en SQLite.
/// - id: INTEGER PRIMARY KEY AUTOINCREMENT
/// - titulo: TEXT NOT NULL (1 a 200 caracteres)
/// - completada: INTEGER 0/1 (Drift lo expone como bool)
@UseRowClass(Tarea)
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 200)();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  /// Constructor para pruebas: recibe cualquier ejecutor (p. ej. en memoria).
  AppDatabase(super.e);

  /// Base persistente real: archivo SQLite en nativo, WASM + OPFS/IndexedDB en web.
  AppDatabase.persistente()
      : super(
          driftDatabase(
            name: 'gestor_tareas',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  /// SELECT * FROM tareas ORDER BY id; como Stream para que la UI se
  /// actualice sola después de cada escritura.
  Stream<List<Tarea>> observarTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  Future<List<Tarea>> obtenerTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  /// INSERT INTO tareas (titulo) VALUES (?); regresa el id generado.
  Future<int> agregarTarea(String titulo) {
    return into(tareas).insert(TareasCompanion.insert(titulo: titulo));
  }
}
