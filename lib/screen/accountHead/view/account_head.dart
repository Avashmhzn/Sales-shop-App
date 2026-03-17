// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_event.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_state.dart';
// import 'package:saleup_app/screen/accountHead/widgets/account_head_card.dart';
// import 'package:shimmer/shimmer.dart';

// class AccountHead extends StatefulWidget {
//   const AccountHead({super.key});

//   @override
//   State<AccountHead> createState() => _AccountHeadState();
// }

// class _AccountHeadState extends State<AccountHead>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;
//   Timer? _debounce;
//   late TextEditingController _searchController;

//   @override
//   void initState() {
//     super.initState();
//     FlutterError.onError = (FlutterErrorDetails details) {
//       print('Flutter error: ${details.exception}, stack: ${details.stack}');
//     };
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
//     _searchController = TextEditingController();
//     context.read<AccountHeadBloc>().add(const ClearFilters());
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _animationController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String value) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       print('Dispatching SearchAccountHeads: $value');
//       context.read<AccountHeadBloc>().add(SearchAccountHeads(value));
//     });
//   }

//   void showFilterBottomSheet() {
//     _animationController.forward();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.grey[850],
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//       ),
//       transitionAnimationController: _animationController,
//       isScrollControlled: true,
//       builder: (BuildContext dialogContext) {
//         return BlocProvider.value(
//           value: context.read<AccountHeadBloc>(),
//           child: BlocBuilder<AccountHeadBloc, AccountHeadState>(
//             builder: (context, state) {
//               print('Bottom sheet rebuilt with state: '
//                   'mainFilter=${state.selectedMainFilter}, '
//                   'subFilter=${state.selectedSubFilter}, '
//                   'isFiltersCleared=${state.isFiltersCleared}');
//               final screenHeight = MediaQuery.of(context).size.height;
//               return SlideTransition(
//                 position: _slideAnimation,
//                 child: Container(
//                   height: screenHeight * 0.8,
//                   padding: const EdgeInsets.all(16.0),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Filters',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'Main Filter',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Wrap(
//                           spacing: 8.0,
//                           runSpacing: 8.0,
//                           children: [
//                             FilterChip(
//                               label: const Text('All'),
//                               selected: state.selectedMainFilter == 'All',
//                               onSelected: (bool value) {
//                                 if (value) {
//                                   print('Selecting main filter: All');
//                                   context
//                                       .read<AccountHeadBloc>()
//                                       .add(const UpdateMainFilter('All'));
//                                 }
//                               },
//                               selectedColor: Colors.brown[700],
//                               labelStyle: TextStyle(
//                                 color: state.selectedMainFilter == 'All'
//                                     ? Colors.white
//                                     : Colors.grey[400],
//                                 fontSize: 14,
//                               ),
//                             ),
//                             ...state.allParents
//                                 .where((parent) => parent != 'All')
//                                 .map((parent) {
//                               return FilterChip(
//                                 label: Text(
//                                   parent,
//                                   style: const TextStyle(fontSize: 14),
//                                   softWrap: true,
//                                   overflow: TextOverflow.clip,
//                                 ),
//                                 selected: state.selectedMainFilter == parent,
//                                 onSelected: (bool value) {
//                                   if (value) {
//                                     print('Selecting main filter: $parent');
//                                     context
//                                         .read<AccountHeadBloc>()
//                                         .add(UpdateMainFilter(parent));
//                                   }
//                                 },
//                                 selectedColor: Colors.brown[700],
//                                 labelStyle: TextStyle(
//                                   color: state.selectedMainFilter == parent
//                                       ? Colors.white
//                                       : Colors.grey[400],
//                                   fontSize: 14,
//                                 ),
//                               );
//                             }),
//                           ],
//                         ),
//                         if (state.selectedMainFilter != 'All') ...[
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Sub Filter',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Wrap(
//                             spacing: 8.0,
//                             runSpacing: 8.0,
//                             children: [
//                               FilterChip(
//                                 label: const Text('All'),
//                                 selected: state.selectedSubFilter == null,
//                                 onSelected: (bool value) {
//                                   print(
//                                       'All sub-filter clicked, value: $value');
//                                   context
//                                       .read<AccountHeadBloc>()
//                                       .add(const UpdateSubFilter(null));
//                                 },
//                                 selectedColor: Colors.brown[700],
//                                 labelStyle: TextStyle(
//                                   color: state.selectedSubFilter == null
//                                       ? Colors.white
//                                       : Colors.grey[400],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               ...state.availableSubFilters.map((mainGroup) {
//                                 return FilterChip(
//                                   label: Text(
//                                     mainGroup,
//                                     style: const TextStyle(fontSize: 14),
//                                     softWrap: true,
//                                     overflow: TextOverflow.clip,
//                                   ),
//                                   selected:
//                                       state.selectedSubFilter == mainGroup,
//                                   onSelected: (bool value) {
//                                     print(
//                                         'Sub-filter $mainGroup clicked, value: $value');
//                                     context
//                                         .read<AccountHeadBloc>()
//                                         .add(UpdateSubFilter(mainGroup));
//                                   },
//                                   selectedColor: Colors.brown[700],
//                                   labelStyle: TextStyle(
//                                     color: state.selectedSubFilter == mainGroup
//                                         ? Colors.white
//                                         : Colors.grey[400],
//                                     fontSize: 14,
//                                   ),
//                                 );
//                               }),
//                             ],
//                           ),
//                         ],
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             TextButton(
//                               onPressed: () {
//                                 print('Clear button pressed');
//                                 _searchController.clear();
//                                 context
//                                     .read<AccountHeadBloc>()
//                                     .add(const ClearFilters());
//                                 Navigator.pop(dialogContext);
//                               },
//                               style: TextButton.styleFrom(
//                                 foregroundColor: Colors.white,
//                               ),
//                               child: const Text('Clear'),
//                             ),
//                             const SizedBox(width: 8),
//                             ElevatedButton(
//                               onPressed: () {
//                                 print('Apply button pressed');
//                                 context
//                                     .read<AccountHeadBloc>()
//                                     .add(const UpdateFiltersApplied());
//                                 Navigator.pop(dialogContext);
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.brown[700],
//                                 foregroundColor: Colors.white,
//                               ),
//                               child: const Text('Apply'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
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
//       itemCount: 8,
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 12),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: screenWidth * 0.5,
//                         height: 16,
//                         color: Colors.grey[300],
//                       ),
//                       Container(
//                         width: screenWidth * 0.2,
//                         height: 16,
//                         color: Colors.grey[300],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: screenWidth * 0.3,
//                         height: 14,
//                         color: Colors.grey[300],
//                       ),
//                       Container(
//                         width: screenWidth * 0.3,
//                         height: 14,
//                         color: Colors.grey[300],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     width: screenWidth * 0.2,
//                     height: 14,
//                     color: Colors.grey[300],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: BlocConsumer<AccountHeadBloc, AccountHeadState>(
//         listener: (context, state) {
//           if (state.errorMessage != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errorMessage!)),
//             );
//           }
//           print('Main UI state updated: '
//               'searchQuery=${state.searchQuery}, '
//               'selectedMainFilter=${state.selectedMainFilter}, '
//               'selectedSubFilter=${state.selectedSubFilter}, '
//               'isFiltersCleared=${state.isFiltersCleared}, '
//               'accountHeadsLength=${state.accountHeads.length}, '
//               'filteredDataLength=${state.getFilteredData().length}');
//           if (_searchController.text != state.searchQuery) {
//             _searchController.text = state.searchQuery;
//             _searchController.selection = TextSelection.fromPosition(
//               TextPosition(offset: _searchController.text.length),
//             );
//           }
//         },
//         builder: (context, state) {
//           final filteredData = state.getFilteredData();
//           final totalPages = filteredData.isNotEmpty
//               ? (filteredData.length / state.itemsPerPage).ceil()
//               : 1;
//           final validCurrentPage = state.currentPage.clamp(1, totalPages);
//           if (validCurrentPage != state.currentPage) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               print(
//                   'Correcting currentPage from ${state.currentPage} to $validCurrentPage');
//               context.read<AccountHeadBloc>().add(GoToPage(validCurrentPage));
//             });
//           }
//           final paginatedData = filteredData.isNotEmpty
//               ? filteredData.sublist(
//                   (validCurrentPage - 1) * state.itemsPerPage,
//                   ((validCurrentPage - 1) * state.itemsPerPage +
//                           state.itemsPerPage)
//                       .clamp(0, filteredData.length))
//               : [];
//           print('Building UI with: '
//               'paginatedDataLength=${paginatedData.length}, '
//               'totalPages=$totalPages, '
//               'currentPage=${state.currentPage}, '
//               'validCurrentPage=$validCurrentPage');

