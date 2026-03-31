import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';
import '../model/bill_settings.dart';

class BillOptionScreen extends StatefulWidget {
  const BillOptionScreen({super.key});

  @override
  State<BillOptionScreen> createState() => _BillOptionScreenState();
}

class _BillOptionScreenState extends State<BillOptionScreen> {
  bool isA4Selected = true;
  bool printTokenOnBill = false;

  final _leftController = TextEditingController();
  final _rightController = TextEditingController();
  final _topController = TextEditingController();
  final _bottomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BillBloc>().add(const LoadBillSettings());
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    _topController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final left = int.tryParse(_leftController.text) ?? 25;
    final right = int.tryParse(_rightController.text) ?? 25;
    final top = int.tryParse(_topController.text) ?? 25;
    final bottom = int.tryParse(_bottomController.text) ?? 25;

    context.read<BillBloc>().add(UpdateBillSettings(
          billId: 1,
          printType: isA4Selected ? 'A4' : 'Thermal',
          printTokenOnBill: printTokenOnBill,
          left: left,
          right: right,
          top: top,
          bottom: bottom,
        ));
  }

  // Preview Row Helper
  Widget _buildPreviewRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // ================== A4 Preview (No Static Data) ==================
  Widget _buildA4Preview(BillSettings? settings) {
    final showToken = settings?.printTokenOnBill ?? printTokenOnBill;

    return Container(
      width: 380,
      margin: EdgeInsets.symmetric(
        horizontal: (settings?.left ?? 20).toDouble(),
        vertical: (settings?.top ?? 20).toDouble(),
      ),
      padding: EdgeInsets.fromLTRB(
        (settings?.left ?? 16).toDouble(),
        (settings?.top ?? 16).toDouble(),
        (settings?.right ?? 16).toDouble(),
        (settings?.bottom ?? 16).toDouble(),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('INVOICE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),

          _buildPreviewRow('Bill No', '[BILL_NUMBER]'),
          _buildPreviewRow('Date', '[DATE]'),
          _buildPreviewRow('Customer', '[CUSTOMER_NAME]'),

          const Divider(height: 25),

          // Table Header
          Container(
            color: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: const Row(
              children: [
                Expanded(
                    child: Text('Item', style: TextStyle(color: Colors.white))),
                Text('Qty', style: TextStyle(color: Colors.white)),
                Text('Rate', style: TextStyle(color: Colors.white)),
                Text('Amount', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('[ITEMS WILL APPEAR HERE]',
                style: TextStyle(color: Colors.grey)),
          ),

          const Divider(),
          _buildPreviewRow('Sub Total', '[SUB_TOTAL]'),
          _buildPreviewRow('Tax', '[TAX_AMOUNT]'),
          _buildPreviewRow('Grand Total', '[GRAND_TOTAL]', isBold: true),

          if (showToken) ...[
            const SizedBox(height: 20),
            const Center(
                child: Text('Token: [TOKEN]',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],

          const SizedBox(height: 20),
          const Center(child: Text('Thank you for your business!')),
        ],
      ),
    );
  }

  // ================== Thermal Preview (No Static Data) ==================
  Widget _buildThermalPreview(BillSettings? settings) {
    final showToken = settings?.printTokenOnBill ?? printTokenOnBill;

    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(
        horizontal: (settings?.left ?? 10).toDouble(),
        vertical: (settings?.top ?? 10).toDouble(),
      ),
      padding: EdgeInsets.fromLTRB(
        (settings?.left ?? 12).toDouble(),
        (settings?.top ?? 12).toDouble(),
        (settings?.right ?? 12).toDouble(),
        (settings?.bottom ?? 12).toDouble(),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Your Shop Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('[ADDRESS]'),
          const Text('Tel: [PHONE]'),
          const Divider(height: 20),
          _buildPreviewRow('Bill No', '[BILL_NO]'),
          _buildPreviewRow('Date', '[DATE]'),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Item', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Qty'),
              Text('Total'),
            ],
          ),
          const Divider(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('[ITEMS WILL APPEAR HERE]',
                style: TextStyle(color: Colors.grey)),
          ),
          const Divider(),
          _buildPreviewRow('Sub Total', '[SUB_TOTAL]'),
          _buildPreviewRow('Tax', '[TAX]'),
          _buildPreviewRow('Grand Total', '[GRAND_TOTAL]', isBold: true),
          if (showToken) ...[
            const SizedBox(height: 12),
            const Text('Token: [TOKEN]',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 15),
          const Text('THANK YOU!',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Option Button
  Widget _buildOption(String title, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF59422) : Colors.white,
            border: Border.all(
                color:
                    selected ? const Color(0xFFF59422) : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarginField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listener: (context, state) {
        if (state is BillLoaded) {
          setState(() {
            isA4Selected = state.bill.printType?.toUpperCase() == 'A4' ||
                state.bill.printType == null;
            printTokenOnBill = state.bill.printTokenOnBill;

            _leftController.text = state.bill.left.toString();
            _rightController.text = state.bill.right.toString();
            _topController.text = state.bill.top.toString();
            _bottomController.text = state.bill.bottom.toString();
          });
        }

        if (state is BillUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Bill settings saved successfully'),
                backgroundColor: Colors.green),
          );
        }

        if (state is BillError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is BillLoading || state is BillUpdating;
        final BillSettings? currentSettings =
            state is BillLoaded ? state.bill : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Bill Option')),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select bill print template',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 24),
                      const Text('* Bill Print Type',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildOption('A4 Print', isA4Selected,
                              () => setState(() => isA4Selected = true)),
                          const SizedBox(width: 16),
                          _buildOption('Thermal Print', !isA4Selected,
                              () => setState(() => isA4Selected = false)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Checkbox(
                            value: printTokenOnBill,
                            onChanged: (v) =>
                                setState(() => printTokenOnBill = v ?? false),
                            activeColor: const Color(0xFFF59422),
                          ),
                          const Text('Print Token on Bill'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text('Bill Margins (in mm)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child:
                                  _buildMarginField('Left', _leftController)),
                          const SizedBox(width: 12),
                          Expanded(
                              child:
                                  _buildMarginField('Right', _rightController)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _buildMarginField('Top', _topController)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildMarginField(
                                  'Bottom', _bottomController)),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Center(
                          child: Text('Bill Preview',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 16),
                      isA4Selected
                          ? _buildA4Preview(currentSettings)
                          : _buildThermalPreview(currentSettings),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59422),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Save Bill Settings',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
