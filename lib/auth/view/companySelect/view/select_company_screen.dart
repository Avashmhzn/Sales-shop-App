// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/auth/view/companySelect/bloc/company_bloc.dart';
// import 'package:saleup_app/auth/view/companySelect/bloc/company_event.dart';
// import 'package:saleup_app/auth/view/companySelect/bloc/company_state.dart';
// import 'package:saleup_app/core/network/api_endpoints.dart';

// class CompanySelectionScreen extends StatelessWidget {
//   const CompanySelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     return BlocProvider(
//       create: (context) => CompanyBloc()..add(const LoadUserCompanies()),
//       child: Scaffold(
//         body: SafeArea(
//           child: Stack(
//             children: [
//               // Background image
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 height: screenHeight * 0.4,
//                 child: Image.asset(
//                   'assets/images/login_bg.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),

//               // Logo
//               Positioned(
//                 top: screenHeight * 0.03,
//                 left: 0,
//                 right: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Image.asset(
//                     'assets/images/Logo.png',
//                     height: screenHeight * 0.10,
//                   ),
//                 ),
//               ),

//               // Back button
//               Positioned(
//                 top: 8,
//                 left: 4,
//                 child: IconButton(
//                   icon: Image.asset(
//                     'assets/images/back_button_logo.png',
//                     width: 50,
//                     height: 50,
//                   ),
//                   onPressed: () => context.go('/onboarding'),
//                 ),
//               ),

//               // Main content
//               Positioned.fill(
//                 top: screenHeight * 0.38,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius:
//                         BorderRadius.vertical(top: Radius.circular(36)),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // Header text
//                       const Padding(
//                         padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Select Company',
//                               style: TextStyle(
//                                 fontSize: 26,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               'Choose Company',
//                               style:
//                                   TextStyle(fontSize: 15, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Company list or states
//                       Expanded(
//                         child: BlocBuilder<CompanyBloc, CompanyState>(
//                           builder: (context, state) {
//                             if (state.isLoading) {
//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             }

//                             if (state.errorMessage != null) {
//                               return Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(24.0),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Icon(
//                                         Icons.error_outline,
//                                         size: 64,
//                                         color: Colors.redAccent,
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Text(
//                                         state.errorMessage!,
//                                         textAlign: TextAlign.center,
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           color: Colors.redAccent,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 24),
//                                       OutlinedButton(
//                                         onPressed: () {
//                                           context
//                                               .read<CompanyBloc>()
//                                               .add(const LoadUserCompanies());
//                                         },
//                                         child: const Text('Try Again'),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }

//                             if (state.companies.isEmpty) {
//                               return Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(32.0),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.business_outlined,
//                                         size: 80,
//                                         color: Colors.grey[400],
//                                       ),
//                                       const SizedBox(height: 24),
//                                       const Text(
//                                         'No companies found',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 12),
//                                       const Text(
//                                         'You don\'t have any registered companies yet.\nContact support or create a new one.',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 32),
//                                       // Optional: button to create company (uncomment when ready)
//                                       // OutlinedButton.icon(
//                                       //   icon: const Icon(Icons.add_business),
//                                       //   label: const Text('Add New Company'),
//                                       //   onPressed: () {
//                                       //     // TODO: navigate to create company screen
//                                       //   },
//                                       // ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }

//                             // Companies list
//                             return ListView.builder(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 24),
//                               itemCount: state.companies.length,
//                               itemBuilder: (context, index) {
//                                 final company = state.companies[index];
//                                 final isSelected =
//                                     state.selectedCompany?.id == company.id;

