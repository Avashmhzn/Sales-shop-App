import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/parties/bloc/party_bloc.dart';
import 'package:saleup_app/screen/parties/bloc/party_event.dart';

class AddPartyScreen extends StatefulWidget {
  const AddPartyScreen({super.key});

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _panController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedType;
  bool _status = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _panController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _openingBalanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Capture before async
    final bloc = context.read<PartyBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    final body = {
      "name": _nameController.text.trim(),
      "type": _selectedType,
      "pan_number": _panController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "opening_balance":
          double.tryParse(_openingBalanceController.text.trim()) ?? 0.0,
      "description": _descriptionController.text.trim(),
      "status": _status,
    };

    try {
      final response = await DioClient().dio.post(
            '/party/create_party/',
            data: body,
          );

      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 201) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));

      if (isSuccess) {
        bloc.add(const FetchParties());
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Party created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(data is Map
            ? (data['message'] ?? 'Create failed')
            : 'Create failed');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to create: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          size: 20, color: Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Party',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Add a new supplier or customer.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Row 1: Name + Type ──
                _buildRow(
                  left: _buildField(
                    label: 'Name:',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(hint: 'Name'),
                    ),
                  ),
                  right: _buildField(
                    label: '* Type',
                    required: true,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: _inputDecoration(),
                      hint: const Text(''),
                      items: const [
                        DropdownMenuItem(
                            value: 'Customer', child: Text('Customer')),
                        DropdownMenuItem(
                            value: 'Supplier', child: Text('Supplier')),
                        DropdownMenuItem(value: 'Both', child: Text('Both')),
                      ],
                      onChanged: (val) => setState(() => _selectedType = val),
                      validator: (val) =>
                          val == null ? 'Please select a type' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Row 2: PAN + Phone ──
                _buildRow(
                  left: _buildField(
                    label: 'PAN No.:',
                    child: TextFormField(
                      controller: _panController,
                      decoration: _inputDecoration(hint: 'PAN no.'),
                    ),
                  ),
                  right: _buildField(
                    label: '* Phone :',
                    required: true,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(hint: 'Phone'),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Phone is required'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Row 3: Address + Opening Balance ──
                _buildRow(
                  left: _buildField(
                    label: 'Address:',
                    child: TextFormField(
                      controller: _addressController,
                      decoration: _inputDecoration(hint: 'Address'),
                    ),
                  ),
                  right: _buildField(
                    label: 'Opening Balance:',
                    child: TextFormField(
                      controller: _openingBalanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(hint: 'Opening Balance'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Row 4: Description (left only) ──
                _buildRow(
                  left: _buildField(
                    label: 'Description :',
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration(hint: 'Enter Description'),
                    ),
                  ),
                  right: const SizedBox(), // empty right column
                ),
                const SizedBox(height: 16),

                // ── Status ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Switch(
                      value: _status,
                      onChanged: (val) => setState(() => _status = val),
                      activeThumbColor: const Color(0xFF2196F3),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Add Button ──
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.black54,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black54),
                          )
                        : const Text(
                            'Add',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildRow({required Widget left, required Widget right}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          // Stack on small screens
          return Column(
            children: [
              left,
              const SizedBox(height: 16),
              right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 24),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required Widget child,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
