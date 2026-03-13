import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:saleup_app/model/account_heads_response.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_state.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_state.dart';
import 'package:saleup_app/services/auth_service.dart';
import 'package:saleup_app/utility/datepiker.dart';

class PostVoucherScreen extends StatefulWidget {
  const PostVoucherScreen({super.key});

  @override
  State<PostVoucherScreen> createState() => _PostVoucherScreenState();
}

class _PostVoucherScreenState extends State<PostVoucherScreen> {
  final _formKey = GlobalKey<FormState>();

  static const _orange = Color(0xFFF59422);

  String? _voucherType;
  final _voucherNumberController = TextEditingController();
  NepaliDateTime? _nepaliDate;
  final _narrationController = TextEditingController();
  final _signatureController = TextEditingController();
  String? _status;
  String? _createdBy;
  bool _hasNavigated = false;

  final List<Map<String, dynamic>> _rows = [];

  double get totalDebit =>
      _rows.fold(0.0, (sum, row) => sum + (row['debit'] as double));
  double get totalCredit =>
      _rows.fold(0.0, (sum, row) => sum + (row['credit'] as double));

  bool get canSave =>
      _voucherType != null &&
      _voucherNumberController.text.trim().isNotEmpty &&
      _nepaliDate != null &&
      _rows.isNotEmpty &&
      _rows.every((row) =>
          row['account'] != null &&
          ((row['debit'] as double) > 0 || (row['credit'] as double) > 0));

  @override
  void initState() {
    super.initState();
    _loadCreatedBy();
    _addEmptyRow();
  }

  Future<void> _loadCreatedBy() async {
    final auth = AuthService();
    final username = await auth.getUsername();
    if (mounted) setState(() => _createdBy = username ?? 'Unknown User');
  }

  void _addEmptyRow() {
    setState(() => _rows.add({
          'account': null,
          'debit': 0.0,
          'credit': 0.0,
          'isTaxLine': false,
          'debitController': TextEditingController(),
          'creditController': TextEditingController(),
        }));
  }

  void _updateRow(int index, Map<String, dynamic> changes) {
    setState(() {
      _rows[index] = {..._rows[index], ...changes};
      final debit = _rows[index]['debit'] as double;
      final credit = _rows[index]['credit'] as double;
      if (debit > 0) _rows[index]['credit'] = 0.0;
      if (credit > 0) _rows[index]['debit'] = 0.0;
    });
  }

  void _removeRow(int index) {
    if (_rows.length > 1) setState(() => _rows.removeAt(index));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final items = _rows.map((row) {
      final acc = row['account'] as AccountHeadData?;
      return {
        'account': acc?.name ?? '',
        'debit': row['debit'],
        'credit': row['credit'],
        'is_tax_line': row['isTaxLine'],
      };
    }).toList();

    context.read<VoucherBloc>().add(CreateVoucher({
          'type': _voucherType,
          'voucher_number': _voucherNumberController.text.trim(),
          'voucher_date': _nepaliDate!.toDateTime().toIso8601String(),
          'narration': _narrationController.text.trim(),
          'signature': _signatureController.text.trim(),
          'status': _status ?? 'pending',
          'total_debit': totalDebit.toStringAsFixed(2),
          'total_credit': totalCredit.toStringAsFixed(2),
          'created_by': _createdBy ?? 'Unknown User',
          'voucher_items': items,
        }));
  }

  Future<void> _showNepaliDatePicker() async {
    final selected = await showDialog<NepaliDateTime?>(
      context: context,
      builder: (context) => NepaliDatePickerDialog(
        initialDate: _nepaliDate ?? NepaliDateTime.now(),
        firstDate: NepaliDateTime(2000, 1, 1),
        lastDate: NepaliDateTime(2100, 12, 30),
        onDateSelected: (date) {},
      ),
    );
    // if (selected != null && mounted) setState(() => _nepaliDate = selected);
    if (selected != null && mounted) {
      setState(() => _nepaliDate = selected);
      FocusScope.of(context).unfocus();
    }
  }