//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 16),
//                                   child: InkWell(
//                                     onTap: () {
//                                       context
//                                           .read<CompanyBloc>()
//                                           .add(SelectCompany(company.id));
//                                       Api.switchToPrivate(company
//                                           .domain); // switch domain immediately
//                                       Future.microtask(() {
//                                         if (context.mounted)
//                                           context.go('/home');
//                                       });
//                                     },
//                                     borderRadius: BorderRadius.circular(16),
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 14,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: isSelected
//                                               ? Colors.orange
//                                               : Colors.grey.shade300,
//                                           width: isSelected ? 2 : 1,
//                                         ),
//                                         borderRadius: BorderRadius.circular(16),
//                                         color: isSelected
//                                             ? Colors.orange.withOpacity(0.05)
//                                             : null,
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           CircleAvatar(
//                                             radius: 30,
//                                             backgroundColor:
//                                                 Colors.blue.shade700,
//                                             child: const Icon(
//                                               Icons.business,
//                                               color: Colors.white,
//                                               size: 36,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 16),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   company.displayName,
//                                                   style: const TextStyle(
//                                                     fontSize: 17,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 3),
//                                                 Text(
//                                                   company.domain ??
//                                                       'No domain set',
//                                                   style: TextStyle(
//                                                     fontSize: 13,
//                                                     color: Colors.grey[600],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           if (isSelected)
//                                             const Icon(
//                                               Icons.check_circle,
//                                               color: Colors.green,
//                                               size: 28,
//                                             )
//                                           else
//                                             const Icon(
//                                               Icons.chevron_right,
//                                               color: Colors.grey,
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // new code
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/auth/view/companySelect/bloc/company_bloc.dart';
// import 'package:saleup_app/auth/view/companySelect/bloc/company_event.dart';
// import 'package:saleup_app/auth/view/companySelect/bloc/company_state.dart';
// import 'package:saleup_app/core/network/api_endpoints.dart';
// import 'package:saleup_app/services/auth_service.dart';

// class CompanySelectionScreen extends StatelessWidget {
//   const CompanySelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     return BlocProvider(
//       create: (context) => CompanyBloc()..add(const LoadUserCompanies()),
//       child: Scaffold(
//         body: SafeArea(
//           child: Stack(
//             children: [
//               // Background image
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 height: screenHeight * 0.4,
//                 child: Image.asset(
//                   'assets/images/login_bg.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),

//               // Logo
//               Positioned(
//                 top: screenHeight * 0.03,
//                 left: 0,
//                 right: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Image.asset(
//                     'assets/images/Logo.png',
//                     height: screenHeight * 0.10,
//                   ),
//                 ),
//               ),

//               // Back button
//               Positioned(
//                 top: 8,
//                 left: 8,
//                 child: IconButton(
//                   icon: Image.asset(
//                     'assets/images/back_button_logo.png',
//                     width: 50,
//                     height: 50,
//                   ),
//                   onPressed: () => context.go('/onboarding'),
//                 ),
//               ),

//               // Main content
//               Positioned.fill(
//                 top: screenHeight * 0.34,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Header text
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFFE8E0FF),
//                               shape: BoxShape.circle,
//                             ),
//                             alignment: Alignment.center,
//                             child: ClipOval(
//                               child: Image.asset(
//                                 'assets/images/comp.png',
//                                 width: 50,
//                                 height: 50,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 'Select Company',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               // SizedBox(height: 1),
//                               Text(
//                                 'Choose Company',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Line separator
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       child: Image.asset(
//                         'assets/images/Line.png',
//                         height: 2,
//                         width: double.infinity,
//                         fit: BoxFit.fill,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     // Profile section - placeholder avatar (person icon)
//                     FutureBuilder<Map<String, String?>>(
//                       future: _getUserInfo(),
//                       builder: (context, snapshot) {
//                         final username = snapshot.data?['username'] ?? 'AAVASH';
//                         final email =
//                             snapshot.data?['email'] ?? 'aavash@gmail.com';

//                         return Padding(
//                           padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
//                           child: Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 28,
//                                 backgroundColor: Colors.grey.shade200,
//                                 child: const Icon(
//                                   Icons.person,
//                                   size: 36,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       username,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     Text(
//                                       email,
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         color: Colors.grey[700],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 60),
//                           child: Image.asset(
//                             'assets/images/Line.png',
//                             height: 2,
//                             width: double.infinity,
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                         Transform.translate(
//                           offset: const Offset(0, -10), // move up by 8
//                           child: Container(
//                             color: Colors.transparent,
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             child: const Text(
//                               'Select Company',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     // Company list or states
//                     Expanded(
//                       child: BlocBuilder<CompanyBloc, CompanyState>(
//                         builder: (context, state) {
//                           if (state.isLoading) {
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           }

//                           if (state.errorMessage != null) {
//                             return Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(24.0),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.error_outline,
//                                       size: 64,
//                                       color: Colors.redAccent,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Text(
//                                       state.errorMessage!,
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.redAccent,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 24),
//                                     OutlinedButton(
//                                       onPressed: () {
//                                         context
//                                             .read<CompanyBloc>()
//                                             .add(const LoadUserCompanies());
//                                       },
//                                       child: const Text('Try Again'),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }

//                           if (state.companies.isEmpty) {
//                             return Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(32.0),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.business_outlined,
//                                       size: 80,
//                                       color: Colors.grey[400],
//                                     ),
//                                     const SizedBox(height: 24),
//                                     const Text(
//                                       'No companies found',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
//                                     const Text(
//                                       'You don\'t have any registered companies yet.\nContact support or create a new one.',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 32),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }

//                           // Companies list - comp.png is used here
//                           return ListView.builder(
//                             padding: const EdgeInsets.symmetric(horizontal: 24),
//                             itemCount: state.companies.length,
//                             itemBuilder: (context, index) {
//                               final company = state.companies[index];
//                               final isSelected =
//                                   state.selectedCompany?.id == company.id;

