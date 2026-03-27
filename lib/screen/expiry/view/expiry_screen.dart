// // lib/screen/expiry/view/expiry_screen.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/model/expiry_response.dart';
// import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
// import 'package:saleup_app/screen/expiry/bloc/expiry_event.dart';
// import 'package:saleup_app/screen/expiry/bloc/expiry_state.dart';
// import 'package:saleup_app/screen/expiry/view/add_expiry_screen.dart';

// class ExpiryScreen extends StatefulWidget {
//   const ExpiryScreen({super.key});

//   @override
//   State<ExpiryScreen> createState() => _ExpiryScreenState();
// }

// class _ExpiryScreenState extends State<ExpiryScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;

//   String? _expandedSection;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) context.read<ExpiryBloc>().add(const FetchExpiry());
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
//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (mounted) context.read<ExpiryBloc>().add(SearchExpiry(query));
//     });
//   }

//   void _toggleSection(String section) {
//     setState(() {
//       _expandedSection = _expandedSection == section ? null : section;
//     });
//   }

//   void _clearAllFilters() {
//     context.read<ExpiryBloc>().add(const ClearFilters());
//     setState(() => _expandedSection = null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F5F5),
//         body: BlocConsumer<ExpiryBloc, ExpiryState>(
//           listener: (context, state) {
//             if (state.errorMessage != null) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(state.errorMessage!),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           builder: (context, state) {
//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildHeader(),
//                   _buildTopBar(context, state),
//                   _buildFilterPanel(context, state),
//                   _buildTableCard(context, state),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ====================== HEADER ======================
//   Widget _buildHeader() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Expiry',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1A1A1A),
//             ),
//           ),
//           const SizedBox(height: 3),
//           Text(
//             'Set up expiry for products and track product expiry dates',
//             style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   // ====================== TOP BAR ======================
//   Widget _buildTopBar(BuildContext context, ExpiryState state) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 190,
//             height: 38,
//             child: TextField(
//               controller: _searchController,
//               onChanged: _onSearchChanged,
//               style: const TextStyle(fontSize: 13),
//               decoration: InputDecoration(
//                 hintText: 'Search by product or batch…',
//                 hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
//                 prefixIcon:
//                     Icon(Icons.search, color: Colors.grey[400], size: 18),
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: BorderSide(color: Colors.grey[300]!),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: BorderSide(color: Colors.grey[300]!),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(color: Color(0xFF4CAF50)),
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//           ElevatedButton.icon(
//             onPressed: () {
//               // FIX: rootNavigator:true so GoRouter doesn't intercept the push
//               Navigator.of(context, rootNavigator: true).push(
//                 MaterialPageRoute(
//                   builder: (_) => BlocProvider.value(
//                     value: context.read<ExpiryBloc>(),
//                     child: const AddExpiryScreen(),
//                   ),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.add, size: 16, color: Colors.white),
//             label: const Text(
//               'New Expiry',
//               style: TextStyle(color: Colors.white, fontSize: 13),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFF6B35),
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               elevation: 0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ====================== FILTER PANEL ======================
//   Widget _buildFilterPanel(BuildContext context, ExpiryState state) {
//     final hasActive = state.selectedProduct != null ||
//         state.priceSort != null ||
//         state.quantitySort != null;

//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Filters',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 4),

//             // ================== PRODUCT FILTER (Dynamic - No Hardcode) ==================
//             _buildFilterSection(
//               title: 'Product',
//               isExpanded: _expandedSection == 'product',
//               onTap: () => _toggleSection('product'),
//               children: state.uniqueProducts.map((product) {
//                 return _filterOption(
//                   label: product,
//                   selected: state.selectedProduct == product,
//                   onTap: () {
//                     final newProduct =
//                         state.selectedProduct == product ? null : product;
//                     context
//                         .read<ExpiryBloc>()
//                         .add(ToggleProductFilter(newProduct));
//                     setState(() => _expandedSection = null);
//                   },
//                 );
//               }).toList(),
//             ),