//           return LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.all(screenWidth * 0.02),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Inventory Management",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.05,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(width: screenWidth * 0.02),
//                       Padding(
//                         padding: EdgeInsets.all(screenWidth * 0.02),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: SizedBox(
//                                     height: 60,
//                                     child: TextField(
//                                       controller: _searchController,
//                                       decoration: InputDecoration(
//                                         labelText: 'Search Here',
//                                         prefixIcon: const Icon(Icons.search),
//                                         border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(30),
//                                         ),
//                                         contentPadding:
//                                             const EdgeInsets.symmetric(
//                                           vertical: 10,
//                                           horizontal: 12,
//                                         ),
//                                       ),
//                                       onChanged: _onSearchChanged,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 5),
//                                 IconButton(
//                                   icon: Image.asset(
//                                     'assets/icons/filter.png',
//                                     width: 24,
//                                     height: 24,
//                                     color: Colors.grey,
//                                   ),
//                                   onPressed: showFilterBottomSheet,
//                                   style: IconButton.styleFrom(
//                                     side: const BorderSide(color: Colors.grey),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         width: screenWidth,
//                         child: state.isLoading
//                             ? _buildSkeletonLoader(screenWidth, screenHeight)
//                             : paginatedData.isEmpty
//                                 ? const Center(
//                                     child: Text("No account heads found"))
//                                 : ListView.builder(
//                                     key: ValueKey(
//                                         '${state.accountHeads.length}_${validCurrentPage}_${state.isFiltersCleared}_${state.searchQuery}_${state.selectedMainFilter}_${state.selectedSubFilter}'),
//                                     shrinkWrap: true,
//                                     physics:
//                                         const NeverScrollableScrollPhysics(),
//                                     itemCount: paginatedData.length,
//                                     itemBuilder: (context, index) {
//                                       return AccountHeadCard(
//                                         head: paginatedData[index],
//                                         screenWidth: screenWidth,
//                                         screenHeight: screenHeight,
//                                       );
//                                     },
//                                   ),
//                       ),
//                       if (!state.isLoading && totalPages > 1)
//                         Padding(
//                           padding: EdgeInsets.all(screenWidth * 0.02),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               IconButton(
//                                   icon: const Icon(Icons.first_page),
//                                   onPressed: validCurrentPage > 1
//                                       ? () => context
//                                           .read<AccountHeadBloc>()
//                                           .add(const GoToPage(1))
//                                       : null),
//                               const SizedBox(width: 5),
//                               IconButton(
//                                   icon: const Icon(Icons.arrow_back),
//                                   onPressed: validCurrentPage > 1
//                                       ? () => context
//                                           .read<AccountHeadBloc>()
//                                           .add(GoToPage(validCurrentPage - 1))
//                                       : null),
//                               const SizedBox(width: 5),
//                               Text('$validCurrentPage of $totalPages'),
//                               const SizedBox(width: 5),
//                               IconButton(
//                                   icon: const Icon(Icons.arrow_forward),
//                                   onPressed: validCurrentPage < totalPages
//                                       ? () => context
//                                           .read<AccountHeadBloc>()
//                                           .add(GoToPage(validCurrentPage + 1))
//                                       : null),
//                               const SizedBox(width: 5),
//                               IconButton(
//                                   icon: const Icon(Icons.last_page),
//                                   onPressed: validCurrentPage < totalPages
//                                       ? () => context
//                                           .read<AccountHeadBloc>()
//                                           .add(GoToPage(totalPages))
//                                       : null),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// //new
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:saleup_app/model/account_heads_response.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_event.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_state.dart';

