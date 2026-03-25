// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/screen/parties/bloc/party_bloc.dart';
// import 'package:saleup_app/screen/parties/bloc/party_event.dart';
// import 'package:saleup_app/screen/parties/bloc/party_state.dart';
// import 'package:saleup_app/model/party_response.dart';

// class PartiesScreen extends StatefulWidget {
//   const PartiesScreen({super.key});

//   @override
//   State<PartiesScreen> createState() => _PartiesScreenState();
// }

// class _PartiesScreenState extends State<PartiesScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   final Set<int> _selectedIds = {};

//   @override
//   void initState() {
//     super.initState();
//     context.read<PartyBloc>().add(const FetchParties());
//     _searchController.addListener(_onSearchChangedListener);
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.removeListener(_onSearchChangedListener);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChangedListener() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       context.read<PartyBloc>().add(SearchParties(_searchController.text));
//     });
//   }

//   void _toggleSelectAll(bool? value) {
//     final filteredData = context.read<PartyBloc>().state.getFilteredData();
//     final pageData = filteredData.isNotEmpty
//         ? filteredData.sublist(
//             ((context.read<PartyBloc>().state.currentPage - 1) *
//                     context.read<PartyBloc>().state.itemsPerPage)
//                 .clamp(0, filteredData.length),
//             (((context.read<PartyBloc>().state.currentPage - 1) *
//                         context.read<PartyBloc>().state.itemsPerPage) +
//                     context.read<PartyBloc>().state.itemsPerPage)
//                 .clamp(0, filteredData.length))
//         : [];
//     setState(() {
//       if (value == true) {
//         _selectedIds.addAll(pageData.map((p) => p.id));
//       } else {
//         _selectedIds.clear();
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

//   void _showPartyDetailDialog(PartyData party) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final dialogWidth = screenWidth < 600 ? screenWidth * 0.92 : 520.0;

//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         backgroundColor: Colors.white,
//         insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//         child: Container(
//           width: dialogWidth,
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Party Details',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.grey),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildDetailField('Party ID:', party.id.toString()),
//                         _buildDetailField(
//                             'Account Head:', party.accType ?? '-'),
//                         _buildDetailField('Type:', party.type ?? 'N/A'),
//                         _buildDetailField(
//                             'Description:', party.description ?? '-'),
//                         _buildDetailField(
//                             'Status:', party.status == true ? 'True' : 'False'),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 24),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildDetailField('Name:', party.name),
//                         _buildDetailField(
//                             'Pan number:', party.panNumber ?? 'N/A'),
//                         _buildDetailField('Phone:', party.phone ?? 'N/A'),
//                         _buildDetailField(
//                           'Opening Balance:',
//                           party.openingBalance != null
//                               ? 'Rs ${party.openingBalance!.toStringAsFixed(2)}'
//                               : 'Rs 0.00',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailField(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.baseline,
//           textBaseline: TextBaseline.alphabetic,
//           children: [
//             SizedBox(
//               width: 110,
//               child: Text(
//                 label,
//                 style: const TextStyle(fontSize: 14, color: Colors.black54),
//               ),
//             ),
//             Expanded(
//               child: Text(
//                 value,
//                 style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
//         const SizedBox(height: 12),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<PartyBloc, PartyState>(
//       listener: (context, state) {
//         if (state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(state.errorMessage!),
//                 backgroundColor: Colors.red),
//           );
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

//         final paginatedData = filteredData.isNotEmpty
//             ? filteredData.sublist(
//                 (validCurrentPage - 1) * state.itemsPerPage,
//                 ((validCurrentPage - 1) * state.itemsPerPage +
//                         state.itemsPerPage)
//                     .clamp(0, filteredData.length),
//               )
//             : [];

