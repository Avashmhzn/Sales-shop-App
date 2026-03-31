import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/model/party_response.dart';
import 'package:saleup_app/model/receipt_response.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_state.dart';
import 'package:saleup_app/screen/receipts/widget/add_party_dialog.dart';

class AddReceiptScreen extends StatefulWidget {
  const AddReceiptScreen({super.key});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPopping = false;

  final _amountController = TextEditingController();
  final _signatureController = TextEditingController();
  final _narrationController = TextEditingController();
  final _chequeNumberController = TextEditingController();
  final _chequeDateController = TextEditingController();

  final List<String> _depositModes = ['Cash', 'Cheque', 'Bank Transfer'];
  String? _selectedDepositMode;

  PartyData? _selectedParty;
  RemainingReceiptData? _selectedInvoice;

  double _totalAmount = 0.0;
  double _paidAmount = 0.0;
  double _remainingAmount = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptBloc>().add(const FetchParties());
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _signatureController.dispose();
    _narrationController.dispose();
    _chequeNumberController.dispose();
    _chequeDateController.dispose();
    super.dispose();
  }

  void _onPartySelected(PartyData? party) {
    setState(() {
      _selectedParty = party;
      _selectedInvoice = null;
      _totalAmount = 0;
      _paidAmount = 0;
      _remainingAmount = 0;
    });
    if (party != null) {
      context
          .read<ReceiptBloc>()
          .add(FetchRemainingReceipts(party.accId ?? party.id));
    }
  }

  void _onInvoiceSelected(RemainingReceiptData? invoice) {
    setState(() {
      _selectedInvoice = invoice;
      _totalAmount = invoice?.total ?? 0;
      _paidAmount = invoice?.received ?? 0;
      _remainingAmount = invoice?.remaining ?? 0;
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer')));
      return;
    }
    if (_selectedInvoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an invoice')));
      return;
    }
    if (_selectedDepositMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select deposit mode')));
      return;
    }

    context.read<ReceiptBloc>().add(CreateReceipt(
          refNumber: _selectedInvoice!.invoiceNumber,
          customer: _selectedParty!.name,
          amount: double.tryParse(_amountController.text.trim()) ?? 0,
          depositedIn: _selectedDepositMode!,
          signature: _signatureController.text.trim(),
          narration: _narrationController.text.trim(),
          chequeNumber: _chequeNumberController.text.trim(),
          chequeDate: _chequeDateController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiptBloc, ReceiptState>(
      listener: (context, state) {
        if (state.createSuccess && !_isPopping) {
          _isPopping = true;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt created successfully!')));
          context.read<ReceiptBloc>().add(const FetchReceipts());
          Navigator.pop(context);
        } else if (state.errorMessage != null && !state.isCreating) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Customer Post Receipt',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<ReceiptBloc, ReceiptState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerSection(state),
                          const SizedBox(height: 24),
                          _buildInvoiceSection(state),
                          const SizedBox(height: 24),

                          // Amount Section
                          Row(
                            children: [
                              Expanded(
                                  child: _buildReadonlyField(
                                      'Total Amount', _totalAmount)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _buildReadonlyField(
                                      'Paid Amount', _paidAmount)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildAmountField(),
                          const SizedBox(height: 24),

                          _buildDepositSection(),
                          const SizedBox(height: 20),

                          _buildSignatureAndNarration(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.isCreating ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5A623),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: state.isCreating
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Receipt',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Customer Section
  Widget _buildCustomerSection(ReceiptState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('* Customer Account',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: state.isLoadingParties
                  ? _loadingBox()
                  : DropdownButtonFormField<PartyData>(
                      value: _selectedParty,
                      hint: const Text('Select Customer'),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      items: state.parties
                          .where(
                              (p) => p.type == 'Customer' || p.type == 'Both')
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: _onPartySelected,
                      validator: (v) =>
                          v == null ? 'Customer is required' : null,
                    ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF5A623),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => BlocProvider.value(
                      value: BlocProvider.of<ReceiptBloc>(
                          context), // ← This fixes the error
                      child: const AddPartyDialog(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Invoice / Reference Section
  Widget _buildInvoiceSection(ReceiptState state) {
    final isLoading = state.isLoading && state.remainingReceipts.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('* Reference Number',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        isLoading
            ? _loadingBox()
            : DropdownButtonFormField<RemainingReceiptData>(
                value: _selectedInvoice,
                hint: const Text('Select Invoice'),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                items: state.remainingReceipts.map((inv) {
                  return DropdownMenuItem(
                    value: inv,
                    child: Text(inv.dropdownLabel,
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _selectedParty == null ? null : _onInvoiceSelected,
                validator: (v) => v == null ? 'Please select an invoice' : null,
              ),
        if (_selectedParty == null)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('Select a customer first',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
      ],
    );
  }

  Widget _buildDepositSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('* Deposited In',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDepositMode,
          hint: const Text('Select Deposit Mode'),
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          items: _depositModes
              .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
              .toList(),
          onChanged: (val) => setState(() => _selectedDepositMode = val),
          validator: (v) => v == null ? 'Deposit mode is required' : null,
        ),
      ],
    );
  }

  Widget _buildSignatureAndNarration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: '* Signature',
          controller: _signatureController,
          hint: 'Enter Signature',
          validator: (v) =>
              (v?.trim().isEmpty ?? true) ? 'Signature is required' : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Narration',
          controller: _narrationController,
          hint: 'Enter Narration (Optional)',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('* Amount', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter Amount',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Amount is required';
            final amount = double.tryParse(v.trim());
            if (amount == null || amount <= 0) return 'Enter valid amount';
            if (_selectedInvoice != null &&
                amount > _selectedInvoice!.remaining) {
              return 'Cannot exceed remaining amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildReadonlyField(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value > 0 ? value.toStringAsFixed(2) : '0.00',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _loadingBox() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
