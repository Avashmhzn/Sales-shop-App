// import 'dart:async';
// import 'package:dio/dio.dart' as dio;
// import 'package:flutter/material.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/account_heads_response.dart';
// import 'package:saleup_app/screen/accountHead/widgets/account_head_card.dart';

// class AccountHead extends StatefulWidget {
//   const AccountHead({super.key});

//   @override
//   State<AccountHead> createState() => _AccountHeadState();
// }

// class _AccountHeadState extends State<AccountHead>
//     with SingleTickerProviderStateMixin {
//   bool isLoading = true;
//   List<AccountHeadData> accountHeads = [];
//   int currentPage = 1;
//   int itemsPerPage = 10;
//   int totalItems = 0;
//   String searchQuery = '';
//   String selectedMainFilter = 'All';
//   String? selectedSubFilter;
//   Map<String, Set<String>> subFilters = {};
//   Set<String> allParents = {'All'};
//   Set<String> availableSubFilters = {};
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
//     fetchAccountHeads();
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchAccountHeads() async {
//     setState(() => isLoading = true);
//     try {
//       final response =
//           await DioClient().dio.get('/account-heads/get_account_heads/');
//       final accountHeadsResponse = AccountHeadsResponse.fromJson(response.data);

//       if (accountHeadsResponse.success == true) {
//         setState(() {
//           accountHeads = accountHeadsResponse.data;
//           totalItems = accountHeadsResponse.total ?? accountHeads.length;
//           subFilters.clear();
//           for (var head in accountHeads) {
//             final parent = head.parent ?? '';
//             final mainGroup = head.mainGroup ?? '';
//             if (parent.isNotEmpty && mainGroup.isNotEmpty) {
//               subFilters.putIfAbsent(parent, () => <String>{}).add(mainGroup);
//             }
//           }
//           allParents = {'All'}..addAll(accountHeads
//               .map((head) => head.parent ?? '')
//               .where((parent) => parent.isNotEmpty));
//           availableSubFilters = selectedMainFilter != 'All'
//               ? accountHeads
//                   .where((head) =>
//                       head.parent == selectedMainFilter &&
//                       head.mainGroup != null &&
//                       head.mainGroup!.isNotEmpty)
//                   .map((head) => head.mainGroup!)
//                   .toSet()
//               : {};
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(accountHeadsResponse.message ?? 'Error occurred')),
//         );
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       final errorMessage = e is dio.DioError
//           ? 'Network error: ${e.message}'
//           : 'An unexpected error occurred';
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(errorMessage)),
//       );
//     }
//   }

//   List<AccountHeadData> getFilteredData() {
//     var filteredList = accountHeads
//         .where((head) =>
//             head.name.toLowerCase().contains(searchQuery.toLowerCase()))
//         .toList();

//     if (selectedMainFilter != 'All') {
//       filteredList = filteredList
//           .where((head) => head.parent == selectedMainFilter)
//           .toList();
//     }

//     if (selectedSubFilter != null && selectedSubFilter!.isNotEmpty) {
//       filteredList = filteredList
//           .where((head) => head.mainGroup == selectedSubFilter)
//           .toList();
//     }

//     filteredList.sort((a, b) => a.id.compareTo(b.id));
//     return filteredList;
//   }

//   List<AccountHeadData> getPaginatedData() {
//     final filteredList = getFilteredData();
//     final startIndex = (currentPage - 1) * itemsPerPage;
//     final endIndex = startIndex + itemsPerPage;
//     return filteredList.sublist(startIndex,
//         endIndex > filteredList.length ? filteredList.length : endIndex);
//   }

//   int getTotalPages() {
//     return (getFilteredData().length / itemsPerPage).ceil();
//   }

//   void goToPage(int page) {
//     final totalPages = getTotalPages();
//     final newPage = page.clamp(1, totalPages);
//     if (newPage != currentPage) {
//       setState(() => currentPage = newPage);
//     }
//   }

//   void updateMainFilter(String? parent) {
//     setState(() {
//       selectedMainFilter = parent ?? 'All';
//       selectedSubFilter = null;
//       currentPage = 1;
//       availableSubFilters = selectedMainFilter != 'All'
//           ? accountHeads
//               .where((head) =>
//                   head.parent == selectedMainFilter &&
//                   head.mainGroup != null &&
//                   head.mainGroup!.isNotEmpty)
//               .map((head) => head.mainGroup!)
//               .toSet()
//           : {};
//     });
//   }

