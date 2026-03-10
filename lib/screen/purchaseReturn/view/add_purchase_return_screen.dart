// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nepali_utils/nepali_utils.dart';
// import 'package:saleup_app/screen/purchase/view/datepiker.dart';
// import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
// import 'package:saleup_app/screen/purchaseReturn/model/purchase.dart';

// class AddPurchaseReturnScreen extends StatefulWidget {
//   const AddPurchaseReturnScreen({super.key});

//   @override
//   State<AddPurchaseReturnScreen> createState() =>
//       _AddPurchaseReturnScreenState();
// }

// class _AddPurchaseReturnScreenState extends State<AddPurchaseReturnScreen> {
//   Purchase? _selectedPurchase;
//   NepaliDateTime? _selectedNepaliDate;
//   final _reasonController = TextEditingController(text: 'damge');
//   bool _returnThisItem = true;
//   bool _isPartial = false; // ← fixed: declared here

//   // Quantity per item (key = item.id, value = return quantity)
//   final Map<int, int> _quantities = {};

//   // Safe number parsing (prevents String → num crash)
//   double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   int _parseInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is String) return int.tryParse(value) ?? 0;
//     return 0;
//   }

//   // Calculate total for one item
//   double _getItemTotal(PurchaseItem item) {
//     final qty = _quantities[item.id] ?? 0;
//     final rate = _parseDouble(item.costPrice);
//     return qty * rate;
//   }

//   // Sum of all item totals
//   double get _taxableAmount {
//     if (_selectedPurchase == null) return 0.0;
//     return _selectedPurchase!.items
//         .fold(0.0, (sum, item) => sum + _getItemTotal(item));
//   }

//   double get _vat => _taxableAmount * 0.13;
//   double get _totalRefund => _taxableAmount + _vat;

//   String _formatNepaliDate(NepaliDateTime? date) {
//     if (date == null) return 'Select Date (BS)';
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }

