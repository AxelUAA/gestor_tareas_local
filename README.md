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
