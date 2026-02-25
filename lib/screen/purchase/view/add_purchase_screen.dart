// import 'package:flutter/material.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/purchase_response.dart'; // if you want to prefill

// class AddPurchaseScreen extends StatefulWidget {
//   final PurchaseData? purchase; // for edit mode

//   const AddPurchaseScreen({super.key, this.purchase});

//   @override
//   State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
// }

// class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
//   final _formKey = GlobalKey<FormState>();

//   late TextEditingController _invoiceCtrl;
//   late TextEditingController _subTotalCtrl;
//   late TextEditingController _vatCtrl;
//   late TextEditingController _totalCtrl;

//   String? _selectedParty;
//   String? _selectedBillType = 'Credit';

//   // Very simple item list (you should improve this later)
//   final List<Map<String, dynamic>> _items = [];

//   @override
//   void initState() {
//     super.initState();
//     _invoiceCtrl =
//         TextEditingController(text: widget.purchase?.invoiceNumber ?? '');
//     _subTotalCtrl = TextEditingController(
//         text: widget.purchase?.subTotal?.toString() ?? '');
//     _vatCtrl =
//         TextEditingController(text: widget.purchase?.vat?.toString() ?? '');
//     _totalCtrl =
//         TextEditingController(text: widget.purchase?.total?.toString() ?? '');

//     _selectedParty = widget.purchase?.party;
//     _selectedBillType = widget.purchase?.billType ?? 'Credit';

//     // TODO: prefill items if editing
//   }

//   @override
//   void dispose() {
//     _invoiceCtrl.dispose();
//     _subTotalCtrl.dispose();
//     _vatCtrl.dispose();
//     _totalCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     final payload = {
//       "invoice_number": _invoiceCtrl.text.trim(),
//       "bill_type": _selectedBillType,
//       "party": _selectedParty,
//       "sub_total": double.tryParse(_subTotalCtrl.text.trim()) ?? 0,
//       "vat": double.tryParse(_vatCtrl.text.trim()) ?? 0,
//       "total": double.tryParse(_totalCtrl.text.trim()) ?? 0,
//       "items": _items.isNotEmpty
//           ? _items
//           : [
//               {
//                 "product": "Sample Item",
//                 "quantity": 1,
//                 "unit": "PCS",
//                 "cost_price": "1000.00",
//               }
//             ],
//     };

//     try {
//       final dio = DioClient().dio;
//       final url = widget.purchase != null
//           ? '/purchase/update/${widget.purchase!.id}/'
//           : '/purchase/create_purchase/';

//       final method = widget.purchase != null ? dio.put : dio.post;

//       final res = await method(url, data: payload);

//       if (res.data['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(widget.purchase != null
//                 ? "Purchase updated!"
//                 : "Purchase created!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context, true);
//       } else {
//         throw Exception(res.data['message'] ?? 'Failed');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.purchase != null ? "Edit Purchase" : "New Purchase"),
//         backgroundColor: Colors.orange,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               DropdownButtonFormField<String>(
//                 initialValue: _selectedParty,
//                 decoration: const InputDecoration(
//                   labelText: "Supplier / Party",
//                   border: OutlineInputBorder(),
//                 ),
//                 items: const [
//                   DropdownMenuItem(
//                       value: "Supplier A", child: Text("Supplier A")),
//                   DropdownMenuItem(
//                       value: "Supplier B", child: Text("Supplier B")),
//                   DropdownMenuItem(value: "Admin", child: Text("Admin")),
//                 ],
//                 onChanged: (v) => setState(() => _selectedParty = v),
//                 validator: (v) => v == null ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),

//               TextFormField(
//                 controller: _invoiceCtrl,
//                 decoration: const InputDecoration(
//                   labelText: "Invoice Number",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),

