import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_repository.dart';
import '../models/app_user.dart';
import '../providers/selected_user_provider.dart';
import '../utils/time_ago.dart';
import 'chat_screen.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<UserRepository>(context, listen: false);
    final sel = Provider.of<SelectedUserProvider>(context);
    final myUid = sel.selectedUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          if (myUid != null) Padding(padding: const EdgeInsets.all(8), child: Center(child: Text('Me: $myUid'))),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () async {
              await sel.clearSelectedUser();
              Navigator.of(context).pushReplacementNamed('/select');
            },
          )
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: repo.streamUsers(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final all = snap.data!;
          final others = all.where((u) => u.uid != myUid).toList();
          if (others.isEmpty) return const Center(child: Text('No other users. Seed users if empty.'));
          return ListView.builder(
            itemCount: others.length,
            itemBuilder: (c, i) {
              final u = others[i];
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(child: Text(u.name[0])),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: u.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(u.name),
                subtitle: Text(u.isOnline ? 'online' : lastSeenText(u.lastSeen)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(peer: u)));
                },
              );
            },
          );
        },
      ),
    );
  }
}