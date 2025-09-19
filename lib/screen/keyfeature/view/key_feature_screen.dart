import 'package:flutter/material.dart';
import 'package:saleup_app/screen/onboarding2/next_screen.dart';

class KeyFeaturesScreen extends StatefulWidget {
  const KeyFeaturesScreen({super.key});

  @override
  _KeyFeaturesScreenState createState() => _KeyFeaturesScreenState();
}

class _KeyFeaturesScreenState extends State<KeyFeaturesScreen> {
  void _onNextPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white, // Soft purple background
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Explore Key ',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Hanken_Grotesk',
                                color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Features',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Hanken_Grotesk',
                                color: Colors.orange),
                          ),
                          TextSpan(
                            text: ' of\nSales Shop',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Hanken_Grotesk',
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Streamline your inventory and sales management.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Hanken_Grotesk'),
                    ),
                    Image.asset('assets/images/keyfeature.png', height: 500,
                        errorBuilder: (_, __, ___) {
                      return const Icon(Icons.image_not_supported,
                          size: 120, color: Colors.grey);
                    }),
                  ],
                ),
              ),

              // Next Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor:
                            Colors.lightBlueAccent.withOpacity(0.1),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward_ios,
                              size: 18, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
