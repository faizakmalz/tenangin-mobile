import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 189, 146, 254),
                    const Color.fromARGB(255, 163, 113, 239)
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade200, Colors.grey.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) 
              CustomPaint(
                size: Size(10, 10),
                painter: _BubbleTailPainter(isMe: isMe),
              ),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            if (isMe) 
              CustomPaint(
                size: Size(10, 10), 
                painter: _BubbleTailPainter(isMe: isMe),
              ),
          ],
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final bool isMe;

  _BubbleTailPainter({required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMe
          ? const Color.fromARGB(255, 187, 137, 201) 
          : Colors.grey.shade300; 

    Path path = Path();

    if (isMe) {
      path.moveTo(size.width, size.height / 2); 
      path.lineTo(size.width + 8, size.height / 2 - 5);
      path.lineTo(size.width + 8, size.height / 2 + 5);
    } else {
      path.moveTo(0, size.height / 2);
      path.lineTo(-8, size.height / 2 - 5);
      path.lineTo(-8, size.height / 2 + 5);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