// const double _kCheckboxW = 24;
// const double _kGapW = 10;
// const double _kIdW = 48;
// const double _kActionW = 90;
// const double _kTableContentWidth = 720.0;
// const int _kPageSize = 10;
// const double _kRowHeight = 72.0;
// const double _kHeaderHeight = 60.0;

// class AccountHead extends StatefulWidget {
//   const AccountHead({super.key});

//   @override
//   State<AccountHead> createState() => _AccountHeadState();
// }

// class _AccountHeadState extends State<AccountHead> {
//   final TextEditingController _searchController = TextEditingController();
//   String? _selectedParent;
//   String? _selectedMainGroup;
//   final Set<int> _selectedIds = {};
//   int _currentPage = 1;

//   static const _orange = Color(0xFFE8891A);

//   @override
//   void initState() {
//     super.initState();
//     context.read<AccountHeadBloc>().add(const ClearFilters());
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() => _currentPage = 1);
//     context
//         .read<AccountHeadBloc>()
//         .add(SearchAccountHeads(_searchController.text));
//   }

//   void _clearAllFilters() {
//     setState(() {
//       _selectedParent = null;
//       _selectedMainGroup = null;
//       _currentPage = 1;
//     });
//     context.read<AccountHeadBloc>().add(const ClearFilters());
//     _searchController.clear();
//   }

//   void _toggleSelectAll(List<AccountHeadData> pageItems, bool? value) {
//     setState(() {
//       if (value == true) {
//         _selectedIds.addAll(pageItems.map((v) => v.id));
//       } else {
//         _selectedIds.removeAll(pageItems.map((v) => v.id));
//       }
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

//   List<AccountHeadData> _pageSlice(List<AccountHeadData> filtered) {
//     final start = (_currentPage - 1) * _kPageSize;
//     if (start >= filtered.length) return [];
//     return filtered.sublist(
//         start, (start + _kPageSize).clamp(0, filtered.length));
//   }

