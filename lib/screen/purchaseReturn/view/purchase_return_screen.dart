// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart'; // Ensure this package is added
// import 'package:saleup_app/model/purchase_return_response.dart';
// import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
// import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_event.dart';
// import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_state.dart';

// class PurchaseReturnScreen extends StatefulWidget {
//   const PurchaseReturnScreen({super.key});

//   @override
//   State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
// }

// class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
//   DateTime? _selectedDate;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!mounted) return;
//     final bloc = BlocProvider.of<PurchaseReturnBloc>(context, listen: false);
//     print('PurchaseReturnBloc in didChangeDependencies: $bloc');
//     if (bloc.state.purchaseReturns.isEmpty) {
//       bloc.add(const FetchPurchaseReturns());
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   void _clearDate() {
//     setState(() {
//       _selectedDate = null;
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

//   List<PurchaseReturnData> _filterPurchases(
//       List<PurchaseReturnData> purchases) {
//     return purchases.where((purchase) {
//       bool dateMatch = true;

//       if (_selectedDate != null) {
//         final returnDate = DateTime.parse(purchase.returnDate).toLocal();
//         dateMatch = returnDate.year == _selectedDate!.year &&
//             returnDate.month == _selectedDate!.month &&
//             returnDate.day == _selectedDate!.day;
//       }

//       return dateMatch;
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

//   void _showDetailsPopup(BuildContext context, PurchaseReturnData purchase) {
//     final DateTime returnDateTime = DateTime.parse(purchase.returnDate);
//     final String formattedDateTime =
//         DateFormat('MMM dd, yyyy hh:mm a').format(returnDateTime);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         backgroundColor: Colors.white,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Purchase Return Details',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.black87,
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.close, color: Colors.grey),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//         content: Container(
//           constraints: const BoxConstraints(maxHeight: 400),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildDetailRow(
//                     Icons.receipt, 'Purchase ID', purchase.purchase.toString()),
//                 _buildDetailRow(
//                     Icons.calendar_today, 'Return Date', formattedDateTime),
//                 _buildDetailRow(Icons.notes, 'Reason', purchase.reason),
//                 _buildDetailRow(Icons.attach_money, 'Sub Total',
//                     '\$${purchase.subTotal.toStringAsFixed(2)}'),
//                 _buildDetailRow(Icons.discount, 'Discount',
//                     '\$${purchase.discount.toStringAsFixed(2)}'),
//                 _buildDetailRow(Icons.currency_exchange, 'VAT',
//                     '\$${purchase.vat.toStringAsFixed(2)}'),
//                 _buildDetailRow(Icons.payments, 'Total',
//                     '\$${purchase.total.toStringAsFixed(2)}'),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Items',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 ...purchase.items.map((item) => _buildItemRow(item)),
//               ],
//             ),
//           ),
//         ),
//         actions: [], // Removed the "Close" button
//       ),
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.grey[600], size: 20),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               '$label: $value',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.black87,
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemRow(PurchaseReturnItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: ExpansionTile(
//         leading: Icon(Icons.inventory, color: Colors.grey[600], size: 20),
//         title: Text(
//           'Product ID: ${item.id}',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.black87,
//               ),
//         ),
//         children: [
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Quantity: ${item.quantity}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//                 Text(
//                   'Rate: \$${item.rate.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//                 Text(
//                   'Total: \$${item.total.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<PurchaseReturnBloc, PurchaseReturnState>(
//         listener: (context, state) {},
//         child: Builder(
//           builder: (context) {
//             final screenWidth = MediaQuery.of(context).size.width;
//             final screenHeight = MediaQuery.of(context).size.height;

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(screenWidth * 0.02),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Purchase Returns",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.05,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () => _selectDate(context),
//                                     child: AbsorbPointer(
//                                       child: TextField(
//                                         controller: TextEditingController(
//                                           text: _selectedDate == null
//                                               ? 'yyyy-MM-dd'
//                                               : DateFormat('yyyy-MM-dd')
//                                                   .format(_selectedDate!),
//                                         ),
//                                         decoration: const InputDecoration(
//                                           labelText: 'Date',
//                                           border: OutlineInputBorder(),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.clear),
//                                   onPressed: _clearDate,
//                                   tooltip: 'Clear Date',
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
//                     builder: (context, state) {
//                       print(
//                           'BlocBuilder state: isLoading=${state.isLoading}, purchaseReturns.length=${state.purchaseReturns.length}, error=${state.errorMessage}');
//                       if (state.isLoading && state.purchaseReturns.isEmpty) {
//                         return _buildShimmerEffect(screenWidth, screenHeight);
//                       }
//                       if (state.errorMessage != null) {
//                         return Center(child: Text(state.errorMessage!));
//                       }
//                       final filteredPurchases =
//                           _filterPurchases(state.purchaseReturns);

//                       if (filteredPurchases.isEmpty) {
//                         return const Center(
//                             child: Text('No purchase returns available'));
//                       }

//                       return ListView.builder(
//                         padding: EdgeInsets.all(screenWidth * 0.03),
//                         itemCount: filteredPurchases.length,
//                         itemBuilder: (context, index) {
//                           final purchase = filteredPurchases[index];
//                           return PurchaseReturnCard(
//                             purchase: purchase,
//                             screenWidth: screenWidth,
//                             screenHeight: screenHeight,
//                             onTap: () => _showDetailsPopup(context, purchase),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class PurchaseReturnCard extends StatelessWidget {
//   final PurchaseReturnData purchase;
//   final double screenWidth;
//   final double screenHeight;
//   final VoidCallback onTap;

//   const PurchaseReturnCard({
//     super.key,
//     required this.purchase,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final DateTime returnDateTime = DateTime.parse(purchase.returnDate);
//     final String formattedDateTime =
//         DateFormat('MMM dd, yyyy hh:mm a').format(returnDateTime);

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
//                         'ID: ${purchase.id}',
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
//                             'Purchase ID: ${purchase.purchase}',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(color: Colors.grey),
//                           ),
//                           Text(
//                             'Return Date: $formattedDateTime',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         'Reason: ${purchase.reason}',
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
import 'package:shimmer/shimmer.dart'; // Ensure this package is added
import 'package:saleup_app/model/purchase_return_response.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_event.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_state.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final bloc = BlocProvider.of<PurchaseReturnBloc>(context, listen: false);
    print('PurchaseReturnBloc in didChangeDependencies: $bloc');
    if (bloc.state.purchaseReturns.isEmpty) {
      bloc.add(const FetchPurchaseReturns());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
    print('Date cleared: _selectedDate is now $_selectedDate');
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

  List<PurchaseReturnData> _filterPurchases(
      List<PurchaseReturnData> purchases) {
    if (_selectedDate == null) return purchases;

    final selectedDate =
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);

    return purchases.where((purchase) {
      try {
        // Log the raw returnDate string before parsing
        print('Raw returnDate before parsing: ${purchase.returnDate}');
        final returnDateStr = purchase.returnDate; // Capture exact string
        final returnDate = DateTime.parse(returnDateStr);
        // Extract the intended date from the original string if parsing shifts it
        final originalDate = DateTime.parse(returnDateStr.split('T')[0]);
        final adjustedReturnDate = DateTime(
            originalDate.year,
            originalDate.month,
            originalDate.day,
            returnDate.hour,
            returnDate.minute);
        final returnDateOnly = DateTime(adjustedReturnDate.year,
            adjustedReturnDate.month, adjustedReturnDate.day);
        final dateMatch = returnDateOnly.isAtSameMomentAs(selectedDate);

        print(
            'Filtering: returnDateStr=$returnDateStr, returnDate=$returnDate, adjusted=$adjustedReturnDate, returnDateOnly=$returnDateOnly, selectedDate=$selectedDate, match=$dateMatch');
        return dateMatch;
      } catch (e) {
        print('Error parsing returnDate ${purchase.returnDate}: $e');
        return false; // Exclude invalid dates
      }
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

  void _showDetailsPopup(BuildContext context, PurchaseReturnData purchase) {
    final returnDateStr = purchase.returnDate; // Capture exact string
    final returnDate = DateTime.parse(returnDateStr);
    // Extract the intended date from the original string
    final originalDate = DateTime.parse(returnDateStr.split('T')[0]);
    final adjustedReturnDate = DateTime(originalDate.year, originalDate.month,
        originalDate.day, returnDate.hour, returnDate.minute);
    final String formattedDateTime =
        DateFormat('MMM dd, yyyy hh:mm a').format(adjustedReturnDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Purchase Return Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                    Icons.receipt, 'Purchase ID', purchase.purchase.toString()),
                _buildDetailRow(
                    Icons.calendar_today, 'Return Date', formattedDateTime),
                _buildDetailRow(Icons.notes, 'Reason', purchase.reason),
                _buildDetailRow(Icons.attach_money, 'Sub Total',
                    '\$${purchase.subTotal.toStringAsFixed(2)}'),
                _buildDetailRow(Icons.discount, 'Discount',
                    '\$${purchase.discount.toStringAsFixed(2)}'),
                _buildDetailRow(Icons.currency_exchange, 'VAT',
                    '\$${purchase.vat.toStringAsFixed(2)}'),
                _buildDetailRow(Icons.payments, 'Total',
                    '\$${purchase.total.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                Text(
                  'Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ...purchase.items.map((item) => _buildItemRow(item)),
              ],
            ),
          ),
        ),
        actions: const [], // No action buttons
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(PurchaseReturnItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        leading: Icon(Icons.inventory, color: Colors.grey[600], size: 20),
        title: Text(
          'Product ID: ${item.id}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantity: ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  'Rate: \$${item.rate.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  'Total: \$${item.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PurchaseReturnBloc, PurchaseReturnState>(
        listener: (context, state) {},
        child: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Purchase Returns",
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
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
                    builder: (context, state) {
                      print(
                          'BlocBuilder state: isLoading=${state.isLoading}, purchaseReturns.length=${state.purchaseReturns.length}, error=${state.errorMessage}');
                      if (state.isLoading && state.purchaseReturns.isEmpty) {
                        return _buildShimmerEffect(screenWidth, screenHeight);
                      }
                      if (state.errorMessage != null) {
                        return Center(child: Text(state.errorMessage!));
                      }
                      final filteredPurchases =
                          _filterPurchases(state.purchaseReturns);

                      print(
                          'Filtered purchases count: ${filteredPurchases.length}, _selectedDate: $_selectedDate');

                      if (filteredPurchases.isEmpty) {
                        return const Center(
                            child: Text('No purchase returns available'));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        itemCount: filteredPurchases.length,
                        itemBuilder: (context, index) {
                          final purchase = filteredPurchases[index];
                          return PurchaseReturnCard(
                            purchase: purchase,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onTap: () => _showDetailsPopup(context, purchase),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PurchaseReturnCard extends StatelessWidget {
  final PurchaseReturnData purchase;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const PurchaseReturnCard({
    super.key,
    required this.purchase,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Capture exact string and parse
    final returnDateStr = purchase.returnDate;
    final returnDate = DateTime.parse(returnDateStr);
    // Extract the intended date from the original string
    final originalDate = DateTime.parse(returnDateStr.split('T')[0]);
    final adjustedReturnDate = DateTime(originalDate.year, originalDate.month,
        originalDate.day, returnDate.hour, returnDate.minute);
    // Format to include date and time with AM/PM, no timezone offset
    final String formattedDateTime =
        DateFormat("yyyy-MM-dd hh:mm a").format(adjustedReturnDate);

    // Log the parsed returnDate for debugging
    print(
        'Card returnDateStr: $returnDateStr, returnDate: $returnDate, adjusted: $adjustedReturnDate, formatted: $formattedDateTime');

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${purchase.id}',
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
                            'Purchase ID: ${purchase.purchase}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                          Text(
                            'Return Date: $formattedDateTime',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reason: ${purchase.reason}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
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
}