//             // ================== PRICE FILTER ==================
//             _buildFilterSection(
//               title: 'Price',
//               isExpanded: _expandedSection == 'price',
//               onTap: () => _toggleSection('price'),
//               children: [
//                 _filterOption(
//                   label: 'High to Low',
//                   selected: state.priceSort == 'High to Low',
//                   onTap: () {
//                     final newSort =
//                         state.priceSort == 'High to Low' ? null : 'High to Low';
//                     context.read<ExpiryBloc>().add(SetPriceSort(newSort));
//                     setState(() => _expandedSection = null);
//                   },
//                 ),
//                 _filterOption(
//                   label: 'Low to High',
//                   selected: state.priceSort == 'Low to High',
//                   onTap: () {
//                     final newSort =
//                         state.priceSort == 'Low to High' ? null : 'Low to High';
//                     context.read<ExpiryBloc>().add(SetPriceSort(newSort));
//                     setState(() => _expandedSection = null);
//                   },
//                 ),
//               ],
//             ),

//             // ================== QUANTITY FILTER ==================
//             _buildFilterSection(
//               title: 'Quantity',
//               isExpanded: _expandedSection == 'quantity',
//               onTap: () => _toggleSection('quantity'),
//               children: [
//                 _filterOption(
//                   label: 'High to Low',
//                   selected: state.quantitySort == 'High to Low',
//                   onTap: () {
//                     final newSort = state.quantitySort == 'High to Low'
//                         ? null
//                         : 'High to Low';
//                     context.read<ExpiryBloc>().add(SetQuantitySort(newSort));
//                     setState(() => _expandedSection = null);
//                   },
//                 ),
//                 _filterOption(
//                   label: 'Low to High',
//                   selected: state.quantitySort == 'Low to High',
//                   onTap: () {
//                     final newSort = state.quantitySort == 'Low to High'
//                         ? null
//                         : 'Low to High';
//                     context.read<ExpiryBloc>().add(SetQuantitySort(newSort));
//                     setState(() => _expandedSection = null);
//                   },
//                 ),
//               ],
//             ),

