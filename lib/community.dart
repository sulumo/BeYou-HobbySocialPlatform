import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedFilter = 'local';

  Future<List<DocumentSnapshot>> _loadUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> _loadGroups() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 24),
          _buildUsersSection(),
          const SizedBox(height: 32),
          _buildGroupsSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        FilterChip(
          label: const Text('Chatbot'),
          selected: _selectedFilter == 'chatbot',
          onSelected: (_) {
            context.push('/chatbot');
          },
          backgroundColor: Colors.black,
          selectedColor: Colors.black87,
          labelStyle: const TextStyle(color: Colors.white),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Discover other users'),
        const SizedBox(height: 12),
        FutureBuilder<List<DocumentSnapshot>>(
          future: _loadUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final users = snapshot.data ?? [];

            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  final userId = users[index].id;

                  return GestureDetector(
                    onTap: () {
                      context.push('/profile/$userId');
                    },
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: user['avatarUrl'] != null
                                ? CachedNetworkImageProvider(user['avatarUrl'])
                                : null,
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user['name'] ?? 'Friend',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('hobby_details')
                                .get(),
                            builder: (context, hobbySnapshot) {
                              final hobbies =
                                  hobbySnapshot.data?.docs
                                      .map((doc) => doc.id)
                                      .toList() ??
                                  [];

                              return Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: hobbies.take(3).map((hobby) {
                                  final color =
                                      hobbyColorMap[hobby] ?? Colors.grey;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      hobby,
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGroupsSection() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Groups you may like'),
        const SizedBox(height: 12),
        FutureBuilder<List<DocumentSnapshot>>(
          future: _loadGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final groups = snapshot.data ?? [];

            return Column(
              children: groups.map((doc) {
                final group = doc.data() as Map<String, dynamic>;
                final groupId = doc.id;
                final hobbyColor = hobbyColorMap[group['hobby']] ?? Colors.grey;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(groupId)
                      .collection('members')
                      .doc(currentUserId)
                      .get(),
                  builder: (context, memberSnapshot) {
                    final isJoined = memberSnapshot.data?.exists ?? false;

                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '/groupChat/$groupId',
                          extra: {
                            'groupName': group['name'],
                            'groupAvatarUrl': group['avatarUrl'],
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: group['avatarUrl'] != null
                                  ? CachedNetworkImageProvider(
                                      group['avatarUrl'],
                                    )
                                  : null,
                              backgroundColor: Colors.grey[300],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    group['description'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hobbyColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      group['hobby'] ?? '',
                                      style: TextStyle(
                                        color: hobbyColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: isJoined
                                  ? null
                                  : () async {
                                      await FirebaseFirestore.instance
                                          .collection('groups')
                                          .doc(groupId)
                                          .collection('members')
                                          .doc(currentUserId)
                                          .set({
                                            'joinedAt':
                                                FieldValue.serverTimestamp(),
                                          });
                                      setState(() {});
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isJoined
                                    ? Colors.grey
                                    : Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(isJoined ? 'Joined' : 'Join'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.people_alt, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
