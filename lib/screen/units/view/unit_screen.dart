// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/unit_response.dart';
// import 'package:saleup_app/screen/units/bloc/unit_bloc.dart';
// import 'package:saleup_app/screen/units/bloc/unit_event.dart';
// import 'package:saleup_app/screen/units/bloc/unit_state.dart';

// class UnitsScreen extends StatefulWidget {
//   const UnitsScreen({super.key});

//   @override
//   State<UnitsScreen> createState() => _UnitsScreenState();
// }

// class _UnitsScreenState extends State<UnitsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   final Set<int> _selectedIds = {};

//   static const _orange = Color(0xFFE8891A);

//   @override
//   void initState() {
//     super.initState();
//     context.read<UnitBloc>().add(const FetchUnits());
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
//       context.read<UnitBloc>().add(SearchUnits(_searchController.text));
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

//   void _toggleSelectAll(List<UnitData> items, bool? value) {
//     setState(() {
//       if (value == true) {
//         _selectedIds.addAll(items.map((u) => u.id));
//       } else {
//         _selectedIds.removeAll(items.map((u) => u.id));
//       }
//     });
//   }

//   // ─── Delete Single ────────────────────────────────────────────────────────
//   Future<void> _deleteUnit(UnitData unit) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Delete Unit',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Text('Are you sure you want to delete "${unit.name}"?'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(ctx, false),
//               child: const Text('Cancel',
//                   style: TextStyle(color: Colors.black54))),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFD9534F),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8))),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;

//     final bloc = context.read<UnitBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     try {
//       final response = await DioClient().dio.delete(
//         '/unit/delete_units/',
//         data: {
//           'unit_ids': [unit.id]
//         }, // ← Backend requires this exact key + array
//       );
//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 204) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));

//       if (isSuccess) {
//         setState(() => _selectedIds.remove(unit.id));
//         bloc.add(const FetchUnits());
//         scaffoldMessenger.showSnackBar(SnackBar(
//             content: Text(data['message'] ?? 'Unit deleted successfully'),
//             backgroundColor: Colors.green));
//       } else {
//         throw Exception(data is Map
//             ? (data['message'] ?? 'Delete failed')
//             : 'Delete failed');
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(e.toString().replaceFirst('Exception: ', '')),
//           backgroundColor: Colors.red));
//     }
//   }

//   // ─── Delete Selected ─────────────────────────────────────────────────────
//   Future<void> _deleteSelected() async {
//     if (_selectedIds.isEmpty) return;
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Delete Units',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Text('Delete ${_selectedIds.length} selected unit(s)?'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(ctx, false),
//               child: const Text('Cancel',
//                   style: TextStyle(color: Colors.black54))),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFD9534F),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8))),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;

//     final bloc = context.read<UnitBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     try {
//       final response = await DioClient().dio.delete(
//         '/unit/delete_units/',
//         data: {
//           'unit_ids': _selectedIds.toList()
//         }, // ← Backend requires this exact key + array
//       );
//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 204) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));

//       if (isSuccess) {
//         setState(() => _selectedIds.clear());
//         bloc.add(const FetchUnits());
//         scaffoldMessenger.showSnackBar(SnackBar(
//             content: Text(data['message'] ?? 'Units deleted successfully'),
//             backgroundColor: Colors.green));
//       } else {
//         throw Exception(data is Map
//             ? (data['message'] ?? 'Delete failed')
//             : 'Delete failed');
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(e.toString().replaceFirst('Exception: ', '')),
//           backgroundColor: Colors.red));
//     }
//   }

//   // ─── View Dialog ─────────────────────────────────────────────────────────

