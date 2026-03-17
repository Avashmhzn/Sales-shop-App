// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_response.dart'; // ProductData
// import 'package:saleup_app/model/party_response.dart'; // PartyData

// class AddSaleScreen extends StatefulWidget {
//   const AddSaleScreen({super.key});

//   @override
//   State<AddSaleScreen> createState() => _AddSaleScreenState();
// }

// class _AddSaleScreenState extends State<AddSaleScreen> {
//   // Controllers
//   final _narrationController = TextEditingController();
//   final _discountController = TextEditingController(text: '0.00');
//   final _tenderController = TextEditingController(text: '0.00');

//   // Selected values
//   String? _selectedBillType = 'Tax Invoice';
//   ProductData? _selectedProduct;
//   PartyData? _selectedCustomer;
//   String? _selectedPaymentMethod = 'Cash';

//   // API-fetched lists
//   final List<String> _billTypes = ['Tax Invoice', 'Regular Invoice'];
//   final List<String> _paymentMethods = [
//     'Cash',
//     'Bank',
//     'Credit',
//     'Mobile Banking'
//   ];
//   List<ProductData> _products = [];
//   List<PartyData> _customers = [];

//   // Cart items: rate is now user-entered
//   final List<Map<String, dynamic>> _items = [];

//   // Totals
//   double _subTotal = 0.0;
//   double _vat = 0.0;
//   double _discount = 0.0;
//   double _total = 0.0;
//   double _tenderAmount = 0.0;
//   double _changeAmount = 0.0;

//   bool _isLoading = true;
//   bool _isSubmitting = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAllData();

//     _discountController.addListener(_recalculate);
//     _tenderController.addListener(_recalculate);
//   }

//   Future<void> _fetchAllData() async {
//     setState(() => _isLoading = true);

//     try {
//       final dio = DioClient().dio;

//       // 1. Products
//       final prodRes =
//           await dio.get('/product/get_products/?limit=5000&offset=0&search=');
//       final prodData = prodRes.data['data'] as List<dynamic>? ?? [];
//       _products = prodData.map((e) => ProductData.fromJson(e)).toList();

//       // 2. Customers (filter for customer or both)
//       final partyRes = await dio.get('/party/get_parties/');
//       final partyData = partyRes.data['data'] as List<dynamic>? ?? [];
//       _customers = partyData
//           .map((e) => PartyData.fromJson(e))
//           .where((p) => ['customer', 'both'].contains(p.type?.toLowerCase()))
//           .toList();

//       setState(() => _isLoading = false);
//     } catch (e, stack) {
//       debugPrint('Fetch error: $e\n$stack');
//       setState(() {
//         _error = 'Failed to load data: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _addItem() {
//     if (_selectedProduct == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a product')),
//       );
//       return;
//     }

//     setState(() {
//       _items.add({
//         'product': _selectedProduct,
//         'quantity': 1,
//         'rate': 0.0, // user will enter rate
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
//     _vat = _subTotal * 0.13; // 13% VAT — change if your rate differs
//     _discount =
//         double.tryParse(_discountController.text.replaceAll(',', '')) ?? 0.0;
//     _total = _subTotal + _vat - _discount;
//     _tenderAmount =
//         double.tryParse(_tenderController.text.replaceAll(',', '')) ?? 0.0;
//     _changeAmount = _tenderAmount - _total;

//     setState(() {});
//   }

//   Future<void> _saveAndPrint() async {
//     if (_items.isEmpty || _selectedCustomer == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Add items and select customer')),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       final dio = DioClient().dio;

//       final payload = {
//         "bill_type": _selectedBillType ?? "Invoice",
//         "customer": _selectedCustomer!.name ?? "",
//         "payment_mode": _selectedPaymentMethod ?? "Credit",
//         "description": _narrationController.text.trim(),
//         "discount": _discount,
//         "tender_amount": _tenderAmount,
//         "items": _items.map((item) {
//           final prod = item['product'] as ProductData;
//           return {
//             "product": prod.id, // integer ID
//             "quantity": item['quantity'] as int,
//             "rate": item['rate'] as double,
//           };
//         }).toList(),
//       };

