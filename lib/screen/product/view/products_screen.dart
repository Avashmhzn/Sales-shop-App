// // File: lib/screen/product/view/products_screen.dart

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_response.dart';
// import 'package:saleup_app/screen/product/bloc/product_bloc.dart';
// import 'package:saleup_app/screen/product/bloc/product_event.dart';
// import 'package:saleup_app/screen/product/bloc/product_state.dart';

// const int _kPageSize = 10;

// class ProductsScreen extends StatefulWidget {
//   const ProductsScreen({super.key});

//   @override
//   State<ProductsScreen> createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends State<ProductsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   final Set<int> _selectedIds = {};
//   int _currentPage = 1;

//   static const _orange = Color(0xFFE8891A);

//   // ─── Lifecycle ────────────────────────────────────────────────────────────

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       context.read<ProductBloc>().add(const FetchProducts());
//       context.read<ProductBloc>().add(const FetchUnits());
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

//   // ─── Handlers ─────────────────────────────────────────────────────────────

//   void _onSearchChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (!mounted) return;
//       setState(() => _currentPage = 1);
//       context.read<ProductBloc>().add(SearchProducts(_searchController.text));
//     });
//   }

//   void _clearAllFilters() {
//     setState(() => _currentPage = 1);
//     context.read<ProductBloc>().add(const ClearFilters());
//     _searchController.clear();
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

//   void _toggleSelectAll(List<ProductData> items, bool? value) {
//     setState(() {
//       if (value == true) {
//         _selectedIds.addAll(items.map((p) => p.id ?? 0));
//       } else {
//         _selectedIds.removeAll(items.map((p) => p.id ?? 0));
//       }
//     });
//   }

//   List<ProductData> _pageSlice(List<ProductData> filtered) {
//     final start = (_currentPage - 1) * _kPageSize;
//     if (start >= filtered.length) return [];
//     return filtered.sublist(
//         start, (start + _kPageSize).clamp(0, filtered.length));
//   }

//   int _totalPages(int count) => (count / _kPageSize).ceil().clamp(1, 9999);

//   // ─── Delete Single ────────────────────────────────────────────────────────

//   Future<void> _deleteProduct(ProductData product) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Delete Product',
//             style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
//         content: Text(
//             'Are you sure you want to delete "${product.name ?? 'this product'}"?',
//             style: const TextStyle(fontFamily: 'Inter')),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel',
//                 style: TextStyle(color: Colors.black54, fontFamily: 'Inter')),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFD9534F),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Delete', style: TextStyle(fontFamily: 'Inter')),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     final bloc = context.read<ProductBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     try {
//       final response = await DioClient().dio.delete(
//         '/product/delete_products/',
//         data: {
//           'product_ids': [product.id]
//         },
//       );
//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 204) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));
//       if (isSuccess) {
//         setState(() => _selectedIds.remove(product.id));
//         bloc.add(const FetchProducts());
//         scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(data['message'] ?? 'Product deleted successfully'),
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

//   // ─── Delete Selected ─────────────────────────────────────────────────────

//   Future<void> _deleteSelected() async {
//     if (_selectedIds.isEmpty) return;
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Delete Products',
//             style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
//         content: Text('Delete ${_selectedIds.length} selected product(s)?',
//             style: const TextStyle(fontFamily: 'Inter')),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel',
//                 style: TextStyle(color: Colors.black54, fontFamily: 'Inter')),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFD9534F),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Delete', style: TextStyle(fontFamily: 'Inter')),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     final bloc = context.read<ProductBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     try {
//       final response = await DioClient().dio.delete(
//         '/product/delete_products/',
//         data: {'product_ids': _selectedIds.toList()},
//       );
//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 204) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));
//       if (isSuccess) {
//         setState(() => _selectedIds.clear());
//         bloc.add(const FetchProducts());
//         scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(data['message'] ?? 'Products deleted successfully'),
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

//   // ─── View Dialog ─────────────────────────────────────────────────────────

//   void _showViewDialog(ProductData product) {
//     showDialog(
//       context: context,
//       builder: (ctx) => Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           constraints: const BoxConstraints(maxWidth: 700),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Product Details',
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Inter')),
//                   IconButton(
//                       icon: const Icon(Icons.close, color: Colors.grey),
//                       onPressed: () => Navigator.pop(ctx)),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               const Divider(),
//               const SizedBox(height: 12),
//               _buildGridRow('ID', product.id?.toString() ?? 'N/A', 'Name',
//                   product.name ?? 'N/A'),
//               const Divider(height: 1),
//               _buildGridRow('Category', product.category ?? 'N/A', 'Unit',
//                   product.unit ?? 'N/A'),
//               const Divider(height: 1),
//               _buildGridRow('Location', product.location ?? 'N/A', 'Stock',
//                   '${product.stockQuantity ?? 0}'),
//               const Divider(height: 1),
//               _buildGridRow(
//                 'Is VAT',
//                 product.isVat == true ? 'Yes' : 'No',
//                 'Is Service',
//                 product.service == true ? 'Yes' : 'No',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGridRow(
//       String label1, String value1, String label2, String value2) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Expanded(child: _buildLabelValue(label1, value1)),
//           Expanded(child: _buildLabelValue(label2, value2)),
//         ],
//       ),
//     );
//   }

//   Widget _buildLabelValue(String label, String value) {
//     return RichText(
//       text: TextSpan(
//         style: const TextStyle(
//             fontSize: 14, fontFamily: 'Inter', color: Colors.black87),
//         children: [
//           TextSpan(
//               text: '$label: ',
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontFamily: 'Inter')),
//           TextSpan(
//               text: value,
//               style: const TextStyle(
//                   fontWeight: FontWeight.normal,
//                   fontFamily: 'Inter',
//                   color: Colors.black54)),
//         ],
//       ),
//     );
//   }

//   // ─── Edit Dialog ─────────────────────────────────────────────────────────

//   void _showEditDialog(ProductData product) {
//     final bloc = context.read<ProductBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final allCategories =
//         bloc.state.allCategories.where((c) => c != 'All').toList();
//     final allUnits = bloc.state.units.map((u) => u.name).toList();

//     List<String> locations = [];
//     DioClient().dio.get('/location/get_locations/').then((r) {
//       if (r.data is Map && r.data['success'] == true) {
//         final data = r.data['data'] as List? ?? [];
//         locations = data
//             .map((l) => l['name']?.toString() ?? '')
//             .where((s) => s.isNotEmpty)
//             .toList();
//       }
//     });

//     final nameController = TextEditingController(text: product.name ?? '');
//     String? selectedCategory =
//         product.category?.isNotEmpty == true ? product.category : null;
//     String? selectedUnit =
//         product.unit?.isNotEmpty == true ? product.unit : null;
//     String? selectedLocation =
//         product.location?.isNotEmpty == true ? product.location : null;
//     bool isVat = product.isVat ?? false;
//     bool isService = product.service ?? false;
//     bool isLoading = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 520.0;

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
//                       height: 200,
//                       child: Center(child: CircularProgressIndicator()))
//                   : SingleChildScrollView(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Header
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Edit Product',
//                                   style: TextStyle(
//                                       fontSize: 17,
//                                       fontFamily: 'Inter',
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black87)),
//                               GestureDetector(
//                                 onTap: () => Navigator.pop(context),
//                                 child: const Icon(Icons.close,
//                                     color: Colors.black54, size: 20),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           const Divider(height: 1, color: Color(0xFFEEEEEE)),
//                           const SizedBox(height: 20),

//                           // Row 1: Product ID + Name
//                           Row(children: [
//                             Expanded(
//                               child: _buildEditFormField(
//                                 label: '* Product ID',
//                                 child: TextFormField(
//                                   initialValue: product.id?.toString() ?? '',
//                                   readOnly: true,
//                                   style: const TextStyle(
//                                       color: Colors.black45,
//                                       fontFamily: 'Inter'),
//                                   decoration: _editInputDecoration(),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildEditFormField(
//                                 label: '* Name',
//                                 child: TextFormField(
//                                   controller: nameController,
//                                   decoration: _editInputDecoration(),
//                                   style: const TextStyle(
//                                       color: Colors.black, fontFamily: 'Inter'),
//                                 ),
//                               ),
//                             ),
//                           ]),
//                           const SizedBox(height: 16),

