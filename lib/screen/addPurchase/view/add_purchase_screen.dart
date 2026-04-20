// // =============================================
// // add_purchase_screen.dart  → UI matches image design
// // =============================================
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/purchase_response.dart';
// import 'package:saleup_app/screen/addPurchase/bloc/purchase_form_bloc.dart';
// import 'package:saleup_app/screen/addPurchase/bloc/purchase_form_event.dart';
// import 'package:saleup_app/screen/addPurchase/bloc/purchase_form_state.dart';

// class AddPurchaseScreen extends StatelessWidget {
//   final PurchaseData? purchase;

//   const AddPurchaseScreen({super.key, this.purchase});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => PurchaseFormBloc(
//         dioClient: DioClient(),
//         initialPurchase: purchase,
//       )..add(InitializePurchaseForm(existingPurchase: purchase)),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF4F6F8),
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFF4F6F8),
//           elevation: 0,
//           titleSpacing: 16,
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 purchase == null ? 'Add Purchase' : 'Edit Purchase',
//                 style: const TextStyle(
//                   color: Color(0xFF1A1A2E),
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Text(
//                 'Stock Inventory > Purchase > Add Purchase',
//                 style: TextStyle(
//                   color: Color(0xFF9E9E9E),
//                   fontSize: 12,
//                   fontWeight: FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//           toolbarHeight: 72,
//         ),
//         body: BlocConsumer<PurchaseFormBloc, PurchaseFormState>(
//           listener: (context, state) {
//             if (state.success) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Purchase saved successfully'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//               Navigator.pop(context, true);
//             }
//             if (state.error != null) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(state.error!),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           builder: (context, state) {
//             if (state.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             final bloc = context.read<PurchaseFormBloc>();

//             return Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // ── Top Form Card ──
//                         _buildCard(
//                           child: Column(
//                             children: [
//                               // Invoice Number + Party
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildField(
//                                       label: 'Invoice Number:',
//                                       child: TextField(
//                                         decoration:
//                                             _inputDecoration('Discount Amount'),
//                                         controller: TextEditingController(
//                                             text: state.invoiceNumber),
//                                         onChanged: (v) =>
//                                             bloc.add(ChangeInvoiceNumber(v)),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _buildField(
//                                       label: 'Party',
//                                       child: DropdownButtonFormField<String>(
//                                         initialValue: state.selectedParty,
//                                         decoration:
//                                             _inputDecoration('Select Party'),
//                                         items: state.parties
//                                             .map((p) => DropdownMenuItem(
//                                                 value: p, child: Text(p)))
//                                             .toList(),
//                                         onChanged: (v) =>
//                                             bloc.add(ChangeParty(v)),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               // Payment Mode + Date
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildField(
//                                       label: 'Payment Mode:',
//                                       child: DropdownButtonFormField<String>(
//                                         initialValue: state.billType,
//                                         decoration: _inputDecoration('Cash'),
//                                         items: const [
//                                           'Cash',
//                                           'Cheque',
//                                           'Credit',
//                                           'Fonepay'
//                                         ]
//                                             .map((e) => DropdownMenuItem(
//                                                 value: e, child: Text(e)))
//                                             .toList(),
//                                         onChanged: (v) {
//                                           if (v != null) {
//                                             bloc.add(ChangeBillType(v));
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _buildField(
//                                       label: 'Date:',
//                                       child: TextField(
//                                         readOnly: true,
//                                         decoration:
//                                             _inputDecoration('').copyWith(
//                                           suffixIcon: const Icon(
//                                               Icons.calendar_today,
//                                               size: 18,
//                                               color: Colors.grey),
//                                         ),
//                                         controller: TextEditingController(
//                                             text: state.date),
//                                         onTap: () async {
//                                           final picked = await showDatePicker(
//                                             context: context,
//                                             initialDate:
//                                                 DateTime.tryParse(state.date) ??
//                                                     DateTime.now(),
//                                             firstDate: DateTime(2020),
//                                             lastDate: DateTime(2035),
//                                           );
//                                           if (picked != null) {
//                                             bloc.add(ChangeDate(
//                                                 DateFormat('yyyy-MM-dd')
//                                                     .format(picked)));
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               // Conditional: Bank cheque fields
//                               if (state.billType == 'Bank') ...[
//                                 const SizedBox(height: 12),
//                                 Row(
//                                   children: [
//                                     const Expanded(
//                                       child: TextField(
//                                         decoration: InputDecoration(
//                                           labelText: 'Cheque Number',
//                                           border: OutlineInputBorder(),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: TextField(
//                                         readOnly: true,
//                                         decoration: const InputDecoration(
//                                           labelText: 'Cheque Date',
//                                           border: OutlineInputBorder(),
//                                           suffixIcon:
//                                               Icon(Icons.calendar_today),
//                                         ),
//                                         controller: TextEditingController(
//                                             text: state.date),
//                                         onTap: () async {
//                                           await showDatePicker(
//                                             context: context,
//                                             initialDate: DateTime.now(),
//                                             firstDate: DateTime(2020),
//                                             lastDate: DateTime(2035),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],

//                               // Conditional: Cash balance
//                               if (state.billType == 'Cash') ...[
//                                 const SizedBox(height: 8),
//                                 Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     'Available Cash: Rs ${state.cashBalance.toStringAsFixed(2)}',
//                                     style: const TextStyle(
//                                         color: Colors.green,
//                                         fontWeight: FontWeight.w600),
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 12),

//                         // ── Add Product Button ──
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: ElevatedButton.icon(
//                             icon: const Icon(Icons.add,
//                                 size: 18, color: Colors.white),
//                             label: const Text(
//                               'Add Product',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFF5A623),
//                               elevation: 0,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                             ),
//                             onPressed: () =>
//                                 _showAddItemDialog(context, state, bloc),
//                           ),
//                         ),

//                         const SizedBox(height: 10),

//                         // ── Items Table Card ──
//                         _buildCard(
//                           padding: EdgeInsets.zero,
//                           child: Column(
//                             children: [
//                               // Header + Rows (horizontally scrollable)
//                               SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Header Row
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 12, vertical: 10),
//                                       child: Row(
//                                         children: [
//                                           Checkbox(
//                                             value: false,
//                                             onChanged: (_) {},
//                                             materialTapTargetSize:
//                                                 MaterialTapTargetSize
//                                                     .shrinkWrap,
//                                             visualDensity:
//                                                 VisualDensity.compact,
//                                           ),
//                                           const SizedBox(width: 4),
//                                           _fixedHeaderCell('SN', width: 40),
//                                           _fixedHeaderCell('Product',
//                                               width: 110),
//                                           _fixedHeaderCell('Qty', width: 55),
//                                           _fixedHeaderCell('Unit', width: 60),
//                                           _fixedHeaderCell('Cost Price',
//                                               width: 95),
//                                           _fixedHeaderCell('Selling Price',
//                                               width: 100),
//                                           _fixedHeaderCell('Total', width: 85),
//                                           _fixedHeaderCell('Batch No.',
//                                               width: 95),
//                                           _fixedHeaderCell('Expiry Date',
//                                               width: 105),
//                                           _fixedHeaderCell('Complementary',
//                                               width: 110),
//                                           _fixedHeaderCell('Action', width: 60),
//                                         ],
//                                       ),
//                                     ),
//                                     // Dashed divider
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 12),
//                                       child: SizedBox(
//                                         width: 1000,
//                                         height: 1,
//                                         child: CustomPaint(
//                                             painter: _DashedLinePainter()),
//                                       ),
//                                     ),
//                                     // Rows or empty space
//                                     if (state.items.isEmpty)
//                                       const SizedBox(height: 120, width: 1000)
//                                     else
//                                       ...state.items
//                                           .asMap()
//                                           .entries
//                                           .map((entry) {
//                                         final i = entry.key;
//                                         final item = entry.value;
//                                         return Container(
//                                           decoration: const BoxDecoration(
//                                             border: Border(
//                                               bottom: BorderSide(
//                                                   color: Color(0xFFF0F0F0)),
//                                             ),
//                                           ),
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 12, vertical: 10),
//                                           child: Row(
//                                             children: [
//                                               const SizedBox(width: 36),
//                                               _fixedDataCell('${i + 1}',
//                                                   width: 40),
//                                               _fixedDataCell(
//                                                   item.product ?? '-',
//                                                   width: 110),
//                                               _fixedDataCell(
//                                                   '${item.quantity ?? 0}',
//                                                   width: 55),
//                                               _fixedDataCell(item.unit ?? 'PCS',
//                                                   width: 60),
//                                               _fixedDataCell(
//                                                   item.costPrice
//                                                           ?.toStringAsFixed(
//                                                               2) ??
//                                                       '-',
//                                                   width: 95),
//                                               _fixedDataCell(
//                                                   item.sellingPrice
//                                                           ?.toStringAsFixed(
//                                                               2) ??
//                                                       '0.00',
//                                                   width: 100),
//                                               _fixedDataCell(
//                                                   item.total?.toStringAsFixed(
//                                                           2) ??
//                                                       '0.00',
//                                                   width: 85),
//                                               _fixedDataCell(
//                                                   item.batchNumber ?? '-',
//                                                   width: 95),
//                                               _fixedDataCell(
//                                                 item.expiryDate != null
//                                                     ? DateFormat('yyyy-MM-dd')
//                                                         .format(
//                                                             item.expiryDate!)
//                                                     : '-',
//                                                 width: 105,
//                                               ),
//                                               _fixedDataCell(
//                                                   item.isComplementary
//                                                       ? 'Yes'
//                                                       : 'No',
//                                                   width: 110),
//                                               SizedBox(
//                                                 width: 60,
//                                                 child: IconButton(
//                                                   icon: const Icon(Icons.delete,
//                                                       color: Colors.red,
//                                                       size: 18),
//                                                   onPressed: () =>
//                                                       bloc.add(RemoveItem(i)),
//                                                   padding: EdgeInsets.zero,
//                                                   constraints:
//                                                       const BoxConstraints(),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       }),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 12),

//                         // ── Summary Card ──
//                         _buildCard(
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                       child: _buildSummaryBox('Sub Total',
//                                           state.subTotal.toStringAsFixed(2))),
//                                   const SizedBox(width: 5),
//                                   Expanded(
//                                       child: _buildSummaryBox('Discount',
//                                           state.discount.toStringAsFixed(2))),
//                                   const SizedBox(width: 5),
//                                   Expanded(
//                                       child: _buildSummaryBox(
//                                           'Vatable Amt',
//                                           state.taxableAmount
//                                               .toStringAsFixed(2))),
//                                 ],
//                               ),
//                               const SizedBox(height: 10),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                       child: _buildSummaryBox(
//                                           'VAT', state.vat.toStringAsFixed(2))),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: Container(
//                                       padding: const EdgeInsets.all(14),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFFF5A623),
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const Text('Grand Total:',
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w600)),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             state.grandTotal.toStringAsFixed(2),
//                                             style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   const Expanded(child: SizedBox()),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 16),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // ── Bottom Submit Button ──
//                 Container(
//                   color: Colors.white,
//                   padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//                   child: state.isSubmitting
//                       ? const Center(child: CircularProgressIndicator())
//                       : SizedBox(
//                           width: double.infinity,
//                           height: 52,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFF5A623),
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)),
//                             ),
//                             onPressed: () => bloc.add(SubmitForm()),
//                             child: Text(
//                               purchase == null ? 'Add' : 'Update',
//                               style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white),
//                             ),
//                           ),
//                         ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildCard({required Widget child, EdgeInsets? padding}) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: padding ?? const EdgeInsets.all(16),
//       child: child,
//     );
//   }

