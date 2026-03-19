// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/parties/bloc/party_bloc.dart';
// import 'package:saleup_app/screen/parties/bloc/party_event.dart';
// import 'package:saleup_app/screen/parties/bloc/party_state.dart';
// import 'package:saleup_app/screen/parties/widget/party_card.dart';

// class PartiesScreen extends StatefulWidget {
//   const PartiesScreen({super.key});

//   @override
//   State<PartiesScreen> createState() => _PartiesScreenState();
// }

// class _PartiesScreenState extends State<PartiesScreen>
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
//     context.read<PartyBloc>().add(const FetchParties());
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
//       context.read<PartyBloc>().add(SearchParties(query));
//     });
//   }

//   void showFilterBottomSheet(BuildContext context, PartyBloc partyBloc) {
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
//                         'Party Type',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: partyBloc.state.allTypes
//                             .map((type) => FilterChip(
//                                   label: Text(type),
//                                   selected:
//                                       partyBloc.state.selectedTypeFilter ==
//                                           type,
//                                   onSelected: (bool value) {
//                                     if (value) {
//                                       setState(() {
//                                         partyBloc.add(UpdateTypeFilter(type));
//                                       });
//                                     }
//                                   },
//                                   selectedColor: Colors.brown[700],
//                                   labelStyle: TextStyle(
//                                     color: partyBloc.state.selectedTypeFilter ==
//                                             type
//                                         ? Colors.white
//                                         : Colors.black,
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           OutlinedButton(
//                             onPressed: () {
//                               setState(() {
//                                 partyBloc.add(const ClearFilters());
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
//                               partyBloc.add(const UpdateFiltersApplied());
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

//     return BlocConsumer<PartyBloc, PartyState>(
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
//             'partiesLength=${state.parties.length}, '
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
//         final totalPages = filteredData.isNotEmpty
//             ? (filteredData.length / state.itemsPerPage).ceil()
//             : 1;
//         final validCurrentPage = state.currentPage.clamp(1, totalPages);
//         if (validCurrentPage != state.currentPage) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             print(
//                 'Correcting currentPage from ${state.currentPage} to $validCurrentPage');
//             context.read<PartyBloc>().add(GoToPage(validCurrentPage));
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
//                       "Parties Management",
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
//                                     context, context.read<PartyBloc>()),
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
//                               ? const Center(child: Text("No parties found"))
//                               : ListView.builder(
//                                   key: ValueKey(
//                                       '${state.parties.length}_${validCurrentPage}_${state.isFiltersCleared}_${state.searchQuery}_${state.selectedTypeFilter}'),
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: paginatedData.length,
//                                   itemBuilder: (context, index) {
//                                     return PartyCard(
//                                       party: paginatedData[index],
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
//                                         .read<PartyBloc>()
//                                         .add(const GoToPage(1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_back),
//                                 onPressed: validCurrentPage > 1
//                                     ? () => context
//                                         .read<PartyBloc>()
//                                         .add(GoToPage(validCurrentPage - 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             Text('$validCurrentPage of $totalPages'),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.arrow_forward),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<PartyBloc>()
//                                         .add(GoToPage(validCurrentPage + 1))
//                                     : null),
//                             const SizedBox(width: 5),
//                             IconButton(
//                                 icon: const Icon(Icons.last_page),
//                                 onPressed: validCurrentPage < totalPages
//                                     ? () => context
//                                         .read<PartyBloc>()
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
import 'package:saleup_app/screen/parties/bloc/party_bloc.dart';
import 'package:saleup_app/screen/parties/bloc/party_event.dart';
import 'package:saleup_app/screen/parties/bloc/party_state.dart';
import 'package:saleup_app/model/party_response.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    context.read<PartyBloc>().add(const FetchParties());
    _searchController.addListener(_onSearchChangedListener);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChangedListener);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChangedListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<PartyBloc>().add(SearchParties(_searchController.text));
    });
  }

  void _toggleSelectAll(bool? value) {
    final filteredData = context.read<PartyBloc>().state.getFilteredData();
    final pageData = filteredData.isNotEmpty
        ? filteredData.sublist(
            ((context.read<PartyBloc>().state.currentPage - 1) *
                    context.read<PartyBloc>().state.itemsPerPage)
                .clamp(0, filteredData.length),
            (((context.read<PartyBloc>().state.currentPage - 1) *
                        context.read<PartyBloc>().state.itemsPerPage) +
                    context.read<PartyBloc>().state.itemsPerPage)
                .clamp(0, filteredData.length))
        : [];
    setState(() {
      if (value == true) {
        _selectedIds.addAll(pageData.map((p) => p.id));
      } else {
        _selectedIds.clear();
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

  void _showPartyDetailDialog(PartyData party) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.92 : 520.0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Party Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailField('Party ID:', party.id.toString()),
                        _buildDetailField(
                            'Account Head:', party.accType ?? '-'),
                        _buildDetailField('Type:', party.type ?? 'N/A'),
                        _buildDetailField(
                            'Description:', party.description ?? '-'),
                        _buildDetailField(
                            'Status:', party.status == true ? 'True' : 'False'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailField('Name:', party.name),
                        _buildDetailField(
                            'Pan number:', party.panNumber ?? 'N/A'),
                        _buildDetailField('Phone:', party.phone ?? 'N/A'),
                        _buildDetailField(
                          'Opening Balance:',
                          party.openingBalance != null
                              ? 'Rs ${party.openingBalance!.toStringAsFixed(2)}'
                              : 'Rs 0.00',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PartyBloc, PartyState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red),
          );
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

        final paginatedData = filteredData.isNotEmpty
            ? filteredData.sublist(
                (validCurrentPage - 1) * state.itemsPerPage,
                ((validCurrentPage - 1) * state.itemsPerPage +
                        state.itemsPerPage)
                    .clamp(0, filteredData.length),
              )
            : [];

        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + New Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Parties',
                                      style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text(
                                    'Add or update suppliers/customers \nand maintain party-related records',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('New Parties'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9800),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Search + Delete All
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search...',
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 0),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton.icon(
                                onPressed: _selectedIds.isEmpty
                                    ? null
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Delete functionality coming soon')),
                                        );
                                        setState(() => _selectedIds.clear());
                                      },
                                icon:
                                    const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Delete All'),
                                style: TextButton.styleFrom(
                                  foregroundColor: _selectedIds.isEmpty
                                      ? Colors.grey
                                      : const Color(0xFFD9534F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Filter
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFEEEEEE)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Filter Parties',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: [
                                    _buildFilterChip(
                                        context,
                                        'Sundry Creditors',
                                        'Sundry Creditor',
                                        state.selectedTypeFilter),
                                    _buildFilterChip(
                                        context,
                                        'Sundry Debtors',
                                        'Sundry Debtor',
                                        state.selectedTypeFilter),
                                    GestureDetector(
                                      onTap: () => context
                                          .read<PartyBloc>()
                                          .add(const ClearFilters()),
                                      child: const Text(
                                        'Clear Filters',
                                        style: TextStyle(
                                            color: Color(0xFFD9534F),
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Table - No extra left space (fixed)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width:
                                  730, // minimum width to avoid squishing (adjust if needed)
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFEEEEEE)),
                                ),
                                child: Column(
                                  children: [
                                    // Header - same style as AccountHead
                                    Container(
                                      height: 60,
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
                                            width: 48,
                                            child: Checkbox(
                                              value: paginatedData.isNotEmpty &&
                                                  paginatedData.every((p) =>
                                                      _selectedIds
                                                          .contains(p.id)),
                                              onChanged: (v) =>
                                                  _toggleSelectAll(v),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const SizedBox(
                                            width: 60,
                                            child: Text('ID',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF555555))),
                                          ),
                                          const SizedBox(
                                            width: 60,
                                            child: Text('Name',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF555555))),
                                          ),
                                          const SizedBox(
                                            width: 140,
                                            child: Text('Phone Number',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF555555))),
                                          ),
                                          const SizedBox(
                                            width: 140,
                                            child: Text('Pan Number',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF555555))),
                                          ),
                                          const SizedBox(
                                            width: 120,
                                            child: Text('Type',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF555555))),
                                          ),
                                          const SizedBox(
                                            width: 110,
                                            child: Text('Action',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF555555))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFEEEEEE)),

                                    // Rows - same style as AccountHead
                                    if (paginatedData.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(40),
                                        child: Center(
                                            child: Text('No parties found')),
                                      )
                                    else
                                      ...paginatedData.map((party) {
                                        final isSelected =
                                            _selectedIds.contains(party.id);
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  _showPartyDetailDialog(party),
                                              child: Container(
                                                height: 72,
                                                color: isSelected
                                                    ? const Color(0xFFFFF8F0)
                                                    : Colors.transparent,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 48,
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged: (v) =>
                                                            _toggleSelect(
                                                                party.id, v),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    SizedBox(
                                                      width: 60,
                                                      child: Text('${party.id}',
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0xFF333333))),
                                                    ),
                                                    SizedBox(
                                                      width: 60,
                                                      child: Text(
                                                        party.name,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFF333333)),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 140,
                                                      child: Text(
                                                        party.phone ?? 'N/A',
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFF333333)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 140,
                                                      child: Text(
                                                        party.panNumber ??
                                                            'N/A',
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFF333333)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 120,
                                                      child: Text(
                                                        party.type ?? 'N/A',
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFF333333)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 110,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () =>
                                                                _showPartyDetailDialog(
                                                                    party),
                                                            child: const Icon(
                                                                Icons
                                                                    .remove_red_eye_outlined,
                                                                size: 16,
                                                                color: Color(
                                                                    0xFF888888)),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          const Icon(
                                                              Icons
                                                                  .edit_outlined,
                                                              size: 16,
                                                              color: Color(
                                                                  0xFF888888)),
                                                          const SizedBox(
                                                              width: 10),
                                                          const Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              size: 16,
                                                              color: Color(
                                                                  0xFF888888)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                                height: 1,
                                                color: Color(0xFFEEEEEE)),
                                          ],
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          if (totalPages > 1)
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: validCurrentPage > 1
                                        ? () => context
                                            .read<PartyBloc>()
                                            .add(GoToPage(validCurrentPage - 1))
                                        : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007AFF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$validCurrentPage',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: validCurrentPage < totalPages
                                        ? () => context
                                            .read<PartyBloc>()
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String blocValue,
      String currentFilter) {
    final bool isSelected = currentFilter == blocValue;
    return GestureDetector(
      onTap: () => context.read<PartyBloc>().add(UpdateTypeFilter(blocValue)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFFE8891A)
                  : const Color(0xFFEEEEEE)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFFE8891A) : Colors.black87,
          ),
        ),
      ),
    );
  }
}
