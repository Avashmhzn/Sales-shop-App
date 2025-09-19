import 'package:flutter/material.dart';
import 'package:saleup_app/auth/view/login/view/login_screen.dart';

class OnboardingScreen2 extends StatefulWidget {
  const OnboardingScreen2({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Inventory Management",
      description: "Track inventory in real-time.",
      imagePath: "assets/images/1.png",
    ),
    OnboardingPage(
      title: "Sales Tracking",
      description: "Track sales performance and trends.",
      imagePath: "assets/images/2.png",
    ),
    OnboardingPage(
      title: "Valuation of Assets",
      description: "Assess asset value for better decisions.",
      imagePath: "assets/images/3.png",
    ),
    OnboardingPage(
      title: "Creditor Management",
      description: "Easily track creditors and payments.",
      imagePath: "assets/images/4.png",
      isLastPage: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null && _pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(() {});
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index]);
              },
            ),
            Positioned(
              bottom: 40, // Matches the design's bottom padding
              right: 20,  // Matches the design's right alignment
              child: GestureDetector(
                onTap: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFFE1F5F0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _pages[_currentPage].isLastPage ? "Continue" : "Next",
                        style: const TextStyle(
                          color: Color(0xFF4A2F0F),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF4A2F0F),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Column(
      children: [
        // Image section
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft Oval Shadow
              Positioned(
                bottom: 15,
                child: Container(
                  width: 120,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 25,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
              // Floating Image
              Image.asset(
                page.imagePath,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        // Bottom section with title, description, indicators, and button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                page.title,
                style: const TextStyle(
                  color: Color(0xFF001D3D),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Hanken_Grotesk',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                page.description,
                style: const TextStyle(
                  color: Color(0xFF494949),
                  fontSize: 16,
                  fontFamily: 'Hanken_Grotesk',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              // Page indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                      (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _currentPage
                          ? const Color(0xFF001D3D)
                          : const Color(0xFFCCCCCC),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 180), // Restored to match your design's spacing
              // Removed button to avoid duplication (now in Stack)
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Button removed, handled by Stack
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Data model for onboarding pages
class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final bool isLastPage;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isLastPage = false,
  });
}