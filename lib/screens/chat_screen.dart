import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../models/message.dart';
import '../services/chat_repository.dart';
import '../providers/selected_user_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final AppUser peer;
  const ChatScreen({Key? key, required this.peer}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ChatRepository>(context, listen: false);
    final sel = Provider.of<SelectedUserProvider>(context);
    final me = sel.selectedUserId;
    if (me == null) return const Scaffold(body: Center(child: Text('Select a user first')));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(child: Text(widget.peer.name[0])),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(widget.peer.isOnline ? 'online' : 'offline'),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: repo.messagesStream(me, widget.peer.uid),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snap.data!;
                // Mark delivered for messages where I'm the recipient and status == sent
                for (final m in msgs) {
                  if (m.receiverId == me && m.status == MessageStatus.sent) {
                    // Note: Using fire-and-forget to mark delivered
                    repo.markDelivered(me: m.receiverId, peer: m.senderId, messageId: m.id);
                  }
                }
                if (msgs.isEmpty) return const Center(child: Text('Say hi 👋'));
                // Scroll to bottom after a tiny delay
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) {
                    _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                  }
                });
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: msgs.length,
                  itemBuilder: (c, i) {
                    final m = msgs[i];
                    final isMe = m.senderId == me;
                    return MessageBubble(text: m.text, isMe: isMe, time: DateTime.fromMillisecondsSinceEpoch(m.timestamp), status: m.status);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Message'), onSubmitted: (_) => _send(me!, repo))),
                  IconButton(icon: const Icon(Icons.send), onPressed: () => _send(me!, repo)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String me, ChatRepository repo) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await repo.sendMessage(me: me, peer: widget.peer.uid, text: text);
    _controller.clear();
    await Future.delayed(const Duration(milliseconds: 120));
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }
}