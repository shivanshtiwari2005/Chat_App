import 'package:intl/intl.dart';

String lastSeenText(int? millis) {
  if (millis == null) return 'last seen: unknown';
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inMinutes < 1) return 'last seen just now';
  if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
  if (diff.inHours < 24) return 'last seen ${diff.inHours}h ago';
  final fmt = DateFormat('MMM d, h:mm a');
  return 'last seen ${fmt.format(dt)}';
}