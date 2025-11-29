import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _loading = false;

  Future<void> _loginAnonymous() async {
    setState(() => _loading = true);

    try {
      final auth = SupabaseClientManager.client.auth;

      final existingUser = auth.currentUser;
      if (existingUser != null) {
        debugPrint("Existing anonymous user found: ${existingUser.id}");

        Navigator.pushReplacementNamed(context, "/profile");
        setState(() => _loading = false);
        return;
      }

      final res = await auth.signInAnonymously();

      if (res.user != null) {
        final data = {
          'id': res.user!.id,
          'anon_name': 'User-${DateTime.now().millisecondsSinceEpoch}',
        };

        await SupabaseClientManager.client.from("profiles").upsert(data);

        Navigator.pushReplacementNamed(context, "/profile");
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal masuk. Silakan coba lagi.')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/onboard.png'
            ),
            fit: BoxFit.cover
          ), 
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              children: [
                const SizedBox(height: 36),
                Column(
                  children: const [
                    SizedBox(height: 35),
                    Text(
                      'Selamat datang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 0.7,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B2E6A), 
                      ),
                    ),
                    Text(
                      'di Tenangin 🌸',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B2E6A),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Tempat semua usia bisa\nberbagi rasa tanpa takut',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6F4A86),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                      widthFactor: 1.2,
                      child: Image.asset(
                        'assets/images/people2.png',
                        fit: BoxFit.fitWidth,
                      ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    width: width,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _loginAnonymous,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A58C2), // purple button
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Mulai Curhat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}