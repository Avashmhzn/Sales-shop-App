// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/location_response.dart';
// import 'package:saleup_app/screen/location/bloc/location_bloc.dart';
// import 'package:saleup_app/screen/location/bloc/location_event.dart';
// import 'package:saleup_app/screen/location/bloc/location_state.dart';

// class LocationsScreen extends StatefulWidget {
//   const LocationsScreen({super.key});

//   @override
//   State<LocationsScreen> createState() => _LocationsScreenState();
// }

// class _LocationsScreenState extends State<LocationsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   final Set<int> _selectedIds = {};

//   static const _orange = Color(0xFFE8891A);

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<LocationBloc>().add(const FetchLocations());
//     });
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       context.read<LocationBloc>().add(SearchLocations(_searchController.text));
//     });
//   }

//   void _toggleSelect(int id, bool? value) {
//     setState(() {
//       if (value == true) {
//         _selectedIds.add(id);
//       } else {
//         _selectedIds.remove(id);
//       }
//     });
//   }

//   void _toggleSelectAll(List<LocationData> items, bool? value) {
//     setState(() {
//       if (value == true) {
//         _selectedIds.addAll(items.map((l) => l.id));
//       } else {
//         _selectedIds.removeAll(items.map((l) => l.id));
//       }
//     });
//   }

//   // ─── Delete Single ────────────────────────────────────────────────────────

//   Future<void> _deleteLocation(LocationData location) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Delete Location',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Text(
//             'Are you sure you want to delete "${location.name}"? This cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child:
//                 const Text('Cancel', style: TextStyle(color: Colors.black54)),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFD9534F),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     final bloc = context.read<LocationBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     try {
//       final response = await DioClient().dio.delete(
//         '/location/delete_locations/',
//         data: {
//           'location_ids': [location.id]
//         },
//       );
//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 204) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));

