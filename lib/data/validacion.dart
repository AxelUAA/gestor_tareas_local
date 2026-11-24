/// Longitud máxima permitida para el título (igual que en la tabla).
const int maxLongitudTitulo = 200;

/// Valida y normaliza un título. Regresa el título sin espacios sobrantes,
/// o lanza [ArgumentError] con un mensaje comprensible para el usuario.
String validarTitulo(String? entrada) {
  final titulo = (entrada ?? '').trim();
  if (titulo.isEmpty) {
    throw ArgumentError('El título no puede estar vacío.');
  }
  if (titulo.length > maxLongitudTitulo) {
    throw ArgumentError(
      'El título no puede tener más de $maxLongitudTitulo caracteres.',
    );
  }
  return titulo;
}
