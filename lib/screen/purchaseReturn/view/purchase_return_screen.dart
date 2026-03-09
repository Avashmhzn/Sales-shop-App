// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart'; // Ensure this package is added
// import 'package:saleup_app/model/purchase_return_response.dart';
// import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
// import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_event.dart';
// import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_state.dart';

// class PurchaseReturnScreen extends StatefulWidget {
//   const PurchaseReturnScreen({super.key});

//   @override
//   State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
// }

// class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
//   DateTime? _selectedDate;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!mounted) return;
//     final bloc = BlocProvider.of<PurchaseReturnBloc>(context, listen: false);
//     print('PurchaseReturnBloc in didChangeDependencies: $bloc');
//     if (bloc.state.purchaseReturns.isEmpty) {
//       bloc.add(const FetchPurchaseReturns());
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   void _clearDate() {
//     setState(() {
//       _selectedDate = null;
//     });
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   List<PurchaseReturnData> _filterPurchases(
//       List<PurchaseReturnData> purchases) {
//     return purchases.where((purchase) {
//       bool dateMatch = true;

//       if (_selectedDate != null) {
//         final returnDate = DateTime.parse(purchase.returnDate).toLocal();
//         dateMatch = returnDate.year == _selectedDate!.year &&
//             returnDate.month == _selectedDate!.month &&
//             returnDate.day == _selectedDate!.day;
//       }

//       return dateMatch;
//     }).toList();
//   }

//   Widget _buildShimmerEffect(double screenWidth, double screenHeight) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.builder(
//         padding: EdgeInsets.all(screenWidth * 0.03),
//         itemCount: 5,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               color: Colors.white,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                         height: 16,
//                         width: screenWidth * 0.4,
//                         color: Colors.white),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                             height: 14,
//                             width: screenWidth * 0.3,
//                             color: Colors.white),
//                         Container(
//                             height: 14,
//                             width: screenWidth * 0.2,
//                             color: Colors.white),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                             height: 14,
//                             width: screenWidth * 0.3,
//                             color: Colors.white),
//                         Container(
//                             height: 14,
//                             width: screenWidth * 0.2,
//                             color: Colors.white),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showDetailsPopup(BuildContext context, PurchaseReturnData purchase) {
//     final DateTime returnDateTime = DateTime.parse(purchase.returnDate);
//     final String formattedDateTime =
//         DateFormat('MMM dd, yyyy hh:mm a').format(returnDateTime);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         backgroundColor: Colors.white,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Purchase Return Details',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.black87,
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.close, color: Colors.grey),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//         content: Container(
//           constraints: const BoxConstraints(maxHeight: 400),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildDetailRow(
//                     Icons.receipt, 'Purchase ID', purchase.purchase.toString()),
//                 _buildDetailRow(
//                     Icons.calendar_today, 'Return Date', formattedDateTime),
//                 _buildDetailRow(Icons.notes, 'Reason', purchase.reason),
//                 _buildDetailRow(Icons.attach_money, 'Sub Total',
//                     '\$${purchase.subTotal.toStringAsFixed(2)}'),
//                 _buildDetailRow(Icons.discount, 'Discount',
//                     '\$${purchase.discount.toStringAsFixed(2)}'),
//                 _buildDetailRow(Icons.currency_exchange, 'VAT',
//                     '\$${purchase.vat.toStringAsFixed(2)}'),
//                 _buildDetailRow(Icons.payments, 'Total',
//                     '\$${purchase.total.toStringAsFixed(2)}'),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Items',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 ...purchase.items.map((item) => _buildItemRow(item)),
//               ],
//             ),
//           ),
//         ),
//         actions: [], // Removed the "Close" button
//       ),
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.grey[600], size: 20),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               '$label: $value',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.black87,
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemRow(PurchaseReturnItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: ExpansionTile(
//         leading: Icon(Icons.inventory, color: Colors.grey[600], size: 20),
//         title: Text(
//           'Product ID: ${item.id}',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.black87,
//               ),
//         ),
//         children: [
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Quantity: ${item.quantity}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//                 Text(
//                   'Rate: \$${item.rate.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//                 Text(
//                   'Total: \$${item.total.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<PurchaseReturnBloc, PurchaseReturnState>(
//         listener: (context, state) {},
//         child: Builder(
//           builder: (context) {
//             final screenWidth = MediaQuery.of(context).size.width;
//             final screenHeight = MediaQuery.of(context).size.height;

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(screenWidth * 0.02),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Purchase Returns",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.05,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () => _selectDate(context),
//                                     child: AbsorbPointer(
//                                       child: TextField(
//                                         controller: TextEditingController(
//                                           text: _selectedDate == null
//                                               ? 'yyyy-MM-dd'
//                                               : DateFormat('yyyy-MM-dd')
//                                                   .format(_selectedDate!),
//                                         ),
//                                         decoration: const InputDecoration(
//                                           labelText: 'Date',
//                                           border: OutlineInputBorder(),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.clear),
//                                   onPressed: _clearDate,
//                                   tooltip: 'Clear Date',
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
//                     builder: (context, state) {
//                       print(
//                           'BlocBuilder state: isLoading=${state.isLoading}, purchaseReturns.length=${state.purchaseReturns.length}, error=${state.errorMessage}');
//                       if (state.isLoading && state.purchaseReturns.isEmpty) {
//                         return _buildShimmerEffect(screenWidth, screenHeight);
//                       }
//                       if (state.errorMessage != null) {
//                         return Center(child: Text(state.errorMessage!));
//                       }
//                       final filteredPurchases =
//                           _filterPurchases(state.purchaseReturns);

//                       if (filteredPurchases.isEmpty) {
//                         return const Center(
//                             child: Text('No purchase returns available'));
//                       }

//                       return ListView.builder(
//                         padding: EdgeInsets.all(screenWidth * 0.03),
//                         itemCount: filteredPurchases.length,
//                         itemBuilder: (context, index) {
//                           final purchase = filteredPurchases[index];
//                           return PurchaseReturnCard(
//                             purchase: purchase,
//                             screenWidth: screenWidth,
//                             screenHeight: screenHeight,
//                             onTap: () => _showDetailsPopup(context, purchase),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class PurchaseReturnCard extends StatelessWidget {
//   final PurchaseReturnData purchase;
//   final double screenWidth;
//   final double screenHeight;
//   final VoidCallback onTap;

//   const PurchaseReturnCard({
//     super.key,
//     required this.purchase,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final DateTime returnDateTime = DateTime.parse(purchase.returnDate);
//     final String formattedDateTime =
//         DateFormat('MMM dd, yyyy hh:mm a').format(returnDateTime);

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
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'ID: ${purchase.id}',
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Purchase ID: ${purchase.purchase}',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(color: Colors.grey),
//                           ),
//                           Text(
//                             'Return Date: $formattedDateTime',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         'Reason: ${purchase.reason}',
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodyMedium
//                             ?.copyWith(color: Colors.grey),
//                       ),
//                     ],
//                   ),
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
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/purchase/view/datepiker.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
import 'package:saleup_app/screen/purchaseReturn/model/purchase_return.dart';
import 'package:saleup_app/screen/purchaseReturn/view/add_purchase_return_screen.dart';
import 'package:saleup_app/screen/purchaseReturn/view/purchase_return_card.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  DateTime? _tempStart;
  DateTime? _tempEnd;
  DateTime? _appliedStart;
  DateTime? _appliedEnd;
  String? _selectedParty;
  String? _appliedParty;
  List<String> _parties = [];

  final TextEditingController _searchCtrl = TextEditingController();

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    context.read<PurchaseReturnBloc>().add(const LoadPurchaseReturns());
    _loadParties();
  }

  Future<void> _loadParties() async {
    try {
      final res = await DioClient().dio.get('/party/get_parties/');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      final data = raw
          .where((e) {
            final t = (e['type'] as String?)?.toLowerCase() ?? '';
            return t == 'supplier' || t == 'both';
          })
          .map((e) => e['name'] as String)
          .toList();
      if (mounted) setState(() => _parties = data);
    } catch (e) {
      debugPrint('_loadParties error: $e');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime? d) =>
      d != null ? DateFormat('MM/dd/yy').format(d) : '';

  Future<void> _selectDate(bool isStart) async {
    await showDialog(
      context: context,
      builder: (_) => NepaliDatePickerDialog(
        initialDate: NepaliDateTime.now(),
        firstDate: NepaliDateTime(2075),
        lastDate: NepaliDateTime(2090),
        onDateSelected: (picked) {
          setState(() {
            if (isStart) {
              _tempStart = picked.toDateTime();
            } else {
              _tempEnd = picked.toDateTime();
            }
          });
          if (context.canPop()) context.pop();
        },
      ),
    );
  }

  void _apply() {
    setState(() {
      _appliedStart = _tempStart;
      _appliedEnd = _tempEnd;
      _appliedParty = _selectedParty;
    });
  }

  void _reset() {
    setState(() {
      _tempStart = null;
      _tempEnd = null;
      _appliedStart = null;
      _appliedEnd = null;
      _selectedParty = null;
      _appliedParty = null;
      _searchCtrl.clear();
    });
  }

  List<PurchaseReturn> _filtered(List<PurchaseReturn> list) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return list.where((r) {
      bool dateMatch = true;
      if (_appliedStart != null) {
        dateMatch = !r.returnDate.isBefore(_appliedStart!);
      }
      if (_appliedEnd != null) {
        dateMatch = dateMatch && !r.returnDate.isAfter(_appliedEnd!);
      }
      bool partyMatch = _appliedParty == null ||
          (r.partyName.toLowerCase() == _appliedParty!.toLowerCase());
      bool searchMatch = q.isEmpty ||
          (r.partyName.toLowerCase().contains(q) ?? false) ||
          (r.invoiceNumber.toLowerCase().contains(q) ?? false) ||
          (r.reason.toLowerCase().contains(q) ?? false);
      return dateMatch && partyMatch && searchMatch;
    }).toList();
  }

  Future<void> _confirmDelete(PurchaseReturn r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Purchase Return'),
        content: const Text('Are you sure you want to delete this return?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final res = await DioClient().dio.delete(
        '/purchase-return/delete_purchase_return/', // adjust endpoint if needed
        queryParameters: {'return_id': r.id},
      );

      if (res.data['success'] == true) {
        context.read<PurchaseReturnBloc>().add(const LoadPurchaseReturns());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase Return deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.data['message'] ?? 'Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting return: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header - same gradient as Purchase screen
              Container(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Image.asset(
                        'assets/images/back_button_logo.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Purchase Return',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Search + New Return button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Image.asset(
                                'assets/images/search.png',
                                width: 22,
                                height: 22,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 1,
                                    vertical: 12,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => PurchaseReturnBloc(
                                dio: DioClient().dio,
                              ),
                              child: const AddPurchaseReturnScreen(),
                            ),
                          ),
                        ).then((added) {
                          if (added == true && mounted) {
                            context
                                .read<PurchaseReturnBloc>()
                                .add(const LoadPurchaseReturns());
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59422),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('New Return'),
                    ),
                  ],
                ),
              ),

              // Filter Section (exact same layout as your Purchase screen)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 380;
                    final buttonWidth = isNarrow ? 68.0 : 80.0;
                    final buttonHeight = isNarrow ? 36.0 : 40.0;
                    final textSize = isNarrow ? 13.0 : 14.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 6),
                                child: Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 6),
                                child: Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: buttonWidth * 2 + 16),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _dateField('Start', _tempStart, true),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 5,
                              child: _dateField('End', _tempEnd, false),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: _apply,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5A623),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Filter',
                                    style: TextStyle(
                                      fontSize: textSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: _reset,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9E9E9E),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: textSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            'Party',
                            style: TextStyle(
                              fontSize: textSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFF7043)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedParty,
                              isExpanded: true,
                              hint: Text(
                                'All Parties',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: textSize,
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFFFF7043),
                                size: 20,
                              ),
                              style: TextStyle(
                                fontSize: textSize,
                                color: Colors.black87,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'All Parties',
                                    style: TextStyle(fontSize: textSize),
                                  ),
                                ),
                                ..._parties.map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p,
                                      style: TextStyle(fontSize: textSize),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedParty = v),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Purchase Return List
              BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
                builder: (context, state) {
                  if (state is PurchaseReturnsLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is PurchaseReturnError) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  final returns = state is PurchaseReturnsLoaded
                      ? state.returns
                      : <PurchaseReturn>[];
                  final filtered = _filtered(returns);
                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No purchase returns found')),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) => PurchaseReturnCard(
                      purchaseReturn: filtered[i],
                      onEdit: () {
                        // TODO: Implement edit screen navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit coming soon')),
                        );
                      },
                      onDelete: () => _confirmDelete(filtered[i]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(String hint, DateTime? date, bool isStart) {
    final text = date != null ? _fmtDate(date) : hint;
    return GestureDetector(
      onTap: () => _selectDate(isStart),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF7043)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: date != null ? Colors.black : Colors.grey[700],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 1),
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: Color(0xFFFF7043),
            ),
          ],
        ),
      ),
    );
  }
}