//                               return Padding(
//                                 padding: const EdgeInsets.only(bottom: 16),
//                                 child: InkWell(
//                                   onTap: () {
//                                     context
//                                         .read<CompanyBloc>()
//                                         .add(SelectCompany(company.id));
//                                     Api.switchToPrivate(company.domain);
//                                     Future.microtask(() {
//                                       if (context.mounted) context.go('/home');
//                                     });
//                                   },
//                                   borderRadius: BorderRadius.circular(16),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                       vertical: 8,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: isSelected
//                                             ? Colors.orange
//                                             : Colors.grey.shade300,
//                                         width: isSelected ? 2 : 1,
//                                       ),
//                                       borderRadius: BorderRadius.circular(20),
//                                       color: isSelected
//                                           ? Colors.orange.withOpacity(0.05)
//                                           : null,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         // comp.png used here for company icon
//                                         Container(
//                                           width: 50,
//                                           height: 50,
//                                           decoration: BoxDecoration(
//                                             color: Colors.black,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                           ),
//                                           child: Center(
//                                             child: Image.asset(
//                                               'assets/images/sales_up_logo.png',
//                                               width: 50,
//                                               height: 50,
//                                               fit: BoxFit.contain,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 company.displayName,
//                                                 style: const TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 3),
//                                               Text(
//                                                 company.domain ??
//                                                     'No domain set',
//                                                 style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: Colors.grey[600],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         if (isSelected)
//                                           const Icon(
//                                             Icons.check_circle,
//                                             color: Colors.green,
//                                             size: 28,
//                                           )
//                                         else
//                                           const Icon(
//                                             Icons.chevron_right,
//                                             color: Colors.grey,
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<Map<String, String?>> _getUserInfo() async {
//     final authService = AuthService();
//     final username = await authService.getUsername();
//     final email = await authService.getEmail();

//     return {
//       'username': username,
//       'email': email,
//     };
//   }
// }

//deisgn fixed
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/auth/view/companySelect/bloc/company_bloc.dart';
import 'package:saleup_app/auth/view/companySelect/bloc/company_event.dart';
import 'package:saleup_app/auth/view/companySelect/bloc/company_state.dart';
import 'package:saleup_app/core/navigation/app_routes.dart';
import 'package:saleup_app/core/network/api_endpoints.dart';
import 'package:saleup_app/services/auth_service.dart';

class CompanySelectionScreen extends StatelessWidget {
  const CompanySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => CompanyBloc()..add(const LoadUserCompanies()),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Background image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: screenHeight * 0.4,
                child: Image.asset(
                  'assets/images/login_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Logo
              Positioned(
                top: screenHeight * 0.07,
                left: 10,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    height: screenHeight * 0.11,
                  ),
                ),
              ),

              // Back button
              Positioned(
                top: 25,
                left: 1,
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/back_button_logo.png',
                    width: 60,
                    height: 60,
                  ),
                  onPressed: () => context.go('/onboarding'),
                ),
              ),

              // Main content
              Positioned.fill(
                top: screenHeight * 0.34,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header text
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8E0FF),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/comp.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Select Company',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Choose Company',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Line separator
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Image.asset(
                          'assets/images/Line.png',
                          height: 2,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Profile section
                      FutureBuilder<Map<String, String?>>(
                        future: _getUserInfo(),
                        builder: (context, snapshot) {
                          final username = snapshot.data?['username'] ?? 'USER';
                          final email =
                              snapshot.data?['email'] ?? 'user@gmail.com';

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.person,
                                    size: 36,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Select Company divider with text
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60),
                            child: Image.asset(
                              'assets/images/Line.png',
                              height: 2,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -10),
                            child: Container(
                              color: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: const Text(
                                'Select Company',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Company list
                      BlocBuilder<CompanyBloc, CompanyState>(
                        builder: (context, state) {
                          if (state.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (state.errorMessage != null) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    OutlinedButton(
                                      onPressed: () {
                                        context
                                            .read<CompanyBloc>()
                                            .add(const LoadUserCompanies());
                                      },
                                      child: const Text('Try Again'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (state.companies.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.business_outlined,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'No companies found',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'You don\'t have any registered companies yet.\nContact support or create a new one.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.companies.length,
                            itemBuilder: (context, index) {
                              final company = state.companies[index];
                              final isSelected =
                                  state.selectedCompany?.id == company.id;

                              return RepaintBoundary(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: InkWell(
                                    onTap: () {
                                      context
                                          .read<CompanyBloc>()
                                          .add(SelectCompany(company.id));
                                      Api.switchToPrivate(company.domain);
                                      Future.microtask(() {
                                        if (context.mounted) {
                                          context.go('/home');
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.orange
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        color: isSelected
                                            ? Colors.orange.withValues(alpha: 0.05)
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/sales_up_logo.png',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  company.displayName,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  company.domain ??
                                                      'No domain set',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 28,
                                            )
                                          else
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_business),
                          label: const Text('Create Company'),
                          onPressed: () =>
                              context.push(AppRoutes.createCompany),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, String?>> _getUserInfo() async {
    final authService = AuthService();
    final username = await authService.getUsername();
    final email = await authService.getEmail();

    return {
      'username': username,
      'email': email,
    };
  }
}
