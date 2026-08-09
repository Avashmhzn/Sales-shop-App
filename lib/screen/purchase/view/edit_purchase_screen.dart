import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // ← added for addPostFrameCallback
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:dio/dio.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'package:saleup_app/utility/datepiker.dart';

class EditPurchaseScreen extends StatefulWidget {
  final PurchaseData purchase;

  const EditPurchaseScreen({super.key, required this.purchase});

  @override
  State<EditPurchaseScreen> createState() => _EditPurchaseScreenState();
}

class _EditPurchaseScreenState extends State<EditPurchaseScreen> {
  late final TextEditingController _voucherCtrl;
  late final TextEditingController _invoiceCtrl;
  late final TextEditingController _chequeNumCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _tenderCtrl;

  String? _selectedBillType;
  String? _selectedParty;
  String? _chequeDate;

  List<String> _parties = [];
  final _billTypes = ['Cash', 'Bank', 'Credit'];

  late List<_ItemRow> _items;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.purchase;

    _voucherCtrl = TextEditingController(text: p.voucherNumber?.trim() ?? '');
    _invoiceCtrl = TextEditingController(text: p.invoiceNumber?.trim() ?? '');
    _chequeNumCtrl = TextEditingController(text: p.chequeNumber?.trim() ?? '');
    _discountCtrl =
        TextEditingController(text: p.discount?.toStringAsFixed(2) ?? '0.00');
    _tenderCtrl = TextEditingController(
        text: p.tenderAmount?.toStringAsFixed(2) ?? '0.00');

    _selectedBillType = p.billType;
    _selectedParty = p.party;
    _chequeDate = p.chequeDate;

    _items = (p.purchaseItems ?? []).map((item) {
      return _ItemRow(
        id: item.id,
        product: item.product ?? '',
        quantity: item.quantity?.toString() ?? '1',
        unit: item.unit ?? '',
        costPrice: item.costPrice?.toStringAsFixed(2) ?? '0.00',
        sellingPrice: item.sellingPrice?.toStringAsFixed(2) ?? '0.00',
        batchNumber: item.batchNumber ?? '',
        expiryDate: item.expiryDate != null
            ? DateFormat('yyyy-MM-dd').format(item.expiryDate!)
            : null,
        isComplementary: item.isComplementary,
      );
    }).toList();

    if (_items.isEmpty) _items.add(_ItemRow());

