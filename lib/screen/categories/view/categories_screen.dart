// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/model/category_response.dart';
// import 'package:saleup_app/screen/categories/bloc/category_bloc.dart';
// import 'package:saleup_app/screen/categories/bloc/category_event.dart';
// import 'package:saleup_app/screen/categories/bloc/category_state.dart';
// import 'dart:developer' as developer;

// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({super.key});

//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;
//   final Set<int> _expandedCategories = {};

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
//     context.read<CategoryBloc>().add(const FetchCategories());
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
//       context.read<CategoryBloc>().add(SearchCategories(query));
//     });
//   }

//   void showFilterBottomSheet(BuildContext context, CategoryBloc categoryBloc) {
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
//         return SlideTransition(
//           position: _slideAnimation,
//           child: Container(
//             height: screenHeight * 0.8,
//             padding: const EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Filter Categories',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Wrap(
//                     spacing: 8.0,
//                     runSpacing: 8.0,
//                     children: [
//                       FilterChip(
//                         label: const Text('All'),
//                         selected:
//                             categoryBloc.state.selectedShortCodeFilter == 'All',
//                         onSelected: (selected) {
//                           if (selected) {
//                             developer.log('Selected filter chip: All');
//                             categoryBloc.add(const UpdateCategoryFilter('All'));
//                             Navigator.pop(context);
//                           }
//                         },
//                         selectedColor: Colors.blue,
//                         labelStyle: TextStyle(
//                           color: categoryBloc.state.selectedShortCodeFilter ==
//                                   'All'
//                               ? Colors.white
//                               : Colors.black,
//                         ),
//                       ),
//                       ...categoryBloc.state.categories
//                           .where((category) =>
//                               category.shortCode != null &&
//                               category.name != null)
//                           .map((category) {
//                         return FilterChip(
//                           label:
//                               Text('${category.name} (${category.shortCode})'),
//                           selected:
//                               categoryBloc.state.selectedShortCodeFilter ==
//                                   category.shortCode,
//                           onSelected: (selected) {
//                             if (selected) {
//                               developer.log(
//                                   'Selected filter chip: ${category.shortCode}');
//                               categoryBloc.add(
//                                   UpdateCategoryFilter(category.shortCode!));
//                               Navigator.pop(context);
//                             }
//                           },
//                           selectedColor: Colors.blue,
//                           labelStyle: TextStyle(
//                             color: categoryBloc.state.selectedShortCodeFilter ==
//                                     category.shortCode
//                                 ? Colors.white
//                                 : Colors.black,
//                           ),
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       OutlinedButton(
//                         onPressed: () {
//                           developer.log('Clearing filters');
//                           categoryBloc.add(const ClearCategoryFilters());
//                           Navigator.pop(context);
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           side: const BorderSide(color: Colors.white),
//                         ),
//                         child: const Text('Clear Filters'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
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

//     return BlocConsumer<CategoryBloc, CategoryState>(
//       listener: (context, state) {
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage!),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//         if (_searchController.text != state.searchQuery) {
//           _searchController.text = state.searchQuery;
//           _searchController.selection = TextSelection.fromPosition(
//             TextPosition(offset: _searchController.text.length),
//           );
//         }
//         developer.log('State categories length: ${state.categories.length}, '
//             'filteredData length: ${state.getFilteredData().length}, '
//             'paginatedData length: ${state.getFilteredData().sublist(0, state.itemsPerPage.clamp(0, state.getFilteredData().length)).length}');
//       },
//       builder: (context, state) {
//         final filteredData = state.getFilteredData();
//         developer.log(
//             'Filtered data: ${filteredData.map((c) => "${c.name}: ${c.shortCode}").toList()}');
//         final totalPages = filteredData.isNotEmpty && state.itemsPerPage > 0
//             ? (filteredData.length / state.itemsPerPage).ceil()
//             : 1;
//         final validCurrentPage = state.currentPage.clamp(1, totalPages);
//         if (validCurrentPage != state.currentPage) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               context
//                   .read<CategoryBloc>()
//                   .add(GoToCategoryPage(validCurrentPage));
//             }
//           });
//         }
//         final paginatedData = filteredData.isNotEmpty && state.itemsPerPage > 0
//             ? filteredData.sublist(
//                 (validCurrentPage - 1) * state.itemsPerPage,
//                 ((validCurrentPage - 1) * state.itemsPerPage +
//                         state.itemsPerPage)
//                     .clamp(0, filteredData.length))
//             : [];
//         developer.log(
//             'Paginated data: ${paginatedData.map((c) => "${c.name}: ${c.shortCode}").toList()}');

