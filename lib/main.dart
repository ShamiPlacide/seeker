import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/startup/startup_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Seeker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
        ),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user == null) return const LoginScreen();

          // Route based on role
          return FutureBuilder<String?>(
            future: ref.read(authServiceProvider).getUserRole(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.data == 'startup') {
                return const StartupHomeScreen();
              }
              return const StudentHomeScreen();
            },
          );
        },
        loading: () => const Scaffold(
          backgroundColor: Color(0xFFF5F7F5),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2D6A4F),
            ),
          ),
        ),
        error: (e, _) => const Scaffold(
          body: Center(child: Text('Something went wrong')),
        ),
      ),
    );
  }
}
