import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'providers/hobby_provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

Widget icon8(String fileName, {double size = 55, Color color = Colors.white}) {
  if (fileName.endsWith('.svg')) {
    return SvgPicture.asset(
      'assets/$fileName',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else {
    return Image.asset(
      'assets/$fileName',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}

class _StartPageState extends State<StartPage> {
  final user = FirebaseAuth.instance.currentUser;
  final List<String> selected = [];

  final hobbies = [
    {'label': 'Cars', 'icon': icon8('lamborghini.svg')},
    {'label': 'Music', 'icon': Icons.music_note_rounded},
    {'label': 'Running', 'icon': Icons.directions_run},
    {'label': 'Traveling', 'icon': Icons.flight},
    {'label': 'Reading', 'icon': Icons.menu_book},
    {'label': 'Swimming', 'icon': Icons.pool},
    {'label': 'Cycling', 'icon': Icons.directions_bike},
    {'label': 'Writing', 'icon': Icons.edit},
    {'label': 'Art', 'icon': Icons.brush},
    {'label': 'Animals', 'icon': Icons.pets},
    {'label': 'Cooking', 'icon': Icons.restaurant},
    {'label': 'Photo', 'icon': Icons.camera_alt},
  ];

  void toggleSelection(String label) {
    setState(() {
      if (selected.contains(label)) {
        selected.remove(label);
      } else {
        selected.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Select hobbies & interests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: hobbies.map((hobby) {
                  final isSelected = selected.contains(hobby['label']);
                  final icon = hobby['icon'];
                  final Widget iconWidget;

                  if (icon is IconData) {
                    iconWidget = Icon(icon, size: 55, color: Colors.white);
                  } else if (icon is Widget) {
                    iconWidget = SizedBox(height: 55, width: 55, child: icon);
                  } else {
                    iconWidget = const SizedBox();
                  }

                  return GestureDetector(
                    onTap: () => toggleSelection(hobby['label'] as String),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          iconWidget,
                          const SizedBox(height: 25),
                          Text(
                            hobby['label']! as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: selected.isEmpty
                  ? null
                  : () {
                      // Saving selected hobbies to global provider
                      final provider = Provider.of<HobbyProvider>(
                        context,
                        listen: false,
                      );
                      provider.setHobbies(selected);
                      context.go('/hobby-setup');
                    },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
