import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _users => _db.collection('users');

  Stream<List<AppUser>> streamUsers() {
    return _users.orderBy('name').snapshots().map((snap) =>
        snap.docs.map((d) => AppUser.fromMap(d.data() as Map<String, dynamic>)).toList());
  }

  Stream<AppUser?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()! as Map<String, dynamic>);
    });
  }

  Future<void> upsertUser(AppUser u) async {
    await _users.doc(u.uid).set(u.toMap(), SetOptions(merge: true));
  }
}