//             if (hasActive) ...[
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: _clearAllFilters,
//                 child: const Text(
//                   'Clear Filters',
//                   style: TextStyle(
//                     color: Color(0xFFE53935),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterSection({
//     required String title,
//     required bool isExpanded,
//     required VoidCallback onTap,
//     required List<Widget> children,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(4),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Icon(
//                   isExpanded
//                       ? Icons.keyboard_arrow_up
//                       : Icons.keyboard_arrow_down,
//                   size: 20,
//                   color: Colors.black54,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (isExpanded)
//           Padding(
//             padding: const EdgeInsets.only(left: 12, bottom: 4),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: children,
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _filterOption({
//     required String label,
//     required bool selected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(4),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 7),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             color: selected ? const Color(0xFF4CAF50) : const Color(0xFF555555),
//             fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   // ====================== TABLE CARD ======================
//   Widget _buildTableCard(BuildContext context, ExpiryState state) {
//     // Sort ascending by ID (nulls last)
//     final filtered = state.getFilteredData()
//       ..sort((a, b) => (a.id ?? double.maxFinite.toInt())
//           .compareTo(b.id ?? double.maxFinite.toInt()));
//     final totalPages =
//         filtered.isEmpty ? 1 : (filtered.length / state.itemsPerPage).ceil();
//     final page = state.currentPage.clamp(1, totalPages);
//     final start = ((page - 1) * state.itemsPerPage).clamp(0, filtered.length);
//     final end = (start + state.itemsPerPage).clamp(0, filtered.length);
//     final pageData = filtered.sublist(start, end);

//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.centerRight,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(0, 8, 16, 4),
//               child: GestureDetector(
//                 // FIX: disabled + guarded when no data
//                 onTap:
//                     filtered.isEmpty ? null : () => _confirmDeleteAll(context),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.delete_outline,
//                         size: 14,
//                         color: filtered.isEmpty
//                             ? Colors.grey[400]
//                             : Colors.orange[700]),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Delete All',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: filtered.isEmpty
//                             ? Colors.grey[400]
//                             : Colors.orange[700],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildTableHeader(),
//                 state.isLoading
//                     ? _buildSkeleton()
//                     : pageData.isEmpty
//                         ? const Padding(
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 40, horizontal: 24),
//                             child: Text(
//                               'No expiry data found',
//                               style:
//                                   TextStyle(color: Colors.grey, fontSize: 14),
//                             ),
//                           )
//                         : Column(
//                             children: List.generate(
//                               pageData.length,
//                               (i) => _buildTableRow(context, pageData[i], i),
//                             ),
//                           ),
//               ],
//             ),
//           ),
//           if (!state.isLoading && totalPages > 1)
//             _buildPagination(context, page, totalPages),
//         ],
//       ),
//     );
//   }

//   static const double _colId = 30;
//   static const double _colProduct = 70;
//   static const double _colBatch = 100;
//   static const double _colExpiry = 80;
//   static const double _colStatus = 90;
//   static const double _colPrice = 100;
//   static const double _colQty = 70;
//   static const double _colAction = 150;

//   Widget _buildTableHeader() {
//     const style = TextStyle(
//       fontSize: 12,
//       fontWeight: FontWeight.w600,
//       color: Color(0xFF555555),
//     );
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFFAFAFA),
//         border: Border(
//           top: BorderSide(color: Colors.grey[200]!),
//           bottom: BorderSide(color: Colors.grey[200]!),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(width: 40, child: SizedBox(height: 40)),
//           _hCell('ID', width: _colId, style: style),
//           _hCell('Product', width: _colProduct, style: style),
//           _hCell('Batch Number', width: _colBatch, style: style),
//           _hCell('Expiry Date', width: _colExpiry, style: style),
//           _hCell('Is Expired', width: _colStatus, style: style),
//           _hCell('Selling Price', width: _colPrice, style: style),
//           _hCell('Quantity', width: _colQty, style: style),
//           _hCell('Action', width: _colAction, style: style),
//         ],
//       ),
//     );
//   }

//   Widget _hCell(String label,
//       {required double width, required TextStyle style}) {
//     return SizedBox(
//       width: width,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//         child: Text(label, style: style),
//       ),
//     );
//   }

//   Widget _buildTableRow(BuildContext context, ExpiryData item, int index) {
//     final isExpired = item.isExpired ?? false;
//     return Container(
//       decoration: BoxDecoration(
//         color: index.isEven ? Colors.white : const Color(0xFFFAFAFA),
//         border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(
//             width: 40,
//             child: Checkbox(value: false, onChanged: (_) {}),
//           ),
//           _dCell('${item.id ?? '-'}', width: _colId),
//           _dCell(item.product ?? '-', width: _colProduct),
//           _dCell(item.batchNumber ?? '-', width: _colBatch),
//           _dCell(
//             item.expiryDate != null
//                 ? item.expiryDate!.toIso8601String().split('T')[0]
//                 : '-',
//             width: _colExpiry,
//           ),
//           SizedBox(
//             width: _colStatus,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: isExpired
//                       ? const Color(0xFFFFEBEB)
//                       : const Color(0xFFE8F5E9),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   isExpired ? 'Expired' : 'Valid',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: isExpired
//                         ? const Color(0xFFD32F2F)
//                         : const Color(0xFF388E3C),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           _dCell(
//             'NPR ${item.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
//             width: _colPrice,
//           ),
//           _dCell('${item.quantity ?? 0}', width: _colQty),
//           SizedBox(
//             width: _colAction,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit_outlined,
//                       size: 17, color: Colors.grey),
//                   // FIX: null-guard on id
//                   onPressed: item.id == null
//                       ? null
//                       : () => _showEditDialog(context, item),
//                   constraints: const BoxConstraints(),
//                   padding: const EdgeInsets.all(6),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.visibility_outlined,
//                       size: 17, color: Colors.grey),
//                   onPressed: () => _showDetailDialog(context, item),
//                   constraints: const BoxConstraints(),
//                   padding: const EdgeInsets.all(6),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline,
//                       size: 17, color: Colors.grey),
//                   // FIX: null-guard on id
//                   onPressed: item.id == null
//                       ? null
//                       : () => _confirmDelete(context, item.id!),
//                   constraints: const BoxConstraints(),
//                   padding: const EdgeInsets.all(6),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _dCell(String text, {required double width}) {
//     return SizedBox(
//       width: width,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//         child: Text(
//           text,
//           style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }

