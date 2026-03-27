// lib/screen/expiry/view/edit_expiry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/model/expiry_response.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_event.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_state.dart';

class EditExpiryScreen extends StatefulWidget {
  final ExpiryData item;

  const EditExpiryScreen({super.key, required this.item});

  @override
  State<EditExpiryScreen> createState() => _EditExpiryScreenState();
}

class _EditExpiryScreenState extends State<EditExpiryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _batchController;
  late TextEditingController _quantityController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;

  String? _selectedProduct;
  DateTime? _expiryDate;

  final List<Map<String, TextEditingController>> _bulkRows = [];

  List<String> _products = [];

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _selectedProduct = item.product;
    _expiryDate = item.expiryDate;

    _batchController = TextEditingController(text: item.batchNumber ?? '');
    _quantityController = TextEditingController(text: '${item.quantity ?? ''}');
    _costPriceController =
        TextEditingController(text: item.costPrice?.toStringAsFixed(2) ?? '');
    _sellingPriceController = TextEditingController(
        text: item.sellingPrice?.toStringAsFixed(2) ?? '');

    // Pre-fill bulk prices
    if (item.bulkPrice.isNotEmpty) {
      item.bulkPrice.forEach((qty, price) {
        _bulkRows.add({
          'qty': TextEditingController(text: qty),
          'price': TextEditingController(text: price.toString()),
        });
      });
    }
  }

  @override
  void dispose() {
    _batchController.dispose();
    _quantityController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    for (final row in _bulkRows) {
      row['qty']!.dispose();
      row['price']!.dispose();
    }
    super.dispose();
  }

  void _addBulkRow() {
    setState(() {
      _bulkRows.add({
        'qty': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  void _removeBulkRow(int index) {
    setState(() {
      _bulkRows[index]['qty']!.dispose();
      _bulkRows[index]['price']!.dispose();
      _bulkRows.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, String> bulkPrice = {};
    for (final row in _bulkRows) {
      final qty = row['qty']!.text.trim();
      final price = row['price']!.text.trim();
      if (qty.isNotEmpty && price.isNotEmpty) {
        bulkPrice[qty] = price;
      }
    }

    final payload = <String, dynamic>{
      'product': _selectedProduct ?? '',
      'batch_number': _batchController.text.trim(),
      'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,
      'cost_price': _costPriceController.text.trim(),
      'selling_prices': _sellingPriceController.text.trim(),
      'bulk_price': bulkPrice.isEmpty ? <String, String>{} : bulkPrice,
    };

    if (_expiryDate != null) {
      payload['expiry_date'] = _expiryDate!.toIso8601String().split('T')[0];
    }

    context.read<ExpiryBloc>().add(
          UpdateExpiry(id: widget.item.id!, payload: payload),
        );
  }

  @override
  Widget build(BuildContext context) {
    _products = context.read<ExpiryBloc>().state.uniqueProducts;
    if (_selectedProduct != null && !_products.contains(_selectedProduct)) {
      _products = [_selectedProduct!, ..._products];
    }

    return BlocListener<ExpiryBloc, ExpiryState>(
      listener: (context, state) {
        if (!state.isLoading && state.errorMessage == null) {
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expiry updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ExpiryBloc, ExpiryState>(
        builder: (context, state) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: SizedBox(
              width: 540,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 20, 12),
                    child: Row(
                      children: [
                        const Text(
                          'Edit Expiry',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close,
                              size: 24, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Form
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Product + Batch
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    label: 'Product Name',
                                    required: true,
                                    value: _selectedProduct,
                                    items: _products,
                                    onChanged: (v) =>
                                        setState(() => _selectedProduct = v),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Batch Number',
                                    controller: _batchController,
                                    required: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 2: Expiry Date + Quantity
                            Row(
                              children: [
                                Expanded(child: _buildDateField()),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Quantity',
                                    controller: _quantityController,
                                    required: true,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 3: Cost Price + Selling Price
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Cost Price',
                                    controller: _costPriceController,
                                    required: true,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Selling Price',
                                    controller: _sellingPriceController,
                                    required: true,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Bulk Prices
                            const Text(
                              'Bulk Prices',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 8),

                            const Row(
                              children: [
                                Expanded(
                                  child: Text('Quantity',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666))),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text('Price',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666))),
                                ),
                                SizedBox(width: 40),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Bulk Rows
                            ..._bulkRows.asMap().entries.map((entry) {
                              final i = entry.key;
                              final row = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildRawTextField(
                                        controller: row['qty']!,
                                        hint: '100',
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildRawTextField(
                                        controller: row['price']!,
                                        hint: '1350',
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _removeBulkRow(i),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEBEB),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.remove,
                                            size: 18, color: Color(0xFFD32F2F)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Add Button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: _addBulkRow,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add,
                                      size: 20, color: Color(0xFF555555)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: state.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== Reusable Widgets ====================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333)),
            children: required
                ? const [
                    TextSpan(text: ' *', style: TextStyle(color: Colors.red))
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 13),
          decoration: _inputDecoration(),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildRawTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: _inputDecoration(hint: hint),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required bool required,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333)),
            children: required
                ? const [
                    TextSpan(text: ' *', style: TextStyle(color: Colors.red))
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          decoration: _inputDecoration(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          items: items
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: onChanged,
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expiry Date',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                Text(
                  _expiryDate != null
                      ? _expiryDate!.toIso8601String().split('T')[0]
                      : 'Select Date',
                  style: TextStyle(
                    fontSize: 13,
                    color: _expiryDate != null
                        ? const Color(0xFF333333)
                        : Colors.grey.shade400,
                  ),
                ),
                const Spacer(),
                if (_expiryDate != null)
                  GestureDetector(
                    onTap: () => setState(() => _expiryDate = null),
                    child: Icon(Icons.close,
                        size: 18, color: Colors.grey.shade400),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF6B35)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
