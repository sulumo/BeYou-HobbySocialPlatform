import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'navigation/navigation.dart';
import 'navigation/navigation_provider.dart';
import 'cards/hobby_card.dart';
import 'community.dart';
import 'profile.dart';
import 'views.dart';
import 'maps.dart';
import 'dart:math';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _contentFilter = 'home'; // 'home' or 'forYou'
  late Future<List<String>> _userHobbies;
  late Future<Map<String, List<Map<String, dynamic>>>> _contentByHobby;

  @override
  void initState() {
    super.initState();
    _userHobbies = getUserHobbies();
    _contentByHobby = getHobbyContent();
  }

  Future<List<String>> getUserHobbies() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('hobby_details')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<Map<String, List<Map<String, dynamic>>>> getHobbyContent() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('hobbyContent')
        .get();

    final contentByHobby = <String, List<Map<String, dynamic>>>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      final hobby = data['hobby'];
      contentByHobby[hobby] = [...(contentByHobby[hobby] ?? []), data];
    }

    return contentByHobby;
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[300],
      elevation: 0,
      title: Row(
        children: [
          const SizedBox(width: 12),
          const Text('Welcome, ', style: TextStyle(color: Colors.black)),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('...');
              }
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final name = data?['name'] ?? 'Friend';
              return Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        FilterChip(
          label: Row(
            children: const [
              Icon(Icons.home, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text('Home'),
            ],
          ),
          selected: _contentFilter == 'home',
          onSelected: (_) {
            setState(() {
              _contentFilter = 'home';
            });
          },
          backgroundColor: Colors.black,
          selectedColor: Colors.black87,
          labelStyle: const TextStyle(color: Colors.white),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('For You'),
          selected: _contentFilter == 'forYou',
          onSelected: (_) {
            setState(() {
              _contentFilter = 'forYou';
            });
          },
          backgroundColor: Colors.black,
          selectedColor: Colors.black87,
          labelStyle: const TextStyle(color: Colors.white),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            context.push('/create');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[200],
            foregroundColor: Colors.black,
          ),
          child: const Text('+ Create'),
        ),
      ],
    );
  }

  Widget _buildHomeContent(
    List<String> hobbies,
    Map<String, List<Map<String, dynamic>>> contentByHobby,
  ) {
    final combinedContent = <Map<String, dynamic>>[];

    if (_contentFilter == 'forYou') {
      for (final hobby in hobbies) {
        combinedContent.addAll(contentByHobby[hobby] ?? []);
      }
    } else {
      for (final contentList in contentByHobby.values) {
        combinedContent.addAll(contentList);
      }
    }

    final Map<String, List<Map<String, dynamic>>> groupedByType = {};
    for (var item in combinedContent) {
      final type = item['type'] ?? 'unknown';
      groupedByType[type] = [...(groupedByType[type] ?? []), item];
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),
          _buildFilterRow(),
          const SizedBox(height: 24),
          for (final type in groupedByType.keys)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionHeader(
                  '${type[0].toUpperCase()}${type.substring(1)}s',
                  'View all',
                  type,
                  groupedByType[type] ?? [],
                ),
                const SizedBox(height: 8),
                hobbyCardRow(_getRandomItems(groupedByType[type] ?? [], 3)),
                const SizedBox(height: 24),
              ],
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRandomItems(
    List<Map<String, dynamic>> items,
    int count,
  ) {
    final random = Random();
    final itemsCopy = List<Map<String, dynamic>>.from(items);
    itemsCopy.shuffle(random);
    return itemsCopy.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationProvider>().selectedIndex;

    return FutureBuilder(
      future: Future.wait([_userHobbies, _contentByHobby]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('No data available')),
          );
        }

        final hobbies = snapshot.data![0] as List<String>;
        final contentByHobby =
            snapshot.data![1] as Map<String, List<Map<String, dynamic>>>;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: _buildBody(selectedIndex, hobbies, contentByHobby),
          bottomNavigationBar: const CustomNavigationBar(),
        );
      },
    );
  }

  Widget _buildBody(
    int selectedIndex,
    List<String> hobbies,
    Map<String, List<Map<String, dynamic>>> contentByHobby,
  ) {
    switch (selectedIndex) {
      case 0:
        return _buildHomeContent(hobbies, contentByHobby);
      case 1:
        return CommunityPage();
      case 2:
        return MapPage();
      case 3:
        return UserProfilePage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget sectionHeader(
    String title,
    String trailing,
    String type,
    List<Map<String, dynamic>> content,
  ) {
    final iconData = _getIconForType(type);
    final trailingColor = _getColorForType(type);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(iconData, color: Colors.black87, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewAllPage(type: type, content: content),
              ),
            );
          },
          child: Text(
            trailing,
            style: TextStyle(color: trailingColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'challenge':
        return Icons.flag;
      case 'recommendation':
        return Icons.bookmark_add;
      case 'tip':
        return Icons.lightbulb;
      default:
        return Icons.category;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'challenge':
        return Colors.redAccent;
      case 'recommendation':
        return Colors.teal;
      case 'tip':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  Widget hobbyCardRow(List<Map<String, dynamic>> cards) {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 320,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final data = cards[index];
              final hobby = data['hobby'] ?? 'Unknown';
              final color = hobbyColorMap[hobby] ?? Colors.grey;
              final type = data['type'] ?? 'recommendation';

              CardStyle cardStyle;
              switch (type) {
                case 'challenge':
                  cardStyle = CardStyle.tall;
                  break;
                case 'tip':
                  cardStyle = CardStyle.wide;
                  break;
                case 'recommendation':
                default:
                  cardStyle = CardStyle.defaultCard;
                  break;
              }

              return AdaptiveHobbyCard(
                data: data,
                color: color,
                style: cardStyle,
                onTap: () {
                  context.push(
                    '/detail',
                    extra: {
                      'id': data['id'],
                      'title': data['title'],
                      'description': data['description'],
                      'likeCount': data['likeCount'],
                      'createdBy': data['createdBy'],
                      'image': data['imageUrl'],
                      'type': data['type'],
                      'hobby': data['hobby'],
                      'color': color.value,
                      'metadata': data['metadata'],
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