//   Widget _buildField({required String label, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 12,
//                 color: Color(0xFF666666),
//                 fontWeight: FontWeight.w500)),
//         const SizedBox(height: 4),
//         child,
//       ],
//     );
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFFF5A623)),
//       ),
//       filled: true,
//       fillColor: Colors.white,
//       isDense: true,
//     );
//   }

//   Widget _fixedHeaderCell(String label, {required double width}) {
//     return SizedBox(
//       width: width,
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF555555),
//         ),
//       ),
//     );
//   }

//   Widget _fixedDataCell(String value, {required double width}) {
//     return SizedBox(
//       width: width,
//       child: Text(
//         value,
//         style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }

//   Widget _headerCell(String label, {required int flex}) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF555555),
//         ),
//       ),
//     );
//   }

//   Widget _dataCell(String value, {required int flex}) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         value,
//         style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
//       ),
//     );
//   }
// }

// class _DashedLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFCCCCCC)
//       ..strokeWidth = 1;
//     const dashWidth = 6.0;
//     const dashSpace = 4.0;
//     double startX = 0;
//     while (startX < size.width) {
//       canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
//       startX += dashWidth + dashSpace;
//     }
//   }

//   @override
//   bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
// }

// Widget _buildSummaryBox(String title, String value, {String? valueOverride}) {
//   return Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: const Color(0xFFF9F9F9),
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: const Color(0xFFEEEEEE)),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title,
//             style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF333333))),
//         const SizedBox(height: 4),
//         Text(value,
//             style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
//       ],
//     ),
//   );
// }

