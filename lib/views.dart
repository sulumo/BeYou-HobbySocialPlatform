import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'cards/hobby_card.dart';
// import 'navigation/navigation.dart';

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

class ViewAllPage extends StatelessWidget {
  final String type;
  final List<Map<String, dynamic>> content;

  const ViewAllPage({super.key, required this.type, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${type[0].toUpperCase()}${type.substring(1)}s'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: content.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final data = content[index];
            final color = hobbyColorMap[data['hobby']] ?? Colors.grey;
            return AdaptiveHobbyCard(
              data: data,
              color: hobbyColorMap[data['hobby']] ?? Colors.grey,
              width: 180,
              height: 200,
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
      ),
      // bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
