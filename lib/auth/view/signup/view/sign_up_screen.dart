// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/auth/view/signup/bloc/sign_in_up_event.dart';
// import 'package:saleup_app/auth/view/signup/bloc/sign_up_bloc.dart';
// import 'package:saleup_app/auth/view/signup/bloc/sign_up_state.dart'; // make sure this matches your actual event file name

// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => SignUpBloc(),
//       child: const _SignUpContent(),
//     );
//   }
// }

// class _SignUpContent extends StatefulWidget {
//   const _SignUpContent();

//   @override
//   State<_SignUpContent> createState() => _SignUpContentState();
// }

// class _SignUpContentState extends State<_SignUpContent> {
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return BlocConsumer<SignUpBloc, SignUpState>(
//       listener: (context, state) {
//         if (state.status == SignUpStatus.success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content:
//                   Text(state.errorMessage ?? 'Account created successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           context.go('/login');
//         } else if (state.status == SignUpStatus.failure &&
//             state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage!),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         final bloc = context.read<SignUpBloc>();

//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: SizedBox(
//               child: Stack(
//                 children: [
//                   // Background image
//                   Positioned(
//                     top: 0,
//                     left: 0,
//                     right: 0,
//                     height: size.height * 0.4,
//                     child: Image.asset(
//                       'assets/images/login_bg.png',
//                       fit: BoxFit.cover,
//                       alignment: Alignment.topCenter,
//                     ),
//                   ),

//                   // Logo
//                   Positioned(
//                     top: size.height * 0.04,
//                     left: 0,
//                     right: 0,
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: Image.asset(
//                         'assets/images/Logo.png',
//                         height: size.height * 0.16,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),

//                   // Back button
//                   Positioned(
//                     top: 8,
//                     left: 4,
//                     child: IconButton(
//                       icon: Image.asset(
//                         'assets/images/back_button_logo.png',
//                         width: 50, // adjust size to match your design
//                         height: 50,
//                       ),
//                       onPressed: () {
//                         if (context.canPop()) {
//                           context.pop(); // ← go_router friendly version
//                         } else {
//                           // Fallback when nothing to pop (common in go_router root-ish routes)
//                           context.go('/onboarding');
//                         }
//                       },
//                     ),
//                   ),

//                   // Form content
//                   Padding(
//                     padding: EdgeInsets.only(
//                       top: size.height * 0.39,
//                       left: size.width * 0.06,
//                       right: size.width * 0.06,
//                     ),
//                     child: SingleChildScrollView(
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Image.asset(
//                               'assets/images/Line.png',
//                               height: 20,
//                               fit: BoxFit.contain,
//                             ),
//                             SizedBox(height: size.height * 0.02),

//                             // First & Last Name
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _field(
//                                     label: "First Name",
//                                     hint: "John",
//                                     value: state.firstName,
//                                     onChanged: (v) =>
//                                         bloc.add(UpdateFirstName(v)),
//                                     icon: Icons.person,
//                                     error: state.fieldErrors?['first_name'],
//                                   ),
//                                 ),
//                                 SizedBox(width: size.width * 0.04),
//                                 Expanded(
//                                   child: _field(
//                                     label: "Last Name",
//                                     hint: "Doe",
//                                     value: state.lastName,
//                                     onChanged: (v) =>
//                                         bloc.add(UpdateLastName(v)),
//                                     icon: Icons.person_outline,
//                                     error: state.fieldErrors?['last_name'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: size.height * 0.025),

//                             // Username
//                             _field(
//                               label: "Username",
//                               hint: "newuser",
//                               value: state.username,
//                               onChanged: (v) => bloc.add(UpdateUsername(v)),
//                               icon: Icons.alternate_email,
//                               error: state.fieldErrors?['username'],
//                             ),
//                             SizedBox(height: size.height * 0.025),

//                             // Email
//                             _field(
//                               label: "Email",
//                               hint: "yourname@gmail.com",
//                               value: state.email,
//                               onChanged: (v) => bloc.add(UpdateEmail(v)),
//                               isEmail: true,
//                               icon: Icons.email,
//                               error: state.fieldErrors?['email'],
//                             ),
//                             SizedBox(height: size.height * 0.025),

//                             // Phone
//                             _field(
//                               label: "Phone",
//                               hint: "9812345678",
//                               value: state.phone,
//                               onChanged: (v) => bloc.add(UpdatePhone(v)),
//                               keyboard: TextInputType.phone,
//                               icon: Icons.phone_android,
//                               error: state.fieldErrors?['mobile'],
//                             ),
//                             SizedBox(height: size.height * 0.025),

//                             // Password
//                             _field(
//                               label: "Password",
//                               hint: "••••••••",
//                               value: state.password,
//                               onChanged: (v) => bloc.add(UpdatePassword(v)),
//                               isPassword: true,
//                               icon: Icons.lock,
//                               error: state.fieldErrors?['password'],
//                             ),
//                             SizedBox(height: size.height * 0.025),

//                             // Confirm Password
//                             _field(
//                               label: "Confirm Password",
//                               hint: "••••••••",
//                               value: state.confirmPassword,
//                               onChanged: (v) =>
//                                   bloc.add(UpdateConfirmPassword(v)),
//                               isPassword: true,
//                               icon: Icons.lock_outline,
//                               error: state.password != state.confirmPassword
//                                   ? "Passwords don't match"
//                                   : null,
//                             ),
//                             SizedBox(height: size.height * 0.03),

//                             // Terms & Privacy Checkbox
//                             Row(
//                               children: [
//                                 Transform.scale(
//                                   scale: 0.85,
//                                   child: Checkbox(
//                                     value: state.termsAgreed,
//                                     onChanged: (v) =>
//                                         bloc.add(ToggleTerms(v ?? false)),
//                                     activeColor: Colors.orange,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   "I agree to Terms & Privacy",
//                                   style: TextStyle(
//                                     fontFamily: 'Hanken_Grotesk',
//                                     fontSize: size.width * 0.035,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: size.height * 0.04),

//                             // Sign Up Button
//                             SizedBox(
//                               width: double.infinity,
//                               height: size.height * 0.065,
//                               child: ElevatedButton(
//                                 onPressed:
//                                     state.status == SignUpStatus.loading ||
//                                             !state.canSubmit
//                                         ? null
//                                         : () => bloc.add(SubmitRegistration()),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.orange,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   elevation: 0,
//                                 ),
//                                 child: state.status == SignUpStatus.loading
//                                     ? const SizedBox(
//                                         width: 24,
//                                         height: 24,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2.5,
//                                         ),
//                                       )
//                                     : const Text(
//                                         'Sign Up',
//                                         style: TextStyle(
//                                           fontFamily: 'Hanken_Grotesk',
//                                           fontSize: 18,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                               ),
//                             ),

//                             SizedBox(height: size.height * 0.04),

//                             // Login link
//                             Center(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "Already have an account? ",
//                                     style:
//                                         TextStyle(fontSize: size.width * 0.035),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () => context.go('/login'),
//                                     child: Text(
//                                       "Login",
//                                       style: TextStyle(
//                                         fontSize: size.width * 0.035,
//                                         color: Colors.orange,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             SizedBox(height: size.height * 0.04),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _field({
//     required String label,
//     required String hint,
//     required String value,
//     required Function(String) onChanged,
//     IconData? icon,
//     bool isPassword = false,
//     bool isEmail = false,
//     TextInputType? keyboard,
//     String? error,
//   }) {
//     final size = MediaQuery.of(context).size;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontFamily: 'Hanken_Grotesk',
//             fontSize: size.width * 0.035,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextFormField(
//           initialValue: value,
//           obscureText: isPassword,
//           keyboardType:
//               keyboard ?? (isEmail ? TextInputType.emailAddress : null),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               fontSize: size.width * 0.035,
//               color: Colors.grey,
//             ),
//             prefixIcon: icon != null
//                 ? Icon(
//                     icon,
//                     color: Colors.orange,
//                     size: size.width * 0.06,
//                   )
//                 : null,
//             errorText: error,
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
//               horizontal: size.width * 0.04,
//               vertical: size.height * 0.018,
//             ),
//           ),
//           validator: (v) {
//             if (v == null || v.trim().isEmpty) return 'Required';
//             return null;
//           },
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/auth/view/signup/bloc/sign_in_up_event.dart';
import 'package:saleup_app/auth/view/signup/bloc/sign_up_bloc.dart';
import 'package:saleup_app/auth/view/signup/bloc/sign_up_state.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpBloc(),
      child: const _SignUpContent(),
    );
  }
}

class _SignUpContent extends StatefulWidget {
  const _SignUpContent();

  @override
  State<_SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<_SignUpContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state.status == SignUpStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(state.errorMessage ?? 'Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/login');
        } else if (state.status == SignUpStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<SignUpBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Background image + Logo + Back button in a Stack
                  SizedBox(
                    height: screenHeight * 0.4,
                    child: Stack(
                      children: [
                        // Background image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/login_bg.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),

                        // Logo
                        Positioned(
                          top: size.height * 0.04,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/Logo.png',
                              height: size.height * 0.10,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // Back button
                        Positioned(
                          top: 8,
                          left: 4,
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
                      ],
                    ),
                  ),

                  // Form content
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.01,
                      left: size.width * 0.06,
                      right: size.width * 0.06,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/Line.png',
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: size.height * 0.02),

                          // First & Last Name
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  label: "First Name",
                                  hint: "John",
                                  value: state.firstName,
                                  onChanged: (v) =>
                                      bloc.add(UpdateFirstName(v)),
                                  icon: Icons.person,
                                  error: state.fieldErrors?['first_name'],
                                ),
                              ),
                              SizedBox(width: size.width * 0.04),
                              Expanded(
                                child: _field(
                                  label: "Last Name",
                                  hint: "Doe",
                                  value: state.lastName,
                                  onChanged: (v) => bloc.add(UpdateLastName(v)),
                                  icon: Icons.person_outline,
                                  error: state.fieldErrors?['last_name'],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.025),

                          // Username
                          _field(
                            label: "Username",
                            hint: "newuser",
                            value: state.username,
                            onChanged: (v) => bloc.add(UpdateUsername(v)),
                            icon: Icons.alternate_email,
                            error: state.fieldErrors?['username'],
                          ),
                          SizedBox(height: size.height * 0.025),

                          // Email
                          _field(
                            label: "Email",
                            hint: "yourname@gmail.com",
                            value: state.email,
                            onChanged: (v) => bloc.add(UpdateEmail(v)),
                            isEmail: true,
                            icon: Icons.email,
                            error: state.fieldErrors?['email'],
                          ),
                          SizedBox(height: size.height * 0.025),

                          // Phone
                          _field(
                            label: "Phone",
                            hint: "9812345678",
                            value: state.phone,
                            onChanged: (v) => bloc.add(UpdatePhone(v)),
                            keyboard: TextInputType.phone,
                            icon: Icons.phone_android,
                            error: state.fieldErrors?['mobile'],
                          ),
                          SizedBox(height: size.height * 0.025),

                          // Password
                          _field(
                            label: "Password",
                            hint: "••••••••",
                            value: state.password,
                            onChanged: (v) => bloc.add(UpdatePassword(v)),
                            isPassword: true,
                            icon: Icons.lock,
                            error: state.fieldErrors?['password'],
                          ),
                          SizedBox(height: size.height * 0.025),

                          // Confirm Password
                          _field(
                            label: "Confirm Password",
                            hint: "••••••••",
                            value: state.confirmPassword,
                            onChanged: (v) =>
                                bloc.add(UpdateConfirmPassword(v)),
                            isPassword: true,
                            icon: Icons.lock_outline,
                            error: state.password != state.confirmPassword
                                ? "Passwords don't match"
                                : null,
                          ),
                          SizedBox(height: size.height * 0.03),

                          // Terms & Privacy Checkbox
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.85,
                                child: Checkbox(
                                  value: state.termsAgreed,
                                  onChanged: (v) =>
                                      bloc.add(ToggleTerms(v ?? false)),
                                  activeColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              Text(
                                "I agree to Terms & Privacy",
                                style: TextStyle(
                                  fontFamily: 'Hanken_Grotesk',
                                  fontSize: size.width * 0.035,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.04),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: size.height * 0.065,
                            child: ElevatedButton(
                              onPressed: state.status == SignUpStatus.loading ||
                                      !state.canSubmit
                                  ? null
                                  : () => bloc.add(SubmitRegistration()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: state.status == SignUpStatus.loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontFamily: 'Hanken_Grotesk',
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: size.height * 0.04),

                          // Login link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style:
                                      TextStyle(fontSize: size.width * 0.035),
                                ),
                                GestureDetector(
                                  onTap: () => context.go('/login'),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: size.width * 0.035,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 0.04),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required String value,
    required Function(String) onChanged,
    IconData? icon,
    bool isPassword = false,
    bool isEmail = false,
    TextInputType? keyboard,
    String? error,
  }) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Hanken_Grotesk',
            fontSize: size.width * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          obscureText: isPassword,
          keyboardType:
              keyboard ?? (isEmail ? TextInputType.emailAddress : null),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.grey,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: Colors.orange,
                    size: size.width * 0.06,
                  )
                : null,
            errorText: error,
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
              horizontal: size.width * 0.04,
              vertical: size.height * 0.018,
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            return null;
          },
        ),
      ],
    );
  }
}