// void _showAddItemDialog(
//     BuildContext context, PurchaseFormState state, PurchaseFormBloc bloc) {
//   String? selectedProduct;
//   final qtyCtrl = TextEditingController(text: '1');
//   final costPriceCtrl = TextEditingController();
//   final sellingPriceCtrl = TextEditingController(text: '0.00');
//   final batchCtrl = TextEditingController();
//   DateTime? selectedExpiry;
//   bool isComplementary = false;
//   bool noExpiry = false;

//   showDialog(
//     context: context,
//     builder: (dialogCtx) {
//       return StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: const Text('Add Purchase Item'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 DropdownButtonFormField<String>(
//                   initialValue: selectedProduct,
//                   isExpanded: true,
//                   hint: const Text('Select Product'),
//                   items: state.products
//                       .map((p) => DropdownMenuItem(value: p, child: Text(p)))
//                       .toList(),
//                   onChanged: (v) => setDialogState(() => selectedProduct = v),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: qtyCtrl,
//                   decoration: const InputDecoration(labelText: 'Quantity'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: costPriceCtrl,
//                   decoration:
//                       const InputDecoration(labelText: 'Cost Price (per unit)'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: sellingPriceCtrl,
//                   decoration: const InputDecoration(
//                       labelText: 'Selling Price (per unit)'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: batchCtrl,
//                   decoration: const InputDecoration(labelText: 'Batch Number'),
//                   enabled: !noExpiry,
//                 ),
//                 const SizedBox(height: 12),
//                 ListTile(
//                   title: const Text('Expiry Date'),
//                   subtitle: Text(
//                     selectedExpiry != null
//                         ? DateFormat('yyyy-MM-dd').format(selectedExpiry!)
//                         : 'Not set',
//                   ),
//                   trailing: const Icon(Icons.calendar_today),
//                   enabled: !noExpiry,
//                   onTap: noExpiry
//                       ? null
//                       : () async {
//                           final picked = await showDatePicker(
//                             context: dialogCtx,
//                             initialDate: selectedExpiry ?? DateTime.now(),
//                             firstDate: DateTime.now(),
//                             lastDate: DateTime(2035),
//                           );
//                           if (picked != null) {
//                             setDialogState(() => selectedExpiry = picked);
//                           }
//                         },
//                 ),
//                 CheckboxListTile(
//                   title: const Text('No Expiry Date'),
//                   value: noExpiry,
//                   onChanged: (val) {
//                     setDialogState(() {
//                       noExpiry = val ?? false;
//                       if (noExpiry) {
//                         selectedExpiry = null;
//                         batchCtrl.clear();
//                       }
//                     });
//                   },
//                   controlAffinity: ListTileControlAffinity.leading,
//                 ),
//                 CheckboxListTile(
//                   title: const Text('Complementary Item'),
//                   value: isComplementary,
//                   onChanged: (val) =>
//                       setDialogState(() => isComplementary = val ?? false),
//                   controlAffinity: ListTileControlAffinity.leading,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogCtx),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 final qty = int.tryParse(qtyCtrl.text) ?? 0;
//                 final costPrice = double.tryParse(costPriceCtrl.text) ?? 0.0;
//                 final sellingPrice =
//                     double.tryParse(sellingPriceCtrl.text) ?? 0.0;
//                 final batch = batchCtrl.text.trim();

