import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import '../providers/bookmark.dart';
import '../cards/hobby_card.dart';
import 'package:go_router/go_router.dart';

class BookmarkedContentsPage extends StatelessWidget {
  const BookmarkedContentsPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchBookmarkedContents(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('hobbyContent')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarkedIds = bookmarkProvider.bookmarks;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBookmarkedContents(bookmarkedIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No bookmarked contents."));
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