//                           // Row 2: Category + Unit
//                           Row(children: [
//                             Expanded(
//                               child: _buildEditFormField(
//                                 label: '* Category:',
//                                 child: DropdownButtonFormField<String>(
//                                   initialValue: selectedCategory,
//                                   decoration: _editInputDecoration(),
//                                   isExpanded: true,
//                                   items: allCategories
//                                       .map((c) => DropdownMenuItem(
//                                           value: c,
//                                           child: Text(c,
//                                               overflow: TextOverflow.ellipsis)))
//                                       .toList(),
//                                   onChanged: (val) => setDialogState(
//                                       () => selectedCategory = val),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildEditFormField(
//                                 label: '* Unit:',
//                                 child: DropdownButtonFormField<String>(
//                                   initialValue: selectedUnit,
//                                   decoration: _editInputDecoration(),
//                                   isExpanded: true,
//                                   items: allUnits
//                                       .map((u) => DropdownMenuItem(
//                                           value: u,
//                                           child: Text(u,
//                                               overflow: TextOverflow.ellipsis)))
//                                       .toList(),
//                                   onChanged: (val) =>
//                                       setDialogState(() => selectedUnit = val),
//                                 ),
//                               ),
//                             ),
//                           ]),
//                           const SizedBox(height: 16),

//                           // Row 3: Location + Stock (read-only)
//                           Row(children: [
//                             Expanded(
//                               child: _buildEditFormField(
//                                 label: '* Location:',
//                                 child: DropdownButtonFormField<String>(
//                                   initialValue: selectedLocation,
//                                   decoration: _editInputDecoration(),
//                                   isExpanded: true,
//                                   items: locations
//                                       .map((l) => DropdownMenuItem(
//                                           value: l,
//                                           child: Text(l,
//                                               overflow: TextOverflow.ellipsis)))
//                                       .toList(),
//                                   onChanged: (val) => setDialogState(
//                                       () => selectedLocation = val),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildEditFormField(
//                                 label: 'Stock Quantity',
//                                 child: TextFormField(
//                                   initialValue:
//                                       product.stockQuantity?.toString() ?? '0',
//                                   readOnly: true,
//                                   style: const TextStyle(
//                                       color: Colors.black45,
//                                       fontFamily: 'Inter'),
//                                   decoration: _editInputDecoration(),
//                                 ),
//                               ),
//                             ),
//                           ]),
//                           const SizedBox(height: 16),

//                           // Is VAT toggle
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text('Is VAT:',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.black87)),
//                               Switch(
//                                 value: isVat,
//                                 onChanged: (val) =>
//                                     setDialogState(() => isVat = val),
//                                 activeThumbColor: const Color(0xFFFF9800),
//                               ),
//                             ],
//                           ),

//                           // Is Service toggle
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text('Is Service:',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.black87)),
//                               Switch(
//                                 value: isService,
//                                 onChanged: (val) =>
//                                     setDialogState(() => isService = val),
//                                 activeThumbColor: const Color(0xFFFF9800),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),

//                           // Save Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 setDialogState(() => isLoading = true);
//                                 final navigator = Navigator.of(context);
//                                 try {
//                                   final response = await DioClient().dio.put(
//                                     '/product/update_product/?product_id=${product.id}',
//                                     data: {
//                                       'name': nameController.text.trim(),
//                                       if (selectedCategory != null)
//                                         'category': selectedCategory,
//                                       if (selectedUnit != null)
//                                         'unit': selectedUnit,
//                                       if (selectedLocation != null)
//                                         'location': selectedLocation,
//                                       'is_vat': isVat,
//                                       'service': isService,
//                                     },
//                                   );
//                                   final data = response.data;
//                                   final isSuccess =
//                                       response.statusCode == 200 &&
//                                           (data is Map &&
//                                               (data['success'] == true ||
//                                                   data['success'] == 'true'));
//                                   if (isSuccess) {
//                                     navigator.pop();
//                                     scaffoldMessenger.showSnackBar(SnackBar(
//                                       content: Text(data['message'] ??
//                                           'Product updated successfully'),
//                                       backgroundColor: Colors.green,
//                                     ));
//                                     bloc.add(const FetchProducts());
//                                   } else {
//                                     throw Exception(data is Map
//                                         ? (data['message'] ?? 'Update failed')
//                                         : 'Update failed');
//                                   }
//                                 } catch (e) {
//                                   scaffoldMessenger.showSnackBar(SnackBar(
//                                     content: Text('Failed to update: $e'),
//                                     backgroundColor: Colors.red,
//                                   ));
//                                 } finally {
//                                   if (context.mounted) {
//                                     setDialogState(() => isLoading = false);
//                                   }
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFFF9800),
//                                 foregroundColor: Colors.white,
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 14),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8)),
//                               ),
//                               child: const Text('Save Changes',
//                                   style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ─── Edit Dialog Helpers ──────────────────────────────────────────────────

//   Widget _buildEditFormField({required String label, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFFE8891A))),
//         const SizedBox(height: 6),
//         child,
//       ],
//     );
//   }

//   InputDecoration _editInputDecoration({String? hint}) {
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
//           borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5)),
//       filled: true,
//       fillColor: Colors.white,
//     );
//   }

//   // ─── Bulk Import Dialog ───────────────────────────────────────────────────