//   int _totalPages(int count) => (count / _kPageSize).ceil().clamp(1, 9999);

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: BlocConsumer<AccountHeadBloc, AccountHeadState>(
//           listener: (context, state) {
//             if (state.errorMessage != null) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.errorMessage!)),
//               );
//             }
//           },
//           builder: (context, state) {
//             final allHeads = state.accountHeads;
//             final parentToGroups = <String, Set<String>>{};
//             for (final head in allHeads) {
//               final parent = head.parent ?? 'No Parent';
//               final mainGroup = head.mainGroup ?? 'Unknown';
//               parentToGroups.putIfAbsent(parent, () => {}).add(mainGroup);
//             }
//             final sortedParents = parentToGroups.keys.toList()..sort();
//             final filteredHeads = state.getFilteredData();
//             final totalPages = _totalPages(filteredHeads.length);

//             if (_currentPage > totalPages) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) setState(() => _currentPage = totalPages);
//               });
//             }

//             final pageItems = _pageSlice(filteredHeads);
//             final pageAllSelected = pageItems.isNotEmpty &&
//                 pageItems.every((v) => _selectedIds.contains(v.id));

//             return Padding(
//               padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Header ──────────────────────────────
//                   const Text(
//                     'Account',
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF1A1A1A),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Manage and categorize different account types',
//                     style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                   ),
//                   const SizedBox(height: 8),

//                   // ── Search + New Account ─────────────────
//                   Row(
//                     children: [
//                       Container(
//                         width: 200,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(200),
//                           border: Border.all(color: const Color(0xFFE0E0E0)),
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
//                       ElevatedButton.icon(
//                         onPressed: () {},
//                         icon: const Icon(Icons.add,
//                             size: 18, color: Colors.white),
//                         label: const Text(
//                           'New Account',
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white),
//                         ),
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

//                   // ── Delete All ───────────────────────────
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton.icon(
//                       onPressed: _selectedIds.isEmpty ? null : () {},
//                       icon: Icon(Icons.delete_outline,
//                           size: 16,
//                           color: _selectedIds.isEmpty
//                               ? Colors.grey
//                               : const Color(0xFFD9534F)),
//                       label: Text(
//                         'Delete All',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: _selectedIds.isEmpty
//                               ? Colors.grey
//                               : const Color(0xFFD9534F),
//                         ),
//                       ),
//                       style: TextButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                           minimumSize: Size.zero,
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap),
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // ── Filter chips ─────────────────────────
//                   _buildFilterChips(sortedParents, parentToGroups),
//                   const SizedBox(height: 12),

