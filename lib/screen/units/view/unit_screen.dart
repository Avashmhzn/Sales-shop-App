// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/units/bloc/unit_bloc.dart';
// import 'package:saleup_app/screen/units/bloc/unit_event.dart';
// import 'package:saleup_app/screen/units/bloc/unit_state.dart';
// import 'package:saleup_app/screen/units/widget/unit_card.dart';

// class UnitsScreen extends StatefulWidget {
//   const UnitsScreen({super.key});

//   @override
//   State<UnitsScreen> createState() => _UnitsScreenState();
// }

// class _UnitsScreenState extends State<UnitsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     context.read<UnitBloc>().add(const FetchUnits());
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       context.read<UnitBloc>().add(SearchUnits(query));
//     });
//   }

//   Widget _buildSkeletonLoader(double screenWidth, double screenHeight) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 5,
//       itemBuilder: (context, index) => Padding(
//         padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 12),
//         child: Container(
//           height: 100,
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return BlocConsumer<UnitBloc, UnitState>(
//       listener: (context, state) {
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage!),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         final filteredData = state.getFilteredData();
//         final totalPages = filteredData.isNotEmpty
//             ? (filteredData.length / state.itemsPerPage).ceil()
//             : 1;
//         final validCurrentPage = state.currentPage.clamp(1, totalPages);
//         if (validCurrentPage != state.currentPage) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             context.read<UnitBloc>().add(GoToPage(validCurrentPage));
//           });
//         }
//         final paginatedData = filteredData.isNotEmpty
//             ? filteredData.sublist(
//                 (validCurrentPage - 1) * state.itemsPerPage,
//                 ((validCurrentPage - 1) * state.itemsPerPage +
//                         state.itemsPerPage)
//                     .clamp(0, filteredData.length))
//             : [];