//       if (isSuccess) {
//         setState(() => _selectedIds.remove(location.id));
//         bloc.add(const FetchLocations());
//         scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(data['message'] ?? 'Location deleted successfully'),
//           backgroundColor: Colors.green,
//         ));
//       } else {
//         throw Exception(data is Map
//             ? (data['message'] ?? 'Delete failed')
//             : 'Delete failed');
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(SnackBar(
//         content: Text('Failed to delete: $e'),
//         backgroundColor: Colors.red,
//       ));
//     }
//   }

//   // ─── Delete Selected (bulk) ───────────────────────────────────────────────

//   Future<void> _deleteSelected() async {
//     if (_selectedIds.isEmpty) return;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Delete Locations',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Text(
//             'Are you sure you want to delete ${_selectedIds.length} selected location(s)?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child:
//                 const Text('Cancel', style: TextStyle(color: Colors.black54)),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFD9534F),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     final bloc = context.read<LocationBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final ids = _selectedIds.toList();

//     try {
//       final response = await DioClient().dio.delete(
//         '/location/delete_locations/',
//         data: {'location_ids': ids},
//       );
//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 204) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));

//       if (isSuccess) {
//         setState(() => _selectedIds.clear());
//         bloc.add(const FetchLocations());
//         scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(data['message'] ?? 'Locations deleted successfully'),
//           backgroundColor: Colors.green,
//         ));
//       } else {
//         throw Exception(data is Map
//             ? (data['message'] ?? 'Delete failed')
//             : 'Delete failed');
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(SnackBar(
//         content: Text('Failed to delete: $e'),
//         backgroundColor: Colors.red,
//       ));
//     }
//   }

//   // ─── Edit Dialog ──────────────────────────────────────────────────────────

//   void _showEditDialog(LocationData location) {
//     final bloc = context.read<LocationBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final nameController = TextEditingController(text: location.name);
//     bool isLoading = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 500.0;

//           return Dialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             backgroundColor: Colors.white,
//             insetPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//             child: Container(
//               width: dialogWidth,
//               padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
//               child: isLoading
//                   ? const SizedBox(
//                       height: 160,
//                       child: Center(child: CircularProgressIndicator()))
//                   : Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('Edit Account',
//                                 style: TextStyle(
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87)),
//                             GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child: const Icon(Icons.close,
//                                   color: Colors.black54, size: 20),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         const Divider(height: 1, color: Color(0xFFEEEEEE)),
//                         const SizedBox(height: 20),

//                         // Row: Location ID (read-only) + Name
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildField(
//                                 label: '* Location ID',
//                                 child: TextFormField(
//                                   initialValue:
//                                       location.code ?? location.id.toString(),
//                                   readOnly: true,
//                                   style: const TextStyle(color: Colors.black45),
//                                   decoration: _inputDeco(),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildField(
//                                 label: '* Name',
//                                 child: TextFormField(
//                                   controller: nameController,
//                                   decoration: _inputDeco(),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),

//                         // Save Button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               setDialogState(() => isLoading = true);
//                               final navigator = Navigator.of(context);

//                               try {
//                                 final response = await DioClient().dio.put(
//                                   '/location/update_location/?location_id=${location.id}',
//                                   data: {
//                                     'name': nameController.text.trim(),
//                                     'code': location.code,
//                                   },
//                                 );
//                                 final data = response.data;
//                                 final isSuccess = response.statusCode == 200 &&
//                                     (data is Map &&
//                                         (data['success'] == true ||
//                                             data['success'] == 'true'));

//                                 if (isSuccess) {
//                                   navigator.pop();
//                                   scaffoldMessenger.showSnackBar(SnackBar(
//                                     content: Text(data['message'] ??
//                                         'Location updated successfully'),
//                                     backgroundColor: Colors.green,
//                                   ));
//                                   bloc.add(const FetchLocations());
//                                 } else {
//                                   throw Exception(data is Map
//                                       ? (data['message'] ?? 'Update failed')
//                                       : 'Update failed');
//                                 }
//                               } catch (e) {
//                                 scaffoldMessenger.showSnackBar(SnackBar(
//                                   content: Text('Failed to update: $e'),
//                                   backgroundColor: Colors.red,
//                                 ));
//                               } finally {
//                                 if (context.mounted) {
//                                   setDialogState(() => isLoading = false);
//                                 }
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _orange,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                             ),
//                             child: const Text('Save Changes',
//                                 style: TextStyle(
//                                     fontSize: 15, fontWeight: FontWeight.w600)),
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ─── Helpers ─────────────────────────────────────────────────────────────

//   Widget _buildField({required String label, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 12, fontWeight: FontWeight.w600, color: _orange)),
//         const SizedBox(height: 6),
//         child,
//       ],
//     );
//   }

//   InputDecoration _inputDeco({String? hint}) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
//       enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: _orange, width: 1.5)),
//       filled: true,
//       fillColor: Colors.white,
//     );
//   }

//   // ─── Build ────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<LocationBloc, LocationState>(
//       listener: (context, state) {
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(state.errorMessage!),
//             backgroundColor: Colors.red,
//           ));
//         }
//         if (_searchController.text != state.searchQuery) {
//           _searchController.text = state.searchQuery;
//           _searchController.selection = TextSelection.fromPosition(
//             TextPosition(offset: _searchController.text.length),
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
//             context.read<LocationBloc>().add(GoToPage(validCurrentPage));
//           });
//         }

//         final paginatedData = filteredData.isNotEmpty
//             ? filteredData.sublist(
//                 (validCurrentPage - 1) * state.itemsPerPage,
//                 ((validCurrentPage - 1) * state.itemsPerPage +
//                         state.itemsPerPage)
//                     .clamp(0, filteredData.length))
//             : <LocationData>[];

//         final allPageSelected = paginatedData.isNotEmpty &&
//             paginatedData.every((l) => _selectedIds.contains(l.id));

//         return SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Title ──
//                   const Text('Locations',
//                       style: TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1A1A1A))),
//                   const SizedBox(height: 4),
//                   Text('Manage store or warehouse locations.',
//                       style: TextStyle(fontSize: 13, color: Colors.grey[600])),
//                   const SizedBox(height: 16),

//                   // ── Search + New Location ──
//                   Row(
//                     children: [
//                       // Search
//                       Container(
//                         width: 200,
//                         height: 38,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: const Color(0xFFDDDDDD)),
//                         ),
//                         child: TextField(
//                           controller: _searchController,
//                           style: const TextStyle(fontSize: 13),
//                           decoration: const InputDecoration(
//                             hintText: 'Search...',
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFAAAAAA), fontSize: 13),
//                             prefixIcon: Icon(Icons.search,
//                                 color: Color(0xFFAAAAAA), size: 18),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(vertical: 10),
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       // New Location button
//                       ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => BlocProvider.value(
//                                 value: context.read<LocationBloc>(),
//                                 child: const AddLocationScreen(),
//                               ),
//                             ),
//                           );
//                         },
//                         icon: const Icon(Icons.add,
//                             size: 18, color: Colors.white),
//                         label: const Text('New Location',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _orange,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           elevation: 0,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),