//                 if (qty <= 0 || costPrice <= 0 || selectedProduct == null) {
//                   ScaffoldMessenger.of(dialogCtx).showSnackBar(
//                     const SnackBar(
//                         content: Text('Quantity and Cost Price must be > 0')),
//                   );
//                   return;
//                 }

//                 if (!noExpiry &&
//                     batch.isNotEmpty &&
//                     state.items.any((it) => it.batchNumber == batch)) {
//                   ScaffoldMessenger.of(dialogCtx).showSnackBar(
//                     const SnackBar(
//                         content: Text('Batch number must be unique')),
//                   );
//                   return;
//                 }

//                 final item = PurchaseItem(
//                   product: selectedProduct,
//                   quantity: qty,
//                   unit: 'PCS',
//                   costPrice: costPrice,
//                   sellingPrice: sellingPrice,
//                   total: qty * costPrice,
//                   batchNumber: noExpiry || batch.isEmpty ? null : batch,
//                   expiryDate: noExpiry ? null : selectedExpiry,
//                   isComplementary: isComplementary,
//                 );

//                 bloc.add(AddItem(item));
//                 Navigator.pop(dialogCtx);
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// =============================================
// add_purchase_screen.dart  → UI matches image design
// =============================================
//update added

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'package:saleup_app/screen/addPurchase/bloc/purchase_form_bloc.dart';
import 'package:saleup_app/screen/addPurchase/bloc/purchase_form_event.dart';
import 'package:saleup_app/screen/addPurchase/bloc/purchase_form_state.dart';
import 'package:saleup_app/utility/datepiker.dart';