//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.02),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Categories Management",
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
//                                     context, context.read<CategoryBloc>()),
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
//                               ? const Center(child: Text("No categories found"))
//                               : ListView.builder(
//                                   key: ValueKey(
//                                       '${state.categories.length}_${validCurrentPage}_${state.isFiltersCleared}_${state.searchQuery}_${state.selectedShortCodeFilter}'),
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: paginatedData.length,
//                                   itemBuilder: (context, index) {
//                                     final category = paginatedData[index];
//                                     final isExpanded = category.id != null &&
//                                         _expandedCategories
//                                             .contains(category.id);
//                                     developer.log(
//                                         'Rendering category: ${category.name} (short_code: ${category.shortCode})');
//                                     return Column(
//                                       children: [
//                                         ListTile(
//                                           title: Text(category.name ??
//                                               'Unnamed Category'),
//                                           subtitle: Text(
//                                               category.shortCode ?? 'No Code'),
//                                           trailing:
//                                               category.subcategories.isNotEmpty
//                                                   ? Icon(isExpanded
//                                                       ? Icons.arrow_drop_up
//                                                       : Icons.arrow_drop_down)
//                                                   : null,
//                                           onTap: category.subcategories
//                                                       .isNotEmpty &&
//                                                   category.id != null
//                                               ? () {
//                                                   setState(() {
//                                                     if (isExpanded) {
//                                                       _expandedCategories
//                                                           .remove(category.id);
//                                                     } else {
//                                                       _expandedCategories
//                                                           .add(category.id!);
//                                                     }
//                                                     developer.log(
//                                                         'Toggled expansion for ${category.name}, isExpanded: $isExpanded');
//                                                   });
//                                                 }
//                                               : null,
//                                         ),
//                                         if (isExpanded &&
//                                             category.subcategories.isNotEmpty)
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                                 left: 16.0),
//                                             child: Column(
//                                               children: (category.subcategories
//                                                           is List<CategoryData>
//                                                       ? category.subcategories
//                                                           as List<CategoryData>
//                                                       : <CategoryData>[])
//                                                   .map<Widget>((subcategory) {
//                                                 return ListTile(
//                                                   title: Text(subcategory
//                                                           .name ??
//                                                       'Unnamed Subcategory'),
//                                                   subtitle: Text(
//                                                       subcategory.shortCode ??
//                                                           'No Code'),
//                                                   dense: true,
//                                                   contentPadding:
//                                                       const EdgeInsets.only(
//                                                           left: 16.0),
//                                                 );
//                                               }).toList(),
//                                             ),
//                                           ),
//                                       ],
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
//                                         .read<CategoryBloc>()
//                                         .add(const GoToCategoryPage(1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_back),
//                                 onPressed: validCurrentPage > 1
//                                     ? () => context.read<CategoryBloc>().add(
//                                         GoToCategoryPage(validCurrentPage - 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             Text('$validCurrentPage of $totalPages'),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_forward),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context.read<CategoryBloc>().add(
//                                         GoToCategoryPage(validCurrentPage + 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.last_page),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<CategoryBloc>()
//                                         .add(GoToCategoryPage(totalPages))
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
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/model/category_response.dart';
// import 'package:saleup_app/screen/categories/bloc/category_bloc.dart';
// import 'package:saleup_app/screen/categories/bloc/category_event.dart';
// import 'package:saleup_app/screen/categories/bloc/category_state.dart';
// import 'dart:developer' as developer;

// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({super.key});

//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;
//   final Set<int> _expandedCategories = {};

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
//     context.read<CategoryBloc>().add(const FetchCategories());
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
//       context.read<CategoryBloc>().add(SearchCategories(query));
//     });
//   }

