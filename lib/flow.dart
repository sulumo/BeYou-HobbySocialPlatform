import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/hobby_provider.dart';

class HobbyFlowPage extends StatefulWidget {
  const HobbyFlowPage({super.key});

  @override
  State<HobbyFlowPage> createState() => _HobbyFlowPageState();
}

class _HobbyFlowPageState extends State<HobbyFlowPage> {
  late final List<String> selectedHobbies;
  final Map<String, Map<String, String?>> _answers = {};

  final Map<String, Map<String, List<String>>> hobbyFields = {
    'Cars': {
      'Favorite Brand': ['Lamborghini', 'Tesla', 'BMW', 'Porsche', 'Ferrari'],
      'Driving Style': ['Cruising', 'Racing', 'Off-road', 'Tuning'],
    },
    'Music': {
      'Genre': ['Pop', 'Rock', 'Jazz', 'Classical', 'Electronic'],
      'Instrument': ['Guitar', 'Piano', 'Drums', 'None'],
    },
    'Running': {
      'Experience': ['Beginner', 'Intermediate', 'Advanced'],
      'Surface': ['Road', 'Trail', 'Track'],
    },
    'Traveling': {
      'Style': ['Backpacking', 'Luxury', 'Solo', 'Group'],
      'Favorite Region': ['Europe', 'Asia', 'Americas', 'Africa'],
    },
    'Reading': {
      'Genre': ['Fiction', 'Non-fiction', 'Sci-fi', 'Romance'],
      'Frequency': ['Daily', 'Weekly', 'Monthly'],
    },
    'Swimming': {
      'Environment': ['Pool', 'Open Water'],
      'Style': ['Freestyle', 'Breaststroke', 'Butterfly'],
    },
    'Cycling': {
      'Level': ['Beginner', 'Intermediate', 'Pro'],
      'Type': ['Road', 'Mountain', 'Commuting'],
    },
    'Writing': {
      'Form': ['Poetry', 'Essays', 'Fiction', 'Journaling'],
      'Tool': ['Notebook', 'Laptop', 'Phone'],
    },
    'Art': {
      'Medium': ['Painting', 'Sketching', 'Digital'],
      'Style': ['Realism', 'Abstract', 'Cartoon'],
    },
    'Animals': {
      'Interest': ['Pets', 'Wildlife', 'Animal Rescue'],
      'Favorite Animal': ['Dogs', 'Cats', 'Birds', 'Exotic'],
    },
    'Cooking': {
      'Cuisine': ['Italian', 'Japanese', 'Mexican', 'Indian'],
      'Skill Level': ['Beginner', 'Intermediate', 'Chef'],
    },
    'Photo': {
      'Camera': ['DSLR', 'Phone', 'Mirrorless'],
      'Subject': ['Portraits', 'Landscapes', 'Street', 'Events'],
    },
  };

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<HobbyProvider>(context, listen: false);
    selectedHobbies = provider.selectedHobbies;
    for (final hobby in selectedHobbies) {
      _answers[hobby] = {};
    }
  }

  Future<void> saveHobbyDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final firestore = FirebaseFirestore.instance;

    for (final hobby in _answers.keys) {
      final details = _answers[hobby]!;
      final cleaned = details..removeWhere((k, v) => v == null || v.isEmpty);
      if (cleaned.isNotEmpty) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('hobby_details')
            .doc(hobby)
            .set(cleaned);
      }
    }
  }

  void _onSubmit() async {
    await saveHobbyDetails();
    if (!mounted) return;
    context.go('/home');
  }

  void _onSkip() => context.go('/home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Personalize Your Hobbies"),
        actions: [
          TextButton(
            onPressed: _onSkip,
            child: const Text("Skip", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final hobby in selectedHobbies)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hobby,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final field in hobbyFields[hobby]!.keys)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String>(
                          value: _answers[hobby]![field],
                          items: hobbyFields[hobby]![field]!
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _answers[hobby]![field] = value),
                          decoration: InputDecoration(
                            labelText: field,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ElevatedButton(
            onPressed: _onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.black,
            ),
            child: const Text(
              "Finish & Continue",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