class AddPurchaseScreen extends StatelessWidget {
  final PurchaseData? purchase;

  const AddPurchaseScreen({super.key, this.purchase});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PurchaseFormBloc(
        dioClient: DioClient(),
        initialPurchase: purchase,
      )..add(InitializePurchaseForm(existingPurchase: purchase)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F6F8),
          elevation: 0,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                purchase == null ? 'Add Purchase' : 'Edit Purchase',
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Stock Inventory > Purchase > Add Purchase',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          toolbarHeight: 72,
        ),
        body: BlocConsumer<PurchaseFormBloc, PurchaseFormState>(
          listener: (context, state) {
            if (state.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final bloc = context.read<PurchaseFormBloc>();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Top Form Card ──
                        _buildCard(
                          child: Column(
                            children: [
                              // Invoice Number + Party
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      label: 'Invoice Number:',
                                      child: TextField(
                                        decoration:
                                            _inputDecoration('Discount Amount'),
                                        controller: TextEditingController(
                                            text: state.invoiceNumber),
                                        onChanged: (v) =>
                                            bloc.add(ChangeInvoiceNumber(v)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildField(
                                      label: 'Party',
                                      child: DropdownButtonFormField<String>(
                                        initialValue: state.selectedParty,
                                        decoration:
                                            _inputDecoration('Select Party'),
                                        items: state.parties
                                            .map((p) => DropdownMenuItem(
                                                value: p, child: Text(p)))
                                            .toList(),
                                        onChanged: (v) =>
                                            bloc.add(ChangeParty(v)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Payment Mode + Date
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      label: 'Payment Mode:',
                                      child: DropdownButtonFormField<String>(
                                        initialValue: state.billType,
                                        decoration: _inputDecoration('Cash'),
                                        items: const [
                                          'Cash',
                                          'Bank',
                                          'Credit',
                                          'Fonepay'
                                        ]
                                            .map((e) => DropdownMenuItem(
                                                value: e, child: Text(e)))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            bloc.add(ChangeBillType(v));
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildField(
                                      label: 'Date:',
                                      child: TextField(
                                        readOnly: true,
                                        decoration:
                                            _inputDecoration('').copyWith(
                                          suffixIcon: const Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                              color: Colors.grey),
                                        ),
                                        controller: TextEditingController(
                                            text: state.date),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                NepaliDatePickerDialog(
                                              initialDate: NepaliDateTime.now(),
                                              firstDate: NepaliDateTime(2076),
                                              lastDate: NepaliDateTime(2092),
                                              onDateSelected: (nepDate) {
                                                final ad = nepDate.toDateTime();
                                                bloc.add(ChangeDate(
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(ad)));
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Conditional: Bank cheque fields
                              if (state.billType == 'Bank') ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Cheque Number',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Cheque Date',
                                          border: OutlineInputBorder(),
                                          suffixIcon:
                                              Icon(Icons.calendar_today),
                                        ),
                                        controller: TextEditingController(
                                            text: state.date),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                NepaliDatePickerDialog(
                                              initialDate: NepaliDateTime.now(),
                                              firstDate: NepaliDateTime(2076),
                                              lastDate: NepaliDateTime(2092),
                                              onDateSelected: (nepDate) {
                                                final ad = nepDate.toDateTime();
                                                bloc.add(ChangeDate(
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(ad)));
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // Conditional: Cash balance
                              if (state.billType == 'Cash') ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Available Cash: Rs ${state.cashBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Add Product Button ──
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add,
                                size: 18, color: Colors.white),
                            label: const Text(
                              'Add Product',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5A623),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () =>
                                _showAddItemDialog(context, state, bloc),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Items Table Card ──
                        _buildCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              // Header + Rows (horizontally scrollable)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Row
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: false,
                                            onChanged: (_) {},
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          const SizedBox(width: 4),
                                          _fixedHeaderCell('SN', width: 40),
                                          _fixedHeaderCell('Product',
                                              width: 110),
                                          _fixedHeaderCell('Qty', width: 55),
                                          _fixedHeaderCell('Unit', width: 60),
                                          _fixedHeaderCell('Cost Price',
                                              width: 95),
                                          _fixedHeaderCell('Selling Price',
                                              width: 100),
                                          _fixedHeaderCell('Total', width: 85),
                                          _fixedHeaderCell('Batch No.',
                                              width: 95),
                                          _fixedHeaderCell('Expiry Date',
                                              width: 105),
                                          _fixedHeaderCell('Complementary',
                                              width: 110),
                                          _fixedHeaderCell('Action', width: 60),
                                        ],
                                      ),
                                    ),
                                    // Dashed divider
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: SizedBox(
                                        width: 1000,
                                        height: 1,
                                        child: CustomPaint(
                                            painter: _DashedLinePainter()),
                                      ),
                                    ),
                                    // Rows or empty space
                                    if (state.items.isEmpty)
                                      const SizedBox(height: 120, width: 1000)
                                    else
                                      ...state.items
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final i = entry.key;
                                        final item = entry.value;
                                        return Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: Color(0xFFF0F0F0)),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 36),
                                              _fixedDataCell('${i + 1}',
                                                  width: 40),
                                              _fixedDataCell(
                                                  item.product ?? '-',
                                                  width: 110),
                                              _fixedDataCell(
                                                  '${item.quantity ?? 0}',
                                                  width: 55),
                                              _fixedDataCell(item.unit ?? 'PCS',
                                                  width: 60),
                                              _fixedDataCell(
                                                  item.costPrice
                                                          ?.toStringAsFixed(
                                                              2) ??
                                                      '-',
                                                  width: 95),
                                              _fixedDataCell(
                                                  item.sellingPrice
                                                          ?.toStringAsFixed(
                                                              2) ??
                                                      '0.00',
                                                  width: 100),
                                              _fixedDataCell(
                                                  item.total?.toStringAsFixed(
                                                          2) ??
                                                      '0.00',
                                                  width: 85),
                                              _fixedDataCell(
                                                  item.batchNumber ?? '-',
                                                  width: 95),
                                              _fixedDataCell(
                                                item.expiryDate != null
                                                    ? DateFormat('yyyy-MM-dd')
                                                        .format(
                                                            item.expiryDate!)
                                                    : '-',
                                                width: 105,
                                              ),
                                              _fixedDataCell(
                                                  item.isComplementary
                                                      ? 'Yes'
                                                      : 'No',
                                                  width: 110),
                                              SizedBox(
                                                width: 60,
                                                child: IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red,
                                                      size: 18),
                                                  onPressed: () =>
                                                      bloc.add(RemoveItem(i)),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Summary Card ──
                        _buildCard(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: _buildSummaryBox('Sub Total',
                                          state.subTotal.toStringAsFixed(2))),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: _buildSummaryBox('Discount',
                                          state.discount.toStringAsFixed(2))),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: _buildSummaryBox(
                                          'Vatable Amount',
                                          state.taxableAmount
                                              .toStringAsFixed(2))),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                      child: _buildSummaryBox(
                                          'VAT', state.vat.toStringAsFixed(2))),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5A623),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Grand Total:',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Text(
                                            state.grandTotal.toStringAsFixed(2),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Bottom Submit Button ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: state.isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5A623),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => bloc.add(SubmitForm()),
                            child: Text(
                              purchase == null ? 'Add' : 'Update',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFF5A623)),
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
    );
  }

  Widget _fixedHeaderCell(String label, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF555555),
        ),
      ),
    );
  }

  Widget _fixedDataCell(String value, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _headerCell(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF555555),
        ),
      ),
    );
  }

  Widget _dataCell(String value, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}

