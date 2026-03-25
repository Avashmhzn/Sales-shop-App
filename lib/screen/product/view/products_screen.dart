// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/product/bloc/product_bloc.dart';
// import 'package:saleup_app/screen/product/bloc/product_event.dart';
// import 'package:saleup_app/screen/product/bloc/product_state.dart';
// import 'package:saleup_app/screen/product/widget/product_card.dart';

// class ProductsScreen extends StatefulWidget {
//   const ProductsScreen({super.key});

//   @override
//   State<ProductsScreen> createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends State<ProductsScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, 1.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       context.read<ProductBloc>().add(const FetchProducts());
//       context.read<ProductBloc>().add(const FetchUnits());
//     });
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       if (!mounted) return;
//       context.read<ProductBloc>().add(SearchProducts(query));
//     });
//   }

//   void showFilterBottomSheet(BuildContext context, ProductBloc productBloc) {
//     _animationController.forward();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.grey[850],
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//       ),
//       transitionAnimationController: _animationController,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         final screenHeight = MediaQuery.of(context).size.height;
//         final units = productBloc.state.units.map((u) => u.name).toList();

//         return SlideTransition(
//           position: _slideAnimation,
//           child: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return Container(
//                 height: screenHeight * 0.8,
//                 padding: const EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Filters',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Category',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: productBloc.state.allCategories
//                             .map((category) => FilterChip(
//                                   label: Text(category),
//                                   selected: productBloc
//                                           .state.selectedCategoryFilter ==
//                                       category,
//                                   onSelected: (bool value) {
//                                     if (value) {
//                                       setState(() {
//                                         productBloc.add(
//                                             UpdateCategoryFilter(category));
//                                       });
//                                     }
//                                   },
//                                   selectedColor: Colors.brown[700],
//                                   labelStyle: TextStyle(
//                                     color: productBloc
//                                                 .state.selectedCategoryFilter ==
//                                             category
//                                         ? Colors.white
//                                         : Colors.black,
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Unit',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: ['All', ...units]
//                             .map((unit) => FilterChip(
//                                   label: Text(unit),
//                                   selected:
//                                       productBloc.state.selectedUnitFilter ==
//                                           unit,
//                                   onSelected: (bool value) {
//                                     if (value) {
//                                       setState(() {
//                                         productBloc.add(UpdateUnitFilter(unit));
//                                       });
//                                     }
//                                   },
//                                   selectedColor: Colors.brown[700],
//                                   labelStyle: TextStyle(
//                                     color:
//                                         productBloc.state.selectedUnitFilter ==
//                                                 unit
//                                             ? Colors.white
//                                             : Colors.black,
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Sort Products',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 productBloc
//                                     .add(const SortProducts('No Sorting'));
//                               });
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   productBloc.state.sortBy == 'No Sorting'
//                                       ? Colors.brown[700]
//                                       : Colors.grey[700],
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('No Sorting'),
//                           ),
//                           const SizedBox(height: 8),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 productBloc.add(const SortProducts(
//                                     'Stock Quantity: High to Low'));
//                               });
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: productBloc.state.sortBy ==
//                                       'Stock Quantity: High to Low'
//                                   ? Colors.brown[700]
//                                   : Colors.grey[700],
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Stock Quantity: High to Low'),
//                           ),
//                           const SizedBox(height: 8),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 productBloc.add(const SortProducts(
//                                     'Stock Quantity: Low to High'));
//                               });
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: productBloc.state.sortBy ==
//                                       'Stock Quantity: Low to High'
//                                   ? Colors.brown[700]
//                                   : Colors.grey[700],
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Stock Quantity: Low to High'),
//                           ),
//                           const SizedBox(height: 8),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 productBloc
//                                     .add(const SortProducts('Name: A to Z'));
//                               });
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   productBloc.state.sortBy == 'Name: A to Z'
//                                       ? Colors.brown[700]
//                                       : Colors.grey[700],
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Name: A to Z'),
//                           ),
//                           const SizedBox(height: 8),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 productBloc
//                                     .add(const SortProducts('Name: Z to A'));
//                               });
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   productBloc.state.sortBy == 'Name: Z to A'
//                                       ? Colors.brown[700]
//                                       : Colors.grey[700],
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Name: Z to A'),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           OutlinedButton(
//                             onPressed: () {
//                               setState(() {
//                                 productBloc.add(const ClearFilters());
//                               });
//                               Navigator.pop(context);
//                             },
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               side: const BorderSide(color: Colors.white),
//                             ),
//                             child: const Text('Clear Filters'),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               productBloc.add(const UpdateFiltersApplied());
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.brown[700],
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Apply Filters'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     ).whenComplete(() {
//       _animationController.reset();
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

