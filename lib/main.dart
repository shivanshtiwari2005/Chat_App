import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbauth;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/user_repository.dart';
import 'services/chat_repository.dart';
import 'services/presence_service.dart';
import 'models/app_user.dart';
import 'models/message.dart';
import 'screens/select_user_screen.dart';
import 'screens/users_list_screen.dart';
import 'screens/chat_screen.dart';
import 'providers/selected_user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Sign in anonymously for demo
  await fbauth.FirebaseAuth.instance.signInAnonymously();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<UserRepository>(create: (_) => UserRepository()),
        Provider<ChatRepository>(create: (_) => ChatRepository()),
        Provider<PresenceService>(create: (ctx) => PresenceService()),
        ChangeNotifierProvider<SelectedUserProvider>(
          create: (_) => SelectedUserProvider(prefs),
        ),
      ],
      child: const ChatApp(),
    ),
  );
}

class ChatApp extends StatefulWidget {
  const ChatApp({Key? key}) : super(key: key);
  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> with WidgetsBindingObserver {
  StreamSubscription<String?>? _selSub;
  PresenceService? _presence;
  SelectedUserProvider? _selProv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selProv ??= Provider.of<SelectedUserProvider>(context, listen: false);
    _presence ??= Provider.of<PresenceService>(context, listen: false);
    // Listen for selected user changes to start presence service
    _selSub ??= _selProv!.selectedUserStream.listen((uid) {
      if (uid != null && uid.isNotEmpty) {
        _presence!.start(uid);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = Provider.of<SelectedUserProvider>(context, listen: false).selectedUserId;
    if (uid == null) return;
    final presence = Provider.of<PresenceService>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      presence.setOnline(uid);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      presence.setOffline(uid);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _selSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Firebase Demo (Provider)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const RootRouter(),
      routes: {
        '/select': (_) => const SelectUserScreen(),
        '/users': (_) => const UsersListScreen(),
      },
    );
  }
}

class RootRouter extends StatelessWidget {
  const RootRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sel = Provider.of<SelectedUserProvider>(context);
    return FutureBuilder<String?>(
      future: sel.loadSelectedUserOnce(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final uid = snap.data;
        if (uid == null || uid.isEmpty) {
          return const SelectUserScreen();
        } else {
          return const UsersListScreen();
        }
      },
    );
  }
}