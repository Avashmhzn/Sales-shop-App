// File: lib/screen/accountHead/view/account_head.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/account_heads_response.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_event.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_state.dart';
import 'package:saleup_app/screen/accountHead/widgets/account_head_card.dart';

const int _kPageSize = 10;
const double _kRowHeight = 72.0;

class AccountHead extends StatefulWidget {
  const AccountHead({super.key});

  @override
  State<AccountHead> createState() => _AccountHeadState();
}

class _AccountHeadState extends State<AccountHead> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedParent;
  String? _selectedMainGroup;
  final Set<int> _selectedIds = {};
  int _currentPage = 1;

  static const _orange = Color(0xFFE8891A);

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    context.read<AccountHeadBloc>().add(const ClearFilters());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ─── Handlers ─────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    setState(() => _currentPage = 1);
    context
        .read<AccountHeadBloc>()
        .add(SearchAccountHeads(_searchController.text));
  }

  void _clearAllFilters() {
    setState(() {
      _selectedParent = null;
      _selectedMainGroup = null;
      _currentPage = 1;
    });
    context.read<AccountHeadBloc>().add(const ClearFilters());
    _searchController.clear();
  }

  void _toggleSelectAll(List<AccountHeadData> pageItems, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(pageItems.map((v) => v.id));
      } else {
        _selectedIds.removeAll(pageItems.map((v) => v.id));
      }
    });
  }

  void _toggleSelect(int id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  List<AccountHeadData> _pageSlice(List<AccountHeadData> filtered) {
    final start = (_currentPage - 1) * _kPageSize;
    if (start >= filtered.length) return [];
    return filtered.sublist(
        start, (start + _kPageSize).clamp(0, filtered.length));
  }

  int _totalPages(int count) => (count / _kPageSize).ceil().clamp(1, 9999);

  // ─── Edit Dialog ──────────────────────────────────────────────────────────

  void _showEditAccountHeadDialog(AccountHeadData head) {
    final bloc = context.read<AccountHeadBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final nameController = TextEditingController(text: head.name ?? '');
    final openingBalanceController = TextEditingController(
        text: head.openingBalance?.toStringAsFixed(2) ?? '');

    String? selectedMainGroup = head.mainGroup;
    String? selectedParent = head.parent;
    String? selectedDrCr = head.drCr;
    String? selectedAccountType = head.accountType;
    bool status = head.status ?? true;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 520.0;

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()))
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Edit Account',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.close,
                                    color: Colors.black54, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 20),

                          // ── Row 1: Account ID + Name ──
                          Row(
                            children: [
                              Expanded(
                                child: _buildEditFormField(
                                  label: '* Account ID',
                                  child: TextFormField(
                                    initialValue: head.id.toString(),
                                    readOnly: true,
                                    style: const TextStyle(
                                        color: Colors.black45,
                                        fontFamily: 'Inter'),
                                    decoration: _editInputDecoration(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildEditFormField(
                                  label: '* Name',
                                  child: TextFormField(
                                    controller: nameController,
                                    decoration: _editInputDecoration(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Inter'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Row 2: Main Group + Parent ──
                          Row(
                            children: [
                              Expanded(
                                child: _buildEditFormField(
                                  label: '* Main Group:',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedMainGroup,
                                    decoration: _editInputDecoration(),
                                    isExpanded: true,
                                    items: const [
                                      'Capital Account',
                                      'Reserves & Surplus',
                                      'Secured Loans',
                                      'Unsecured Loans',
                                      'Bank OD',
                                      'Bank OCC Account',
                                      'Current Assets',
                                      'Fixed Assets',
                                      'Current Liabilities',
                                      'Direct Income',
                                      'Indirect Income',
                                      'Direct Expenses',
                                      'Indirect Expenses',
                                      'Bank Account',
                                      'Cash-in-Hand',
                                      'Sundry Debtors',
                                      'Sundry Creditors',
                                      'Loans & Advances',
                                      'Provisions',
                                    ]
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (val) => setDialogState(
                                        () => selectedMainGroup = val),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildEditFormField(
                                  label: '* Parent:',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedParent,
                                    decoration: _editInputDecoration(),
                                    isExpanded: true,
                                    items: const [
                                      'Assets',
                                      'Liabilities',
                                      'Income',
                                      'Expenses',
                                    ]
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (val) => setDialogState(
                                        () => selectedParent = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Row 3: Dr/Cr + Account Type ──
                          Row(
                            children: [
                              Expanded(
                                child: _buildEditFormField(
                                  label: '* Dr/Cr',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedDrCr,
                                    decoration: _editInputDecoration(),
                                    isExpanded: true,
                                    items: const ['Debit', 'Credit']
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (val) => setDialogState(
                                        () => selectedDrCr = val),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildEditFormField(
                                  label: '* Account Type',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedAccountType,
                                    decoration: _editInputDecoration(),
                                    isExpanded: true,
                                    items: const ['Real', 'Personal', 'Nominal']
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (val) => setDialogState(
                                        () => selectedAccountType = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Opening Balance ──
                          SizedBox(
                            width: (dialogWidth - 48) / 2,
                            child: _buildEditFormField(
                              label: '* Opening Balance:',
                              child: TextFormField(
                                controller: openingBalanceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: _editInputDecoration(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Status ──
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Status:',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                              Switch(
                                value: status,
                                onChanged: (val) =>
                                    setDialogState(() => status = val),
                                activeThumbColor: const Color(0xFFFF9800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Save Button ──
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                setDialogState(() => isLoading = true);
                                final navigator = Navigator.of(context);

                                final updatedData = {
                                  "name": nameController.text.trim(),
                                  "main_group": selectedMainGroup,
                                  "parent": selectedParent,
                                  "dr_cr": selectedDrCr,
                                  "account_type": selectedAccountType,
                                  "opening_balance": double.tryParse(
                                          openingBalanceController.text
                                              .trim()) ??
                                      0.0,
                                  "status": status,
                                };

                                try {
                                  final response = await DioClient().dio.put(
                                        '/account-heads/update_account_head/?account_head_id=${head.id}',
                                        data: updatedData,
                                      );

                                  final data = response.data;
                                  final isSuccess =
                                      response.statusCode == 200 &&
                                          (data is Map &&
                                              (data['success'] == true ||
                                                  data['success'] == 'true'));

                                  if (isSuccess) {
                                    navigator.pop();
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                          content: Text(data['message'] ??
                                              'Account updated successfully'),
                                          backgroundColor: Colors.green),
                                    );
                                    bloc.add(const FetchAccountHeads());
                                  } else {
                                    throw Exception(data is Map
                                        ? (data['message'] ?? 'Update failed')
                                        : 'Update failed');
                                  }
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                      content: Text('Failed to update: $e'),
                                      backgroundColor: Colors.red));
                                } finally {
                                  if (context.mounted) {
                                    setDialogState(() => isLoading = false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Save Changes',
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
      ),
    );
  }

  // ─── Edit Dialog Helpers ──────────────────────────────────────────────────

  Widget _buildEditFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE8891A))),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _editInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // ─── View Dialog ──────────────────────────────────────────────────────────

  void _showAccountDetailPopup(BuildContext context, AccountHeadData head) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Account Details',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter')),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 12),
                _buildGridRow(
                    'ID', head.id.toString(), 'Name', head.name ?? 'N/A'),
                const Divider(height: 1),
                _buildGridRow('Main Group', head.mainGroup ?? 'N/A', 'Parent',
                    head.parent ?? 'N/A'),
                const Divider(height: 1),
                _buildGridRow('Dr Cr', head.drCr ?? 'N/A', 'Account Type',
                    head.accountType ?? 'N/A'),
                const Divider(height: 1),
                _buildGridRow(
                  'Opening Balance',
                  head.openingBalance?.toStringAsFixed(2) ?? '-',
                  'Status',
                  head.status == true ? 'Active' : 'Inactive',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridRow(
      String label1, String value1, String label2, String value2) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: _buildLabelValue(label1, value1)),
          Expanded(child: _buildLabelValue(label2, value2)),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 14, fontFamily: 'Inter', color: Colors.black87),
        children: [
          TextSpan(
              text: '$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          TextSpan(
              text: value,
              style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Inter',
                  color: Colors.black54)),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<AccountHeadBloc, AccountHeadState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            // ── Derived data ──
            final allHeads = state.accountHeads;
            final parentToGroups = <String, Set<String>>{};
            for (final head in allHeads) {
              final parent = head.parent ?? 'No Parent';
              final mainGroup = head.mainGroup ?? 'Unknown';
              parentToGroups.putIfAbsent(parent, () => {}).add(mainGroup);
            }
            final sortedParents = parentToGroups.keys.toList()..sort();

            final baseFiltered = state.getFilteredData();
            final searchLower = _searchController.text.trim().toLowerCase();
            final filteredHeads = searchLower.isEmpty
                ? baseFiltered
                : baseFiltered
                    .where((head) =>
                        (head.name.toLowerCase().contains(searchLower)) ||
                        (head.mainGroup?.toLowerCase().contains(searchLower) ??
                            false) ||
                        (head.parent?.toLowerCase().contains(searchLower) ??
                            false) ||
                        (head.accountType
                                ?.toLowerCase()
                                .contains(searchLower) ??
                            false))
                    .toList();

            final totalPages = _totalPages(filteredHeads.length);
            if (_currentPage > totalPages && totalPages > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _currentPage = totalPages);
              });
            }

            final pageItems = _pageSlice(filteredHeads);
            final pageAllSelected = pageItems.isNotEmpty &&
                pageItems.every((v) => _selectedIds.contains(v.id));

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──
                    const Text('Account',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 4),
                    Text('Manage and categorize different account types',
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Colors.grey[600])),
                    const SizedBox(height: 12),

                    // ── Search + New Account ──
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(200),
                                border:
                                    Border.all(color: const Color(0xFFE0E0E0))),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFFAAAAAA),
                                    fontSize: 13),
                                prefixIcon: Icon(Icons.search,
                                    color: Color(0xFFAAAAAA), size: 18),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                          label: const Text('New Account',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Select All + Delete All row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Select all checkbox for current page
                        if (pageItems.isNotEmpty)
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: pageAllSelected,
                                  onChanged: (v) =>
                                      _toggleSelectAll(pageItems, v),
                                  activeColor: _orange,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  side: const BorderSide(
                                      color: Color(0xFFCCCCCC), width: 1.5),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Select All',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    color: Colors.grey[600]),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),

                        // Delete All button
                        TextButton.icon(
                          onPressed: _selectedIds.isEmpty ? null : () {},
                          icon: Icon(Icons.delete_outline,
                              size: 16,
                              color: _selectedIds.isEmpty
                                  ? Colors.grey
                                  : const Color(0xFFD9534F)),
                          label: Text('Delete All',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  color: _selectedIds.isEmpty
                                      ? Colors.grey
                                      : const Color(0xFFD9534F))),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, minimumSize: Size.zero),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Filter chips ──
                    _buildFilterChips(sortedParents, parentToGroups),
                    const SizedBox(height: 16),

                    // ── List or shimmer ──
                    state.isLoading
                        ? _buildShimmer()
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFEEEEEE))),
                            child: Column(
                              children: [
                                // ── Items ──
                                pageItems.isEmpty
                                    ? const SizedBox(
                                        height: 200,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                  Icons
                                                      .account_balance_outlined,
                                                  size: 48,
                                                  color: Color(0xFFCCCCCC)),
                                              SizedBox(height: 12),
                                              Text(
                                                'No account heads found',
                                                style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFF888888),
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        itemCount: pageItems.length,
                                        itemBuilder: (context, index) {
                                          final head = pageItems[index];
                                          final isSelected =
                                              _selectedIds.contains(head.id);

                                          return AccountHeadCard(
                                            head: head,
                                            isSelected: isSelected,
                                            onSelect: (v) =>
                                                _toggleSelect(head.id, v),
                                            onView: () =>
                                                _showAccountDetailPopup(
                                                    context, head),
                                            onEdit: () =>
                                                _showEditAccountHeadDialog(
                                                    head),
                                            onDelete: () {
                                              // TODO: implement delete
                                            },
                                          );
                                        },
                                      ),

                                // ── Divider + Pagination ──
                                const Divider(
                                    height: 1, color: Color(0xFFEEEEEE)),
                                SizedBox(
                                  height: 52,
                                  child: _PaginationBar(
                                    currentPage: _currentPage,
                                    totalPages: totalPages,
                                    onPageChanged: (p) =>
                                        setState(() => _currentPage = p),
                                  ),
                                ),
                              ],
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

  // ─── Filter Chips ─────────────────────────────────────────────────────────

  Widget _buildFilterChips(
      List<String> sortedParents, Map<String, Set<String>> parentToGroups) {
    final hasFilter = _selectedParent != null || _selectedMainGroup != null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...sortedParents.map((parent) {
          final isSelected = _selectedParent == parent;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedParent = null;
                  _selectedMainGroup = null;
                } else {
                  _selectedParent = parent;
                  _selectedMainGroup = null;
                }
                _currentPage = 1;
              });
              if (isSelected) {
                context.read<AccountHeadBloc>().add(const ClearFilters());
              } else {
                context.read<AccountHeadBloc>().add(UpdateMainFilter(parent));
                context
                    .read<AccountHeadBloc>()
                    .add(const UpdateSubFilter(null));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _orange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? _orange : const Color(0xFFDDDDDD)),
              ),
              child: Text(
                parent,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF555555),
                ),
              ),
            ),
          );
        }),
        if (_selectedParent != null)
          ...() {
            final groups = parentToGroups[_selectedParent]!.toList()..sort();
            return groups.map((group) {
              final isSelected = _selectedMainGroup == group;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMainGroup = isSelected ? null : group;
                    _currentPage = 1;
                  });
                  context.read<AccountHeadBloc>().add(isSelected
                      ? const UpdateSubFilter(null)
                      : UpdateSubFilter(group));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isSelected ? _orange : const Color(0xFFDDDDDD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color:
                                isSelected ? _orange : const Color(0xFFCCCCCC),
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        group,
                        style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected ? _orange : const Color(0xFF777777)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          }(),
        if (hasFilter)
          GestureDetector(
            onTap: _clearAllFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFCCCC)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 12, color: Color(0xFFD9534F)),
                  SizedBox(width: 4),
                  Text('Clear',
                      style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFD9534F))),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ─── Shimmer ──────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE))),
        child: Column(
          children: List.generate(
              10,
              (_) => Column(children: [
                    Container(height: _kRowHeight, color: Colors.white),
                    const Divider(height: 1, color: Color(0xFFEEEEEE))
                  ])),
        ),
      ),
    );
  }
}