//                   // ── Delete All ──
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton.icon(
//                       onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
//                       icon: Icon(Icons.delete_outline,
//                           size: 16,
//                           color: _selectedIds.isEmpty
//                               ? Colors.grey
//                               : const Color(0xFFD9534F)),
//                       label: Text('Delete All',
//                           style: TextStyle(
//                               fontSize: 13,
//                               color: _selectedIds.isEmpty
//                                   ? Colors.grey
//                                   : const Color(0xFFD9534F))),
//                       style: TextButton.styleFrom(
//                           padding: EdgeInsets.zero, minimumSize: Size.zero),
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // ── Table ──
//                   Container(
//                     width: 700,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: const Color(0xFFEEEEEE)),
//                     ),
//                     child: Column(
//                       children: [
//                         // Header
//                         Container(
//                           height: 48,
//                           decoration: const BoxDecoration(
//                             color: Color(0xFFFAFAFA),
//                             borderRadius:
//                                 BorderRadius.vertical(top: Radius.circular(10)),
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Row(
//                             children: [
//                               SizedBox(
//                                 width: 20,
//                                 child: Checkbox(
//                                   value: allPageSelected,
//                                   onChanged: (v) =>
//                                       _toggleSelectAll(paginatedData, v),
//                                   materialTapTargetSize:
//                                       MaterialTapTargetSize.shrinkWrap,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               const SizedBox(
//                                   width: 50,
//                                   child: Text('ID',
//                                       style: _headerStyle,
//                                       textAlign: TextAlign.center)),
//                               const Expanded(
//                                   child: Text('Location ID',
//                                       style: _headerStyle,
//                                       textAlign: TextAlign.center)),
//                               const Expanded(
//                                   child: Text('Name',
//                                       style: _headerStyle,
//                                       textAlign: TextAlign.center)),
//                               const SizedBox(
//                                   width: 100,
//                                   child: Text('Action',
//                                       style: _headerStyle,
//                                       textAlign: TextAlign.center)),
//                             ],
//                           ),
//                         ),
//                         const Divider(height: 1, color: Color(0xFFEEEEEE)),

//                         // Loading
//                         if (state.isLoading)
//                           const Padding(
//                             padding: EdgeInsets.all(40),
//                             child: Center(child: CircularProgressIndicator()),
//                           )

//                         // Empty
//                         else if (paginatedData.isEmpty)
//                           const Padding(
//                             padding: EdgeInsets.all(40),
//                             child: Center(child: Text('No locations found')),
//                           )

//                         // Rows
//                         else
//                           ...paginatedData.map((location) {
//                             final isSelected =
//                                 _selectedIds.contains(location.id);
//                             return Column(
//                               children: [
//                                 Container(
//                                   height: 56,
//                                   color: isSelected
//                                       ? const Color(0xFFFFF8F0)
//                                       : Colors.transparent,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16),
//                                   child: Row(
//                                     children: [
//                                       SizedBox(
//                                         width: 20,
//                                         child: Checkbox(
//                                           value: isSelected,
//                                           onChanged: (v) =>
//                                               _toggleSelect(location.id, v),
//                                           materialTapTargetSize:
//                                               MaterialTapTargetSize.shrinkWrap,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       SizedBox(
//                                         width: 50,
//                                         child: Text('${location.id}',
//                                             style: _rowStyle,
//                                             textAlign: TextAlign.center),
//                                       ),
//                                       Expanded(
//                                         child: Text(location.code ?? 'N/A',
//                                             style: _rowStyle,
//                                             textAlign: TextAlign.center),
//                                       ),
//                                       Expanded(
//                                         child: Text(location.name,
//                                             style: _rowStyle,
//                                             textAlign: TextAlign.center),
//                                       ),
//                                       SizedBox(
//                                         width: 100,
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             // Edit
//                                             GestureDetector(
//                                               onTap: () =>
//                                                   _showEditDialog(location),
//                                               child: const Icon(
//                                                   Icons.edit_outlined,
//                                                   size: 16,
//                                                   color: Color(0xFF888888)),
//                                             ),
//                                             const SizedBox(width: 12),
//                                             // View
//                                             GestureDetector(
//                                               onTap: () =>
//                                                   _showViewDialog(location),
//                                               child: const Icon(
//                                                   Icons.remove_red_eye_outlined,
//                                                   size: 16,
//                                                   color: Color(0xFF888888)),
//                                             ),
//                                             const SizedBox(width: 12),
//                                             // Delete
//                                             GestureDetector(
//                                               onTap: () =>
//                                                   _deleteLocation(location),
//                                               child: const Icon(
//                                                   Icons.delete_outline,
//                                                   size: 16,
//                                                   color: Color(0xFFD9534F)),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const Divider(
//                                     height: 1, color: Color(0xFFEEEEEE)),
//                               ],
//                             );
//                           }),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // ── Pagination ──
//                   if (!state.isLoading && totalPages > 1)
//                     Center(
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.chevron_left),
//                             onPressed: validCurrentPage > 1
//                                 ? () => context
//                                     .read<LocationBloc>()
//                                     .add(GoToPage(validCurrentPage - 1))
//                                 : null,
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 6),
//                             decoration: BoxDecoration(
//                               border:
//                                   Border.all(color: const Color(0xFFAAAAAA)),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text('$validCurrentPage',
//                                 style: const TextStyle(
//                                     fontSize: 13, fontWeight: FontWeight.w700)),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.chevron_right),
//                             onPressed: validCurrentPage < totalPages
//                                 ? () => context
//                                     .read<LocationBloc>()
//                                     .add(GoToPage(validCurrentPage + 1))
//                                 : null,
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ─── View Dialog ─────────────────────────────────────────────────────────

