// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:saleup_app/model/voucher_response.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_state.dart';
// import 'package:saleup_app/screen/voucher/widget/voucher_detail_dialog.dart';

// class VoucherScreen extends StatefulWidget {
//   const VoucherScreen({super.key});

//   @override
//   State<VoucherScreen> createState() => _VoucherScreenState();
// }

// class _VoucherScreenState extends State<VoucherScreen> {
//   DateTime? _selectedDate;
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.trim();
//       });
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!mounted) return;
//     final bloc = BlocProvider.of<VoucherBloc>(context, listen: false);
//     if (bloc.state.vouchers.isEmpty) {
//       bloc.add(const FetchVouchers());
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _clearDate() {
//     setState(() {
//       _selectedDate = null;
//     });
//   }

//   void _clearSearch() {
//     setState(() {
//       _searchController.clear();
//       _searchQuery = '';
//     });
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   List<VoucherData> _filterVouchers(List<VoucherData> vouchers) {
//     return vouchers.where((voucher) {
//       bool dateMatch = true;
//       bool searchMatch = true;

//       if (_selectedDate != null) {
//         try {
//           final voucherDate = DateTime.parse(voucher.voucherDate ?? '');
//           final voucherDateOnly =
//               DateTime(voucherDate.year, voucherDate.month, voucherDate.day);
//           final selectedDate = DateTime(
//               _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
//           dateMatch = voucherDateOnly.isAtSameMomentAs(selectedDate);
//         } catch (e) {
//           return false;
//         }
//       }

//       if (_searchQuery.isNotEmpty) {
//         searchMatch = (voucher.voucherNumber ?? '')
//             .toLowerCase()
//             .contains(_searchQuery.toLowerCase());
//       }

//       return dateMatch && searchMatch;
//     }).toList();
//   }

//   Widget _buildShimmerEffect(double screenWidth, double screenHeight) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.builder(
//         padding: EdgeInsets.all(screenWidth * 0.03),
//         itemCount: 5,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               color: Colors.white,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                         height: 16,
//                         width: screenWidth * 0.4,
//                         color: Colors.white),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                             height: 14,
//                             width: screenWidth * 0.3,
//                             color: Colors.white),
//                         Container(
//                             height: 14,
//                             width: screenWidth * 0.2,
//                             color: Colors.white),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                             height: 14,
//                             width: screenWidth * 0.3,
//                             color: Colors.white),
//                         Container(
//                             height: 14,
//                             width: screenWidth * 0.2,
//                             color: Colors.white),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(screenWidth * 0.02),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Vouchers",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.05,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => _selectDate(context),
//                               child: AbsorbPointer(
//                                 child: TextField(
//                                   controller: TextEditingController(
//                                     text: _selectedDate == null
//                                         ? 'yyyy-MM-dd'
//                                         : DateFormat('yyyy-MM-dd')
//                                             .format(_selectedDate!),
//                                   ),
//                                   decoration: const InputDecoration(
//                                     labelText: 'Date',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: _clearDate,
//                             tooltip: 'Clear Date',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _searchController,
//                               decoration: const InputDecoration(
//                                 labelText: 'Search Voucher Number',
//                                 border: OutlineInputBorder(),
//                                 prefixIcon: Icon(Icons.search),
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: _clearSearch,
//                             tooltip: 'Clear Search',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: BlocBuilder<VoucherBloc, VoucherState>(
//               builder: (context, state) {
//                 if (state.isLoading && state.vouchers.isEmpty) {
//                   return _buildShimmerEffect(screenWidth, screenHeight);
//                 }
//                 if (state.errorMessage != null) {
//                   return Center(child: Text(state.errorMessage!));
//                 }
//                 final filteredVouchers = _filterVouchers(state.vouchers);

//                 if (filteredVouchers.isEmpty) {
//                   return const Center(child: Text('No vouchers available'));
//                 }

//                 return ListView.builder(
//                   padding: EdgeInsets.all(screenWidth * 0.03),
//                   itemCount: filteredVouchers.length,
//                   itemBuilder: (context, index) {
//                     final voucher = filteredVouchers[index];
//                     return VoucherCard(
//                       voucher: voucher,
//                       screenWidth: screenWidth,
//                       screenHeight: screenHeight,
//                       onTap: () {
//                         try {
//                           context
//                               .read<VoucherBloc>()
//                               .add(FetchVoucherById(voucher.id));
//                           showDialog(
//                             context: context,
//                             builder: (dialogContext) =>
//                                 VoucherDetailDialog(voucherId: voucher.id),
//                           );
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error: $e')),
//                           );
//                         }
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class VoucherCard extends StatelessWidget {
//   final VoucherData voucher;
//   final double screenWidth;
//   final double screenHeight;
//   final VoidCallback onTap;

//   const VoucherCard({
//     super.key,
//     required this.voucher,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final voucherDateStr = voucher.voucherDate ?? '';
//     String formattedDateTime = 'Unknown';
//     if (voucherDateStr.isNotEmpty) {
//       try {
//         final voucherDate = DateTime.parse(voucherDateStr);
//         formattedDateTime =
//             DateFormat('MMM dd, yyyy hh:mm a').format(voucherDate);
//       } catch (e) {
//         formattedDateTime = 'Invalid Date';
//       }
//     }

//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Card(
//           elevation: 4,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           color: Colors.white,
//           child: Container(
//             padding: EdgeInsets.all(screenWidth * 0.02),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Voucher: ${voucher.voucherNumber ?? 'N/A'}',
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Type: ${voucher.type ?? 'N/A'}',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(color: Colors.grey),
//                           ),
//                           Text(
//                             'Date: $formattedDateTime',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         'Narration: ${voucher.narration ?? 'N/A'}',
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodyMedium
//                             ?.copyWith(color: Colors.grey),
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
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/model/voucher_response.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_state.dart';
import 'package:saleup_app/screen/voucher/widget/voucher_detail_dialog.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasFetchedVouchers = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
      print('Search query updated: $_searchQuery');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final bloc = BlocProvider.of<VoucherBloc>(context, listen: false);
    print('VoucherBloc in didChangeDependencies: $bloc');
    if (!_hasFetchedVouchers && bloc.state.vouchers.isEmpty) {
      bloc.add(const FetchVouchers());
      _hasFetchedVouchers = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
    print('Date cleared: _selectedDate is now $_selectedDate');
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
    print('Search cleared: _searchQuery is now $_searchQuery');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      print('Date selected: $_selectedDate');
    }
  }

  List<VoucherData> _filterVouchers(List<VoucherData> vouchers) {
    return vouchers.where((voucher) {
      bool dateMatch = true;
      bool searchMatch = true;

      if (_selectedDate != null) {
        try {
          final voucherDateStr = voucher.voucherDate ?? '';
          print('Raw voucherDate before parsing: $voucherDateStr');
          if (voucherDateStr.isEmpty) return false;
          final voucherDate = DateTime.parse(voucherDateStr);
          final originalDate = DateTime.parse(voucherDateStr.split('T')[0]);
          final adjustedVoucherDate = DateTime(
              originalDate.year,
              originalDate.month,
              originalDate.day,
              voucherDate.hour,
              voucherDate.minute);
          final voucherDateOnly = DateTime(adjustedVoucherDate.year,
              adjustedVoucherDate.month, adjustedVoucherDate.day);
          final selectedDate = DateTime(
              _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
          dateMatch = voucherDateOnly.isAtSameMomentAs(selectedDate);
          print(
              'Filtering: voucherDateStr=$voucherDateStr, voucherDate=$voucherDate, '
              'adjusted=$adjustedVoucherDate, voucherDateOnly=$voucherDateOnly, '
              'selectedDate=$selectedDate, match=$dateMatch');
        } catch (e) {
          print('Error parsing voucherDate ${voucher.voucherDate}: $e');
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        searchMatch = (voucher.voucherNumber ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }

      return dateMatch && searchMatch;
    }).toList();
  }

  Widget _buildShimmerEffect(double screenWidth, double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.03),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 16,
                        width: screenWidth * 0.4,
                        color: Colors.white),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            height: 14,
                            width: screenWidth * 0.3,
                            color: Colors.white),
                        Container(
                            height: 14,
                            width: screenWidth * 0.2,
                            color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            height: 14,
                            width: screenWidth * 0.3,
                            color: Colors.white),
                        Container(
                            height: 14,
                            width: screenWidth * 0.2,
                            color: Colors.white),
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
  }

  void _showDetailsPopup(BuildContext parentContext, VoucherData voucher) {
    print('Initiating _showDetailsPopup for voucherId: ${voucher.id}');
    // Only trigger FetchVoucherById if voucherDetail doesn't match
    final bloc = BlocProvider.of<VoucherBloc>(parentContext, listen: false);
    if (bloc.state.voucherDetail?.id != voucher.id) {
      bloc.add(FetchVoucherById(voucher.id));
    }
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<VoucherBloc>(parentContext),
        child: VoucherDetailDialog(voucherId: voucher.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocListener<VoucherBloc, VoucherState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vouchers",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: _selectedDate == null
                                          ? 'yyyy-MM-dd'
                                          : DateFormat('yyyy-MM-dd')
                                              .format(_selectedDate!),
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearDate,
                              tooltip: 'Clear Date',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  labelText: 'Search Voucher Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                              tooltip: 'Clear Search',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<VoucherBloc, VoucherState>(
                builder: (context, state) {
                  print('BlocBuilder state: isLoading=${state.isLoading}, '
                      'vouchers.length=${state.vouchers.length}, '
                      'error=${state.errorMessage}');
                  if (state.isLoading && state.vouchers.isEmpty) {
                    return _buildShimmerEffect(screenWidth, screenHeight);
                  }
                  if (state.errorMessage != null) {
                    return Center(child: Text(state.errorMessage!));
                  }
                  final filteredVouchers = _filterVouchers(state.vouchers);
                  print('Filtered vouchers count: ${filteredVouchers.length}, '
                      '_selectedDate: $_selectedDate, _searchQuery: $_searchQuery');

                  if (filteredVouchers.isEmpty) {
                    return const Center(child: Text('No vouchers available'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    itemCount: filteredVouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = filteredVouchers[index];
                      return VoucherCard(
                        key: ValueKey(voucher.id),
                        voucher: voucher,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onTap: () => _showDetailsPopup(context, voucher),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VoucherCard extends StatelessWidget {
  final VoucherData voucher;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final voucherDateStr = voucher.voucherDate ?? '';
    String formattedDateTime = 'Unknown';
    if (voucherDateStr.isNotEmpty) {
      try {
        final voucherDate = DateTime.parse(voucherDateStr);
        formattedDateTime =
            DateFormat('MMM dd, yyyy hh:mm a').format(voucherDate);
        print(
            'Card voucherDateStr: $voucherDateStr, voucherDate: $voucherDate, '
            'formatted: $formattedDateTime');
      } catch (e) {
        print('Error formatting voucher date: $e');
        formattedDateTime = 'Invalid Date';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voucher: ${voucher.voucherNumber ?? 'N/A'}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Type: ${voucher.type ?? 'N/A'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            Text(
                              'Date: $formattedDateTime',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Narration: ${voucher.narration ?? 'N/A'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
