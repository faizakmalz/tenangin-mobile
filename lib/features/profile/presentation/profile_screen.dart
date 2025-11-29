import 'package:flutter/material.dart';
import 'package:tenangin_mobile/core/supabase_client.dart';
import 'package:tenangin_mobile/features/chat/presentation/chat_history_screen.dart';
import '../../chat/data/chat_service.dart';
import '../../chat/presentation/chat_screen.dart';
import '../data/profile_service.dart';
import '../../payment/route/payment_route.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  // Simpan stories sebagai List<Map<String,dynamic>> untuk lebih aman
  List<Map<String, dynamic>> stories = [];
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    load();
    // Sample fallback stories
    stories = [
      {'text': 'Aku merasa sangat lelah hari ini'},
      {'text': 'Kadang aku susah tidur karena banyak pikiran'},
      {'text': 'Hari ini aku senang karena mendapat dukungan dari teman'},
    ];
  }

  Future<void> load() async {
    try {
      final data = await ProfileService.getProfile();
      if (data is Map<String, dynamic>) {
        setState(() {
          profile = data;
        });

        // Pass the threadId to PaymentRoute
      }
    } catch (e, st) {
      debugPrint('Error loading profile: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat profil')),
        );
      }
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun'),
        content: const Text(
          'Apakah kamu yakin ingin keluar? Kamu akan kembali ke halaman awal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoggingOut = true);

    try {
      // Sign out from Supabase
      await SupabaseClientManager.client.auth.signOut();

      if (mounted) {
        // Navigate to onboarding and clear all routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error logging out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal keluar. Silakan coba lagi.')),
        );
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String name = profile!['anon_name']?.toString() ?? 'Teman';

    return Scaffold(
      backgroundColor: const Color(0xFFF3EAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hai, selamat datang di Tenangin 🌸',
                              style: TextStyle(
                                color: const Color(0xFF4B2E6A),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kamu aman di sini.\nCeritakan apapun yang kamu rasakan.',
                              style: TextStyle(
                                color: const Color(0xFF6F4A86),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 70)
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 50),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 170,
                              height: 170,
                              color: const Color(0xFFF6EFFF).withOpacity(0.0),
                              child: Image.asset(
                                'assets/images/hero-profile.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person, size: 48, color: Color(0xFFB99BE0));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PackageRoute.go(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A58C2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Mulai Curhat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur "Baca Cerita Orang Lain" belum tersedia')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6EEFB),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Baca Cerita Orang Lain',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6F4A86),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to Chat History Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatHistoryScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6EEFB),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lihat Riwayat Chat',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6F4A86),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6EEFB),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6F4A86),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Cerita Mereka',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B2E6A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Cerita mereka mungkin mirip dengan rasamu.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6F4A86),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(
                    stories.length,
                    (index) {
                      final s = stories[index];
                      final text = s['text']?.toString() ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEDE7F7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF7A58C2),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3D2B49),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Color(0xFFB99BE0)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Buka cerita: $text')),
                                );
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
