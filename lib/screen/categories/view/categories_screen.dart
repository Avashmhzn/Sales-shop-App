import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/category_response.dart';
import 'package:saleup_app/screen/categories/bloc/category_bloc.dart';
import 'package:saleup_app/screen/categories/bloc/category_event.dart';
import 'package:saleup_app/screen/categories/bloc/category_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Set<int> _selectedIds = {};
  bool _showFilter = false;

  static const _orange = Color(0xFFE8891A);

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const FetchCategories());
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
      context
          .read<CategoryBloc>()
          .add(SearchCategories(_searchController.text));
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

  void _toggleSelectAll(List<CategoryData> items, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(items.map((c) => c.id));
      } else {
        _selectedIds.removeAll(items.map((c) => c.id));
      }
    });
  }

  // ─── Delete Single ────────────────────────────────────────────────────────

  Future<void> _deleteCategory(CategoryData category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Category',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete "${category.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9534F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final bloc = context.read<CategoryBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final response = await DioClient().dio.delete(
        '/category/delete_categories/',
        data: {
          'category_ids': [category.id]
        },
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 204) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));
      if (isSuccess) {
        setState(() => _selectedIds.remove(category.id));
        bloc.add(const FetchCategories());
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Category deleted successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception(data is Map
            ? (data['message'] ?? 'Delete failed')
            : 'Delete failed');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Failed to delete: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ─── Delete Selected (bulk) ───────────────────────────────────────────────

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Categories',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Delete ${_selectedIds.length} selected category(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9534F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final bloc = context.read<CategoryBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final response = await DioClient().dio.delete(
        '/category/delete_categories/',
        data: {'category_ids': _selectedIds.toList()},
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 204) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));
      if (isSuccess) {
        setState(() => _selectedIds.clear());
        bloc.add(const FetchCategories());
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Categories deleted successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception(data is Map
            ? (data['message'] ?? 'Delete failed')
            : 'Delete failed');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Failed to delete: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ─── View Dialog ─────────────────────────────────────────────────────────

  void _showViewDialog(CategoryData category) {
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
                  const Text('Category Details',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 4),
              // Two-column detail rows
              _viewRow2(
                  'ID: ${category.id}', 'Name: ${category.name ?? 'N/A'}'),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _viewRow2('Short Code: ${category.shortCode ?? 'N/A'}',
                  'Parent: ${category.parent?.toString() ?? 'None'}'),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    'Description: ${(category.description ?? '').trim().isEmpty ? 'N/A' : category.description}',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewRow2(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              child: Text(left,
                  style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Expanded(
              child: Text(right,
                  style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  // ─── Edit Dialog ──────────────────────────────────────────────────────────

  void _showEditDialog(CategoryData category) {
    final bloc = context.read<CategoryBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // Get all categories for parent dropdown (exclude self)
    final allCategories =
        bloc.state.categories.where((c) => c.id != category.id).toList();

    final nameController = TextEditingController(text: category.name ?? '');
    final descController =
        TextEditingController(text: category.description ?? '');
    bool status = category.status;
    bool isDiscountRestricted = false;
    int? selectedParentId = category.parent;
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
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Edit Categories',
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

                          // ── Category ID + Short Code (read-only display) ──
                          Row(
                            children: [
                              Expanded(
                                child: _editField(
                                  label: 'Category ID',
                                  child: TextFormField(
                                    initialValue: category.id.toString(),
                                    readOnly: true,
                                    style:
                                        const TextStyle(color: Colors.black45),
                                    decoration: _editDeco(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _editField(
                                  label: 'Short Code',
                                  child: TextFormField(
                                    initialValue: category.shortCode ?? '',
                                    readOnly: true,
                                    style:
                                        const TextStyle(color: Colors.black45),
                                    decoration: _editDeco(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Name + Parent (same row) ──
                          Row(
                            children: [
                              Expanded(
                                child: _editField(
                                  label: '* Name',
                                  required: true,
                                  child: TextFormField(
                                    controller: nameController,
                                    decoration: _editDeco(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _editField(
                                  label: 'Parent:',
                                  child: DropdownButtonFormField<int?>(
                                    initialValue: selectedParentId,
                                    decoration: _editDeco(
                                        hint: 'Select an account head'),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('None'),
                                      ),
                                      ...allCategories
                                          .map((c) => DropdownMenuItem<int?>(
                                                value: c.id,
                                                child: Text(
                                                  c.name ?? 'Unnamed',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )),
                                    ],
                                    onChanged: (val) => setDialogState(
                                        () => selectedParentId = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Description ──
                          _editField(
                            label: 'Description',
                            child: TextFormField(
                              controller: descController,
                              maxLines: 4,
                              decoration: _editDeco(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Status ──
                          Row(
                            children: [
                              const Text('Status',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                              const SizedBox(width: 8),
                              Switch(
                                value: status,
                                onChanged: (val) =>
                                    setDialogState(() => status = val),
                                activeThumbColor: _orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // ── Is Discount Restricted ──
                          Row(
                            children: [
                              const Text('Is Discount Restricted',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                              const SizedBox(width: 8),
                              Switch(
                                value: isDiscountRestricted,
                                onChanged: (val) => setDialogState(
                                    () => isDiscountRestricted = val),
                                activeThumbColor: _orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Save Button ──
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                setDialogState(() => isLoading = true);
                                final navigator = Navigator.of(context);
                                try {
                                  final bool nameChanged =
                                      nameController.text.trim() !=
                                          (category.name ?? '');
                                  final bool parentChanged =
                                      selectedParentId != category.parent;
                                  final body = {
                                    if (nameChanged)
                                      'name': nameController.text.trim(),
                                    'description': descController.text.trim(),
                                    'status': status,
                                    'is_discount_restricted':
                                        isDiscountRestricted,
                                    if (parentChanged)
                                      'parent': selectedParentId,
                                  };
                                  debugPrint('PUT body: $body');
                                  final response = await DioClient().dio.put(
                                        '/category/update_category/?category_id=${category.id}',
                                        data: body,
                                      );
                                  debugPrint(
                                      'PUT response [${response.statusCode}]: ${response.data}');
                                  final data = response.data;
                                  final isSuccess =
                                      response.statusCode == 200 &&
                                          (data is Map &&
                                              (data['success'] == true ||
                                                  data['success'] == 'true'));
                                  if (isSuccess) {
                                    navigator.pop();
                                    scaffoldMessenger.showSnackBar(SnackBar(
                                      content: Text(data['message'] ??
                                          'Category updated successfully'),
                                      backgroundColor: Colors.green,
                                    ));
                                    bloc.add(const FetchCategories());
                                  } else {
                                    final msg = data is Map
                                        ? (data['message'] ?? 'Update failed')
                                        : 'Update failed';
                                    scaffoldMessenger.showSnackBar(SnackBar(
                                      content: Text(msg),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                } catch (e) {
                                  final msg = e
                                      .toString()
                                      .replaceFirst('Exception: ', '');
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                    content: Text(msg),
                                    backgroundColor: Colors.red,
                                  ));
                                } finally {
                                  if (context.mounted) {
                                    setDialogState(() => isLoading = false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
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

  // ─── Edit Helpers ─────────────────────────────────────────────────────────

  Widget _editField(
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

  InputDecoration _editDeco({String? hint}) {
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
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
          ));
        }
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
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
            if (mounted) {
              context
                  .read<CategoryBloc>()
                  .add(GoToCategoryPage(validCurrentPage));
            }
          });
        }

        final paginatedData = filteredData.isNotEmpty
            ? filteredData.sublist(
                (validCurrentPage - 1) * state.itemsPerPage,
                ((validCurrentPage - 1) * state.itemsPerPage +
                        state.itemsPerPage)
                    .clamp(0, filteredData.length))
            : <CategoryData>[];

        final allPageSelected = paginatedData.isNotEmpty &&
            paginatedData.every((c) => _selectedIds.contains(c.id));

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + New Button ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Categories',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A))),
                            SizedBox(height: 4),
                            Text(
                                'Organize products into categories for easier filtering and reporting.',
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
                                value: context.read<CategoryBloc>(),
                                child: const AddCategoryScreen(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add,
                            size: 18, color: Colors.white),
                        label: const Text('New Categories',
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

                  // ── Filter panel above table (visible when toggled) ──
                  if (_showFilter)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Filter Categories',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 10),
                          // Build tree: top-level categories + their children
                          ...() {
                            // Separate top-level (no parent) from children
                            final topLevel = state.categories
                                .where((c) => c.parent == null)
                                .toList();
                            final widgets = <Widget>[];

                            for (final cat in topLevel) {
                              final children = state.categories
                                  .where((c) => c.parent == cat.id)
                                  .toList();
                              final isSelected =
                                  state.selectedShortCodeFilter ==
                                      cat.shortCode;
                              final isExpanded =
                                  children.isNotEmpty && isSelected ||
                                      children.any((c) =>
                                          state.selectedShortCodeFilter ==
                                          c.shortCode);

                              // Parent row
                              widgets.add(
                                GestureDetector(
                                  onTap: () => context.read<CategoryBloc>().add(
                                      UpdateCategoryFilter(
                                          isSelected ? 'All' : cat.shortCode)),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            cat.name ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isSelected
                                                  ? _orange
                                                  : Colors.black87,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (children.isNotEmpty)
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            size: 16,
                                            color: Colors.black45,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              // Children (indented), shown when parent selected or child selected
                              if (children.isNotEmpty && isExpanded) {
                                for (final child in children) {
                                  final isChildSelected =
                                      state.selectedShortCodeFilter ==
                                          child.shortCode;
                                  widgets.add(
                                    GestureDetector(
                                      onTap: () => context
                                          .read<CategoryBloc>()
                                          .add(UpdateCategoryFilter(
                                              isChildSelected
                                                  ? 'All'
                                                  : child.shortCode)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, top: 4, bottom: 4),
                                        child: Text(
                                          child.name ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isChildSelected
                                                ? _orange
                                                : Colors.black54,
                                            fontWeight: isChildSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }

                            // Also show orphan categories (those whose parent id
                            // is not in the flat list — edge case)
                            final topLevelIds =
                                topLevel.map((c) => c.id).toSet();
                            final orphans = state.categories
                                .where((c) =>
                                    c.parent != null &&
                                    !topLevelIds.contains(c.parent))
                                .toList();
                            for (final cat in orphans) {
                              final isSelected =
                                  state.selectedShortCodeFilter ==
                                      cat.shortCode;
                              widgets.add(
                                GestureDetector(
                                  onTap: () => context.read<CategoryBloc>().add(
                                      UpdateCategoryFilter(
                                          isSelected ? 'All' : cat.shortCode)),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Text(
                                      cat.name ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isSelected
                                            ? _orange
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return widgets;
                          }(),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => context
                                .read<CategoryBloc>()
                                .add(const ClearCategoryFilters()),
                            child: const Text('Clear Filters',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFD9534F),
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),

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
                            // Table Header
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
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Filter icon toggle
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _showFilter = !_showFilter),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _showFilter
                                            ? const Color(0xFFFFF3E0)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: const Color(0xFFDDDDDD)),
                                      ),
                                      child: Icon(Icons.filter_list,
                                          size: 16,
                                          color: _showFilter
                                              ? _orange
                                              : const Color(0xFF888888)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const SizedBox(
                                      width: 60,
                                      child: Text('ID',
                                          style: _headerStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 160,
                                      child: Text('Name',
                                          style: _headerStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 120,
                                      child: Text('Short Code',
                                          style: _headerStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 100,
                                      child: Text('Parent',
                                          style: _headerStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 110,
                                      child: Text('Action',
                                          style: _headerStyle,
                                          textAlign: TextAlign.center)),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),

                            // Loading
                            if (state.isLoading)
                              const Padding(
                                padding: EdgeInsets.all(48),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )

                            // Empty
                            else if (paginatedData.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(48),
                                child: Center(
                                    child: Text('No categories found',
                                        style: TextStyle(
                                            color: Color(0xFF888888)))),
                              )

                            // Rows
                            else
                              ...paginatedData.map((category) {
                                final isSelected =
                                    _selectedIds.contains(category.id);
                                return Column(
                                  children: [
                                    Container(
                                      height: 60,
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
                                                  _toggleSelect(category.id, v),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: 48),
                                          SizedBox(
                                            width: 60,
                                            child: Text('${category.id}',
                                                style: _rowStyle,
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            width: 160,
                                            child: Text(category.name ?? 'N/A',
                                                style: _rowStyle,
                                                textAlign: TextAlign.center,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                                category.shortCode ?? 'N/A',
                                                style: _rowStyle,
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                                category.parent == null
                                                    ? 'None'
                                                    : (state.categories
                                                            .where((c) =>
                                                                c.id ==
                                                                category.parent)
                                                            .isNotEmpty
                                                        ? state.categories
                                                                .firstWhere((c) =>
                                                                    c.id ==
                                                                    category
                                                                        .parent)
                                                                .name ??
                                                            'None'
                                                        : category.parent
                                                            .toString()),
                                                style: _rowStyle,
                                                textAlign: TextAlign.center,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          SizedBox(
                                            width: 110,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _showEditDialog(category),
                                                  child: const Icon(
                                                      Icons.edit_outlined,
                                                      size: 17,
                                                      color: Color(0xFF888888)),
                                                ),
                                                const SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _showViewDialog(category),
                                                  child: const Icon(
                                                      Icons
                                                          .remove_red_eye_outlined,
                                                      size: 17,
                                                      color: Color(0xFF888888)),
                                                ),
                                                const SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _deleteCategory(category),
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

                  // ── Pagination — always visible ──
                  if (!state.isLoading)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: validCurrentPage > 1
                                ? () => context
                                    .read<CategoryBloc>()
                                    .add(GoToCategoryPage(validCurrentPage - 1))
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
                                    .read<CategoryBloc>()
                                    .add(GoToCategoryPage(validCurrentPage + 1))
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

  static const _headerStyle = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555));
  static const _rowStyle = TextStyle(fontSize: 13, color: Color(0xFF333333));
}

// ─── Add Category Screen ──────────────────────────────────────────────────────

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _status = true;
  bool _isDiscountRestricted = false;
  bool _isSubCategory = false;
  bool _isLoading = false;
  int? _selectedParentId;

  static const _orange = Color(0xFFE8891A);

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<CategoryBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final response = await DioClient().dio.post(
        '/category/create_category/',
        data: {
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'status': _status,
          'is_discount_restricted': _isDiscountRestricted,
          if (_selectedParentId != null) 'parent': _selectedParentId,
        },
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 201) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));
      if (isSuccess) {
        bloc.add(const FetchCategories());
        navigator.pop();
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Category created successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception(data is Map
            ? (data['message'] ?? 'Create failed')
            : 'Create failed');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Failed to create: $e'),
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
                        Text('Add Category',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('Create a new product category.',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Row 1: Name + Parent (same row as original design)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildField(
                        label: '* Name:',
                        required: true,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: _inputDeco(hint: 'Name'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildField(
                        label: 'Parent:',
                        child: DropdownButtonFormField<int?>(
                          initialValue: _selectedParentId,
                          decoration:
                              _inputDeco(hint: 'Select an account head'),
                          isExpanded: true,
                          // ✅ disabled when Is Sub Category is OFF
                          onChanged: _isSubCategory
                              ? (val) => setState(() => _selectedParentId = val)
                              : null,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('None'),
                            ),
                            ...context
                                .read<CategoryBloc>()
                                .state
                                .categories
                                .map((c) => DropdownMenuItem<int?>(
                                      value: c.id,
                                      child: Text(
                                        c.name ?? 'Unnamed',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description (left half only)
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: _buildField(
                    label: 'Description :',
                    child: TextFormField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: _inputDeco(hint: 'Enter Description'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Status + Is Discount Restricted + Is Sub Category toggles
                Row(
                  children: [
                    _buildToggle(
                        'Status:', _status, (v) => setState(() => _status = v)),
                    const SizedBox(width: 28),
                    _buildToggle(
                        'Is Discount Restricted:',
                        _isDiscountRestricted,
                        (v) => setState(() => _isDiscountRestricted = v)),
                    const SizedBox(width: 28),
                    _buildToggle(
                        'Is Sub Category:',
                        _isSubCategory,
                        (v) => setState(() {
                              _isSubCategory = v;
                              if (!v) _selectedParentId = null;
                            })),
                  ],
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

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget _buildField(
      {required String label, required Widget child, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: required ? _orange : Colors.black87)),
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
