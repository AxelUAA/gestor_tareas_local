# Gestor de tareas local (SQLite + Drift)

Práctica de Programación de Dispositivos Móviles (UAA, 7.º semestre).
Aplicación Flutter que guarda tareas en una base **SQLite local**, sin servidor ni internet.

## Tecnología de persistencia elegida

- **Drift** (`drift`): consultas tipadas sobre SQLite, con consultas reactivas (`Stream`).
- **drift_flutter**: abre la base en cada plataforma con una sola llamada (`driftDatabase`):
  - Android / iOS / Windows / Linux / macOS: archivo SQLite nativo en la carpeta de documentos/soporte de la app.
  - Web: SQLite compilado a WebAssembly (`sqlite3.wasm`) y un worker (`drift_worker.js`),
    con almacenamiento en OPFS o IndexedDB según el navegador.
- **drift_dev + build_runner**: generan el código de la tabla (`*.g.dart`).

Se descartaron `sqflite` (no soporta web ni escritorio por sí solo) y `shared_preferences`
(no es una base de datos; la práctica lo prohíbe).

## Diseño de la tabla

| Columna      | Tipo SQLite | Notas                                     |
|--------------|-------------|-------------------------------------------|
| `id`         | INTEGER     | PRIMARY KEY AUTOINCREMENT (identificador) |
| `titulo`     | TEXT        | NOT NULL, 1–200 caracteres                |
| `completada` | INTEGER     | booleano (0/1), DEFAULT 0                 |

Cada registro se identifica por `id`, que SQLite asigna automáticamente.

## Estructura

```
lib/
  main.dart                 # abre la base al iniciar y la cierra en dispose()
  models/tarea.dart         # modelo (Drift lo usa como fila con @UseRowClass)
  data/database.dart        # tabla Tareas + AppDatabase (CRUD)
  data/database.g.dart      # generado por build_runner
  data/validacion.dart      # validación de títulos (vacíos, solo espacios, >200)
  screens/tareas_page.dart  # interfaz; escucha un Stream (consulta reactiva)
web/
  sqlite3.wasm              # SQLite compilado a WebAssembly (sqlite3 3.5.2)
  drift_worker.js           # worker de Drift (drift 2.35.4)
test/
  widget_test.dart          # la pantalla inicial abre sin errores
  database_test.dart        # INSERT/SELECT/UPDATE/DELETE y persistencia al reabrir el archivo
  validacion_test.dart      # validación de títulos y P5 desde la interfaz
```

La interfaz no consulta la base dentro de `build()`: el `Stream` de
`observarTareas()` se crea una vez en `initState()` y Drift lo vuelve a emitir
después de cada INSERT/UPDATE/DELETE.

## Cómo ejecutarlo

```bash
git clone <url-de-este-repositorio>
cd gestor_tareas_local
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenera database.g.dart (ya está incluido)
flutter analyze
flutter test
flutter run -d chrome        # web
flutter run -d windows       # escritorio (requiere Visual Studio con "Desktop development with C++")
flutter run -d <android-id>  # Android (requiere Android SDK)
```

### Archivos web
`sqlite3.wasm` y `drift_worker.js` deben coincidir con las versiones de
`sqlite3` y `drift` en `pubspec.lock`. Se descargaron de:

- https://github.com/simolus3/sqlite3.dart/releases (tag `sqlite3-3.5.2`, archivo `sqlite3.wasm`)
- https://github.com/simolus3/drift/releases (tag `drift-2.35.4`, archivo `drift_worker.js`)

Si se actualizan los paquetes, hay que descargar de nuevo ambos archivos.

## Dónde se guardan los datos

- Nativo: `gestor_tareas.sqlite` en la carpeta de documentos de la app (`path_provider`).
- Web: en Chrome se usó `sharedIndexedDb` (IndexedDB del origen). En modo incógnito
  o al borrar los datos del sitio, la base se pierde.

## Pruebas

| ID | Acción | Windows 11 (release) | Web (Chrome 158) |
|----|--------|----------------------|------------------|
| P1 | Agregar 3 tareas, cerrar y abrir | ✅ permanecen | ✅ permanecen |
| P2 | Marcar completada y reiniciar | ✅ se conserva | ✅ se conserva |
| P3 | Editar título y reiniciar | ✅ nuevo título | ✅ nuevo título |
| P4 | Eliminar y reiniciar | ✅ no reaparece | ✅ no reaparece |
| P5 | Título vacío / solo espacios | ✅ no se registra | ✅ no se registra |
| P6 | Recargar y cerrar/abrir pestaña | — | ✅ datos permanecen |

En Windows la base quedó en `Documentos\gestor_tareas.sqlite` (en este equipo,
`C:\Users\<usuario>\OneDrive\Documents\`, porque Documentos está sincronizado con OneDrive).

Pruebas automatizadas (`flutter test`, 11 pruebas): CRUD sobre SQLite en memoria,
persistencia real cerrando y reabriendo un archivo `.sqlite`, validación de títulos y
P5 desde la interfaz.

## Plataformas

| Plataforma | Estado |
|------------|--------|
| Web (Chrome) | Probada |
| Windows 11 (escritorio) | Probada |
| Android, iOS, Linux, macOS | Previstas (mismo código; `drift_flutter` elige la implementación) |
