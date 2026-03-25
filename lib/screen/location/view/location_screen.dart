// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/location/bloc/location_bloc.dart';
// import 'package:saleup_app/screen/location/bloc/location_event.dart';
// import 'package:saleup_app/screen/location/bloc/location_state.dart';
// import 'package:saleup_app/screen/location/widget/location_card.dart';

// class LocationsScreen extends StatefulWidget {
//   const LocationsScreen({super.key});

//   @override
//   State<LocationsScreen> createState() => _LocationsScreenState();
// }

// class _LocationsScreenState extends State<LocationsScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     // Trigger FetchLocations immediately when the screen is initialized
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       print('Initiating FetchLocations in initState');
//       context.read<LocationBloc>().add(const FetchLocations());
//     });
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
//       context.read<LocationBloc>().add(SearchLocations(query));
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

//     return BlocConsumer<LocationBloc, LocationState>(
//       listener: (context, state) {
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage!),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//         print('State updated: '
//             'isLoading=${state.isLoading}, '
//             'locationsLength=${state.locations.length}, '
//             'filteredDataLength=${state.getFilteredData().length}');
//         if (_searchController.text != state.searchQuery) {
//           _searchController.text = state.searchQuery;
//           _searchController.selection = TextSelection.fromPosition(
//             TextPosition(offset: _searchController.text.length),
//           );
//         }
//       },
//       builder: (context, state) {
//         final filteredData = state.getFilteredData();
//         print(
//             'Rendering with filteredData: ${filteredData.map((l) => l.name).toList()}');
//         final totalPages = filteredData.isNotEmpty
//             ? (filteredData.length / state.itemsPerPage).ceil()
//             : 1;
//         final validCurrentPage = state.currentPage.clamp(1, totalPages);
//         if (validCurrentPage != state.currentPage) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             print(
//                 'Correcting currentPage from ${state.currentPage} to $validCurrentPage');
//             context.read<LocationBloc>().add(GoToPage(validCurrentPage));
//           });
//         }
//         final paginatedData = filteredData.isNotEmpty
//             ? filteredData.sublist(
//                 (validCurrentPage - 1) * state.itemsPerPage,
//                 ((validCurrentPage - 1) * state.itemsPerPage +
//                         state.itemsPerPage)
//                     .clamp(0, filteredData.length))
//             : [];

//         print('Building UI with: '
//             'paginatedDataLength=${paginatedData.length}, '
//             'totalPages=$totalPages, '
//             'currentPage=${state.currentPage}, '
//             'validCurrentPage=$validCurrentPage');

