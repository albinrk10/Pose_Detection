/// Fases biomecánicas de una flexión de pecho
enum ExerciseStage {
  /// Postura neutral o de espera (cuerpo alineado, brazos en extensión)
  neutral,

  /// Fase descendente / punto de flexión máxima alcanzado (pecho abajo)
  down,

  /// Retorno completado a extensión completa
  up,
}

/// Brazo corporal que se está rastreando según visibilidad/confianza
enum DetectedArm {
  left,
  right,
  none,
}
