// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
// import 'package:saleup_app/screen/expiry/bloc/expiry_event.dart';
// import 'package:saleup_app/screen/expiry/bloc/expiry_state.dart';
// import 'package:saleup_app/model/expiry_response.dart';

// class ExpiryScreen extends StatefulWidget {
//   const ExpiryScreen({super.key});

//   @override
//   State<ExpiryScreen> createState() => _ExpiryScreenState();
// }

// class _ExpiryScreenState extends State<ExpiryScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       context.read<ExpiryBloc>().add(const FetchExpiry());
//     });
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         context.read<ExpiryBloc>().add(SearchExpiry(query));
//       }
//     });
//   }

//   void showFilterBottomSheet(BuildContext context) {
//     _animationController.forward();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.grey[850],
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//       ),
//       transitionAnimationController: _animationController,
//       isScrollControlled: true,
//       builder: (BuildContext sheetContext) {
//         return BlocProvider.value(
//           value: context.read<ExpiryBloc>(),
//           child: BlocBuilder<ExpiryBloc, ExpiryState>(
//             builder: (sheetContext, state) {
//               // Safeguard against null or empty expiryData
//               final expiryData = state.expiryData;
//               final uniqueProducts = expiryData
//                   .map((e) => e.product)
//                   .where((p) => p != null && p.isNotEmpty)
//                   .toSet()
//                   .toList()
//                 ..sort();

//               return Container(
//                 height: 650,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[850],
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(15)),
//                 ),
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Filters',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     const Text(
//                       'Expiry Date',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Wrap(
//                       spacing: 6.0,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             if (mounted) {
//                               context.read<ExpiryBloc>().add(const SortExpiry(
//                                   'Expiry Date', 'High to Low'));
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 state.tempSortCriteria['Expiry Date'] ==
//                                         'High to Low'
//                                     ? Colors.brown[700]
//                                     : Colors.grey[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 6),
//                           ),
//                           child: const Text('High to Low'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             if (mounted) {
//                               context.read<ExpiryBloc>().add(const SortExpiry(
//                                   'Expiry Date', 'Low to High'));
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 state.tempSortCriteria['Expiry Date'] ==
//                                         'Low to High'
//                                     ? Colors.brown[700]
//                                     : Colors.grey[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 6),
//                           ),
//                           child: const Text('Low to High'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     const Text(
//                       'Quantity',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Wrap(
//                       spacing: 6.0,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             if (mounted) {
//                               context.read<ExpiryBloc>().add(
//                                   const SortExpiry('Quantity', 'High to Low'));
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 state.tempSortCriteria['Quantity'] ==
//                                         'High to Low'
//                                     ? Colors.brown[700]
//                                     : Colors.grey[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 6),
//                           ),
//                           child: const Text('High to Low'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             if (mounted) {
//                               context.read<ExpiryBloc>().add(
//                                   const SortExpiry('Quantity', 'Low to High'));
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 state.tempSortCriteria['Quantity'] ==
//                                         'Low to High'
//                                     ? Colors.brown[700]
//                                     : Colors.grey[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 6),
//                           ),
//                           child: const Text('Low to High'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     const Text(
//                       'Selling Price',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Wrap(
//                       spacing: 6.0,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             if (mounted) {
//                               context.read<ExpiryBloc>().add(const SortExpiry(
//                                   'Selling Price', 'High to Low'));
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 state.tempSortCriteria['Selling Price'] ==
//                                         'High to Low'
//                                     ? Colors.brown[700]
//                                     : Colors.grey[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 6),
//                           ),
//                           child: const Text('High to Low'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             if (mounted) {
//                               context.read<ExpiryBloc>().add(const SortExpiry(
//                                   'Selling Price', 'Low to High'));
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 state.tempSortCriteria['Selling Price'] ==
//                                         'Low to High'
//                                     ? Colors.brown[700]
//                                     : Colors.grey[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 6),
//                           ),
//                           child: const Text('Low to High'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     const Text(
//                       'Product',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Wrap(
//                       spacing: 6.0,
//                       children: [
//                         for (var product in [null, ...uniqueProducts])
//                           ElevatedButton(
//                             onPressed: () {
//                               if (mounted) {
//                                 context
//                                     .read<ExpiryBloc>()
//                                     .add(SortExpiry('Product', product ?? ''));
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   state.tempSortCriteria['Product'] == product
//                                       ? Colors.brown[700]
//                                       : Colors.grey[700],
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 6),
//                             ),
//                             child: Text(product ?? 'All'),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (mounted) {
//                           context.read<ExpiryBloc>().add(const ApplyFilters());
//                           Navigator.pop(sheetContext);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.brown[700],
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 6),
//                       ),
//                       child: const Text('Apply Filters'),
//                     ),
//                     const SizedBox(height: 6),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (mounted) {
//                           context.read<ExpiryBloc>().add(const SortExpiry(
//                               'Expiry Date', '',
//                               remove: true));
//                           context.read<ExpiryBloc>().add(
//                               const SortExpiry('Quantity', '', remove: true));
//                           context.read<ExpiryBloc>().add(const SortExpiry(
//                               'Selling Price', '',
//                               remove: true));
//                           context.read<ExpiryBloc>().add(
//                               const SortExpiry('Product', '', remove: true));
//                           context.read<ExpiryBloc>().add(const ApplyFilters());
//                           Navigator.pop(sheetContext);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[700],
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 6),
//                       ),
//                       child: const Text('Clear All Filters'),
//                     ),
//                     if (state.tempSortCriteria.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 6.0),
//                         child: Text(
//                           'Selected: ${state.tempSortCriteria.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
//                           style: const TextStyle(
//                               color: Colors.yellow,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     ).whenComplete(() {
//       if (mounted) {
//         _animationController.reset();
//       }
//     });
//   }

