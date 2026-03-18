// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_response.dart'; // ProductData
// import 'package:saleup_app/model/party_response.dart'; // PartyData
// import 'dart:developer' as developer;
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';

// class ExpiryItem {
//   final int id;
//   final String productName;
//   final String batchNumber;
//   final DateTime expiryDate;
//   final int quantity;
//   final double costPrice;
//   final bool isExpired;

//   ExpiryItem.fromJson(Map<String, dynamic> json)
//       : id = json['id'] as int? ?? 0,
//         productName = (json['product'] as String? ?? 'Unknown Product').trim(),
//         batchNumber = (json['batch_number'] as String? ?? 'N/A').trim(),
//         expiryDate = _parseSafeDate(json['expiry_date']),
//         quantity = json['quantity'] as int? ?? 0,
//         costPrice =
//             double.tryParse((json['cost_price'] ?? '0').toString()) ?? 0.0,
//         isExpired = json['is_expired'] as bool? ?? false;

//   static DateTime _parseSafeDate(dynamic value) {
//     if (value == null) return DateTime.now();
//     try {
//       return DateTime.parse(value.toString());
//     } catch (_) {
//       return DateTime.now();
//     }
//   }
// }

// class AddSaleScreen extends StatefulWidget {
//   const AddSaleScreen({super.key});

//   @override
//   State<AddSaleScreen> createState() => _AddSaleScreenState();
// }

// class _AddSaleScreenState extends State<AddSaleScreen> {
//   final _narrationController = TextEditingController();
//   final _discountInputController = TextEditingController(text: '0.00');
//   final _tenderController = TextEditingController();
//   final _changeAmountController = TextEditingController();
//   final _chequeNoController = TextEditingController();

//   DateTime? _chequeDate;

//   String? _selectedBillType = 'Tax Invoice';
//   String? _selectedPaymentMethod = 'Cash';
//   String _discountType = 'Amount';
//   PartyData? _selectedCustomer;

//   final List<String> _billTypes = ['Tax Invoice'];
//   final List<String> _paymentMethods = [
//     'Credit',
//     'Cash',
//     'Credit Card',
//     'Online Transaction',
//     'Cheque'
//   ];
//   List<ProductData> _products = [];
//   List<PartyData> _customers = [];
//   List<ExpiryItem> _expiries = [];

//   List<Map<String, dynamic>> _availableProducts = [];
//   final List<Map<String, dynamic>> _items = [];

//   double _subTotal = 0.0;
//   double _vat = 0.0;
//   double _discount = 0.0;
//   double _total = 0.0;
//   double _tenderAmount = 0.0;
//   double _changeAmount = 0.0;

//   double _taxPercent = 0.0;

//   bool _isLoading = true;
//   bool _isSubmitting = false;
//   String? _error;

//   bool get _isCashMode => _selectedPaymentMethod == 'Cash';

//   @override
//   void initState() {
//     super.initState();
//     _fetchAllData();
//   }

//   @override
//   void dispose() {
//     _narrationController.dispose();
//     _discountInputController.dispose();
//     _tenderController.dispose();
//     _changeAmountController.dispose();
//     _chequeNoController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchAllData() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final dio = DioClient().dio;

//       final profileRes = await dio.get('/profile/get_profile/');
//       if (profileRes.data['success'] == true &&
//           profileRes.data['data'] is List &&
//           profileRes.data['data'].isNotEmpty) {
//         final profile = profileRes.data['data'][0];
//         final taxStr = profile['tax_percent']?.toString() ?? '0';
//         _taxPercent = double.tryParse(taxStr) ?? 0.0;
//       }

//       final prodRes =
//           await dio.get('/product/get_products/?limit=5000&offset=0&search=');
//       List<dynamic> prodRaw = [];
//       if (prodRes.data is Map &&
//           prodRes.data['data'] is Map &&
//           prodRes.data['data']['results'] is List) {
//         prodRaw = prodRes.data['data']['results'];
//       }
//       _products = prodRaw.map((e) => ProductData.fromJson(e)).toList();

//       final expRes = await dio.get('/expiry/get_expiries/');
//       List<dynamic> expRaw = expRes.data['data'] ?? [];
//       _expiries = expRaw.map((e) => ExpiryItem.fromJson(e)).toList();

//       final partyRes = await dio.get('/party/get_parties/');
//       List<dynamic> partyRaw = [];
//       if (partyRes.data is Map && partyRes.data['data'] is List) {
//         partyRaw = partyRes.data['data'];
//       }
//       _customers = partyRaw
//           .map((e) => PartyData.fromJson(e))
//           .where((p) => ['customer', 'both'].contains(p.type?.toLowerCase()))
//           .toList();

//       // ── Corrected: Dropdown comes from ALL products + batch from expiry ──
//       _availableProducts = [];
//       for (var prod in _products) {
//         String batch = 'N/A';

//         // Find matching expiry entry for this product name
//         final matchingExpiry = _expiries.firstWhere(
//           (exp) =>
//               exp.productName.trim().toLowerCase() ==
//               (prod.name ?? '').trim().toLowerCase(),
//           orElse: () => ExpiryItem.fromJson({}),
//         );

//         if (matchingExpiry.batchNumber.isNotEmpty &&
//             matchingExpiry.batchNumber != 'N/A') {
//           batch = matchingExpiry.batchNumber;
//         }

//         _availableProducts.add({
//           'product': prod,
//           'batch': batch,
//         });
//       }

//       developer
//           .log('Products from /product/get_products/: ${_products.length}');
//       developer.log('Dropdown items ready: ${_availableProducts.length}');

