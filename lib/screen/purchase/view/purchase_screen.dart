// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:nepali_date_picker/nepali_date_picker.dart';
// import 'package:saleup_app/model/purchase_response.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_event.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_state.dart';
// import 'package:saleup_app/screen/addPurchase/view/add_purchase_screen.dart';
// import 'package:saleup_app/screen/purchase/view/datepiker.dart';
// // import 'package:saleup_app/screen/purchase/view/add_purchase_screen.dart';  // uncomment when ready

// class PurchaseScreen extends StatefulWidget {
//   const PurchaseScreen({super.key});

//   @override
//   State<PurchaseScreen> createState() => _PurchaseScreenState();
// }

// class _PurchaseScreenState extends State<PurchaseScreen> {
//   DateTime? _tempStart;
//   DateTime? _tempEnd;
//   DateTime? _appliedStart;
//   DateTime? _appliedEnd;

//   final TextEditingController _searchCtrl = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     context.read<PurchaseBloc>().add(const FetchPurchases());
//   }

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   String _fmtDate(DateTime? d) =>
//       d != null ? DateFormat('MM/dd/yyyy').format(d) : '';

//   Future<void> _selectDate(bool isStart) async {
//     await showDialog(
//       context: context,
//       builder: (_) => NepaliDatePickerDialog(
//         initialDate: NepaliDateTime.now(),
//         firstDate: NepaliDateTime(2075),
//         lastDate: NepaliDateTime(2090),
//         onDateSelected: (picked) {
//           setState(() {
//             if (isStart) {
//               _tempStart = picked.toDateTime(); // or keep as NepaliDateTime
//             } else {
//               _tempEnd = picked.toDateTime();
//             }
//           });
//           if (context.canPop()) context.pop();
//         },
//       ),
//     );
//   }

//   void _apply() {
//     setState(() {
//       _appliedStart = _tempStart;
//       _appliedEnd = _tempEnd;
//     });
//   }

//   void _reset() {
//     setState(() {
//       _tempStart = null;
//       _tempEnd = null;
//       _appliedStart = null;
//       _appliedEnd = null;
//       _searchCtrl.clear();
//     });
//   }

//   List<PurchaseData> _filtered(List<PurchaseData> list) {
//     final q = _searchCtrl.text.trim().toLowerCase();

//     return list.where((p) {
//       bool dateMatch = true;
//       if (_appliedStart != null && p.createdOn != null) {
//         dateMatch = !p.createdOn!.isBefore(_appliedStart!);
//       }
//       if (_appliedEnd != null && p.createdOn != null) {
//         dateMatch = dateMatch && !p.createdOn!.isAfter(_appliedEnd!);
//       }

//       bool searchMatch = q.isEmpty ||
//           (p.party?.toLowerCase().contains(q) ?? false) ||
//           (p.voucherNumber?.toLowerCase().contains(q) ?? false) ||
//           (p.invoiceNumber?.toLowerCase().contains(q) ?? false);

//       return dateMatch && searchMatch;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
//               color: Colors.transparent,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize:
//                     MainAxisSize.min, // prevents unnecessary extra space
//                 children: [
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           context.go('/home'); // ← navigates to root/home
//                           // OR: context.go('/home');  // if your home route is named '/home'
//                         },
//                         child: Image.asset(
//                           'assets/images/back_button_logo.png',
//                           width: 50,
//                           height: 50,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Purchase',
//                         style: TextStyle(
//                           color: Colors
//                               .black87, // changed to darker for better contrast (common in modern UIs)
//                           fontSize: 26,
//                           fontWeight: FontWeight.w700,
//                           height: 1.1,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // const SizedBox(
//                   //     height:
//                   //         2), // very small gap — makes breadcrumb feel "right below"

//                   // Text(
//                   //   GoRouterState.of(context)
//                   //       .uri
//                   //       .path
//                   //       .substring(1)
//                   //       .split('-')
//                   //       .map((s) => s[0].toUpperCase() + s.substring(1))
//                   //       .join(' → '),
//                   //   style: const TextStyle(
//                   //       color: Colors.grey,
//                   //       fontSize: 14,
//                   //       fontWeight: FontWeight.w500),
//                   // )
//                 ],
//               ),
//             ),
//             Image.asset(
//               'assets/images/Line.png',
//               width: double.infinity,
//               height: 1,
//               fit: BoxFit.cover,
//             ),

//             // Search + New Purchase
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(30),
//                         border: Border.all(color: Colors.transparent),
//                       ),
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(left: 16),
//                             child: Image.asset(
//                               'assets/images/search.png',
//                               width: 22,
//                               height: 22,
//                               // fit: BoxFit.contain,      // usually not needed for icons
//                             ),
//                           ),
//                           Expanded(
//                             child: TextField(
//                               controller: _searchCtrl,
//                               textAlign: TextAlign.center,
//                               decoration: const InputDecoration(
//                                 hintText: 'Search',
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 1, vertical: 12),
//                                 hintStyle: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               onChanged: (_) => setState(() {}),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => const AddPurchaseScreen()))
//                           .then((added) {
//                         if (added == true) {
//                           context
//                               .read<PurchaseBloc>()
//                               .add(const FetchPurchases());
//                         }
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF59422),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 12),
//                     ),
//                     child: const Text('New Purchase'),
//                   ),
//                 ],
//               ),
//             ),