//   void _showBulkImportDialog() {
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
//                 children: [
//                   GestureDetector(
//                       onTap: () => Navigator.pop(ctx),
//                       child: const Icon(Icons.arrow_back,
//                           size: 18, color: Colors.black54)),
//                   const SizedBox(width: 10),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Import Bulk Products',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87)),
//                         Text('Upload an Excel file to add products in bulk.',
//                             style:
//                                 TextStyle(fontSize: 11, color: Colors.black54)),
//                       ],
//                     ),
//                   ),
//                   GestureDetector(
//                       onTap: () => Navigator.pop(ctx),
//                       child: const Icon(Icons.close,
//                           color: Colors.black54, size: 18)),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 32),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: const Color(0xFF4CAF50), width: 2),
//                   borderRadius: BorderRadius.circular(8),
//                   color: const Color(0xFFF9FFF9),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(Icons.inbox_outlined,
//                         size: 40, color: Colors.green[600]),
//                     const SizedBox(height: 10),
//                     const Text(
//                         'Click or drag Excel file to this area to upload',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 13, color: Colors.black87)),
//                     const SizedBox(height: 4),
//                     const Text('Only .xlsx files are supported',
//                         style: TextStyle(fontSize: 11, color: Colors.black45)),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green[600],
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Text('Upload File',
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── Build ────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: BlocConsumer<ProductBloc, ProductState>(
//           listener: (context, state) {
//             if (state.errorMessage != null) {
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
//             }
//           },
//           builder: (context, state) {
//             final categories =
//                 state.allCategories.where((c) => c != 'All').toList()..sort();
//             final units = state.units.map((u) => u.name).toList()..sort();

//             final filteredData = state.getFilteredData();
//             final totalPages = _totalPages(filteredData.length);
//             if (_currentPage > totalPages && totalPages > 0) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) setState(() => _currentPage = totalPages);
//               });
//             }

//             final pageItems = _pageSlice(filteredData);
//             final pageAllSelected = pageItems.isNotEmpty &&
//                 pageItems.every((p) => _selectedIds.contains(p.id ?? 0));

//             final hasFilter = (state.selectedCategoryFilter != 'All') ||
//                 (state.selectedUnitFilter != 'All') ||
//                 (state.sortBy != 'No Sorting');

//             return SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ── Title ──
//                     const Text('Products',
//                         style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.w800,
//                             fontFamily: 'Inter',
//                             color: Color(0xFF1A1A1A))),
//                     const SizedBox(height: 4),
//                     Text('Add, edit, or manage product details and inventory.',
//                         style: TextStyle(
//                             fontSize: 13,
//                             fontFamily: 'Inter',
//                             color: Colors.grey[600])),
//                     const SizedBox(height: 12),

//                     // ── Search + New + Bulk Actions ──
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             height: 40,
//                             decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(200),
//                                 border:
//                                     Border.all(color: const Color(0xFFE0E0E0))),
//                             child: TextField(
//                               controller: _searchController,
//                               style: const TextStyle(fontSize: 13),
//                               decoration: const InputDecoration(
//                                 hintText: 'Search...',
//                                 hintStyle: TextStyle(
//                                     fontFamily: 'Inter',
//                                     color: Color(0xFFAAAAAA),
//                                     fontSize: 13),
//                                 prefixIcon: Icon(Icons.search,
//                                     color: Color(0xFFAAAAAA), size: 18),
//                                 border: InputBorder.none,
//                                 contentPadding:
//                                     EdgeInsets.symmetric(vertical: 10),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         ElevatedButton.icon(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => BlocProvider.value(
//                                   value: context.read<ProductBloc>(),
//                                   child: const AddProductScreen(),
//                                 ),
//                               ),
//                             );
//                           },
//                           icon: const Icon(Icons.add,
//                               size: 18, color: Colors.white),
//                           label: const Text('New',
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   fontFamily: 'Inter',
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white)),
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: _orange,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                               elevation: 0),
//                         ),
//                         const SizedBox(width: 6),
//                         // Bulk Actions button
//                         PopupMenuButton<String>(
//                           onSelected: (val) async {
//                             if (val == 'import') {
//                               _showBulkImportDialog();
//                             } else if (val == 'batch') {
//                               try {
//                                 await DioClient().dio.get(
//                                     '/import/download_sample_excel/?template_type=product_batch_pricing');
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content: Text('Downloading...')));
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text('Error: $e')));
//                               }
//                             } else if (val == 'name') {
//                               try {
//                                 await DioClient().dio.get(
//                                     '/import/download_sample_excel/?template_type=product_name_pricing');
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content: Text('Downloading...')));
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text('Error: $e')));
//                               }
//                             }
//                           },
//                           itemBuilder: (ctx) => [
//                             const PopupMenuItem(
//                                 value: 'import', child: Text('Bulk Import')),
//                             const PopupMenuItem(
//                                 value: 'batch',
//                                 child: Text('Download Batch Pricing Template')),
//                             const PopupMenuItem(
//                                 value: 'name',
//                                 child: Text('Download Name Pricing Template')),
//                           ],
//                           child: Container(
//                             padding: const EdgeInsets.all(9),
//                             decoration: BoxDecoration(
//                                 border: Border.all(color: _orange),
//                                 borderRadius: BorderRadius.circular(8)),
//                             child: const Icon(Icons.more_vert,
//                                 color: _orange, size: 20),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // ── Select All + Delete All ──
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         if (pageItems.isNotEmpty)
//                           Row(
//                             children: [
//                               SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: Checkbox(
//                                   value: pageAllSelected,
//                                   onChanged: (v) =>
//                                       _toggleSelectAll(pageItems, v),
//                                   activeColor: _orange,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(4)),
//                                   side: const BorderSide(
//                                       color: Color(0xFFCCCCCC), width: 1.5),
//                                   materialTapTargetSize:
//                                       MaterialTapTargetSize.shrinkWrap,
//                                   visualDensity: VisualDensity.compact,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Text('Select All',
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontFamily: 'Inter',
//                                       color: Colors.grey[600])),
//                             ],
//                           )
//                         else
//                           const SizedBox.shrink(),
//                         TextButton.icon(
//                           onPressed:
//                               _selectedIds.isEmpty ? null : _deleteSelected,
//                           icon: Icon(Icons.delete_outline,
//                               size: 16,
//                               color: _selectedIds.isEmpty
//                                   ? Colors.grey
//                                   : const Color(0xFFD9534F)),
//                           label: Text('Delete All',
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   fontFamily: 'Inter',
//                                   color: _selectedIds.isEmpty
//                                       ? Colors.grey
//                                       : const Color(0xFFD9534F))),
//                           style: TextButton.styleFrom(
//                               padding: EdgeInsets.zero, minimumSize: Size.zero),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // ── Filter Chips ──
//                     _buildFilterChips(categories, units, state, hasFilter),
//                     const SizedBox(height: 16),

//                     // ── Card List or Shimmer ──
//                     state.isLoading
//                         ? _buildShimmer()
//                         : Container(
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border:
//                                     Border.all(color: const Color(0xFFEEEEEE))),
//                             child: Column(
//                               children: [
//                                 pageItems.isEmpty
//                                     ? const SizedBox(
//                                         height: 200,
//                                         child: Center(
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Icon(Icons.inventory_2_outlined,
//                                                   size: 48,
//                                                   color: Color(0xFFCCCCCC)),
//                                               SizedBox(height: 12),
//                                               Text('No products found',
//                                                   style: TextStyle(
//                                                       fontFamily: 'Inter',
//                                                       color: Color(0xFF888888),
//                                                       fontSize: 14)),
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                     : ListView.builder(
//                                         shrinkWrap: true,
//                                         physics:
//                                             const NeverScrollableScrollPhysics(),
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 8),
//                                         itemCount: pageItems.length,
//                                         itemBuilder: (context, index) {
//                                           final product = pageItems[index];
//                                           final isSelected = _selectedIds
//                                               .contains(product.id ?? 0);
//                                           return _ProductCard(
//                                             product: product,
//                                             isSelected: isSelected,
//                                             onSelect: (v) => _toggleSelect(
//                                                 product.id ?? 0, v),
//                                             onView: () =>
//                                                 _showViewDialog(product),
//                                             onEdit: () =>
//                                                 _showEditDialog(product),
//                                             onDelete: () =>
//                                                 _deleteProduct(product),
//                                           );
//                                         },
//                                       ),

//                                 // ── Divider + Pagination ──
//                                 const Divider(
//                                     height: 1, color: Color(0xFFEEEEEE)),
//                                 SizedBox(
//                                   height: 52,
//                                   child: _PaginationBar(
//                                     currentPage: _currentPage,
//                                     totalPages: totalPages,
//                                     onPageChanged: (p) =>
//                                         setState(() => _currentPage = p),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ─── Filter Chips ─────────────────────────────────────────────────────────

//   Widget _buildFilterChips(
//     List<String> categories,
//     List<String> units,
//     ProductState state,
//     bool hasFilter,
//   ) {
//     // Sort options as compact chips
//     final sortOptions = [
//       ('Stock ↓', 'Stock Quantity: High to Low'),
//       ('Stock ↑', 'Stock Quantity: Low to High'),
//       ('A → Z', 'Name: A to Z'),
//       ('Z → A', 'Name: Z to A'),
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Row 1: Category chips (orange = AccountHead style) ──
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               ...categories.map((cat) {
//                 final isSelected = state.selectedCategoryFilter == cat;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() => _currentPage = 1);
//                       context
//                           .read<ProductBloc>()
//                           .add(UpdateCategoryFilter(isSelected ? 'All' : cat));
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: isSelected ? _orange : Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                             color:
//                                 isSelected ? _orange : const Color(0xFFDDDDDD)),
//                       ),
//                       child: Text(cat,
//                           style: TextStyle(
//                               fontSize: 12,
//                               fontFamily: 'Inter',
//                               fontWeight: FontWeight.w500,
//                               color: isSelected
//                                   ? Colors.white
//                                   : const Color(0xFF555555))),
//                     ),
//                   ),
//                 );
//               }),

//               // Sort chips – small pill style (like AccountHead sub-filter)
//               ...sortOptions.map((entry) {
//                 final isSelected = state.sortBy == entry.$2;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() => _currentPage = 1);
//                       context.read<ProductBloc>().add(
//                           SortProducts(isSelected ? 'No Sorting' : entry.$2));
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected ? const Color(0xFFFFF3E0) : Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                             color:
//                                 isSelected ? _orange : const Color(0xFFDDDDDD)),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 6,
//                             height: 6,
//                             decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? _orange
//                                     : const Color(0xFFCCCCCC),
//                                 shape: BoxShape.circle),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(entry.$1,
//                               style: TextStyle(
//                                   fontSize: 11,
//                                   fontFamily: 'Inter',
//                                   fontWeight: FontWeight.w500,
//                                   color: isSelected
//                                       ? _orange
//                                       : const Color(0xFF777777))),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }),

//               // Clear button
//               if (hasFilter)
//                 GestureDetector(
//                   onTap: _clearAllFilters,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFF0F0),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: const Color(0xFFFFCCCC)),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.close, size: 12, color: Color(0xFFD9534F)),
//                         SizedBox(width: 4),
//                         Text('Clear',
//                             style: TextStyle(
//                                 fontSize: 11,
//                                 fontFamily: 'Inter',
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xFFD9534F))),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),

