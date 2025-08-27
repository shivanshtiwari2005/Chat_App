import 'package:flutter/material.dart';
import '../models/message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.isMe,
    required this.time,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = DateFormat('h:mm a').format(time);
    final ticks = status == MessageStatus.delivered ? '✅✅' : '✅';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.indigo.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text),
            const SizedBox(height: 6),
            Text(isMe ? '$t  $ticks' : t, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}