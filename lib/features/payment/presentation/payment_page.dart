import 'package:flutter/material.dart';
import 'package:tenangin_mobile/features/chat/data/chat_service.dart';
import 'package:tenangin_mobile/features/chat/presentation/chat_screen.dart';
import 'package:tenangin_mobile/features/chat/presentation/pre-chat.dart';

class TenanginPaymentPage extends StatefulWidget {
  final int sessionCount;
  final int pricePerSession;

  const TenanginPaymentPage({
    Key? key,
    required this.sessionCount,
    required this.pricePerSession,
  }) : super(key: key);

  @override
  _TenanginPaymentPageState createState() => _TenanginPaymentPageState();
}

class _TenanginPaymentPageState extends State<TenanginPaymentPage> {
  final TextEditingController _voucherController = TextEditingController();
  String selectedPaymentMethod = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Column(
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9B7EBD)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),


                  const Text(
                    'Langkah terakhir',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(67, 32, 91, 1),
                      height: 0.8
                    ),
                  ),
                  const Text(
                    'sebelum kamu mulai',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF43205B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih metode pembayaran yang kamu inginkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF43205B),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 255, 255, 255).withValues(alpha: 0.5), // Transparent container background
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9B7EBD).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPaymentOption(
                          'Transfer Bank / VA', 
                          Icons.account_balance, 
                          'transfer', 
                          Color(0xFF9B7EBD), 
                          Color(0xFFD1B3E5)
                        ),
                        _buildPaymentOption(
                          'Kartu Debit / Kredit', 
                          Icons.credit_card, 
                          'debit', 
                          Color(0xFF9B7EBD), 
                          Color(0xFFFFD26F)
                        ),
                        _buildPaymentOption(
                          'E-Wallet (Gopay, OVO, Dana, etc.)', 
                          Icons.wallet_giftcard, 
                          'ewallet', 
                          Color(0xFF9B7EBD), 
                          Color(0xFF82D5D2)
                        ),
                        _buildPaymentOption(
                          'Kode Voucher / Gratis Sesi Pertama', 
                          Icons.card_giftcard, 
                          'voucher', 
                          Color(0xFF9B7EBD), 
                          Color(0xFFE96D6D)
                        ),

                        const SizedBox(height: 5),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255), // Transparent container background
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Sesi:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF565656),
                                    ),
                                  ),
                                  Text(
                                    'Rp ${(widget.sessionCount * widget.pricePerSession).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF565656),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Durasi:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF565656),
                                    ),
                                  ),
                                  Text(
                                    '${widget.sessionCount * 10} menit', // Assuming each session is 10 minutes
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF565656),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        _buildPaymentButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(height: 27)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData iconData, String paymentMethod, Color iconColor, Color backgroundColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = paymentMethod;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: selectedPaymentMethod == paymentMethod
              ? Color(0xFFD8C6F6)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color.fromARGB(255, 168, 168, 168).withOpacity(0.2)) ,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9B7EBD).withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selectedPaymentMethod == paymentMethod ? backgroundColor.withOpacity(0.7) : backgroundColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                iconData,
                color: Colors.white, 
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selectedPaymentMethod == paymentMethod
                      ? Color.fromARGB(255, 66, 51, 82)
                      : Color.fromARGB(255, 106, 86, 130),
                ),
              ),
            ),
            if (selectedPaymentMethod == paymentMethod)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF373737),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (selectedPaymentMethod.isNotEmpty) {
           Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => PreChatPage()
            )
          );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 227, 171),
          padding: const EdgeInsets.symmetric(vertical: 25),
          shape: RoundedRectangleBorder(side: BorderSide(color: Color.fromARGB(255, 170, 159, 178), width: 0.5),
            borderRadius: BorderRadius.circular(20)
          ),
          elevation: 1,
          shadowColor: Color.fromARGB(255, 106, 106, 106).withValues(alpha: 0.2) // No shadow, flat appearance
        ),
        child: Text(
          'Bayar dan Mulai Curhat Sekarang',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF565656),
          ),
        ),
        
      ),
    );
  }
  
}