//   void showFilterBottomSheet(BuildContext context, CategoryBloc categoryBloc) {
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
//         return SlideTransition(
//           position: _slideAnimation,
//           child: Container(
//             height: screenHeight * 0.8,
//             padding: const EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Filter Categories',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Wrap(
//                     spacing: 8.0,
//                     runSpacing: 8.0,
//                     children: [
//                       FilterChip(
//                         label: const Text('All'),
//                         selected:
//                             categoryBloc.state.selectedShortCodeFilter == 'All',
//                         onSelected: (selected) {
//                           if (selected) {
//                             developer.log('Selected filter chip: All');
//                             categoryBloc.add(const UpdateCategoryFilter('All'));
//                             Navigator.pop(context);
//                           }
//                         },
//                         selectedColor: Colors.blue,
//                         labelStyle: TextStyle(
//                           color: categoryBloc.state.selectedShortCodeFilter ==
//                                   'All'
//                               ? Colors.white
//                               : Colors.black,
//                         ),
//                       ),
//                       ...categoryBloc.state.categories
//                           .where((category) =>
//                               category.shortCode != null &&
//                               category.name != null)
//                           .map((category) {
//                         return FilterChip(
//                           label:
//                               Text('${category.name} (${category.shortCode})'),
//                           selected:
//                               categoryBloc.state.selectedShortCodeFilter ==
//                                   category.shortCode,
//                           onSelected: (selected) {
//                             if (selected) {
//                               developer.log(
//                                   'Selected filter chip: ${category.shortCode}');
//                               categoryBloc.add(
//                                   UpdateCategoryFilter(category.shortCode!));
//                               Navigator.pop(context);
//                             }
//                           },
//                           selectedColor: Colors.blue,
//                           labelStyle: TextStyle(
//                             color: categoryBloc.state.selectedShortCodeFilter ==
//                                     category.shortCode
//                                 ? Colors.white
//                                 : Colors.black,
//                           ),
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       OutlinedButton(
//                         onPressed: () {
//                           developer.log('Clearing filters');
//                           categoryBloc.add(const ClearCategoryFilters());
//                           Navigator.pop(context);
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           side: const BorderSide(color: Colors.white),
//                         ),
//                         child: const Text('Clear Filters'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
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

//   // New widget to show subcategory details in a dialog
//   void _showSubcategoryDetails(BuildContext context, CategoryData subcategory) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(subcategory.name ?? 'Unnamed Subcategory'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('ID: ${subcategory.id ?? 'N/A'}'),
//                 const SizedBox(height: 8),
//                 Text('Name: ${subcategory.name ?? 'N/A'}'),
//                 const SizedBox(height: 8),
//                 Text('Short Code: ${subcategory.shortCode ?? 'N/A'}'),
//                 const SizedBox(height: 8),
//                 Text('Status: ${subcategory.status ? 'Active' : 'Inactive'}'),
//                 const SizedBox(height: 8),
//                 Text(
//                     'Created On: ${subcategory.createdOn?.toIso8601String() ?? 'N/A'}'),
//                 const SizedBox(height: 8),
//                 Text(
//                     'Updated On: ${subcategory.updatedOn?.toIso8601String() ?? 'N/A'}'),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return BlocConsumer<CategoryBloc, CategoryState>(
//       listener: (context, state) {
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage!),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//         if (_searchController.text != state.searchQuery) {
//           _searchController.text = state.searchQuery;
//           _searchController.selection = TextSelection.fromPosition(
//             TextPosition(offset: _searchController.text.length),
//           );
//         }
//         developer.log('State categories length: ${state.categories.length}, '
//             'filteredData length: ${state.getFilteredData().length}, '
//             'paginatedData length: ${state.getFilteredData().sublist(0, state.itemsPerPage.clamp(0, state.getFilteredData().length)).length}');
//       },
//       builder: (context, state) {
//         final filteredData = state.getFilteredData();
//         developer.log(
//             'Filtered data: ${filteredData.map((c) => "${c.name}: ${c.shortCode}").toList()}');
//         final totalPages = filteredData.isNotEmpty && state.itemsPerPage > 0
//             ? (filteredData.length / state.itemsPerPage).ceil()
//             : 1;
//         final validCurrentPage = state.currentPage.clamp(1, totalPages);
//         if (validCurrentPage != state.currentPage) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               context
//                   .read<CategoryBloc>()
//                   .add(GoToCategoryPage(validCurrentPage));
//             }
//           });
//         }
//         final paginatedData = filteredData.isNotEmpty && state.itemsPerPage > 0
//             ? filteredData.sublist(
//                 (validCurrentPage - 1) * state.itemsPerPage,
//                 ((validCurrentPage - 1) * state.itemsPerPage +
//                         state.itemsPerPage)
//                     .clamp(0, filteredData.length))
//             : [];
//         developer.log(
//             'Paginated data: ${paginatedData.map((c) => "${c.name}: ${c.shortCode}").toList()}');

