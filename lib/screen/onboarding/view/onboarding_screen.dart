// import 'package:flutter/material.dart';

// class OnboardingScreen extends StatelessWidget {
//   const OnboardingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Full background wave/image
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: screenHeight * 3.0, // ← control here
//             child: Image.asset(
//               'assets/images/onboarding_bg.png',
//               fit: BoxFit.contain,
//               alignment: Alignment.topCenter,
//             ),
//           ),

//           // Main content overlay
//           SafeArea(
//             child: Column(
//               children: [
//                 // Logo at top
//                 Padding(
//                   padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
//                   child: Image.asset(
//                     'assets/images/Logo.png',
//                     height: screenHeight * 0.08,
//                     fit: BoxFit.contain,
//                   ),
//                 ),

//                 SizedBox(height: screenHeight * 0.01),
//                 // Title + tagline
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 32),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Sales Shop Inventory Portal',
//                         style: TextStyle(
//                           fontSize: 25,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                       SizedBox(height: 2),
//                       Text(
//                         'The Ultimate Inventory Dashboard to Track, Manage,and Optimize \nYour Business Effectively.',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.white,
//                           height: 1.45,
//                           fontWeight: FontWeight.w400,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.02),

//                 // Main illustration (person with laptop/dashboard)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Image.asset(
//                     'assets/images/onboarding_icon.png',
//                     height: screenHeight *
//                         0.24, // ← tune this (0.38–0.45) until it looks centered like your screenshot
//                     fit: BoxFit.contain,
//                   ),
//                 ),

//                 const Spacer(flex: 2),

//                 // Buttons
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 28),
//                   child: Column(
//                     children: [
//                       _buildButton(
//                         label: 'Signup as Guest A/c',
//                         icon: Icons.person_outline_rounded,
//                         bgColor: Colors.white,
//                         textColor: const Color(0xFF6B48FF),
//                         onPressed: () {
//                           // context.go('/signup');
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       _buildButton(
//                         label: 'Login with Work A/c',
//                         icon: Icons.work_outline_rounded,
//                         bgColor: Colors.black.withOpacity(0.92),
//                         textColor: Colors.white,
//                         hasBorder: true,
//                         onPressed: () {
//                           // context.go('/login');
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 64),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildButton({
//     required String label,
//     required IconData icon,
//     required Color bgColor,
//     required Color textColor,
//     VoidCallback? onPressed,
//     bool hasBorder = false,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon, color: textColor, size: 26),
//         label: Text(
//           label,
//           style: TextStyle(
//             fontSize: 16.5,
//             fontWeight: FontWeight.w600,
//             color: textColor,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: bgColor,
//           foregroundColor: textColor,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: hasBorder
//                 ? const BorderSide(color: Colors.white, width: 1.5)
//                 : BorderSide.none,
//           ),
//           padding: const EdgeInsets.symmetric(vertical: 12),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Your background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 3.0,
            child: Image.asset(
              'assets/images/onboarding_bg.png',
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── your existing top part (logo + title + illustration) ──
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    height: screenHeight * 0.08,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        'Sales Shop Inventory Portal',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'The Ultimate Inventory Dashboard to Track, Manage,and Optimize \nYour Business Effectively.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Image.asset(
                    'assets/images/onboarding_icon.png',
                    height: screenHeight * 0.24,
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(flex: 2),

                // ── NEW BOTTOM SECTION – exactly like your image ───────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'C',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59422),
                              ),
                            ),
                            TextSpan(
                              text: 'hoose ',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const TextSpan(
                              text: 'L',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59422),
                              ),
                            ),
                            TextSpan(
                              text: 'ogin',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'How would you like to sign up? Please choose your preferred\naccount type.',
                        style: TextStyle(
                          fontSize:
                              12, // tiny bump to 14 for better readability
                          color: Colors.grey,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(
                          height: 40), // more breathing room before buttons

                      // ── Guest button (solid orange) ──
                      _buildChoiceButton(
                        iconPath: 'assets/images/person_icon.png',
                        label: 'Signup as Guest A/c',
                        backgroundColor: const Color(0xFFF59422),
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        isOutlined: false,
                        onPressed: () {
                          context.go('/signup');
                        },
                      ),

                      const SizedBox(height: 16),

                      // ── Work button (white + orange border) ──
                      _buildChoiceButton(
                        iconPath: 'assets/images/work_icon.png',
                        label: 'Login with Work A/c',
                        backgroundColor: Colors.white,
                        textColor: const Color(0xFFF59422),
                        iconColor: const Color(0xFFF59422),
                        borderColor: const Color(0xFFF59422),
                        isOutlined: true, // ← this makes it outlined
                        onPressed: () {
                          context.go('/login');
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ── Updated button builder ───────────────────────────────────────────────
  Widget _buildChoiceButton({
    IconData? icon,
    String? iconPath,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    Color? borderColor,
    VoidCallback? onPressed,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isOutlined
                ? BorderSide(
                    color: borderColor ?? const Color(0xFFF59422),
                    width: 1.2,
                  )
                : BorderSide.none,
          ),
          elevation: isOutlined ? 0 : 2,
          shadowColor: isOutlined ? Colors.transparent : Colors.black26,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // centers the whole content
          children: [
            // Left icon (fixed width)
            if (iconPath != null)
              Image.asset(
                iconPath,
                width: 28,
                height: 28,
                color:
                    iconColor, // remove this line if PNG already has desired color
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(
                icon,
                color: iconColor,
                size: 28,
              )
            else
              const SizedBox(
                  width: 28), // invisible placeholder to keep symmetry

            const SizedBox(width: 16),

            // Text takes remaining space → centers naturally
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: textColor, // important: use the passed color
                ),
                textAlign: TextAlign
                    .center, // ensures text is centered inside Expanded
              ),
            ),

            // Invisible spacer on right to balance the icon (keeps text truly centered)
            const SizedBox(width: 28), // ≈ icon (28) + gap (16) = 44
          ],
        ),
      ),
    );
  }
}
