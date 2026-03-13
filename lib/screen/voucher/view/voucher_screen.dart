import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/model/voucher_response.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_state.dart';
import 'package:saleup_app/screen/voucher/widget/voucher_detail_dialog.dart';

const double _kCheckboxW = 24;
const double _kGapW = 12;
const double _kIdW = 50;
const double _kActionW = 80;
const double _kMinTableWidth = 520.0;
const int _kPageSize = 10;
const List<(String, int)> _kFlexCols = [
  ('Voucher Number', 3),
  ('Type', 2),
  ('Debit', 2),
  ('Credit', 2),
];
const int _kTotalFlex = 9;

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasFetchedVouchers = false;
  final Set<int> _selectedIds = {};
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
        _currentPage = 1;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final bloc = BlocProvider.of<VoucherBloc>(context, listen: false);
    if (!_hasFetchedVouchers) {
      bloc.add(const FetchVouchers());
      _hasFetchedVouchers = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VoucherData> _filterVouchers(List<VoucherData> vouchers) {
    final filtered = _searchQuery.isEmpty
        ? List<VoucherData>.from(vouchers)
        : vouchers
            .where((v) => (v.voucherNumber ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();
    filtered.sort((a, b) => a.id.compareTo(b.id));
    return filtered;
  }

  List<VoucherData> _pageSlice(List<VoucherData> filtered) {
    final start = (_currentPage - 1) * _kPageSize;
    if (start >= filtered.length) return [];
    return filtered.sublist(
        start, (start + _kPageSize).clamp(0, filtered.length));
  }

  int _totalPages(int count) => (count / _kPageSize).ceil().clamp(1, 9999);

  void _toggleSelectAll(List<VoucherData> pageItems, bool? value) {
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

  void _showDetailsPopup(BuildContext parentContext, VoucherData voucher) {
    final bloc = BlocProvider.of<VoucherBloc>(parentContext, listen: false);
    if (bloc.state.voucherDetail?.id != voucher.id) {
      bloc.add(FetchVoucherById(voucher.id));
    }
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<VoucherBloc>(parentContext),
        child: VoucherDetailDialog(voucherId: voucher.id),
      ),
    );
  }

  Widget _buildShimmerTable() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: List.generate(
            6,
            (_) => Column(children: [
              Container(height: 48, color: Colors.white),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<VoucherBloc, VoucherState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────
                const Text(
                  'Post Vouchers',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage and review posted vouchers',
                  style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 20),

                // ── Search + New Voucher ─────────────────────────
                Row(
                  children: [
                    Container(
                      width: 190,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(200),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          hintStyle:
                              TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                          prefixIcon: Icon(Icons.search,
                              color: Color(0xFFAAAAAA), size: 18),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await context.push('/voucher/create');
                        // Refresh list when returning from create screen
                        if (mounted) {
                          context
                              .read<VoucherBloc>()
                              .add(const FetchVouchers());
                        }
                      },
                      icon:
                          const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text(
                        'New\nVoucher',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8891A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Delete All ───────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () {
                            // TODO: delete selected
                          },
                    icon: Icon(Icons.delete_outline,
                        size: 16,
                        color: _selectedIds.isEmpty
                            ? Colors.grey
                            : const Color(0xFFD9534F)),
                    label: Text(
                      'Delete All',
                      style: TextStyle(
                        fontSize: 13,
                        color: _selectedIds.isEmpty
                            ? Colors.grey
                            : const Color(0xFFD9534F),
                      ),
                    ),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Table ────────────────────────────────────────
                Expanded(
                  child: BlocBuilder<VoucherBloc, VoucherState>(
                    builder: (context, state) {
                      if (state.isLoading && state.vouchers.isEmpty) {
                        return _buildShimmerTable();
                      }
                      if (state.errorMessage != null &&
                          state.vouchers.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 48, color: Color(0xFFCCCCCC)),
                              SizedBox(height: 12),
                              Text(
                                'No vouchers available',
                                style: TextStyle(
                                    color: Color(0xFF888888), fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }

                      final filtered = _filterVouchers(state.vouchers);
                      final totalPages = _totalPages(filtered.length);

                      if (_currentPage > totalPages) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _currentPage = totalPages);
                          }
                        });
                      }

                      final pageItems = _pageSlice(filtered);
                      final pageAllSelected = pageItems.isNotEmpty &&
                          pageItems.every((v) => _selectedIds.contains(v.id));

                      return _ResponsiveTable(
                        pageItems: pageItems,
                        filteredCount: filtered.length,
                        selectAll: pageAllSelected,
                        currentPage: _currentPage,
                        totalPages: totalPages,
                        onSelectAll: (v) => _toggleSelectAll(pageItems, v),
                        isSelected: (id) => _selectedIds.contains(id),
                        onSelect: _toggleSelect,
                        onView: (v) => _showDetailsPopup(context, v),
                        onDelete: (_) {},
                        onPageChanged: (p) => setState(() => _currentPage = p),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _ResponsiveTable
// ─────────────────────────────────────────────────────────────────
class _ResponsiveTable extends StatelessWidget {
  final List<VoucherData> pageItems;
  final int filteredCount;
  final bool selectAll;
  final int currentPage;
  final int totalPages;
  final void Function(bool?) onSelectAll;
  final bool Function(int) isSelected;
  final void Function(int, bool?) onSelect;
  final void Function(VoucherData) onView;
  final void Function(VoucherData) onDelete;
  final void Function(int) onPageChanged;

  const _ResponsiveTable({
    required this.pageItems,
    required this.filteredCount,
    required this.selectAll,
    required this.currentPage,
    required this.totalPages,
    required this.onSelectAll,
    required this.isSelected,
    required this.onSelect,
    required this.onView,
    required this.onDelete,
    required this.onPageChanged,
  });

  List<double> _colWidths(double availW) {
    const fixed = _kCheckboxW + _kGapW + _kIdW + _kActionW + 32.0 + 4.0;
    final flex = (availW < _kMinTableWidth ? _kMinTableWidth : availW) - fixed;
    return _kFlexCols.map((c) => flex * c.$2 / _kTotalFlex).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final availW = constraints.maxWidth;
      final colWidths = _colWidths(availW);
      final needsHScroll = availW < _kMinTableWidth;

      Widget tableBox = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: [
            _TableHeader(
              selectAll: selectAll,
              onSelectAll: onSelectAll,
              colWidths: colWidths,
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: pageItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No vouchers available',
                        style:
                            TextStyle(color: Color(0xFF888888), fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      itemCount: pageItems.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, i) {
                        final v = pageItems[i];
                        return _VoucherRow(
                          voucher: v,
                          isSelected: isSelected(v.id),
                          onSelect: (val) => onSelect(v.id, val),
                          onView: () => onView(v),
                          onDelete: () => onDelete(v),
                          colWidths: colWidths,
                        );
                      },
                    ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _PaginationBar(
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChanged: onPageChanged,
            ),
          ],
        ),
      );

      if (needsHScroll) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: _kMinTableWidth,
              height: constraints.maxHeight,
              child: tableBox,
            ),
          ),
        );
      }

      return tableBox;
    });
  }
}

// ─────────────────────────────────────────────────────────────────
// _TableHeader
// ─────────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final bool selectAll;
  final ValueChanged<bool?> onSelectAll;
  final List<double> colWidths;

  const _TableHeader({
    required this.selectAll,
    required this.onSelectAll,
    required this.colWidths,
  });

  @override
  Widget build(BuildContext context) {
    const s = TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: _kCheckboxW,
            child: Checkbox(
              value: selectAll,
              onChanged: onSelectAll,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
          const SizedBox(width: _kGapW),
          const SizedBox(width: _kIdW, child: Text('ID', style: s)),
          SizedBox(
              width: colWidths[0],
              child: const Text('Voucher Number', style: s)),
          SizedBox(width: colWidths[1], child: const Text('Type', style: s)),
          SizedBox(width: colWidths[2], child: const Text('Debit', style: s)),
          SizedBox(width: colWidths[3], child: const Text('Credit', style: s)),
          const SizedBox(
            width: _kActionW,
            child: Text('Action', style: s, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _VoucherRow
// ─────────────────────────────────────────────────────────────────
class _VoucherRow extends StatelessWidget {
  final VoucherData voucher;
  final bool isSelected;
  final ValueChanged<bool?> onSelect;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final List<double> colWidths;

  const _VoucherRow({
    required this.voucher,
    required this.isSelected,
    required this.onSelect,
    required this.onView,
    required this.onDelete,
    required this.colWidths,
  });

  @override
  Widget build(BuildContext context) {
    const s = TextStyle(fontSize: 13, color: Color(0xFF333333));
    return Container(
      color: isSelected ? const Color(0xFFFFF8F0) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: _kCheckboxW,
            child: Checkbox(
              value: isSelected,
              onChanged: onSelect,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              activeColor: const Color(0xFFE8891A),
              side: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
          const SizedBox(width: _kGapW),
          SizedBox(width: _kIdW, child: Text('${voucher.id}', style: s)),
          SizedBox(
            width: colWidths[0],
            child: Text(voucher.voucherNumber ?? 'N/A', style: s),
          ),
          SizedBox(
            width: colWidths[1],
            child: Text(voucher.type ?? 'N/A', style: s),
          ),
          SizedBox(
            width: colWidths[2],
            child: Text(voucher.totalDebit.toStringAsFixed(2), style: s),
          ),
          SizedBox(
            width: colWidths[3],
            child: Text(voucher.totalCredit.toStringAsFixed(2), style: s),
          ),
          SizedBox(
            width: _kActionW,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onView,
                  child: const Icon(Icons.remove_red_eye_outlined,
                      size: 18, color: Color(0xFF888888)),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      size: 18, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _PaginationBar
// ─────────────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

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
              onTap:
                  currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
            const SizedBox(width: 4),
            for (final p in pages) ...[
              if (p == -1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text('…',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                )
              else
                _PagePill(
                  page: p,
                  isActive: p == currentPage,
                  onTap: () => onPageChanged(p),
                ),
              const SizedBox(width: 2),
            ],
            _PageBtn(
              icon: Icons.chevron_right,
              onTap: currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _PagePill
// ─────────────────────────────────────────────────────────────────
class _PagePill extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PagePill({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? const Color(0xFFAAAAAA) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? const Color(0xFF1A1A1A) : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _PageBtn
// ─────────────────────────────────────────────────────────────────
class _PageBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _PageBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 20,
        color:
            onTap == null ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
      ),
    );
  }
}