//         return Scaffold(
//           body: SafeArea(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: ConstrainedBox(
//                     constraints:
//                         BoxConstraints(minHeight: constraints.maxHeight),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Title + New Button
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Parties',
//                                       style: TextStyle(
//                                           fontSize: 26,
//                                           fontWeight: FontWeight.bold)),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     'Add or update suppliers/customers \nand maintain party-related records',
//                                     style: TextStyle(
//                                         fontSize: 13, color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                               ElevatedButton.icon(
//                                 onPressed: () {},
//                                 icon: const Icon(Icons.add, size: 18),
//                                 label: const Text('New Parties'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFFF9800),
//                                   foregroundColor: Colors.white,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 10),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8)),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // Search + Delete All
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   height: 44,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF5F5F5),
//                                     borderRadius: BorderRadius.circular(30),
//                                   ),
//                                   child: TextField(
//                                     controller: _searchController,
//                                     decoration: const InputDecoration(
//                                       hintText: 'Search...',
//                                       prefixIcon: Icon(Icons.search,
//                                           color: Colors.grey),
//                                       border: InputBorder.none,
//                                       contentPadding: EdgeInsets.symmetric(
//                                           horizontal: 16, vertical: 0),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               TextButton.icon(
//                                 onPressed: _selectedIds.isEmpty
//                                     ? null
//                                     : () {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           const SnackBar(
//                                               content: Text(
//                                                   'Delete functionality coming soon')),
//                                         );
//                                         setState(() => _selectedIds.clear());
//                                       },
//                                 icon:
//                                     const Icon(Icons.delete_outline, size: 18),
//                                 label: const Text('Delete All'),
//                                 style: TextButton.styleFrom(
//                                   foregroundColor: _selectedIds.isEmpty
//                                       ? Colors.grey
//                                       : const Color(0xFFD9534F),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // Filter
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               border:
//                                   Border.all(color: const Color(0xFFEEEEEE)),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text('Filter Parties',
//                                     style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(height: 8),
//                                 Wrap(
//                                   spacing: 10,
//                                   runSpacing: 8,
//                                   children: [
//                                     _buildFilterChip(
//                                         context,
//                                         'Sundry Creditors',
//                                         'Sundry Creditor',
//                                         state.selectedTypeFilter),
//                                     _buildFilterChip(
//                                         context,
//                                         'Sundry Debtors',
//                                         'Sundry Debtor',
//                                         state.selectedTypeFilter),
//                                     GestureDetector(
//                                       onTap: () => context
//                                           .read<PartyBloc>()
//                                           .add(const ClearFilters()),
//                                       child: const Text(
//                                         'Clear Filters',
//                                         style: TextStyle(
//                                             color: Color(0xFFD9534F),
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           // Table - No extra left space (fixed)
//                           SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: SizedBox(
//                               width:
//                                   730, // minimum width to avoid squishing (adjust if needed)
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                       color: const Color(0xFFEEEEEE)),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     // Header - same style as AccountHead
//                                     Container(
//                                       height: 60,
//                                       decoration: const BoxDecoration(
//                                         color: Color(0xFFFAFAFA),
//                                         borderRadius: BorderRadius.vertical(
//                                             top: Radius.circular(12)),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 16),
//                                       child: Row(
//                                         children: [
//                                           SizedBox(
//                                             width: 48,
//                                             child: Checkbox(
//                                               value: paginatedData.isNotEmpty &&
//                                                   paginatedData.every((p) =>
//                                                       _selectedIds
//                                                           .contains(p.id)),
//                                               onChanged: (v) =>
//                                                   _toggleSelectAll(v),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 10),
//                                           const SizedBox(
//                                             width: 60,
//                                             child: Text('ID',
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Color(0xFF555555))),
//                                           ),
//                                           const SizedBox(
//                                             width: 60,
//                                             child: Text('Name',
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Color(0xFF555555))),
//                                           ),
//                                           const SizedBox(
//                                             width: 140,
//                                             child: Text('Phone Number',
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Color(0xFF555555))),
//                                           ),
//                                           const SizedBox(
//                                             width: 140,
//                                             child: Text('Pan Number',
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Color(0xFF555555))),
//                                           ),
//                                           const SizedBox(
//                                             width: 120,
//                                             child: Text('Type',
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Color(0xFF555555))),
//                                           ),
//                                           const SizedBox(
//                                             width: 110,
//                                             child: Text('Action',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Color(0xFF555555))),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const Divider(
//                                         height: 1, color: Color(0xFFEEEEEE)),