//     return BlocConsumer<ProductBloc, ProductState>(
//       listener: (context, state) {
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage!),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//         print(
//             'State: isLoading=${state.isLoading}, currentPage=${state.currentPage}, itemsPerPage=${state.itemsPerPage}, products=${state.products.length}, filteredData=${state.getFilteredData().length}');
//       },
//       builder: (context, state) {
//         final filteredData = state.getFilteredData();
//         final itemsPerPage = state.itemsPerPage.toDouble();
//         final totalPages = filteredData.isNotEmpty
//             ? (filteredData.length / itemsPerPage).ceil()
//             : 1;
//         final validCurrentPage = (state.currentPage ?? 1).clamp(1, totalPages);
//         if (validCurrentPage != (state.currentPage ?? 1)) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (!mounted) return;
//             context.read<ProductBloc>().add(GoToPage(validCurrentPage));
//           });
//         }
//         final startIndex = ((validCurrentPage - 1) * state.itemsPerPage)
//             .clamp(0, filteredData.length);
//         final endIndex =
//             (startIndex + state.itemsPerPage).clamp(0, filteredData.length);
//         final paginatedData = filteredData.isNotEmpty
//             ? filteredData.sublist(startIndex, endIndex)
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
//                       "Products Management",
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
//                               const SizedBox(width: 5),
//                               IconButton(
//                                 icon: Image.asset(
//                                   'assets/icons/filter.png',
//                                   width: 24,
//                                   height: 24,
//                                   color: Colors.grey,
//                                 ),
//                                 onPressed: () => showFilterBottomSheet(
//                                     context, context.read<ProductBloc>()),
//                                 style: IconButton.styleFrom(
//                                   side: const BorderSide(color: Colors.grey),
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
//                               ? const Center(child: Text("No products found"))
//                               : ListView.builder(
//                                   key: ValueKey(
//                                       '${state.products.length}_$validCurrentPage${state.isFiltersCleared}_${state.searchQuery}_${state.selectedCategoryFilter}_${state.selectedUnitFilter}_${state.sortBy}'),
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: paginatedData.length,
//                                   itemBuilder: (context, index) {
//                                     return ProductCard(
//                                       product: paginatedData[index],
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
//                                         .read<ProductBloc>()
//                                         .add(const GoToPage(1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_back),
//                                 onPressed: validCurrentPage > 1
//                                     ? () => context
//                                         .read<ProductBloc>()
//                                         .add(GoToPage(validCurrentPage - 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             Text('$validCurrentPage of $totalPages'),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_forward),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<ProductBloc>()
//                                         .add(GoToPage(validCurrentPage + 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.last_page),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<ProductBloc>()
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
import 'package:saleup_app/model/product_response.dart';
import 'package:saleup_app/screen/product/bloc/product_bloc.dart';
import 'package:saleup_app/screen/product/bloc/product_event.dart';
import 'package:saleup_app/screen/product/bloc/product_state.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Set<int> _selectedIds = {};
  bool _showFilter = false;
  // Filter panel expandable sections
  bool _catExpanded = true;
  bool _unitExpanded = true;
  bool _sortExpanded = true;
  static const _orange = Color(0xFFE8891A);

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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<ProductBloc>().add(SearchProducts(_searchController.text));
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

  void _toggleSelectAll(List<ProductData> items, bool? value) {
    setState(() {
      if (value == true)
        _selectedIds.addAll(items.map((p) => p.id ?? 0));
      else
        _selectedIds.removeAll(items.map((p) => p.id ?? 0));
    });
  }

  // ─── Delete Single ────────────────────────────────────────────────────────
  Future<void> _deleteProduct(ProductData product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Product',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete "${product.name ?? 'this product'}"?'),
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
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Delete ${_selectedIds.length} selected product(s)?'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Product Details',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              _vRow2(
                  'ID: ${product.id ?? 0}', 'Name: ${product.name ?? 'N/A'}'),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _vRow2('Category: ${product.category ?? 'N/A'}',
                  'Unit: ${product.unit ?? 'N/A'}'),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _vRow2('Location: ${product.location ?? 'N/A'}',
                  'Stock: ${product.stockQuantity ?? 0}'),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _vRow2('Is VAT: ${product.isVat == true ? 'Yes' : 'No'}',
                  'Is VAT: ${product.isVat == true ? 'Yes' : 'No'}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vRow2(String left, String right) {
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

  // ─── Edit Dialog ─────────────────────────────────────────────────────────
  void _showEditDialog(ProductData product) {
    final bloc = context.read<ProductBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final allCategories =
        bloc.state.allCategories.where((c) => c != 'All').toList();
    final allUnits = bloc.state.units.map((u) => u.name).toList();
    // Pre-fetch locations
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Edit Product',
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
                          // Row 1: Product ID + Name
                          Row(children: [
                            Expanded(
                                child: _pField(
                                    label: 'Product ID',
                                    child: TextFormField(
                                      initialValue:
                                          product.id?.toString() ?? '',
                                      readOnly: true,
                                      style: const TextStyle(
                                          color: Colors.black45),
                                      decoration: _pDeco(),
                                    ))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _pField(
                                    label: '* Name',
                                    required: true,
                                    child: TextFormField(
                                      controller: nameController,
                                      decoration: _pDeco(),
                                    ))),
                          ]),
                          const SizedBox(height: 12),
                          // Row 2: Location + Category
                          Row(children: [
                            Expanded(
                                child: _pField(
                                    label: '* Location:',
                                    child: DropdownButtonFormField<String>(
                                      value: selectedLocation,
                                      decoration: _pDeco(hint: 'Select'),
                                      isExpanded: true,
                                      items: locations
                                          .map((l) => DropdownMenuItem(
                                              value: l,
                                              child: Text(l,
                                                  overflow:
                                                      TextOverflow.ellipsis)))
                                          .toList(),
                                      onChanged: (val) => setDialogState(
                                          () => selectedLocation = val),
                                    ))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _pField(
                                    label: '* Category:',
                                    child: DropdownButtonFormField<String>(
                                      value: selectedCategory,
                                      decoration: _pDeco(hint: 'Select'),
                                      isExpanded: true,
                                      items: allCategories
                                          .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c,
                                                  overflow:
                                                      TextOverflow.ellipsis)))
                                          .toList(),
                                      onChanged: (val) => setDialogState(
                                          () => selectedCategory = val),
                                    ))),
                          ]),
                          const SizedBox(height: 12),
                          // Row 3: Unit + Stock Quantity (read-only)
                          Row(children: [
                            Expanded(
                                child: _pField(
                                    label: '* Unit:',
                                    child: DropdownButtonFormField<String>(
                                      value: selectedUnit,
                                      decoration: _pDeco(hint: 'Select'),
                                      isExpanded: true,
                                      items: allUnits
                                          .map((u) => DropdownMenuItem(
                                              value: u,
                                              child: Text(u,
                                                  overflow:
                                                      TextOverflow.ellipsis)))
                                          .toList(),
                                      onChanged: (val) => setDialogState(
                                          () => selectedUnit = val),
                                    ))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _pField(
                                    label: 'Stock Quantity',
                                    child: TextFormField(
                                      initialValue:
                                          product.stockQuantity?.toString() ??
                                              '0',
                                      readOnly: true,
                                      style: const TextStyle(
                                          color: Colors.black45),
                                      decoration: _pDeco(),
                                    ))),
                          ]),
                          const SizedBox(height: 12),
                          // Is Vat
                          Row(children: [
                            const Text('Is Vat:',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87)),
                            const SizedBox(width: 8),
                            Switch(
                              value: isVat,
                              onChanged: (val) =>
                                  setDialogState(() => isVat = val),
                              activeColor: _orange,
                            ),
                          ]),
                          const SizedBox(height: 4),
                          // Is Service
                          Row(children: [
                            const Text('Is Service:',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87)),
                            const SizedBox(width: 8),
                            Switch(
                              value: isService,
                              onChanged: (val) =>
                                  setDialogState(() => isService = val),
                              activeColor: _orange,
                            ),
                          ]),
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
                        size: 18, color: Colors.black54),
                  ),
                  const SizedBox(width: 10),
                  const Column(
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
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close,
                        color: Colors.black54, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Upload area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF4CAF50),
                      style: BorderStyle.solid,
                      width: 2),
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

  // ─── Helpers ─────────────────────────────────────────────────────────────
  Widget _pField(
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

  InputDecoration _pDeco({String? hint}) {
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

  // ─── Filter Panel ─────────────────────────────────────────────────────────
  Widget _buildFilterPanel(ProductState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filters',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _catExpanded = !_catExpanded),
                      child: Row(
                        children: [
                          const Expanded(
                              child: Text('Categories',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87))),
                          Icon(
                              _catExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.black45),
                        ],
                      ),
                    ),
                    if (_catExpanded) ...[
                      const SizedBox(height: 6),
                      ...state.allCategories
                          .where((c) => c != 'All')
                          .map((cat) {
                        final isSelected = state.selectedCategoryFilter == cat;
                        return GestureDetector(
                          onTap: () => context.read<ProductBloc>().add(
                              UpdateCategoryFilter(isSelected ? 'All' : cat)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(cat,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isSelected ? _orange : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => context
                            .read<ProductBloc>()
                            .add(const UpdateCategoryFilter('All')),
                        child: const Text('Clear Category Filter',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFD9534F),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const VerticalDivider(width: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(width: 16),
              // Unit section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _unitExpanded = !_unitExpanded),
                      child: Row(
                        children: [
                          const Expanded(
                              child: Text('Unit',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87))),
                          Icon(
                              _unitExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.black45),
                        ],
                      ),
                    ),
                    if (_unitExpanded) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => context
                            .read<ProductBloc>()
                            .add(const UpdateUnitFilter('All')),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: state.selectedUnitFilter == 'All'
                                ? const Color(0xFFE3F0FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('All Units',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: state.selectedUnitFilter == 'All'
                                      ? const Color(0xFF1565C0)
                                      : Colors.black87,
                                  fontWeight: state.selectedUnitFilter == 'All'
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ),
                      ),
                      ...state.units.map((unit) {
                        final isSelected =
                            state.selectedUnitFilter == unit.name;
                        return GestureDetector(
                          onTap: () => context
                              .read<ProductBloc>()
                              .add(UpdateUnitFilter(unit.name)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(unit.name,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isSelected ? _orange : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => context
                            .read<ProductBloc>()
                            .add(const UpdateUnitFilter('All')),
                        child: const Text('Clear Unit Filter',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFD9534F),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const VerticalDivider(width: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(width: 16),
              // Sort Products section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _sortExpanded = !_sortExpanded),
                      child: Row(
                        children: [
                          const Expanded(
                              child: Text('Sort Products',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87))),
                          Icon(
                              _sortExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.black45),
                        ],
                      ),
                    ),
                    if (_sortExpanded) ...[
                      const SizedBox(height: 6),
                      ...[
                        'No Sorting',
                        'Stock Quantity: High to Low',
                        'Stock Quantity: Low to High',
                        'Name: A to Z',
                        'Name: Z to A'
                      ].map((sort) {
                        final isSelected = state.sortBy == sort;
                        return GestureDetector(
                          onTap: () => context
                              .read<ProductBloc>()
                              .add(SortProducts(sort)),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE3F0FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(sort,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? const Color(0xFF1565C0)
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => context
                            .read<ProductBloc>()
                            .add(const SortProducts('No Sorting')),
                        child: const Text('Clear Sorting',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFD9534F),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
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
              context.read<ProductBloc>().add(GoToPage(validCurrentPage));
          });
        }
        final paginatedData = filteredData.isNotEmpty
            ? filteredData.sublist(
                (validCurrentPage - 1) * state.itemsPerPage,
                ((validCurrentPage - 1) * state.itemsPerPage +
                        state.itemsPerPage)
                    .clamp(0, filteredData.length))
            : <ProductData>[];
        final allPageSelected = paginatedData.isNotEmpty &&
            paginatedData.every((p) => _selectedIds.contains(p.id ?? 0));
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + New Product + Bulk Actions ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Products',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A))),
                            SizedBox(height: 4),
                            Text(
                                'Add, edit, or manage product details and inventory information.',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF777777))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                            label: const Text('New Products',
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
                          const SizedBox(height: 8),
                          PopupMenuButton<String>(
                            onSelected: (val) async {
                              if (val == 'import') {
                                _showBulkImportDialog();
                              } else if (val == 'batch') {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                try {
                                  await DioClient().dio.get(
                                      '/import/download_sample_excel/?template_type=product_batch_pricing');
                                  scaffoldMessenger.showSnackBar(const SnackBar(
                                      content: Text('Downloading...')));
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              } else if (val == 'name') {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                try {
                                  await DioClient().dio.get(
                                      '/import/download_sample_excel/?template_type=product_name_pricing');
                                  scaffoldMessenger.showSnackBar(const SnackBar(
                                      content: Text('Downloading...')));
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                  value: 'import', child: Text('Bulk Import')),
                              const PopupMenuItem(
                                  value: 'batch',
                                  child: Text(
                                      'Download Sample Excel For Product Batch Pricing')),
                              const PopupMenuItem(
                                  value: 'name',
                                  child: Text(
                                      'Download Sample Excel For Product Name Pricing')),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: _orange),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.table_chart_outlined,
                                      size: 16, color: _orange),
                                  const SizedBox(width: 6),
                                  Text('Bulk Actions',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _orange)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down,
                                      size: 16, color: _orange),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                  // ── Filter panel above table ──
                  _buildFilterPanel(state),
                  const SizedBox(height: 10),
                  // ── Table (full width) ──
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 40),
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
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                                      width: 50,
                                      child: Text('ID',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 120,
                                      child: Text('Name',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 100,
                                      child: Text('Category',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 70,
                                      child: Text('Unit',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 90,
                                      child: Text('Location',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 110,
                                      child: Text('Stock Quantity',
                                          style: _hStyle,
                                          textAlign: TextAlign.center)),
                                  const SizedBox(
                                      width: 90,
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
                                    child: Text('No products found',
                                        style: TextStyle(
                                            color: Color(0xFF888888)))),
                              )
                            else
                              ...paginatedData.map((product) {
                                final isSelected =
                                    _selectedIds.contains(product.id ?? 0);
                                return Column(
                                  children: [
                                    Container(
                                      height: 56,
                                      color: isSelected
                                          ? const Color(0xFFFFF8F0)
                                          : Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                              width: 32,
                                              child: Checkbox(
                                                value: isSelected,
                                                onChanged: (v) => _toggleSelect(
                                                    product.id ?? 0, v),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              )),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                              width: 50,
                                              child: Text('${product.id ?? 0}',
                                                  style: _rStyle,
                                                  textAlign: TextAlign.center)),
                                          SizedBox(
                                              width: 120,
                                              child: Text(product.name ?? '',
                                                  style: _rStyle,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                          SizedBox(
                                              width: 100,
                                              child: Text(
                                                  product.category ?? '',
                                                  style: _rStyle,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                          SizedBox(
                                              width: 70,
                                              child: Text(product.unit ?? '',
                                                  style: _rStyle,
                                                  textAlign: TextAlign.center)),
                                          SizedBox(
                                              width: 90,
                                              child: Text(
                                                  product.location ?? '',
                                                  style: _rStyle,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                          SizedBox(
                                              width: 110,
                                              child: Text(
                                                  '${product.stockQuantity ?? 0}',
                                                  style: _rStyle,
                                                  textAlign: TextAlign.center)),
                                          SizedBox(
                                            width: 90,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _showEditDialog(product),
                                                  child: const Icon(
                                                      Icons.edit_outlined,
                                                      size: 17,
                                                      color: Color(0xFF888888)),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _showViewDialog(product),
                                                  child: const Icon(
                                                      Icons
                                                          .remove_red_eye_outlined,
                                                      size: 17,
                                                      color: Color(0xFF888888)),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _deleteProduct(product),
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
                  // ── Pagination ──
                  if (!state.isLoading)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: validCurrentPage > 1
                                ? () => context
                                    .read<ProductBloc>()
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
                                    .read<ProductBloc>()
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
                // Product Details card
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
                      // Row 1: Name + Location
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
                                value: _selectedLocation,
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
                      // Row 2: Category + Unit
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _addField(
                            label: '* Category',
                            child: Row(children: [
                              Expanded(
                                  child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
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
                                value: _selectedUnit,
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
                      // H.S Code
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
                      // Toggles
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
                      // Add Product Button
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
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(6),
      ),
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
            activeColor: const Color(0xFF2196F3)),
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
