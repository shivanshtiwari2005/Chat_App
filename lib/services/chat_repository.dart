import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

String chatIdFor(String a, String b) {
  final two = [a, b]..sort();
  return '${two[0]}_${two[1]}';
}

class ChatRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesColl(String a, String b) {
    final id = chatIdFor(a, b);
    return _db.collection('chats').doc(id).collection('messages');
  }

  Stream<List<Message>> messagesStream(String me, String peer) {
    return _messagesColl(me, peer)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Message.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> sendMessage({
    required String me,
    required String peer,
    required String text,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _messagesColl(me, peer).add({
      'senderId': me,
      'receiverId': peer,
      'text': text,
      'timestamp': now,
      'status': 'sent',
    });
  }

  Future<void> markDelivered({
    required String me, // recipient uid
    required String peer, // sender uid
    required String messageId,
  }) async {
    final doc = _messagesColl(me, peer).doc(messageId);
    await doc.update({'status': 'delivered'});
  }
}