import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';
import 'start.dart';
import 'home.dart';
import 'profile.dart';
import 'community.dart';
import 'detail.dart';
import 'flow.dart';
import 'groupchat.dart';
import 'chatbot.dart';
import 'create.dart';
import 'liked_content.dart';
import 'bookmarked.dart';
import 'user_created.dart';
import 'providers/hobby_provider.dart';

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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final loggingIn =
        state.fullPath == '/login' || state.fullPath == '/register';

    if (user == null) {
      return loggingIn ? null : '/login';
    }

    if (loggingIn) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          LoginPage(onTap: () => context.go('/register')),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) =>
          RegisterPage(onTap: () => context.go('/login')),
    ),
    GoRoute(path: '/start', builder: (context, state) => const StartPage()),
    GoRoute(path: '/home', builder: (context, state) => HomePage()),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateContentPage(),
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) => const UserProfilePage(),
    ),
    GoRoute(
      path: '/hobby-setup',
      builder: (context, state) {
        return const HobbyFlowPage();
      },
    ),
    GoRoute(
      path: '/community',
      builder: (context, state) => const CommunityPage(),
    ),
    GoRoute(
      path: '/groupChat/:groupId',
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        final extras = state.extra as Map<String, dynamic>;
        final groupName = extras['groupName'] as String;
        final groupAvatarUrl = extras['groupAvatarUrl'] as String;

        return GroupChatPage(
          groupId: groupId,
          groupName: groupName,
          groupAvatarUrl: groupAvatarUrl,
        );
      },
    ),
    GoRoute(
      path: '/liked',
      builder: (context, state) => const LikedContentsPage(),
    ),
    GoRoute(
      path: '/bookmarks',
      builder: (context, state) => const BookmarkedContentsPage(),
    ),
    GoRoute(
      path: '/created',
      builder: (context, state) => const CreatedContentsPage(),
    ),
    GoRoute(path: '/chatbot', builder: (context, state) => const ChatbotPage()),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return DetailPage(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          image: data['imageUrl'],
          hobby: data['hobby'],
          createdBy: data['createdBy'],
          type: data['type'],
          likeCount: data['likeCount'] ?? 0,
          color: hobbyColorMap[data['hobby']] ?? Colors.grey,
          metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
        );
      },
    ),
    GoRoute(
      path: '/profile/:uid',
      builder: (context, state) {
        final uid = state.pathParameters['uid'];
        return UserProfilePage(uid: uid);
      },
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};

        return DetailPage(
          id: extra['id'] ?? '',
          description: extra['description'] ?? '',
          likeCount: extra['likeCount'] ?? '',
          createdBy: extra['createdBy'] ?? '',
          title: extra['title'] ?? '',
          image: extra['image'] ?? '',
          hobby: extra['hobby'] ?? '',
          type: extra['type'] ?? '',
          color: Color(extra['color'] ?? 0xFF000000),
          metadata: extra['metadata'] ?? {},
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HobbyProvider(),
      child: MaterialApp.router(
        title: 'beYou',
        theme: ThemeData.light(useMaterial3: true),
        routerConfig: _router,
      ),
    );
  }
}