//   Widget _buildSkeletonLoader(double screenWidth, double screenHeight) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 5,
//       itemBuilder: (context, index) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
//         child: Card(
//           elevation: 4,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Container(
//             height: 100,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: BlocConsumer<ExpiryBloc, ExpiryState>(
//         listener: (context, state) {
//           if (state.errorMessage != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text(state.errorMessage!),
//                   backgroundColor: Colors.red),
//             );
//           }
//         },
//         builder: (context, state) {
//           final filteredData = state.getFilteredData();
//           final itemsPerPage = state.itemsPerPage.toDouble();
//           final totalPages = filteredData.isNotEmpty
//               ? (filteredData.length / itemsPerPage).ceil()
//               : 1;
//           final validCurrentPage = (state.currentPage).clamp(1, totalPages);
//           final startIndex = ((validCurrentPage - 1) * state.itemsPerPage)
//               .clamp(0, filteredData.length);
//           final endIndex =
//               (startIndex + state.itemsPerPage).clamp(0, filteredData.length);
//           final paginatedData = filteredData.isNotEmpty
//               ? filteredData.sublist(startIndex, endIndex)
//               : [];

//           return LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxHeight: screenHeight),
//                   child: Padding(
//                     padding: EdgeInsets.all(screenWidth * 0.02),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           "Expiry Management",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.05,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: screenWidth * 0.01),
//                         Padding(
//                           padding: EdgeInsets.all(screenWidth * 0.02),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: SizedBox(
//                                   height: 50,
//                                   child: TextField(
//                                     controller: _searchController,
//                                     decoration: InputDecoration(
//                                       labelText: 'Search by Product or Batch',
//                                       prefixIcon: const Icon(Icons.search),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                         vertical: 8,
//                                         horizontal: 12,
//                                       ),
//                                     ),
//                                     onChanged: _onSearchChanged,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               IconButton(
//                                 icon: Image.asset(
//                                   'assets/icons/filter.png',
//                                   width: 24,
//                                   height: 24,
//                                   color: Colors.grey,
//                                 ),
//                                 onPressed: () => showFilterBottomSheet(context),
//                                 style: IconButton.styleFrom(
//                                   side: const BorderSide(color: Colors.grey),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: state.isLoading
//                               ? _buildSkeletonLoader(screenWidth, screenHeight)
//                               : paginatedData.isEmpty
//                                   ? const Center(
//                                       child: Text("No expiry data found"))
//                                   : ListView.builder(
//                                       shrinkWrap: true,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       itemCount: paginatedData.length,
//                                       itemBuilder: (context, index) {
//                                         final expiry = paginatedData[index];
//                                         print('Rendering Expiry: $expiry');
//                                         return ExpiryCard(
//                                           expiry: expiry,
//                                           screenWidth: screenWidth,
//                                           screenHeight: screenHeight,
//                                         );
//                                       },
//                                     ),
//                         ),
//                         if (!state.isLoading && totalPages > 1)
//                           Padding(
//                             padding: EdgeInsets.symmetric(
//                                 vertical: screenWidth * 0.01),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 IconButton(
//                                     icon: const Icon(Icons.first_page),
//                                     onPressed: validCurrentPage > 1
//                                         ? () => context
//                                             .read<ExpiryBloc>()
//                                             .add(const GoToPage(1))
//                                         : null),
//                                 const SizedBox(width: 5),
//                                 IconButton(
//                                     icon: const Icon(Icons.arrow_back),
//                                     onPressed: validCurrentPage > 1
//                                         ? () => context
//                                             .read<ExpiryBloc>()
//                                             .add(GoToPage(validCurrentPage - 1))
//                                         : null),
//                                 const SizedBox(width: 5),
//                                 Text('$validCurrentPage of $totalPages'),
//                                 const SizedBox(width: 5),
//                                 IconButton(
//                                     icon: const Icon(Icons.arrow_forward),
//                                     onPressed: validCurrentPage < totalPages
//                                         ? () => context
//                                             .read<ExpiryBloc>()
//                                             .add(GoToPage(validCurrentPage + 1))
//                                         : null),
//                                 const SizedBox(width: 5),
//                                 IconButton(
//                                     icon: const Icon(Icons.last_page),
//                                     onPressed: validCurrentPage < totalPages
//                                         ? () => context
//                                             .read<ExpiryBloc>()
//                                             .add(GoToPage(totalPages))
//                                         : null),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class ExpiryCard extends StatelessWidget {
//   final ExpiryData expiry;
//   final double screenWidth;
//   final double screenHeight;