//   void _showViewDialog(LocationData location) {
//     showDialog(
//       context: context,
//       builder: (ctx) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         backgroundColor: Colors.white,
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           constraints: const BoxConstraints(maxWidth: 400),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Location Details',
//                       style:
//                           TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.grey),
//                     onPressed: () => Navigator.pop(ctx),
//                   ),
//                 ],
//               ),
//               const Divider(),
//               _viewRow('ID', location.id.toString()),
//               _viewRow('Location ID', location.code ?? 'N/A'),
//               _viewRow('Name', location.name),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _viewRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           SizedBox(
//               width: 110,
//               child: Text(label,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w600, color: Colors.black87))),
//           Expanded(
//               child:
//                   Text(value, style: const TextStyle(color: Colors.black54))),
//         ],
//       ),
//     );
//   }

//   static const _headerStyle = TextStyle(
//       fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555));

//   static const _rowStyle = TextStyle(fontSize: 13, color: Color(0xFF333333));
// }

// // ─── Add Location Screen ──────────────────────────────────────────────────────

// class AddLocationScreen extends StatefulWidget {
//   const AddLocationScreen({super.key});

//   @override
//   State<AddLocationScreen> createState() => _AddLocationScreenState();
// }

// class _AddLocationScreenState extends State<AddLocationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _codeController = TextEditingController();
//   bool _isLoading = false;

//   static const _orange = Color(0xFFE8891A);

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _codeController.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     final bloc = context.read<LocationBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final navigator = Navigator.of(context);

//     setState(() => _isLoading = true);

//     try {
//       final response = await DioClient().dio.post(
//         '/location/create_location/',
//         data: {
//           'name': _nameController.text.trim(),
//           'code': _codeController.text.trim(),
//         },
//       );

//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 201) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));

