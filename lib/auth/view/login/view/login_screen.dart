
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
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _rememberMe = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final requestData = {
//         'email': _emailController.text.trim(),
//         'password': _passwordController.text.trim(),
//       };
//       log('Sending login request: ${requestData.toString().replaceAll(_passwordController.text, '****')}');

//       final response =
//           await DioClient().dio.post('/auth/login/', data: requestData);
//       final loginResponse = LoginResponse.fromJson(response.data);
//       log('Login response: ${loginResponse.toJson()}');

//       if (response.statusCode == 200 && loginResponse.success == true) {
//         final data = loginResponse.data;
//         if (data != null &&
//             data.access_token != null &&
//             data.refresh_token != null &&
//             data.user_id != null) {
//           await AuthService().saveTokens(
//             accessToken: data.access_token!,
//             refreshToken: data.refresh_token!,
//             userId: data.user_id!,
//             email: data.email,
//             username: data.username,
//             firstName: data.first_name,
//             lastName: data.last_name,
//             phone: data.phone,
//           );
//           log('Tokens saved: access=${data.access_token}, refresh=${data.refresh_token}');
//           if (mounted) context.go('/home'); // Use GoRouter
//         } else {
//           _showError(
//               'Login failed: Missing required data (access_token, refresh_token, or user_id)');
//         }
//       } else {
//         String msg = loginResponse.message ?? 'Login failed';
//         _showError(msg);
//       }
//     } on DioException catch (e) {
//       log('Login error: $e, Response: ${e.response?.data}');
//       if (e.error.toString().contains('SocketException') &&
//           e.error.toString().contains('Failed host lookup')) {
//         if (mounted) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               backgroundColor: Colors.white,
//               title: Text(
//                 'Connection Error',
//                 style: TextStyle(
//                   fontFamily: 'Hanken_Grotesk',
//                   fontSize: MediaQuery.of(context).size.width * 0.05,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               content: Text(
//                 'Please check your connection and try again.',
//                 style: TextStyle(
//                   fontFamily: 'Hanken_Grotesk',
//                   fontSize: MediaQuery.of(context).size.width * 0.04,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: MediaQuery.of(context).size.width * 0.04,
//                       vertical: MediaQuery.of(context).size.height * 0.015,
//                     ),
//                   ),
//                   child: Text(
//                     'OK',
//                     style: TextStyle(
//                       fontFamily: 'Hanken_Grotesk',
//                       fontSize: MediaQuery.of(context).size.width * 0.04,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       } else if (e.response != null &&
//           e.response!.statusCode != null &&
//           e.response!.statusCode! >= 500 &&
//           e.response!.statusCode! <= 599) {
//         if (mounted) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               backgroundColor: Colors.white,
//               title: Text(
//                 'Server Maintenance',
//                 style: TextStyle(
//                   fontFamily: 'Hanken_Grotesk',
//                   fontSize: MediaQuery.of(context).size.width * 0.05,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               content: Text(
//                 'Sorry, we are maintaining the server. Please try again later.',
//                 style: TextStyle(
//                   fontFamily: 'Hanken_Grotesk',
//                   fontSize: MediaQuery.of(context).size.width * 0.04,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: MediaQuery.of(context).size.width * 0.04,
//                       vertical: MediaQuery.of(context).size.height * 0.015,
//                     ),
//                   ),
//                   child: Text(
//                     'OK',
//                     style: TextStyle(
//                       fontFamily: 'Hanken_Grotesk',
//                       fontSize: MediaQuery.of(context).size.width * 0.04,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       } else {
//         String errorMsg = 'Login failed: ';
//         if (e.response?.data != null) {
//           final responseData = LoginResponse.fromJson(e.response!.data);
//           errorMsg += responseData.message ??
//               responseData.message ??
//               (e.response?.statusCode == 401
//                   ? 'Invalid email or password'
//                   : 'Invalid credentials');
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

//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 5),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: MediaQuery.of(context).size.width * 0.06),
//           child: SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight: MediaQuery.of(context).size.height -
//                     MediaQuery.of(context).padding.top -
//                     MediaQuery.of(context).padding.bottom,
//               ),
//               child: IntrinsicHeight(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                           height: MediaQuery.of(context).size.height * 0.08),
//                       _buildTitleSection(),
//                       SizedBox(
//                           height: MediaQuery.of(context).size.height * 0.04),
//                       _buildTextField(
//                           "Email Address", "Enter your email address",
//                           controller: _emailController, isEmail: true),
//                       _buildTextField("Password", "Enter your password",
//                           isPassword: true, controller: _passwordController),
//                       _buildRememberMeAndForgotPassword(),
//                       SizedBox(
//                           height: MediaQuery.of(context).size.height * 0.03),
//                       _buildLoginButton(),
//                       const Spacer(),
//                       _buildSignupSection(),
//                       SizedBox(
//                           height: MediaQuery.of(context).size.height * 0.03),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTitleSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Login into Your Account",
//           style: TextStyle(
//             fontFamily: 'Hanken_Grotesk',
//             fontSize: MediaQuery.of(context).size.width * 0.06,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           "Manage your inventory, sales, and more with ease.",
//           style: TextStyle(
//             fontFamily: 'Hanken_Grotesk',
//             fontSize: MediaQuery.of(context).size.width * 0.035,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField(String label, String hint,
//       {bool isPassword = false,
//       bool isEmail = false,
//       required TextEditingController controller}) {
//     return Padding(
//       padding:
//           EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontFamily: 'Hanken_Grotesk',
//               fontSize: MediaQuery.of(context).size.width * 0.035,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 5),
//           TextFormField(
//             controller: controller,
//             obscureText: isPassword,
//             keyboardType: isEmail ? TextInputType.emailAddress : null,
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(
//                 fontFamily: 'Hanken_Grotesk',
//                 fontSize: MediaQuery.of(context).size.width * 0.035,
//                 color: Colors.grey,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(color: Colors.orange, width: 2),
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: MediaQuery.of(context).size.width * 0.04,
//                 vertical: MediaQuery.of(context).size.height * 0.015,
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'Please enter your $label';
//               }
//               if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
//                 return 'Please enter a valid email address';
//               }
//               return null;
//             },
//           ),
//         ],
//       ),
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
//                   setState(() {
//                     _rememberMe = value ?? false;
//                   });
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
//           onTap: () {
//             context.push('/forgot-password'); // Use GoRouter
//           },
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
//       height: MediaQuery.of(context).size.height * 0.06,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _login,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.orange,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                     color: Colors.white, strokeWidth: 2),
//               )
//             : Text(
//                 'Login',
//                 style: TextStyle(
//                   fontFamily: 'Hanken_Grotesk',
//                   fontSize: MediaQuery.of(context).size.width * 0.04,
//                   color: Colors.white,
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
//             onTap: () {
//               context.go('/signup'); // Use GoRouter
//             },
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
import 'dart:convert'; // Added for jsonDecode
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/login_model.dart';
import 'package:saleup_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final requestData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      };
      log('Sending login request: ${requestData.toString().replaceAll(_passwordController.text, '****')}');

      // Note: Adjust this endpoint based on your server's API (e.g., '/api/auth/login' or '/login')
      final response = await DioClient().dio.post('/auth/login/', data: requestData);
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
              log('Tokens saved: access=${data.access_token}, refresh=${data.refresh_token}');
              if (mounted) context.go('/home');
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
          errorMsg += 'Authentication endpoint not found. Please check the server configuration.';
        } else {
          errorMsg += 'Server returned status ${response.statusCode}.';
        }
        _showError(errorMsg);
      }
    } on DioException catch (e) {
      log('Login error: $e, Response: ${e.response?.data}');
      if (e.error.toString().contains('SocketException') &&
          e.error.toString().contains('Failed host lookup')) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
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
      } else if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! >= 500 &&
          e.response!.statusCode! <= 599) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
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

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.06),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08),
                      _buildTitleSection(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      _buildTextField(
                          "Email Address", "Enter your email address",
                          controller: _emailController, isEmail: true),
                      _buildTextField("Password", "Enter your password",
                          isPassword: true, controller: _passwordController),
                      _buildRememberMeAndForgotPassword(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      _buildLoginButton(),
                      const Spacer(),
                      _buildSignupSection(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Login into Your Account",
          style: TextStyle(
            fontFamily: 'Hanken_Grotesk',
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage your inventory, sales, and more with ease.",
          style: TextStyle(
            fontFamily: 'Hanken_Grotesk',
            fontSize: MediaQuery.of(context).size.width * 0.035,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint,
      {bool isPassword = false,
      bool isEmail = false,
      required TextEditingController controller}) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
      child: Column(
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
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: isEmail ? TextInputType.emailAddress : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Hanken_Grotesk',
                fontSize: MediaQuery.of(context).size.width * 0.035,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.015,
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
      ),
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
                  setState(() {
                    _rememberMe = value ?? false;
                  });
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
          onTap: () {
            context.push('/forgot-password');
          },
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
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'Hanken_Grotesk',
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.white,
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
            onTap: () {
              context.go('/signup');
            },
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