//   // ====================== PAGINATION ======================
//   Widget _buildPagination(
//       BuildContext context, int currentPage, int totalPages) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.chevron_left, size: 20),
//             onPressed: currentPage > 1
//                 ? () =>
//                     context.read<ExpiryBloc>().add(GoToPage(currentPage - 1))
//                 : null,
//           ),
//           for (int i = 1; i <= totalPages; i++)
//             GestureDetector(
//               onTap: () => context.read<ExpiryBloc>().add(GoToPage(i)),
//               child: Container(
//                 width: 30,
//                 height: 30,
//                 margin: const EdgeInsets.symmetric(horizontal: 3),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(
//                     color: i == currentPage
//                         ? const Color(0xFF4CAF50)
//                         : Colors.grey[300]!,
//                   ),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '$i',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: i == currentPage
//                           ? const Color(0xFF4CAF50)
//                           : const Color(0xFF555555),
//                       fontWeight: i == currentPage
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           IconButton(
//             icon: const Icon(Icons.chevron_right, size: 20),
//             onPressed: currentPage < totalPages
//                 ? () =>
//                     context.read<ExpiryBloc>().add(GoToPage(currentPage + 1))
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }

//   // ====================== SKELETON ======================
//   Widget _buildSkeleton() {
//     return Column(
//       children: List.generate(
//         6,
//         (_) => Container(
//           height: 44,
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//       ),
//     );
//   }

//   // ====================== DETAIL DIALOG ======================
//   void _showDetailDialog(BuildContext context, ExpiryData item) {
//     showDialog(
//       context: context,
//       // FIX: useRootNavigator:true pushes dialog onto the root Navigator,
//       // so closing it never touches GoRouter's page stack.
//       useRootNavigator: true,
//       builder: (dialogCtx) => AlertDialog(
//         title: Text(
//           item.product ?? 'N/A',
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _detailRow('ID', '${item.id ?? '-'}'),
//             _detailRow('Batch Number', item.batchNumber ?? '-'),
//             _detailRow(
//               'Expiry Date',
//               item.expiryDate?.toIso8601String().split('T')[0] ?? '-',
//             ),
//             _detailRow(
//               'Selling Price',
//               'NPR ${item.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
//             ),
//             _detailRow(
//               'Cost Price',
//               'NPR ${item.costPrice?.toStringAsFixed(2) ?? '0.00'}',
//             ),
//             _detailRow('Quantity', '${item.quantity ?? 0}'),
//             _detailRow('Is Expired', item.isExpired == true ? 'Yes' : 'No'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             // FIX: use dialogCtx — only closes the dialog, not the page
//             onPressed: () => Navigator.of(dialogCtx).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(fontSize: 13)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ====================== EDIT DIALOG ======================
//   void _showEditDialog(BuildContext context, ExpiryData item) {
//     // Replace the body of this dialog with your real edit form/sheet.
//     showDialog(
//       context: context,
//       useRootNavigator: true,
//       builder: (dialogCtx) => AlertDialog(
//         title: const Text('Edit Expiry'),
//         content:
//             Text('Edit feature for "${item.product ?? 'item'}" coming soon.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogCtx).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ====================== DELETE SINGLE ======================
//   void _confirmDelete(BuildContext context, int id) {
//     // FIX: capture bloc BEFORE entering the dialog so it stays valid
//     // even if the widget tree rebuilds while the dialog is open.
//     final bloc = context.read<ExpiryBloc>();