//         // ── Row 2: Unit chips (blue accent) ──
//         if (units.isNotEmpty) ...[
//           const SizedBox(height: 8),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: units.map((unit) {
//                 final isSelected = state.selectedUnitFilter == unit;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() => _currentPage = 1);
//                       context
//                           .read<ProductBloc>()
//                           .add(UpdateUnitFilter(isSelected ? 'All' : unit));
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected ? const Color(0xFFF0F4FF) : Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                             color: isSelected
//                                 ? const Color(0xFF5C7CFA)
//                                 : const Color(0xFFDDDDDD)),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 6,
//                             height: 6,
//                             decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? const Color(0xFF5C7CFA)
//                                     : const Color(0xFFCCCCCC),
//                                 shape: BoxShape.circle),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(unit,
//                               style: TextStyle(
//                                   fontSize: 11,
//                                   fontFamily: 'Inter',
//                                   fontWeight: FontWeight.w500,
//                                   color: isSelected
//                                       ? const Color(0xFF5C7CFA)
//                                       : const Color(0xFF777777))),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   // ─── Shimmer ──────────────────────────────────────────────────────────────

//   Widget _buildShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[200]!,
//       highlightColor: Colors.grey[50]!,
//       child: Container(
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFFEEEEEE))),
//         child: Column(
//           children: List.generate(
//             5,
//             (_) => Column(children: [
//               Container(height: 110, color: Colors.white),
//               const Divider(height: 1, color: Color(0xFFEEEEEE)),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── Product Card ─────────────────────────────────────────────────────────────

// class _ProductCard extends StatelessWidget {
//   final ProductData product;
//   final bool isSelected;
//   final ValueChanged<bool?> onSelect;
//   final VoidCallback onView;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   static const _orange = Color(0xFFE8891A);

//   const _ProductCard({
//     required this.product,
//     required this.isSelected,
//     required this.onSelect,
//     required this.onView,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           color: isSelected ? const Color(0xFFFFF8F0) : Colors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Checkbox ──
//               Padding(
//                 padding: const EdgeInsets.only(top: 2),
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: Checkbox(
//                     value: isSelected,
//                     onChanged: onSelect,
//                     activeColor: _orange,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4)),
//                     side:
//                         const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     visualDensity: VisualDensity.compact,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),

//               // ── Main content ──
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Name + ID badge
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             product.name ?? 'N/A',
//                             style: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Inter',
//                                 color: Color(0xFF1A1A1A)),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF5F5F5),
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(color: const Color(0xFFDDDDDD)),
//                           ),
//                           child: Text(
//                             'ID: ${product.id ?? 0}',
//                             style: const TextStyle(
//                                 fontSize: 11,
//                                 fontFamily: 'Inter',
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xFF555555)),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // Tags: category, unit, location
//                     Wrap(
//                       spacing: 6,
//                       runSpacing: 6,
//                       children: [
//                         if (product.category?.isNotEmpty == true)
//                           _tag(Icons.category_outlined, product.category!,
//                               const Color(0xFFE3F0FF), const Color(0xFF5C7CFA)),
//                         if (product.unit?.isNotEmpty == true)
//                           _tag(Icons.straighten_outlined, product.unit!,
//                               const Color(0xFFEDE7F6), const Color(0xFF9C27B0)),
//                         if (product.location?.isNotEmpty == true)
//                           _tag(Icons.location_on_outlined, product.location!,
//                               const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // Bottom: stock qty + badges + actions
//                     Row(
//                       children: [
//                         // Stock quantity
//                         const Icon(Icons.inventory_2_outlined,
//                             size: 13, color: Color(0xFF888888)),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${product.stockQuantity ?? 0} units',
//                           style: const TextStyle(
//                               fontSize: 13,
//                               fontFamily: 'Inter',
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF333333)),
//                         ),
//                         const SizedBox(width: 8),

//                         // VAT badge
//                         if (product.isVat == true)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 7, vertical: 2),
//                             decoration: BoxDecoration(
//                                 color: const Color(0xFFE8F5E9),
//                                 borderRadius: BorderRadius.circular(4)),
//                             child: const Text('VAT',
//                                 style: TextStyle(
//                                     fontSize: 11,
//                                     fontFamily: 'Inter',
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF2E7D32))),
//                           ),

//                         // Service badge
//                         if (product.service == true) ...[
//                           const SizedBox(width: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 7, vertical: 2),
//                             decoration: BoxDecoration(
//                                 color: const Color(0xFFE3F0FF),
//                                 borderRadius: BorderRadius.circular(4)),
//                             child: const Text('Service',
//                                 style: TextStyle(
//                                     fontSize: 11,
//                                     fontFamily: 'Inter',
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF1565C0))),
//                           ),
//                         ],

//                         const Spacer(),

//                         // Action buttons (view, edit, delete)
//                         _actionBtn(
//                             Icons.remove_red_eye_outlined,
//                             const Color(0xFFEEEEEE),
//                             const Color(0xFF888888),
//                             onView),
//                         const SizedBox(width: 8),
//                         _actionBtn(Icons.edit_outlined, const Color(0xFFFFF3E0),
//                             _orange, onEdit),
//                         const SizedBox(width: 8),
//                         _actionBtn(
//                             Icons.delete_outline,
//                             const Color(0xFFFFEBEE),
//                             const Color(0xFFD9534F),
//                             onDelete),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const Divider(height: 1, color: Color(0xFFEEEEEE)),
//       ],
//     );
//   }

//   Widget _tag(IconData icon, String label, Color bg, Color fg) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration:
//           BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: fg),
//           const SizedBox(width: 4),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 11,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w500,
//                   color: fg),
//               overflow: TextOverflow.ellipsis),
//         ],
//       ),
//     );
//   }

//   Widget _actionBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 32,
//         height: 32,
//         decoration:
//             BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
//         child: Icon(icon, size: 16, color: fg),
//       ),
//     );
//   }
// }

// // ─── Pagination Bar ───────────────────────────────────────────────────────────

// class _PaginationBar extends StatelessWidget {
//   final int currentPage;
//   final int totalPages;
//   final void Function(int) onPageChanged;

//   const _PaginationBar({
//     required this.currentPage,
//     required this.totalPages,
//     required this.onPageChanged,
//   });