//       debugPrint('Sending payload: $payload');

//       final res = await dio.post('/sale/create_sale/', data: payload);

//       if (res.data['success'] == true) {
//         final saleId = res.data['data']['id'] as int;

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text(res.data['message'] ?? 'Sale created successfully')),
//         );

//         // Generate bill
//         await dio.get(
//           '/sale/generate_sales_bill/?sales_id=$saleId&action=download',
//         );

//         if (mounted) Navigator.pop(context);
//       } else {
//         throw Exception(res.data['message'] ?? 'Failed to create sale');
//       }
//     } catch (e, stack) {
//       debugPrint('Submit error: $e\n$stack');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//       );
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
//         title: const Text('Add Sales'),
//         backgroundColor: Colors.blue,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Breadcrumb
//             const Text(
//               'Stock Inventory > Sales > Add Sales',
//               style: TextStyle(color: Colors.grey, fontSize: 13),
//             ),
//             const SizedBox(height: 20),

//             // Top row: Bill Type, Product, Customer, Payment Method
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     initialValue: _selectedBillType,
//                     decoration: const InputDecoration(
//                       labelText: 'Bill Type',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: _billTypes
//                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                     onChanged: (v) => setState(() => _selectedBillType = v),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<ProductData>(
//                     initialValue: _selectedProduct,
//                     decoration: const InputDecoration(
//                       labelText: 'Product',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: _products
//                         .map((p) => DropdownMenuItem(
//                             value: p, child: Text(p.name ?? 'Unnamed')))
//                         .toList(),
//                     onChanged: (v) => setState(() => _selectedProduct = v),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<PartyData>(
//                     initialValue: _selectedCustomer,
//                     decoration: const InputDecoration(
//                       labelText: 'Customer',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: _customers
//                         .map((c) => DropdownMenuItem(
//                             value: c, child: Text(c.name ?? 'Unnamed')))
//                         .toList(),
//                     onChanged: (v) => setState(() => _selectedCustomer = v),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     initialValue: _selectedPaymentMethod,
//                     decoration: const InputDecoration(
//                       labelText: 'Payment Method',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: _paymentMethods
//                         .map((m) => DropdownMenuItem(value: m, child: Text(m)))
//                         .toList(),
//                     onChanged: (v) =>
//                         setState(() => _selectedPaymentMethod = v),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Items Table - Rate is editable
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade400),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   // Header
//                   Container(
//                     color: Colors.grey[100],
//                     padding: const EdgeInsets.all(12),
//                     child: const Row(
//                       children: [
//                         Expanded(
//                             flex: 2,
//                             child: Text('Product',
//                                 style: TextStyle(fontWeight: FontWeight.w600))),
//                         Expanded(
//                             child: Text('Unit',
//                                 style: TextStyle(fontWeight: FontWeight.w600))),
//                         Expanded(
//                             child: Text('Qty',
//                                 style: TextStyle(fontWeight: FontWeight.w600))),
//                         Expanded(
//                             child: Text('Rate',
//                                 style: TextStyle(fontWeight: FontWeight.w600))),
//                         Expanded(
//                             child: Text('Total',
//                                 style: TextStyle(fontWeight: FontWeight.w600))),
//                         SizedBox(width: 48),
//                       ],
//                     ),
//                   ),
//                   // Rows
//                   ..._items.asMap().entries.map((entry) {
//                     final idx = entry.key;
//                     final item = entry.value;
//                     final prod = item['product'] as ProductData;
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8, horizontal: 16),
//                       child: Row(
//                         children: [
//                           Expanded(flex: 2, child: Text(prod.name ?? '')),
//                           Expanded(child: Text(prod.unit ?? '-')),
//                           Expanded(
//                             child: SizedBox(
//                               width: 80,
//                               child: TextFormField(
//                                 initialValue: '1',
//                                 keyboardType: TextInputType.number,
//                                 textAlign: TextAlign.center,
//                                 decoration: const InputDecoration(
//                                   border: OutlineInputBorder(),
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8),
//                                 ),
//                                 onChanged: (v) => _updateQuantity(idx, v),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: SizedBox(
//                               width: 100,
//                               child: TextFormField(
//                                 initialValue:
//                                     (item['rate'] as double).toStringAsFixed(2),
//                                 keyboardType:
//                                     const TextInputType.numberWithOptions(
//                                         decimal: true),
//                                 textAlign: TextAlign.center,
//                                 decoration: const InputDecoration(
//                                   border: OutlineInputBorder(),
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8),
//                                 ),
//                                 onChanged: (v) => _updateRate(idx, v),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               child: Text(
//                                   '${item['total']?.toStringAsFixed(2) ?? '0.00'}')),
//                           IconButton(
//                             icon: const Icon(Icons.delete_outline,
//                                 color: Colors.red),
//                             onPressed: () => _removeItem(idx),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Add Item Button
//             Align(
//               alignment: Alignment.centerRight,
//               child: ElevatedButton.icon(
//                 onPressed: _addItem,
//                 icon: const Icon(Icons.add, size: 18),
//                 label: const Text('Add Item'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Discount & Tender
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _discountController,
//                     decoration: const InputDecoration(
//                       labelText: 'Discount Amount',
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType:
//                         const TextInputType.numberWithOptions(decimal: true),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     controller: _tenderController,
//                     decoration: const InputDecoration(
//                       labelText: 'Tender Amount',
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType:
//                         const TextInputType.numberWithOptions(decimal: true),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Totals Section (orange box)
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.orange[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.orange.shade200),
//               ),
//               child: Column(
//                 children: [
//                   _totalLine('Total Items', _items.length.toString()),
//                   _totalLine('Sub Total', _subTotal.toStringAsFixed(2)),
//                   _totalLine('Discount', _discount.toStringAsFixed(2)),
//                   _totalLine('VAT (13%)', _vat.toStringAsFixed(2)),
//                   const Divider(height: 24),
//                   _totalLine('Total Amount', _total.toStringAsFixed(2),
//                       bold: true),
//                   _totalLine(
//                       'Change Amount',
//                       _changeAmount < 0
//                           ? '0.00'
//                           : _changeAmount.toStringAsFixed(2)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Narration
//             TextFormField(
//               controller: _narrationController,
//               decoration: const InputDecoration(
//                 labelText: 'Narration',
//                 border: OutlineInputBorder(),
//                 alignLabelWithHint: true,
//               ),
//               maxLines: 3,
//             ),

