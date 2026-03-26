import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_event.dart';

class AddExpiryScreen extends StatefulWidget {
  const AddExpiryScreen({super.key});

  @override
  State<AddExpiryScreen> createState() => _AddExpiryScreenState();
}

class _AddExpiryScreenState extends State<AddExpiryScreen> {
  String? _selectedProduct;
  List<String> _products = [];
  bool _loadingProducts = true;

  final _batchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  DateTime? _expiryDate;
  bool _willNotExpire = false;
  bool _submitting = false;

  final List<Map<String, TextEditingController>> _bulkRows = [];

  @override
  void initState() {
    super.initState();
    _expiryDate = DateTime.now();
    _fetchProducts();
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

  Future<void> _fetchProducts() async {
    try {
      final res = await DioClient()
          .dio
          .get('/product/get_products/?limit=5000&offset=0&search=');
      final results = res.data['data']['results'] as List<dynamic>;
      setState(() {
        _products = results.map((e) => e['name'].toString()).toList();
        _loadingProducts = false;
      });
    } catch (_) {
      setState(() => _loadingProducts = false);
    }
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
    final row = _bulkRows.removeAt(index);
    row['qty']!.dispose();
    row['price']!.dispose();
    setState(() {});
  }

  Future<void> _submit() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final bulkPrice = <String, String>{};
      for (final row in _bulkRows) {
        final qty = row['qty']!.text.trim();
        final price = row['price']!.text.trim();
        if (qty.isNotEmpty && price.isNotEmpty) {
          bulkPrice[qty] = price;
        }
      }

      await DioClient().dio.post('/expiry/create_expiry/', data: {
        'product': _selectedProduct,
        'batch_number': _batchController.text.trim(),
        'expiry_date': _willNotExpire
            ? null
            : _expiryDate?.toIso8601String().split('T')[0],
        'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,
        'cost_price': _costPriceController.text.trim(),
        'selling_prices': _sellingPriceController.text.trim(),
        'bulk_price': bulkPrice,
      });

      if (mounted) {
        context.read<ExpiryBloc>().add(const FetchExpiry());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expiry created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: Color(0xFF333333)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Add Expiry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Text(
                  'Add a new expiry date for your products.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),

              // Form Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Product + Batch Number
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProductDropdown()),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildField(
                            label: 'Batch Number',
                            hint: 'Enter 4-digit Batch Number',
                            controller: _batchController,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row 2: Expiry Date + Quantity
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDateField()),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildField(
                            label: 'Quantity',
                            hint: 'Enter quantity',
                            controller: _quantityController,
                            required: true,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row 3: Cost Price + Selling Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Cost Price',
                            hint: 'Enter cost price',
                            controller: _costPriceController,
                            required: true,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildField(
                            label: 'Selling Price',
                            hint: 'Enter selling price',
                            controller: _sellingPriceController,
                            required: true,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Will not expire toggle
                    Row(
                      children: [
                        const Text(
                          'Will not expire',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF444444)),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: _willNotExpire,
                          onChanged: (v) => setState(() => _willNotExpire = v),
                          activeColor: const Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Add Bulk Button
                    OutlinedButton.icon(
                      onPressed: _addBulkRow,
                      icon: const Icon(Icons.add,
                          size: 16, color: Color(0xFF1565C0)),
                      label: const Text(
                        'Add Bulk',
                        style:
                            TextStyle(color: Color(0xFF1565C0), fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1565C0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                    ),

                    // Bulk Price Rows
                    if (_bulkRows.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Bulk Prices',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (int i = 0; i < _bulkRows.length; i++)
                        _buildBulkRow(i),
                    ],

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: 160,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: const Color(0xFF555555),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Add Expiry',
                                style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: '* ',
            style: TextStyle(color: Colors.red, fontSize: 13),
            children: [
              TextSpan(
                text: 'Product Name:',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedProduct,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
          hint: Text(
            _loadingProducts ? 'Loading...' : '',
            style: const TextStyle(fontSize: 13),
          ),
          items: _products
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p, style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedProduct = v),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: '* ',
            style: TextStyle(color: Colors.red, fontSize: 13),
            children: [
              TextSpan(
                text: 'Expiry Date:',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _willNotExpire
              ? null
              : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _expiryDate = picked);
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: _willNotExpire ? Colors.grey[100] : Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: _willNotExpire ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  _willNotExpire
                      ? 'Will not expire'
                      : (_expiryDate != null
                          ? '${_expiryDate!.year}-'
                              '${_expiryDate!.month.toString().padLeft(2, '0')}-'
                              '${_expiryDate!.day.toString().padLeft(2, '0')}'
                          : 'Select date'),
                  style: TextStyle(
                    fontSize: 13,
                    color: _willNotExpire
                        ? Colors.grey[400]
                        : const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: required ? '* ' : '',
            style: const TextStyle(color: Colors.red, fontSize: 13),
            children: [
              TextSpan(
                text: '$label:',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkRow(int index) {
    final row = _bulkRows[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: row['qty'],
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Quantity',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: row['price'],
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Price',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _addBulkRow,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeBulkRow(index),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.remove, size: 18, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