//       if (isSuccess) {
//         bloc.add(const FetchLocations());
//         navigator.pop();
//         scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(data['message'] ?? 'Location created successfully'),
//           backgroundColor: Colors.green,
//         ));
//       } else {
//         throw Exception(data is Map
//             ? (data['message'] ?? 'Create failed')
//             : 'Create failed');
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(SnackBar(
//         content: Text('Failed to create: $e'),
//         backgroundColor: Colors.red,
//       ));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: const Icon(Icons.arrow_back,
//                           size: 20, color: Colors.black87),
//                     ),
//                     const SizedBox(width: 10),
//                     const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Add Locations',
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87)),
//                         Text('Add a new store or warehouse location',
//                             style:
//                                 TextStyle(fontSize: 12, color: Colors.black54)),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 28),

//                 // Row: Name + Code
//                 LayoutBuilder(builder: (context, constraints) {
//                   if (constraints.maxWidth < 500) {
//                     return Column(
//                       children: [
//                         _buildField(
//                           label: '* Name:',
//                           child: TextFormField(
//                             controller: _nameController,
//                             decoration: _inputDeco(hint: 'Enter Location name'),
//                             validator: (v) => (v == null || v.trim().isEmpty)
//                                 ? 'Name is required'
//                                 : null,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildField(
//                           label: '* Code:',
//                           child: TextFormField(
//                             controller: _codeController,
//                             decoration: _inputDeco(hint: 'Enter Location code'),
//                             validator: (v) => (v == null || v.trim().isEmpty)
//                                 ? 'Code is required'
//                                 : null,
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//                   return Row(
//                     children: [
//                       Expanded(
//                         child: _buildField(
//                           label: '* Name:',
//                           child: TextFormField(
//                             controller: _nameController,
//                             decoration: _inputDeco(hint: 'Enter Location name'),
//                             validator: (v) => (v == null || v.trim().isEmpty)
//                                 ? 'Name is required'
//                                 : null,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 24),
//                       Expanded(
//                         child: _buildField(
//                           label: '* Code:',
//                           child: TextFormField(
//                             controller: _codeController,
//                             decoration: _inputDeco(hint: 'Enter Location code'),
//                             validator: (v) => (v == null || v.trim().isEmpty)
//                                 ? 'Code is required'
//                                 : null,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//                 const SizedBox(height: 28),

//                 // Add Button
//                 SizedBox(
//                   width: 160,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _submit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE0E0E0),
//                       foregroundColor: Colors.black54,
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(6)),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 18,
//                             width: 18,
//                             child: CircularProgressIndicator(
//                                 strokeWidth: 2, color: Colors.black54))
//                         : const Text('Add',
//                             style: TextStyle(
//                                 fontSize: 14, fontWeight: FontWeight.w500)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildField({required String label, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87)),
//         const SizedBox(height: 6),
//         child,
//       ],
//     );
//   }

//   InputDecoration _inputDeco({String? hint}) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
//       enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: _orange, width: 1.5)),
//       errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: Colors.red)),
//     );
//   }
// }

// File: lib/screen/location/view/locations_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/location_response.dart';
import 'package:saleup_app/screen/location/bloc/location_bloc.dart';
import 'package:saleup_app/screen/location/bloc/location_event.dart';
import 'package:saleup_app/screen/location/bloc/location_state.dart';
import 'package:saleup_app/screen/location/widget/location_card.dart';