//             // Date range + buttons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   final totalWidth = constraints.maxWidth;
//                   final isNarrow = totalWidth < 380;

//                   final buttonWidth = isNarrow ? 68.0 : 80.0;
//                   final buttonHeight = isNarrow ? 36.0 : 40.0;
//                   final textSize = isNarrow ? 13.0 : 14.0;

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Labels row
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 4, bottom: 6),
//                               child: Text(
//                                 'Start Date',
//                                 style: TextStyle(
//                                   fontSize: textSize,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey[800],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 4, bottom: 6),
//                               child: Text(
//                                 'End Date',
//                                 style: TextStyle(
//                                   fontSize: textSize,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey[800],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // empty space for buttons
//                           SizedBox(width: buttonWidth * 2 + 16), // or even +12
//                         ],
//                       ),

//                       // Fields + buttons
//                       Row(
//                         children: [
//                           Expanded(
//                             flex: 6,
//                             child: _dateField('Start', _tempStart, true),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             flex: 6,
//                             child: _dateField('End', _tempEnd, false),
//                           ),
//                           const SizedBox(width: 8),
//                           SizedBox(
//                             width: buttonWidth,
//                             height: buttonHeight,
//                             child: ElevatedButton(
//                               onPressed: _apply,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFF5A623),
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.zero,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8)),
//                               ),
//                               child: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 child: Text(
//                                   'Filter',
//                                   style: TextStyle(
//                                       fontSize: textSize,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           SizedBox(
//                             width: buttonWidth,
//                             height: buttonHeight,
//                             child: ElevatedButton(
//                               onPressed: _reset,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF9E9E9E),
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.zero,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8)),
//                               ),
//                               child: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 child: Text(
//                                   'Reset',
//                                   style: TextStyle(
//                                       fontSize: textSize,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 8),

//             Expanded(
//               child: BlocBuilder<PurchaseBloc, PurchaseState>(
//                 builder: (context, state) {
//                   if (state.isLoading && state.purchases.isEmpty) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (state.errorMessage != null) {
//                     return Center(
//                         child: Text(state.errorMessage!,
//                             style: const TextStyle(color: Colors.red)));
//                   }