//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.02),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Locations Management",
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
//                               ? const Center(child: Text("No locations found"))
//                               : ListView.builder(
//                                   key: ValueKey(
//                                       '${state.locations.length}_${validCurrentPage}_${state.searchQuery}'),
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: paginatedData.length,
//                                   itemBuilder: (context, index) {
//                                     print(
//                                         'Rendering card for: ${paginatedData[index].name}');
//                                     return LocationCard(
//                                       location: paginatedData[index],
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
//                                         .read<LocationBloc>()
//                                         .add(const GoToPage(1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_back),
//                                 onPressed: validCurrentPage > 1
//                                     ? () => context
//                                         .read<LocationBloc>()
//                                         .add(GoToPage(validCurrentPage - 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             Text('$validCurrentPage of $totalPages'),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_forward),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<LocationBloc>()
//                                         .add(GoToPage(validCurrentPage + 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.last_page),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<LocationBloc>()
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
import 'package:saleup_app/model/location_response.dart';
import 'package:saleup_app/screen/location/bloc/location_bloc.dart';
import 'package:saleup_app/screen/location/bloc/location_event.dart';
import 'package:saleup_app/screen/location/bloc/location_state.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Set<int> _selectedIds = {};

  static const _orange = Color(0xFFE8891A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(const FetchLocations());
    });
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
      context.read<LocationBloc>().add(SearchLocations(_searchController.text));
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

  void _toggleSelectAll(List<LocationData> items, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(items.map((l) => l.id));
      } else {
        _selectedIds.removeAll(items.map((l) => l.id));
      }
    });
  }

  // ─── Delete Single ────────────────────────────────────────────────────────

  Future<void> _deleteLocation(LocationData location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Location',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete "${location.name}"? This cannot be undone.'),
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

    final bloc = context.read<LocationBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final response = await DioClient().dio.delete(
        '/location/delete_locations/',
        data: {
          'location_ids': [location.id]
        },
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 204) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));

      if (isSuccess) {
        setState(() => _selectedIds.remove(location.id));
        bloc.add(const FetchLocations());
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Location deleted successfully'),
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
        title: const Text('Delete Locations',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete ${_selectedIds.length} selected location(s)?'),
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

    final bloc = context.read<LocationBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final ids = _selectedIds.toList();

    try {
      final response = await DioClient().dio.delete(
        '/location/delete_locations/',
        data: {'location_ids': ids},
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 204) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));

      if (isSuccess) {
        setState(() => _selectedIds.clear());
        bloc.add(const FetchLocations());
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Locations deleted successfully'),
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

  // ─── Edit Dialog ──────────────────────────────────────────────────────────

  void _showEditDialog(LocationData location) {
    final bloc = context.read<LocationBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final nameController = TextEditingController(text: location.name);
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 500.0;

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
                            const Text('Edit Account',
                                style: TextStyle(
                                    fontSize: 17,
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

                        // Row: Location ID (read-only) + Name
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: '* Location ID',
                                child: TextFormField(
                                  initialValue:
                                      location.code ?? location.id.toString(),
                                  readOnly: true,
                                  style: const TextStyle(color: Colors.black45),
                                  decoration: _inputDeco(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildField(
                                label: '* Name',
                                child: TextFormField(
                                  controller: nameController,
                                  decoration: _inputDeco(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setDialogState(() => isLoading = true);
                              final navigator = Navigator.of(context);

                              try {
                                final response = await DioClient().dio.put(
                                  '/location/update_location/?location_id=${location.id}',
                                  data: {
                                    'name': nameController.text.trim(),
                                    'code': location.code,
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
                                        'Location updated successfully'),
                                    backgroundColor: Colors.green,
                                  ));
                                  bloc.add(const FetchLocations());
                                } else {
                                  throw Exception(data is Map
                                      ? (data['message'] ?? 'Update failed')
                                      : 'Update failed');
                                }
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(SnackBar(
                                  content: Text('Failed to update: $e'),
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

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _orange)),
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
    return BlocConsumer<LocationBloc, LocationState>(
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
            context.read<LocationBloc>().add(GoToPage(validCurrentPage));
          });
        }

        final paginatedData = filteredData.isNotEmpty
            ? filteredData.sublist(
                (validCurrentPage - 1) * state.itemsPerPage,
                ((validCurrentPage - 1) * state.itemsPerPage +
                        state.itemsPerPage)
                    .clamp(0, filteredData.length))
            : <LocationData>[];

        final allPageSelected = paginatedData.isNotEmpty &&
            paginatedData.every((l) => _selectedIds.contains(l.id));

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ──
                  const Text('Locations',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 4),
                  Text('Manage store or warehouse locations.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 16),

                  // ── Search + New Location ──
                  Row(
                    children: [
                      // Search
                      Container(
                        width: 200,
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
                      // New Location button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<LocationBloc>(),
                                child: const AddLocationScreen(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add,
                            size: 18, color: Colors.white),
                        label: const Text('New Location',
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
                  const SizedBox(height: 8),

                  // ── Delete All ──
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
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
                  ),
                  const SizedBox(height: 8),

                  // ── Table ──
                  Container(
                    width: 700,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                child: Checkbox(
                                  value: allPageSelected,
                                  onChanged: (v) =>
                                      _toggleSelectAll(paginatedData, v),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const SizedBox(
                                  width: 50,
                                  child: Text('ID',
                                      style: _headerStyle,
                                      textAlign: TextAlign.center)),
                              const Expanded(
                                  child: Text('Location ID',
                                      style: _headerStyle,
                                      textAlign: TextAlign.center)),
                              const Expanded(
                                  child: Text('Name',
                                      style: _headerStyle,
                                      textAlign: TextAlign.center)),
                              const SizedBox(
                                  width: 100,
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
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator()),
                          )

                        // Empty
                        else if (paginatedData.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: Text('No locations found')),
                          )

                        // Rows
                        else
                          ...paginatedData.map((location) {
                            final isSelected =
                                _selectedIds.contains(location.id);
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
                                        width: 20,
                                        child: Checkbox(
                                          value: isSelected,
                                          onChanged: (v) =>
                                              _toggleSelect(location.id, v),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 50,
                                        child: Text('${location.id}',
                                            style: _rowStyle,
                                            textAlign: TextAlign.center),
                                      ),
                                      Expanded(
                                        child: Text(location.code ?? 'N/A',
                                            style: _rowStyle,
                                            textAlign: TextAlign.center),
                                      ),
                                      Expanded(
                                        child: Text(location.name,
                                            style: _rowStyle,
                                            textAlign: TextAlign.center),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Edit
                                            GestureDetector(
                                              onTap: () =>
                                                  _showEditDialog(location),
                                              child: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 16,
                                                  color: Color(0xFF888888)),
                                            ),
                                            const SizedBox(width: 12),
                                            // View
                                            GestureDetector(
                                              onTap: () =>
                                                  _showViewDialog(location),
                                              child: const Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  size: 16,
                                                  color: Color(0xFF888888)),
                                            ),
                                            const SizedBox(width: 12),
                                            // Delete
                                            GestureDetector(
                                              onTap: () =>
                                                  _deleteLocation(location),
                                              child: const Icon(
                                                  Icons.delete_outline,
                                                  size: 16,
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
                  const SizedBox(height: 16),

                  // ── Pagination ──
                  if (!state.isLoading && totalPages > 1)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: validCurrentPage > 1
                                ? () => context
                                    .read<LocationBloc>()
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
                                    .read<LocationBloc>()
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

  // ─── View Dialog ─────────────────────────────────────────────────────────

  void _showViewDialog(LocationData location) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Location Details',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              _viewRow('ID', location.id.toString()),
              _viewRow('Location ID', location.code ?? 'N/A'),
              _viewRow('Name', location.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87))),
          Expanded(
              child:
                  Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555));

  static const _rowStyle = TextStyle(fontSize: 13, color: Color(0xFF333333));
}

// ─── Add Location Screen ──────────────────────────────────────────────────────

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  static const _orange = Color(0xFFE8891A);

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<LocationBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final response = await DioClient().dio.post(
        '/location/create_location/',
        data: {
          'name': _nameController.text.trim(),
          'code': _codeController.text.trim(),
        },
      );

      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 201) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));

      if (isSuccess) {
        bloc.add(const FetchLocations());
        navigator.pop();
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Location created successfully'),
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
                        Text('Add Locations',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('Add a new store or warehouse location',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Row: Name + Code
                LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth < 500) {
                    return Column(
                      children: [
                        _buildField(
                          label: '* Name:',
                          child: TextFormField(
                            controller: _nameController,
                            decoration: _inputDeco(hint: 'Enter Location name'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: '* Code:',
                          child: TextFormField(
                            controller: _codeController,
                            decoration: _inputDeco(hint: 'Enter Location code'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Code is required'
                                : null,
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          label: '* Name:',
                          child: TextFormField(
                            controller: _nameController,
                            decoration: _inputDeco(hint: 'Enter Location name'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildField(
                          label: '* Code:',
                          child: TextFormField(
                            controller: _codeController,
                            decoration: _inputDeco(hint: 'Enter Location code'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Code is required'
                                : null,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
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