const int _kPageSize = 10;
const double _kCardHeight = 110.0;

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Set<int> _selectedIds = {};
  int _currentPage = 1;

  static const _orange = Color(0xFFE8891A);

  // ─── Lifecycle ────────────────────────────────────────────────────────────

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

  // ─── Handlers ─────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _currentPage = 1);
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

  List<LocationData> _pageSlice(List<LocationData> filtered) {
    final start = (_currentPage - 1) * _kPageSize;
    if (start >= filtered.length) return [];
    return filtered.sublist(
        start, (start + _kPageSize).clamp(0, filtered.length));
  }

  int _totalPages(int count) => (count / _kPageSize).ceil().clamp(1, 9999);

  // ─── Delete Single ────────────────────────────────────────────────────────

  Future<void> _deleteLocation(LocationData location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Location',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        content: Text('Are you sure you want to delete "${location.name}"?',
            style: const TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  const Text('Cancel', style: TextStyle(fontFamily: 'Inter'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9534F),
                foregroundColor: Colors.white),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Inter')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

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

  // ─── Delete Bulk ──────────────────────────────────────────────────────────

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final ids = _selectedIds.toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Locations',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        content: Text('Delete ${ids.length} selected location(s)?',
            style: const TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  const Text('Cancel', style: TextStyle(fontFamily: 'Inter'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9534F),
                foregroundColor: Colors.white),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Inter')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final bloc = context.read<LocationBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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

  // ─── View Dialog ──────────────────────────────────────────────────────────

  void _showViewDialog(LocationData location) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter')),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              _viewRow('ID', location.id.toString()),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _viewRow('Location Code', location.code),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _viewRow('Name', location.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: Colors.black87)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.black54, fontFamily: 'Inter'))),
        ],
      ),
    );
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Edit Location',
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: '* Location ID',
                                child: TextFormField(
                                  initialValue: location.code,
                                  readOnly: true,
                                  style: const TextStyle(
                                      color: Colors.black45,
                                      fontFamily: 'Inter'),
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
                                  style: const TextStyle(
                                      color: Colors.black, fontFamily: 'Inter'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<LocationBloc, LocationState>(
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
                  TextPosition(offset: _searchController.text.length));
            }
          },
          builder: (context, state) {
            final filteredData = state.getFilteredData();
            final totalPages = _totalPages(filteredData.length);

            if (_currentPage > totalPages && totalPages > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _currentPage = totalPages);
              });
            }

            final pageItems = _pageSlice(filteredData);
            final pageAllSelected = pageItems.isNotEmpty &&
                pageItems.every((l) => _selectedIds.contains(l.id));

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──
                    const Text('Locations',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 4),
                    Text('Manage store or warehouse locations',
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Colors.grey[600])),
                    const SizedBox(height: 12),

                    // ── Search + New Location ──
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

                    // ── Select All + Delete All ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                              Text('Select All',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      color: Colors.grey[600])),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
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
                                  fontFamily: 'Inter',
                                  color: _selectedIds.isEmpty
                                      ? Colors.grey
                                      : const Color(0xFFD9534F))),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, minimumSize: Size.zero),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Cards or Shimmer ──
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
                                pageItems.isEmpty
                                    ? const SizedBox(
                                        height: 200,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  size: 48,
                                                  color: Color(0xFFCCCCCC)),
                                              SizedBox(height: 12),
                                              Text(
                                                'No locations found',
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
                                          final location = pageItems[index];
                                          final isSelected = _selectedIds
                                              .contains(location.id);
                                          return LocationCard(
                                            location: location,
                                            isSelected: isSelected,
                                            onSelect: (v) =>
                                                _toggleSelect(location.id, v),
                                            onView: () =>
                                                _showViewDialog(location),
                                            onEdit: () =>
                                                _showEditDialog(location),
                                            onDelete: () =>
                                                _deleteLocation(location),
                                          );
                                        },
                                      ),
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
              5,
              (_) => Column(children: [
                    Container(height: _kCardHeight, color: Colors.white),
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
                        Text('Add Location',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('Add a new store or warehouse location',
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Inter',
                                color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 500;
                  final nameField = _buildFormField(
                    label: '* Name:',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: _inputDeco(hint: 'Enter location name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                  );
                  final codeField = _buildFormField(
                    label: '* Code:',
                    child: TextFormField(
                      controller: _codeController,
                      decoration: _inputDeco(hint: 'Enter location code'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Code is required'
                          : null,
                    ),
                  );

                  if (isNarrow) {
                    return Column(children: [
                      nameField,
                      const SizedBox(height: 16),
                      codeField,
                    ]);
                  }
                  return Row(children: [
                    Expanded(child: nameField),
                    const SizedBox(width: 24),
                    Expanded(child: codeField),
                  ]);
                }),
                const SizedBox(height: 28),

                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Add Location',
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
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
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _orange, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
