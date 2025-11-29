import 'package:flutter/material.dart';
import 'package:tenangin_mobile/features/chat/data/chat_service.dart';
import 'package:tenangin_mobile/features/chat/presentation/chat_screen.dart';

class PreChatPage extends StatefulWidget {
  const PreChatPage({super.key});

  @override
  _PreChatPageState createState() => _PreChatPageState();
}

class _PreChatPageState extends State<PreChatPage> {
  Future<void> startChat() async {
    final service = ChatService();
    final thread = await service.createNewThread();

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(threadId: thread["id"]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EAF8), 
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/prechat.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9B7EBD)),
                      onPressed: () => Navigator.pop(context), 
                    ),
                    const Spacer(),  
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Tarik napas perlahan...\nLepaskan semua yang terasa berat.\nSekarang, kamu siap untuk bercerita 🌿',
                    style: TextStyle(
                      color: const Color(0xFF4B2E6A),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      startChat();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A58C2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Mulai Menulis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