//                   final filtered = _filtered(state.purchases);
//                   if (filtered.isEmpty) {
//                     return const Center(child: Text('No purchases found'));
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: filtered.length,
//                     itemBuilder: (context, i) => _purchaseCard(filtered[i]),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dateField(String hint, DateTime? date, bool isStart) {
//     final text = date != null ? _fmtDate(date) : hint;
//     return GestureDetector(
//       onTap: () => _selectDate(isStart),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
//         decoration: BoxDecoration(
//           border: Border.all(color: const Color(0xFFFF7043)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                     color: date != null ? Colors.black : Colors.grey[700],
//                     fontSize: 14),
//                 overflow: TextOverflow.ellipsis, // safety
//                 maxLines: 1,
//               ),
//             ),
//             const SizedBox(width: 1), // small gap
//             const Icon(
//               Icons.calendar_today_outlined,
//               size: 14, // ← was 18 → now 16
//               color: Color(0xFFFF7043),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _purchaseCard(PurchaseData p) {
//     final desc = [
//       p.voucherNumber ?? '',
//       p.invoiceNumber ?? '',
//       p.billType ?? '',
//     ].where((s) => s.isNotEmpty).join(' • ');

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       p.party ?? 'Unknown Party',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w600),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       desc.isNotEmpty ? desc : 'No details available',
//                       style: TextStyle(fontSize: 13, color: Colors.grey[700]),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   _circleIcon(Icons.edit, Colors.green, () {
//
//                   }),
//                   const SizedBox(width: 12),
//                   _circleIcon(Icons.delete, Colors.red, () {
//
//                   }),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Amount',
//             style: TextStyle(fontSize: 13, color: Colors.grey),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             'NPR ${(p.total ?? 0).toStringAsFixed(2)}',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _circleIcon(IconData icon, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: color.withOpacity(0.15),
//         ),
//         child: Icon(icon, color: color, size: 20),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'package:saleup_app/screen/addPurchase/view/add_purchase_screen.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_event.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_state.dart';
import 'package:saleup_app/utility/datepiker.dart';
import 'package:saleup_app/screen/purchase/view/edit_purchase_screen.dart';
import 'package:saleup_app/screen/purchase/view/purchase_detail_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
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
    context.read<PurchaseBloc>().add(const FetchPurchases());
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

  List<PurchaseData> _filtered(List<PurchaseData> list) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return list.where((p) {
      bool dateMatch = true;
      if (_appliedStart != null && p.createdOn != null) {
        dateMatch = !p.createdOn!.isBefore(_appliedStart!);
      }
      if (_appliedEnd != null && p.createdOn != null) {
        dateMatch = dateMatch && !p.createdOn!.isAfter(_appliedEnd!);
      }
      bool partyMatch = _appliedParty == null ||
          (p.party?.toLowerCase() == _appliedParty!.toLowerCase());
      bool searchMatch = q.isEmpty ||
          (p.party?.toLowerCase().contains(q) ?? false) ||
          (p.voucherNumber?.toLowerCase().contains(q) ?? false) ||
          (p.invoiceNumber?.toLowerCase().contains(q) ?? false);
      return dateMatch && partyMatch && searchMatch;
    }).toList();
  }

  Future<void> _confirmDelete(PurchaseData p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Purchase'),
        content: const Text('Are you sure you want to delete this purchase?'),
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
        '/purchase/delete_purchases/',
        queryParameters: {'purchase_id': p.id},
      );

      final resp = PurchaseResponse.fromJson(res.data);

      if (resp.success) {
        context.read<PurchaseBloc>().add(const FetchPurchases());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.message ?? 'Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting purchase: $e'),
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
        child: Column(
          children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                color: Colors.transparent,
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
                      'Purchase',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              Image.asset(
                'assets/images/Line.png',
                width: double.infinity,
                height: 1,
                fit: BoxFit.cover,
              ),

              // Search + New Purchase
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
                              child: Image.asset('assets/images/search.png',
                                  width: 22, height: 22),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 12),
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 16),
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
                              builder: (_) => const AddPurchaseScreen()),
                        ).then((added) {
                          if (added == true && mounted) {
                            context
                                .read<PurchaseBloc>()
                                .add(const FetchPurchases());
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59422),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('New Purchase'),
                    ),
                  ],
                ),
              ),

              // Filter Section
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
                                child: Text('Start Date',
                                    style: TextStyle(
                                        fontSize: textSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800])),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 6),
                                child: Text('End Date',
                                    style: TextStyle(
                                        fontSize: textSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800])),
                              ),
                            ),
                            SizedBox(width: buttonWidth * 2 + 16),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 5,
                                child: _dateField('Start', _tempStart, true)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 5,
                                child: _dateField('End', _tempEnd, false)),
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
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Filter',
                                      style: TextStyle(
                                          fontSize: textSize,
                                          fontWeight: FontWeight.w600)),
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
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Reset',
                                      style: TextStyle(
                                          fontSize: textSize,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Text('Party',
                              style: TextStyle(
                                  fontSize: textSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800])),
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
                              hint: Text('All Parties',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: textSize)),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFFFF7043), size: 20),
                              style: TextStyle(
                                  fontSize: textSize, color: Colors.black87),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('All Parties',
                                      style: TextStyle(fontSize: textSize)),
                                ),
                                ..._parties.map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p,
                                          style: TextStyle(fontSize: textSize),
                                          overflow: TextOverflow.ellipsis),
                                    )),
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

              // Purchase List
              Expanded(
                child: BlocBuilder<PurchaseBloc, PurchaseState>(
                  builder: (context, state) {
                    if (state.isLoading && state.purchases.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                            child: Text(state.errorMessage!,
                                style: const TextStyle(color: Colors.red))),
                      );
                    }
                    final filtered = _filtered(state.purchases);
                    if (filtered.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No purchases found')),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => _purchaseCard(filtered[i]),
                    );
                  },
                ),
              ),
            ],
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
            const Icon(Icons.calendar_today_outlined,
                size: 14, color: Color(0xFFFF7043)),
          ],
        ),
      ),
    );
  }

  Widget _purchaseCard(PurchaseData p) {
    final desc = [
      p.voucherNumber ?? '',
      p.invoiceNumber ?? '',
      p.billType ?? '',
    ].where((s) => s.isNotEmpty).join(' • ');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<PurchaseBloc>(),
              child: PurchaseDetailScreen(purchase: p),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
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
                      Text(
                        p.party ?? 'Unknown Party',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc.isNotEmpty ? desc : 'No details available',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Edit button
                    _circleIcon(
                      'assets/images/edit.png',
                      const Color(0xFF4CAF50),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: context.read<PurchaseBloc>(),
                              child: EditPurchaseScreen(purchase: p),
                            ),
                          ),
                        ).then((updated) {
                          if (updated == true && mounted) {
                            context
                                .read<PurchaseBloc>()
                                .add(const FetchPurchases());
                          }
                        });
                      },
                      'Edit',
                    ),
                    const SizedBox(width: 12),
                    // Delete button
                    _circleIcon(
                      'assets/images/delete.png',
                      const Color(0xFFE53935),
                      () => _confirmDelete(p),
                      'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Amount',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              'NPR ${(p.total ?? 0).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(
      String asset, Color bgColor, VoidCallback onTap, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Image.asset(asset, width: 13, height: 13),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: bgColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
