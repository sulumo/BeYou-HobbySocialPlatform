import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MessageUploader {
  static final groupIds = [
    '5rSUf4KLrCJskr4iBf6Z', // "Creative Writers Pohang"
    '6HRGxQC6VxoSREXayU66', // "Pohang Runners Club"
    'HG4vgc71FpVKnVsV1TR8', // "Pohang Foodies & Cooks"
    'IgT83QiKZIXFYOUTJWzD', // "Pohang Art & Creatives"
    'KnZNxQ96UjGwVmK5t7jf', // "Pohang Bookworms"
    'aVMcmkjBzn8OzOhwipqB', // "Music Lovers of Pohang"
    'eyfvjirXjYdgnS0edLNW', // "Pohang Travel Explorers"
    'wZ2s9mMyYQcK5NffFMHa', // "Cycling Buddies Pohang"
  ];

  static final users = [
    {
      'uid': 'user1',
      'name': 'Anaya Patel',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/65.jpg',
    },
    {
      'uid': 'user2',
      'name': 'Luis Fernandez',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
    },
    {
      'uid': 'user3',
      'name': 'Emeka Okafor',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/82.jpg',
    },
    {
      'uid': 'user4',
      'name': 'Leila Haddad',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/12.jpg',
    },
    {
      'uid': 'user5',
      'name': 'Noah Tanaka',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/41.jpg',
    },
    {
      'uid': 'user6',
      'name': 'Fatima Al-Mansoori',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/25.jpg',
    },
    {
      'uid': 'user7',
      'name': 'Mateo Rossi',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/56.jpg',
    },
    {
      'uid': 'user8',
      'name': 'Zainab Yusuf',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/88.jpg',
    },
  ];

  // Sample messages
  static final sampleMessages = [
    "Hey everyone! When is the next meetup?",
    "Just finished my latest project — excited to share!",
    "Anyone up for a weekend trip?",
    "Loved the last event, great discussions!",
    "Can someone recommend good resources?",
    "I'll bring snacks next time!",
    "Looking forward to meeting you all!",
    "What’s everyone working on these days?",
    "Let’s plan something fun for next month.",
    "Thanks for all the inspiration here!",
  ];

  static Future<void> uploadSampleMessages() async {
    final firestore = FirebaseFirestore.instance;
    final random = Random();

    for (var groupId in groupIds) {
      print('Uploading messages for group: $groupId');

      for (int i = 0; i < 5; i++) {
        // pick a random user
        final user = users[random.nextInt(users.length)];
        // pick a random message
        final text = sampleMessages[random.nextInt(sampleMessages.length)];

        await firestore
            .collection('groups')
            .doc(groupId)
            .collection('messages')
            .add({
              'senderId': user['uid'],
              'senderName': user['name'],
              'senderAvatar': user['avatarUrl'],
              'text': text,
              'timestamp': FieldValue.serverTimestamp(),
            });
      }
    }

    print('✅ Sample messages uploaded successfully!');
  }
}