//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.02),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Categories Management",
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
//                                     context, context.read<CategoryBloc>()),
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
//                               ? const Center(child: Text("No categories found"))
//                               : ListView.builder(
//                                   key: ValueKey(
//                                       '${state.categories.length}_${validCurrentPage}_${state.isFiltersCleared}_${state.searchQuery}_${state.selectedShortCodeFilter}'),
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: paginatedData.length,
//                                   itemBuilder: (context, index) {
//                                     final category = paginatedData[index];
//                                     final isExpanded = category.id != null &&
//                                         _expandedCategories
//                                             .contains(category.id);
//                                     developer.log(
//                                         'Rendering category: ${category.name} (short_code: ${category.shortCode})');
//                                     return Column(
//                                       children: [
//                                         ListTile(
//                                           title: Text(category.name ??
//                                               'Unnamed Category'),
//                                           subtitle: Text(
//                                               category.shortCode ?? 'No Code'),
//                                           trailing:
//                                               category.subcategories.isNotEmpty
//                                                   ? Icon(isExpanded
//                                                       ? Icons.arrow_drop_up
//                                                       : Icons.arrow_drop_down)
//                                                   : null,
//                                           onTap: category.subcategories
//                                                       .isNotEmpty &&
//                                                   category.id != null
//                                               ? () {
//                                                   setState(() {
//                                                     if (isExpanded) {
//                                                       _expandedCategories
//                                                           .remove(category.id);
//                                                     } else {
//                                                       _expandedCategories
//                                                           .add(category.id!);
//                                                     }
//                                                     developer.log(
//                                                         'Toggled expansion for ${category.name}, isExpanded: $isExpanded');
//                                                   });
//                                                 }
//                                               : null,
//                                         ),
//                                         if (isExpanded &&
//                                             category.subcategories.isNotEmpty)
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                                 left: 16.0),
//                                             child: Column(
//                                               children: (category.subcategories
//                                                           is List<CategoryData>
//                                                       ? category.subcategories
//                                                           as List<CategoryData>
//                                                       : <CategoryData>[])
//                                                   .map<Widget>((subcategory) {
//                                                 return GestureDetector(
//                                                   onTap: () =>
//                                                       _showSubcategoryDetails(
//                                                           context, subcategory),
//                                                   child: ListTile(
//                                                     title: Text(subcategory
//                                                             .name ??
//                                                         'Unnamed Subcategory'),
//                                                     subtitle: Text(
//                                                         subcategory.shortCode ??
//                                                             'No Code'),
//                                                     dense: true,
//                                                     contentPadding:
//                                                         const EdgeInsets.only(
//                                                             left: 16.0),
//                                                   ),
//                                                 );
//                                               }).toList(),
//                                             ),
//                                           ),
//                                       ],
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
//                                         .read<CategoryBloc>()
//                                         .add(const GoToCategoryPage(1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_back),
//                                 onPressed: validCurrentPage > 1
//                                     ? () => context.read<CategoryBloc>().add(
//                                         GoToCategoryPage(validCurrentPage - 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             Text('$validCurrentPage of $totalPages'),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_forward),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context.read<CategoryBloc>().add(
//                                         GoToCategoryPage(validCurrentPage + 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.last_page),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<CategoryBloc>()
//                                         .add(GoToCategoryPage(totalPages))
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
import 'package:saleup_app/model/category_response.dart';
import 'package:saleup_app/screen/categories/bloc/category_bloc.dart';
import 'package:saleup_app/screen/categories/bloc/category_event.dart';
import 'package:saleup_app/screen/categories/bloc/category_state.dart';
import 'dart:developer' as developer;

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final Set<int> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    context.read<CategoryBloc>().add(const FetchCategories());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CategoryBloc>().add(SearchCategories(query));
    });
  }

  void showFilterBottomSheet(BuildContext context, CategoryBloc categoryBloc) {
    _animationController.forward();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      transitionAnimationController: _animationController,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: screenHeight * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected:
                            categoryBloc.state.selectedShortCodeFilter == 'All',
                        onSelected: (selected) {
                          if (selected) {
                            developer.log('Selected filter chip: All');
                            categoryBloc.add(const UpdateCategoryFilter('All'));
                            Navigator.pop(context);
                          }
                        },
                        selectedColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: categoryBloc.state.selectedShortCodeFilter ==
                                  'All'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      ...categoryBloc.state.categories
                          .where((category) =>
                              category.shortCode != null &&
                              category.name != null)
                          .map((category) {
                        return FilterChip(
                          label:
                              Text('${category.name} (${category.shortCode})'),
                          selected:
                              categoryBloc.state.selectedShortCodeFilter ==
                                  category.shortCode,
                          onSelected: (selected) {
                            if (selected) {
                              developer.log(
                                  'Selected filter chip: ${category.shortCode}');
                              categoryBloc.add(
                                  UpdateCategoryFilter(category.shortCode!));
                              Navigator.pop(context);
                            }
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: categoryBloc.state.selectedShortCodeFilter ==
                                    category.shortCode
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          developer.log('Clearing filters');
                          categoryBloc.add(const ClearCategoryFilters());
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      _animationController.reset();
    });
  }

  Widget _buildSkeletonLoader(double screenWidth, double screenHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // New widget to show subcategory details in a dialog
  void _showSubcategoryDetails(BuildContext context, CategoryData subcategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(subcategory.name ?? 'Unnamed Subcategory'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${subcategory.id}'),
                const SizedBox(height: 8),
                Text('Name: ${subcategory.name ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Short Code: ${subcategory.shortCode ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Status: ${subcategory.status ? 'Active' : 'Inactive'}'),
                const SizedBox(height: 8),
                Text(
                    'Description: ${(subcategory.description ?? '').trim().isEmpty ? 'N/A' : subcategory.description}'),
                const SizedBox(height: 8),
                Text('Created On: ${subcategory.createdOn.toIso8601String()}'),
                const SizedBox(height: 8),
                Text('Updated On: ${subcategory.updatedOn.toIso8601String()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }
        developer.log('State categories length: ${state.categories.length}, '
            'filteredData length: ${state.getFilteredData().length}, '
            'paginatedData length: ${state.getFilteredData().sublist(0, state.itemsPerPage.clamp(0, state.getFilteredData().length)).length}');
      },
      builder: (context, state) {
        final filteredData = state.getFilteredData();
        developer.log(
            'Filtered data: ${filteredData.map((c) => "${c.name}: ${c.shortCode}").toList()}');
        final totalPages = filteredData.isNotEmpty && state.itemsPerPage > 0
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
        final paginatedData = filteredData.isNotEmpty && state.itemsPerPage > 0
            ? filteredData.sublist(
                (validCurrentPage - 1) * state.itemsPerPage,
                ((validCurrentPage - 1) * state.itemsPerPage +
                        state.itemsPerPage)
                    .clamp(0, filteredData.length))
            : [];
        developer.log(
            'Paginated data: ${paginatedData.map((c) => "${c.name}: ${c.shortCode}").toList()}');

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Categories Management",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      labelText: 'Search Here',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 12,
                                      ),
                                    ),
                                    onChanged: _onSearchChanged,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              IconButton(
                                icon: Image.asset(
                                  'assets/icons/filter.png',
                                  width: 24,
                                  height: 24,
                                  color: Colors.grey,
                                ),
                                onPressed: () => showFilterBottomSheet(
                                    context, context.read<CategoryBloc>()),
                                style: IconButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: screenWidth,
                      child: state.isLoading
                          ? _buildSkeletonLoader(screenWidth, screenHeight)
                          : paginatedData.isEmpty
                              ? const Center(child: Text("No categories found"))
                              : ListView.builder(
                                  key: ValueKey(
                                      '${state.categories.length}_${validCurrentPage}_${state.isFiltersCleared}_${state.searchQuery}_${state.selectedShortCodeFilter}'),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: paginatedData.length,
                                  itemBuilder: (context, index) {
                                    final category = paginatedData[index];
                                    final isExpanded = category.id != null &&
                                        _expandedCategories
                                            .contains(category.id);
                                    developer.log(
                                        'Rendering category: ${category.name} (short_code: ${category.shortCode})');
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: category.subcategories
                                                          .isNotEmpty &&
                                                      category.id != null
                                                  ? () {
                                                      setState(() {
                                                        if (isExpanded) {
                                                          _expandedCategories
                                                              .remove(
                                                                  category.id);
                                                        } else {
                                                          _expandedCategories
                                                              .add(
                                                                  category.id!);
                                                        }
                                                        developer.log(
                                                            'Toggled expansion for ${category.name}, isExpanded: $isExpanded');
                                                      });
                                                    }
                                                  : null,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          category.name ??
                                                              'Unnamed Category',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          ),
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              'Short Code: ${category.shortCode ?? 'N/A'}',
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              textAlign:
                                                                  TextAlign.end,
                                                              softWrap: true,
                                                            ),
                                                            if (category
                                                                .subcategories
                                                                .isNotEmpty)
                                                              Icon(isExpanded
                                                                  ? Icons
                                                                      .arrow_drop_up
                                                                  : Icons
                                                                      .arrow_drop_down),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Status: ${category.status ? 'Active' : 'Inactive'}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          category.subcategories
                                                                  .isNotEmpty
                                                              ? 'Subcatagory: ${category.subcategories.length}'
                                                              : 'No Subcats',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                          textAlign:
                                                              TextAlign.end,
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isExpanded &&
                                                category
                                                    .subcategories.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0, top: 8.0),
                                                child: Column(
                                                  children: () {
                                                    final subcategories = (category
                                                                .subcategories
                                                            is List<
                                                                CategoryData>
                                                        ? category.subcategories
                                                            as List<
                                                                CategoryData>
                                                        : <CategoryData>[]);
                                                    List<Widget> subcatWidgets =
                                                        [];
                                                    for (int i = 0;
                                                        i <
                                                            subcategories
                                                                .length;
                                                        i++) {
                                                      subcatWidgets.add(
                                                        GestureDetector(
                                                          onTap: () =>
                                                              _showSubcategoryDetails(
                                                                  context,
                                                                  subcategories[
                                                                      i]),
                                                          child: ListTile(
                                                            title: Text(
                                                                subcategories[i]
                                                                        .name ??
                                                                    'Unnamed Subcategory'),
                                                            subtitle: Text(
                                                                subcategories[i]
                                                                        .shortCode ??
                                                                    'No Code'),
                                                            dense: true,
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16.0),
                                                          ),
                                                        ),
                                                      );
                                                      if (i <
                                                          subcategories.length -
                                                              1) {
                                                        subcatWidgets.add(
                                                            const Divider());
                                                      }
                                                    }
                                                    return subcatWidgets;
                                                  }(),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                    if (!state.isLoading && totalPages > 1)
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.first_page),
                                onPressed: validCurrentPage > 1
                                    ? () => context
                                        .read<CategoryBloc>()
                                        .add(const GoToCategoryPage(1))
                                    : null),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: validCurrentPage > 1
                                    ? () => context.read<CategoryBloc>().add(
                                        GoToCategoryPage(validCurrentPage - 1))
                                    : null),
                            const SizedBox(width: 5),
                            Text('$validCurrentPage of $totalPages'),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: validCurrentPage < totalPages
                                    ? () => context.read<CategoryBloc>().add(
                                        GoToCategoryPage(validCurrentPage + 1))
                                    : null),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.last_page),
                                onPressed: validCurrentPage < totalPages
                                    ? () => context
                                        .read<CategoryBloc>()
                                        .add(GoToCategoryPage(totalPages))
                                    : null),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
