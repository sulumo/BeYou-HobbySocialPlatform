import 'package:cloud_firestore/cloud_firestore.dart';

class HobbyContentUploader {
  static Future<void> uploadSampleContent() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final List<Map<String, dynamic>> contents = [
      // Cars
      {
        'title': '5 Best Budget Sports Cars',
        'description': 'Explore these affordable sports cars.',
        'type': 'recommendation',
        'hobby': 'Cars',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcars_2.jpg?alt=media&token=fb51f522-74b2-431d-8988-9a25b7c4dc12',
        'metadata': {'horsepower': '250hp'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 27,
      },
      {
        'title': 'Modify Your First Car',
        'description': 'Challenge yourself to learn tuning basics.',
        'type': 'challenge',
        'hobby': 'Cars',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcars_4.jpg?alt=media&token=b21f89b0-fc28-4777-b08e-24b3a5a42f80',
        'metadata': {'toolsRequired': true},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 52,
      },
      {
        'title': 'Top Driving Routes',
        'description': 'Scenic roads to enjoy.',
        'type': 'tip',
        'hobby': 'Cars',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcars_3.jpg?alt=media&token=8fcaa761-bc9d-43d5-85c7-864c107c07e1',
        'metadata': {'location': 'France'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 79,
      },

      // Music
      {
        'title': 'Explore Classical Playlists',
        'description': 'Discover calming classical music.',
        'type': 'recommendation',
        'hobby': 'Music',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fmusic_1.jpg?alt=media&token=f0c747ab-ab23-456c-a068-5f06aa5b7945',
        'metadata': {'genre': 'Classical'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 102,
      },
      {
        'title': 'Create a 1-Minute Song',
        'description': 'Write and produce a 1-minute track.',
        'type': 'challenge',
        'hobby': 'Music',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fmusic_2.jpg?alt=media&token=4058d602-2f88-49c1-a8d7-808cbbb1cc53',
        'metadata': {'duration': '1 min'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 47,
      },
      {
        'title': 'Music Collaboration Tips',
        'description': 'How to co-create music with others online.',
        'type': 'tip',
        'hobby': 'Music',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fmusic_3.jpg?alt=media&token=32c8adc8-5b58-4e24-9680-21ac4d801be9',
        'metadata': {
          'tools': ['BandLab', 'Soundtrap'],
        },
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 64,
      },

      // Running
      {
        'title': 'Trail Running Routes Near You',
        'description': 'Find exciting trail routes to explore.',
        'type': 'recommendation',
        'hobby': 'Running',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Frunning_1.jpg?alt=media&token=e30de44b-4b14-44c6-b565-824bd71fb7a5',
        'metadata': {'distance': '5-10 km'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 143,
      },
      {
        'title': 'Run a 5k in 30 Days',
        'description': 'Challenge yourself with a beginner running plan.',
        'type': 'challenge',
        'hobby': 'Running',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Frunning_2.jpg?alt=media&token=bb7d3de5-19ce-482a-9c82-039173884145',
        'metadata': {'durationDays': 30},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 92,
      },
      {
        'title': 'Best Running Shoes',
        'description': 'Tips on choosing the right shoes.',
        'type': 'tip',
        'hobby': 'Running',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Frunning_3.jpg?alt=media&token=e40f690a-9d5d-4619-ac7d-75f069fe4e95',
        'metadata': {
          'brands': ['Nike', 'Adidas'],
        },
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 36,
      },

      // Traveling
      {
        'title': 'Top 10 Travel Destinations in Europe',
        'description': 'Must-visit places for travelers.',
        'type': 'recommendation',
        'hobby': 'Traveling',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Ftravel_1.jpg?alt=media&token=02a6ee03-ab99-431b-ae09-fef8662ea332',
        'metadata': {'continent': 'Europe'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 324,
      },
      {
        'title': 'Travel with a Budget Challenge',
        'description': 'Plan a 7-day trip under \$1000.',
        'type': 'challenge',
        'hobby': 'Traveling',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Ftravel_2.jpg?alt=media&token=8ccd9c61-da22-492d-82f4-6494b4be737b',
        'metadata': {'budgetUSD': 1000},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 78,
      },
      {
        'title': 'Packing Tips for Frequent Travelers',
        'description': 'How to pack light and smart.',
        'type': 'tip',
        'hobby': 'Traveling',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Ftravel_4.jpg?alt=media&token=91118e46-027c-40ae-8253-79cd9944f6cd',
        'metadata': {'tipCategory': 'Packing'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 134,
      },

      // Reading
      {
        'title': 'Top 5 Mystery Novels',
        'description': 'Books that keep you on the edge.',
        'type': 'recommendation',
        'hobby': 'Reading',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Freading_1.jpg?alt=media&token=334836a6-50ad-4248-bf71-68b9bb1f3267',
        'metadata': {'genre': 'Mystery'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 87,
      },
      {
        'title': 'Read a Book a Week',
        'description': 'Challenge yourself to read regularly.',
        'type': 'challenge',
        'hobby': 'Reading',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Freading_2.jpg?alt=media&token=e4f20262-6938-403d-b061-26cb2e2634af',
        'metadata': {'goal': '1 book/week'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 75,
      },
      {
        'title': 'Speed Reading Techniques',
        'description': 'Improve your reading speed and retention.',
        'type': 'tip',
        'hobby': 'Reading',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Freading_3.jpg?alt=media&token=7ab3076d-f34c-437e-ae6a-270f9466127e',
        'metadata': {
          'methods': ['Skimming', 'Chunking'],
        },
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 51,
      },

      // Swimming
      {
        'title': 'Best Pools in Your City',
        'description': 'Where to swim and relax.',
        'type': 'recommendation',
        'hobby': 'Swimming',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fswim_1.jpg?alt=media&token=d8a58443-bf9f-4a36-98b2-31c6f68beda0',
        'metadata': {'location': 'City Pools'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 143,
      },
      {
        'title': 'Swim 1 km Challenge',
        'description': 'Build up endurance to swim 1 kilometer.',
        'type': 'challenge',
        'hobby': 'Swimming',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fswim_2.jpg?alt=media&token=df5e22e6-e892-48e6-9b53-58427ab4bbd8',
        'metadata': {'distance': '1 km'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 49,
      },
      {
        'title': 'Improve Your Freestyle Stroke',
        'description': 'Tips for better technique.',
        'type': 'tip',
        'hobby': 'Swimming',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fswim_3.jpg?alt=media&token=c6ea2d03-fbf0-45d7-931c-b8fe127a3656',
        'metadata': {'focus': 'Technique'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 217,
      },

      // Cycling
      {
        'title': 'Top Cycling Routes',
        'description': 'Explore scenic cycling paths.',
        'type': 'recommendation',
        'hobby': 'Cycling',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcycling_1.jpg?alt=media&token=b2bc3a07-aae7-466a-b07d-300e80160e24',
        'metadata': {'distanceRange': '10-30 km'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 119,
      },
      {
        'title': 'Cycle 100 km in a Month',
        'description': 'Challenge to improve stamina.',
        'type': 'challenge',
        'hobby': 'Cycling',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcycling_2.jpg?alt=media&token=7f13406a-4168-4d27-887d-824e4c4207bb',
        'metadata': {'goalDistance': '100 km'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 88,
      },
      {
        'title': 'Maintain Your Bike',
        'description': 'Tips on cleaning and upkeep.',
        'type': 'tip',
        'hobby': 'Cycling',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcycling_3.jpg?alt=media&token=8dabf0ba-a308-48dd-bcba-325c4531f551',
        'metadata': {'toolsNeeded': true},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 120,
      },

      // Writing
      {
        'title': 'Daily Writing Prompts',
        'description': 'Stimulate creativity every day.',
        'type': 'recommendation',
        'hobby': 'Writing',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fwriting_1.jpg?alt=media&token=97149234-cb71-4227-b4ef-486ec8e5ba3f',
        'metadata': {'genre': 'Creative'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 37,
      },
      {
        'title': 'Write a Short Story',
        'description': 'Challenge yourself to write a story in a week.',
        'type': 'challenge',
        'hobby': 'Writing',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fwriting_2.jpg?alt=media&token=66adb2c3-dfdf-4743-bdbc-d7068a431ebd',
        'metadata': {'durationDays': 7},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 64,
      },
      {
        'title': 'Improve Your Grammar',
        'description': 'Tips and resources for better writing.',
        'type': 'tip',
        'hobby': 'Writing',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fwriting_3.jpg?alt=media&token=00e50a1f-f793-4280-8b8c-f03fd6498973m',
        'metadata': {
          'resources': ['Grammarly', 'Hemingway Editor'],
        },
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 73,
      },

      // Art
      {
        'title': 'Top Art Museums to Visit',
        'description': 'Discover world-class art museums.',
        'type': 'recommendation',
        'hobby': 'Art',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fart_1.jpg?alt=media&token=4c370a95-9823-40f8-b03c-e39e58b0ec38',
        'metadata': {'location': 'Global'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 156,
      },
      {
        'title': 'Create a Painting in a Week',
        'description': 'Art challenge to finish a painting.',
        'type': 'challenge',
        'hobby': 'Art',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fart_2.jpg?alt=media&token=6353b23d-765a-4c2b-b0be-8b0738bef4f5',
        'metadata': {'durationDays': 7},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 105,
      },
      {
        'title': 'Mixing Colors Guide',
        'description': 'Tips on color theory and mixing paints.',
        'type': 'tip',
        'hobby': 'Art',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fart_3.jpg?alt=media&token=11fa3834-5fd2-4c39-a325-8649a4ba1081',
        'metadata': {'colorTheory': true},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 94,
      },

      // Animals
      {
        'title': 'Top Pet Breeds for Families',
        'description': 'Recommendations for family pets.',
        'type': 'recommendation',
        'hobby': 'Animals',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fanimals_1.jpg?alt=media&token=55d35c24-d065-4937-87d5-702c2287559a',
        'metadata': {'petType': 'dog'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 142,
      },
      {
        'title': 'Volunteer at Animal Shelter',
        'description': 'Challenge to spend time helping animals.',
        'type': 'challenge',
        'hobby': 'Animals',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fanimals_2.jpg?alt=media&token=8cb54a18-5593-41f1-bd6d-235e5fa88bbd',
        'metadata': {'hoursGoal': 10},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 76,
      },
      {
        'title': 'Caring for Exotic Pets',
        'description': 'Tips on exotic pet care.',
        'type': 'tip',
        'hobby': 'Animals',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fanimals_3.jpg?alt=media&token=a554aa28-6586-4723-94d1-b3271f06c541',
        'metadata': {
          'petExamples': ['iguana', 'ferret'],
        },
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 68,
      },

      // Cooking
      {
        'title': 'Top 10 Easy Recipes',
        'description': 'Delicious meals for beginners.',
        'type': 'recommendation',
        'hobby': 'Cooking',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcooking_2.jpg?alt=media&token=bf3f283e-856c-4403-9947-4c363fe45e58',
        'metadata': {'difficulty': 'easy'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 136,
      },
      {
        'title': 'Cook a New Cuisine',
        'description': 'Challenge yourself to try a new cuisine this week.',
        'type': 'challenge',
        'hobby': 'Cooking',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcooking_1.jpg?alt=media&token=76339839-6c88-406a-a087-962eed5dd0f1',
        'metadata': {'cuisine': 'Thai'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 178,
      },
      {
        'title': 'Knife Skills 101',
        'description': 'Basic knife handling tips.',
        'type': 'tip',
        'hobby': 'Cooking',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fcooking_3.jpg?alt=media&token=2eaf87f3-f2fa-4f4d-95b6-2d3ae19174d5',
        'metadata': {
          'tools': ['chef knife'],
        },
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 34,
      },

      // Photo
      {
        'title': 'Best Cameras for Beginners',
        'description': 'Recommendations for new photographers.',
        'type': 'recommendation',
        'hobby': 'Photo',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fphoto_1.jpg?alt=media&token=2ef247e7-3b17-4392-b3dd-327a252fd8fe',
        'metadata': {'cameraType': 'DSLR'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 109,
      },
      {
        'title': '30-Day Photo Challenge',
        'description': 'Take a photo every day for 30 days.',
        'type': 'challenge',
        'hobby': 'Photo',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fphoto_2.jpg?alt=media&token=8e3b9170-8eed-4c61-a7ec-3eb0f610bb60',
        'metadata': {'durationDays': 30},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 154,
      },
      {
        'title': 'Composition Tips',
        'description': 'Improve your photo framing and composition.',
        'type': 'tip',
        'hobby': 'Photo',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/beyou-89241.firebasestorage.app/o/hobby_images%2Fphoto_3.jpg?alt=media&token=294c7de1-b4ae-4b1d-80b7-55412cd3bd5e',
        'metadata': {'focus': 'Rule of Thirds'},
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 98,
      },
    ];

    for (var content in contents) {
      await firestore.collection('hobbyContent').add(content);
    }
  }
}