//   @override
//   void initState() {
//     super.initState();
//     context.read<PurchaseReturnBloc>().add(const LoadPurchasesForReturn());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.white, // or your desired color
//         elevation: 0, // flat look like your first example
//         leadingWidth: 72, // gives more space for icon + padding
//         leading: GestureDetector(
//           onTap: () =>
//               context.go('/purchase-return'), // or Navigator.pop(context)
//           child: Padding(
//             padding: const EdgeInsets.only(left: 8),
//             child: Image.asset(
//               'assets/images/back_button_logo.png',
//               width: 44,
//               height: 44,
//             ),
//           ),
//         ),
//         title: const Text(
//           'Purchase Return',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 24, // slightly smaller than 26 for AppBar balance
//             fontWeight: FontWeight.w700,
//             height: 1.1,
//           ),
//         ),
//         centerTitle: false, // keeps title left-aligned like your Row
//       ),
//       body: BlocConsumer<PurchaseReturnBloc, PurchaseReturnState>(
//         listener: (context, state) {
//           if (state is PurchaseReturnCreated) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                     'Return created → ${state.purchaseReturn.invoiceNumber}'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             Navigator.pop(context, true);
//           }
//           if (state is PurchaseReturnError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text(state.message), backgroundColor: Colors.red),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is PurchasesLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final purchases =
//               state is PurchasesLoaded ? state.purchases : <Purchase>[];

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Text(
//                 //   'Quickly Add Items and Manage Your Purchase Returns',
//                 //   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                 // ),
//                 // const SizedBox(height: 24),

//                 Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           '* Purchase   * Reason   * Return Date',
//                           style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonFormField<Purchase>(
//                           initialValue: _selectedPurchase,
//                           decoration: InputDecoration(
//                             labelText: 'Purchase',
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                           items: purchases.map((p) {
//                             return DropdownMenuItem(
//                               value: p,
//                               child: Text(
//                                   '${p.invoiceNumber} - ${p.party} (Rs. ${p.total.toStringAsFixed(2)})'),
//                             );
//                           }).toList(),
//                           onChanged: (val) {
//                             setState(() {
//                               _selectedPurchase = val;
//                               _quantities
//                                   .clear(); // Reset quantities when purchase changes
//                             });
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _reasonController,
//                           decoration: InputDecoration(
//                             labelText: 'Reason',
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         InkWell(
//                           onTap: () async {
//                             final picked = await showDialog<NepaliDateTime>(
//                               context: context,
//                               builder: (dialogContext) =>
//                                   NepaliDatePickerDialog(
//                                 initialDate:
//                                     _selectedNepaliDate ?? NepaliDateTime.now(),
//                                 firstDate: NepaliDateTime(2075, 1, 1),
//                                 lastDate: NepaliDateTime(2099, 12, 30),
//                                 onDateSelected: (date) {
//                                   Navigator.pop(dialogContext, date);
//                                 },
//                               ),
//                             );

//                             if (picked != null && mounted) {
//                               setState(() {
//                                 _selectedNepaliDate = picked;
//                               });
//                             }
//                           },
//                           child: InputDecorator(
//                             decoration: InputDecoration(
//                               labelText: 'Return Date',
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                               filled: true,
//                               fillColor: Colors.white,
//                             ),
//                             child: Text(_formatNepaliDate(_selectedNepaliDate)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Dynamic item section
//                 Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: _returnThisItem,
//                               activeColor: const Color(0xFFF59422),
//                               onChanged: (v) =>
//                                   setState(() => _returnThisItem = v!),
//                             ),
//                             const Text('Return this item',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         if (_selectedPurchase == null ||
//                             _selectedPurchase!.items.isEmpty)
//                           const Center(
//                             child: Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Text(
//                                 'Select a purchase to show items',
//                                 style:
//                                     TextStyle(color: Colors.grey, fontSize: 16),
//                               ),
//                             ),
//                           )
//                         else ...[
//                           // One section per item
//                           ..._selectedPurchase!.items.map((item) {
//                             final remainingQty = _parseInt(item.quantity);
//                             final rate = _parseDouble(item.costPrice);
//                             final currentQty = _quantities[item.id] ?? 0;
//                             final itemTotal = currentQty * rate;

//                             return Padding(
//                               padding: const EdgeInsets.only(bottom: 24),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${item.product} (Batch: ${item.batchNumber ?? "N/A"})',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 15),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Table(
//                                     border: TableBorder.all(
//                                         color: Colors.grey[300]!),
//                                     columnWidths: const {
//                                       0: FlexColumnWidth(2),
//                                       1: FlexColumnWidth(1.2),
//                                       2: FlexColumnWidth(1.2),
//                                       3: FlexColumnWidth(1),
//                                       4: FlexColumnWidth(1),
//                                       5: FlexColumnWidth(1),
//                                     },
//                                     children: [
//                                       const TableRow(
//                                         decoration: BoxDecoration(
//                                             color: Color(0xFFFFF3E0)),
//                                         children: [
//                                           Padding(
//                                               padding: EdgeInsets.all(8),
//                                               child: Text('Batch Number',
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold))),
//                                           Padding(
//                                               padding: EdgeInsets.all(8),
//                                               child: Text('Remaining Qty',
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold))),
//                                           Padding(
//                                               padding: EdgeInsets.all(8),
//                                               child: Text('Quantity',
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold))),
//                                           Padding(
//                                               padding: EdgeInsets.all(8),
//                                               child: Text('Rate',
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold))),
//                                           Padding(
//                                               padding: EdgeInsets.all(8),
//                                               child: Text('Total',
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold))),
//                                           Padding(
//                                               padding: EdgeInsets.all(8),
//                                               child: Text('Partial',
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold))),
//                                         ],
//                                       ),
//                                       TableRow(
//                                         children: [
//                                           Padding(
//                                               padding: const EdgeInsets.all(8),
//                                               child: Text(
//                                                   item.batchNumber ?? 'N/A')),
//                                           Padding(
//                                               padding: const EdgeInsets.all(8),
//                                               child: Text('$remainingQty')),
//                                           Padding(
//                                             padding: const EdgeInsets.all(8),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 IconButton(
//                                                   icon: const Icon(
//                                                       Icons
//                                                           .remove_circle_outline,
//                                                       color: Color(0xFFF59422)),
//                                                   onPressed: currentQty > 0
//                                                       ? () => setState(() {
//                                                             _quantities[
//                                                                     item.id] =
//                                                                 currentQty - 1;
//                                                           })
//                                                       : null,
//                                                 ),
//                                                 Text('$currentQty',
//                                                     style: const TextStyle(
//                                                         fontSize: 16)),
//                                                 IconButton(
//                                                   icon: const Icon(
//                                                       Icons.add_circle_outline,
//                                                       color: Color(0xFFF59422)),
//                                                   onPressed: currentQty <
//                                                           remainingQty
//                                                       ? () => setState(() {
//                                                             _quantities[
//                                                                     item.id] =
//                                                                 currentQty + 1;
//                                                           })
//                                                       : null,
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Padding(
//                                               padding: const EdgeInsets.all(8),
//                                               child: Text(
//                                                   rate.toStringAsFixed(2))),
//                                           Padding(
//                                               padding: const EdgeInsets.all(8),
//                                               child: Text(itemTotal
//                                                   .toStringAsFixed(2))),
//                                           Padding(
//                                             padding: const EdgeInsets.all(8),
//                                             child: Switch(
//                                               value: _isPartial,
//                                               activeThumbColor:
//                                                   const Color(0xFFF59422),
//                                               onChanged: (v) => setState(
//                                                   () => _isPartial = v),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   color: Colors.orange[50],
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                             'Taxable Amount: Rs. ${_taxableAmount.toStringAsFixed(2)}',
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 4),
//                         Text('VAT (13%): Rs. ${_vat.toStringAsFixed(2)}',
//                             style: const TextStyle(color: Color(0xFFF59422))),
//                         const Divider(height: 24),
//                         Text(
//                           'Total Refund: Rs. ${_totalRefund.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFFF59422)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 54,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_selectedPurchase == null ||
//                           _selectedNepaliDate == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text(
//                                   'Please select purchase and return date')),
//                         );
//                         return;
//                       }

