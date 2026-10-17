import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bookmark.dart';

class DetailPage extends StatelessWidget {
  final String id;
  final String description;
  final String title;
  final int likeCount;
  final String image;
  final String hobby;
  final String createdBy;
  final String type;
  final Color color;
  final Map<String, dynamic> metadata;

  const DetailPage({
    super.key,
    required this.id,
    required this.description,
    required this.likeCount,
    required this.title,
    required this.image,
    required this.hobby,
    required this.createdBy,
    required this.type,
    required this.color,
    required this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final isBookmarked = bookmarkProvider.isBookmarked(id);
    final String contentId = id;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Image with bookmark
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.network(
                          image,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300], height: 220),
                        ),
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked ? Colors.black : Colors.black54,
                          ),
                          onPressed: () => bookmarkProvider.toggleBookmark(id),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Like row
                  Row(
                    children: [
                      Icon(Icons.favorite_border, color: Colors.red),
                      const SizedBox(width: 6),
                      Text('$likeCount likes', style: TextStyle(fontSize: 14)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(description, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 16),

                  // Hobby + Type row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hobby,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: Text(type),
                        backgroundColor: color.withOpacity(0.1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Creator + Hashtags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Created by: $createdBy',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Wrap(
                        spacing: 4,
                        children: metadata.values.map((tag) {
                          return Chip(
                            label: Text('#$tag'),
                            backgroundColor: Colors.grey[200],
                            labelStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  const Text(
                    'Comments',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  // Dynamic Comments
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('hobbyContent')
                        .doc(contentId)
                        .collection('comments')
                        .orderBy('createdAt', descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('No comments yet.');
                      }

                      final comments = snapshot.data!.docs;

                      return Column(
                        children: comments.map<Widget>((doc) {
                          final comment = doc.data() as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    comment['avatar'] ?? '',
                                  ),
                                  radius: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comment['createdBy'] ?? 'Anonymous',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '•', // might add timestamp format
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(comment['text'] ?? ''),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Reply',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                  const SizedBox(width: 12),
                  if (type.toLowerCase() == 'challenge')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Show challenge participants
                          showModalBottomSheet(
                            context: context,
                            builder: (_) =>
                                ChallengeProgressSheet(contentId: contentId),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Join now'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class ChallengeProgressSheet extends StatelessWidget {
  final String contentId;

  const ChallengeProgressSheet({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('hobbyContent')
          .doc(contentId)
          .collection('participants')
          .orderBy('joinedAt', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No participants yet. Be the first to join!'),
          );
        }

        final participants = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: participants.map((doc) {
            final participant = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(participant['avatar'] ?? ''),
              ),
              title: Text(participant['name'] ?? 'Anonymous'),
              subtitle: LinearProgressIndicator(
                value: (participant['progress'] ?? 0) / 100.0,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
