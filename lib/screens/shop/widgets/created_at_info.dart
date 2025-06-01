import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatedAtInfo extends StatelessWidget {
  final DateTime createdAt;

  const CreatedAtInfo({Key? key, required this.createdAt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM dd, yyyy').format(createdAt);
    final relativeTime = _getRelativeTime(createdAt);

    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$dateStr · $relativeTime',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  String _getRelativeTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week${diff.inDays ~/ 7 == 1 ? '' : 's'} ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} month${diff.inDays ~/ 30 == 1 ? '' : 's'} ago';

    return '${(diff.inDays / 365).floor()} year${diff.inDays ~/ 365 == 1 ? '' : 's'} ago';
  }
}