//       setState(() => _isLoading = false);
//     } catch (e, stack) {
//       developer.log('Failed to load data', error: e, stackTrace: stack);
//       setState(() {
//         _error = 'Failed to load data: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _addItemFromSelection(Map<String, dynamic>? selected) {
//     if (selected == null) return;

//     setState(() {
//       _items.add({
//         'product': selected['product'],
//         'batch': selected['batch'],
//         'quantity': 1,
//         'rate': 0.0,
//         'total': 0.0,
//       });
//       _recalculate();
//     });
//   }

//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//       _recalculate();
//     });
//   }

//   void _updateQuantity(int index, String val) {
//     final qty = int.tryParse(val) ?? 1;
//     if (qty < 1) return;

//     setState(() {
//       final item = _items[index];
//       item['quantity'] = qty;
//       item['total'] = (item['rate'] as double) * qty;
//       _recalculate();
//     });
//   }

//   void _updateRate(int index, String val) {
//     final rate = double.tryParse(val.replaceAll(',', '')) ?? 0.0;

//     setState(() {
//       final item = _items[index];
//       item['rate'] = rate;
//       item['total'] = rate * (item['quantity'] as int);
//       _recalculate();
//     });
//   }

//   void _recalculate() {
//     _subTotal = _items.fold(0.0, (sum, i) => sum + (i['total'] as double));
//     _vat = _subTotal * (_taxPercent / 100.0);

//     final input =
//         double.tryParse(_discountInputController.text.replaceAll(',', '')) ??
//             0.0;
//     _discount = _discountType == 'Percent' ? (_subTotal * input) / 100 : input;

//     _total = _subTotal + _vat - _discount;

//     if (_isCashMode) {
//       _tenderAmount =
//           double.tryParse(_tenderController.text.replaceAll(',', '')) ?? 0.0;
//       _changeAmount = _tenderAmount - _total;
//       _changeAmountController.text = _changeAmount.toStringAsFixed(2);
//     } else {
//       _tenderAmount = _total;
//       _tenderController.text = _total.toStringAsFixed(2);
//       _changeAmount =
//           double.tryParse(_changeAmountController.text.replaceAll(',', '')) ??
//               0.0;
//     }

//     _selectedBillType = _total < 10000 ? 'Tax Invoice' : 'Tax Abbreviation';

//     setState(() {});
//   }

//   Future<void> _selectChequeDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _chequeDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) setState(() => _chequeDate = picked);
//   }

//   Future<void> _saveAndPrint() async {
//     if (_items.isEmpty || _selectedCustomer == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Add items and select customer')),
//       );
//       return;
//     }

//     FocusScope.of(context).unfocus();
//     FocusManager.instance.primaryFocus?.unfocus();

//     setState(() => _isSubmitting = true);

//     try {
//       final dio = DioClient().dio;

//       final now = DateTime.now();
//       final dateStr =
//           "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

//       final payload = {
//         "bill_type": "Invoice",
//         "customer": _selectedCustomer!.name ?? "",
//         "payment_mode": _selectedPaymentMethod ?? "Credit",
//         "description": _narrationController.text.trim(),
//         "discount": _discount.toStringAsFixed(2),
//         "tender_amount": _tenderAmount.toStringAsFixed(2),
//         "date": dateStr,
//         "sub_total": _subTotal.toStringAsFixed(2),
//         "vat": _vat.toStringAsFixed(2),
//         "total": _total.toStringAsFixed(2),
//         "balance_due": (_total - _tenderAmount)
//             .clamp(0.0, double.infinity)
//             .toStringAsFixed(2),
//         "items": _items.map((item) {
//           final prod = item['product'] as ProductData;
//           final qty = item['quantity'] as int;
//           final rate = item['rate'] as double;
//           final itemTotal = rate * qty;

//           return {
//             "product": item['batch'] ?? "N/A",
//             "quantity": qty.toString(),
//             "rate": rate.toStringAsFixed(2),
//             "total": itemTotal.toStringAsFixed(2),
//           };
//         }).toList(),
//       };

//       if (_selectedPaymentMethod == 'Cheque') {
//         payload["cheque_number"] = _chequeNoController.text.trim();
//         if (_chequeDate != null) {
//           payload["cheque_date"] =
//               "${_chequeDate!.year}-${_chequeDate!.month.toString().padLeft(2, '0')}-${_chequeDate!.day.toString().padLeft(2, '0')}";
//         }
//       }

//       developer.log('''
// ══════════════════════════════════════════════
// Sending payload to /sale/create_sale/:
// ${jsonEncode(payload)}
// ══════════════════════════════════════════════
// ''', name: 'SALE_PAYLOAD');

//       final res = await dio.post('/sale/create_sale/', data: payload);

//       developer.log('Response: ${res.statusCode} → ${res.data}',
//           name: 'SALE_RESPONSE');

//       if (res.data['success'] == true) {
//         final saleId = res.data['data']['id'] as int;

//         if (mounted) {
//           FocusScope.of(context).unfocus();
//           FocusManager.instance.primaryFocus?.unfocus();
//           await Future.delayed(const Duration(milliseconds: 100));

//           showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (BuildContext dialogContext) {
//               return AlertDialog(
//                 title: const Text('Success!'),
//                 content: Text(
//                   res.data['message'] ??
//                       'Sale created successfully! (ID: $saleId)',
//                 ),
//                 actions: [
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.download, color: Colors.white),
//                     label: const Text('Download PDF Bill',
//                         style: TextStyle(color: Colors.white)),
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange),
//                     onPressed: () async {
//                       FocusScope.of(dialogContext).unfocus();
//                       Navigator.of(dialogContext).pop();

