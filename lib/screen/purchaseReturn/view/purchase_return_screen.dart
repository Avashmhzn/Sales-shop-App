import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/purchase/view/datepiker.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
import 'package:saleup_app/screen/purchaseReturn/model/purchase_return.dart';
import 'package:saleup_app/screen/purchaseReturn/view/add_purchase_return_screen.dart';
import 'package:saleup_app/screen/purchaseReturn/view/purchase_return_card.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  DateTime? _tempStart;
  DateTime? _tempEnd;
  DateTime? _appliedStart;
  DateTime? _appliedEnd;
  String? _selectedParty;
  String? _appliedParty;
  List<String> _parties = [];

  final TextEditingController _searchCtrl = TextEditingController();

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    context.read<PurchaseReturnBloc>().add(const LoadPurchaseReturns());
    _loadParties();
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
      debugPrint('_loadParties error: $e');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime? d) =>
      d != null ? DateFormat('MM/dd/yy').format(d) : '';

  Future<void> _selectDate(bool isStart) async {
    await showDialog(
      context: context,
      builder: (_) => NepaliDatePickerDialog(
        initialDate: NepaliDateTime.now(),
        firstDate: NepaliDateTime(2075),
        lastDate: NepaliDateTime(2090),
        onDateSelected: (picked) {
          setState(() {
            if (isStart) {
              _tempStart = picked.toDateTime();
            } else {
              _tempEnd = picked.toDateTime();
            }
          });
          if (context.canPop()) context.pop();
        },
      ),
    );
  }

  void _apply() {
    setState(() {
      _appliedStart = _tempStart;
      _appliedEnd = _tempEnd;
      _appliedParty = _selectedParty;
    });
  }

  void _reset() {
    setState(() {
      _tempStart = null;
      _tempEnd = null;
      _appliedStart = null;
      _appliedEnd = null;
      _selectedParty = null;
      _appliedParty = null;
      _searchCtrl.clear();
    });
  }

  List<PurchaseReturn> _filtered(List<PurchaseReturn> list) {
    final q = _searchCtrl.text.trim().toLowerCase();

    return list.where((r) {
      bool dateMatch = true;
      if (_appliedStart != null) {
        dateMatch = !r.returnDate.isBefore(_appliedStart!);
      }
      if (_appliedEnd != null) {
        dateMatch = dateMatch && !r.returnDate.isAfter(_appliedEnd!);
      }

      // Safe handling for partyName
      final partyNameLower = r.partyName?.toLowerCase() ?? '';
      bool partyMatch = _appliedParty == null ||
          (partyNameLower == _appliedParty!.toLowerCase());

      // Safe handling for invoiceNumber and reason
      final invoiceLower = r.invoiceNumber?.toLowerCase() ?? '';
      final reasonLower = r.reason?.toLowerCase() ?? '';

      bool searchMatch = q.isEmpty ||
          partyNameLower.contains(q) ||
          invoiceLower.contains(q) ||
          reasonLower.contains(q);

      return dateMatch && partyMatch && searchMatch;
    }).toList();
  }

  Future<void> _confirmDelete(PurchaseReturn r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Purchase Return'),
        content: const Text('Are you sure you want to delete this return?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final res = await DioClient().dio.delete(
        '/purchase-return/delete_purchase_return/',
        queryParameters: {'return_id': r.id},
      );

      if (res.data['success'] == true) {
        context.read<PurchaseReturnBloc>().add(const LoadPurchaseReturns());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase Return deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.data['message'] ?? 'Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting return: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Image.asset(
                        'assets/images/back_button_logo.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Purchase Return',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Search + New Return button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Image.asset(
                                'assets/images/search.png',
                                width: 22,
                                height: 22,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 1,
                                    vertical: 12,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => PurchaseReturnBloc(
                                dio: DioClient().dio,
                              ),
                              child: const AddPurchaseReturnScreen(),
                            ),
                          ),
                        ).then((added) {
                          if (added == true && mounted) {
                            context
                                .read<PurchaseReturnBloc>()
                                .add(const LoadPurchaseReturns());
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59422),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('New Return'),
                    ),
                  ],
                ),
              ),

              // Filter Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 380;
                    final buttonWidth = isNarrow ? 68.0 : 80.0;
                    final buttonHeight = isNarrow ? 36.0 : 40.0;
                    final textSize = isNarrow ? 13.0 : 14.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 6),
                                child: Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 6),
                                child: Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: buttonWidth * 2 + 16),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _dateField('Start', _tempStart, true),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 5,
                              child: _dateField('End', _tempEnd, false),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: _apply,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5A623),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Filter',
                                    style: TextStyle(
                                      fontSize: textSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: _reset,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9E9E9E),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: textSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            'Party',
                            style: TextStyle(
                              fontSize: textSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFF7043)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedParty,
                              isExpanded: true,
                              hint: Text(
                                'All Parties',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: textSize,
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFFFF7043),
                                size: 20,
                              ),
                              style: TextStyle(
                                fontSize: textSize,
                                color: Colors.black87,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'All Parties',
                                    style: TextStyle(fontSize: textSize),
                                  ),
                                ),
                                ..._parties.map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p,
                                      style: TextStyle(fontSize: textSize),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedParty = v),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Purchase Return List
              BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
                builder: (context, state) {
                  if (state is PurchaseReturnsLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is PurchaseReturnError) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  final returns = state is PurchaseReturnsLoaded
                      ? state.returns
                      : <PurchaseReturn>[];
                  final filtered = _filtered(returns);
                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No purchase returns found')),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) => PurchaseReturnCard(
                      purchaseReturn: filtered[i],
                      onEdit: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit coming soon')),
                        );
                      },
                      onDelete: () => _confirmDelete(filtered[i]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(String hint, DateTime? date, bool isStart) {
    final text = date != null ? _fmtDate(date) : hint;
    return GestureDetector(
      onTap: () => _selectDate(isStart),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF7043)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: date != null ? Colors.black : Colors.grey[700],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 1),
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: Color(0xFFFF7043),
            ),
          ],
        ),
      ),
    );
  }
}
