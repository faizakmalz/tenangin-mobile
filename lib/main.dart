import 'package:flutter/material.dart';
import 'core/supabase_client.dart';
import 'features/onboarding/presentation/onboarding.dart';
import 'features/profile/presentation/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tenangin',
      initialRoute: "/",
      routes: {
        "/": (_) => const OnboardingScreen(),
        "/profile": (_) => const ProfileScreen(),
      },
      theme: ThemeData(
        fontFamily: 'Quicksand'
      ),
    );
  }
}