//                       try {
//                         final pdfResponse = await dio.get(
//                           '/sale/generate_sales_bill/',
//                           queryParameters: {
//                             'sales_id': saleId,
//                             'action': 'download'
//                           },
//                           options: Options(responseType: ResponseType.bytes),
//                         );

//                         if (pdfResponse.statusCode == 200) {
//                           final bytes = pdfResponse.data as List<int>;

//                           final tempDir = await getTemporaryDirectory();
//                           final filePath =
//                               '${tempDir.path}/sale_bill_$saleId.pdf';

//                           final file = File(filePath);
//                           await file.writeAsBytes(bytes);

//                           developer.log('PDF saved: $filePath',
//                               name: 'PDF_SUCCESS');

//                           final openResult = await OpenFile.open(filePath);
//                           if (openResult.type == ResultType.done) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content:
//                                       Text('PDF opened — preview / print now')),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                   content: Text(
//                                       'Failed to open PDF: ${openResult.message}')),
//                             );
//                           }
//                         } else {
//                           throw Exception(
//                               'PDF download failed: ${pdfResponse.statusCode}');
//                         }
//                       } catch (e) {
//                         developer.log('PDF download failed: $e',
//                             name: 'PDF_ERROR');
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Failed to download PDF: $e')),
//                         );
//                       }
//                     },
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(dialogContext).pop();
//                       context.go(
//                           '/sales'); // ← CHANGE THIS TO YOUR ACTUAL SALES ROUTE
//                     },
//                     child: const Text('Go to Sales List'),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.of(dialogContext).pop(),
//                     child: const Text('Stay Here'),
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       } else {
//         throw Exception(res.data['message'] ?? 'Failed');
//       }
//     } catch (e) {
//       String msg = 'Error creating sale: $e';

//       if (e is DioException && e.response != null) {
//         msg += '\nStatus: ${e.response?.statusCode}';
//         msg += '\nBackend response:\n${jsonEncode(e.response?.data)}';
//         developer.log(msg, name: 'SALE_ERROR', error: e);
//       } else {
//         developer.log(msg, name: 'SALE_ERROR', error: e);
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(msg), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_error != null) {
//       return Scaffold(body: Center(child: Text(_error!)));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Add Sales', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               children: [
//                 Text('Stock Inventory', style: TextStyle(color: Colors.grey)),
//                 Icon(Icons.chevron_right, color: Colors.grey),
//                 Text('Sales', style: TextStyle(color: Colors.grey)),
//                 Icon(Icons.chevron_right, color: Colors.grey),
//                 Text('Add Sales',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Bill Type',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.orange),
//                           borderRadius: BorderRadius.circular(8),
//                           color: Colors.grey[50],
//                         ),
//                         child: Text(
//                           _selectedBillType ?? 'Calculating...',
//                           style: TextStyle(
//                               color: _selectedBillType == null
//                                   ? Colors.grey
//                                   : Colors.black),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Product',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.orange),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<Map<String, dynamic>>(
//                             value: null,
//                             isExpanded: true,
//                             hint: const Text('Select Product'),
//                             items: _availableProducts.map((entry) {
//                               final prod = entry['product'] as ProductData;
//                               final batch = entry['batch'] as String;
//                               final displayText =
//                                   '${prod.name ?? 'Unnamed Product'} - $batch';
//                               return DropdownMenuItem(
//                                 value: entry,
//                                 child: Text(displayText),
//                               );
//                             }).toList(),
//                             onChanged: (selected) {
//                               if (selected != null)
//                                 _addItemFromSelection(selected);
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Customer',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.orange),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<PartyData>(
//                             value: _selectedCustomer,
//                             isExpanded: true,
//                             hint: const Text('Select Customer'),
//                             items: _customers
//                                 .map((c) => DropdownMenuItem(
//                                     value: c, child: Text(c.name ?? 'Unnamed')))
//                                 .toList(),
//                             onChanged: (v) =>
//                                 setState(() => _selectedCustomer = v),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Payment Method',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.orange),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: _selectedPaymentMethod,
//                             isExpanded: true,
//                             items: _paymentMethods
//                                 .map((m) =>
//                                     DropdownMenuItem(value: m, child: Text(m)))
//                                 .toList(),
//                             onChanged: (v) {
//                               setState(() {
//                                 _selectedPaymentMethod = v;
//                                 if (v == 'Cash') {
//                                   _tenderController.text = '0.00';
//                                   _changeAmountController.text =
//                                       (-_total).toStringAsFixed(2);
//                                 } else {
//                                   _tenderController.text =
//                                       _total.toStringAsFixed(2);
//                                   _changeAmountController.text = '0.00';
//                                 }
//                                 _recalculate();
//                                 if (v != 'Cheque') {
//                                   _chequeNoController.clear();
//                                   _chequeDate = null;
//                                 }
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_selectedCustomer != null)
//               Chip(
//                 label: Text(_selectedCustomer!.name ?? 'Unnamed'),
//                 backgroundColor: Colors.orange[100],
//                 deleteIcon: const Icon(Icons.close, size: 18),
//                 onDeleted: () => setState(() => _selectedCustomer = null),
//               ),
//             if (_selectedPaymentMethod == 'Cheque') ...[
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _chequeNoController,
//                       decoration: InputDecoration(
//                         labelText: 'Cheque No',
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: InkWell(
//                       onTap: _selectChequeDate,
//                       child: InputDecorator(
//                         decoration: InputDecoration(
//                           labelText: 'Cheque Date',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: Text(
//                           _chequeDate == null
//                               ? 'Select Date'
//                               : '${_chequeDate!.day.toString().padLeft(2, '0')}-${_chequeDate!.month.toString().padLeft(2, '0')}-${_chequeDate!.year}',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             const SizedBox(height: 24),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Container(
//                 width: 720,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(8)),
//                       ),
//                       child: const Row(
//                         children: [
//                           SizedBox(width: 24),
//                           Expanded(
//                               flex: 2,
//                               child: Text('Product',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14))),
//                           Expanded(
//                               flex: 1,
//                               child: Text('Batch',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14))),
//                           Expanded(
//                               flex: 1,
//                               child: Text('Unit',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14))),
//                           Expanded(
//                               flex: 1,
//                               child: Text('Quantity',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14))),
//                           Expanded(
//                               flex: 1,
//                               child: Text('Rate',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14))),
//                           Expanded(
//                               flex: 1,
//                               child: Text('Total',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14))),
//                           SizedBox(width: 48),
//                         ],
//                       ),
//                     ),
//                     ..._items.asMap().entries.map((entry) {
//                       final idx = entry.key;
//                       final item = entry.value;
//                       final prod = item['product'] as ProductData;

//                       return Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12, horizontal: 16),
//                         decoration: BoxDecoration(
//                           border: Border(
//                               top: BorderSide(color: Colors.grey.shade200)),
//                         ),
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: 24,
//                               child: Checkbox(
//                                 value: false,
//                                 activeColor: Colors.orange,
//                                 onChanged: (bool? v) {},
//                               ),
//                             ),
//                             Expanded(flex: 2, child: Text(prod.name ?? '')),
//                             Expanded(
//                                 flex: 1, child: Text(item['batch'] ?? 'N/A')),
//                             Expanded(flex: 1, child: Text(prod.unit ?? '-')),
//                             Expanded(
//                               flex: 1,
//                               child: SizedBox(
//                                 width: 70,
//                                 child: TextFormField(
//                                   initialValue: item['quantity'].toString(),
//                                   keyboardType: TextInputType.number,
//                                   textAlign: TextAlign.center,
//                                   decoration: const InputDecoration(
//                                     border: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: Colors.blueAccent,
//                                             width: 1.5)),
//                                     contentPadding: EdgeInsets.symmetric(
//                                         vertical: 8, horizontal: 4),
//                                     isDense: true,
//                                   ),
//                                   onChanged: (v) => _updateQuantity(idx, v),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               flex: 1,
//                               child: SizedBox(
//                                 width: 80,
//                                 child: TextFormField(
//                                   initialValue: (item['rate'] as double)
//                                       .toStringAsFixed(2),
//                                   keyboardType:
//                                       const TextInputType.numberWithOptions(
//                                           decimal: true),
//                                   textAlign: TextAlign.center,
//                                   decoration: const InputDecoration(
//                                     border: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: Colors.redAccent,
//                                             width: 1.5)),
//                                     contentPadding: EdgeInsets.symmetric(
//                                         vertical: 8, horizontal: 4),
//                                     isDense: true,
//                                   ),
//                                   onChanged: (v) => _updateRate(idx, v),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(
//                                     '${(item['total'] as double?)?.toStringAsFixed(2) ?? '0.00'}')),
//                             IconButton(
//                               icon: const Icon(Icons.delete_outline,
//                                   color: Colors.red, size: 20),
//                               onPressed: () => _removeItem(idx),
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Discount',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.orange),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: _discountType,
//                             isExpanded: true,
//                             items: const [
//                               DropdownMenuItem(
//                                   value: 'Amount',
//                                   child: Text('Discount Amount')),
//                               DropdownMenuItem(
//                                   value: 'Percent', child: Text('Discount %')),
//                             ],
//                             onChanged: (value) {
//                               if (value != null) {
//                                 setState(() {
//                                   _discountType = value;
//                                   _recalculate();
//                                 });
//                               }
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       flex: 3,
//                       child: TextFormField(
//                         controller: _discountInputController,
//                         decoration: InputDecoration(
//                           labelText:
//                               _discountType == 'Percent' ? 'Percent' : 'Amount',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true),
//                         onChanged: (_) => _recalculate(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Tender Amount',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _tenderController,
//                         readOnly: !_isCashMode,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           filled: !_isCashMode,
//                           fillColor: !_isCashMode ? Colors.grey[100] : null,
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true),
//                         onChanged: (value) {
//                           if (_isCashMode) _recalculate();
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Change Amount',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _changeAmountController,
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             if (_selectedPaymentMethod == 'Cheque') ...[
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _chequeNoController,
//                       decoration: InputDecoration(
//                         labelText: 'Cheque No',
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: InkWell(
//                       onTap: _selectChequeDate,
//                       child: InputDecorator(
//                         decoration: InputDecoration(
//                           labelText: 'Cheque Date',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: Text(
//                           _chequeDate == null
//                               ? 'Select Date'
//                               : '${_chequeDate!.day.toString().padLeft(2, '0')}-${_chequeDate!.month.toString().padLeft(2, '0')}-${_chequeDate!.year}',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             const SizedBox(height: 24),
//             TextFormField(
//               controller: _narrationController,
//               decoration: InputDecoration(
//                 labelText: 'Narration',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 32),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _summaryCard('Total Item', _items.length.toString()),
//                 _summaryCard('Sub Total', _subTotal.toStringAsFixed(2)),
//                 _summaryCard('Discount', _discount.toStringAsFixed(2)),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _summaryCard('Vatable Amount', _subTotal.toStringAsFixed(2)),
//                 _summaryCard('VAT', _vat.toStringAsFixed(2)),
//                 _summaryCard('Total', _total.toStringAsFixed(2),
//                     color: Colors.orange),
//               ],
//             ),
//             const SizedBox(height: 32),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isSubmitting ? null : _saveAndPrint,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: _isSubmitting
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2),
//                         )
//                       : const Text('Print & Save',
//                           style: TextStyle(color: Colors.white)),
//                 ),
//                 OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 16),
//                     side: const BorderSide(color: Colors.grey),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Text('Void'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _summaryCard(String title, String value, {Color? color}) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: color ?? Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             Text(title,
//                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: color != null ? Colors.white : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_response.dart'; // ProductData (still used for structure)
import 'package:saleup_app/model/party_response.dart'; // PartyData
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExpiryItem {
  final int id;
  final String productName;
  final String batchNumber;
  final DateTime expiryDate;
  final int quantity;
  final double costPrice;
  final bool isExpired;

  ExpiryItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int? ?? 0,
        productName = (json['product'] as String? ?? 'Unknown Product').trim(),
        batchNumber = (json['batch_number'] as String? ?? 'N/A').trim(),
        expiryDate = _parseSafeDate(json['expiry_date']),
        quantity = json['quantity'] as int? ?? 0,
        costPrice =
            double.tryParse((json['cost_price'] ?? '0').toString()) ?? 0.0,
        isExpired = json['is_expired'] as bool? ?? false;

  static DateTime _parseSafeDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _narrationController = TextEditingController();
  final _discountInputController = TextEditingController(text: '0.00');
  final _tenderController = TextEditingController();
  final _changeAmountController = TextEditingController();
  final _chequeNoController = TextEditingController();

  DateTime? _chequeDate;

  String? _selectedBillType = 'Tax Invoice';
  String? _selectedPaymentMethod = 'Cash';
  String _discountType = 'Amount';
  PartyData? _selectedCustomer;

  final List<String> _billTypes = ['Tax Invoice'];
  final List<String> _paymentMethods = [
    'Credit',
    'Cash',
    'Credit Card',
    'Online Transaction',
    'Cheque'
  ];
  List<ExpiryItem> _expiries = [];
  List<PartyData> _customers = [];

  List<Map<String, dynamic>> _availableProducts = [];
  final List<Map<String, dynamic>> _items = [];

  double _subTotal = 0.0;
  double _vat = 0.0;
  double _discount = 0.0;
  double _total = 0.0;
  double _tenderAmount = 0.0;
  double _changeAmount = 0.0;

  double _taxPercent = 0.0;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  bool get _isCashMode => _selectedPaymentMethod == 'Cash';

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    _narrationController.dispose();
    _discountInputController.dispose();
    _tenderController.dispose();
    _changeAmountController.dispose();
    _chequeNoController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = DioClient().dio;

      // Profile (tax percent)
      final profileRes = await dio.get('/profile/get_profile/');
      if (profileRes.data['success'] == true &&
          profileRes.data['data'] is List &&
          profileRes.data['data'].isNotEmpty) {
        final profile = profileRes.data['data'][0];
        final taxStr = profile['tax_percent']?.toString() ?? '0';
        _taxPercent = double.tryParse(taxStr) ?? 0.0;
      }

      // Customers
      final partyRes = await dio.get('/party/get_parties/');
      List<dynamic> partyRaw = [];
      if (partyRes.data is Map && partyRes.data['data'] is List) {
        partyRaw = partyRes.data['data'];
      }
      _customers = partyRaw
          .map((e) => PartyData.fromJson(e))
          .where((p) => ['customer', 'both'].contains(p.type?.toLowerCase()))
          .toList();

      // ── MAIN CHANGE: Dropdown comes ONLY from /expiry/get_expiries/ ──
      final expRes = await dio.get('/expiry/get_expiries/');
      List<dynamic> expRaw = [];
      if (expRes.data is Map && expRes.data['data'] is List) {
        expRaw = expRes.data['data'];
      }
      _expiries = expRaw.map((e) => ExpiryItem.fromJson(e)).toList();

      // Build dropdown: one entry per expiry record
      _availableProducts = [];
      for (var exp in _expiries) {
        // Create a fake ProductData object for compatibility
        final fakeProd = ProductData(
          id: exp.id, // use expiry ID as fallback
          name: exp.productName,
          category: '',
          unit: '',
          location: '',
        );

        _availableProducts.add({
          'product': fakeProd,
          'batch': exp.batchNumber.isNotEmpty ? exp.batchNumber : 'N/A',
        });
      }

      developer.log(
          'Dropdown built from /expiry/get_expiries/: ${_availableProducts.length} items');

      setState(() => _isLoading = false);
    } catch (e, stack) {
      developer.log('Failed to load data', error: e, stackTrace: stack);
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  void _addItemFromSelection(Map<String, dynamic>? selected) {
    if (selected == null) return;

    setState(() {
      _items.add({
        'product': selected['product'],
        'batch': selected['batch'],
        'quantity': 1,
        'rate': 0.0,
        'total': 0.0,
      });
      _recalculate();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _recalculate();
    });
  }

  void _updateQuantity(int index, String val) {
    final qty = int.tryParse(val) ?? 1;
    if (qty < 1) return;

    setState(() {
      final item = _items[index];
      item['quantity'] = qty;
      item['total'] = (item['rate'] as double) * qty;
      _recalculate();
    });
  }

  void _updateRate(int index, String val) {
    final rate = double.tryParse(val.replaceAll(',', '')) ?? 0.0;

    setState(() {
      final item = _items[index];
      item['rate'] = rate;
      item['total'] = rate * (item['quantity'] as int);
      _recalculate();
    });
  }

  void _recalculate() {
    _subTotal = _items.fold(0.0, (sum, i) => sum + (i['total'] as double));
    _vat = _subTotal * (_taxPercent / 100.0);

    final input =
        double.tryParse(_discountInputController.text.replaceAll(',', '')) ??
            0.0;
    _discount = _discountType == 'Percent' ? (_subTotal * input) / 100 : input;

    _total = _subTotal + _vat - _discount;

    if (_isCashMode) {
      _tenderAmount =
          double.tryParse(_tenderController.text.replaceAll(',', '')) ?? 0.0;
      _changeAmount = _tenderAmount - _total;
      _changeAmountController.text = _changeAmount.toStringAsFixed(2);
    } else {
      _tenderAmount = _total;
      _tenderController.text = _total.toStringAsFixed(2);
      _changeAmount =
          double.tryParse(_changeAmountController.text.replaceAll(',', '')) ??
              0.0;
    }

    _selectedBillType = _total < 10000 ? 'Tax Invoice' : 'Tax Abbreviation';

    setState(() {});
  }

  Future<void> _selectChequeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _chequeDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _chequeDate = picked);
  }

  Future<void> _saveAndPrint() async {
    if (_items.isEmpty || _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items and select customer')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _isSubmitting = true);

    try {
      final dio = DioClient().dio;

      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final payload = {
        "bill_type": "Invoice",
        "customer": _selectedCustomer!.name ?? "",
        "payment_mode": _selectedPaymentMethod ?? "Credit",
        "description": _narrationController.text.trim(),
        "discount": _discount.toStringAsFixed(2),
        "tender_amount": _tenderAmount.toStringAsFixed(2),
        "date": dateStr,
        "sub_total": _subTotal.toStringAsFixed(2),
        "vat": _vat.toStringAsFixed(2),
        "total": _total.toStringAsFixed(2),
        "balance_due": (_total - _tenderAmount)
            .clamp(0.0, double.infinity)
            .toStringAsFixed(2),
        "items": _items.map((item) {
          final prod = item['product'] as ProductData;
          final qty = item['quantity'] as int;
          final rate = item['rate'] as double;
          final itemTotal = rate * qty;

          return {
            "product": item['batch'] ?? "N/A",
            "quantity": qty.toString(),
            "rate": rate.toStringAsFixed(2),
            "total": itemTotal.toStringAsFixed(2),
          };
        }).toList(),
      };

      if (_selectedPaymentMethod == 'Cheque') {
        payload["cheque_number"] = _chequeNoController.text.trim();
        if (_chequeDate != null) {
          payload["cheque_date"] =
              "${_chequeDate!.year}-${_chequeDate!.month.toString().padLeft(2, '0')}-${_chequeDate!.day.toString().padLeft(2, '0')}";
        }
      }

      developer.log('''
══════════════════════════════════════════════
Sending payload to /sale/create_sale/:
${jsonEncode(payload)}
══════════════════════════════════════════════
''', name: 'SALE_PAYLOAD');

      final res = await dio.post('/sale/create_sale/', data: payload);

      developer.log('Response: ${res.statusCode} → ${res.data}',
          name: 'SALE_RESPONSE');

      if (res.data['success'] == true) {
        final saleId = res.data['data']['id'] as int;

        if (mounted) {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
          await Future.delayed(const Duration(milliseconds: 100));

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Success!'),
                content: Text(
                  res.data['message'] ??
                      'Sale created successfully! (ID: $saleId)',
                ),
                actions: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Download PDF Bill',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    onPressed: () async {
                      FocusScope.of(dialogContext).unfocus();
                      Navigator.of(dialogContext).pop();

                      try {
                        final pdfResponse = await dio.get(
                          '/sale/generate_sales_bill/',
                          queryParameters: {
                            'sales_id': saleId,
                            'action': 'download'
                          },
                          options: Options(responseType: ResponseType.bytes),
                        );

                        if (pdfResponse.statusCode == 200) {
                          final bytes = pdfResponse.data as List<int>;

                          final tempDir = await getTemporaryDirectory();
                          final filePath =
                              '${tempDir.path}/sale_bill_$saleId.pdf';

                          final file = File(filePath);
                          await file.writeAsBytes(bytes);

                          developer.log('PDF saved: $filePath',
                              name: 'PDF_SUCCESS');

                          final openResult = await OpenFile.open(filePath);
                          if (openResult.type == ResultType.done) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('PDF opened — preview / print now')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to open PDF: ${openResult.message}')),
                            );
                          }
                        } else {
                          throw Exception(
                              'PDF download failed: ${pdfResponse.statusCode}');
                        }
                      } catch (e) {
                        developer.log('PDF download failed: $e',
                            name: 'PDF_ERROR');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to download PDF: $e')),
                        );
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go(
                          '/sales'); // ← CHANGE THIS TO YOUR ACTUAL SALES ROUTE NAME
                    },
                    child: const Text('Go to Sales List'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Stay Here'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        throw Exception(res.data['message'] ?? 'Failed');
      }
    } catch (e) {
      String msg = 'Error creating sale: $e';

      if (e is DioException && e.response != null) {
        msg += '\nStatus: ${e.response?.statusCode}';
        msg += '\nBackend response:\n${jsonEncode(e.response?.data)}';
        developer.log(msg, name: 'SALE_ERROR', error: e);
      } else {
        developer.log(msg, name: 'SALE_ERROR', error: e);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Sales', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('Stock Inventory', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right, color: Colors.grey),
                Text('Sales', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right, color: Colors.grey),
                Text('Add Sales',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bill Type',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: Text(
                          _selectedBillType ?? 'Calculating...',
                          style: TextStyle(
                              color: _selectedBillType == null
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Product',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 1.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: null,
                            isExpanded: true,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Select Product',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.orange),
                            menuMaxHeight: 400, // ← limits list height
                            borderRadius: BorderRadius.circular(
                                8), // ← rounded menu corners
                            items: _availableProducts.map((entry) {
                              final prod = entry['product'] as ProductData;
                              final batch = entry['batch'] as String;
                              final displayText =
                                  '${prod.name ?? 'Unnamed Product'} - $batch';
                              return DropdownMenuItem(
                                value: entry,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  child: Text(
                                    displayText,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (selected) {
                              if (selected != null)
                                _addItemFromSelection(selected);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.orange,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<PartyData>(
                            value: _selectedCustomer,
                            isExpanded: true,
                            hint: const Text('Select Customer'),
                            items: _customers
                                .map((c) => DropdownMenuItem(
                                    value: c, child: Text(c.name ?? 'Unnamed')))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCustomer = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Method',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPaymentMethod,
                            isExpanded: true,
                            items: _paymentMethods
                                .map((m) =>
                                    DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedPaymentMethod = v;
                                if (v == 'Cash') {
                                  _tenderController.text = '0.00';
                                  _changeAmountController.text =
                                      (-_total).toStringAsFixed(2);
                                } else {
                                  _tenderController.text =
                                      _total.toStringAsFixed(2);
                                  _changeAmountController.text = '0.00';
                                }
                                _recalculate();
                                if (v != 'Cheque') {
                                  _chequeNoController.clear();
                                  _chequeDate = null;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedCustomer != null)
              Chip(
                label: Text(_selectedCustomer!.name ?? 'Unnamed'),
                backgroundColor: Colors.orange[100],
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => setState(() => _selectedCustomer = null),
              ),
            if (_selectedPaymentMethod == 'Cheque') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chequeNoController,
                      decoration: InputDecoration(
                        labelText: 'Cheque No',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectChequeDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Cheque Date',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _chequeDate == null
                              ? 'Select Date'
                              : '${_chequeDate!.day.toString().padLeft(2, '0')}-${_chequeDate!.month.toString().padLeft(2, '0')}-${_chequeDate!.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Container(
            //     width: 720,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.grey.shade300),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Column(
            //       children: [
            //         Container(
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 12, horizontal: 16),
            //           decoration: BoxDecoration(
            //             color: Colors.grey[100],
            //             borderRadius: const BorderRadius.vertical(
            //                 top: Radius.circular(8)),
            //           ),
            //           child: const Row(
            //             children: [
            //               SizedBox(width: 24),
            //               Expanded(
            //                   flex: 2,
            //                   child: Text('Product',
            //                       style: TextStyle(
            //                           fontWeight: FontWeight.w600,
            //                           fontSize: 14))),
            //               Expanded(
            //                   flex: 1,
            //                   child: Text('Batch',
            //                       style: TextStyle(
            //                           fontWeight: FontWeight.w600,
            //                           fontSize: 14))),
            //               Expanded(
            //                   flex: 1,
            //                   child: Text('Unit',
            //                       style: TextStyle(
            //                           fontWeight: FontWeight.w600,
            //                           fontSize: 14))),
            //               Expanded(
            //                   flex: 1,
            //                   child: Text('Quantity',
            //                       style: TextStyle(
            //                           fontWeight: FontWeight.w600,
            //                           fontSize: 14))),
            //               Expanded(
            //                   flex: 1,
            //                   child: Text('Rate',
            //                       style: TextStyle(
            //                           fontWeight: FontWeight.w600,
            //                           fontSize: 14))),
            //               Expanded(
            //                   flex: 1,
            //                   child: Text('Total',
            //                       style: TextStyle(
            //                           fontWeight: FontWeight.w600,
            //                           fontSize: 14))),
            //               SizedBox(width: 48),
            //             ],
            //           ),
            //         ),
            //         ..._items.asMap().entries.map((entry) {
            //           final idx = entry.key;
            //           final item = entry.value;
            //           final prod = item['product'] as ProductData;

            //           return Container(
            //             padding: const EdgeInsets.symmetric(
            //                 vertical: 12, horizontal: 16),
            //             decoration: BoxDecoration(
            //               border: Border(
            //                   top: BorderSide(color: Colors.grey.shade200)),
            //             ),
            //             child: Row(
            //               children: [
            //                 SizedBox(
            //                   width: 24,
            //                   child: Checkbox(
            //                     value: false,
            //                     activeColor: Colors.orange,
            //                     onChanged: (bool? v) {},
            //                   ),
            //                 ),
            //                 Expanded(flex: 2, child: Text(prod.name ?? '')),
            //                 Expanded(
            //                     flex: 1, child: Text(item['batch'] ?? 'N/A')),
            //                 Expanded(flex: 1, child: Text(prod.unit ?? '-')),
            //                 Expanded(
            //                   flex: 1,
            //                   child: SizedBox(
            //                     width: 70,
            //                     child: TextFormField(
            //                       initialValue: item['quantity'].toString(),
            //                       keyboardType: TextInputType.number,
            //                       textAlign: TextAlign.center,
            //                       decoration: const InputDecoration(
            //                         border: OutlineInputBorder(
            //                             borderSide: BorderSide(
            //                                 color: Colors.blueAccent,
            //                                 width: 1.5)),
            //                         contentPadding: EdgeInsets.symmetric(
            //                             vertical: 8, horizontal: 4),
            //                         isDense: true,
            //                       ),
            //                       onChanged: (v) => _updateQuantity(idx, v),
            //                     ),
            //                   ),
            //                 ),
            //                 const SizedBox(width: 8),
            //                 Expanded(
            //                   flex: 1,
            //                   child: SizedBox(
            //                     width: 80,
            //                     child: TextFormField(
            //                       initialValue: (item['rate'] as double)
            //                           .toStringAsFixed(2),
            //                       keyboardType:
            //                           const TextInputType.numberWithOptions(
            //                               decimal: true),
            //                       textAlign: TextAlign.center,
            //                       decoration: const InputDecoration(
            //                         border: OutlineInputBorder(
            //                             borderSide: BorderSide(
            //                                 color: Colors.redAccent,
            //                                 width: 1.5)),
            //                         contentPadding: EdgeInsets.symmetric(
            //                             vertical: 8, horizontal: 4),
            //                         isDense: true,
            //                       ),
            //                       onChanged: (v) => _updateRate(idx, v),
            //                     ),
            //                   ),
            //                 ),
            //                 const SizedBox(width: 8),
            //                 Expanded(
            //                     flex: 1,
            //                     child: Text(
            //                         '${(item['total'] as double?)?.toStringAsFixed(2) ?? '0.00'}')),
            //                 IconButton(
            //                   icon: const Icon(Icons.delete_outline,
            //                       color: Colors.red, size: 20),
            //                   onPressed: () => _removeItem(idx),
            //                 ),
            //               ],
            //             ),
            //           );
            //         }),
            //       ],
            //     ),
            //   ),
            // ),
            _buildCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Horizontally scrollable content
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
                              SizedBox(
                                width: 36,
                                child: Checkbox(
                                  value: false,
                                  onChanged: (_) {},
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              _fixedHeaderCell('SN', width: 40),
                              _fixedHeaderCell('Product', width: 140),
                              _fixedHeaderCell('Batch', width: 100),
                              _fixedHeaderCell('Unit', width: 60),
                              _fixedHeaderCell('Quantity', width: 70),
                              _fixedHeaderCell('Rate', width: 80),
                              _fixedHeaderCell('Total', width: 90),
                              _fixedHeaderCell('Action', width: 60),
                            ],
                          ),
                        ),

                        // Dashed divider (same as purchase)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width:
                                800, // ← keep or adjust to match your total column width
                            height: 1,
                            child: Image.asset(
                              'assets/images/Line.png',
                              fit: BoxFit
                                  .fill, // stretches the image horizontally to fill width
                            ),
                          ),
                        ),

                        // Data Rows
                        if (_items.isEmpty)
                          const SizedBox(
                              height: 120, width: 800) // empty state space
                        else
                          ..._items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            final prod = item['product'] as ProductData;

                            return Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFF0F0F0)),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 36,
                                    child: Checkbox(
                                      value: false,
                                      activeColor: Colors.orange,
                                      onChanged: (_) {},
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  _fixedDataCell('${idx + 1}', width: 40),
                                  _fixedDataCell(prod.name ?? 'Unnamed',
                                      width: 140),
                                  _fixedDataCell(item['batch'] ?? 'N/A',
                                      width: 100),
                                  _fixedDataCell(prod.unit ?? '-', width: 60),
                                  SizedBox(
                                    width: 70,
                                    child: TextFormField(
                                      initialValue: item['quantity'].toString(),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blueAccent,
                                              width: 1.5),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 4),
                                        isDense: true,
                                      ),
                                      onChanged: (v) => _updateQuantity(idx, v),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: TextFormField(
                                      initialValue: (item['rate'] as double)
                                          .toStringAsFixed(2),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.redAccent,
                                              width: 1.5),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 4),
                                        isDense: true,
                                      ),
                                      onChanged: (v) => _updateRate(idx, v),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _fixedDataCell(
                                    '${(item['total'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                                    width: 90,
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red, size: 20),
                                      onPressed: () => _removeItem(idx),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
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
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Discount',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _discountType,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Amount',
                                  child: Text('Discount Amount')),
                              DropdownMenuItem(
                                  value: 'Percent', child: Text('Discount %')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _discountType = value;
                                  _recalculate();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _discountInputController,
                        decoration: InputDecoration(
                          labelText:
                              _discountType == 'Percent' ? 'Percent' : 'Amount',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tender Amount',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tenderController,
                        readOnly: !_isCashMode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: !_isCashMode,
                          fillColor: !_isCashMode ? Colors.grey[100] : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (value) {
                          if (_isCashMode) _recalculate();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Change Amount',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _changeAmountController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_selectedPaymentMethod == 'Cheque') ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chequeNoController,
                      decoration: InputDecoration(
                        labelText: 'Cheque No',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectChequeDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Cheque Date',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _chequeDate == null
                              ? 'Select Date'
                              : '${_chequeDate!.day.toString().padLeft(2, '0')}-${_chequeDate!.month.toString().padLeft(2, '0')}-${_chequeDate!.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            TextFormField(
              controller: _narrationController,
              decoration: InputDecoration(
                labelText: 'Narration',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryCard('Total Item', _items.length.toString()),
                _summaryCard('Sub Total', _subTotal.toStringAsFixed(2)),
                _summaryCard('Discount', _discount.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryCard('Vatable Amount', _subTotal.toStringAsFixed(2)),
                _summaryCard('VAT', _vat.toStringAsFixed(2)),
                _summaryCard('Total', _total.toStringAsFixed(2),
                    color: Colors.orange),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveAndPrint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Print & Save',
                          style: TextStyle(color: Colors.white)),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Void'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, {Color? color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color != null ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fixedHeaderCell(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _fixedDataCell(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
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
}