//                       final apiDate =
//                           '${_selectedNepaliDate!.year}-${_selectedNepaliDate!.month.toString().padLeft(2, '0')}-${_selectedNepaliDate!.day.toString().padLeft(2, '0')}';

//                       final items = _selectedPurchase!.items
//                           .where((item) => (_quantities[item.id] ?? 0) > 0)
//                           .map((item) {
//                         return {
//                           'product': item.product,
//                           'quantity': _quantities[item.id] ?? 0,
//                           'rate': _parseDouble(item.costPrice),
//                           'batch_number': item.batchNumber ?? '',
//                         };
//                       }).toList();

//                       if (items.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text('No items selected for return')),
//                         );
//                         return;
//                       }

//                       context.read<PurchaseReturnBloc>().add(
//                             CreatePurchaseReturn(
//                               purchaseId: _selectedPurchase!.id,
//                               returnDate: apiDate,
//                               reason: _reasonController.text.trim(),
//                               items: items,
//                             ),
//                           );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF59422),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       elevation: 3,
//                     ),
//                     child: const Text(
//                       'Add Return',
//                       style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:saleup_app/screen/purchase/view/datepiker.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
import 'package:saleup_app/screen/purchaseReturn/model/purchase.dart';

class AddPurchaseReturnScreen extends StatefulWidget {
  const AddPurchaseReturnScreen({super.key});

  @override
  State<AddPurchaseReturnScreen> createState() =>
      _AddPurchaseReturnScreenState();
}

class _AddPurchaseReturnScreenState extends State<AddPurchaseReturnScreen> {
  Purchase? _selectedPurchase;
  NepaliDateTime? _selectedNepaliDate;
  final _reasonController = TextEditingController(text: 'damage');

  bool _returnThisItem = false;

  final Map<int, int> _quantities = {};
  final Map<int, bool> _isPartial = {};
  final Map<int, double> _customAmounts = {};

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _getItemTotal(PurchaseItem item) {
    if (!_returnThisItem) return 0.0;

    final isPartial = _isPartial[item.id] ?? false;
    if (isPartial) {
      return _customAmounts[item.id] ?? 0.0;
    }
    final qty = _quantities[item.id] ?? 0;
    final rate = _parseDouble(item.costPrice);
    return qty * rate;
  }

  double get _taxableAmount {
    if (_selectedPurchase == null) return 0.0;
    return _selectedPurchase!.items
        .fold(0.0, (sum, item) => sum + _getItemTotal(item));
  }

  double get _vat => _taxableAmount * 0.13;
  double get _totalRefund => _taxableAmount + _vat;