  String _formatNepaliDate(NepaliDateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final ad = dt.toDateTime();
    final adDay = ad.day.toString().padLeft(2, '0');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '$y-$m-$d ($adDay ${months[ad.month - 1]})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Voucher',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: BlocBuilder<AccountHeadBloc, AccountHeadState>(
        builder: (context, accState) {
          if (accState.isLoading && accState.accountHeads.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: _orange));
          }
          final accounts = accState.getFilteredData();

          return BlocConsumer<VoucherBloc, VoucherState>(
            listener: (context, state) {
              if (state.createError != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.createError!),
                    backgroundColor: Colors.red));
              }
              if (state.newlyCreatedVoucher != null && !_hasNavigated) {
                _hasNavigated = true;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Voucher ${state.newlyCreatedVoucher!.voucherNumber ?? "—"} created successfully'),
                  backgroundColor: Colors.green,
                ));
                Navigator.pop(context);
              }
            },
            builder: (context, vState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildVoucherTypeDropdown()),
                            const SizedBox(width: 10),
                            Expanded(child: _buildVoucherNumberField()),
                            const SizedBox(width: 10),
                            Expanded(child: _buildDateField()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Row'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 11),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: _addEmptyRow,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildTable(accounts),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _readOnlyField(
                                'Total Debit',
                                totalDebit > 0
                                    ? totalDebit.toStringAsFixed(2)
                                    : '',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _readOnlyField(
                                'Total Credit',
                                totalCredit > 0
                                    ? totalCredit.toStringAsFixed(2)
                                    : '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStatusDropdown(),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _narrationController,
                          decoration: _inputDecoration('Narration',
                              hint: 'Enter Narration'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _signatureController,
                          decoration: _inputDecoration('Signature',
                              hint: 'Enter Signature'),
                        ),
                        const SizedBox(height: 12),
                        _readOnlyField(
                            'Created By', _createdBy ?? 'Loading...'),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _orange.withOpacity(0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed:
                                canSave && !vState.isCreating ? _submit : null,
                            child: vState.isCreating
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text('Save',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTable(List<AccountHeadData> accounts) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text('Account',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: Center(
                      child: Text('DR',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13))),
                ),
                SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: Center(
                      child: Text('CR',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13))),
                ),
                SizedBox(width: 6),
                SizedBox(
                  width: 50,
                  child: Center(
                      child: Text('Tax\nLine',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12))),
                ),
                SizedBox(width: 32),
              ],
            ),
          ),
          ...List.generate(_rows.length, (index) {
            final row = _rows[index];
            final selected = row['account'] as AccountHeadData?;
            final hasDebit = (row['debit'] as double) > 0;
            final hasCredit = (row['credit'] as double) > 0;
            final debitCtrl = row['debitController'] as TextEditingController;
            final creditCtrl = row['creditController'] as TextEditingController;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<AccountHeadData>(
                      // value: selected,
                      // isExpanded: true,
                      // hint: const Text('Select',
                      //     style:
                      //         TextStyle(fontSize: 12, color: Colors.black38)),
                      // decoration: const InputDecoration(
                      //   border: OutlineInputBorder(),
                      //   contentPadding:
                      //       EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      //   isDense: true,
                      // ),
                      initialValue: selected,
                      isExpanded: true,
                      menuMaxHeight: 250,
                      hint: const Text('Select',
                          style:
                              TextStyle(fontSize: 12, color: Colors.black38)),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        isDense: true,
                      ),
                      items: accounts
                          .map((acc) => DropdownMenuItem<AccountHeadData>(
                                value: acc,
                                child: Text(acc.name,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (val) => _updateRow(index, {'account': val}),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: debitCtrl,
                      enabled: !hasCredit,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        isDense: true,
                        hintText: '0',
                        hintStyle: const TextStyle(color: Colors.black38),
                        filled: hasCredit,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) {
                        final d = double.tryParse(v) ?? 0.0;
                        if (d > 0) creditCtrl.clear();
                        _updateRow(index, {
                          'debit': d,
                          'credit': d > 0 ? 0.0 : row['credit'],
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: creditCtrl,
                      enabled: !hasDebit,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        isDense: true,
                        hintText: '0',
                        hintStyle: const TextStyle(color: Colors.black38),
                        filled: hasDebit,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) {
                        final c = double.tryParse(v) ?? 0.0;
                        if (c > 0) debitCtrl.clear();
                        _updateRow(index, {
                          'credit': c,
                          'debit': c > 0 ? 0.0 : row['debit'],
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 50,
                    child: Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: row['isTaxLine'] as bool,
                        activeThumbColor: _orange,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (v) => _updateRow(index, {'isTaxLine': v}),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 20),
                      onPressed: () => _removeRow(index),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVoucherTypeDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: _inputDecoration('Voucher Type', required: true),
      hint: const Text('Select Type',
          style: TextStyle(fontSize: 13, color: Colors.black38)),
      initialValue: _voucherType,
      items: ['Journal', 'Purchase', 'Contra', 'Receipt', 'Sales', 'Payment']
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => _voucherType = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildVoucherNumberField() {
    return TextFormField(
      controller: _voucherNumberController,
      decoration: _inputDecoration('Voucher Number',
          required: true, hint: 'Enter Voucher Number'),
      validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          _showNepaliDatePicker();
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '* Date',
          labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          prefixIcon: const Icon(Icons.calendar_today_outlined,
              size: 16, color: Colors.black54),
        ),
        child: Text(
          _nepaliDate == null ? 'Select (BS)' : _formatNepaliDate(_nepaliDate!),
          style: TextStyle(
            fontSize: 13,
            color: _nepaliDate == null ? Colors.black38 : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: _inputDecoration('Voucher Status'),
      hint: const Text('Select Status',
          style: TextStyle(fontSize: 13, color: Colors.black38)),
      initialValue: _status,
      items: const [
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'approved', child: Text('Approved')),
        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
      ],
      onChanged: (v) => setState(() => _status = v),
    );
  }

  InputDecoration _inputDecoration(String label,
      {bool required = false, String? hint}) {
    return InputDecoration(
      labelText: required ? '* $label' : label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      isDense: true,
    );
  }

  Widget _readOnlyField(String label, String value) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: value,
      readOnly: true,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        isDense: true,
      ),
    );
  }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    _narrationController.dispose();
    _signatureController.dispose();
    for (final row in _rows) {
      (row['debitController'] as TextEditingController).dispose();
      (row['creditController'] as TextEditingController).dispose();
    }
    super.dispose();
  }
}
