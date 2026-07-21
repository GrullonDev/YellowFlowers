/// Maps low-level exceptions/failures (Firestore errors, timeouts, socket
/// errors...) to short, warm, user-facing Spanish copy. Keeps raw
/// exception text (stack traces, package names) out of the UI, while
/// still giving the user an actionable next step.
String friendlyErrorMessage(Object error) {
  final text = error.toString().toLowerCase();

  if (text.contains('timeoutexception') || text.contains('timeout')) {
    return 'Esto está tardando más de lo normal. Revisa tu conexión '
        'e inténtalo de nuevo.';
  }

  if (text.contains('socketexception') ||
      text.contains('network') ||
      text.contains('unavailable') ||
      text.contains('failed host lookup') ||
      text.contains('no address associated')) {
    return 'Parece que no hay conexión a internet. Mostrando lo último '
        'guardado, si está disponible.';
  }

  if (text.contains('permission-denied') || text.contains('unauthenticated')) {
    return 'No pudimos acceder al contenido en este momento. '
        'Inténtalo de nuevo más tarde.';
  }

  return 'Algo no salió como esperábamos. Inténtalo de nuevo.';
}
