import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  final digits = size >= 10 || unit == 0 ? 0 : 1;
  return '${size.toStringAsFixed(digits)} ${units[unit]}';
}

String formatRelativeDate(DateTime date, [AppLocalizations? l10n]) {
  final now = DateTime.now();
  final local = date.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(local.year, local.month, local.day);
  final diff = today.difference(that).inDays;
  final time = DateFormat('HH:mm').format(local);
  if (diff == 0) return l10n?.todayAt(time) ?? 'Today, $time';
  if (diff == 1) return l10n?.yesterday ?? 'Yesterday';
  if (diff < 7) return DateFormat('EEEE', l10n?.isArabic == true ? 'ar' : 'en').format(local);
  return DateFormat('MMM d', l10n?.isArabic == true ? 'ar' : 'en').format(local);
}

String greetingFor(DateTime time, [AppLocalizations? l10n]) {
  if (l10n != null) return l10n.greeting(time);
  final hour = time.hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

String pageLabel(int count, [AppLocalizations? l10n]) {
  if (l10n != null) return l10n.pageLabel(count);
  return count == 1 ? '1 page' : '$count pages';
}