//   List<int> _pages() {
//     if (totalPages <= 7) return List.generate(totalPages, (i) => i + 1);
//     final result = <int>[1];
//     if (currentPage > 3) result.add(-1);
//     for (int p = (currentPage - 1).clamp(2, totalPages - 1);
//         p <= (currentPage + 1).clamp(2, totalPages - 1);
//         p++) {
//       result.add(p);
//     }
//     if (currentPage < totalPages - 2) result.add(-1);
//     result.add(totalPages);
//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pages = _pages();
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _PageBtn(
//                 icon: Icons.chevron_left,
//                 onTap: currentPage > 1
//                     ? () => onPageChanged(currentPage - 1)
//                     : null),
//             const SizedBox(width: 4),
//             for (final p in pages) ...[
//               if (p == -1)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 2),
//                   child: Text('…',
//                       style: TextStyle(
//                           color: Color(0xFF888888),
//                           fontFamily: 'Inter',
//                           fontSize: 13)),
//                 )
//               else
//                 _PagePill(
//                     page: p,
//                     isActive: p == currentPage,
//                     onTap: () => onPageChanged(p)),
//               const SizedBox(width: 2),
//             ],
//             _PageBtn(
//                 icon: Icons.chevron_right,
//                 onTap: currentPage < totalPages
//                     ? () => onPageChanged(currentPage + 1)
//                     : null),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _PagePill extends StatelessWidget {
//   final int page;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _PagePill(
//       {required this.page, required this.isActive, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//             border: Border.all(
//                 color: isActive ? const Color(0xFFAAAAAA) : Colors.transparent),
//             borderRadius: BorderRadius.circular(6)),
//         alignment: Alignment.center,
//         child: Text('$page',
//             style: TextStyle(
//                 fontSize: 12,
//                 fontFamily: 'Inter',
//                 fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
//                 color: isActive
//                     ? const Color(0xFF1A1A1A)
//                     : const Color(0xFF555555))),
//       ),
//     );
//   }
// }

// class _PageBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;

//   const _PageBtn({required this.icon, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Icon(icon,
//           size: 20,
//           color: onTap == null
//               ? const Color(0xFFCCCCCC)
//               : const Color(0xFF555555)),
//     );
//   }
// }

// // ─── Add Product Screen ───────────────────────────────────────────────────────
// // (unchanged from original — kept as is)

// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({super.key});

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _hsCodeController = TextEditingController();
//   String? _selectedCategory;
//   String? _selectedUnit;
//   String? _selectedLocation;
//   bool _isVat = true;
//   bool _isHsCode = true;
//   bool _isService = false;
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _categories = [];
//   List<Map<String, dynamic>> _locations = [];
//   List<Map<String, dynamic>> _units = [];
//   static const _orange = Color(0xFFE8891A);

//   @override
//   void initState() {
//     super.initState();
//     _loadDropdowns();
//   }

//   Future<void> _loadDropdowns() async {
//     try {
//       final results = await Future.wait([
//         DioClient().dio.get('/category/get_categories/'),
//         DioClient().dio.get('/location/get_locations/'),
//         DioClient().dio.get('/unit/get_units/'),
//       ]);
//       List<Map<String, dynamic>> flatCats = [];
//       void flattenCats(List items) {
//         for (final item in items) {
//           if (item is Map<String, dynamic>) {
//             flatCats.add(item);
//             final subs = item['subcategories'] as List? ?? [];
//             if (subs.isNotEmpty) flattenCats(subs);
//           }
//         }
//       }

//       if (results[0].data is Map && results[0].data['success'] == true) {
//         flattenCats(results[0].data['data'] as List? ?? []);
//       }
//       List<Map<String, dynamic>> locs = [];
//       if (results[1].data is Map && results[1].data['success'] == true) {
//         locs = List<Map<String, dynamic>>.from(results[1].data['data'] ?? []);
//       }
//       List<Map<String, dynamic>> units = [];
//       if (results[2].data is Map && results[2].data['success'] == true) {
//         units = List<Map<String, dynamic>>.from(results[2].data['data'] ?? []);
//       }
//       if (mounted) {
//         setState(() {
//           _categories = flatCats;
//           _locations = locs;
//           _units = units;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading dropdowns: $e');
//     }
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     final bloc = context.read<ProductBloc>();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final navigator = Navigator.of(context);
//     setState(() => _isLoading = true);
//     try {
//       final response = await DioClient().dio.post(
//         '/product/create_product/',
//         data: {
//           'name': _nameController.text.trim(),
//           if (_selectedCategory != null) 'category': _selectedCategory,
//           if (_selectedLocation != null) 'location': _selectedLocation,
//           if (_selectedUnit != null) 'unit': _selectedUnit,
//           'hs_code': _hsCodeController.text.trim(),
//           'is_vat': _isVat,
//           'service': _isService,
//         },
//       );
//       final data = response.data;
//       final isSuccess =
//           (response.statusCode == 200 || response.statusCode == 201) &&
//               (data is Map &&
//                   (data['success'] == true || data['success'] == 'true'));
//       if (isSuccess) {
//         bloc.add(const FetchProducts());
//         navigator.pop();
//         scaffoldMessenger.showSnackBar(SnackBar(
//           content: Text(data['message'] ?? 'Product created successfully'),
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
//   void dispose() {
//     _nameController.dispose();
//     _hsCodeController.dispose();
//     super.dispose();
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
//                         Text('Add Product',
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87)),
//                         Text('Gracefully fill in the product details below.',
//                             style:
//                                 TextStyle(fontSize: 12, color: Colors.black54)),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: const Color(0xFFEEEEEE)),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('Product Details',
//                               style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87)),
//                           OutlinedButton.icon(
//                             onPressed: () {},
//                             icon: const Icon(Icons.print_outlined,
//                                 size: 14, color: _orange),
//                             label: const Text('Generate Barcode',
//                                 style: TextStyle(fontSize: 12, color: _orange)),
//                             style: OutlinedButton.styleFrom(
//                               side: const BorderSide(color: _orange),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 8),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6)),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       const Divider(height: 1, color: Color(0xFFEEEEEE)),
//                       const SizedBox(height: 16),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                               child: _addField(
//                             label: '* Name',
//                             child: TextFormField(
//                               controller: _nameController,
//                               decoration: _addDeco(hint: 'Product Name'),
//                               validator: (v) => (v == null || v.trim().isEmpty)
//                                   ? 'Name required'
//                                   : null,
//                             ),
//                           )),
//                           const SizedBox(width: 24),
//                           Expanded(
//                               child: _addField(
//                             label: '* Location',
//                             child: Row(children: [
//                               Expanded(
//                                   child: DropdownButtonFormField<String>(
//                                 initialValue: _selectedLocation,
//                                 decoration: _addDeco(hint: 'Select'),
//                                 isExpanded: true,
//                                 items: _locations
//                                     .map((l) => DropdownMenuItem<String>(
//                                           value: l['name']?.toString(),
//                                           child: Text(
//                                               l['name']?.toString() ?? '',
//                                               overflow: TextOverflow.ellipsis),
//                                         ))
//                                     .toList(),
//                                 onChanged: (val) =>
//                                     setState(() => _selectedLocation = val),
//                                 validator: (v) => v == null ? 'Required' : null,
//                               )),
//                               const SizedBox(width: 6),
//                               _addBtn(),
//                             ]),
//                           )),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                               child: _addField(
//                             label: '* Category',
//                             child: Row(children: [
//                               Expanded(
//                                   child: DropdownButtonFormField<String>(
//                                 initialValue: _selectedCategory,
//                                 decoration: _addDeco(hint: 'Select'),
//                                 isExpanded: true,
//                                 items: _categories
//                                     .map((c) => DropdownMenuItem<String>(
//                                           value: c['name']?.toString(),
//                                           child: Text(
//                                               c['name']?.toString() ?? '',
//                                               overflow: TextOverflow.ellipsis),
//                                         ))
//                                     .toList(),
//                                 onChanged: (val) =>
//                                     setState(() => _selectedCategory = val),
//                                 validator: (v) => v == null ? 'Required' : null,
//                               )),
//                               const SizedBox(width: 6),
//                               _addBtn(),
//                             ]),
//                           )),
//                           const SizedBox(width: 24),
//                           Expanded(
//                               child: _addField(
//                             label: '* Unit',
//                             child: Row(children: [
//                               Expanded(
//                                   child: DropdownButtonFormField<String>(
//                                 initialValue: _selectedUnit,
//                                 decoration: _addDeco(hint: 'Select'),
//                                 isExpanded: true,
//                                 items: _units
//                                     .map((u) => DropdownMenuItem<String>(
//                                           value: u['name']?.toString(),
//                                           child: Text(
//                                               u['name']?.toString() ?? '',
//                                               overflow: TextOverflow.ellipsis),
//                                         ))
//                                     .toList(),
//                                 onChanged: (val) =>
//                                     setState(() => _selectedUnit = val),
//                                 validator: (v) => v == null ? 'Required' : null,
//                               )),
//                               const SizedBox(width: 6),
//                               _addBtn(),
//                             ]),
//                           )),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: (MediaQuery.of(context).size.width - 80) / 3,
//                         child: _addField(
//                           label: '* Enter H.S Code',
//                           child: TextFormField(
//                             controller: _hsCodeController,
//                             decoration:
//                                 _addDeco(hint: 'Enter 6-digit H.S co...'),
//                             keyboardType: TextInputType.number,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Divider(height: 1, color: Color(0xFFEEEEEE)),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           _addToggle('Is VAT', _isVat,
//                               (v) => setState(() => _isVat = v)),
//                           const SizedBox(width: 48),
//                           _addToggle('H.S code', _isHsCode,
//                               (v) => setState(() => _isHsCode = v)),
//                           const SizedBox(width: 48),
//                           _addToggle('Service', _isService,
//                               (v) => setState(() => _isService = v)),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       Center(
//                         child: SizedBox(
//                           width: 180,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _submit,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFE0E0E0),
//                               foregroundColor: Colors.black54,
//                               elevation: 0,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6)),
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                                     height: 18,
//                                     width: 18,
//                                     child: CircularProgressIndicator(
//                                         strokeWidth: 2, color: Colors.black54))
//                                 : const Text('Add Product',
//                                     style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _addBtn() {
//     return Container(
//       width: 32,
//       height: 40,
//       decoration:
//           BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(6)),
//       child: const Icon(Icons.add, color: Colors.white, size: 18),
//     );
//   }

//   Widget _addToggle(String label, bool value, ValueChanged<bool> onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87)),
//         Switch(
//             value: value,
//             onChanged: onChanged,
//             activeThumbColor: const Color(0xFF2196F3)),
//       ],
//     );
//   }

//   Widget _addField({required String label, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 12, fontWeight: FontWeight.w500, color: _orange)),
//         const SizedBox(height: 6),
//         child,
//       ],
//     );
//   }

//   InputDecoration _addDeco({String? hint}) {
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
//     );
//   }
// }

