import 'package:flutter/material.dart';
import 'supabase_client.dart';

class AuthGuard extends StatelessWidget {
  final Widget builder;
  const AuthGuard({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseClientManager.client.auth.currentUser;

    if (user == null) {
      // If not logged in, go to onboarding
      return const Scaffold(
        body: Center(child: Text("Redirecting to Onboarding...")),
      );
    }

    return builder;
  }
}
