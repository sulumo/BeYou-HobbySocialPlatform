import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import '../components/svg_style.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

final Map<String, Color> hobbyColorMap = {
  'Cars': Color(0xFFE74C3C), // Red
  'Music': Color(0xFF9B59B6), // Purple
  'Running': Color(0xFF3498DB), // Blue
  'Traveling': Color(0xFF1ABC9C), // Turquoise
  'Reading': Color(0xFF2ECC71), // Green
  'Swimming': Color(0xFF16A085), // Deep Teal
  'Cycling': Color(0xFFF1C40F), // Yellow
  'Writing': Color(0xFF34495E), // Dark Blue
  'Art': Color(0xFFE67E22), // Orange
  'Animals': Color(0xFF95A5A6), // Grey
  'Cooking': Color(0xFFD35400), // Dark Orange
  'Photo': Color(0xFF7F8C8D), //Dark Grey
};

extension ColorShade on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class UserProfilePage extends StatefulWidget {
  final String? uid;
  const UserProfilePage({super.key, this.uid});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late final String profileUid;
  bool isCurrentUser = false;

  String? userName;
  String? email;
  String? avatarUrl;
  List<String> hobbies = [];

  bool isEditing = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    profileUid = widget.uid ?? currentUser?.uid ?? '';
    isCurrentUser = widget.uid == null || widget.uid == currentUser?.uid;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(profileUid);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        userName = data['name'] ?? 'Anonymous';
        email = data['email'] ?? '';
        avatarUrl = data['avatarUrl'];
        _nameController.text = userName!;
      });

      final hobbySnapshot = await userRef.collection('hobby_details').get();
      final hobbyList = hobbySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        hobbies = hobbyList;
      });
    }
  }

  Future<void> _updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(profileUid).update(
      {'name': _nameController.text.trim()},
    );
    setState(() {
      userName = _nameController.text.trim();
      isEditing = false;
    });
  }

  Future<void> _updateProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance.ref().child('avatars/$profileUid.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(profileUid).update(
      {'avatarUrl': url},
    );
    setState(() => avatarUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => setState(() => isEditing = true),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: [
              TransparentSvgIcon(assetPath: 'assets/hobbies.svg', size: 100),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: 'Welcome to ',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  children: [
                    const TextSpan(
                      text: 'Beyou',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(text: "'s Profile"),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: isCurrentUser ? _updateProfileImage : null,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : const AssetImage('assets/user.jpg')
                                  as ImageProvider,
                        backgroundColor: Colors.grey[300],
                        child: avatarUrl == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: isEditing
                          ? TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  email ?? 'No email',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                    ),
                    if (isEditing)
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: _updateProfile,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hobbies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: hobbies.map((hobby) {
                  final color = hobbyColorMap[hobby] ?? Colors.grey;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color, width: 1),
                    ),
                    child: Text(
                      hobby,
                      style: TextStyle(
                        fontSize: 13,
                        color: color.darken(0.2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              if (isCurrentUser)
                Column(
                  children: [
                    _profileOptionTile(
                      icon: Icons.favorite,
                      title: 'Liked Contents',
                      subtitle: 'All contents you liked',
                      onTap: () => context.push('/liked'),
                    ),
                    const SizedBox(height: 10),
                    _profileOptionTile(
                      icon: Icons.bookmark,
                      title: 'Bookmarks',
                      subtitle: 'Your saved contents',
                      onTap: () => context.push('/bookmarks'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              _profileOptionTile(
                icon: Icons.edit,
                title: 'Created Contents',
                subtitle: 'Hobby posts',
                onTap: () => context.push('/created', extra: profileUid),
              ),
              const SizedBox(height: 30),
              if (isCurrentUser)
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