//               DropdownButtonFormField<String>(
//                 initialValue: _selectedBillType,
//                 decoration: const InputDecoration(
//                   labelText: "Bill Type",
//                   border: OutlineInputBorder(),
//                 ),
//                 items: const [
//                   DropdownMenuItem(value: "Cash", child: Text("Cash")),
//                   DropdownMenuItem(value: "Credit", child: Text("Credit")),
//                   DropdownMenuItem(value: "Bank", child: Text("Bank")),
//                 ],
//                 onChanged: (v) => setState(() => _selectedBillType = v),
//               ),
//               const SizedBox(height: 24),

//               const Text("Items",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),

//               // TODO: real item adder UI (for now placeholder)
//               if (_items.isEmpty)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Center(
//                       child: Text("No items added yet",
//                           style: TextStyle(color: Colors.grey))),
//                 ),

//               const SizedBox(height: 24),

//               TextFormField(
//                 controller: _subTotalCtrl,
//                 decoration: const InputDecoration(
//                     labelText: "Sub Total", border: OutlineInputBorder()),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _vatCtrl,
//                 decoration: const InputDecoration(
//                     labelText: "VAT", border: OutlineInputBorder()),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _totalCtrl,
//                 decoration: const InputDecoration(
//                     labelText: "Grand Total", border: OutlineInputBorder()),
//                 keyboardType: TextInputType.number,
//               ),

//               const SizedBox(height: 40),

//               SizedBox(
//                 height: 54,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: _submit,
//                   child: Text(
//                     widget.purchase != null
//                         ? "UPDATE PURCHASE"
//                         : "CREATE PURCHASE",
//                     style: const TextStyle(fontSize: 16, color: Colors.white),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/model/purchase_response.dart'; // Adjust import to your model

class AddPurchaseScreen extends StatefulWidget {
  final PurchaseData? purchase; // nullable → for both create & edit

  const AddPurchaseScreen({
    super.key,
    this.purchase,
  });

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _invoiceController;
  late TextEditingController _discountController;
  late TextEditingController _dateController;

  String? _selectedParty;
  String? _selectedPaymentMode = 'Cash';

  // List of added products
  final List<Map<String, dynamic>> _items = [];

  // Summary fields (calculated)
  double subTotal = 0.0;
  double discount = 0.0;
  double taxableAmount = 0.0;
  double vat = 0.0;
  double grandTotal = 0.0;

