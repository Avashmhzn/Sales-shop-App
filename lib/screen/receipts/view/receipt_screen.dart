// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/model/receipt_response.dart';
// import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
// import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
// import 'package:saleup_app/screen/receipts/bloc/receipt_state.dart';
// import 'package:saleup_app/screen/receipts/view/add_receipt_screen.dart';
// import 'package:saleup_app/screen/receipts/widget/receipt_detail_dialog.dart';
// import 'package:shimmer/shimmer.dart';

// class ReceiptScreen extends StatefulWidget {
//   const ReceiptScreen({super.key});

//   @override
//   State<ReceiptScreen> createState() => _ReceiptScreenState();
// }

// class _ReceiptScreenState extends State<ReceiptScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   bool _hasFetchedReceipts = false;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       setState(() => _searchQuery = _searchController.text.trim());
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!mounted) return;
//     final bloc = BlocProvider.of<ReceiptBloc>(context, listen: false);
//     if (!_hasFetchedReceipts && bloc.state.receipts.isEmpty) {
//       bloc.add(const FetchReceipts());
//       _hasFetchedReceipts = true;
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _clearSearch() {
//     setState(() {
//       _searchController.clear();
//       _searchQuery = '';
//     });
//   }

//   List<ReceiptData> _filterReceipts(List<ReceiptData> receipts) {
//     if (_searchQuery.isEmpty) return receipts;
//     return receipts
//         .where((r) => (r.refNumber ?? '')
//             .toLowerCase()
//             .contains(_searchQuery.toLowerCase()))
//         .toList();
//   }

//   Widget _buildShimmerEffect(double screenWidth) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.builder(
//         padding: EdgeInsets.all(screenWidth * 0.03),
//         itemCount: 5,
//         itemBuilder: (_, __) => Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Card(
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             color: Colors.white,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                       height: 16,
//                       width: screenWidth * 0.4,
//                       color: Colors.white),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                           height: 14,
//                           width: screenWidth * 0.3,
//                           color: Colors.white),
//                       Container(
//                           height: 14,
//                           width: screenWidth * 0.2,
//                           color: Colors.white),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDetailsPopup(BuildContext parentContext, ReceiptData receipt) {
//     final bloc = BlocProvider.of<ReceiptBloc>(parentContext, listen: false);
//     if (bloc.state.receiptDetail?.id != receipt.id) {
//       bloc.add(FetchReceiptById(receipt.id));
//     }
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) => BlocProvider.value(
//         value: BlocProvider.of<ReceiptBloc>(parentContext),
//         child: ReceiptDetailDialog(receiptId: receipt.id),
//       ),
//     );
//   }

//   void _navigateToAddReceipt(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => BlocProvider.value(
//           value: BlocProvider.of<ReceiptBloc>(context),
//           child: const AddReceiptScreen(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         body: BlocListener<ReceiptBloc, ReceiptState>(
//           listener: (context, state) {
//             if (state.errorMessage != null) {
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
//             }
//           },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.02),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Title + New Receipt button
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Receipts',
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.05,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: () => _navigateToAddReceipt(context),
//                           icon: const Icon(Icons.add, size: 16),
//                           label: const Text('New Receipt'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFF5A623),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Search bar
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _searchController,
//                             decoration: const InputDecoration(
//                               labelText: 'Search',
//                               border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(30))),
//                               prefixIcon: Icon(Icons.search),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Receipt list
//               Expanded(
//                 child: BlocBuilder<ReceiptBloc, ReceiptState>(
//                   builder: (context, state) {
//                     if (state.isLoading && state.receipts.isEmpty) {
//                       return _buildShimmerEffect(screenWidth);
//                     }
//                     if (state.errorMessage != null && state.receipts.isEmpty) {
//                       return Center(child: Text(state.errorMessage!));
//                     }

//                     final filtered = _filterReceipts(state.receipts);
//                     if (filtered.isEmpty) {
//                       return const Center(child: Text('No receipts available'));
//                     }

//                     return ListView.builder(
//                       padding: EdgeInsets.all(screenWidth * 0.03),
//                       itemCount: filtered.length,
//                       itemBuilder: (context, index) {
//                         final receipt = filtered[index];
//                         return ReceiptCard(
//                           key: ValueKey(receipt.id),
//                           receipt: receipt,
//                           screenWidth: screenWidth,
//                           screenHeight: screenHeight,
//                           onTap: () => _showDetailsPopup(context, receipt),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ReceiptCard extends StatelessWidget {
//   final ReceiptData receipt;
//   final double screenWidth;
//   final double screenHeight;
//   final VoidCallback onTap;

//   const ReceiptCard({
//     super.key,
//     required this.receipt,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String formattedDateTime = 'Unknown';
//     final createdOnStr = receipt.createdOn ?? '';
//     if (createdOnStr.isNotEmpty) {
//       try {
//         formattedDateTime = DateFormat('MMM dd, yyyy hh:mm a')
//             .format(DateTime.parse(createdOnStr));
//       } catch (_) {
//         formattedDateTime = 'Invalid Date';
//       }
//     }

//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Card(
//           elevation: 4,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           color: Colors.white,
//           child: Container(
//             padding: EdgeInsets.all(screenWidth * 0.02),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Receipt: ${receipt.refNumber ?? 'N/A'}',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleMedium
//                       ?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Customer: ${receipt.customer ?? 'N/A'}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                     ),
//                     Text(
//                       'Date: $formattedDateTime',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Amount: Rs.${receipt.amount.toStringAsFixed(2)}',
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyMedium
//                       ?.copyWith(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/model/receipt_response.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_state.dart';
import 'package:saleup_app/screen/receipts/view/add_receipt_screen.dart';
import 'package:saleup_app/screen/receipts/widget/receipt_detail_dialog.dart';
import 'package:shimmer/shimmer.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasFetchedReceipts = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final bloc = BlocProvider.of<ReceiptBloc>(context, listen: false);
    if (!_hasFetchedReceipts && bloc.state.receipts.isEmpty) {
      bloc.add(const FetchReceipts());
      _hasFetchedReceipts = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
  }

  List<ReceiptData> _filterReceipts(List<ReceiptData> receipts) {
    if (_searchQuery.isEmpty) return receipts;
    final q = _searchQuery.toLowerCase();
    return receipts.where((r) {
      return (r.refNumber ?? '').toLowerCase().contains(q) ||
          (r.customer ?? '').toLowerCase().contains(q);
    }).toList();
  }

  void _showDetailsPopup(BuildContext parentContext, ReceiptData receipt) {
    final bloc = BlocProvider.of<ReceiptBloc>(parentContext, listen: false);
    if (bloc.state.receiptDetail?.id != receipt.id) {
      bloc.add(FetchReceiptById(receipt.id));
    }
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<ReceiptBloc>(parentContext),
        child: ReceiptDetailDialog(receiptId: receipt.id),
      ),
    );
  }

  void _navigateToAddReceipt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<ReceiptBloc>(context),
          child: const AddReceiptScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: BlocListener<ReceiptBloc, ReceiptState>(
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
          child: Column(
            children: [
              // ═══════════════════════════════════════════
              // HEADER
              // ═══════════════════════════════════════════
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                    sw * 0.04, sh * 0.02, sw * 0.04, sh * 0.015),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Receipts',
                                  style: TextStyle(
                                      fontSize: sw * 0.065,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                              SizedBox(height: sh * 0.003),
                              Text('Manage and track all receipts',
                                  style: TextStyle(
                                      fontSize: sw * 0.035,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddReceipt(context),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text('New Receipt',
                              style: TextStyle(
                                  fontSize: sw * 0.035,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5A623),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.03, vertical: sh * 0.014),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.018),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search receipts...',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: sw * 0.038),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.grey.shade400, size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color: Colors.grey.shade400, size: 20),
                                  onPressed: _clearSearch)
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: sh * 0.014),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ═══════════════════════════════════════════
              // RECEIPT LIST
              // ═══════════════════════════════════════════
              Expanded(
                child: BlocBuilder<ReceiptBloc, ReceiptState>(
                  builder: (context, state) {
                    if (state.isLoading && state.receipts.isEmpty) {
                      return _buildShimmerEffect(sw, sh);
                    }

                    if (state.errorMessage != null && state.receipts.isEmpty) {
                      return _buildEmptyState(
                          icon: Icons.error_outline,
                          title: 'Error loading receipts',
                          subtitle: state.errorMessage!);
                    }

                    final filtered = _filterReceipts(state.receipts);

                    if (filtered.isEmpty) {
                      return _buildEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: _searchQuery.isNotEmpty
                            ? 'No receipts found'
                            : 'No receipts yet',
                        subtitle: _searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'Tap "New Receipt" to create one',
                      );
                    }

                    return RefreshIndicator(
                      color: const Color(0xFFF5A623),
                      onRefresh: () async {
                        context.read<ReceiptBloc>().add(const FetchReceipts());
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                            sw * 0.04, sh * 0.015, sw * 0.04, sh * 0.02),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: sh * 0.012),
                        itemBuilder: (context, index) {
                          final receipt = filtered[index];
                          return RepaintBoundary(
                            child: _ReceiptCard(
                              receipt: receipt,
                              screenWidth: sw,
                              screenHeight: sh,
                              onTap: () => _showDetailsPopup(context, receipt),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // SHIMMER — Professional layout matching the new card
  // ═══════════════════════════════════════════════════
  Widget _buildShimmerEffect(double sw, double sh) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: EdgeInsets.all(sw * 0.04),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(height: sh * 0.012),
        itemBuilder: (_, __) => Container(
          padding: EdgeInsets.all(sw * 0.035),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12))),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 16,
                        width: sw * 0.4,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(
                        height: 12,
                        width: sw * 0.25,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height: 16,
                      width: sw * 0.2,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(
                      height: 20,
                      width: 45,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MODERN RECEIPT CARD - Clean Visual Hierarchy
// ═══════════════════════════════════════════════════════════
class _ReceiptCard extends StatelessWidget {
  final ReceiptData receipt;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const _ReceiptCard({
    required this.receipt,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  Color _tagBg(String tag) {
    switch (tag.toLowerCase()) {
      case 'cash':
        return Colors.purple.shade50;
      case 'bank':
        return Colors.indigo.shade50;
      default:
        return Colors.orange.shade50;
    }
  }

  Color _tagText(String tag) {
    switch (tag.toLowerCase()) {
      case 'cash':
        return Colors.purple.shade700;
      case 'bank':
        return Colors.indigo.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositedIn =
        receipt.depositedIn ?? 'Cash'; // Adjust field name if needed

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.035),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // ── Left: Icon ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5A623).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long,
                  color: Color(0xFFF5A623), size: 22),
            ),
            SizedBox(width: screenWidth * 0.03),

            // ── Middle: Customer & Ref ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.customer ?? 'Unknown Customer',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    'Ref: ${receipt.refNumber ?? '-'} (ID:${receipt.id})',
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.02),

            // ── Right: Amount & Tag ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs.${receipt.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.039,
                    fontWeight: FontWeight.w800,
                    color:
                        Colors.green.shade700, // Green implies "Credit/Income"
                  ),
                ),
                SizedBox(height: screenHeight * 0.006),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025, vertical: 3),
                  decoration: BoxDecoration(
                    color: _tagBg(depositedIn),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    depositedIn,
                    style: TextStyle(
                      fontSize: screenWidth * 0.028,
                      color: _tagText(depositedIn),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
