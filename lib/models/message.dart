enum MessageStatus { sent, delivered }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final int timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.status,
  });

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    final s = map['status'] as String? ?? 'sent';
    return Message(
      id: id,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String,
      timestamp: (map['timestamp'] as num).toInt(),
      status: s == 'delivered' ? MessageStatus.delivered : MessageStatus.sent,
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': timestamp,
        'status': status == MessageStatus.delivered ? 'delivered' : 'sent',
      };
}