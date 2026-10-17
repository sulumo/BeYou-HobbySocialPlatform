// File: hobby_content_extras_uploader.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class HobbyContentExtrasUploader {
  static Future<void> uploadExtras() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final hobbyContentSnapshot = await firestore
        .collection('hobbyContent')
        .get();

    final random = Random();

    // Some realistic usernames
    final List<Map<String, String>> users = [
      {
        'name': 'david_17',
        'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      },
      {
        'name': 'jessy_queen',
        'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      },
      {
        'name': 'mike_runner',
        'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
      },
      {
        'name': 'sofia_writes',
        'avatar': 'https://randomuser.me/api/portraits/women/50.jpg',
      },
      {
        'name': 'lucas_car_guy',
        'avatar': 'https://randomuser.me/api/portraits/men/65.jpg',
      },
      {
        'name': 'ella_music',
        'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
      },
      {
        'name': 'oliver_travels',
        'avatar': 'https://randomuser.me/api/portraits/men/12.jpg',
      },
      {
        'name': 'grace_swimmer',
        'avatar': 'https://randomuser.me/api/portraits/women/22.jpg',
      },
      {
        'name': 'ethan_cyclist',
        'avatar': 'https://randomuser.me/api/portraits/men/70.jpg',
      },
      {
        'name': 'mia_chef',
        'avatar': 'https://randomuser.me/api/portraits/women/30.jpg',
      },
    ];

    // Example comments per hobby
    final Map<String, List<String>> hobbyComments = {
      'Cars': [
        "Love these car picks! 🚗🔥",
        "I've driven one of these, super fun!",
        "Can't wait to try tuning my first car!",
      ],
      'Music': [
        "This playlist is amazing 🎶",
        "Gonna try making my first track!",
        "Anyone collabing? DM me 🎧",
      ],
      'Running': [
        "Just ran this trail last weekend 🏃‍♂️",
        "Great tips on shoes, thanks!",
        "Training for my first 5k! 🏅",
      ],
      'Traveling': [
        "I visited 3 of these places already ✈️",
        "Budget tips are gold 💰",
        "Can’t wait to plan my next trip!",
      ],
      'Reading': [
        "Mystery novels are my fav 🔍📚",
        "Adding these books to my list!",
        "Love speed reading techniques!",
      ],
      'Swimming': [
        "Tried this pool, so relaxing 🏊‍♀️",
        "1km swim challenge accepted!",
        "Great stroke tips, thank you!",
      ],
      'Cycling': [
        "Rode this route last month 🚴‍♀️",
        "Maintaining my bike now!",
        "Love these cycling tips!",
      ],
      'Writing': [
        "Just wrote 500 words today ✍️",
        "These prompts are so creative!",
        "Challenge accepted — writing this week!",
      ],
      'Art': [
        "Been to this museum! 🎨",
        "Mixing colors is tricky but fun",
        "Starting my painting challenge!",
      ],
      'Animals': [
        "I love dogs 🐶",
        "Volunteered last weekend — best experience!",
        "Thinking of adopting a pet!",
      ],
      'Cooking': [
        "Just tried recipe #3 — delicious! 🍳",
        "Knife skills are improving!",
        "Will cook Thai this week!",
      ],
      'Photo': [
        "Learning new composition tricks 📸",
        "Love my new DSLR!",
        "Doing this 30-day photo challenge!",
      ],
    };

    for (var doc in hobbyContentSnapshot.docs) {
      final contentId = doc.id;
      final data = doc.data();
      final hobby = data['hobby'] ?? '';
      final type = data['type'] ?? '';

      final commentsCollection = firestore
          .collection('hobbyContent')
          .doc(contentId)
          .collection('comments');

      // Upload 2-3 random comments
      final int numComments = 2 + random.nextInt(2); // 2 or 3
      final hobbyCommentTexts = hobbyComments[hobby] ?? ['Great content!'];

      for (int i = 0; i < numComments; i++) {
        final user = users[random.nextInt(users.length)];
        final commentText =
            hobbyCommentTexts[random.nextInt(hobbyCommentTexts.length)];

        await commentsCollection.add({
          'text': commentText,
          'createdBy': user['name'],
          'createdAt': FieldValue.serverTimestamp(),
          'avatar':
              user['avatar'], // optional, nice for displaying avatar with comment
        });
      }

      // If challenge, upload participants
      if (type == 'challenge') {
        final participantsCollection = firestore
            .collection('hobbyContent')
            .doc(contentId)
            .collection('participants');

        final int numParticipants = 2 + random.nextInt(2); // 2 or 3
        for (int i = 0; i < numParticipants; i++) {
          final user = users[random.nextInt(users.length)];
          final userId = user['name']!.replaceAll(' ', '_'); // simulate userId
          final progress = 10 + random.nextInt(91); // 10 - 100
          final status = progress >= 100 ? 'completed' : 'in_progress';

          await participantsCollection.doc(userId).set({
            'joinedAt': FieldValue.serverTimestamp(),
            'progress': progress,
            'status': status,
            'avatar': user['avatar'],
            'name': user['name'],
          });
        }
      }

      print('✅ Added extras for contentId: $contentId');
    }

    print('🎉 All extras uploaded!');
  }
}