  String _formatNepaliDate(NepaliDateTime? date) {
    if (date == null) return 'Select Date (BS)';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    context.read<PurchaseReturnBloc>().add(const LoadPurchasesForReturn());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 72,
        leading: GestureDetector(
          onTap: () => context.go('/purchase-return'),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Image.asset(
              'assets/images/back_button_logo.png',
              width: 44,
              height: 44,
            ),
          ),
        ),
        title: const Text(
          'Purchase Return',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<PurchaseReturnBloc, PurchaseReturnState>(
        listener: (context, state) {
          if (state is PurchaseReturnCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Return created → ${state.purchaseReturn.invoiceNumber ?? "N/A"}'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<PurchaseReturnBloc>().add(const LoadPurchaseReturns());
            context.pop(true);
          }
          if (state is PurchaseReturnError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PurchasesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final purchases =
              state is PurchasesLoaded ? state.purchases : <Purchase>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '* Purchase   * Reason   * Return Date',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Purchase>(
                          initialValue: _selectedPurchase,
                          decoration: InputDecoration(
                            labelText: 'Purchase',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: purchases.map((p) {
                            return DropdownMenuItem<Purchase>(
                              value: p,
                              child: Text(
                                  '${p.invoiceNumber} - ${p.party} (Rs. ${p.total.toStringAsFixed(2)})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPurchase = val;
                              _quantities.clear();
                              _isPartial.clear();
                              _customAmounts.clear();
                              _returnThisItem = false;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reasonController,
                          decoration: InputDecoration(
                            labelText: 'Reason',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final picked = await showDialog<NepaliDateTime>(
                              context: context,
                              builder: (dialogContext) =>
                                  NepaliDatePickerDialog(
                                initialDate:
                                    _selectedNepaliDate ?? NepaliDateTime.now(),
                                firstDate: NepaliDateTime(2075, 1, 1),
                                lastDate: NepaliDateTime(2099, 12, 30),
                                onDateSelected: (date) =>
                                    Navigator.pop(dialogContext, date),
                              ),
                            );
                            if (picked != null && mounted) {
                              setState(() => _selectedNepaliDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Return Date',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            child: Text(_formatNepaliDate(_selectedNepaliDate)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _returnThisItem,
                              activeColor: const Color(0xFFF59422),
                              onChanged: (v) {
                                setState(() {
                                  _returnThisItem = v ?? false;
                                  if (!_returnThisItem) {
                                    _quantities.clear();
                                    _isPartial.clear();
                                    _customAmounts.clear();
                                  }
                                });
                              },
                            ),
                            const Text('Return this item',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_selectedPurchase == null ||
                            _selectedPurchase!.items.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Select a purchase to show items',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)),
                            ),
                          )
                        else ...[
                          ..._selectedPurchase!.items.map((item) {
                            final remainingQty = _parseInt(item.quantity);
                            final rate = _parseDouble(item.costPrice);
                            final currentQty = _quantities[item.id] ?? 0;
                            final isPartial = _isPartial[item.id] ?? false;
                            final customAmount = _customAmounts[item.id] ?? 0.0;
                            final displayedTotal = _getItemTotal(item);

                            final productDisplay = item.product ?? 'Unnamed';
                            final batchDisplay = item.batchNumber ?? 'N/A';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$productDisplay (Batch: $batchDisplay)',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('Partial refund? '),
                                      Switch(
                                        value: isPartial,
                                        activeThumbColor:
                                            const Color(0xFFF59422),
                                        onChanged: _returnThisItem
                                            ? (v) {
                                                setState(() {
                                                  _isPartial[item.id] = v;
                                                  if (!v) {
                                                    _customAmounts
                                                        .remove(item.id);
                                                  } else if (currentQty > 0) {
                                                    _customAmounts[item.id] =
                                                        currentQty * rate;
                                                  }
                                                });
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Table(
                                      border: TableBorder.all(
                                          color: Colors.grey[300]!),
                                      columnWidths: const {
                                        0: FixedColumnWidth(140),
                                        1: FixedColumnWidth(90),
                                        2: FixedColumnWidth(160),
                                        3: FixedColumnWidth(100),
                                        4: FixedColumnWidth(120),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        const TableRow(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFFFF3E0)),
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text('Batch',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text('Rem. Qty',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text('Quantity',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text('Rate',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text('Total',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(batchDisplay,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text('$remainingQty')),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 8),
                                              child: remainingQty == 0
                                                  ? const Center(
                                                      child: Text(
                                                        '0 (No return possible)',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 15),
                                                      ),
                                                    )
                                                  : isPartial
                                                      ? const Center(
                                                          child: Text('—',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      18)))
                                                      : TextFormField(
                                                          initialValue:
                                                              currentQty
                                                                  .toString(),
                                                          enabled: remainingQty >
                                                                  0 &&
                                                              _returnThisItem,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        12,
                                                                    horizontal:
                                                                        8),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .blue),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .blue),
                                                            ),
                                                            disabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Color(
                                                                          0xFFF59422),
                                                                      width: 2),
                                                            ),
                                                          ),
                                                          onChanged: (value) {
                                                            if (remainingQty ==
                                                                0) {
                                                              return;
                                                            }

                                                            final newQty =
                                                                int.tryParse(
                                                                        value) ??
                                                                    0;
                                                            int clamped =
                                                                newQty.clamp(0,
                                                                    remainingQty);

                                                            if (newQty !=
                                                                clamped) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    newQty >
                                                                            remainingQty
                                                                        ? "Cannot exceed remaining quantity ($remainingQty)"
                                                                        : "Quantity cannot be negative",
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            setState(() {
                                                              _quantities[
                                                                      item.id] =
                                                                  clamped;
                                                            });
                                                          },
                                                        ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(
                                                    rate.toStringAsFixed(2))),
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: isPartial
                                                  ? SizedBox(
                                                      width: 110,
                                                      child: TextFormField(
                                                        initialValue:
                                                            customAmount
                                                                .toStringAsFixed(
                                                                    2),
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(
                                                                decimal: true),
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      8),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6)),
                                                        ),
                                                        onChanged: (val) {
                                                          setState(() {
                                                            _customAmounts[
                                                                    item.id] =
                                                                _parseDouble(
                                                                    val);
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  : Text(displayedTotal
                                                      .toStringAsFixed(2)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Taxable Amount: Rs. ${_taxableAmount.toStringAsFixed(2)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('VAT (13%): Rs. ${_vat.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFFF59422))),
                        const Divider(height: 24),
                        Text(
                          'Total Refund: Rs. ${_totalRefund.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59422)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_selectedPurchase == null ||
                          _selectedNepaliDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please select purchase and return date')),
                        );
                        return;
                      }

                      if (!_returnThisItem) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please enable "Return this item"')),
                        );
                        return;
                      }

                      final gregorian = _selectedNepaliDate!.toDateTime();
                      final apiDate =
                          '${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}';

                      final items = _selectedPurchase!.items
                          .where((item) => _getItemTotal(item) > 0)
                          .map((item) {
                            final remainingQty = _parseInt(item.quantity);
                            final isPartial = _isPartial[item.id] ?? false;
                            final qty =
                                isPartial ? 0 : (_quantities[item.id] ?? 0);

                            // ──── IMPORTANT FIX ────
                            // Backend validates 'product' as batch_number → send batch here
                            final productValue =
                                (item.batchNumber ?? '').trim().isNotEmpty
                                    ? item.batchNumber!
                                    : (item.product ?? '');

                            if (productValue.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Item missing batch/product identifier')),
                              );
                              return null;
                            }

                            return {
                              'product': productValue,
                              'quantity': qty,
                              'rate': _parseDouble(item.costPrice),
                              'batch_number': item.batchNumber ?? '',
                            };
                          })
                          .whereType<Map<String, dynamic>>()
                          .toList();

                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('No valid items selected for return')),
                        );
                        return;
                      }

                      print("=== CREATE PURCHASE RETURN PAYLOAD ===");
                      print("purchase: ${_selectedPurchase!.id}");
                      print("return_date: $apiDate");
                      print("reason: ${_reasonController.text.trim()}");
                      print("items: $items");
                      print("=====================================");

                      try {
                        context.read<PurchaseReturnBloc>().add(
                              CreatePurchaseReturn(
                                purchaseId: _selectedPurchase!.id,
                                returnDate: apiDate,
                                reason: _reasonController.text.trim(),
                                items: items,
                              ),
                            );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sending request: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59422),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Add Return',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
