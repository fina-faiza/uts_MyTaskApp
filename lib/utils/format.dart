const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

String formatDeadline(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_bulan[d.month - 1]} ${d.year}, $h:$m';
}

String sisaWaktu(DateTime d) {
  final diff = d.difference(DateTime.now());
  if (diff.isNegative) {
    final late = diff.abs();
    if (late.inDays >= 1) return 'Terlambat ${late.inDays} hari';
    if (late.inHours >= 1) return 'Terlambat ${late.inHours} jam';
    return 'Baru saja lewat';
  }
  if (diff.inDays >= 1) return '${diff.inDays} hari lagi';
  if (diff.inHours >= 1) return '${diff.inHours} jam lagi';
  return '${diff.inMinutes} menit lagi';
}