//   void updateSubFilter(String? mainGroup) {
//     setState(() {
//       selectedSubFilter = mainGroup;
//       currentPage = 1;
//     });
//   }

//   void clearFilters() {
//     setState(() {
//       selectedMainFilter = 'All';
//       selectedSubFilter = null;
//       currentPage = 1;
//       searchQuery = '';
//       availableSubFilters.clear();
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
//       builder: (BuildContext context) {
//         final screenHeight = MediaQuery.of(context).size.height;
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
//                         'Main Filter',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: [
//                           FilterChip(
//                             label: const Text('All'),
//                             selected: selectedMainFilter == 'All',
//                             onSelected: (bool value) {
//                               if (value)
//                                 setState(() => updateMainFilter('All'));
//                             },
//                             selectedColor: Colors.brown[700],
//                             labelStyle: TextStyle(
//                               color: selectedMainFilter == 'All'
//                                   ? Colors.white
//                                   : Colors.grey[400],
//                               fontSize: 14,
//                             ),
//                           ),
//                           ...allParents
//                               .where((parent) => parent != 'All')
//                               .map((parent) {
//                             return FilterChip(
//                               label: Text(
//                                 parent,
//                                 style: const TextStyle(fontSize: 14),
//                                 softWrap: true,
//                                 overflow: TextOverflow.clip,
//                               ),
//                               selected: selectedMainFilter == parent,
//                               onSelected: (bool value) {
//                                 if (value)
//                                   setState(() => updateMainFilter(parent));
//                               },
//                               selectedColor: Colors.brown[700],
//                               labelStyle: TextStyle(
//                                 color: selectedMainFilter == parent
//                                     ? Colors.white
//                                     : Colors.grey[400],
//                                 fontSize: 14,
//                               ),
//                             );
//                           }).toList(),
//                         ],
//                       ),
//                       if (selectedMainFilter != 'All') ...[
//                         const SizedBox(height: 16),
//                         const Text(
//                           'Sub Filter',
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
//                               selected: selectedSubFilter == null,
//                               onSelected: (bool value) {
//                                 if (value)
//                                   setState(() => updateSubFilter(null));
//                               },
//                               selectedColor: Colors.brown[700],
//                               labelStyle: TextStyle(
//                                 color: selectedSubFilter == null
//                                     ? Colors.white
//                                     : Colors.grey[400],
//                                 fontSize: 14,
//                               ),
//                             ),
//                             ...availableSubFilters.map((mainGroup) {
//                               return FilterChip(
//                                 label: Text(
//                                   mainGroup,
//                                   style: const TextStyle(fontSize: 14),
//                                   softWrap: true,
//                                   overflow: TextOverflow.clip,
//                                 ),
//                                 selected: selectedSubFilter == mainGroup,
//                                 onSelected: (bool value) {
//                                   if (value)
//                                     setState(() => updateSubFilter(mainGroup));
//                                 },
//                                 selectedColor: Colors.brown[700],
//                                 labelStyle: TextStyle(
//                                   color: selectedSubFilter == mainGroup
//                                       ? Colors.white
//                                       : Colors.grey[400],
//                                   fontSize: 14,
//                                 ),
//                               );
//                             }).toList(),
//                           ],
//                         ),
//                       ],
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             onPressed: () {
//                               clearFilters();
//                               Navigator.pop(context);
//                             },
//                             style: TextButton.styleFrom(
//                                 foregroundColor: Colors.white),
//                             child: const Text('Clear'),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {});
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.brown[700],
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Apply'),
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
//     ).whenComplete(() => _animationController.reset());
//   }

//   void _onSearchChanged(String value) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       setState(() => searchQuery = value);
//     });
//   }

//   void _deleteAccountHead(int id) async {
//     try {
//       // Placeholder for API call to delete the account head
//       // await DioClient().dio.delete('/account-heads/$id');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Account head with ID: $id deleted')),
//       );
//       await fetchAccountHeads(); // Refresh the list after deletion
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete account head: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final paginatedData = getPaginatedData();
//     final totalPages = getTotalPages();
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.all(screenWidth * 0.02),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Inventory Management",
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.05,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(width: screenWidth * 0.02),
//                   Padding(
//                     padding: EdgeInsets.all(screenWidth * 0.02),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: SizedBox(
//                                 height: 60,
//                                 child: TextField(
//                                   decoration: InputDecoration(
//                                     labelText: 'Search Here',
//                                     prefixIcon: const Icon(Icons.search),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 10,
//                                       horizontal: 12,
//                                     ),
//                                   ),
//                                   onChanged: _onSearchChanged,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 5),
//                             IconButton(
//                               icon: Image.asset(
//                                 'assets/icons/filter.png',
//                                 width: 24,
//                                 height: 24,
//                                 color: Colors.grey,
//                               ),
//                               onPressed: showFilterBottomSheet,
//                               style: IconButton.styleFrom(
//                                 side: const BorderSide(
//                                     color: Colors.grey), // Adds outline
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: screenWidth,
//                     child: isLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : paginatedData.isEmpty
//                             ? const Center(
//                                 child: Text("No account heads found"))
//                             : ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: paginatedData.length,
//                                 itemBuilder: (context, index) {
//                                   return AccountHeadCard(
//                                     head: paginatedData[index],
//                                     screenWidth: screenWidth,
//                                     screenHeight: screenHeight,
//                                     onDelete: _deleteAccountHead,
//                                   );
//                                 },
//                               ),
//                   ),
//                   if (totalPages > 1)
//                     Padding(
//                       padding: EdgeInsets.all(screenWidth * 0.02),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                               icon: const Icon(Icons.first_page),
//                               onPressed:
//                                   currentPage > 1 ? () => goToPage(1) : null),
//                           const SizedBox(width: 5),
//                           IconButton(
//                               icon: const Icon(Icons.arrow_back),
//                               onPressed: currentPage > 1
//                                   ? () => goToPage(currentPage - 1)
//                                   : null),
//                           const SizedBox(width: 5),
//                           Text('$currentPage of $totalPages'),
//                           const SizedBox(width: 5),
//                           IconButton(
//                               icon: const Icon(Icons.arrow_forward),
//                               onPressed: currentPage < totalPages
//                                   ? () => goToPage(currentPage + 1)
//                                   : null),
//                           const SizedBox(width: 5),
//                           IconButton(
//                               icon: const Icon(Icons.last_page),
//                               onPressed: currentPage < totalPages
//                                   ? () => goToPage(totalPages)
//                                   : null),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_event.dart';
// import 'package:saleup_app/screen/accountHead/bloc/account_head_state.dart';
// import 'package:saleup_app/screen/accountHead/widgets/account_head_card.dart';

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
//     context.read<AccountHeadBloc>().add(ClearFilters());
//     context.read<AccountHeadBloc>().add(FetchAccountHeads());
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
//                             }).toList(),
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
//                                   if (value) {
//                                     print('Selecting sub filter: All');
//                                     context
//                                         .read<AccountHeadBloc>()
//                                         .add(const UpdateSubFilter(null));
//                                   }
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
//                                     if (value) {
//                                       print('Selecting sub filter: $mainGroup');
//                                       context
//                                           .read<AccountHeadBloc>()
//                                           .add(UpdateSubFilter(mainGroup));
//                                     }
//                                   },
//                                   selectedColor: Colors.brown[700],
//                                   labelStyle: TextStyle(
//                                     color: state.selectedSubFilter == mainGroup
//                                         ? Colors.white
//                                         : Colors.grey[400],
//                                     fontSize: 14,
//                                   ),
//                                 );
//                               }).toList(),
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
//                                     .add(ClearFilters());
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
//           final paginatedData = filteredData.isNotEmpty
//               ? filteredData.sublist(
//                   (state.currentPage - 1) * state.itemsPerPage,
//                   ((state.currentPage - 1) * state.itemsPerPage +
//                           state.itemsPerPage)
//                       .clamp(0, filteredData.length))
//               : [];
//           final totalPages = filteredData.isNotEmpty
//               ? (filteredData.length / state.itemsPerPage).ceil()
//               : 1;
//           print('Building UI with: '
//               'paginatedDataLength=${paginatedData.length}, '
//               'totalPages=$totalPages, '
//               'currentPage=${state.currentPage}');

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
//                             ? const Center(child: CircularProgressIndicator())
//                             : paginatedData.isEmpty
//                                 ? const Center(
//                                     child: Text("No account heads found"))
//                                 : ListView.builder(
//                                     key: ValueKey(
//                                         '${state.accountHeads.length}_${state.currentPage}_${state.isFiltersCleared}_${state.searchQuery}_${state.selectedMainFilter}_${state.selectedSubFilter}'),
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
//                       if (totalPages > 1)
//                         Padding(
//                           padding: EdgeInsets.all(screenWidth * 0.02),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               IconButton(
//                                   icon: const Icon(Icons.first_page),
//                                   onPressed: state.currentPage > 1
//                                       ? () => context
//                                           .read<AccountHeadBloc>()
//                                           .add(const GoToPage(1))
//                                       : null),
//                               const SizedBox(width: 5),
//                               IconButton(
//                                   icon: const Icon(Icons.arrow_back),
//                                   onPressed: state.currentPage > 1
//                                       ? () => context
//                                           .read<AccountHeadBloc>()
//                                           .add(GoToPage(state.currentPage - 1))
//                                       : null),
//                               const SizedBox(width: 5),
//                               Text('${state.currentPage} of $totalPages'),
//                               const SizedBox(width: 5),
//                               IconButton(
//                                   icon: const Icon(Icons.arrow_forward),
//                                   onPressed: state.currentPage < totalPages
//                                       ? () => context
//                                           .read<AccountHeadBloc>()
//                                           .add(GoToPage(state.currentPage + 1))
//                                       : null),
//                               const SizedBox(width: 5),
//                               IconButton(
//                                   icon: const Icon(Icons.last_page),
//                                   onPressed: state.currentPage < totalPages
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
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_bloc.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_event.dart';
import 'package:saleup_app/screen/accountHead/bloc/account_head_state.dart';
import 'package:saleup_app/screen/accountHead/widgets/account_head_card.dart';
import 'package:shimmer/shimmer.dart';

class AccountHead extends StatefulWidget {
  const AccountHead({super.key});

  @override
  State<AccountHead> createState() => _AccountHeadState();
}

class _AccountHeadState extends State<AccountHead>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _debounce;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      print('Flutter error: ${details.exception}, stack: ${details.stack}');
    };
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
    _searchController = TextEditingController();
    context.read<AccountHeadBloc>().add(const ClearFilters());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      print('Dispatching SearchAccountHeads: $value');
      context.read<AccountHeadBloc>().add(SearchAccountHeads(value));
    });
  }

  void showFilterBottomSheet() {
    _animationController.forward();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      transitionAnimationController: _animationController,
      isScrollControlled: true,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<AccountHeadBloc>(),
          child: BlocBuilder<AccountHeadBloc, AccountHeadState>(
            builder: (context, state) {
              print('Bottom sheet rebuilt with state: '
                  'mainFilter=${state.selectedMainFilter}, '
                  'subFilter=${state.selectedSubFilter}, '
                  'isFiltersCleared=${state.isFiltersCleared}');
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
                          'Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Main Filter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: state.selectedMainFilter == 'All',
                              onSelected: (bool value) {
                                if (value) {
                                  print('Selecting main filter: All');
                                  context
                                      .read<AccountHeadBloc>()
                                      .add(const UpdateMainFilter('All'));
                                }
                              },
                              selectedColor: Colors.brown[700],
                              labelStyle: TextStyle(
                                color: state.selectedMainFilter == 'All'
                                    ? Colors.white
                                    : Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            ...state.allParents
                                .where((parent) => parent != 'All')
                                .map((parent) {
                              return FilterChip(
                                label: Text(
                                  parent,
                                  style: const TextStyle(fontSize: 14),
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                ),
                                selected: state.selectedMainFilter == parent,
                                onSelected: (bool value) {
                                  if (value) {
                                    print('Selecting main filter: $parent');
                                    context
                                        .read<AccountHeadBloc>()
                                        .add(UpdateMainFilter(parent));
                                  }
                                },
                                selectedColor: Colors.brown[700],
                                labelStyle: TextStyle(
                                  color: state.selectedMainFilter == parent
                                      ? Colors.white
                                      : Colors.grey[400],
                                  fontSize: 14,
                                ),
                              );
                            }),
                          ],
                        ),
                        if (state.selectedMainFilter != 'All') ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Sub Filter',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: state.selectedSubFilter == null,
                                onSelected: (bool value) {
                                  print(
                                      'All sub-filter clicked, value: $value');
                                  context
                                      .read<AccountHeadBloc>()
                                      .add(const UpdateSubFilter(null));
                                },
                                selectedColor: Colors.brown[700],
                                labelStyle: TextStyle(
                                  color: state.selectedSubFilter == null
                                      ? Colors.white
                                      : Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              ...state.availableSubFilters.map((mainGroup) {
                                return FilterChip(
                                  label: Text(
                                    mainGroup,
                                    style: const TextStyle(fontSize: 14),
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                  ),
                                  selected:
                                      state.selectedSubFilter == mainGroup,
                                  onSelected: (bool value) {
                                    print(
                                        'Sub-filter $mainGroup clicked, value: $value');
                                    context
                                        .read<AccountHeadBloc>()
                                        .add(UpdateSubFilter(mainGroup));
                                  },
                                  selectedColor: Colors.brown[700],
                                  labelStyle: TextStyle(
                                    color: state.selectedSubFilter == mainGroup
                                        ? Colors.white
                                        : Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                print('Clear button pressed');
                                _searchController.clear();
                                context
                                    .read<AccountHeadBloc>()
                                    .add(const ClearFilters());
                                Navigator.pop(dialogContext);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Clear'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                print('Apply button pressed');
                                context
                                    .read<AccountHeadBloc>()
                                    .add(const UpdateFiltersApplied());
                                Navigator.pop(dialogContext);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[700],
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: screenWidth * 0.5,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      Container(
                        width: screenWidth * 0.2,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: screenWidth * 0.3,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                      Container(
                        width: screenWidth * 0.3,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: screenWidth * 0.2,
                    height: 14,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocConsumer<AccountHeadBloc, AccountHeadState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          print('Main UI state updated: '
              'searchQuery=${state.searchQuery}, '
              'selectedMainFilter=${state.selectedMainFilter}, '
              'selectedSubFilter=${state.selectedSubFilter}, '
              'isFiltersCleared=${state.isFiltersCleared}, '
              'accountHeadsLength=${state.accountHeads.length}, '
              'filteredDataLength=${state.getFilteredData().length}');
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
              print(
                  'Correcting currentPage from ${state.currentPage} to $validCurrentPage');
              context.read<AccountHeadBloc>().add(GoToPage(validCurrentPage));
            });
          }
          final paginatedData = filteredData.isNotEmpty
              ? filteredData.sublist(
                  (validCurrentPage - 1) * state.itemsPerPage,
                  ((validCurrentPage - 1) * state.itemsPerPage +
                          state.itemsPerPage)
                      .clamp(0, filteredData.length))
              : [];
          print('Building UI with: '
              'paginatedDataLength=${paginatedData.length}, '
              'totalPages=$totalPages, '
              'currentPage=${state.currentPage}, '
              'validCurrentPage=$validCurrentPage');

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Inventory Management",
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
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                                  onPressed: showFilterBottomSheet,
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
                                ? const Center(
                                    child: Text("No account heads found"))
                                : ListView.builder(
                                    key: ValueKey(
                                        '${state.accountHeads.length}_${validCurrentPage}_${state.isFiltersCleared}_${state.searchQuery}_${state.selectedMainFilter}_${state.selectedSubFilter}'),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: paginatedData.length,
                                    itemBuilder: (context, index) {
                                      return AccountHeadCard(
                                        head: paginatedData[index],
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
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
                                          .read<AccountHeadBloc>()
                                          .add(const GoToPage(1))
                                      : null),
                              const SizedBox(width: 5),
                              IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: validCurrentPage > 1
                                      ? () => context
                                          .read<AccountHeadBloc>()
                                          .add(GoToPage(validCurrentPage - 1))
                                      : null),
                              const SizedBox(width: 5),
                              Text('$validCurrentPage of $totalPages'),
                              const SizedBox(width: 5),
                              IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: validCurrentPage < totalPages
                                      ? () => context
                                          .read<AccountHeadBloc>()
                                          .add(GoToPage(validCurrentPage + 1))
                                      : null),
                              const SizedBox(width: 5),
                              IconButton(
                                  icon: const Icon(Icons.last_page),
                                  onPressed: validCurrentPage < totalPages
                                      ? () => context
                                          .read<AccountHeadBloc>()
                                          .add(GoToPage(totalPages))
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
      ),
    );
  }
}