Widget _buildSummaryBox(String title, String value) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF9F9F9),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFEEEEEE)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333))),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
      ],
    ),
  );
}

// void _showAddItemDialog(
//     BuildContext context, PurchaseFormState state, PurchaseFormBloc bloc) {
//   String? selectedProduct;
//   final qtyCtrl = TextEditingController(text: '1');
//   final costPriceCtrl = TextEditingController();
//   final sellingPriceCtrl = TextEditingController(text: '0.00');
//   final batchCtrl = TextEditingController();
//   DateTime? selectedExpiry;
//   bool isComplementary = false;
//   bool noExpiry = false;

//   showDialog(
//     context: context,
//     builder: (dialogCtx) {
//       return StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: const Text('Add Purchase Item'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 DropdownButtonFormField<String>(
//                   initialValue: selectedProduct,
//                   isExpanded: true,
//                   hint: const Text('Select Product'),
//                   items: state.products
//                       .map((p) => DropdownMenuItem(value: p, child: Text(p)))
//                       .toList(),
//                   onChanged: (v) => setDialogState(() => selectedProduct = v),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: qtyCtrl,
//                   decoration: const InputDecoration(labelText: 'Quantity'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: costPriceCtrl,
//                   decoration:
//                       const InputDecoration(labelText: 'Cost Price (per unit)'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: sellingPriceCtrl,
//                   decoration: const InputDecoration(
//                       labelText: 'Selling Price (per unit)'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: batchCtrl,
//                   decoration: const InputDecoration(labelText: 'Batch Number'),
//                   enabled: !noExpiry,
//                 ),
//                 const SizedBox(height: 12),
//                 ListTile(
//                   title: const Text('Expiry Date'),
//                   subtitle: Text(
//                     selectedExpiry != null
//                         ? DateFormat('yyyy-MM-dd').format(selectedExpiry!)
//                         : 'Not set',
//                   ),
//                   trailing: const Icon(Icons.calendar_today),
//                   enabled: !noExpiry,
//                   onTap: noExpiry
//                       ? null
//                       : () {
//                           showDialog(
//                             context: dialogCtx,
//                             builder: (_) => NepaliDatePickerDialog(
//                               initialDate: NepaliDateTime.now(),
//                               firstDate: NepaliDateTime(2076),
//                               lastDate: NepaliDateTime(2092),
//                               onDateSelected: (nepDate) {
//                                 final ad = nepDate.toDateTime();
//                                 setDialogState(() => selectedExpiry = ad);
//                                 Navigator.pop(dialogCtx);
//                               },
//                             ),
//                           );
//                         },
//                 ),
//                 CheckboxListTile(
//                   title: const Text('No Expiry Date'),
//                   value: noExpiry,
//                   onChanged: (val) {
//                     setDialogState(() {
//                       noExpiry = val ?? false;
//                       if (noExpiry) {
//                         selectedExpiry = null;
//                         batchCtrl.clear();
//                       }
//                     });
//                   },
//                   controlAffinity: ListTileControlAffinity.leading,
//                 ),
//                 CheckboxListTile(
//                   title: const Text('Complementary Item'),
//                   value: isComplementary,
//                   onChanged: (val) =>
//                       setDialogState(() => isComplementary = val ?? false),
//                   controlAffinity: ListTileControlAffinity.leading,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogCtx),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 final qty = int.tryParse(qtyCtrl.text) ?? 0;
//                 final costPrice = double.tryParse(costPriceCtrl.text) ?? 0.0;
//                 final sellingPrice =
//                     double.tryParse(sellingPriceCtrl.text) ?? 0.0;
//                 final batch = batchCtrl.text.trim();