// File: lib/screen/product/view/products_screen.dart

// File: lib/screen/product/view/products_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_response.dart';
import 'package:saleup_app/screen/product/bloc/product_bloc.dart';
import 'package:saleup_app/screen/product/bloc/product_event.dart';
import 'package:saleup_app/screen/product/bloc/product_state.dart';

const int _kPageSize = 10;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
      if (!mounted) return;
      context.read<ProductBloc>().add(const FetchProducts());
      context.read<ProductBloc>().add(const FetchUnits());
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
      if (!mounted) return;
      setState(() => _currentPage = 1);
      context.read<ProductBloc>().add(SearchProducts(_searchController.text));
    });
  }

  void _clearAllFilters() {
    setState(() => _currentPage = 1);
    context.read<ProductBloc>().add(const UpdateCategoryFilter('All'));
    context.read<ProductBloc>().add(const UpdateUnitFilter('All'));
    context.read<ProductBloc>().add(const SortProducts('No Sorting'));
    context.read<ProductBloc>().add(const SearchProducts(''));
    _searchController.clear();
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

  void _toggleSelectAll(List<ProductData> items, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(items.map((p) => p.id ?? 0));
      } else {
        _selectedIds.removeAll(items.map((p) => p.id ?? 0));
      }
    });
  }

  List<ProductData> _pageSlice(List<ProductData> filtered) {
    final start = (_currentPage - 1) * _kPageSize;
    if (start >= filtered.length) return [];
    return filtered.sublist(
        start, (start + _kPageSize).clamp(0, filtered.length));
  }

  int _totalPages(int count) => (count / _kPageSize).ceil().clamp(1, 9999);

  // ─── Delete Single ────────────────────────────────────────────────────────

  Future<void> _deleteProduct(ProductData product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Product',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        content: Text(
            'Are you sure you want to delete "${product.name ?? 'this product'}"?',
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
    final bloc = context.read<ProductBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final response = await DioClient().dio.delete(
        '/product/delete_products/',
        data: {
          'product_ids': [product.id]
        },
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 204) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));
      if (isSuccess) {
        setState(() => _selectedIds.remove(product.id));
        bloc.add(const FetchProducts());
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Product deleted successfully'),
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

  // ─── Delete Selected ─────────────────────────────────────────────────────

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Products',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        content: Text('Delete ${_selectedIds.length} selected product(s)?',
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
    final bloc = context.read<ProductBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final response = await DioClient().dio.delete(
        '/product/delete_products/',
        data: {'product_ids': _selectedIds.toList()},
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 204) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));
      if (isSuccess) {
        setState(() => _selectedIds.clear());
        bloc.add(const FetchProducts());
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Products deleted successfully'),
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

  void _showViewDialog(ProductData product) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  const Text('Product Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter')),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 12),
              _buildGridRow('ID', product.id?.toString() ?? 'N/A', 'Name',
                  product.name ?? 'N/A'),
              const Divider(height: 1),
              _buildGridRow('Category', product.category ?? 'N/A', 'Unit',
                  product.unit ?? 'N/A'),
              const Divider(height: 1),
              _buildGridRow('Location', product.location ?? 'N/A', 'Stock',
                  '${product.stockQuantity ?? 0}'),
              const Divider(height: 1),
              _buildGridRow(
                'Is VAT',
                product.isVat == true ? 'Yes' : 'No',
                'Is Service',
                product.service == true ? 'Yes' : 'No',
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

  void _showEditDialog(ProductData product) {
    final bloc = context.read<ProductBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final allCategories =
        bloc.state.allCategories.where((c) => c != 'All').toList();
    final allUnits = bloc.state.units.map((u) => u.name).toList();

    List<String> locations = [];
    DioClient().dio.get('/location/get_locations/').then((r) {
      if (r.data is Map && r.data['success'] == true) {
        final data = r.data['data'] as List? ?? [];
        locations = data
            .map((l) => l['name']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
    });

    final nameController = TextEditingController(text: product.name ?? '');
    String? selectedCategory =
        product.category?.isNotEmpty == true ? product.category : null;
    String? selectedUnit =
        product.unit?.isNotEmpty == true ? product.unit : null;
    String? selectedLocation =
        product.location?.isNotEmpty == true ? product.location : null;
    bool isVat = product.isVat ?? false;
    bool isService = product.service ?? false;
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
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Edit Product',
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

                          // Row 1: Product ID + Name
                          Row(children: [
                            Expanded(
                              child: _buildEditFormField(
                                label: '* Product ID',
                                child: TextFormField(
                                  initialValue: product.id?.toString() ?? '',
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
                                      color: Colors.black, fontFamily: 'Inter'),
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),

                          // Row 2: Category + Unit
                          Row(children: [
                            Expanded(
                              child: _buildEditFormField(
                                label: '* Category:',
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedCategory,
                                  decoration: _editInputDecoration(),
                                  isExpanded: true,
                                  items: allCategories
                                      .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c,
                                              overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (val) => setDialogState(
                                      () => selectedCategory = val),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildEditFormField(
                                label: '* Unit:',
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedUnit,
                                  decoration: _editInputDecoration(),
                                  isExpanded: true,
                                  items: allUnits
                                      .map((u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(u,
                                              overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (val) =>
                                      setDialogState(() => selectedUnit = val),
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),

                          // Row 3: Location + Stock (read-only)
                          Row(children: [
                            Expanded(
                              child: _buildEditFormField(
                                label: '* Location:',
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedLocation,
                                  decoration: _editInputDecoration(),
                                  isExpanded: true,
                                  items: locations
                                      .map((l) => DropdownMenuItem(
                                          value: l,
                                          child: Text(l,
                                              overflow: TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (val) => setDialogState(
                                      () => selectedLocation = val),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildEditFormField(
                                label: 'Stock Quantity',
                                child: TextFormField(
                                  initialValue:
                                      product.stockQuantity?.toString() ?? '0',
                                  readOnly: true,
                                  style: const TextStyle(
                                      color: Colors.black45,
                                      fontFamily: 'Inter'),
                                  decoration: _editInputDecoration(),
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),

                          // Is VAT toggle
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Is VAT:',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                              Switch(
                                value: isVat,
                                onChanged: (val) =>
                                    setDialogState(() => isVat = val),
                                activeThumbColor: const Color(0xFFFF9800),
                              ),
                            ],
                          ),

                          // Is Service toggle
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Is Service:',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                              Switch(
                                value: isService,
                                onChanged: (val) =>
                                    setDialogState(() => isService = val),
                                activeThumbColor: const Color(0xFFFF9800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                setDialogState(() => isLoading = true);
                                final navigator = Navigator.of(context);
                                try {
                                  final response = await DioClient().dio.put(
                                    '/product/update_product/?product_id=${product.id}',
                                    data: {
                                      'name': nameController.text.trim(),
                                      if (selectedCategory != null)
                                        'category': selectedCategory,
                                      if (selectedUnit != null)
                                        'unit': selectedUnit,
                                      if (selectedLocation != null)
                                        'location': selectedLocation,
                                      'is_vat': isVat,
                                      'service': isService,
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
                                          'Product updated successfully'),
                                      backgroundColor: Colors.green,
                                    ));
                                    bloc.add(const FetchProducts());
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

  // ─── Bulk Import Dialog ───────────────────────────────────────────────────

  void _showBulkImportDialog() {
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
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.arrow_back,
                          size: 18, color: Colors.black54)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Import Bulk Products',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('Upload an Excel file to add products in bulk.',
                            style:
                                TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close,
                          color: Colors.black54, size: 18)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF9FFF9),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 40, color: Colors.green[600]),
                    const SizedBox(height: 10),
                    const Text(
                        'Click or drag Excel file to this area to upload',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text('Only .xlsx files are supported',
                        style: TextStyle(fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Upload File',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            final categories =
                state.allCategories.where((c) => c != 'All').toList()..sort();
            final units = state.units.map((u) => u.name).toList()..sort();

            final filteredData = state.getFilteredData();
            final totalPages = _totalPages(filteredData.length);
            if (_currentPage > totalPages && totalPages > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _currentPage = totalPages);
              });
            }

            final pageItems = _pageSlice(filteredData);
            final pageAllSelected = pageItems.isNotEmpty &&
                pageItems.every((p) => _selectedIds.contains(p.id ?? 0));

            final hasFilter = (state.selectedCategoryFilter != 'All') ||
                (state.selectedUnitFilter != 'All') ||
                (state.sortBy != 'No Sorting');

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──
                    const Text('Products',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 4),
                    Text('Add, edit, or manage product details and inventory.',
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Colors.grey[600])),
                    const SizedBox(height: 12),

                    // ── Search + New + Bulk Actions ──
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
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ProductBloc>(),
                                  child: const AddProductScreen(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                          label: const Text('New',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0),
                        ),
                        const SizedBox(width: 6),
                        // Bulk Actions button
                        PopupMenuButton<String>(
                          onSelected: (val) async {
                            if (val == 'import') {
                              _showBulkImportDialog();
                            } else if (val == 'batch') {
                              try {
                                await DioClient().dio.get(
                                    '/import/download_sample_excel/?template_type=product_batch_pricing');
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Downloading...')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')));
                              }
                            } else if (val == 'name') {
                              try {
                                await DioClient().dio.get(
                                    '/import/download_sample_excel/?template_type=product_name_pricing');
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Downloading...')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')));
                              }
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                                value: 'import', child: Text('Bulk Import')),
                            const PopupMenuItem(
                                value: 'batch',
                                child: Text('Download Batch Pricing Template')),
                            const PopupMenuItem(
                                value: 'name',
                                child: Text('Download Name Pricing Template')),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                                border: Border.all(color: _orange),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.more_vert,
                                color: _orange, size: 20),
                          ),
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
                    const SizedBox(height: 12),

                    // ── Filter Section ──
                    _buildFilterSection(categories, units, state, hasFilter),
                    const SizedBox(height: 16),

                    // ── Card List or Shimmer ──
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
                                              Icon(Icons.inventory_2_outlined,
                                                  size: 48,
                                                  color: Color(0xFFCCCCCC)),
                                              SizedBox(height: 12),
                                              Text('No products found',
                                                  style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      color: Color(0xFF888888),
                                                      fontSize: 14)),
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
                                          final product = pageItems[index];
                                          final isSelected = _selectedIds
                                              .contains(product.id ?? 0);
                                          return _ProductCard(
                                            product: product,
                                            isSelected: isSelected,
                                            onSelect: (v) => _toggleSelect(
                                                product.id ?? 0, v),
                                            onView: () =>
                                                _showViewDialog(product),
                                            onEdit: () =>
                                                _showEditDialog(product),
                                            onDelete: () =>
                                                _deleteProduct(product),
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

  // ─── Filter Section ────────────────────────────────────────────────────────

  Widget _buildFilterSection(
    List<String> categories,
    List<String> units,
    ProductState state,
    bool hasFilter,
  ) {
    final sortOptions = [
      ('Stock ↑', 'Stock Quantity: High to Low'),
      ('Stock ↓', 'Stock Quantity: Low to High'),
      ('A → Z', 'Name: A to Z'),
      ('Z → A', 'Name: Z to A'),
    ];

    final selectedCat = state.selectedCategoryFilter != 'All'
        ? state.selectedCategoryFilter
        : null;
    final selectedUnit =
        state.selectedUnitFilter != 'All' ? state.selectedUnitFilter : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter Bar ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Category trigger
              if (categories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterTrigger(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: selectedCat,
                    accentColor: _orange,
                    onTap: () => _showFilterSheet(
                      title: 'Category',
                      items: categories,
                      selectedItem: selectedCat,
                      accentColor: _orange,
                      onSelected: (val) {
                        setState(() => _currentPage = 1);
                        context
                            .read<ProductBloc>()
                            .add(UpdateCategoryFilter(val));
                      },
                    ),
                  ),
                ),

              // Unit trigger
              if (units.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterTrigger(
                    icon: Icons.straighten_outlined,
                    label: 'Unit',
                    value: selectedUnit,
                    accentColor: const Color(0xFF5C7CFA),
                    onTap: () => _showFilterSheet(
                      title: 'Unit',
                      items: units,
                      selectedItem: selectedUnit,
                      accentColor: const Color(0xFF5C7CFA),
                      onSelected: (val) {
                        setState(() => _currentPage = 1);
                        context.read<ProductBloc>().add(UpdateUnitFilter(val));
                      },
                    ),
                  ),
                ),

              // Sort pills
              ...sortOptions.map((entry) {
                final isActive = state.sortBy == entry.$2;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildSortPill(
                    label: entry.$1,
                    isActive: isActive,
                    onTap: () {
                      setState(() => _currentPage = 1);
                      context.read<ProductBloc>().add(
                          SortProducts(isActive ? 'No Sorting' : entry.$2));
                    },
                  ),
                );
              }),

              // Clear all
              if (hasFilter)
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        Text('Clear All',
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
          ),
        ),

        // ── Active Filters ──
        if (hasFilter) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (selectedCat != null)
                _buildActiveChip(
                  label: selectedCat,
                  onRemove: () {
                    setState(() => _currentPage = 1);
                    context
                        .read<ProductBloc>()
                        .add(const UpdateCategoryFilter('All'));
                  },
                  color: _orange,
                ),
              if (selectedUnit != null)
                _buildActiveChip(
                  label: selectedUnit,
                  onRemove: () {
                    setState(() => _currentPage = 1);
                    context
                        .read<ProductBloc>()
                        .add(const UpdateUnitFilter('All'));
                  },
                  color: const Color(0xFF5C7CFA),
                ),
              if (state.sortBy != 'No Sorting')
                _buildActiveChip(
                  label: state.sortBy,
                  onRemove: () {
                    setState(() => _currentPage = 1);
                    context
                        .read<ProductBloc>()
                        .add(const SortProducts('No Sorting'));
                  },
                  color: const Color(0xFF9C27B0),
                ),
            ],
          ),
        ],
      ],
    );
  }

  // ─── Filter Trigger Chip (dropdown style) ─────────────────────────────────

  Widget _buildFilterTrigger({
    required IconData icon,
    required String label,
    required String? value,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: hasValue ? accentColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasValue ? accentColor : const Color(0xFFDDDDDD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: hasValue ? accentColor : const Color(0xFF888888)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                hasValue ? value! : label,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: hasValue ? accentColor : const Color(0xFF555555),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 14,
                color: hasValue ? accentColor : const Color(0xFF888888)),
          ],
        ),
      ),
    );
  }

  // ─── Sort Pill ─────────────────────────────────────────────────────────────

  Widget _buildSortPill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isActive ? _orange : const Color(0xFFDDDDDD)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? _orange : const Color(0xFFCCCCCC),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: isActive ? _orange : const Color(0xFF777777),
                )),
          ],
        ),
      ),
    );
  }

  // ─── Active Filter Chip (removable) ───────────────────────────────────────

  Widget _buildActiveChip({
    required String label,
    required VoidCallback onRemove,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 12, color: color),
          ),
        ],
      ),
    );
  }

  // ─── Filter Bottom Sheet (searchable, scalable) ───────────────────────────

  void _showFilterSheet({
    required String title,
    required List<String> items,
    required String? selectedItem,
    required Color accentColor,
    required void Function(String) onSelected,
  }) {
    final searchController = TextEditingController();
    List<String> filteredItems = List.from(items);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filter by $title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              color: Colors.black87,
                            )),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  // Search bar (only when many items)
                  if (items.length > 5)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: TextField(
                        controller: searchController,
                        style:
                            const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Search $title...',
                          hintStyle: const TextStyle(
                              color: Color(0xFFAAAAAA), fontSize: 13),
                          prefixIcon: const Icon(Icons.search,
                              size: 18, color: Color(0xFFAAAAAA)),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFDDDDDD)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFDDDDDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: accentColor, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (val) {
                          setSheetState(() {
                            filteredItems = items
                                .where((i) =>
                                    i.toLowerCase().contains(val.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),

                  const SizedBox(height: 8),

                  // "All" option
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.select_all,
                        size: 20,
                        color: selectedItem == null
                            ? accentColor
                            : const Color(0xFF888888)),
                    title: Text('All',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: selectedItem == null
                              ? accentColor
                              : const Color(0xFF555555),
                        )),
                    trailing: selectedItem == null
                        ? Icon(Icons.check, size: 18, color: accentColor)
                        : null,
                    onTap: () {
                      onSelected('All');
                      Navigator.pop(ctx);
                    },
                  ),

                  const Divider(height: 1),

                  // Items list
                  Expanded(
                    child: filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No results found',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF888888),
                                    fontSize: 13)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: filteredItems.length,
                            itemBuilder: (ctx, index) {
                              final item = filteredItems[index];
                              final isSelected = item == selectedItem;
                              return ListTile(
                                dense: true,
                                title: Text(item,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? accentColor
                                          : const Color(0xFF333333),
                                    )),
                                trailing: isSelected
                                    ? Icon(Icons.check,
                                        size: 18, color: accentColor)
                                    : null,
                                onTap: () {
                                  onSelected(item);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
            5,
            (_) => Column(children: [
              Container(height: 110, color: Colors.white),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductData product;
  final bool isSelected;
  final ValueChanged<bool?> onSelect;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _orange = Color(0xFFE8891A);

  const _ProductCard({
    required this.product,
    required this.isSelected,
    required this.onSelect,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: isSelected ? const Color(0xFFFFF8F0) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Checkbox ──
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: onSelect,
                    activeColor: _orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    side:
                        const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Main content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + ID badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name ?? 'N/A',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                color: Color(0xFF1A1A1A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFDDDDDD)),
                          ),
                          child: Text(
                            'ID: ${product.id ?? 0}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF555555)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tags: category, unit, location
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (product.category?.isNotEmpty == true)
                          _tag(Icons.category_outlined, product.category!,
                              const Color(0xFFE3F0FF), const Color(0xFF5C7CFA)),
                        if (product.unit?.isNotEmpty == true)
                          _tag(Icons.straighten_outlined, product.unit!,
                              const Color(0xFFEDE7F6), const Color(0xFF9C27B0)),
                        if (product.location?.isNotEmpty == true)
                          _tag(Icons.location_on_outlined, product.location!,
                              const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Bottom: stock qty + badges + actions
                    Row(
                      children: [
                        // Stock quantity
                        const Icon(Icons.inventory_2_outlined,
                            size: 13, color: Color(0xFF888888)),
                        const SizedBox(width: 4),
                        Text(
                          '${product.stockQuantity ?? 0} units',
                          style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333)),
                        ),
                        const SizedBox(width: 8),

                        // VAT badge
                        if (product.isVat == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('VAT',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32))),
                          ),

                        // Service badge
                        if (product.service == true) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE3F0FF),
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('Service',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1565C0))),
                          ),
                        ],

                        const Spacer(),

                        // Action buttons (view, edit, delete)
                        _actionBtn(
                            Icons.remove_red_eye_outlined,
                            const Color(0xFFEEEEEE),
                            const Color(0xFF888888),
                            onView),
                        const SizedBox(width: 8),
                        _actionBtn(Icons.edit_outlined, const Color(0xFFFFF3E0),
                            _orange, onEdit),
                        const SizedBox(width: 8),
                        _actionBtn(
                            Icons.delete_outline,
                            const Color(0xFFFFEBEE),
                            const Color(0xFFD9534F),
                            onDelete),
                      ],
                    ),
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

  Widget _tag(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: fg),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: fg),
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

