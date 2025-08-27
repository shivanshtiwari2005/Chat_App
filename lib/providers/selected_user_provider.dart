import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedUserProvider extends ChangeNotifier {
  static const _kKey = 'selected_demo_user_uid';
  final SharedPreferences _prefs;

  SelectedUserProvider(this._prefs) {
    _selected = _prefs.getString(_kKey);
    _controller = StreamController<String?>.broadcast();
    _controller!.add(_selected);
  }

  String? _selected;
  StreamController<String?>? _controller;

  String? get selectedUserId => _selected;
  Stream<String?> get selectedUserStream => _controller!.stream;

  Future<String?> loadSelectedUserOnce() async {
    // already loaded from constructor; return it
    return _selected;
  }

  Future<void> setSelectedUser(String uid) async {
    _selected = uid;
    await _prefs.setString(_kKey, uid);
    _controller?.add(_selected);
    notifyListeners();
  }

  Future<void> clearSelectedUser() async {
    _selected = null;
    await _prefs.remove(_kKey);
    _controller?.add(_selected);
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }
}