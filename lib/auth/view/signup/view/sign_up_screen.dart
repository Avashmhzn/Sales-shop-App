import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleup_app/auth/view/login/view/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Sign Up To Start Your Journey!",
                style: TextStyle(
                  fontFamily: 'Hanken_Grotesk',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Create your account to unlock possibilities!",
                style: TextStyle(
                    fontFamily: 'Hanken_Grotesk',
                    fontSize: 14,
                    color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField("Full Name", "Enter your full name"),
              _buildTextField("Contact Number", "Enter your contact number"),
              _buildTextField("Email Address", "Enter your email address"),
              _buildTextField("Password", "Enter your password",
                  isPassword: true),
              _buildTextField("Confirm Password", "Enter confirm password",
                  isPassword: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    const LoginScreen();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                        fontFamily: 'Hanken_Grotesk',
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildOrDivider(),
              const SizedBox(height: 20),
              _buildSocialButton(
                "Continue with Google",
                SvgPicture.asset(
                  'assets/svg/google-color-icon.svg',
                  width: 24,
                  height: 24,
                ),
                backgroundColor:
                    const Color(0xFFEFFFFF), // Light blue background
              ),
              _buildSocialButton(
                "Continue with Facebook",
                SvgPicture.asset(
                  'assets/svg/facebook-round-color-icon.svg',
                  width: 24,
                  height: 24,
                ),
                backgroundColor: Colors.white,
                borderColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ",
                        style: TextStyle(
                            fontFamily: 'Hanken_Grotesk', fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: 'Hanken_Grotesk',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontFamily: 'Hanken_Grotesk',
                fontSize: 14,
              )),
          const SizedBox(height: 5),
          TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  fontFamily: 'Hanken_Grotesk',
                  fontSize: 14,
                  color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    Widget icon, {
    Color backgroundColor = Colors.white,
    Color? borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: icon, // Accepting a Widget instead of IconData
          label: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Hanken_Grotesk',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.black,
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(thickness: 1, color: Colors.lightBlue)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "OR",
            style: TextStyle(
              fontFamily: 'Hanken_Grotesk',
              fontSize: 14,
              color: Colors.lightBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(thickness: 1, color: Colors.lightBlue)),
      ],
    );
  }
}
