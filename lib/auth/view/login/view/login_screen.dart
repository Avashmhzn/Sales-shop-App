// import 'dart:convert';
// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/login_model.dart';
// import 'package:saleup_app/services/auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _rememberMe = false;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _emailController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final requestData = {
//         'email': _emailController.text.trim(),
//         'password': _passwordController.text.trim(),
//       };

//       log('Sending login request: ${requestData.toString().replaceAll(_passwordController.text, '****')}');

//       final response =
//           await DioClient().dio.post('/auth/login/', data: requestData);

//       log('Response: ${response.statusCode} ${response.requestOptions.path}, Data: ${response.data}');

//       if (response.statusCode == 200) {
//         dynamic responseData = response.data;
//         if (responseData is String) {
//           try {
//             responseData = jsonDecode(responseData);
//           } catch (e) {
//             log('Failed to parse response data: $e');
//             _showError('Invalid response from server. Please try again.');
//             return;
//           }
//         }

//         if (responseData is Map<String, dynamic>) {
//           final loginResponse = LoginResponse.fromJson(responseData);
//           log('Login response: ${loginResponse.toJson()}');

//           if (loginResponse.success == true) {
//             final data = loginResponse.data;
//             if (data != null &&
//                 data.access_token != null &&
//                 data.refresh_token != null &&
//                 data.user_id != null) {
//               await AuthService().saveTokens(
//                 accessToken: data.access_token!,
//                 refreshToken: data.refresh_token!,
//                 userId: data.user_id!,
//                 email: data.email,
//                 username: data.username,
//                 firstName: data.first_name,
//                 lastName: data.last_name,
//                 phone: data.phone,
//               );

//               log('Tokens saved: access=${data.access_token}, refresh=${data.refresh_token}');

//               if (mounted) context.go('/select_company');
//             } else {
//               _showError(
//                   'Login failed: Missing required data (access_token, refresh_token, or user_id)');
//             }
//           } else {
//             String msg = loginResponse.message ?? 'Login failed';
//             _showError(msg);
//           }
//         } else {
//           _showError('Unexpected response format from server.');
//         }
//       } else {
//         String errorMsg = 'Login failed: ';
//         if (response.statusCode == 404) {
//           errorMsg +=
//               'Authentication endpoint not found. Please check server configuration.';
//         } else {
//           errorMsg += 'Server returned status ${response.statusCode}.';
//         }
//         _showError(errorMsg);
//       }
//     } on DioException catch (e) {
//       log('Login error: $e, Response: ${e.response?.data}');

//       if (e.error.toString().contains('SocketException') &&
//           e.error.toString().contains('Failed host lookup')) {
//         if (mounted) _showConnectionErrorDialog();
//       } else if (e.response != null &&
//           e.response!.statusCode != null &&
//           e.response!.statusCode! >= 500 &&
//           e.response!.statusCode! <= 599) {
//         if (mounted) _showServerMaintenanceDialog();
//       } else {
//         String errorMsg = 'Login failed: ';
//         if (e.response?.data != null) {
//           dynamic responseData = e.response!.data;
//           if (responseData is String) {
//             try {
//               responseData = jsonDecode(responseData);
//             } catch (e) {
//               log('Failed to parse error response data: $e');
//               errorMsg += 'Invalid error response from server.';
//               _showError(errorMsg);
//               return;
//             }
//           }
//           if (responseData is Map<String, dynamic>) {
//             final loginResponse = LoginResponse.fromJson(responseData);
//             errorMsg += loginResponse.message ??
//                 (e.response?.statusCode == 401
//                     ? 'Invalid email or password'
//                     : 'Invalid credentials');
//           } else {
//             errorMsg += 'Unexpected error response format.';
//           }
//         } else {
//           errorMsg += e.message ?? 'Network error';
//         }
//         _showError(errorMsg);
//       }
//     } catch (e) {
//       log('Unexpected error: $e');
//       _showError('An unexpected error occurred. Please try again.');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showConnectionErrorDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         backgroundColor: Colors.white,
//         title: Text(
//           'Connection Error',
//           style: TextStyle(
//             fontFamily: 'Hanken_Grotesk',
//             fontSize: MediaQuery.of(context).size.width * 0.05,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         content: Text(
//           'Please check your connection and try again.',
//           style: TextStyle(
//             fontFamily: 'Hanken_Grotesk',
//             fontSize: MediaQuery.of(context).size.width * 0.04,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: TextButton.styleFrom(
//               backgroundColor: Colors.orange,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//               padding: EdgeInsets.symmetric(
//                 horizontal: MediaQuery.of(context).size.width * 0.04,
//                 vertical: MediaQuery.of(context).size.height * 0.015,
//               ),
//             ),
//             child: Text(
//               'OK',
//               style: TextStyle(
//                 fontFamily: 'Hanken_Grotesk',
//                 fontSize: MediaQuery.of(context).size.width * 0.04,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showServerMaintenanceDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         backgroundColor: Colors.white,
//         title: Text(
//           'Server Maintenance',
//           style: TextStyle(
//             fontFamily: 'Hanken_Grotesk',
//             fontSize: MediaQuery.of(context).size.width * 0.05,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         content: Text(
//           'Sorry, we are maintaining the server. Please try again later.',
//           style: TextStyle(
//             fontFamily: 'Hanken_Grotesk',
//             fontSize: MediaQuery.of(context).size.width * 0.04,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: TextButton.styleFrom(
//               backgroundColor: Colors.orange,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//               padding: EdgeInsets.symmetric(
//                 horizontal: MediaQuery.of(context).size.width * 0.04,
//                 vertical: MediaQuery.of(context).size.height * 0.015,
//               ),
//             ),
//             child: Text(
//               'OK',
//               style: TextStyle(
//                 fontFamily: 'Hanken_Grotesk',
//                 fontSize: MediaQuery.of(context).size.width * 0.04,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: SizedBox(
//             height: screenHeight,
//             child: Stack(
//               children: [
//                 // Background gradient + wave
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   height: screenHeight * 0.4,
//                   child: Image.asset(
//                     'assets/images/login_bg.png',
//                     fit: BoxFit.cover,
//                     alignment: Alignment.topCenter,
//                   ),
//                 ),