//                                     // Rows - same style as AccountHead
//                                     if (paginatedData.isEmpty)
//                                       const Padding(
//                                         padding: EdgeInsets.all(40),
//                                         child: Center(
//                                             child: Text('No parties found')),
//                                       )
//                                     else
//                                       ...paginatedData.map((party) {
//                                         final isSelected =
//                                             _selectedIds.contains(party.id);
//                                         return Column(
//                                           children: [
//                                             GestureDetector(
//                                               onTap: () =>
//                                                   _showPartyDetailDialog(party),
//                                               child: Container(
//                                                 height: 72,
//                                                 color: isSelected
//                                                     ? const Color(0xFFFFF8F0)
//                                                     : Colors.transparent,
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 16),
//                                                 child: Row(
//                                                   children: [
//                                                     SizedBox(
//                                                       width: 48,
//                                                       child: Checkbox(
//                                                         value: isSelected,
//                                                         onChanged: (v) =>
//                                                             _toggleSelect(
//                                                                 party.id, v),
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 10),
//                                                     SizedBox(
//                                                       width: 60,
//                                                       child: Text('${party.id}',
//                                                           style: const TextStyle(
//                                                               fontSize: 13,
//                                                               color: Color(
//                                                                   0xFF333333))),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 60,
//                                                       child: Text(
//                                                         party.name,
//                                                         style: const TextStyle(
//                                                             fontSize: 13,
//                                                             color: Color(
//                                                                 0xFF333333)),
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 140,
//                                                       child: Text(
//                                                         party.phone ?? 'N/A',
//                                                         style: const TextStyle(
//                                                             fontSize: 13,
//                                                             color: Color(
//                                                                 0xFF333333)),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 140,
//                                                       child: Text(
//                                                         party.panNumber ??
//                                                             'N/A',
//                                                         style: const TextStyle(
//                                                             fontSize: 13,
//                                                             color: Color(
//                                                                 0xFF333333)),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 120,
//                                                       child: Text(
//                                                         party.type ?? 'N/A',
//                                                         style: const TextStyle(
//                                                             fontSize: 13,
//                                                             color: Color(
//                                                                 0xFF333333)),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 110,
//                                                       child: Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           GestureDetector(
//                                                             onTap: () =>
//                                                                 _showPartyDetailDialog(
//                                                                     party),
//                                                             child: const Icon(
//                                                                 Icons
//                                                                     .remove_red_eye_outlined,
//                                                                 size: 16,
//                                                                 color: Color(
//                                                                     0xFF888888)),
//                                                           ),
//                                                           const SizedBox(
//                                                               width: 10),
//                                                           const Icon(
//                                                               Icons
//                                                                   .edit_outlined,
//                                                               size: 16,
//                                                               color: Color(
//                                                                   0xFF888888)),
//                                                           const SizedBox(
//                                                               width: 10),
//                                                           const Icon(
//                                                               Icons
//                                                                   .delete_outline,
//                                                               size: 16,
//                                                               color: Color(
//                                                                   0xFF888888)),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             const Divider(
//                                                 height: 1,
//                                                 color: Color(0xFFEEEEEE)),
//                                           ],
//                                         );
//                                       }),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 24),