//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.02),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Units Management",
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.05,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     Padding(
//                       padding: EdgeInsets.all(screenWidth * 0.02),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: SizedBox(
//                                   height: 60,
//                                   child: TextField(
//                                     controller: _searchController,
//                                     decoration: InputDecoration(
//                                       labelText: 'Search Here',
//                                       prefixIcon: const Icon(Icons.search),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                         vertical: 10,
//                                         horizontal: 12,
//                                       ),
//                                     ),
//                                     onChanged: _onSearchChanged,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       width: screenWidth,
//                       child: state.isLoading
//                           ? _buildSkeletonLoader(screenWidth, screenHeight)
//                           : paginatedData.isEmpty
//                               ? const Center(child: Text("No units found"))
//                               : ListView.builder(
//                                   key: ValueKey(
//                                       '${state.units.length}_${validCurrentPage}_${state.searchQuery}'),
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: paginatedData.length,
//                                   itemBuilder: (context, index) {
//                                     return UnitCard(
//                                       unit: paginatedData[index],
//                                       screenWidth: screenWidth,
//                                       screenHeight: screenHeight,
//                                     );
//                                   },
//                                 ),
//                     ),
//                     if (!state.isLoading && totalPages > 1)
//                       Padding(
//                         padding: EdgeInsets.all(screenWidth * 0.02),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                                 icon: const Icon(Icons.first_page),
//                                 onPressed: validCurrentPage > 1
//                                     ? () => context
//                                         .read<UnitBloc>()
//                                         .add(const GoToPage(1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_back),
//                                 onPressed: validCurrentPage > 1
//                                     ? () => context
//                                         .read<UnitBloc>()
//                                         .add(GoToPage(validCurrentPage - 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             Text('$validCurrentPage of $totalPages'),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_forward),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<UnitBloc>()
//                                         .add(GoToPage(validCurrentPage + 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.last_page),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<UnitBloc>()
//                                         .add(GoToPage(totalPages))
//                                     : null),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/unit_response.dart';
import 'package:saleup_app/screen/units/bloc/unit_bloc.dart';
import 'package:saleup_app/screen/units/bloc/unit_event.dart';
import 'package:saleup_app/screen/units/bloc/unit_state.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Set<int> _selectedIds = {};

  static const _orange = Color(0xFFE8891A);

  @override
  void initState() {
    super.initState();
    context.read<UnitBloc>().add(const FetchUnits());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<UnitBloc>().add(SearchUnits(_searchController.text));
    });
  }

  void _toggleSelect(int id, bool? value) {
    setState(() {
      if (value == true)
        _selectedIds.add(id);
      else
        _selectedIds.remove(id);
    });
  }

  void _toggleSelectAll(List<UnitData> items, bool? value) {
    setState(() {
      if (value == true)
        _selectedIds.addAll(items.map((u) => u.id));
      else
        _selectedIds.removeAll(items.map((u) => u.id));
    });
  }

  // ─── Delete Single ────────────────────────────────────────────────────────
  Future<void> _deleteUnit(UnitData unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Unit',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${unit.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9534F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final bloc = context.read<UnitBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final response = await DioClient().dio.delete(
        '/unit/delete_units/',
        data: {
          'unit_ids': [unit.id]
        }, // ← Backend requires this exact key + array
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 204) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));

      if (isSuccess) {
        setState(() => _selectedIds.remove(unit.id));
        bloc.add(const FetchUnits());
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(data['message'] ?? 'Unit deleted successfully'),
            backgroundColor: Colors.green));
      } else {
        throw Exception(data is Map
            ? (data['message'] ?? 'Delete failed')
            : 'Delete failed');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red));
    }
  }

  // ─── Delete Selected ─────────────────────────────────────────────────────
  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Units',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Delete ${_selectedIds.length} selected unit(s)?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9534F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final bloc = context.read<UnitBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final response = await DioClient().dio.delete(
        '/unit/delete_units/',
        data: {
          'unit_ids': _selectedIds.toList()
        }, // ← Backend requires this exact key + array
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 204) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));

      if (isSuccess) {
        setState(() => _selectedIds.clear());
        bloc.add(const FetchUnits());
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(data['message'] ?? 'Units deleted successfully'),
            backgroundColor: Colors.green));
      } else {
        throw Exception(data is Map
            ? (data['message'] ?? 'Delete failed')
            : 'Delete failed');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red));
    }
  }

  // ─── View Dialog ─────────────────────────────────────────────────────────

  void _showViewDialog(UnitData unit) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Unit Details',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              // Row: Unit ID + Name
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: Text('Unit ID: ${unit.id}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87))),
                    Expanded(
                        child: Text('Name: ${unit.name}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87))),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Description: ${(unit.description ?? '').trim().isEmpty ? 'N/A' : unit.description}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Edit Dialog ─────────────────────────────────────────────────────────

  void _showEditDialog(UnitData unit) {
    final bloc = context.read<UnitBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final nameController = TextEditingController(text: unit.name);
    final descController = TextEditingController(text: unit.description ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 440.0;

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: isLoading
                  ? const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Edit Unit',
                                style: TextStyle(
                                    fontSize: 16,
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
                        const SizedBox(height: 16),

                        // Row: Unit ID (readonly) + Name
                        Row(
                          children: [
                            Expanded(
                                child: _field(
                              label: 'Unit ID',
                              child: TextFormField(
                                initialValue: unit.id.toString(),
                                readOnly: true,
                                style: const TextStyle(color: Colors.black45),
                                decoration: _deco(),
                              ),
                            )),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _field(
                              label: '* Name',
                              required: true,
                              child: TextFormField(
                                controller: nameController,
                                decoration: _deco(),
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        _field(
                          label: 'Description',
                          child: TextFormField(
                            controller: descController,
                            maxLines: 3,
                            decoration: _deco(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setDialogState(() => isLoading = true);
                              final navigator = Navigator.of(context);
                              try {
                                final response = await DioClient().dio.put(
                                  '/unit/update_unit/?unit_id=${unit.id}',
                                  data: {
                                    'name': nameController.text.trim(),
                                    'description': descController.text.trim(),
                                  },
                                );
                                final data = response.data;
                                final isSuccess = response.statusCode == 200 &&
                                    (data is Map &&
                                        (data['success'] == true ||
                                            data['success'] == 'true'));
                                if (isSuccess) {
                                  navigator.pop();
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                    content: Text(data['message'] ??
                                        'Unit updated successfully'),
                                    backgroundColor: Colors.green,
                                  ));
                                  bloc.add(const FetchUnits());
                                } else {
                                  final msg = data is Map
                                      ? (data['message'] ?? 'Update failed')
                                      : 'Update failed';
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                      content: Text(msg),
                                      backgroundColor: Colors.red));
                                }
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(SnackBar(
                                  content: Text(e
                                      .toString()
                                      .replaceFirst('Exception: ', '')),
                                  backgroundColor: Colors.red,
                                ));
                              } finally {
                                if (context.mounted)
                                  setDialogState(() => isLoading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Save Changes',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
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

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _field(
      {required String label, required Widget child, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: required ? _orange : Colors.black87)),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  InputDecoration _deco({String? hint}) {
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
          borderSide: const BorderSide(color: _orange, width: 1.5)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UnitBloc, UnitState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
          ));
        }
      },
      builder: (context, state) {
        final filteredData = state.getFilteredData();
        final totalPages = filteredData.isNotEmpty
            ? (filteredData.length / state.itemsPerPage).ceil()
            : 1;
        final validCurrentPage = state.currentPage.clamp(1, totalPages);

        if (validCurrentPage != state.currentPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted)
              context.read<UnitBloc>().add(GoToPage(validCurrentPage));
          });
        }

        final paginatedData = filteredData.isNotEmpty
            ? filteredData.sublist(
                (validCurrentPage - 1) * state.itemsPerPage,
                ((validCurrentPage - 1) * state.itemsPerPage +
                        state.itemsPerPage)
                    .clamp(0, filteredData.length))
            : <UnitData>[];

        final allPageSelected = paginatedData.isNotEmpty &&
            paginatedData.every((u) => _selectedIds.contains(u.id));

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + New Button ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Units',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A))),
                            SizedBox(height: 4),
                            Text(
                                'Manage units of measurement for your products.',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF777777))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<UnitBloc>(),
                                child: const AddUnitScreen(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add,
                            size: 18, color: Colors.white),
                        label: const Text('New Unit',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Search + Delete All ──
                  Row(
                    children: [
                      Container(
                        width: 220,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                                color: Color(0xFFAAAAAA), fontSize: 13),
                            prefixIcon: Icon(Icons.search,
                                color: Color(0xFFAAAAAA), size: 18),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed:
                            _selectedIds.isEmpty ? null : _deleteSelected,
                        icon: Icon(Icons.delete_outline,
                            size: 16,
                            color: _selectedIds.isEmpty
                                ? Colors.grey
                                : const Color(0xFFD9534F)),
                        label: Text('Delete All',
                            style: TextStyle(
                                fontSize: 13,
                                color: _selectedIds.isEmpty
                                    ? Colors.grey
                                    : const Color(0xFFD9534F))),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero, minimumSize: Size.zero),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Table ──
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 40,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10)),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 32,
                                      child: Checkbox(
                                        value: allPageSelected,
                                        onChanged: (v) =>
                                            _toggleSelectAll(paginatedData, v),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      )),
                                  const SizedBox(width: 8),
                                  const SizedBox(
                                      width: 80,
                                      child: Text('ID',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 160,
                                      child: Text('Name',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 110,
                                      child: Text('Action',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),

                            if (state.isLoading)
                              const Padding(
                                  padding: EdgeInsets.all(48),
                                  child: Center(
                                      child: CircularProgressIndicator()))
                            else if (paginatedData.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(48),
                                child: Center(
                                    child: Text('No units found',
                                        style: TextStyle(
                                            color: Color(0xFF888888)))),
                              )
                            else
                              ...paginatedData.map((unit) {
                                final isSelected =
                                    _selectedIds.contains(unit.id);
                                return Column(
                                  children: [
                                    Container(
                                      height: 56,
                                      color: isSelected
                                          ? const Color(0xFFFFF8F0)
                                          : Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                              width: 32,
                                              child: Checkbox(
                                                value: isSelected,
                                                onChanged: (v) =>
                                                    _toggleSelect(unit.id, v),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              )),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                              width: 80,
                                              child: Text('${unit.id}',
                                                  style: _rStyle,
                                                  textAlign: TextAlign.center)),
                                          SizedBox(
                                              width: 160,
                                              child: Text(unit.name,
                                                  style: _rStyle,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                          SizedBox(
                                            width: 110,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _showEditDialog(unit),
                                                  child: const Icon(
                                                      Icons.edit_outlined,
                                                      size: 17,
                                                      color: Color(0xFF888888)),
                                                ),
                                                const SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _showViewDialog(unit),
                                                  child: const Icon(
                                                      Icons
                                                          .remove_red_eye_outlined,
                                                      size: 17,
                                                      color: Color(0xFF888888)),
                                                ),
                                                const SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _deleteUnit(unit),
                                                  child: const Icon(
                                                      Icons.delete_outline,
                                                      size: 17,
                                                      color: Color(0xFFD9534F)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFEEEEEE)),
                                  ],
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Pagination (always visible) ──
                  if (!state.isLoading)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: validCurrentPage > 1
                                ? () => context
                                    .read<UnitBloc>()
                                    .add(GoToPage(validCurrentPage - 1))
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFAAAAAA)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('$validCurrentPage',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: validCurrentPage < totalPages
                                ? () => context
                                    .read<UnitBloc>()
                                    .add(GoToPage(validCurrentPage + 1))
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static const _hStyle = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555));
  static const _rStyle = TextStyle(fontSize: 13, color: Color(0xFF333333));
}

// ─── Add Unit Screen ──────────────────────────────────────────────────────────

class AddUnitScreen extends StatefulWidget {
  const AddUnitScreen({super.key});

  @override
  State<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends State<AddUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  static const _orange = Color(0xFFE8891A);

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<UnitBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final response = await DioClient().dio.post(
        '/unit/create_unit/',
        data: {
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
        },
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 201) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));
      if (isSuccess) {
        bloc.add(const FetchUnits());
        navigator.pop();
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Unit created successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception(data is Map
            ? (data['message'] ?? 'Create failed')
            : 'Create failed');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ));
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
                // Header
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
                        Text('Add Unit',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('Add a new unit of measurement.',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Name
                _buildField(
                  label: '* Name:',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: _inputDeco(hint: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                _buildField(
                  label: 'Description :',
                  child: TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: _inputDeco(hint: 'Enter Description'),
                  ),
                ),
                const SizedBox(height: 28),

                // Add Button
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.black54,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black54))
                        : const Text('Add',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: _orange)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _orange, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