//   const ExpiryCard({
//     super.key,
//     required this.expiry,
//     required this.screenWidth,
//     required this.screenHeight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     print('Building ExpiryCard with batchNumber: ${expiry.batchNumber}');
//     return GestureDetector(
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (context) => Dialog(
//             insetPadding: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.03,
//               vertical: screenHeight * 0.1,
//             ),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               width: screenWidth * 0.9,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 4),
//                           child: Text(
//                             'Product: ${expiry.product ?? 'N/A'}',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headlineSmall
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close, color: Colors.grey),
//                         onPressed: () => Navigator.pop(context),
//                         padding: EdgeInsets.zero,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   _buildDetailRow(context, 'ID', '${expiry.id ?? 'N/A'}'),
//                   _buildDetailRow(context, 'Batch Number',
//                       expiry.batchNumber ?? 'N/A'),
//                   _buildDetailRow(context, 'Expiry Date',
//                       expiry.expiryDate?.toIso8601String().split('T')[0] ?? 'N/A'),
//                   _buildDetailRow(context, 'Selling Price',
//                       'NPR ${expiry.sellingPrice?.toStringAsFixed(2) ?? '0.00'}'),
//                   _buildDetailRow(
//                       context, 'Quantity', '${expiry.quantity ?? 0}'),
//                   _buildDetailRow(context, 'Cost Price',
//                       'NPR ${expiry.costPrice?.toStringAsFixed(2) ?? '0.00'}'),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
//         child: Card(
//           elevation: 4,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         expiry.product ?? 'N/A',
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Text(
//                       'ID: ${expiry.id ?? 'N/A'}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium
//                           ?.copyWith(fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.end,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       expiry.batchNumber ?? 'N/A',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       expiry.expiryDate?.toIso8601String().split('T')[0] ?? 'N/A',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                       textAlign: TextAlign.end,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'NPR ${expiry.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                     ),
//                     Text(
//                       '${expiry.quantity ?? 0}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                       textAlign: TextAlign.end,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(BuildContext context, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: RichText(
//         text: TextSpan(
//           text: '$label: ',
//           style: Theme.of(context)
//               .textTheme
//               .bodyMedium
//               ?.copyWith(fontWeight: FontWeight.bold),
//           children: [
//             TextSpan(
//               text: value,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/screen/expiry/view/expiry_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/model/expiry_response.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_event.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_state.dart';
import 'package:saleup_app/screen/expiry/view/add_expiry_screen.dart';

class ExpiryScreen extends StatefulWidget {
  const ExpiryScreen({super.key});

  @override
  State<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String? _expandedSection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ExpiryBloc>().add(const FetchExpiry());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<ExpiryBloc>().add(SearchExpiry(query));
    });
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  void _clearAllFilters() {
    context.read<ExpiryBloc>().add(const ClearFilters());
    setState(() => _expandedSection = null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: BlocConsumer<ExpiryBloc, ExpiryState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildTopBar(context, state),
                  _buildFilterPanel(context, state),
                  _buildTableCard(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ====================== HEADER ======================
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expiry',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Set up expiry for products and track product expiry dates',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ====================== TOP BAR ======================
  Widget _buildTopBar(BuildContext context, ExpiryState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          SizedBox(
            width: 190,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by product or batch…',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey[400], size: 18),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              // FIX: rootNavigator:true so GoRouter doesn't intercept the push
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ExpiryBloc>(),
                    child: const AddExpiryScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text(
              'New Expiry',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ====================== FILTER PANEL ======================
  Widget _buildFilterPanel(BuildContext context, ExpiryState state) {
    final hasActive = state.selectedProduct != null ||
        state.priceSort != null ||
        state.quantitySort != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // ================== PRODUCT FILTER (Dynamic - No Hardcode) ==================
            _buildFilterSection(
              title: 'Product',
              isExpanded: _expandedSection == 'product',
              onTap: () => _toggleSection('product'),
              children: state.uniqueProducts.map((product) {
                return _filterOption(
                  label: product,
                  selected: state.selectedProduct == product,
                  onTap: () {
                    final newProduct =
                        state.selectedProduct == product ? null : product;
                    context
                        .read<ExpiryBloc>()
                        .add(ToggleProductFilter(newProduct));
                    setState(() => _expandedSection = null);
                  },
                );
              }).toList(),
            ),

            // ================== PRICE FILTER ==================
            _buildFilterSection(
              title: 'Price',
              isExpanded: _expandedSection == 'price',
              onTap: () => _toggleSection('price'),
              children: [
                _filterOption(
                  label: 'High to Low',
                  selected: state.priceSort == 'High to Low',
                  onTap: () {
                    final newSort =
                        state.priceSort == 'High to Low' ? null : 'High to Low';
                    context.read<ExpiryBloc>().add(SetPriceSort(newSort));
                    setState(() => _expandedSection = null);
                  },
                ),
                _filterOption(
                  label: 'Low to High',
                  selected: state.priceSort == 'Low to High',
                  onTap: () {
                    final newSort =
                        state.priceSort == 'Low to High' ? null : 'Low to High';
                    context.read<ExpiryBloc>().add(SetPriceSort(newSort));
                    setState(() => _expandedSection = null);
                  },
                ),
              ],
            ),

            // ================== QUANTITY FILTER ==================
            _buildFilterSection(
              title: 'Quantity',
              isExpanded: _expandedSection == 'quantity',
              onTap: () => _toggleSection('quantity'),
              children: [
                _filterOption(
                  label: 'High to Low',
                  selected: state.quantitySort == 'High to Low',
                  onTap: () {
                    final newSort = state.quantitySort == 'High to Low'
                        ? null
                        : 'High to Low';
                    context.read<ExpiryBloc>().add(SetQuantitySort(newSort));
                    setState(() => _expandedSection = null);
                  },
                ),
                _filterOption(
                  label: 'Low to High',
                  selected: state.quantitySort == 'Low to High',
                  onTap: () {
                    final newSort = state.quantitySort == 'Low to High'
                        ? null
                        : 'Low to High';
                    context.read<ExpiryBloc>().add(SetQuantitySort(newSort));
                    setState(() => _expandedSection = null);
                  },
                ),
              ],
            ),

            if (hasActive) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _clearAllFilters,
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }

  Widget _filterOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? const Color(0xFF4CAF50) : const Color(0xFF555555),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ====================== TABLE CARD ======================
  Widget _buildTableCard(BuildContext context, ExpiryState state) {
    // Sort ascending by ID (nulls last)
    final filtered = state.getFilteredData()
      ..sort((a, b) => (a.id ?? double.maxFinite.toInt())
          .compareTo(b.id ?? double.maxFinite.toInt()));
    final totalPages =
        filtered.isEmpty ? 1 : (filtered.length / state.itemsPerPage).ceil();
    final page = state.currentPage.clamp(1, totalPages);
    final start = ((page - 1) * state.itemsPerPage).clamp(0, filtered.length);
    final end = (start + state.itemsPerPage).clamp(0, filtered.length);
    final pageData = filtered.sublist(start, end);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 4),
              child: GestureDetector(
                // FIX: disabled + guarded when no data
                onTap:
                    filtered.isEmpty ? null : () => _confirmDeleteAll(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline,
                        size: 14,
                        color: filtered.isEmpty
                            ? Colors.grey[400]
                            : Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Delete All',
                      style: TextStyle(
                        fontSize: 12,
                        color: filtered.isEmpty
                            ? Colors.grey[400]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(),
                state.isLoading
                    ? _buildSkeleton()
                    : pageData.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 40, horizontal: 24),
                            child: Text(
                              'No expiry data found',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        : Column(
                            children: List.generate(
                              pageData.length,
                              (i) => _buildTableRow(context, pageData[i], i),
                            ),
                          ),
              ],
            ),
          ),
          if (!state.isLoading && totalPages > 1)
            _buildPagination(context, page, totalPages),
        ],
      ),
    );
  }

  static const double _colId = 30;
  static const double _colProduct = 70;
  static const double _colBatch = 100;
  static const double _colExpiry = 80;
  static const double _colStatus = 90;
  static const double _colPrice = 100;
  static const double _colQty = 70;
  static const double _colAction = 150;

  Widget _buildTableHeader() {
    const style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF555555),
    );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 40, child: SizedBox(height: 40)),
          _hCell('ID', width: _colId, style: style),
          _hCell('Product', width: _colProduct, style: style),
          _hCell('Batch Number', width: _colBatch, style: style),
          _hCell('Expiry Date', width: _colExpiry, style: style),
          _hCell('Is Expired', width: _colStatus, style: style),
          _hCell('Selling Price', width: _colPrice, style: style),
          _hCell('Quantity', width: _colQty, style: style),
          _hCell('Action', width: _colAction, style: style),
        ],
      ),
    );
  }

  Widget _hCell(String label,
      {required double width, required TextStyle style}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(label, style: style),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, ExpiryData item, int index) {
    final isExpired = item.isExpired ?? false;
    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFAFAFA),
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(value: false, onChanged: (_) {}),
          ),
          _dCell('${item.id ?? '-'}', width: _colId),
          _dCell(item.product ?? '-', width: _colProduct),
          _dCell(item.batchNumber ?? '-', width: _colBatch),
          _dCell(
            item.expiryDate != null
                ? item.expiryDate!.toIso8601String().split('T')[0]
                : '-',
            width: _colExpiry,
          ),
          SizedBox(
            width: _colStatus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isExpired
                      ? const Color(0xFFFFEBEB)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isExpired ? 'Expired' : 'Valid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isExpired
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF388E3C),
                  ),
                ),
              ),
            ),
          ),
          _dCell(
            'NPR ${item.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
            width: _colPrice,
          ),
          _dCell('${item.quantity ?? 0}', width: _colQty),
          SizedBox(
            width: _colAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 17, color: Colors.grey),
                  // FIX: null-guard on id
                  onPressed: item.id == null
                      ? null
                      : () => _showEditDialog(context, item),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined,
                      size: 17, color: Colors.grey),
                  onPressed: () => _showDetailDialog(context, item),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 17, color: Colors.grey),
                  // FIX: null-guard on id
                  onPressed: item.id == null
                      ? null
                      : () => _confirmDelete(context, item.id!),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dCell(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // ====================== PAGINATION ======================
  Widget _buildPagination(
      BuildContext context, int currentPage, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: currentPage > 1
                ? () =>
                    context.read<ExpiryBloc>().add(GoToPage(currentPage - 1))
                : null,
          ),
          for (int i = 1; i <= totalPages; i++)
            GestureDetector(
              onTap: () => context.read<ExpiryBloc>().add(GoToPage(i)),
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: i == currentPage
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$i',
                    style: TextStyle(
                      fontSize: 13,
                      color: i == currentPage
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF555555),
                      fontWeight: i == currentPage
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: currentPage < totalPages
                ? () =>
                    context.read<ExpiryBloc>().add(GoToPage(currentPage + 1))
                : null,
          ),
        ],
      ),
    );
  }

  // ====================== SKELETON ======================
  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        6,
        (_) => Container(
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // ====================== DETAIL DIALOG ======================
  void _showDetailDialog(BuildContext context, ExpiryData item) {
    showDialog(
      context: context,
      // FIX: useRootNavigator:true pushes dialog onto the root Navigator,
      // so closing it never touches GoRouter's page stack.
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          item.product ?? 'N/A',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('ID', '${item.id ?? '-'}'),
            _detailRow('Batch Number', item.batchNumber ?? '-'),
            _detailRow(
              'Expiry Date',
              item.expiryDate?.toIso8601String().split('T')[0] ?? '-',
            ),
            _detailRow(
              'Selling Price',
              'NPR ${item.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
            ),
            _detailRow(
              'Cost Price',
              'NPR ${item.costPrice?.toStringAsFixed(2) ?? '0.00'}',
            ),
            _detailRow('Quantity', '${item.quantity ?? 0}'),
            _detailRow('Is Expired', item.isExpired == true ? 'Yes' : 'No'),
          ],
        ),
        actions: [
          TextButton(
            // FIX: use dialogCtx — only closes the dialog, not the page
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ====================== EDIT DIALOG ======================
  void _showEditDialog(BuildContext context, ExpiryData item) {
    // Replace the body of this dialog with your real edit form/sheet.
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit Expiry'),
        content:
            Text('Edit feature for "${item.product ?? 'item'}" coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ====================== DELETE SINGLE ======================
  void _confirmDelete(BuildContext context, int id) {
    // FIX: capture bloc BEFORE entering the dialog so it stays valid
    // even if the widget tree rebuilds while the dialog is open.
    final bloc = context.read<ExpiryBloc>();

    showDialog(
      context: context,
      useRootNavigator: true, // FIX: prevents GoRouter from intercepting pop
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Expiry'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            // FIX: dialogCtx — only closes the dialog
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // FIX: close dialog first, then dispatch via captured bloc ref
              Navigator.of(dialogCtx).pop();
              bloc.add(DeleteExpiry(id));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ====================== DELETE ALL ======================
  void _confirmDeleteAll(BuildContext context) {
    final bloc = context.read<ExpiryBloc>();

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete All'),
        content:
            const Text('Are you sure you want to delete all expiry records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              // Dispatch your DeleteAll event here:
              // bloc.add(const DeleteAllExpiry());
            },
            child:
                const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