//                 if (qty <= 0 || costPrice <= 0 || selectedProduct == null) {
//                   ScaffoldMessenger.of(dialogCtx).showSnackBar(
//                     const SnackBar(
//                         content: Text('Quantity and Cost Price must be > 0')),
//                   );
//                   return;
//                 }

//                 if (!noExpiry &&
//                     batch.isNotEmpty &&
//                     state.items.any((it) => it.batchNumber == batch)) {
//                   ScaffoldMessenger.of(dialogCtx).showSnackBar(
//                     const SnackBar(
//                         content: Text('Batch number must be unique')),
//                   );
//                   return;
//                 }

//                 final item = PurchaseItem(
//                   product: selectedProduct,
//                   quantity: qty,
//                   unit: 'PCS',
//                   costPrice: costPrice,
//                   sellingPrice: sellingPrice,
//                   total: qty * costPrice,
//                   batchNumber: noExpiry || batch.isEmpty ? null : batch,
//                   expiryDate: noExpiry ? null : selectedExpiry,
//                   isComplementary: isComplementary,
//                 );

//                 bloc.add(AddItem(item));
//                 Navigator.pop(dialogCtx);
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
void _showAddItemDialog(
  BuildContext context,
  PurchaseFormState state,
  PurchaseFormBloc bloc,
) {
  String? selectedProduct;
  String? selectedUnit;
  final qtyCtrl = TextEditingController(text: '1');
  final costPriceCtrl = TextEditingController();
  final batchCtrl = TextEditingController();
  DateTime? selectedExpiry;
  bool noExpiry = false;
  bool isComplementary = false;

  showDialog(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Product',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 28),
                onPressed: () => Navigator.pop(dialogCtx),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product + Quantity
                Row(
                  children: [
                    Expanded(child: _buildFieldLabel('Product Name')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFieldLabel('Quantity')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedProduct,
                        hint: const Text('Product Name',
                            style: TextStyle(color: Colors.grey)),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        decoration: _inputDecoration(),
                        items: state.products
                            .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p,
                                    style:
                                        const TextStyle(fontFamily: 'Inter'))))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedProduct = v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        decoration: _inputDecoration(hint: 'Quantity'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Unit + Cost Price
                Row(
                  children: [
                    Expanded(child: _buildFieldLabel('Unit')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFieldLabel('Cost Price')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: state.isLoadingUnits
                          ? const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.5))
                          : state.units.isEmpty
                              ? const Text(
                                  'No units available',
                                  style: TextStyle(
                                      color: Colors.redAccent, fontSize: 14),
                                )
                              : DropdownButtonFormField<String>(
                                  initialValue: selectedUnit,
                                  hint: const Text('Select Unit',
                                      style: TextStyle(color: Colors.grey)),
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      size: 20),
                                  decoration: _inputDecoration(),
                                  items: state.units
                                      .map((unit) => DropdownMenuItem<String>(
                                            value: unit.name,
                                            child: Text(
                                              unit.name,
                                              style: const TextStyle(
                                                  fontFamily: 'Inter'),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() => selectedUnit = value);
                                  },
                                ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: costPriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: _inputDecoration(hint: 'Cost Price'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Expiry Date + Batch Number
                Row(
                  children: [
                    Expanded(child: _buildFieldLabel('Expiry Date')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFieldLabel('Batch Number')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: IgnorePointer(
                        ignoring: noExpiry,
                        child: InkWell(
                          onTap: noExpiry
                              ? null
                              : () async {
                                  await showDialog(
                                    context: dialogCtx,
                                    builder: (_) => NepaliDatePickerDialog(
                                      initialDate: NepaliDateTime.now(),
                                      firstDate: NepaliDateTime(2076),
                                      lastDate: NepaliDateTime(2092),
                                      onDateSelected: (nepDate) {
                                        setDialogState(() {
                                          selectedExpiry = nepDate.toDateTime();
                                        });
                                        Navigator.pop(dialogCtx);
                                      },
                                    ),
                                  );
                                },
                          child: InputDecorator(
                            decoration: _inputDecoration(hint: 'Expiry Date'),
                            child: Text(
                              selectedExpiry != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(selectedExpiry!)
                                  : 'Select expiry date',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: noExpiry ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: batchCtrl,
                        enabled: !noExpiry,
                        decoration: _inputDecoration(hint: 'Batch Number'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // No expiry toggle
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          noExpiry = !noExpiry;
                          if (noExpiry) {
                            selectedExpiry = null;
                            batchCtrl.clear();
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: noExpiry
                              ? Colors.orange.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: noExpiry ? Colors.orange : Colors.grey),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: noExpiry ? Colors.orange : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              noExpiry ? 'Active' : 'Will not expire',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: noExpiry
                                    ? Colors.orange.shade800
                                    : Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                      final cost =
                          double.tryParse(costPriceCtrl.text.trim()) ?? 0.0;
                      final batch = batchCtrl.text.trim();

                      if (qty <= 0 ||
                          cost <= 0 ||
                          selectedProduct == null ||
                          selectedUnit == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please fill all required fields correctly')),
                        );
                        return;
                      }

                      final item = PurchaseItem(
                        product: selectedProduct!,
                        quantity: qty,
                        unit: selectedUnit,
                        costPrice: cost,
                        batchNumber: noExpiry || batch.isEmpty ? null : batch,
                        expiryDate: noExpiry ? null : selectedExpiry,
                        isComplementary: isComplementary,
                        total: qty * cost,
                      );

                      bloc.add(AddItem(item));
                      Navigator.pop(dialogCtx);
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

// Keep your existing helper functions
InputDecoration _inputDecoration({String? hint}) {
  return InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Inter'),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.orange, width: 1.5),
    ),
  );
}

Widget _buildFieldLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
  );
}
