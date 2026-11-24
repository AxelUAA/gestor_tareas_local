import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/validacion.dart';
import '../models/tarea.dart';

class TareasPage extends StatefulWidget {
  final AppDatabase db;

  const TareasPage({super.key, required this.db});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  /// El Stream se crea una sola vez aquí (no en build) para no repetir
  /// la consulta en cada reconstrucción de la interfaz.
  late final Stream<List<Tarea>> _tareas;

  @override
  void initState() {
    super.initState();
    _tareas = widget.db.observarTareas();
  }

  Future<void> _agregarTarea() async {
    final String titulo;
    try {
      titulo = validarTitulo(_tituloController.text);
    } on ArgumentError catch (e) {
      _mensaje(e.message.toString());
      return;
    }
    try {
      await widget.db.agregarTarea(titulo);
      _tituloController.clear();
    } catch (e) {
      _mensaje('No se pudo guardar la tarea: $e');
    }
  }

  void _alternarCompletada(Tarea tarea, bool completada) {
    _mensaje('Implementar actualización de tarea');
  }

  void _editarTarea(Tarea tarea) {
    _mensaje('Implementar edición de título');
  }

  void _eliminarTarea(Tarea tarea) {
    _mensaje('Implementar eliminación de tarea');
  }

  void _mensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              maxLength: maxLongitudTitulo,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _agregarTarea(),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Tarea>>(
                stream: _tareas,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al leer la base de datos:\n${snapshot.error}',
                          textAlign: TextAlign.center),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tareas = snapshot.data!;
                  if (tareas.isEmpty) {
                    return const Center(child: Text('Todavía no hay tareas guardadas'));
                  }
                  return ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) => _itemTarea(tareas[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemTarea(Tarea tarea) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: tarea.completada,
          onChanged: (valor) {
            if (valor != null) _alternarCompletada(tarea, valor);
          },
        ),
        title: Text(
          tarea.titulo,
          style: tarea.completada
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text('ID: ${tarea.id}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: () => _editarTarea(tarea),
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminarTarea(tarea),
            ),
          ],
        ),
      ),
    );
  }
}
