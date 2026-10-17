import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookmarkProvider with ChangeNotifier {
  final Set<String> _bookmarkedIds = {};

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  List<String> get bookmarks => _bookmarkedIds.toList();

  Future<void> loadBookmarks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .get();

    _bookmarkedIds
      ..clear()
      ..addAll(snapshot.docs.map((doc) => doc.id));

    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(id);

    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
      await docRef.delete();
    } else {
      _bookmarkedIds.add(id);
      await docRef.set({'bookmarkedAt': FieldValue.serverTimestamp()});
    }

    notifyListeners();
  }
}
