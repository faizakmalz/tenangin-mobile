import 'dart:ui'; // Import ImageFilter
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tenangin_mobile/features/payment/route/payment_route.dart';

class TenanginPackagePage extends StatefulWidget {
  const TenanginPackagePage({Key? key, required}) : super(key: key);

  @override
  State<TenanginPackagePage> createState() => _TenanginPackagePageState();
}

class _TenanginPackagePageState extends State<TenanginPackagePage> {
  int sessionCount = 1;
  final int pricePerSession = 10000;
  late LinearGradient randomGradient;

  @override
  void initState() {
    super.initState();
    randomGradient = getRandomGradient();
  }

  LinearGradient getRandomGradient() {
    List<Color> colors = [
      Color(0xffd9c1fd),
      Color(0Xfffeeecd)
    ];

    return LinearGradient(
      colors: [
        colors[0],
        colors[1],
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  final Map<int, int> sessionDurationMinutes = {
    1: 10,
    2: 20,
    3: 30,
  };

  void navigateToPaymentPage() {
    Navigator.push(
      context,
      PaymentRoute.go(
        sessionCount: sessionCount,
        pricePerSession: pricePerSession,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background-package.png'
            ),
            fit: BoxFit.cover
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9B7EBD)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Durasi',
                    style: TextStyle(height: 0.6, fontSize: 38, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 58, 24, 80)),
                  ),
                  const Text(
                    'Sesi Curhatmu',
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF43205B)),
                  ),
                  const SizedBox(height: 18),
                  Column(
                    children: [
                      _buildSessionOption('Sesi 10 Menit', 'Curhat Cepat', 1, 0xFFB297D0),
                      _buildSessionOption('Sesi 20 Menit', 'Cerita Tenang', 2, 0xFFFFEB3B),
                      _buildSessionOption('Sesi 30 Menit', 'Berbagi Lebih Dalam', 3, 0xFF9F9F99),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildPaymentButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionOption(String title, String subtitle, int sessionIndex, int color) {
    bool isSelected = sessionCount == sessionIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 35),
      child: GestureDetector(
        onTap: () {
          setState(() {
            sessionCount = sessionIndex; 
          });
        },
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? Color(color).withValues(alpha: 0.4) : Color(color).withValues(alpha: 0.1), // Adjust opacity
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color.fromARGB(255, 168, 168, 168).withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Color.fromARGB(255, 86, 86, 84).withValues(alpha: 0.03) // Darker shadow for selected option
                    : Color.fromARGB(255, 86, 86, 84).withValues(alpha: 0.01), // Lighter shadow for unselected
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Add blur effect
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w900, // Bold for selected option
                            color: isSelected ? Color(0xFF1E0B32) : Color(0xFF5E426F),
                          ),
                        ),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Color(0xFF3D3C3D) : Color.fromARGB(255, 86, 86, 86),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      height: 100,
      width: 320,
      child: ElevatedButton(
        onPressed: navigateToPaymentPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 227, 171),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(side: BorderSide(color: Color.fromARGB(255, 170, 159, 178), width: 0.5),
            borderRadius: BorderRadius.circular(20)
          ),
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Mulai Curhat Sekarang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF43205B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
