/// Utilidades de formato para montos, fechas y tiempos relativos.
///
/// Evita dependencias externas (p.ej. `intl`): todo el formateo es manual.
library;

/// Formatea un monto como moneda Pesos Mexicanos (MXN): `$1,234,567.89` o `$1,234,567.89 MXN`.
String formatCurrency(num value, {int decimals = 2, bool showCode = false}) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final intPart = _groupThousands(parts[0]);
  final sign = negative ? '-' : '';
  final cents = parts.length > 1 ? '.${parts[1]}' : '';
  final suffix = showCode ? ' MXN' : '';
  return '$sign\$$intPart$cents$suffix';
}

/// Versión compacta para métricas: `$1.2M`, `$845K`, `$950`.
String formatCompactCurrency(num value) {
  if (value >= 1000000) {
    final m = value / 1000000;
    return '\$${m % 1 == 0 ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
  }
  if (value >= 10000) {
    final k = value / 1000;
    return '\$${k % 1 == 0 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K';
  }
  return formatCurrency(value, decimals: value % 1 == 0 ? 0 : 2);
}

const _monthsEs = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// Fecha corta en español: `24 ago 2026`.
String formatDateEs(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_monthsEs[local.month - 1]} ${local.year}';
}

/// Fecha y hora en español: `24 ago 2026 · 14:30`.
String formatDateTimeEs(DateTime date) {
  final local = date.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${formatDateEs(local)} · $hh:$mm';
}

/// Tiempo relativo en español: `hace 5 s`, `hace 12 min`, `hace 3 h`,
/// y fecha corta si supera 24 h.
String timeAgoEs(DateTime date) {
  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inSeconds < 60) return 'hace ${diff.inSeconds.clamp(0, 59)} s';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  return 'el ${formatDateEs(date)}';
}

/// Convierte un [Duration] a `HH:MM:SS`. Si es negativo o cero devuelve
/// `Finalizada`.
String formatCountdown(Duration remaining) {
  if (remaining.isNegative || remaining == Duration.zero) return 'Finalizada';
  final totalSeconds = remaining.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(hours)}:${two(minutes)}:${two(seconds)}';
}

String _groupThousands(String digits) {
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final posFromEnd = digits.length - i;
    buf.write(digits[i]);
    if (posFromEnd > 1 && (posFromEnd - 1) % 3 == 0) buf.write(',');
  }
  return buf.toString();
}
