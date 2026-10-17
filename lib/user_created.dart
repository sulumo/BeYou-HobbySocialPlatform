import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cards/hobby_card.dart';
import 'package:go_router/go_router.dart';
import 'home.dart';

class CreatedContentsPage extends StatelessWidget {
  const CreatedContentsPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchCreatedContents() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('hobbyContent')
        .where('createdBy', isEqualTo: uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Created Contents"),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCreatedContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("You haven’t created any contents yet."),
            );
          }

          final contents = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: contents.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final content = contents[index];
                final hobby = content['hobby'] ?? '';
                final color = hobbyColorMap[hobby] ?? Colors.grey;

                return AdaptiveHobbyCard(
                  data: content,
                  color: color,
                  height: 190,
                  width: 180,
                  onTap: () {
                    context.push('/detail/${content['id']}', extra: content);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