//                           if (totalPages > 1)
//                             Center(
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.chevron_left),
//                                     onPressed: validCurrentPage > 1
//                                         ? () => context
//                                             .read<PartyBloc>()
//                                             .add(GoToPage(validCurrentPage - 1))
//                                         : null,
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 16, vertical: 8),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFF007AFF),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(
//                                       '$validCurrentPage',
//                                       style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.chevron_right),
//                                     onPressed: validCurrentPage < totalPages
//                                         ? () => context
//                                             .read<PartyBloc>()
//                                             .add(GoToPage(validCurrentPage + 1))
//                                         : null,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFilterChip(BuildContext context, String label, String blocValue,
//       String currentFilter) {
//     final bool isSelected = currentFilter == blocValue;
//     return GestureDetector(
//       onTap: () => context.read<PartyBloc>().add(UpdateTypeFilter(blocValue)),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(
//               color: isSelected
//                   ? const Color(0xFFE8891A)
//                   : const Color(0xFFEEEEEE)),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//             color: isSelected ? const Color(0xFFE8891A) : Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/screen/parties/bloc/party_bloc.dart';
import 'package:saleup_app/screen/parties/bloc/party_event.dart';
import 'package:saleup_app/screen/parties/bloc/party_state.dart';
import 'package:saleup_app/model/party_response.dart';
import 'package:saleup_app/screen/parties/view/add_party_screen.dart';

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

  // ─── Delete Single Party ──────────────────────────────────────────────────
  Future<void> _deleteParty(PartyData party) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Party',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${party.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9534F),
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final body = {
        "party_ids": [party.id]
      };
      debugPrint('Sending single delete body: $body');

      final response = await DioClient().dio.request(
            '/party/delete_parties/',
            data: body,
            options: Options(
              method: 'DELETE',
              contentType: Headers.jsonContentType,
            ),
          );

      debugPrint(
          'Delete single response [${response.statusCode}]: ${response.data}');

      final data = response.data as Map<String, dynamic>?;
      if ((response.statusCode == 200 || response.statusCode == 204) &&
          data?['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data?['message'] ?? 'Party deleted successfully'),
              backgroundColor: Colors.green),
        );
        context.read<PartyBloc>().add(const FetchParties());
        setState(() => _selectedIds.remove(party.id));
      } else {
        throw Exception(data?['message'] ?? 'Delete failed');
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ─── Delete Selected (bulk) ───────────────────────────────────────────────
  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final ids = _selectedIds.toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Parties',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Delete ${ids.length} selected parties?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9534F),
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final body = {"party_ids": ids};
      debugPrint('Sending bulk delete body: $body');

      final response = await DioClient().dio.request(
            '/party/delete_parties/',
            data: body,
            options: Options(
              method: 'DELETE',
              contentType: Headers.jsonContentType,
            ),
          );

      debugPrint(
          'Bulk delete response [${response.statusCode}]: ${response.data}');

      final data = response.data as Map<String, dynamic>?;
      if ((response.statusCode == 200 || response.statusCode == 204) &&
          data?['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data?['message'] ?? 'Parties deleted successfully'),
              backgroundColor: Colors.green),
        );
        setState(() => _selectedIds.clear());
        context.read<PartyBloc>().add(const FetchParties());
      } else {
        throw Exception(data?['message'] ?? 'Bulk delete failed');
      }
    } catch (e) {
      debugPrint('Bulk delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ─── View Detail Dialog ───────────────────────────────────────────────────
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

  // ─── Edit Dialog ──────────────────────────────────────────────────────────
  void _showEditPartyDialog(PartyData party) {
    // Capture from screen context BEFORE showDialog
    final bloc = context.read<PartyBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final nameController = TextEditingController(text: party.name);
    final phoneController = TextEditingController(text: party.phone ?? '');
    final panController = TextEditingController(text: party.panNumber ?? '');
    final addressController = TextEditingController(text: party.address ?? '');
    final descriptionController =
        TextEditingController(text: party.description ?? '');
    final openingBalanceController = TextEditingController(
      text: party.openingBalance?.toStringAsFixed(2) ?? '0.00',
    );
    String selectedType = party.type ?? 'Customer';
    bool status = party.status ?? true;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : 560.0;
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.all(20),
              child: isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Edit Parties',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Party ID',
                                  child: TextFormField(
                                    initialValue: party.id.toString(),
                                    readOnly: true,
                                    style:
                                        const TextStyle(color: Colors.black54),
                                    decoration: _inputDecoration(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Name',
                                  child: TextFormField(
                                    controller: nameController,
                                    decoration:
                                        _inputDecoration(hint: 'Enter name'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: '* Type',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedType,
                                    decoration: _inputDecoration(),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Customer',
                                          child: Text('Customer')),
                                      DropdownMenuItem(
                                          value: 'Supplier',
                                          child: Text('Supplier')),
                                      DropdownMenuItem(
                                          value: 'Both', child: Text('Both')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(
                                            () => selectedType = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Address',
                                  child: TextFormField(
                                    controller: addressController,
                                    decoration:
                                        _inputDecoration(hint: 'Enter address'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: '* Phone No.',
                                  child: TextFormField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: _inputDecoration(
                                        hint: 'Enter phone number'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Pan No.',
                                  child: TextFormField(
                                    controller: panController,
                                    decoration:
                                        _inputDecoration(hint: 'Enter PAN'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Opening Balance',
                                  child: TextFormField(
                                    controller: openingBalanceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: _inputDecoration(hint: '0.00'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Description',
                                  child: TextFormField(
                                    controller: descriptionController,
                                    maxLines: 3,
                                    decoration: _inputDecoration(
                                        hint: 'Enter description'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Switch(
                                value: status,
                                onChanged: (val) =>
                                    setDialogState(() => status = val),
                                activeThumbColor: const Color(0xFFFF9800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                setDialogState(() => isLoading = true);
                                final updatedData = {
                                  "name": nameController.text.trim(),
                                  "type": selectedType,
                                  "phone": phoneController.text.trim(),
                                  "pan_number": panController.text.trim(),
                                  "address": addressController.text.trim(),
                                  "description":
                                      descriptionController.text.trim(),
                                  "opening_balance": double.tryParse(
                                          openingBalanceController.text
                                              .trim()) ??
                                      0.0,
                                  "status": status,
                                };
                                final navigator = Navigator.of(context);
                                try {
                                  final response = await DioClient().dio.put(
                                        '/party/update_party/?party_id=${party.id}',
                                        data: updatedData,
                                      );
                                  final data = response.data;
                                  final isSuccess =
                                      response.statusCode == 200 &&
                                          (data is Map &&
                                              (data['success'] == true ||
                                                  data['success'] == 'true'));
                                  if (isSuccess) {
                                    final msg = data['message'] ??
                                        'Party updated successfully';
                                    navigator.pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    bloc.add(const FetchParties());
                                  } else {
                                    throw Exception(data is Map
                                        ? (data['message'] ?? 'Update failed')
                                        : 'Update failed');
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
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

  // ─── Form Field Helpers ───────────────────────────────────────────────────
  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
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
                          // ── Title + New Button ──
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<PartyBloc>(),
                                        child: const AddPartyScreen(),
                                      ),
                                    ),
                                  );
                                },
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

                          // ── Search + Delete All ──
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
                                    : _deleteSelected,
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

                          // ── Filter ──
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

                          // ── Table ──
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 730,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFEEEEEE)),
                                ),
                                child: Column(
                                  children: [
                                    // Header
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
                                    // Rows
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
                                        return GestureDetector(
                                          onTap: () =>
                                              _showPartyDetailDialog(party),
                                          child: Column(
                                            children: [
                                              Container(
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
                                                          // View
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
                                                          // Edit
                                                          GestureDetector(
                                                            onTap: () =>
                                                                _showEditPartyDialog(
                                                                    party),
                                                            child: const Icon(
                                                                Icons
                                                                    .edit_outlined,
                                                                size: 16,
                                                                color: Color(
                                                                    0xFF888888)),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          // Delete
                                                          GestureDetector(
                                                            onTap: () =>
                                                                _deleteParty(
                                                                    party),
                                                            child: const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                                size: 16,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Divider(
                                                  height: 1,
                                                  color: Color(0xFFEEEEEE)),
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Pagination
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
