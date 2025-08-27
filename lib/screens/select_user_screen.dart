import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_repository.dart';
import '../models/app_user.dart';
import '../providers/selected_user_provider.dart';

class SelectUserScreen extends StatelessWidget {
  const SelectUserScreen({Key? key}) : super(key: key);

  Future<void> _seedUsers(BuildContext context) async {
    final repo = Provider.of<UserRepository>(context, listen: false);
    final users = [
      AppUser(uid: 'u_alice', name: 'Alice', isOnline: false),
      AppUser(uid: 'u_bob', name: 'Bob', isOnline: false),
      AppUser(uid: 'u_cara', name: 'Cara', isOnline: false),
      AppUser(uid: 'u_dan', name: 'Dan', isOnline: false),
    ];
    for (final u in users) {
      await repo.upsertUser(u);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded dummy users')));
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<UserRepository>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose demo user')),
      body: StreamBuilder<List<AppUser>>(
        stream: repo.streamUsers(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.active && snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Seed dummy users'),
                    onPressed: () => _seedUsers(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Tap to seed if users are empty.')),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final u = list[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(u.name[0])),
                      title: Text(u.name),
                      subtitle: Text(u.uid),
                      onTap: () async {
                        await Provider.of<SelectedUserProvider>(context, listen: false).setSelectedUser(u.uid);
                        Navigator.of(context).pushReplacementNamed('/users');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}