import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HobbyProvider with ChangeNotifier {
  List<String> _selectedHobbies = [];

  List<String> get selectedHobbies => List.unmodifiable(_selectedHobbies);

  void setHobbies(List<String> hobbies) {
    _selectedHobbies = hobbies;
    notifyListeners();
  }

  void addHobby(String hobby) {
    if (!_selectedHobbies.contains(hobby)) {
      _selectedHobbies.add(hobby);
      notifyListeners();
    }
  }

  void removeHobby(String hobby) {
    if (_selectedHobbies.remove(hobby)) {
      notifyListeners();
    }
  }

  Future<void> loadHobbiesFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null && data['hobbies'] is List) {
      final List<String> hobbies = List<String>.from(data['hobbies']);
      _selectedHobbies = hobbies;
      notifyListeners();
    }
  }

  Future<void> saveHobbiesToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'hobbies': _selectedHobbies,
    }, SetOptions(merge: true));
    // print('Saved hobbies: $_selectedHobbies');
  }
}
