import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'navigation_provider.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final selectedIndex = navigationProvider.selectedIndex;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              iconTheme: MaterialStateProperty.resolveWith((states) {
                final isSelected = states.contains(MaterialState.selected);
                return IconThemeData(
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  size: 26,
                );
              }),
              indicatorColor: Colors.white.withOpacity(0.1),
              height: 70,
            ),
            child: NavigationBar(
              backgroundColor: Colors.black,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: selectedIndex,
              onDestinationSelected: navigationProvider.updateIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(CupertinoIcons.home),
                  label: 'Home',
                ),
                // NavigationDestination(
                //   icon: Icon(CupertinoIcons.news),
                //   label: 'News',
                // ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.person_2),
                  label: 'Community',
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.map),
                  label: 'Map',
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
