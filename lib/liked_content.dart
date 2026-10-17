import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'cards/hobby_card.dart';
import 'home.dart';

class LikedContentsPage extends StatefulWidget {
  const LikedContentsPage({super.key});

  @override
  State<LikedContentsPage> createState() => _LikedContentsPageState();
}

class _LikedContentsPageState extends State<LikedContentsPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> _fetchLikedContents() async {
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('hobbyContent')
        .get();

    final liked = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final likeDoc = await doc.reference
          .collection('likes')
          .doc(user!.uid)
          .get();
      if (likeDoc.exists && likeDoc.data()?['liked'] == true) {
        final data = doc.data();
        data['id'] = doc.id;
        liked.add(data);
      }
    }
    return liked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liked Contents"),
        backgroundColor: Colors.grey[300],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: _fetchLikedContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No liked content found."));
          }

          final likedContents = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: likedContents.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final content = likedContents[index];
              final color = hobbyColorMap[content['hobby']] ?? Colors.blueGrey;
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
          );
        },
      ),
    );
  }
}
