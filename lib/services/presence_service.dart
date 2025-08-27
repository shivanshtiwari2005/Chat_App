import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;

  DatabaseReference _statusRef(String uid) => _rtdb.ref('status/$uid');

  StreamSubscription<DatabaseEvent>? _connectedSub;

  void start(String uid) {
    // listen .info/connected
    final infoRef = _rtdb.ref('.info/connected');
    _connectedSub?.cancel();
    _connectedSub = infoRef.onValue.listen((event) async {
      final connected = event.snapshot.value == true;
      if (connected) {
        // ensure onDisconnect will set offline
        await _statusRef(uid).onDisconnect().set({
          'state': 'offline',
          'lastSeen': ServerValue.timestamp,
        });
        await setOnline(uid);
      } else {
        // will be handled by onDisconnect automatically
      }
    });
  }

  Future<void> setOnline(String uid) async {
    try {
      await _statusRef(uid).set({
        'state': 'online',
        'lastSeen': ServerValue.timestamp,
      });
    } catch (_) {}
    // mirror to firestore for convenient queries
    await _firestore.collection('users').doc(uid).set({
      'isOnline': true,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  Future<void> setOffline(String uid) async {
    try {
      await _statusRef(uid).set({
        'state': 'offline',
        'lastSeen': ServerValue.timestamp,
      });
    } catch (_) {}
    await _firestore.collection('users').doc(uid).set({
      'isOnline': false,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  void dispose() {
    _connectedSub?.cancel();
  }
}