// ─── Add Product Screen ───────────────────────────────────────────────────────

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hsCodeController = TextEditingController();
  String? _selectedCategory;
  String? _selectedUnit;
  String? _selectedLocation;
  bool _isVat = true;
  bool _isHsCode = true;
  bool _isService = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _units = [];
  static const _orange = Color(0xFFE8891A);

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    try {
      final results = await Future.wait([
        DioClient().dio.get('/category/get_categories/'),
        DioClient().dio.get('/location/get_locations/'),
        DioClient().dio.get('/unit/get_units/'),
      ]);
      List<Map<String, dynamic>> flatCats = [];
      void flattenCats(List items) {
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            flatCats.add(item);
            final subs = item['subcategories'] as List? ?? [];
            if (subs.isNotEmpty) flattenCats(subs);
          }
        }
      }

      if (results[0].data is Map && results[0].data['success'] == true) {
        flattenCats(results[0].data['data'] as List? ?? []);
      }
      List<Map<String, dynamic>> locs = [];
      if (results[1].data is Map && results[1].data['success'] == true) {
        locs = List<Map<String, dynamic>>.from(results[1].data['data'] ?? []);
      }
      List<Map<String, dynamic>> units = [];
      if (results[2].data is Map && results[2].data['success'] == true) {
        units = List<Map<String, dynamic>>.from(results[2].data['data'] ?? []);
      }
      if (mounted) {
        setState(() {
          _categories = flatCats;
          _locations = locs;
          _units = units;
        });
      }
    } catch (e) {
      debugPrint('Error loading dropdowns: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<ProductBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);
    try {
      final response = await DioClient().dio.post(
        '/product/create_product/',
        data: {
          'name': _nameController.text.trim(),
          if (_selectedCategory != null) 'category': _selectedCategory,
          if (_selectedLocation != null) 'location': _selectedLocation,
          if (_selectedUnit != null) 'unit': _selectedUnit,
          'hs_code': _hsCodeController.text.trim(),
          'is_vat': _isVat,
          'service': _isService,
        },
      );
      final data = response.data;
      final isSuccess =
          (response.statusCode == 200 || response.statusCode == 201) &&
              (data is Map &&
                  (data['success'] == true || data['success'] == 'true'));
      if (isSuccess) {
        bloc.add(const FetchProducts());
        navigator.pop();
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Product created successfully'),
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
  void dispose() {
    _nameController.dispose();
    _hsCodeController.dispose();
    super.dispose();
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
                        Text('Add Product',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('Gracefully fill in the product details below.',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Product Details',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.print_outlined,
                                size: 14, color: _orange),
                            label: const Text('Generate Barcode',
                                style: TextStyle(fontSize: 12, color: _orange)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _orange),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _addField(
                            label: '* Name',
                            child: TextFormField(
                              controller: _nameController,
                              decoration: _addDeco(hint: 'Product Name'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name required'
                                  : null,
                            ),
                          )),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _addField(
                            label: '* Location',
                            child: Row(children: [
                              Expanded(
                                  child: DropdownButtonFormField<String>(
                                initialValue: _selectedLocation,
                                decoration: _addDeco(hint: 'Select'),
                                isExpanded: true,
                                items: _locations
                                    .map((l) => DropdownMenuItem<String>(
                                          value: l['name']?.toString(),
                                          child: Text(
                                              l['name']?.toString() ?? '',
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedLocation = val),
                                validator: (v) => v == null ? 'Required' : null,
                              )),
                              const SizedBox(width: 6),
                              _addBtn(),
                            ]),
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _addField(
                            label: '* Category',
                            child: Row(children: [
                              Expanded(
                                  child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: _addDeco(hint: 'Select'),
                                isExpanded: true,
                                items: _categories
                                    .map((c) => DropdownMenuItem<String>(
                                          value: c['name']?.toString(),
                                          child: Text(
                                              c['name']?.toString() ?? '',
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedCategory = val),
                                validator: (v) => v == null ? 'Required' : null,
                              )),
                              const SizedBox(width: 6),
                              _addBtn(),
                            ]),
                          )),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _addField(
                            label: '* Unit',
                            child: Row(children: [
                              Expanded(
                                  child: DropdownButtonFormField<String>(
                                initialValue: _selectedUnit,
                                decoration: _addDeco(hint: 'Select'),
                                isExpanded: true,
                                items: _units
                                    .map((u) => DropdownMenuItem<String>(
                                          value: u['name']?.toString(),
                                          child: Text(
                                              u['name']?.toString() ?? '',
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedUnit = val),
                                validator: (v) => v == null ? 'Required' : null,
                              )),
                              const SizedBox(width: 6),
                              _addBtn(),
                            ]),
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 3,
                        child: _addField(
                          label: '* Enter H.S Code',
                          child: TextFormField(
                            controller: _hsCodeController,
                            decoration:
                                _addDeco(hint: 'Enter 6-digit H.S co...'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _addToggle('Is VAT', _isVat,
                              (v) => setState(() => _isVat = v)),
                          const SizedBox(width: 48),
                          _addToggle('H.S code', _isHsCode,
                              (v) => setState(() => _isHsCode = v)),
                          const SizedBox(width: 48),
                          _addToggle('Service', _isService,
                              (v) => setState(() => _isService = v)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: 180,
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
                                : const Text('Add Product',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                          ),
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

  Widget _addBtn() {
    return Container(
      width: 32,
      height: 40,
      decoration:
          BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(6)),
      child: const Icon(Icons.add, color: Colors.white, size: 18),
    );
  }

  Widget _addToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF2196F3)),
      ],
    );
  }

  Widget _addField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: _orange)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _addDeco({String? hint}) {
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
    );
  }
}
