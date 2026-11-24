import 'package:flutter/material.dart';

import 'data/database.dart';
import 'screens/tareas_page.dart';

void main() {
  runApp(const GestorTareasApp());
}

/// Punto de entrada de la aplicación.
/// Es dueña de la base de datos: la abre al iniciar y la cierra al destruirse.
class GestorTareasApp extends StatefulWidget {
  /// Permite inyectar una base (por ejemplo en memoria) para las pruebas.
  final AppDatabase? database;

  const GestorTareasApp({super.key, this.database});

  @override
  State<GestorTareasApp> createState() => _GestorTareasAppState();
}

class _GestorTareasAppState extends State<GestorTareasApp> {
  late final AppDatabase _db;
  late final bool _esPropia;

  @override
  void initState() {
    super.initState();
    _esPropia = widget.database == null;
    _db = widget.database ?? AppDatabase.persistente();
  }

  @override
  void dispose() {
    // Liberar la conexión SQLite solo si la abrimos aquí.
    if (_esPropia) _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(db: _db),
    );
  }
}