    _loadParties();
  }

  @override
  void dispose() {
    _voucherCtrl.dispose();
    _invoiceCtrl.dispose();
    _chequeNumCtrl.dispose();
    _discountCtrl.dispose();
    _tenderCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _confirmDeleteItem(int itemId, String? productName) {
    final safeName = (productName ?? 'this item').trim();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text(
            'Are you sure you want to delete "$safeName"?\nThis cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  final dio = DioClient().dio;
                  const path =
                      '/purchase/delete_purchases/'; // ← your working endpoint

                  debugPrint('→ SENDING DELETE REQUEST');
                  debugPrint(
                      '  → URL: ${dio.options.baseUrl}$path?item_id=$itemId');
                  debugPrint('  → Method: DELETE');

                  final response = await dio.delete(
                    path,
                    queryParameters: {'item_id': itemId},
                    options: Options(
                      receiveTimeout: const Duration(seconds: 10),
                      sendTimeout: const Duration(seconds: 10),
                    ),
                  );

                  debugPrint('← DELETE RESPONSE RECEIVED');
                  debugPrint('  ← Status: ${response.statusCode}');

                  if (response.statusCode == 200 ||
                      response.statusCode == 204) {
                    // Close dialog
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    // Defer UI update & snackbar until next frame
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      setState(() {
                        _items.removeWhere((item) => item.id == itemId);
                        if (_items.isEmpty) _items.add(_ItemRow());
                      });
                    });
                  } else {
                    throw Exception(
                        'Unexpected status: ${response.statusCode}');
                  }
                } catch (e) {
                  debugPrint('DELETE FAILED: $e');

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  // Defer error snackbar
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;

                    String msg = 'Failed to delete item';
                    if (e is DioException) {
                      final status = e.response?.statusCode;
                      if (status == 405) {
                        msg = '405 Method Not Allowed';
                      } else if (status != null) {
                        msg += ' (HTTP $status)';
                      }
                      if (e.response?.data != null) {
                        msg += '\n${e.response!.data.toString()}';
                      }
                    } else {
                      msg += ': $e';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg), backgroundColor: Colors.red),
                    );
                  });
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
      debugPrint('Load parties error: $e');
    }
  }

  Future<void> _pickDate({required bool isCheque, int? itemIndex}) async {
    final picked = await showDialog<NepaliDateTime?>(
      context: context,
      builder: (context) => NepaliDatePickerDialog(
        initialDate: NepaliDateTime.now(),
        firstDate: NepaliDateTime(2075),
        lastDate: NepaliDateTime(2090),
        onDateSelected: (NepaliDateTime selected) {
          Navigator.pop(context, selected);
        },
      ),
    );

    if (picked != null && mounted) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked.toDateTime());
      setState(() {
        if (isCheque) {
          _chequeDate = formatted;
        } else if (itemIndex != null) {
          _items[itemIndex].expiryDate = formatted;
        }
      });
    }
  }

  String _displayDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'Select Date';
    try {
      return DateFormat('MM/dd/yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Future<void> _update() async {
    if (_selectedParty == null || _selectedParty!.isEmpty) {
      _snack('Please select a party', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dio = DioClient().dio;
      final purchaseId = widget.purchase.id;

      final headerPayload = {
        'voucher_number': _voucherCtrl.text.trim(),
        'invoice_number': _invoiceCtrl.text.trim(),
        'bill_type': _selectedBillType ?? 'Cash',
        'party': _selectedParty,
        'cheque_number': _chequeNumCtrl.text.trim(),
        'cheque_date': _chequeDate ?? '',
        'discount': double.tryParse(_discountCtrl.text) ?? 0.0,
        'tender_amount': double.tryParse(_tenderCtrl.text) ?? 0.0,
      };

      final headerRes = await dio.put(
        '/purchase/update_purchase/?purchase_id=$purchaseId',
        data: headerPayload,
        options: Options(contentType: Headers.jsonContentType),
      );

      final headerResp = PurchaseResponse.fromJson(headerRes.data);
      if (!headerResp.success) {
        _snack(headerResp.message ?? 'Failed to update purchase', Colors.red);
        return;
      }

      for (final item in _items) {
        if (item.id == null) continue;

        final itemPayload = {
          'product': item.product.text.trim(),
          'quantity': int.tryParse(item.quantity.text) ?? 1,
          'unit': item.unit.text.trim(),
          'cost_price': double.tryParse(item.costPrice.text) ?? 0.0,
          'selling_price': double.tryParse(item.sellingPrice.text) ?? 0.0,
          'batch_number': item.batchNumber.text.trim(),
          'expiry_date': item.expiryDate ?? '',
          'is_complementary': item.isComplementary,
        };

        final itemRes = await dio.put(
          '/purchase/update_purchase_item/?item_id=${item.id}',
          data: itemPayload,
          options: Options(contentType: Headers.jsonContentType),
        );

        final itemResp = PurchaseResponse.fromJson(itemRes.data);
        if (!itemResp.success) {
          _snack(itemResp.message ?? 'Failed to update item', Colors.red);
          return;
        }
      }

      _snack('Purchase updated successfully', Colors.green);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _snack('Error during update: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 16, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Purchase',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Stock Inventory > Purchase > Edit',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    _card(
                      title: 'Purchase Details',
                      child: Column(
                        children: [
                          _field('Voucher Number', _voucherCtrl),
                          _field('Invoice Number', _invoiceCtrl),
                          _dropdown(
                            label: 'Bill Type',
                            value: _selectedBillType,
                            items: _billTypes,
                            onChanged: (v) =>
                                setState(() => _selectedBillType = v),
                          ),
                          _dropdown(
                            label: 'Party',
                            value: _selectedParty,
                            items: _parties,
                            onChanged: (v) =>
                                setState(() => _selectedParty = v),
                          ),
                          if (_selectedBillType == 'Bank') ...[
                            _field('Cheque Number', _chequeNumCtrl),
                            _datePicker(
                              label: 'Cheque Date',
                              value: _chequeDate,
                              onTap: () => _pickDate(isCheque: true),
                            ),
                          ],
                          _field('Discount', _discountCtrl,
                              keyboard: const TextInputType.numberWithOptions(
                                  decimal: true)),
                          _field('Tender Amount', _tenderCtrl,
                              keyboard: const TextInputType.numberWithOptions(
                                  decimal: true)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return _card(
                        title: 'Item ${i + 1}',
                        child: Column(
                          children: [
                            _field('Product', item.product),
                            _field('Quantity', item.quantity,
                                keyboard: TextInputType.number),
                            _field('Unit', item.unit),
                            _field('Cost Price', item.costPrice,
                                keyboard: const TextInputType.numberWithOptions(
                                    decimal: true)),
                            _field('Selling Price', item.sellingPrice,
                                keyboard: const TextInputType.numberWithOptions(
                                    decimal: true)),
                            _field('Batch Number', item.batchNumber),
                            _datePicker(
                              label: 'Expiry Date',
                              value: item.expiryDate,
                              onTap: () =>
                                  _pickDate(isCheque: false, itemIndex: i),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Complementary',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    if (item.id != null)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () {
                                          final name = item.product.text.trim();
                                          _confirmDeleteItem(
                                            item.id!,
                                            name.isNotEmpty ? name : null,
                                          );
                                        },
                                        tooltip: 'Delete item',
                                      ),
                                    Switch(
                                      value: item.isComplementary,
                                      activeThumbColor: const Color(0xFF4CAF50),
                                      onChanged: (v) => setState(
                                          () => item.isComplementary = v),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _update,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Update Purchase',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555))),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboard,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              border: Border.all(color: const Color(0xFFDDDDDD)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: safeValue,
                isExpanded: true,
                hint: Text('Select $label',
                    style: const TextStyle(color: Colors.grey)),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555))),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                border: Border.all(color: const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _displayDate(value),
                    style: TextStyle(
                        color:
                            value != null ? Colors.black87 : Colors.grey[500]),
                  ),
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: Color(0xFFFF7043)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow {
  final int? id;
  final TextEditingController product;
  final TextEditingController quantity;
  final TextEditingController unit;
  final TextEditingController costPrice;
  final TextEditingController sellingPrice;
  final TextEditingController batchNumber;
  String? expiryDate;
  bool isComplementary;

  _ItemRow({
    this.id,
    String product = '',
    String quantity = '1',
    String unit = '',
    String costPrice = '0.00',
    String sellingPrice = '0.00',
    String batchNumber = '',
    this.expiryDate,
    this.isComplementary = false,
  })  : product = TextEditingController(text: product),
        quantity = TextEditingController(text: quantity),
        unit = TextEditingController(text: unit),
        costPrice = TextEditingController(text: costPrice),
        sellingPrice = TextEditingController(text: sellingPrice),
        batchNumber = TextEditingController(text: batchNumber);

  void dispose() {
    product.dispose();
    quantity.dispose();
    unit.dispose();
    costPrice.dispose();
    sellingPrice.dispose();
    batchNumber.dispose();
  }
}