//     showDialog(
//       context: context,
//       useRootNavigator: true, // FIX: prevents GoRouter from intercepting pop
//       builder: (dialogCtx) => AlertDialog(
//         title: const Text('Delete Expiry'),
//         content: const Text('Are you sure you want to delete this record?'),
//         actions: [
//           TextButton(
//             // FIX: dialogCtx — only closes the dialog
//             onPressed: () => Navigator.of(dialogCtx).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               // FIX: close dialog first, then dispatch via captured bloc ref
//               Navigator.of(dialogCtx).pop();
//               bloc.add(DeleteExpiry(id));
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ====================== DELETE ALL ======================
//   void _confirmDeleteAll(BuildContext context) {
//     final bloc = context.read<ExpiryBloc>();

//     showDialog(
//       context: context,
//       useRootNavigator: true,
//       builder: (dialogCtx) => AlertDialog(
//         title: const Text('Delete All'),
//         content:
//             const Text('Are you sure you want to delete all expiry records?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogCtx).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogCtx).pop();
//               // Dispatch your DeleteAll event here:
//               // bloc.add(const DeleteAllExpiry());
//             },
//             child:
//                 const Text('Delete All', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screen/expiry/view/expiry_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/model/expiry_response.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_event.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_state.dart';
import 'package:saleup_app/screen/expiry/view/add_expiry_screen.dart';
import 'package:saleup_app/screen/expiry/view/edit_expiry_screen.dart';

class ExpiryScreen extends StatefulWidget {
  const ExpiryScreen({super.key});