//             const SizedBox(height: 40),

//             // Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.print),
//                   label: const Text('Print & Save'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 32, vertical: 16),
//                     minimumSize: const Size(160, 56),
//                   ),
//                   onPressed: _isSubmitting ? null : _saveAndPrint,
//                 ),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.cancel),
//                   label: const Text('Void'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 32, vertical: 16),
//                     minimumSize: const Size(160, 56),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _totalLine(String label, String value, {bool bold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: bold ? FontWeight.w600 : FontWeight.normal),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
//               color: bold ? Colors.orange[900] : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _narrationController.dispose();
//     _discountController.dispose();
//     _tenderController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_response.dart'; // ProductData
import 'package:saleup_app/model/party_response.dart'; // PartyData

class ExpiryItem {
  final int id;
  final String productName;
  final String batchNumber;
  final DateTime expiryDate;
  final int quantity;
  final double costPrice;
  final bool isExpired;

  ExpiryItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        productName = json['product'],
        batchNumber = json['batch_number'],
        expiryDate = DateTime.parse(json['expiry_date']),
        quantity = json['quantity'],
        costPrice = double.tryParse(json['cost_price'].toString()) ?? 0.0,
        isExpired = json['is_expired'] ?? false;
}

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  // Controllers
  final _narrationController = TextEditingController();
  final _discountInputController = TextEditingController(text: '0.00');
  final _tenderController = TextEditingController();
  final _changeAmountController = TextEditingController();
  final _chequeNoController = TextEditingController();

  DateTime? _chequeDate;

  // Selected values
  String? _selectedBillType = 'Tax Invoice';
  String? _selectedPaymentMethod = 'Cash';
  String _discountType = 'Amount'; // 'Amount' or 'Percent'
  PartyData? _selectedCustomer;

  // API data
  final List<String> _billTypes = ['Tax Invoice'];
  final List<String> _paymentMethods = [
    'Credit',
    'Cash',
    'Credit Card',
    'Online Transaction',
    'Cheque'
  ];
  List<ProductData> _products = [];
  List<PartyData> _customers = [];
  List<ExpiryItem> _expiries = [];
  List<Map<String, dynamic>> _availableProducts = [];

  // Cart items
  final List<Map<String, dynamic>> _items = [];

  // Totals
  double _subTotal = 0.0;
  double _vat = 0.0;
  double _discount = 0.0;
  double _total = 0.0;
  double _tenderAmount = 0.0;
  double _changeAmount = 0.0;

  // Tax percent from profile (no default, set from API)
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

      // Fetch profile to get tax_percent (no default)
      final profileRes = await dio.get('/profile/get_profile/');
      if (profileRes.data['success'] == true &&
          profileRes.data['data'] is List &&
          profileRes.data['data'].isNotEmpty) {
        final profile = profileRes.data['data'][0];
        final taxStr = profile['tax_percent']?.toString() ?? '0';
        _taxPercent = double.tryParse(taxStr) ?? 0.0;
      } else {
        _taxPercent = 0.0; // No static default, use 0 if not found
      }

      print('Fetched tax percent: $_taxPercent'); // Log for debugging

      // Fetch products
      final prodRes =
          await dio.get('/product/get_products/?limit=5000&offset=0&search=');
      List<dynamic> prodRaw = [];
      if (prodRes.data is Map &&
          prodRes.data['data'] is Map &&
          prodRes.data['data']['results'] is List) {
        prodRaw = prodRes.data['data']['results'];
      }
      _products = prodRaw.map((e) => ProductData.fromJson(e)).toList();

      // Fetch expiries
      final expRes = await dio.get('/expiry/get_expiries/');
      List<dynamic> expRaw = expRes.data['data'] ?? [];
      _expiries = expRaw.map((e) => ExpiryItem.fromJson(e)).toList();

      // Fetch customers
      final partyRes = await dio.get('/party/get_parties/');
      List<dynamic> partyRaw = [];
      if (partyRes.data is Map && partyRes.data['data'] is List) {
        partyRaw = partyRes.data['data'];
      }
      _customers = partyRaw
          .map((e) => PartyData.fromJson(e))
          .where((p) => ['customer', 'both'].contains(p.type?.toLowerCase()))
          .toList();

      // Available products
      _availableProducts = [];
      for (var exp in _expiries) {
        if (!exp.isExpired && exp.quantity > 0) {
          final prod = _products.firstWhere(
            (p) => p.name.toLowerCase() == exp.productName.toLowerCase(),
            orElse: () => ProductData(
                id: 0,
                name: exp.productName,
                category: '',
                unit: '',
                location: ''),
          );
          if (prod.id != 0) {
            _availableProducts.add({'product': prod, 'batch': exp.batchNumber});
          }
        }
      }

      if (_availableProducts.isEmpty && _products.isNotEmpty) {
        _availableProducts =
            _products.map((p) => {'product': p, 'batch': 'N/A'}).toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
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

    // VAT from fetched tax_percent
    _vat = _subTotal * (_taxPercent / 100.0);

    final input =
        double.tryParse(_discountInputController.text.replaceAll(',', '')) ??
            0.0;
    _discount = _discountType == 'Percent' ? (_subTotal * input) / 100 : input;

    _total = _subTotal + _vat - _discount;

    // Payment mode logic
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

    setState(() => _isSubmitting = true);

    try {
      final dio = DioClient().dio;

      // Fix: Send date in full ISO 8601 format with timezone (matches your backend example)
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final offsetSign = offset.isNegative ? '-' : '+';
      final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
      final offsetMinutes =
          (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T"
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}"
          "$offsetSign$offsetHours:$offsetMinutes";

      final payload = {
        "bill_type": _selectedBillType ?? "Invoice",
        "customer": _selectedCustomer!.name ?? "",
        "payment_mode": _selectedPaymentMethod ?? "Credit",
        "description": _narrationController.text.trim(),
        "discount": _discount,
        "tender_amount": _tenderAmount,
        "date": dateStr, // ← This fixes "exception invalid date"
        "items": _items.map((item) {
          final prod = item['product'] as ProductData;
          return {
            "product": prod.id,
            "quantity": item['quantity'],
            "rate": item['rate'],
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

      print('Sending payload: $payload');

      final res = await dio.post('/sale/create_sale/', data: payload);

      if (res.data['success'] == true) {
        final saleId = res.data['data']['id'] as int;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.data['message'] ?? 'Sale created')),
        );

        await dio
            .get('/sale/generate_sales_bill/?sales_id=$saleId&action=download');

        if (mounted) Navigator.pop(context);
      } else {
        throw Exception(res.data['message'] ?? 'Failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
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
            // Breadcrumb
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

            // Bill Type + Product
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Product',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: null,
                            isExpanded: true,
                            hint: const Text('Select Product'),
                            items: _availableProducts.map((entry) {
                              final prod = entry['product'] as ProductData;
                              final batch = entry['batch'] as String;
                              return DropdownMenuItem(
                                  value: entry,
                                  child: Text('${prod.name} - $batch'));
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

            // Customer + Payment Method
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
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
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
                            horizontal: 12, vertical: 8),
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

                                // Reset logic as per your last requirement
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

            // Cheque fields
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
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _chequeDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null)
                          setState(() => _chequeDate = picked);
                      },
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

            // Table (unchanged - your original table)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: 720,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Product',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14))),
                          Expanded(
                              flex: 1,
                              child: Text('Product Code',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14))),
                          Expanded(
                              flex: 1,
                              child: Text('Unit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14))),
                          Expanded(
                              flex: 1,
                              child: Text('Quantity',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14))),
                          Expanded(
                              flex: 1,
                              child: Text('Rate',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14))),
                          Expanded(
                              flex: 1,
                              child: Text('Total',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14))),
                          SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Image.asset('assets/images/Line.png',
                        width: double.infinity, height: 2, fit: BoxFit.fill),
                    ..._items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final prod = item['product'] as ProductData;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: Colors.grey.shade200))),
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Text(prod.name ?? '')),
                            Expanded(
                                flex: 1, child: Text(item['batch'] ?? 'N/A')),
                            Expanded(child: Text(prod.unit ?? '-')),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                width: 70,
                                child: TextFormField(
                                  initialValue: item['quantity'].toString(),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueAccent,
                                            width: 1.5)),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    isDense: true,
                                  ),
                                  onChanged: (v) => _updateQuantity(idx, v),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
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
                                            width: 1.5)),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    isDense: true,
                                  ),
                                  onChanged: (v) => _updateRate(idx, v),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    '${item['total']?.toStringAsFixed(2) ?? '0.00'}')),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              onPressed: () => _removeItem(idx),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Discount selector + input
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

            // Tender + Change Amount
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
                          if (_isCashMode) {
                            _recalculate(); // live update change
                          }
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
                        readOnly: _isCashMode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: _isCashMode,
                          fillColor: _isCashMode ? Colors.grey[100] : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (val) {
                          if (!_isCashMode) {
                            final change =
                                double.tryParse(val.replaceAll(',', '')) ?? 0.0;
                            setState(() => _changeAmount = change);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Cheque fields
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
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _chequeDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null)
                          setState(() => _chequeDate = picked);
                      },
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

            // Narration
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

            // Summary cards
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
                _summaryCard('Total Item', _total.toStringAsFixed(2),
                    color: Colors.orange),
              ],
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveAndPrint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Print & Save',
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
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color != null ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }
}