//                   // ── Table fills remaining screen ─────────
//                   Expanded(
//                     child: state.isLoading
//                         ? _buildShimmer()
//                         : Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               border:
//                                   Border.all(color: const Color(0xFFEEEEEE)),
//                             ),
//                             child: Column(
//                               children: [
//                                 Expanded(
//                                   child: pageItems.isEmpty
//                                       ? const Center(
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Icon(
//                                                 Icons.account_balance_outlined,
//                                                 size: 48,
//                                                 color: Color(0xFFCCCCCC),
//                                               ),
//                                               SizedBox(height: 12),
//                                               Text(
//                                                 'No account heads found',
//                                                 style: TextStyle(
//                                                     color: Color(0xFF888888),
//                                                     fontSize: 14),
//                                               ),
//                                             ],
//                                           ),
//                                         )
//                                       : _TableWithSharedScroll(
//                                           pageItems: pageItems,
//                                           selectedIds: _selectedIds,
//                                           pageAllSelected: pageAllSelected,
//                                           onSelectAll: (v) =>
//                                               _toggleSelectAll(pageItems, v),
//                                           onSelect: _toggleSelect,
//                                           orange: _orange,
//                                         ),
//                                 ),
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
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChips(
//     List<String> sortedParents,
//     Map<String, Set<String>> parentToGroups,
//   ) {
//     final hasFilter = _selectedParent != null || _selectedMainGroup != null;
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       crossAxisAlignment: WrapCrossAlignment.center,
//       children: [
//         ...sortedParents.map((parent) {
//           final isSelected = _selectedParent == parent;
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 if (isSelected) {
//                   _selectedParent = null;
//                   _selectedMainGroup = null;
//                 } else {
//                   _selectedParent = parent;
//                   _selectedMainGroup = null;
//                 }
//                 _currentPage = 1;
//               });
//               if (isSelected) {
//                 context.read<AccountHeadBloc>().add(const ClearFilters());
//               } else {
//                 context.read<AccountHeadBloc>().add(UpdateMainFilter(parent));
//                 context
//                     .read<AccountHeadBloc>()
//                     .add(const UpdateSubFilter(null));
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: isSelected ? _orange : Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: isSelected ? _orange : const Color(0xFFDDDDDD),
//                 ),
//               ),
//               child: Text(
//                 parent,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: isSelected ? Colors.white : const Color(0xFF555555),
//                 ),
//               ),
//             ),
//           );
//         }),
//         if (_selectedParent != null)
//           ...() {
//             final groups = parentToGroups[_selectedParent]!.toList()..sort();
//             return groups.map((group) {
//               final isSelected = _selectedMainGroup == group;
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedMainGroup = isSelected ? null : group;
//                     _currentPage = 1;
//                   });
//                   context.read<AccountHeadBloc>().add(
//                         isSelected
//                             ? const UpdateSubFilter(null)
//                             : UpdateSubFilter(group),
//                       );
//                 },
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: isSelected ? _orange : const Color(0xFFDDDDDD),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 6,
//                         height: 6,
//                         decoration: BoxDecoration(
//                           color: isSelected ? _orange : const Color(0xFFCCCCCC),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         group,
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w500,
//                           color: isSelected ? _orange : const Color(0xFF777777),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList();
//           }(),
//         if (hasFilter)
//           GestureDetector(
//             onTap: _clearAllFilters,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFF0F0),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: const Color(0xFFFFCCCC)),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.close, size: 12, color: Color(0xFFD9534F)),
//                   SizedBox(width: 4),
//                   Text(
//                     'Clear',
//                     style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFFD9534F)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[200]!,
//       highlightColor: Colors.grey[50]!,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFEEEEEE)),
//         ),
//         child: Column(
//           children: List.generate(
//             10,
//             (_) => Column(children: [
//               Container(height: _kRowHeight, color: Colors.white),
//               const Divider(height: 1, color: Color(0xFFEEEEEE)),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// // _TableWithSharedScroll
// // ─────────────────────────────────────────────────────────────────
// class _TableWithSharedScroll extends StatefulWidget {
//   final List<AccountHeadData> pageItems;
//   final Set<int> selectedIds;
//   final bool pageAllSelected;
//   final void Function(bool?) onSelectAll;
//   final void Function(int, bool?) onSelect;
//   final Color orange;

//   const _TableWithSharedScroll({
//     required this.pageItems,
//     required this.selectedIds,
//     required this.pageAllSelected,
//     required this.onSelectAll,
//     required this.onSelect,
//     required this.orange,
//   });

//   @override
//   State<_TableWithSharedScroll> createState() => _TableWithSharedScrollState();
// }

// class _TableWithSharedScrollState extends State<_TableWithSharedScroll> {
//   late final ScrollController _hScroll;

//   @override
//   void initState() {
//     super.initState();
//     _hScroll = ScrollController();
//   }

//   @override
//   void dispose() {
//     _hScroll.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const headerStyle = TextStyle(
//         fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555));

//     return RawScrollbar(
//       controller: _hScroll,
//       thumbVisibility: true,
//       thickness: 4,
//       radius: const Radius.circular(2),
//       thumbColor: const Color(0xFFCCCCCC),
//       scrollbarOrientation: ScrollbarOrientation.bottom,
//       child: SingleChildScrollView(
//         controller: _hScroll,
//         scrollDirection: Axis.horizontal,
//         child: SizedBox(
//           width: _kTableContentWidth,
//           child: Column(
//             children: [
//               // ── Header ────────────────────────────
//               Container(
//                 height: _kHeaderHeight,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFFAFAFA),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: _kCheckboxW,
//                       child: Checkbox(
//                         value: widget.pageAllSelected,
//                         onChanged: widget.onSelectAll,
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(4)),
//                         side: const BorderSide(color: Color(0xFFCCCCCC)),
//                       ),
//                     ),
//                     const SizedBox(width: _kGapW),
//                     SizedBox(
//                         width: _kIdW,
//                         child: const Text('ID', style: headerStyle)),
//                     const SizedBox(
//                         width: 180, child: Text('Name', style: headerStyle)),
//                     const SizedBox(
//                         width: 130,
//                         child: Text('Main Group', style: headerStyle)),
//                     const SizedBox(
//                         width: 100, child: Text('Parent', style: headerStyle)),
//                     const SizedBox(
//                         width: 100,
//                         child: Text('Account Type', style: headerStyle)),
//                     SizedBox(
//                       width: _kActionW,
//                       child: const Text('Action',
//                           style: headerStyle, textAlign: TextAlign.center),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Color(0xFFEEEEEE)),

//               // ── Rows ──────────────────────────────
//               Expanded(
//                 child: ListView.separated(
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: widget.pageItems.length,
//                   separatorBuilder: (_, __) =>
//                       const Divider(height: 1, color: Color(0xFFEEEEEE)),
//                   itemBuilder: (context, i) {
//                     final head = widget.pageItems[i];
//                     final isSelected = widget.selectedIds.contains(head.id);
//                     const rs =
//                         TextStyle(fontSize: 13, color: Color(0xFF333333));
//                     return Container(
//                       height: _kRowHeight,
//                       color: isSelected
//                           ? const Color(0xFFFFF8F0)
//                           : Colors.transparent,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: _kCheckboxW,
//                             child: Checkbox(
//                               value: isSelected,
//                               onChanged: (v) => widget.onSelect(head.id, v),
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4)),
//                               activeColor: widget.orange,
//                               side: const BorderSide(color: Color(0xFFCCCCCC)),
//                             ),
//                           ),
//                           const SizedBox(width: _kGapW),
//                           SizedBox(
//                               width: _kIdW,
//                               child: Text('${head.id}', style: rs)),
//                           SizedBox(
//                             width: 180,
//                             child: Text(head.name,
//                                 style: rs, overflow: TextOverflow.ellipsis),
//                           ),
//                           SizedBox(
//                             width: 130,
//                             child: Text(head.mainGroup ?? 'N/A',
//                                 style: rs, overflow: TextOverflow.ellipsis),
//                           ),
//                           SizedBox(
//                             width: 100,
//                             child: Text(head.parent ?? 'N/A',
//                                 style: rs, overflow: TextOverflow.ellipsis),
//                           ),
//                           SizedBox(
//                             width: 100,
//                             child: Text(head.accountType ?? 'N/A',
//                                 style: rs, overflow: TextOverflow.ellipsis),
//                           ),
//                           SizedBox(
//                             width: _kActionW,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: const Icon(Icons.edit_outlined,
//                                       size: 16, color: Color(0xFF888888)),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: const Icon(
//                                       Icons.remove_red_eye_outlined,
//                                       size: 16,
//                                       color: Color(0xFF888888)),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: const Icon(Icons.delete_outline,
//                                       size: 16, color: Color(0xFF888888)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// // _PaginationBar
// // ─────────────────────────────────────────────────────────────────
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
//               icon: Icons.chevron_left,
//               onTap:
//                   currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
//             ),
//             const SizedBox(width: 4),
//             for (final p in pages) ...[
//               if (p == -1)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 2),
//                   child: Text('…',
//                       style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
//                 )
//               else
//                 _PagePill(
//                   page: p,
//                   isActive: p == currentPage,
//                   onTap: () => onPageChanged(p),
//                 ),
//               const SizedBox(width: 2),
//             ],
//             _PageBtn(
//               icon: Icons.chevron_right,
//               onTap: currentPage < totalPages
//                   ? () => onPageChanged(currentPage + 1)
//                   : null,
//             ),
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
//           border: Border.all(
//             color: isActive ? const Color(0xFFAAAAAA) : Colors.transparent,
//           ),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           '$page',
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
//             color: isActive ? const Color(0xFF1A1A1A) : const Color(0xFF555555),
//           ),
//         ),
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
//       child: Icon(
//         icon,
//         size: 20,
//         color:
//             onTap == null ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/model/account_heads_response.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_event.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_state.dart';