  @override
  State<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _expandedSection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ExpiryBloc>().add(const FetchExpiry());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<ExpiryBloc>().add(SearchExpiry(query));
    });
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  void _clearAllFilters() {
    context.read<ExpiryBloc>().add(const ClearFilters());
    setState(() => _expandedSection = null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: BlocConsumer<ExpiryBloc, ExpiryState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildTopBar(context, state),
                  _buildFilterPanel(context, state),
                  _buildTableCard(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ====================== HEADER ======================
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expiry',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Set up expiry for products and track product expiry dates',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ====================== TOP BAR ======================
  Widget _buildTopBar(BuildContext context, ExpiryState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          SizedBox(
            width: 190,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by product or batch…',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey[400], size: 18),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ExpiryBloc>(),
                    child: const AddExpiryScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text(
              'New Expiry',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ====================== FILTER PANEL ======================
  Widget _buildFilterPanel(BuildContext context, ExpiryState state) {
    final hasActive = state.selectedProduct != null ||
        state.priceSort != null ||
        state.quantitySort != null;

    final products = state.uniqueProducts;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            _buildFilterSection(
              title: 'Product',
              isExpanded: _expandedSection == 'product',
              onTap: () => _toggleSection('product'),
              children: products.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'No products available',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF999999)),
                        ),
                      ),
                    ]
                  : products.map((product) {
                      final isSelected = state.selectedProduct == product;
                      return _filterOption(
                        label: product,
                        selected: isSelected,
                        onTap: () {
                          context.read<ExpiryBloc>().add(
                                ToggleProductFilter(
                                    isSelected ? null : product),
                              );
                        },
                      );
                    }).toList(),
            ),
            _buildFilterSection(
              title: 'Price',
              isExpanded: _expandedSection == 'price',
              onTap: () => _toggleSection('price'),
              children: [
                _filterOption(
                  label: 'High to Low',
                  selected: state.priceSort == 'High to Low',
                  onTap: () {
                    context.read<ExpiryBloc>().add(SetPriceSort(
                        state.priceSort == 'High to Low'
                            ? null
                            : 'High to Low'));
                  },
                ),
                _filterOption(
                  label: 'Low to High',
                  selected: state.priceSort == 'Low to High',
                  onTap: () {
                    context.read<ExpiryBloc>().add(SetPriceSort(
                        state.priceSort == 'Low to High'
                            ? null
                            : 'Low to High'));
                  },
                ),
              ],
            ),
            _buildFilterSection(
              title: 'Quantity',
              isExpanded: _expandedSection == 'quantity',
              onTap: () => _toggleSection('quantity'),
              children: [
                _filterOption(
                  label: 'High to Low',
                  selected: state.quantitySort == 'High to Low',
                  onTap: () {
                    context.read<ExpiryBloc>().add(SetQuantitySort(
                        state.quantitySort == 'High to Low'
                            ? null
                            : 'High to Low'));
                  },
                ),
                _filterOption(
                  label: 'Low to High',
                  selected: state.quantitySort == 'Low to High',
                  onTap: () {
                    context.read<ExpiryBloc>().add(SetQuantitySort(
                        state.quantitySort == 'Low to High'
                            ? null
                            : 'Low to High'));
                  },
                ),
              ],
            ),
            if (hasActive) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _clearAllFilters,
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }

  Widget _filterOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EAF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? const Color(0xFF1A237E) : const Color(0xFF555555),
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ====================== TABLE CARD ======================
  Widget _buildTableCard(BuildContext context, ExpiryState state) {
    final filtered = state.getFilteredData();

    final totalPages =
        filtered.isEmpty ? 1 : (filtered.length / state.itemsPerPage).ceil();

    final currentPage = state.currentPage.clamp(1, totalPages);

    final start =
        ((currentPage - 1) * state.itemsPerPage).clamp(0, filtered.length);
    final end = (start + state.itemsPerPage).clamp(0, filtered.length);
    final pageData = filtered.sublist(start, end);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 4),
              child: GestureDetector(
                onTap:
                    filtered.isEmpty ? null : () => _confirmDeleteAll(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline,
                        size: 14,
                        color: filtered.isEmpty
                            ? Colors.grey[400]
                            : Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Delete All',
                      style: TextStyle(
                        fontSize: 12,
                        color: filtered.isEmpty
                            ? Colors.grey[400]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(),
                state.isLoading
                    ? _buildSkeleton()
                    : pageData.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 40, horizontal: 24),
                            child: Text(
                              'No expiry data found',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        : Column(
                            children: List.generate(
                              pageData.length,
                              (i) => _buildTableRow(context, pageData[i], i),
                            ),
                          ),
              ],
            ),
          ),
          if (!state.isLoading)
            _buildPagination(context, currentPage, totalPages),
        ],
      ),
    );
  }

  static const double _colId = 55;
  static const double _colProduct = 70;
  static const double _colBatch = 100;
  static const double _colExpiry = 80;
  static const double _colStatus = 90;
  static const double _colPrice = 100;
  static const double _colQty = 70;
  static const double _colAction = 150;

  Widget _buildTableHeader() {
    const style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF555555),
    );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 40, child: SizedBox(height: 40)),
          _hCell('ID', width: _colId, style: style),
          _hCell('Product', width: _colProduct, style: style),
          _hCell('Batch Number', width: _colBatch, style: style),
          _hCell('Expiry Date', width: _colExpiry, style: style),
          _hCell('Is Expired', width: _colStatus, style: style),
          _hCell('Selling Price', width: _colPrice, style: style),
          _hCell('Quantity', width: _colQty, style: style),
          _hCell('Action', width: _colAction, style: style),
        ],
      ),
    );
  }

  Widget _hCell(String label,
      {required double width, required TextStyle style}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(label, style: style),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, ExpiryData item, int index) {
    final isExpired = item.isExpired ?? false;
    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFAFAFA),
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 40, child: Checkbox(value: false, onChanged: (_) {})),
          _dCell('${item.id ?? '-'}', width: _colId),
          _dCell(item.product ?? '-', width: _colProduct),
          _dCell(item.batchNumber ?? '-', width: _colBatch),
          _dCell(
            item.expiryDate != null
                ? item.expiryDate!.toIso8601String().split('T')[0]
                : '-',
            width: _colExpiry,
          ),
          SizedBox(
            width: _colStatus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isExpired
                      ? const Color(0xFFFFEBEB)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isExpired ? 'Expired' : 'Valid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isExpired
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF388E3C),
                  ),
                ),
              ),
            ),
          ),
          _dCell('NPR ${item.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
              width: _colPrice),
          _dCell('${item.quantity ?? 0}', width: _colQty),
          SizedBox(
            width: _colAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 17, color: Colors.grey),
                  onPressed: item.id == null
                      ? null
                      : () => _showEditDialog(context, item),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined,
                      size: 17, color: Colors.grey),
                  onPressed: () => _showDetailDialog(context, item),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 17, color: Colors.grey),
                  onPressed: item.id == null
                      ? null
                      : () => _confirmDelete(context, item.id!),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dCell(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // ====================== PAGINATION ======================
  Widget _buildPagination(
      BuildContext context, int currentPage, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 22),
            color: Colors.black54,
            onPressed: currentPage > 1
                ? () =>
                    context.read<ExpiryBloc>().add(GoToPage(currentPage - 1))
                : null,
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 245, 249, 245),
              border: Border.all(color: const Color(0xFF2196F3), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '$currentPage',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 22),
            color: Colors.black54,
            onPressed: currentPage < totalPages
                ? () =>
                    context.read<ExpiryBloc>().add(GoToPage(currentPage + 1))
                : null,
          ),
        ],
      ),
    );
  }

  // ====================== SKELETON ======================
  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        6,
        (_) => Container(
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // ====================== DETAIL DIALOG ======================
  void _showDetailDialog(BuildContext context, ExpiryData item) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        child: Container(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(dialogCtx).pop(),
                      child: const Icon(Icons.close,
                          size: 22, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  children: [
                    _detailRow('Batch ID', '${item.id ?? '-'}'),
                    _detailRow('Product', item.product ?? '-'),
                    _detailRow('Batch Number', item.batchNumber ?? '-'),
                    _detailRow(
                      'Expiry Date',
                      item.expiryDate != null
                          ? item.expiryDate!.toIso8601String().split('T')[0]
                          : '-',
                    ),
                    _detailRow('Quantity', '${item.quantity ?? 0}'),
                    _detailRow(
                      'Cost Price',
                      'NPR ${item.costPrice?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    _detailRow(
                      'Selling Price',
                      'NPR ${item.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    _detailRow(
                      'Is Expired',
                      item.isExpired == true ? 'Yes' : 'No',
                    ),
                    _detailRow(
                        'Bulk Prices',
                        item.bulkPrice.isEmpty
                            ? '-'
                            : item.bulkPrice.toString()),
                    _detailRow(
                      'Created On',
                      item.createdOn != null
                          ? item.createdOn!.toIso8601String().split('T')[0]
                          : '-',
                    ),
                    _detailRow(
                      'Updated On',
                      item.updatedOn != null
                          ? item.updatedOn!.toIso8601String().split('T')[0]
                          : '-',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Clean two-column layout matching the image
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF1F1F1F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== EDIT DIALOG ======================
  void _showEditDialog(BuildContext context, ExpiryData item) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<ExpiryBloc>(),
        child: EditExpiryScreen(item: item),
      ),
    );
  }

  // ====================== DELETE SINGLE ======================
  void _confirmDelete(BuildContext context, int id) {
    final bloc = context.read<ExpiryBloc>();
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Expiry'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              bloc.add(DeleteExpiry(id));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ====================== DELETE ALL ======================
  void _confirmDeleteAll(BuildContext context) {
    final bloc = context.read<ExpiryBloc>();
    final ids = bloc.state
        .getFilteredData()
        .where((e) => e.id != null)
        .map((e) => e.id!)
        .toList();

    if (ids.isEmpty) return;

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete All'),
        content: Text(
            'Are you sure you want to delete ${ids.length} expiry record(s)?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              bloc.add(DeleteAllExpiry(ids));
            },
            child:
                const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
