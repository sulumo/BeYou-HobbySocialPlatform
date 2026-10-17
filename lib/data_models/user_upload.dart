import 'package:cloud_firestore/cloud_firestore.dart';

class SampleUserUploader {
  static final users = [
    {
      'uid': 'user1',
      'name': 'Anaya Patel',
      'email': 'anaya.patel@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/65.jpg',
      'lastLocation': GeoPoint(36.063952, 129.375146),
      'hobbies': {
        'Traveling': {
          'interest':
              'I want to explore different regions and meet new people.',
          'goal': 'Visit all continents by age 40.',
        },
        'Cooking': {
          'interest': 'Trying new recipes and flavors excites me.',
          'goal': 'Master cuisines from 10 different countries.',
        },
        'Reading': {
          'interest': 'Books help me relax and expand my thinking.',
          'goal': 'Read 50 books each year.',
        },
      },
    },
    {
      'uid': 'user2',
      'name': 'Luis Fernandez',
      'email': 'luis.fernandez@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
      'lastLocation': GeoPoint(36.0195, 129.3460),
      'hobbies': {
        'Cars': {
          'interest': 'I admire car design and engineering.',
          'goal': 'Own and restore a vintage muscle car.',
        },
        'Music': {
          'interest': 'Listening to music is my daily therapy.',
          'goal': 'Learn to play the guitar fluently.',
        },
        'Cycling': {
          'interest': 'I enjoy long scenic bike rides.',
          'goal': 'Bike across a different country each summer.',
        },
      },
    },
    {
      'uid': 'user3',
      'name': 'Emeka Okafor',
      'email': 'emeka.okafor@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/82.jpg',
      'lastLocation': GeoPoint(36.0170, 129.3422),
      'hobbies': {
        'Writing': {
          'interest': 'Writing helps me express my ideas clearly.',
          'goal': 'Publish a fiction novel.',
        },
        'Animals': {
          'interest': 'I love caring for pets and wildlife.',
          'goal': 'Volunteer at an animal rescue center.',
        },
        'Running': {
          'interest': 'Running clears my mind and boosts energy.',
          'goal': 'Run a full marathon in under 4 hours.',
        },
      },
    },
    {
      'uid': 'user4',
      'name': 'Leila Haddad',
      'email': 'leila.haddad@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/12.jpg',
      'lastLocation': GeoPoint(36.079915, 129.398074),
      'hobbies': {
        'Art': {
          'interest': 'Art lets me express my emotions freely.',
          'goal': 'Host my first solo art exhibition.',
        },
        'Swimming': {
          'interest': 'I love the feeling of freedom in water.',
          'goal': 'Compete in an amateur swimming tournament.',
        },
        'Reading': {
          'interest': 'I enjoy escaping into fantasy novels.',
          'goal': 'Finish reading 100 classics.',
        },
      },
    },
    {
      'uid': 'user5',
      'name': 'Noah Tanaka',
      'email': 'noah.tanaka@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/41.jpg',
      'lastLocation': GeoPoint(36.0222, 129.3481),
      'hobbies': {
        'Photo': {
          'interest': 'Capturing candid moments is my passion.',
          'goal': 'Build a photo journal of 50 unique cities.',
        },
        'Cycling': {
          'interest': 'It’s my daily fitness and commuting choice.',
          'goal': 'Complete a 100km race.',
        },
        'Writing': {
          'interest': 'I enjoy writing personal essays.',
          'goal': 'Start a popular personal blog.',
        },
      },
    },
    {
      'uid': 'user6',
      'name': 'Fatima Al-Mansoori',
      'email': 'fatima.mansoori@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/25.jpg',
      'lastLocation': GeoPoint(36.029840, 129.370424),
      'hobbies': {
        'Animals': {
          'interest': 'Helping stray animals is close to my heart.',
          'goal': 'Open a small animal shelter someday.',
        },
        'Music': {
          'interest': 'Singing is a joyful escape for me.',
          'goal': 'Record a studio album.',
        },
        'Cooking': {
          'interest': 'I enjoy cooking for family and friends.',
          'goal': 'Start a small catering business.',
        },
      },
    },
    {
      'uid': 'user7',
      'name': 'Mateo Rossi',
      'email': 'mateo.rossi@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/56.jpg',
      'lastLocation': GeoPoint(36.067974, 129.378056),
      'hobbies': {
        'Cars': {
          'interest': 'I follow car racing events closely.',
          'goal': 'Attend a Formula 1 Grand Prix.',
        },
        'Reading': {
          'interest': 'History books fascinate me.',
          'goal': 'Write a nonfiction history book.',
        },
        'Art': {
          'interest': 'I sketch landscapes in my free time.',
          'goal': 'Sell my artwork online.',
        },
      },
    },
    {
      'uid': 'user8',
      'name': 'Zainab Yusuf',
      'email': 'zainab.yusuf@example.com',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/88.jpg',
      'lastLocation': GeoPoint(36.080930, 129.407870),
      'hobbies': {
        'Swimming': {
          'interest': 'It’s a relaxing and energizing activity.',
          'goal': 'Swim in the world’s five oceans.',
        },
        'Traveling': {
          'interest': 'Meeting new cultures excites me.',
          'goal': 'Travel to 30 countries before 30.',
        },
        'Music': {
          'interest': 'I create playlists for every mood.',
          'goal': 'Become a part-time DJ.',
        },
      },
    },
  ];

  static Future<void> uploadSampleUsers() async {
    final firestore = FirebaseFirestore.instance;

    for (var user in users) {
      final uid = user['uid'] as String;

      // Upload main user document
      await firestore.collection('users').doc(uid).set({
        'name': user['name'],
        'email': user['email'],
        'avatarUrl': user['avatarUrl'],
        'lastLocation': user['lastLocation'],
      });

      // Upload hobby details
      final hobbies = user['hobbies'] as Map<String, dynamic>;
      for (var entry in hobbies.entries) {
        final hobbyName = entry.key;
        final details = entry.value as Map<String, dynamic>;

        await firestore
            .collection('users')
            .doc(uid)
            .collection('hobby_details')
            .doc(hobbyName)
            .set(details);
      }
    }

    print('✅ Sample users uploaded successfully!');
  }
}
