import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'navigation/navigation_provider.dart';
import 'providers/hobby_provider.dart';
import 'providers/bookmark.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HobbyProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = BookmarkProvider();
            provider.loadBookmarks();
            return provider;
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}