//   void _showViewDialog(UnitData unit) {
//     showDialog(
//       context: context,
//       builder: (ctx) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         backgroundColor: Colors.white,
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           constraints: const BoxConstraints(maxWidth: 520),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Unit Details',
//                       style:
//                           TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.grey),
//                     onPressed: () => Navigator.pop(ctx),
//                   ),
//                 ],
//               ),
//               const Divider(),
//               // Row: Unit ID + Name
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Row(
//                   children: [
//                     Expanded(
//                         child: Text('Unit ID: ${unit.id}',
//                             style: const TextStyle(
//                                 fontSize: 13, color: Colors.black87))),
//                     Expanded(
//                         child: Text('Name: ${unit.name}',
//                             style: const TextStyle(
//                                 fontSize: 13, color: Colors.black87))),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Color(0xFFEEEEEE)),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Text(
//                   'Description: ${(unit.description ?? '').trim().isEmpty ? 'N/A' : unit.description}',
//                   style: const TextStyle(fontSize: 13, color: Colors.black87),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── Edit Dialog ─────────────────────────────────────────────────────────

//   void _showEditDialog(UnitData unit) {
//     final bloc = context.read<UnitBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final nameController = TextEditingController(text: unit.name);
//     final descController = TextEditingController(text: unit.description ?? '');
//     bool isLoading = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 440.0;

//           return Dialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             backgroundColor: Colors.white,
//             insetPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//             child: Container(
//               width: dialogWidth,
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
//                             const Text('Edit Unit',
//                                 style: TextStyle(
//                                     fontSize: 16,
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
//                         const SizedBox(height: 16),

//                         // Row: Unit ID (readonly) + Name
//                         Row(
//                           children: [
//                             Expanded(
//                                 child: _field(
//                               label: 'Unit ID',
//                               child: TextFormField(
//                                 initialValue: unit.id.toString(),
//                                 readOnly: true,
//                                 style: const TextStyle(color: Colors.black45),
//                                 decoration: _deco(),
//                               ),
//                             )),
//                             const SizedBox(width: 12),
//                             Expanded(
//                                 child: _field(
//                               label: '* Name',
//                               required: true,
//                               child: TextFormField(
//                                 controller: nameController,
//                                 decoration: _deco(),
//                               ),
//                             )),
//                           ],
//                         ),
//                         const SizedBox(height: 12),

//                         // Description
//                         _field(
//                           label: 'Description',
//                           child: TextFormField(
//                             controller: descController,
//                             maxLines: 3,
//                             decoration: _deco(),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Save Button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               setDialogState(() => isLoading = true);
//                               final navigator = Navigator.of(context);
//                               try {
//                                 final response = await DioClient().dio.put(
//                                   '/unit/update_unit/?unit_id=${unit.id}',
//                                   data: {
//                                     'name': nameController.text.trim(),
//                                     'description': descController.text.trim(),
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
//                                         'Unit updated successfully'),
//                                     backgroundColor: Colors.green,
//                                   ));
//                                   bloc.add(const FetchUnits());
//                                 } else {
//                                   final msg = data is Map
//                                       ? (data['message'] ?? 'Update failed')
//                                       : 'Update failed';
//                                   scaffoldMessenger.showSnackBar(SnackBar(
//                                       content: Text(msg),
//                                       backgroundColor: Colors.red));
//                                 }
//                               } catch (e) {
//                                 scaffoldMessenger.showSnackBar(SnackBar(
//                                   content: Text(e
//                                       .toString()
//                                       .replaceFirst('Exception: ', '')),
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

//   Widget _field(
//       {required String label, required Widget child, bool required = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: required ? _orange : Colors.black87)),
//         const SizedBox(height: 5),
//         child,
//       ],
//     );
//   }

//   InputDecoration _deco({String? hint}) {
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
//     return BlocConsumer<UnitBloc, UnitState>(
//       listener: (context, state) {
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(state.errorMessage!),
//             backgroundColor: Colors.red,
//           ));
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
//             if (mounted) {
//               context.read<UnitBloc>().add(GoToPage(validCurrentPage));
//             }
//           });
//         }

//         final paginatedData = filteredData.isNotEmpty
//             ? filteredData.sublist(
//                 (validCurrentPage - 1) * state.itemsPerPage,
//                 ((validCurrentPage - 1) * state.itemsPerPage +
//                         state.itemsPerPage)
//                     .clamp(0, filteredData.length))
//             : <UnitData>[];

//         final allPageSelected = paginatedData.isNotEmpty &&
//             paginatedData.every((u) => _selectedIds.contains(u.id));

//         return SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Title + New Button ──
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Flexible(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Units',
//                                 style: TextStyle(
//                                     fontSize: 26,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF1A1A1A))),
//                             SizedBox(height: 4),
//                             Text(
//                                 'Manage units of measurement for your products.',
//                                 style: TextStyle(
//                                     fontSize: 13, color: Color(0xFF777777))),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => BlocProvider.value(
//                                 value: context.read<UnitBloc>(),
//                                 child: const AddUnitScreen(),
//                               ),
//                             ),
//                           );
//                         },
//                         icon: const Icon(Icons.add,
//                             size: 18, color: Colors.white),
//                         label: const Text('New Unit',
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
//                   const SizedBox(height: 16),

//                   // ── Search + Delete All ──
//                   Row(
//                     children: [
//                       Container(
//                         width: 220,
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
//                       TextButton.icon(
//                         onPressed:
//                             _selectedIds.isEmpty ? null : _deleteSelected,
//                         icon: Icon(Icons.delete_outline,
//                             size: 16,
//                             color: _selectedIds.isEmpty
//                                 ? Colors.grey
//                                 : const Color(0xFFD9534F)),
//                         label: Text('Delete All',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: _selectedIds.isEmpty
//                                     ? Colors.grey
//                                     : const Color(0xFFD9534F))),
//                         style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero, minimumSize: Size.zero),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   // ── Table ──
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(
//                         minWidth: MediaQuery.of(context).size.width - 40,
//                       ),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: const Color(0xFFEEEEEE)),
//                         ),
//                         child: Column(
//                           children: [
//                             // Header
//                             Container(
//                               height: 52,
//                               decoration: const BoxDecoration(
//                                 color: Color(0xFFFAFAFA),
//                                 borderRadius: BorderRadius.vertical(
//                                     top: Radius.circular(10)),
//                               ),
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 16),
//                               child: Row(
//                                 children: [
//                                   SizedBox(
//                                       width: 32,
//                                       child: Checkbox(
//                                         value: allPageSelected,
//                                         onChanged: (v) =>
//                                             _toggleSelectAll(paginatedData, v),
//                                         materialTapTargetSize:
//                                             MaterialTapTargetSize.shrinkWrap,
//                                       )),
//                                   const SizedBox(width: 8),
//                                   const SizedBox(
//                                       width: 80,
//                                       child: Text('ID',
//                                           style: _hStyle,
//                                           textAlign: TextAlign.center)),
//                                   const SizedBox(
//                                       width: 160,
//                                       child: Text('Name',
//                                           style: _hStyle,
//                                           textAlign: TextAlign.center)),
//                                   const SizedBox(
//                                       width: 110,
//                                       child: Text('Action',
//                                           style: _hStyle,
//                                           textAlign: TextAlign.center)),
//                                 ],
//                               ),
//                             ),
//                             const Divider(height: 1, color: Color(0xFFEEEEEE)),

//                             if (state.isLoading)
//                               const Padding(
//                                   padding: EdgeInsets.all(48),
//                                   child: Center(
//                                       child: CircularProgressIndicator()))
//                             else if (paginatedData.isEmpty)
//                               const Padding(
//                                 padding: EdgeInsets.all(48),
//                                 child: Center(
//                                     child: Text('No units found',
//                                         style: TextStyle(
//                                             color: Color(0xFF888888)))),
//                               )
//                             else
//                               ...paginatedData.map((unit) {
//                                 final isSelected =
//                                     _selectedIds.contains(unit.id);
//                                 return Column(
//                                   children: [
//                                     Container(
//                                       height: 56,
//                                       color: isSelected
//                                           ? const Color(0xFFFFF8F0)
//                                           : Colors.transparent,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 16),
//                                       child: Row(
//                                         children: [
//                                           SizedBox(
//                                               width: 32,
//                                               child: Checkbox(
//                                                 value: isSelected,
//                                                 onChanged: (v) =>
//                                                     _toggleSelect(unit.id, v),
//                                                 materialTapTargetSize:
//                                                     MaterialTapTargetSize
//                                                         .shrinkWrap,
//                                               )),
//                                           const SizedBox(width: 8),
//                                           SizedBox(
//                                               width: 80,
//                                               child: Text('${unit.id}',
//                                                   style: _rStyle,
//                                                   textAlign: TextAlign.center)),
//                                           SizedBox(
//                                               width: 160,
//                                               child: Text(unit.name,
//                                                   style: _rStyle,
//                                                   textAlign: TextAlign.center,
//                                                   overflow:
//                                                       TextOverflow.ellipsis)),
//                                           SizedBox(
//                                             width: 110,
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 GestureDetector(
//                                                   onTap: () =>
//                                                       _showEditDialog(unit),
//                                                   child: const Icon(
//                                                       Icons.edit_outlined,
//                                                       size: 17,
//                                                       color: Color(0xFF888888)),
//                                                 ),
//                                                 const SizedBox(width: 12),
//                                                 GestureDetector(
//                                                   onTap: () =>
//                                                       _showViewDialog(unit),
//                                                   child: const Icon(
//                                                       Icons
//                                                           .remove_red_eye_outlined,
//                                                       size: 17,
//                                                       color: Color(0xFF888888)),
//                                                 ),
//                                                 const SizedBox(width: 12),
//                                                 GestureDetector(
//                                                   onTap: () =>
//                                                       _deleteUnit(unit),
//                                                   child: const Icon(
//                                                       Icons.delete_outline,
//                                                       size: 17,
//                                                       color: Color(0xFFD9534F)),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const Divider(
//                                         height: 1, color: Color(0xFFEEEEEE)),
//                                   ],
//                                 );
//                               }),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // ── Pagination (always visible) ──
//                   if (!state.isLoading)
//                     Center(
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.chevron_left),
//                             onPressed: validCurrentPage > 1
//                                 ? () => context
//                                     .read<UnitBloc>()
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
//                                     .read<UnitBloc>()
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

//   static const _hStyle = TextStyle(
//       fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555));
//   static const _rStyle = TextStyle(fontSize: 13, color: Color(0xFF333333));
// }

// // ─── Add Unit Screen ──────────────────────────────────────────────────────────

// class AddUnitScreen extends StatefulWidget {
//   const AddUnitScreen({super.key});

//   @override
//   State<AddUnitScreen> createState() => _AddUnitScreenState();
// }

// class _AddUnitScreenState extends State<AddUnitScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descController = TextEditingController();
//   bool _isLoading = false;

//   static const _orange = Color(0xFFE8891A);

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     final bloc = context.read<UnitBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final navigator = Navigator.of(context);

//     setState(() => _isLoading = true);

//     try {
//       final response = await DioClient().dio.post(
//         '/unit/create_unit/',
//         data: {
//           'name': _nameController.text.trim(),
//           'description': _descController.text.trim(),
//         },
//       );
//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 201) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));
//       if (isSuccess) {
//         bloc.add(const FetchUnits());
//         navigator.pop();
//         scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(data['message'] ?? 'Unit created successfully'),
//           backgroundColor: Colors.green,
//         ));
//       } else {
//         throw Exception(data is Map
//             ? (data['message'] ?? 'Create failed')
//             : 'Create failed');
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(SnackBar(
//         content: Text(e.toString().replaceFirst('Exception: ', '')),
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
//                         Text('Add Unit',
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87)),
//                         Text('Add a new unit of measurement.',
//                             style:
//                                 TextStyle(fontSize: 12, color: Colors.black54)),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 28),

//                 // Name
//                 _buildField(
//                   label: '* Name:',
//                   child: TextFormField(
//                     controller: _nameController,
//                     decoration: _inputDeco(hint: 'Name'),
//                     validator: (v) => (v == null || v.trim().isEmpty)
//                         ? 'Name is required'
//                         : null,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Description
//                 _buildField(
//                   label: 'Description :',
//                   child: TextFormField(
//                     controller: _descController,
//                     maxLines: 4,
//                     decoration: _inputDeco(hint: 'Enter Description'),
//                   ),
//                 ),
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
//                 fontSize: 13, fontWeight: FontWeight.w500, color: _orange)),
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
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _toggleSelectAll(List<UnitData> items, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(items.map((u) => u.id));
      } else {
        _selectedIds.removeAll(items.map((u) => u.id));
      }
    });
  }

  // ─── Delete Single ────────────────────────────────────────────────────────

  Future<void> _deleteUnit(UnitData unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Unit',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        content: Text('Are you sure you want to delete "${unit.name}"?',
            style: const TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54, fontFamily: 'Inter')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9534F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Inter')),
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
        },
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
          content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
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
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        content: Text('Delete ${_selectedIds.length} selected unit(s)?',
            style: const TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54, fontFamily: 'Inter')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9534F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Inter')),
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
        data: {'unit_ids': _selectedIds.toList()},
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
          content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
    }
  }

  // ─── View Dialog ─────────────────────────────────────────────────────────

  void _showViewDialog(UnitData unit) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Unit Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter')),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 12),
              _buildGridRow('Unit ID', '${unit.id}', 'Name', unit.name),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _buildLabelValue(
                    'Description',
                    (unit.description ?? '').trim().isEmpty
                        ? 'N/A'
                        : unit.description ?? 'N/A'),
              ),
            ],
          ),
        ),
      ),
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
          final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 480.0;

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
                      height: 180,
                      child: Center(child: CircularProgressIndicator()))
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Edit Unit',
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
                          Row(children: [
                            Expanded(
                              child: _buildEditField(
                                label: 'Unit ID',
                                child: TextFormField(
                                  initialValue: unit.id.toString(),
                                  readOnly: true,
                                  style: const TextStyle(
                                      color: Colors.black45,
                                      fontFamily: 'Inter'),
                                  decoration: _editDeco(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildEditField(
                                label: '* Name',
                                required: true,
                                child: TextFormField(
                                  controller: nameController,
                                  decoration: _editDeco(),
                                  style: const TextStyle(
                                      color: Colors.black, fontFamily: 'Inter'),
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildEditField(
                            label: 'Description',
                            child: TextFormField(
                              controller: descController,
                              maxLines: 3,
                              decoration: _editDeco(),
                              style: const TextStyle(
                                  color: Colors.black, fontFamily: 'Inter'),
                            ),
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
                                    '/unit/update_unit/?unit_id=${unit.id}',
                                    data: {
                                      'name': nameController.text.trim(),
                                      'description': descController.text.trim(),
                                    },
                                  );
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
                                          'Unit updated successfully'),
                                      backgroundColor: Colors.green,
                                    ));
                                    bloc.add(const FetchUnits());
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

  Widget _buildEditField(
      {required String label, required Widget child, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: required ? _orange : Colors.black87)),
        const SizedBox(height: 6),
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
          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // ─── UI Components ──────────────────────────────────────────────────────

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(200),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
        decoration: const InputDecoration(
          hintText: 'Search units...',
          hintStyle: TextStyle(
              fontFamily: 'Inter', color: Color(0xFFAAAAAA), fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Color(0xFFAAAAAA), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildNewUnitButton() {
    return ElevatedButton.icon(
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
      icon: const Icon(Icons.add, size: 18, color: Colors.white),
      label: const Text('New Unit',
          style: TextStyle(
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _orange,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildDeleteButton(int count) {
    return ElevatedButton.icon(
      onPressed: _deleteSelected,
      icon:
          const Icon(Icons.delete_outline, size: 16, color: Color(0xFFD9534F)),
      label: Text('Delete ($count)',
          style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Color(0xFFD9534F))),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFF0F0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        side: const BorderSide(color: Color(0xFFFFCCCC)),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: color),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
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
            if (mounted) {
              context.read<UnitBloc>().add(GoToPage(validCurrentPage));
            }
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

        final selectedCount = _selectedIds.length;

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 650;
                    final isMedium = constraints.maxWidth >= 450;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Title ──
                        const Text('Units',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Inter',
                                color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 4),
                        Text('Manage units of measurement for your products.',
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Inter',
                                color: Colors.grey[600])),
                        const SizedBox(height: 16),

                        // ── Search + Actions ──
                        if (isMedium)
                          Row(
                            children: [
                              Expanded(child: _buildSearchField()),
                              const SizedBox(width: 8),
                              _buildNewUnitButton(),
                              if (selectedCount > 0) ...[
                                const SizedBox(width: 8),
                                _buildDeleteButton(selectedCount),
                              ],
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSearchField(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildNewUnitButton(),
                                  if (selectedCount > 0) ...[
                                    const SizedBox(width: 8),
                                    _buildDeleteButton(selectedCount),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // ── Summary Stats ──
                        Row(
                          children: [
                            _buildStatCard(
                              icon: Icons.straighten_outlined,
                              label: 'Total Units',
                              value: '${state.units.length}',
                              color: _orange,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              icon: Icons.filter_list_outlined,
                              label: 'Showing',
                              value: '${filteredData.length}',
                              color: const Color(0xFF5C7CFA),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              icon: Icons.check_circle_outline,
                              label: 'Selected',
                              value: '$selectedCount',
                              color: const Color(0xFF4CAF50),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Table / Cards ──
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (isWide) ...[
                                // ── Wide Table Header ──
                                Container(
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: allPageSelected,
                                          onChanged: (v) => _toggleSelectAll(
                                              paginatedData, v),
                                          activeColor: _orange,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          side: const BorderSide(
                                              color: Color(0xFFCCCCCC),
                                              width: 1.5),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const SizedBox(
                                          width: 70,
                                          child: Text('ID',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFF888888)),
                                              textAlign: TextAlign.center)),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                          child: Text('Name',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFF888888)))),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                          flex: 2,
                                          child: Text('Description',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFF888888)))),
                                      const SizedBox(width: 8),
                                      const SizedBox(
                                          width: 110,
                                          child: Text('Actions',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFF888888)),
                                              textAlign: TextAlign.center)),
                                    ],
                                  ),
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFEEEEEE)),
                              ] else ...[
                                // ── Narrow Card Header ──
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: allPageSelected,
                                          onChanged: (v) => _toggleSelectAll(
                                              paginatedData, v),
                                          activeColor: _orange,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          side: const BorderSide(
                                              color: Color(0xFFCCCCCC),
                                              width: 1.5),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Select All',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],

                              // ── Body ──
                              if (state.isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(48),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: _orange)),
                                )
                              else if (paginatedData.isEmpty)
                                SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.straighten_outlined,
                                            size: 48, color: Color(0xFFCCCCCC)),
                                        const SizedBox(height: 12),
                                        Text('No units found',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.grey[500],
                                                fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text(
                                            'Try adjusting your search or add a new unit.',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.grey[400],
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                )
                              else if (isWide)
                                ...paginatedData.map((unit) {
                                  final isSelected =
                                      _selectedIds.contains(unit.id);
                                  return _UnitRow(
                                    unit: unit,
                                    isSelected: isSelected,
                                    onSelect: (v) => _toggleSelect(unit.id, v),
                                    onView: () => _showViewDialog(unit),
                                    onEdit: () => _showEditDialog(unit),
                                    onDelete: () => _deleteUnit(unit),
                                  );
                                })
                              else
                                ...paginatedData.map((unit) {
                                  final isSelected =
                                      _selectedIds.contains(unit.id);
                                  return _MobileUnitCard(
                                    unit: unit,
                                    isSelected: isSelected,
                                    onSelect: (v) => _toggleSelect(unit.id, v),
                                    onView: () => _showViewDialog(unit),
                                    onEdit: () => _showEditDialog(unit),
                                    onDelete: () => _deleteUnit(unit),
                                  );
                                }),

                              // ── Pagination ──
                              if (!state.isLoading && totalPages > 0) ...[
                                const Divider(
                                    height: 1, color: Color(0xFFEEEEEE)),
                                SizedBox(
                                  height: 52,
                                  child: _PaginationBar(
                                    currentPage: validCurrentPage,
                                    totalPages: totalPages,
                                    onPageChanged: (p) => context
                                        .read<UnitBloc>()
                                        .add(GoToPage(p)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Wide Table Row ───────────────────────────────────────────────────────────

class _UnitRow extends StatelessWidget {
  final UnitData unit;
  final bool isSelected;
  final ValueChanged<bool?> onSelect;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _orange = Color(0xFFE8891A);

  const _UnitRow({
    required this.unit,
    required this.isSelected,
    required this.onSelect,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final desc = (unit.description ?? '').trim();
    return Column(
      children: [
        Container(
          color: isSelected ? const Color(0xFFFFF8F0) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onSelect,
                  activeColor: _orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                  ),
                  child: Text('#${unit.id}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF555555)),
                      textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.straighten_outlined,
                          size: 14, color: Color(0xFF9C27B0)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(unit.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Color(0xFF1A1A1A)),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(desc.isEmpty ? '—' : desc,
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        color: desc.isEmpty
                            ? const Color(0xFFBBBBBB)
                            : const Color(0xFF555555)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionBtn(
                        Icons.remove_red_eye_outlined,
                        const Color(0xFFEEEEEE),
                        const Color(0xFF888888),
                        onView),
                    const SizedBox(width: 6),
                    _actionBtn(Icons.edit_outlined, const Color(0xFFFFF3E0),
                        _orange, onEdit),
                    const SizedBox(width: 6),
                    _actionBtn(Icons.delete_outline, const Color(0xFFFFEBEE),
                        const Color(0xFFD9534F), onDelete),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  Widget _actionBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 15, color: fg),
      ),
    );
  }
}

// ─── Narrow Mobile Card ───────────────────────────────────────────────────────

class _MobileUnitCard extends StatelessWidget {
  final UnitData unit;
  final bool isSelected;
  final ValueChanged<bool?> onSelect;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _orange = Color(0xFFE8891A);

  const _MobileUnitCard({
    required this.unit,
    required this.isSelected,
    required this.onSelect,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final desc = (unit.description ?? '').trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF8F0) : Colors.transparent,
        border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: onSelect,
              activeColor: _orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.straighten_outlined,
                          size: 14, color: Color(0xFF9C27B0)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(unit.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Color(0xFF1A1A1A)),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text('#${unit.id}',
                          style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'Inter',
                              color: Color(0xFF555555))),
                    ),
                  ],
                ),
                if (desc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 36),
                    child: Text(desc,
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionBtn(
                        Icons.remove_red_eye_outlined,
                        const Color(0xFFEEEEEE),
                        const Color(0xFF888888),
                        onView),
                    const SizedBox(width: 6),
                    _actionBtn(Icons.edit_outlined, const Color(0xFFFFF3E0),
                        _orange, onEdit),
                    const SizedBox(width: 6),
                    _actionBtn(Icons.delete_outline, const Color(0xFFFFEBEE),
                        const Color(0xFFD9534F), onDelete),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 15, color: fg),
      ),
    );
  }
}

// ─── Pagination Bar ───────────────────────────────────────────────────────────

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
                          fontSize: 13)),
                )
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
            const SizedBox(width: 12),
            Text('$currentPage / $totalPages',
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Inter',
                    color: Color(0xFF888888))),
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
            color: isActive ? const Color(0xFFE8891A) : Colors.transparent,
            borderRadius: BorderRadius.circular(6)),
        alignment: Alignment.center,
        child: Text('$page',
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? Colors.white : const Color(0xFF555555))),
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
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap != null
                ? const Color(0xFFDDDDDD)
                : const Color(0xFFEEEEEE),
          ),
          borderRadius: BorderRadius.circular(6),
          color: onTap != null ? Colors.white : const Color(0xFFFAFAFA),
        ),
        child: Icon(icon,
            size: 16,
            color: onTap == null
                ? const Color(0xFFCCCCCC)
                : const Color(0xFF555555)),
      ),
    );
  }
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
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 18, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Unit',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: Colors.black87)),
                          Text('Add a new unit of measurement.',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.straighten_outlined,
                                size: 16, color: _orange),
                          ),
                          const SizedBox(width: 10),
                          const Text('Unit Information',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 20),

                      // Name
                      _buildField(
                        label: '* Name',
                        child: TextFormField(
                          controller: _nameController,
                          decoration: _inputDeco(hint: 'e.g. KGs, PCS, Liters'),
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              color: Colors.black),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildField(
                        label: 'Description',
                        child: TextFormField(
                          controller: _descController,
                          maxLines: 4,
                          decoration: _inputDeco(
                              hint: 'Brief description of this unit...'),
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Add Button
                      SizedBox(
                        width: double.infinity,
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
                              : const Text('Create Unit',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: _orange)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: Colors.black38, fontSize: 13, fontFamily: 'Inter'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _orange, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
    );
  }
}
