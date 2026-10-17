import 'package:cloud_firestore/cloud_firestore.dart';

class SampleGroupUploader {
  static final groups = [
    {
      'name': 'Pohang Runners Club',
      'avatarUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      'description':
          'Join us for morning runs and marathon training in Pohang!',
      'hobby': 'Running',
      'members': ['user3'], // Emeka Okafor
    },
    {
      'name': 'Pohang Foodies & Cooks',
      'avatarUrl':
          'https://images.unsplash.com/photo-1512058564366-c9e3b2f1e011',
      'description': 'A place to share recipes and cooking tips!',
      'hobby': 'Cooking',
      'members': ['user1', 'user6'], // Anaya Patel, Fatima Al-Mansoori
    },
    {
      'name': 'Cycling Buddies Pohang',
      'avatarUrl':
          'https://images.unsplash.com/photo-1502791451860-9ffb33d9f907',
      'description': 'Weekend cycling trips and long rides.',
      'hobby': 'Cycling',
      'members': ['user2', 'user5'], // Luis Fernandez, Noah Tanaka
    },
    {
      'name': 'Creative Writers Pohang',
      'avatarUrl':
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853',
      'description': 'Meet fellow writers and work on creative projects.',
      'hobby': 'Writing',
      'members': ['user3', 'user5'], // Emeka Okafor, Noah Tanaka
    },
    {
      'name': 'Pohang Art & Creatives',
      'avatarUrl':
          'https://images.unsplash.com/photo-1529101091764-c3526daf38fe',
      'description': 'For artists and creatives to collaborate.',
      'hobby': 'Art',
      'members': ['user4', 'user7'], // Leila Haddad, Mateo Rossi
    },
    {
      'name': 'Music Lovers of Pohang',
      'avatarUrl':
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d',
      'description': 'Share playlists, perform, or just chat about music.',
      'hobby': 'Music',
      'members': [
        'user2',
        'user6',
        'user8',
      ], // Luis Fernandez, Fatima Al-Mansoori, Zainab Yusuf
    },
    {
      'name': 'Pohang Travel Explorers',
      'avatarUrl':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      'description': 'For those who love exploring new destinations.',
      'hobby': 'Traveling',
      'members': ['user1', 'user8'], // Anaya Patel, Zainab Yusuf
    },
    {
      'name': 'Pohang Bookworms',
      'avatarUrl':
          'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f',
      'description': 'Discuss your favorite books and authors!',
      'hobby': 'Reading',
      'members': [
        'user1',
        'user4',
        'user7',
      ], // Anaya Patel, Leila Haddad, Mateo Rossi
    },
  ];

  static Future<void> uploadSampleGroups() async {
    final firestore = FirebaseFirestore.instance;

    for (var group in groups) {
      final docRef = firestore.collection('groups').doc();

      await docRef.set({
        'name': group['name'],
        'avatarUrl': group['avatarUrl'],
        'description': group['description'],
        'hobby': group['hobby'],
        'members': group['members'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    print('✅ Sample groups uploaded successfully!');
  }
}