//                 // Logo
//                 Positioned(
//                   top: screenHeight * 0.04,
//                   left: 10,
//                   right: 0,
//                   child: Padding(
//                     // ← padding is allowed here
//                     padding: const EdgeInsets.all(10),
//                     child: Image.asset(
//                       'assets/images/Logo.png',
//                       height: screenHeight * 0.10,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),

//                 // Back arrow
//                 Positioned(
//                   top: 10,
//                   left: 3,
//                   child: IconButton(
//                     icon: Image.asset(
//                       'assets/images/back_button_logo.png',
//                       width: 60, // adjust size to match your design
//                       height: 60,
//                     ),
//                     onPressed: () {
//                       if (context.canPop()) {
//                         context.pop(); // ← go_router friendly version
//                       } else {
//                         // Fallback when nothing to pop (common in go_router root-ish routes)
//                         context.go('/onboarding');
//                       }
//                     },
//                   ),
//                 ),

//                 // Form content
//                 Padding(
//                   padding: EdgeInsets.only(
//                     top: screenHeight * 0.39,
//                     left: screenWidth * 0.06,
//                     right: screenWidth * 0.06,
//                   ),
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       minHeight: screenHeight -
//                           MediaQuery.of(context).padding.top -
//                           MediaQuery.of(context).padding.bottom -
//                           screenHeight * 0.5,
//                     ),
//                     child: IntrinsicHeight(
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Image.asset(
//                               'assets/images/login_line.png',
//                               height: 20,
//                               fit: BoxFit.contain,
//                             ),
//                             SizedBox(height: screenHeight * 0.02),

//                             // Email
//                             _buildTextField(
//                               "Email",
//                               "yourname@gmail.com",
//                               controller: _emailController,
//                               isEmail: true,
//                               prefixIcon: Icons.email,
//                             ),

//                             SizedBox(height: screenHeight * 0.025),

//                             // Password
//                             _buildTextField(
//                               "Password",
//                               "**********",
//                               isPassword: true,
//                               controller: _passwordController,
//                               prefixIcon: Icons.lock,
//                             ),

//                             SizedBox(height: screenHeight * 0.03),

//                             // Remember me + Forgot password
//                             _buildRememberMeAndForgotPassword(),

//                             SizedBox(height: screenHeight * 0.04),

//                             // Login button
//                             _buildLoginButton(),

//                             SizedBox(height: screenHeight * 0.03),

//                             // Signup section + line above it
//                             Center(
//                               child: Column(
//                                 children: [
//                                   SizedBox(height: screenHeight * 0.025),
//                                   _buildSignupSection(),
//                                 ],
//                               ),
//                             ),

//                             SizedBox(height: screenHeight * 0.03),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     String label,
//     String hint, {
//     bool isPassword = false,
//     bool isEmail = false,
//     TextInputType? keyboardType,
//     IconData? prefixIcon,
//     required TextEditingController controller,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontFamily: 'Hanken_Grotesk',
//             fontSize: MediaQuery.of(context).size.width * 0.035,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           obscureText: isPassword,
//           keyboardType:
//               keyboardType ?? (isEmail ? TextInputType.emailAddress : null),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               fontFamily: 'Hanken_Grotesk',
//               fontSize: MediaQuery.of(context).size.width * 0.035,
//               color: Colors.grey,
//             ),
//             prefixIcon: prefixIcon != null
//                 ? Icon(
//                     prefixIcon,
//                     color: Colors.orange,
//                     size: MediaQuery.of(context).size.width * 0.06,
//                   )
//                 : null,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.orange, width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: MediaQuery.of(context).size.width * 0.04,
//               vertical: MediaQuery.of(context).size.height * 0.018,
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return 'Please enter your $label';
//             }
//             if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
//               return 'Please enter a valid email address';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildRememberMeAndForgotPassword() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Transform.scale(
//               scale: 0.85,
//               child: Checkbox(
//                 value: _rememberMe,
//                 onChanged: (value) {
//                   setState(() => _rememberMe = value ?? false);
//                 },
//                 activeColor: Colors.orange,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6)),
//               ),
//             ),
//             Text(
//               "Remember Me",
//               style: TextStyle(
//                 fontFamily: 'Hanken_Grotesk',
//                 fontSize: MediaQuery.of(context).size.width * 0.035,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//         GestureDetector(
//           onTap: () => context.push('/forgot-password'),
//           child: Text(
//             "Forgot Password?",
//             style: TextStyle(
//               fontFamily: 'Hanken_Grotesk',
//               fontSize: MediaQuery.of(context).size.width * 0.035,
//               fontWeight: FontWeight.w500,
//               color: Colors.orange.shade400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoginButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: MediaQuery.of(context).size.height * 0.065,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _login,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.orange,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: 0,
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 width: 26,
//                 height: 26,
//                 child: CircularProgressIndicator(
//                     color: Colors.white, strokeWidth: 2.5),
//               )
//             : Text(
//                 'Login',
//                 style: TextStyle(
//                   fontFamily: 'Hanken_Grotesk',
//                   fontSize: MediaQuery.of(context).size.width * 0.045,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildSignupSection() {
//     return Center(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Don't have an account? ",
//             style: TextStyle(
//               fontFamily: 'Hanken_Grotesk',
//               fontSize: MediaQuery.of(context).size.width * 0.035,
//             ),
//           ),
//           GestureDetector(
//             onTap: () => context.go('/signup'),
//             child: Text(
//               "Signup",
//               style: TextStyle(
//                 fontFamily: 'Hanken_Grotesk',
//                 fontSize: MediaQuery.of(context).size.width * 0.035,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/login_model.dart';
import 'package:saleup_app/services/auth_service.dart';
import 'package:saleup_app/services/session_manager.dart'; // ← ADD THIS

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final requestData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      };

      log('Sending login request: ${requestData.toString().replaceAll(_passwordController.text, '****')}');

      final response =
          await DioClient().dio.post('/auth/login/', data: requestData);

      log('Response: ${response.statusCode} ${response.requestOptions.path}, Data: ${response.data}');

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            log('Failed to parse response data: $e');
            _showError('Invalid response from server. Please try again.');
            return;
          }
        }

        if (responseData is Map<String, dynamic>) {
          final loginResponse = LoginResponse.fromJson(responseData);
          log('Login response: ${loginResponse.toJson()}');

          if (loginResponse.success == true) {
            final data = loginResponse.data;
            if (data != null &&
                data.access_token != null &&
                data.refresh_token != null &&
                data.user_id != null) {
              await AuthService().saveTokens(
                accessToken: data.access_token!,
                refreshToken: data.refresh_token!,
                userId: data.user_id!,
                email: data.email,
                username: data.username,
                firstName: data.first_name,
                lastName: data.last_name,
                phone: data.phone,
              );

              // ← ADD THIS LINE — saves remember me flag
              await SessionManager().loginSuccess(rememberMe: _rememberMe);

              log('Tokens saved: access=${data.access_token}, refresh=${data.refresh_token}');

              if (mounted) context.go('/select_company');
            } else {
              _showError(
                  'Login failed: Missing required data (access_token, refresh_token, or user_id)');
            }
          } else {
            String msg = loginResponse.message ?? 'Login failed';
            _showError(msg);
          }
        } else {
          _showError('Unexpected response format from server.');
        }
      } else {
        String errorMsg = 'Login failed: ';
        if (response.statusCode == 404) {
          errorMsg +=
              'Authentication endpoint not found. Please check server configuration.';
        } else {
          errorMsg += 'Server returned status ${response.statusCode}.';
        }
        _showError(errorMsg);
      }
    } on DioException catch (e) {
      log('Login error: $e, Response: ${e.response?.data}');

      if (e.error.toString().contains('SocketException') &&
          e.error.toString().contains('Failed host lookup')) {
        if (mounted) _showConnectionErrorDialog();
      } else if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! >= 500 &&
          e.response!.statusCode! <= 599) {
        if (mounted) _showServerMaintenanceDialog();
      } else {
        String errorMsg = 'Login failed: ';
        if (e.response?.data != null) {
          dynamic responseData = e.response!.data;
          if (responseData is String) {
            try {
              responseData = jsonDecode(responseData);
            } catch (e) {
              log('Failed to parse error response data: $e');
              errorMsg += 'Invalid error response from server.';
              _showError(errorMsg);
              return;
            }
          }
          if (responseData is Map<String, dynamic>) {
            final loginResponse = LoginResponse.fromJson(responseData);
            errorMsg += loginResponse.message ??
                (e.response?.statusCode == 401
                    ? 'Invalid email or password'
                    : 'Invalid credentials');
          } else {
            errorMsg += 'Unexpected error response format.';
          }
        } else {
          errorMsg += e.message ?? 'Network error';
        }
        _showError(errorMsg);
      }
    } catch (e) {
      log('Unexpected error: $e');
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConnectionErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: Text(
          'Connection Error',
          style: TextStyle(
            fontFamily: 'Hanken_Grotesk',
            fontSize: MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Please check your connection and try again.',
          style: TextStyle(
            fontFamily: 'Hanken_Grotesk',
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Hanken_Grotesk',
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showServerMaintenanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: Text(
          'Server Maintenance',
          style: TextStyle(
            fontFamily: 'Hanken_Grotesk',
            fontSize: MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Sorry, we are maintaining the server. Please try again later.',
          style: TextStyle(
            fontFamily: 'Hanken_Grotesk',
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Hanken_Grotesk',
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            child: Stack(
              children: [
                // Background gradient + wave
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: screenHeight * 0.4,
                  child: Image.asset(
                    'assets/images/login_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // Logo
                Positioned(
                  top: screenHeight * 0.04,
                  left: 10,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/Logo.png',
                      height: screenHeight * 0.10,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Back arrow
                Positioned(
                  top: 10,
                  left: 3,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/back_button_logo.png',
                      width: 60,
                      height: 60,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/onboarding');
                      }
                    },
                  ),
                ),

                // Form content
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.39,
                    left: screenWidth * 0.06,
                    right: screenWidth * 0.06,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          screenHeight * 0.5,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/login_line.png',
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Email
                            _buildTextField(
                              "Email",
                              "yourname@gmail.com",
                              controller: _emailController,
                              isEmail: true,
                              prefixIcon: Icons.email,
                            ),

                            SizedBox(height: screenHeight * 0.025),

                            // Password
                            _buildTextField(
                              "Password",
                              "**********",
                              isPassword: true,
                              controller: _passwordController,
                              prefixIcon: Icons.lock,
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // Remember me + Forgot password
                            _buildRememberMeAndForgotPassword(),

                            SizedBox(height: screenHeight * 0.04),

                            // Login button
                            _buildLoginButton(),

                            SizedBox(height: screenHeight * 0.03),

                            Center(
                              child: Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.025),
                                  _buildSignupSection(),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    bool isPassword = false,
    bool isEmail = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Hanken_Grotesk',
            fontSize: MediaQuery.of(context).size.width * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType:
              keyboardType ?? (isEmail ? TextInputType.emailAddress : null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Hanken_Grotesk',
              fontSize: MediaQuery.of(context).size.width * 0.035,
              color: Colors.grey,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: Colors.orange,
                    size: MediaQuery.of(context).size.width * 0.06,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: MediaQuery.of(context).size.height * 0.018,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your $label';
            }
            if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() => _rememberMe = value ?? false);
                },
                activeColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
            Text(
              "Remember Me",
              style: TextStyle(
                fontFamily: 'Hanken_Grotesk',
                fontSize: MediaQuery.of(context).size.width * 0.035,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/forgot-password'),
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              fontFamily: 'Hanken_Grotesk',
              fontSize: MediaQuery.of(context).size.width * 0.035,
              fontWeight: FontWeight.w500,
              color: Colors.orange.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.065,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'Hanken_Grotesk',
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSignupSection() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              fontFamily: 'Hanken_Grotesk',
              fontSize: MediaQuery.of(context).size.width * 0.035,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/signup'),
            child: Text(
              "Signup",
              style: TextStyle(
                fontFamily: 'Hanken_Grotesk',
                fontSize: MediaQuery.of(context).size.width * 0.035,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