  @override
  void initState() {
    super.initState();

    _invoiceController = TextEditingController();
    _discountController = TextEditingController();
    _dateController = TextEditingController();

    if (widget.purchase != null) {
      // Edit mode - prefill
      _invoiceController.text = widget.purchase!.invoiceNumber ?? '';
      _selectedParty = widget.purchase!.party;
      _selectedPaymentMode = widget.purchase!.billType ?? 'Cash';
      _discountController.text = widget.purchase!.discount?.toString() ?? '0';

      // if (widget.purchase!.date != null) {
      //   _dateController.text = DateFormat('yyyy-MM-dd').format(
      //     DateTime.parse(widget.purchase!.date!),
      //   );
      // }

      // TODO: Load items if your model has purchaseItems list
      // Example:
      // if (widget.purchase!.purchaseItems != null) {
      //   for (var item in widget.purchase!.purchaseItems!) {
      //     _items.add({
      //       'sn': _items.length + 1,
      //       'product': item.product ?? 'Unknown',
      //       'qty': item.quantity ?? 0,
      //       'batch': item.batchNumber ?? '',
      //       'total': (item.quantity ?? 0) * (item.costPrice ?? 0),
      //     });
      //   }
      // }

      _updateSummary();
    } else {
      // Create mode
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    _discountController.addListener(_updateSummary);
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _discountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _updateSummary() {
    setState(() {
      subTotal = _items.fold<double>(
        0.0,
        (sum, item) => sum + (item['total'] as double? ?? 0.0),
      );

      discount = double.tryParse(_discountController.text.trim()) ?? 0.0;
      if (discount < 0) discount = 0;

      taxableAmount = subTotal - discount;
      vat = taxableAmount *
          0.13; // ← change VAT rate as per your country/business
      grandTotal = taxableAmount + vat;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _showAddProductDialog() {
    final productCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final batchCtrl = TextEditingController();
    final rateCtrl = TextEditingController(); // cost price per unit

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: batchCtrl,
                decoration: const InputDecoration(labelText: 'Batch Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rateCtrl,
                decoration:
                    const InputDecoration(labelText: 'Rate / Unit Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final qty = double.tryParse(qtyCtrl.text) ?? 1;
              final rate = double.tryParse(rateCtrl.text) ?? 0.0;
              final total = qty * rate;

              setState(() {
                _items.add({
                  'sn': _items.length + 1,
                  'product': productCtrl.text.trim().isNotEmpty
                      ? productCtrl.text.trim()
                      : 'Unnamed Product',
                  'qty': qty,
                  'batch': batchCtrl.text.trim(),
                  'rate': rate,
                  'total': total,
                });
              });

              _updateSummary();
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      for (int i = 0; i < _items.length; i++) {
        _items[i]['sn'] = i + 1;
      }
    });
    _updateSummary();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product')),
      );
      return;
    }

    // Prepare data to send (adapt to your API structure)
    final payload = {
      'invoice_number': _invoiceController.text.trim(),
      'party': _selectedParty,
      'bill_type': _selectedPaymentMode,
      'date': _dateController.text,
      'discount_amount': discount,
      'sub_total': subTotal,
      'vat': vat,
      'grand_total': grandTotal,
      'items': _items.map((item) {
        return {
          'product': item['product'],
          'quantity': item['qty'],
          'batch_number': item['batch'],
          'rate': item['rate'],
          'total': item['total'],
        };
      }).toList(),
    };

    // TODO: Call your API here
    // Example using bloc / dio:
    // context.read<PurchaseBloc>().add(CreateOrUpdatePurchase(payload, isEdit: widget.purchase != null));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.purchase != null
            ? 'Purchase updated successfully'
            : 'Purchase added successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true); // signal success to previous screen
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.purchase != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Purchase' : 'Add Purchase'),
        backgroundColor: Colors.orange,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Invoice + Party
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _invoiceController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v?.trim().isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedParty,
                    decoration: const InputDecoration(
                      labelText: 'Party',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Supplier A', child: Text('Supplier A')),
                      DropdownMenuItem(
                          value: 'Supplier B', child: Text('Supplier B')),
                      DropdownMenuItem(
                          value: 'Wholesaler X', child: Text('Wholesaler X')),
                      // Add real parties from API later
                    ],
                    onChanged: (v) => setState(() => _selectedParty = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Discount + Payment + Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPaymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                      DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                    ],
                    onChanged: (v) => setState(() => _selectedPaymentMode = v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add Product Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Product',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _showAddProductDialog,
              ),
            ),
            const SizedBox(height: 16),

            // Items Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No products added yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor:
                            WidgetStatePropertyAll(Colors.orange.shade50),
                        columns: const [
                          DataColumn(label: Text('SN')),
                          DataColumn(label: Text('Product')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Batch Number')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: _items.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${item['sn']}')),
                            DataCell(Text(item['product'].toString())),
                            DataCell(Text(item['qty'].toString())),
                            DataCell(Text(item['batch'].toString())),
                            DataCell(
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(idx),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Summary Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _SummaryRow('Sub Total', subTotal),
                  const Divider(),
                  _SummaryRow('Discount', discount, isNegative: true),
                  const Divider(),
                  _SummaryRow('Taxable Amount', taxableAmount),
                  const Divider(),
                  _SummaryRow('VAT', vat),
                  const Divider(height: 32, thickness: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Grand Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Rs ${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Final Action Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: Text(
                  isEdit ? 'UPDATE PURCHASE' : 'ADD PURCHASE',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SummaryRow(String label, double value, {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          isNegative
              ? '-${value.toStringAsFixed(2)}'
              : value.toStringAsFixed(2),
          style: TextStyle(
            color: isNegative ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}
