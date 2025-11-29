import 'package:flutter/material.dart';
import 'package:tenangin_mobile/features/payment/route/payment_route.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background image with family illustration
            Positioned.fill(
              
              child: Image.asset(
                'assets/images/thankyou.png', // Replace with the correct image path
                fit: BoxFit.fill,
              ),
            ),
            // The content on top of the background
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Title and message
                  const SizedBox(height: 40),
                  const Text(
                    'Terima kasih sudah berbagi hari',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.0,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A58C2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Semoga hatimu terasa lebih tenang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6F4A86),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Buttons for actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the package screen (left button)
                          Navigator.push(context, PackageRoute.go() ); // Replace with your actual route
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7A58C2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        child: const Text(
                          'Tambah 10\n menit lagi',
                          style: TextStyle(fontSize: 16, color: Colors.white, height: 1.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the profile screen (right button)
                          Navigator.pushNamed(context, '/profile'); // Replace with your actual route
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF6EFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        child: const Text(
                          'Selesai & \n Keluar',
                          style: TextStyle(fontSize: 16, height: 1.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
