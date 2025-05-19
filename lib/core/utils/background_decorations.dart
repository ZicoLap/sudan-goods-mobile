import 'package:flutter/material.dart';

class BackgroundDecorationsWeb extends StatelessWidget {
  const BackgroundDecorationsWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🟡 Yellow Circle
        Positioned(
          top: -400,
          left: -600,
          child: Container(
            width: 1600,
            height: 1100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6C243),
            ),
          ),
        ),

        // 🧂 Sudanese Spices Image
        Positioned(
          bottom: -80,
          right: 200,
          child: Image.asset(
            'assets/images/sudanese_spices.png',
            width: 600,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}


class BackgroundDecorationsMobile extends StatelessWidget {
  const BackgroundDecorationsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🟡 Yellow Circle
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 800,
            height: 600,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6C243),
            ),
          ),
        ),

          Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 800,
            height: 600,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6C243),
            ),
          ),
        ),

        // 🧂 Sudanese Spices Image
     
      ],
    );
  }
}
