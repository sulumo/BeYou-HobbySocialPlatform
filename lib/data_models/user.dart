import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final bool? onboardingComplete; // optional
  final GeoPoint? lastLocation;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl = 'assets/user.jpg',
    this.onboardingComplete,
    this.lastLocation,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? 'assets/user.jpg',
      onboardingComplete: data.containsKey('onboarding_complete')
          ? data['onboarding_complete']
          : null,
      lastLocation: data['lastLocation'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (lastLocation != null) 'lastLocation': lastLocation,
    };
  }
}
