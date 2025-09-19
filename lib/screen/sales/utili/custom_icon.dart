import 'package:flutter/material.dart';

class CustomMenuIcon extends StatelessWidget {
  const CustomMenuIcon({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: CustomPaint(
        size: const Size(24, 24), // Icon size
        painter: MenuWithDotsPainter(),
      ),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
        elevation: 2,
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}

class MenuWithDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw three horizontal lines
    double lineLength = size.width * 0.6; // Adjust line length (60% of width)
    double spacing = size.height / 4; // Space between lines
    for (int i = 0; i < 3; i++) {
      double y = spacing * (i + 1);
      canvas.drawLine(
        Offset(2, y), // Start of line
        Offset(2 + lineLength, y), // End of line
        paint,
      );

      // Draw a dot on the right side of each line
      final dotPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width - 4, y), // Position dot on the right
        1.5, // Dot radius
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}