const double _kCheckboxW = 24;
const double _kGapW = 10;
const double _kIdW = 48;
const double _kActionW = 90;
const double _kTableMinWidth = 810.0;
const int _kPageSize = 10;
const double _kRowHeight = 72.0;
const double _kHeaderHeight = 60.0;

class AccountHead extends StatefulWidget {
  const AccountHead({super.key});

  @override
  State<AccountHead> createState() => _AccountHeadState();
}

class _AccountHeadState extends State<AccountHead> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedParent;
  String? _selectedMainGroup;
  final Set<int> _selectedIds = {};
  int _currentPage = 1;

  static const _orange = Color(0xFFE8891A);

  @override
  void initState() {
    super.initState();
    context.read<AccountHeadBloc>().add(const ClearFilters());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _currentPage = 1);
    context
        .read<AccountHeadBloc>()
        .add(SearchAccountHeads(_searchController.text));
  }

  void _clearAllFilters() {
    setState(() {
      _selectedParent = null;
      _selectedMainGroup = null;
      _currentPage = 1;
    });
    context.read<AccountHeadBloc>().add(const ClearFilters());
    _searchController.clear();
  }

  void _toggleSelectAll(List<AccountHeadData> pageItems, bool? value) {
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

  List<AccountHeadData> _pageSlice(List<AccountHeadData> filtered) {
    final start = (_currentPage - 1) * _kPageSize;
    if (start >= filtered.length) return [];
    return filtered.sublist(
        start, (start + _kPageSize).clamp(0, filtered.length));
  }

  int _totalPages(int count) => (count / _kPageSize).ceil().clamp(1, 9999);

  // New function: Show view detail popup
  void _showAccountDetailPopup(BuildContext context, AccountHeadData head) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Account Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Details in table-like rows
                _buildDetailRow('ID', head.id.toString()),
                _buildDetailRow('Name', head.name ?? 'N/A'),
                _buildDetailRow('Main Group', head.mainGroup ?? 'N/A'),
                _buildDetailRow('Parent', head.parent ?? 'N/A'),
                _buildDetailRow('Dr/Cr', head.drCr ?? 'N/A'),
                _buildDetailRow('Account Type', head.accountType ?? 'N/A'),
                _buildDetailRow('Opening Balance',
                    head.openingBalance?.toStringAsFixed(2) ?? '-'),
                _buildDetailRow(
                    'Status', head.status == true ? 'True' : 'False'),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<AccountHeadBloc, AccountHeadState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            final allHeads = state.accountHeads;
            final parentToGroups = <String, Set<String>>{};
            for (final head in allHeads) {
              final parent = head.parent ?? 'No Parent';
              final mainGroup = head.mainGroup ?? 'Unknown';
              parentToGroups.putIfAbsent(parent, () => {}).add(mainGroup);
            }
            final sortedParents = parentToGroups.keys.toList()..sort();
            final filteredHeads = state.getFilteredData();
            final totalPages = _totalPages(filteredHeads.length);

            if (_currentPage > totalPages && totalPages > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _currentPage = totalPages);
              });
            }

            final pageItems = _pageSlice(filteredHeads);
            final pageAllSelected = pageItems.isNotEmpty &&
                pageItems.every((v) => _selectedIds.contains(v.id));

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and categorize different account types',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(200),
                              border:
                                  Border.all(color: const Color(0xFFE0E0E0)),
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
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                          label: const Text('New Account',
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
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _selectedIds.isEmpty ? null : () {},
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
                    const SizedBox(height: 12),
                    _buildFilterChips(sortedParents, parentToGroups),
                    const SizedBox(height: 16),

                    // ── SHIMMER LOADING ────────────────────────────────
                    state.isLoading
                        ? _buildShimmer()
                        : Container(
                            height: 847,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFEEEEEE)),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: pageItems.isEmpty
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                  Icons
                                                      .account_balance_outlined,
                                                  size: 48,
                                                  color: Color(0xFFCCCCCC)),
                                              SizedBox(height: 12),
                                              Text('No account heads found',
                                                  style: TextStyle(
                                                      color: Color(0xFF888888),
                                                      fontSize: 14)),
                                            ],
                                          ),
                                        )
                                      : _TableWithSharedScroll(
                                          pageItems: pageItems,
                                          selectedIds: _selectedIds,
                                          pageAllSelected: pageAllSelected,
                                          onSelectAll: (v) =>
                                              _toggleSelectAll(pageItems, v),
                                          onSelect: _toggleSelect,
                                          orange: _orange,
                                        ),
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

  Widget _buildFilterChips(
      List<String> sortedParents, Map<String, Set<String>> parentToGroups) {
    final hasFilter = _selectedParent != null || _selectedMainGroup != null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...sortedParents.map((parent) {
          final isSelected = _selectedParent == parent;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedParent = null;
                  _selectedMainGroup = null;
                } else {
                  _selectedParent = parent;
                  _selectedMainGroup = null;
                }
                _currentPage = 1;
              });
              if (isSelected) {
                context.read<AccountHeadBloc>().add(const ClearFilters());
              } else {
                context.read<AccountHeadBloc>().add(UpdateMainFilter(parent));
                context
                    .read<AccountHeadBloc>()
                    .add(const UpdateSubFilter(null));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _orange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? _orange : const Color(0xFFDDDDDD)),
              ),
              child: Text(
                parent,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF555555)),
              ),
            ),
          );
        }),
        if (_selectedParent != null)
          ...() {
            final groups = parentToGroups[_selectedParent]!.toList()..sort();
            return groups.map((group) {
              final isSelected = _selectedMainGroup == group;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMainGroup = isSelected ? null : group;
                    _currentPage = 1;
                  });
                  context.read<AccountHeadBloc>().add(
                        isSelected
                            ? const UpdateSubFilter(null)
                            : UpdateSubFilter(group),
                      );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isSelected ? _orange : const Color(0xFFDDDDDD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? _orange : const Color(0xFFCCCCCC),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        group,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? _orange : const Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          }(),
        if (hasFilter)
          GestureDetector(
            onTap: _clearAllFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  Text('Clear',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFD9534F))),
                ],
              ),
            ),
          ),
      ],
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
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: List.generate(
            10,
            (_) => Column(children: [
              Container(height: _kRowHeight, color: Colors.white),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _TableWithSharedScroll extends StatefulWidget {
  final List<AccountHeadData> pageItems;
  final Set<int> selectedIds;
  final bool pageAllSelected;
  final void Function(bool?) onSelectAll;
  final void Function(int, bool?) onSelect;
  final Color orange;

  const _TableWithSharedScroll({
    required this.pageItems,
    required this.selectedIds,
    required this.pageAllSelected,
    required this.onSelectAll,
    required this.onSelect,
    required this.orange,
  });

  @override
  State<_TableWithSharedScroll> createState() => _TableWithSharedScrollState();
}

class _TableWithSharedScrollState extends State<_TableWithSharedScroll> {
  late final ScrollController _hScroll;

  @override
  void initState() {
    super.initState();
    _hScroll = ScrollController();
  }

  @override
  void dispose() {
    _hScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555));
    const rs = TextStyle(fontSize: 13, color: Color(0xFF333333));

    return RawScrollbar(
      controller: _hScroll,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(2),
      thumbColor: const Color(0xFFCCCCCC),
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        controller: _hScroll,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _kTableMinWidth,
          child: Column(
            children: [
              Container(
                height: _kHeaderHeight,
                decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12))),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                        width: _kCheckboxW,
                        child: Checkbox(
                            value: widget.pageAllSelected,
                            onChanged: widget.onSelectAll)),
                    const SizedBox(width: _kGapW),
                    const SizedBox(
                        width: _kIdW, child: Text('ID', style: headerStyle)),
                    const SizedBox(
                        width: 200, child: Text('Name', style: headerStyle)),
                    const SizedBox(
                        width: 140,
                        child: Text('Main Group', style: headerStyle)),
                    const SizedBox(
                        width: 120, child: Text('Parent', style: headerStyle)),
                    const SizedBox(
                        width: 120,
                        child: Text('Account Type', style: headerStyle)),
                    const SizedBox(
                        width: _kActionW + 20,
                        child: Text('Action',
                            style: headerStyle, textAlign: TextAlign.center)),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Column(
                children: widget.pageItems.asMap().entries.map((entry) {
                  final head = entry.value;
                  final isSelected = widget.selectedIds.contains(head.id);

                  return Column(
                    children: [
                      Container(
                        height: _kRowHeight,
                        color: isSelected
                            ? const Color(0xFFFFF8F0)
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            SizedBox(
                                width: _kCheckboxW,
                                child: Checkbox(
                                    value: isSelected,
                                    onChanged: (v) =>
                                        widget.onSelect(head.id, v))),
                            const SizedBox(width: _kGapW),
                            SizedBox(
                                width: _kIdW,
                                child: Text('${head.id}', style: rs)),
                            SizedBox(
                                width: 200,
                                child: Text(head.name ?? '',
                                    style: rs,
                                    overflow: TextOverflow.ellipsis)),
                            SizedBox(
                                width: 140,
                                child: Text(head.mainGroup ?? 'N/A',
                                    style: rs,
                                    overflow: TextOverflow.ellipsis)),
                            SizedBox(
                                width: 120,
                                child: Text(head.parent ?? 'N/A',
                                    style: rs,
                                    overflow: TextOverflow.ellipsis)),
                            SizedBox(
                                width: 120,
                                child: Text(head.accountType ?? 'N/A',
                                    style: rs,
                                    overflow: TextOverflow.ellipsis)),
                            SizedBox(
                              width: _kActionW + 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Show popup for view detail
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              constraints: const BoxConstraints(
                                                  maxWidth: 700),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Header
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'Account Details',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            color: Colors.grey),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Grid rows with dividers
                                                  _buildGridRow(
                                                      'ID',
                                                      head.id.toString(),
                                                      'Name',
                                                      head.name ?? 'N/A'),
                                                  const Divider(height: 1),
                                                  _buildGridRow(
                                                      'Main Group',
                                                      head.mainGroup ?? 'N/A',
                                                      'Parent',
                                                      head.parent ?? 'N/A'),
                                                  const Divider(height: 1),
                                                  _buildGridRow(
                                                      'Dr Cr',
                                                      head.drCr ?? 'N/A',
                                                      'Account Type',
                                                      head.accountType ??
                                                          'N/A'),
                                                  const Divider(height: 1),
                                                  _buildGridRow(
                                                    'Opening Balance',
                                                    head.openingBalance
                                                            ?.toStringAsFixed(
                                                                2) ??
                                                        '-',
                                                    'Status',
                                                    head.status == true
                                                        ? 'True'
                                                        : 'False',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 16,
                                        color: Color(0xFF888888)),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Icon(Icons.edit_outlined,
                                        size: 16, color: Color(0xFF888888)),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Icon(Icons.delete_outline,
                                        size: 16, color: Color(0xFF888888)),
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
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
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
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
                fontWeight: FontWeight.normal, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// Pagination (your original code - unchanged)
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
                        style:
                            TextStyle(color: Color(0xFF888888), fontSize: 13)))
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
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text('$page',
            style: TextStyle(
                fontSize: 12,
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