// ─── Pagination Bar ───────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  const _PaginationBar(
      {required this.currentPage,
      required this.totalPages,
      required this.onPageChanged});

  List<int> _pages() {
    if (totalPages <= 7) return List.generate(totalPages, (i) => i + 1);
    final result = <int>[1];
    if (currentPage > 3) result.add(-1);
    for (int p = (currentPage - 1).clamp(2, totalPages - 1);
        p <= (currentPage + 1).clamp(2, totalPages - 1);
        p++) {
      result.add(p);
    }
    if (currentPage < totalPages - 2) result.add(-1);
    result.add(totalPages);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageBtn(
                icon: Icons.chevron_left,
                onTap: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null),
            const SizedBox(width: 4),
            for (final p in pages) ...[
              if (p == -1)
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text('…',
                        style: TextStyle(
                            color: Color(0xFF888888),
                            fontFamily: 'Inter',
                            fontSize: 13)))
              else
                _PagePill(
                    page: p,
                    isActive: p == currentPage,
                    onTap: () => onPageChanged(p)),
              const SizedBox(width: 2),
            ],
            _PageBtn(
                icon: Icons.chevron_right,
                onTap: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null),
          ],
        ),
      ),
    );
  }
}

// ─── Page Pill ────────────────────────────────────────────────────────────────

class _PagePill extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PagePill(
      {required this.page, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            border: Border.all(
                color: isActive ? const Color(0xFFAAAAAA) : Colors.transparent),
            borderRadius: BorderRadius.circular(6)),
        alignment: Alignment.center,
        child: Text('$page',
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF555555))),
      ),
    );
  }
}

// ─── Page Button ──────────────────────────────────────────────────────────────

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _PageBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon,
          size: 20,
          color: onTap == null
              ? const Color(0xFFCCCCCC)
              : const Color(0xFF555555)),
    );
  }
}
