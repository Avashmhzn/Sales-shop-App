import 'package:flutter/material.dart';
import 'package:saleup_app/screen/keyfeature/view/key_feature_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 24,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),

            // Title & Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Streamline Your\n",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Hanken_Grotesk',
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "Inventory Management",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Hanken_Grotesk',
                            color: Color(0xFFF7945D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    "Easily track and optimize assets.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Hanken_Grotesk',
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            // Image section with circular background
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.45,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer soft glow
                  Container(
                    width: screenWidth * 1.0,
                    height: screenWidth * 1.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.5,
                        colors: [
                          const Color(0xFFFFF0E6).withOpacity(0.4),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: const [0.2, 1.0],
                      ),
                    ),
                  ),

                  // Middle glow layer
                  Container(
                    width: screenWidth * 0.85,
                    height: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.7,
                        colors: [
                          const Color(0xFFFFE0CC),
                          const Color(0xFFFFF2E6).withOpacity(0.6),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // Golden ring effect
                  Container(
                    width: screenWidth * 0.65,
                    height: screenWidth * 0.65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5C98A).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // Plus signs (decorative elements)
                  Positioned(
                    top: screenHeight * 0.09,
                    child: Icon(
                      Icons.add,
                      color: const Color(0xFFE5C98A).withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    right: screenWidth * 0.24,
                    child: Icon(
                      Icons.add,
                      color: const Color(0xFFE5C98A).withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    bottom: screenHeight * 0.09,
                    child: Icon(
                      Icons.add,
                      color: const Color(0xFFE5C98A).withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.24,
                    child: Icon(
                      Icons.add,
                      color: const Color(0xFFE5C98A).withOpacity(0.7),
                      size: 20,
                    ),
                  ),

                  // Main image
                  Image.asset(
                    "assets/images/onboarding1.png",
                    fit: BoxFit.contain,
                    height: screenHeight * 0.35,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.15),

            // Get Started Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  const KeyFeaturesScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7945D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Hanken_Grotesk',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}