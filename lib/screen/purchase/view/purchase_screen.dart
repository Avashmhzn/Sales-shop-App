// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/purchase_response.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_event.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_state.dart';
// import 'package:shimmer/shimmer.dart'; // Ensure this package is added

// class PurchaseScreen extends StatefulWidget {
//   const PurchaseScreen({super.key});

//   @override
//   State<PurchaseScreen> createState() => _PurchaseScreenState();
// }

// class _PurchaseScreenState extends State<PurchaseScreen> {
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!mounted) return;
//     final bloc = BlocProvider.of<PurchaseBloc>(context, listen: false);
//     print('PurchaseBloc in didChangeDependencies: $bloc');
//     if (bloc.state.purchases.isEmpty) {
//       bloc.add(const FetchPurchases());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Builder(
//         builder: (context) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final screenHeight = MediaQuery.of(context).size.height;

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
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
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: BlocBuilder<PurchaseBloc, PurchaseState>(
//                   builder: (context, state) {
//                     print(
//                         'BlocBuilder state: isLoading=${state.isLoading}, purchases.length=${state.purchases.length}, error=${state.errorMessage}');
//                     if (state.isLoading && state.purchases.isEmpty) {
//                       return _buildShimmerEffect(screenWidth, screenHeight);
//                     }
//                     if (state.errorMessage != null) {
//                       return Center(child: Text(state.errorMessage!));
//                     }
//                     final purchases = state.purchases;

//                     if (purchases.isEmpty) {
//                       return const Center(
//                           child: Text('No purchases available'));
//                     }

//                     return ListView.builder(
//                       padding: EdgeInsets.all(screenWidth * 0.03),
//                       itemCount: purchases.length,
//                       itemBuilder: (context, index) {
//                         final purchase = purchases[index];
//                         return PurchaseCard(
//                           purchase: purchase,
//                           screenWidth: screenWidth,
//                           screenHeight: screenHeight,
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
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
// }

// class PurchaseCard extends StatelessWidget {
//   final PurchaseData purchase;
//   final double screenWidth;
//   final double screenHeight;

//   const PurchaseCard({
//     super.key,
//     required this.purchase,
//     required this.screenWidth,
//     required this.screenHeight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         print('Tapping purchase ID: ${purchase.id ?? 'null'}');
//         if (purchase.id == null) {
//           print('Purchase ID is null, cannot fetch details');
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Invalid purchase ID')),
//           );
//           return;
//         }
//         try {
//           final bloc = BlocProvider.of<PurchaseBloc>(context, listen: false);
//           if (bloc == null) {
//             print('BlocProvider.of<PurchaseBloc> returned null');
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Bloc not found')),
//             );
//             return;
//           }
//           print('Dispatching FetchPurchaseById for ID: ${purchase.id}');
//           bloc.add(FetchPurchaseById(purchase.id!));
//           print('Dialog will be shown when data is ready via BlocConsumer');
//           showDialog(
//             context: context,
//             builder: (context) => BlocProvider.value(
//               value: bloc,
//               child: PurchaseDetailDialog(purchaseId: purchase.id!),
//             ),
//           );
//         } catch (e, stackTrace) {
//           print('Exception in onTap: $e\nStackTrace: $stackTrace');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error fetching details: $e')),
//           );
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Card(
//           elevation: 4,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           color: Colors.white,
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Voucher: ${purchase.voucherNumber ?? 'N/A'}',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleMedium
//                       ?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Invoice: ${purchase.invoiceNumber ?? 'N/A'}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                     ),
//                     Text(
//                       'Total: NPR ${purchase.total ?? '0.00'}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Type: ${purchase.billType ?? 'N/A'}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                     ),
//                     Text(
//                       'Party: ${purchase.party ?? 'N/A'}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PurchaseDetailDialog extends StatefulWidget {
//   final int purchaseId;

//   const PurchaseDetailDialog({super.key, required this.purchaseId});

//   @override
//   State<PurchaseDetailDialog> createState() => _PurchaseDetailDialogState();
// }

// class _PurchaseDetailDialogState extends State<PurchaseDetailDialog> {
//   @override
//   void initState() {
//     super.initState();
//     final bloc = BlocProvider.of<PurchaseBloc>(context, listen: false);
//     if (bloc != null && bloc.state.purchaseDetail == null) {
//       print('Initiating FetchPurchaseById for ID: ${widget.purchaseId}');
//       bloc.add(FetchPurchaseById(widget.purchaseId));
//     }
//   }

//   String formatDate(dynamic date) {
//     if (date == null) return 'N/A';
//     DateTime dateTime;
//     if (date is DateTime) {
//       dateTime = date;
//     } else if (date is String) {
//       try {
//         dateTime = DateTime.parse(date); // e.g., "2001-01-12"
//       } catch (e) {
//         return 'N/A';
//       }
//     } else {
//       return 'N/A';
//     }
//     final year = dateTime.year.toString().padLeft(4, '0'); // YYYY
//     final month = dateTime.month.toString().padLeft(2, '0'); // MM
//     final day = dateTime.day.toString().padLeft(2, '0'); // DD
//     final hour = dateTime.hour;
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     final period = hour >= 12 ? 'PM' : 'AM';
//     final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
//     if (hour == 0 && minute == '00') {
//       return '$year-$month-$day';
//     }
//     return '$year-$month-$day ${displayHour.toString().padLeft(2, '0')}:$minute $period';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<PurchaseBloc, PurchaseState>(
//       listener: (context, state) {
//         print(
//             'BlocConsumer listener: error=${state.errorMessage}, purchaseDetail=${state.purchaseDetail}');
//         if (state.errorMessage != null) {
//           print('Dialog error: ${state.errorMessage}');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.errorMessage!)),
//           );
//           if (state.errorMessage!.contains('Unauthorized')) {
//             final dioClient = DioClient();
//             dioClient.logout(context);
//           }
//           Navigator.pop(context);
//         }
//       },
//       builder: (context, state) {
//         print(
//             'BlocConsumer builder: isLoading=${state.isLoading}, purchaseDetail=${state.purchaseDetail}, error=${state.errorMessage}');
//         if (state.isLoading) {
//           return _buildShimmerDialog();
//         }
//         if (state.errorMessage != null) {
//           return AlertDialog(
//             content: Text(state.errorMessage!),
//             contentPadding: const EdgeInsets.all(16),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         }
//         final detail = state.purchaseDetail;
//         if (detail == null || detail.id != widget.purchaseId) {
//           return AlertDialog(
//             content: const Text('No details available for this purchase'),
//             contentPadding: const EdgeInsets.all(16),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         }
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           contentPadding: const EdgeInsets.all(16),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Purchase Details',
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleLarge
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.grey),
//                       onPressed: () => Navigator.pop(context),
//                       padding: EdgeInsets.zero,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 _buildDetailRow(
//                     context, 'Purchase ID', '${detail.id ?? 'N/A'}'),
//                 _buildDetailRow(context, 'Voucher Number',
//                     '${detail.voucherNumber ?? 'N/A'}'),
//                 _buildDetailRow(
//                     context, 'Invoice Number', detail.invoiceNumber ?? 'N/A'),
//                 _buildDetailRow(context, 'Bill Type', detail.billType ?? 'N/A'),
//                 _buildDetailRow(context, 'Party', detail.party ?? 'N/A'),
//                 _buildDetailRow(
//                     context, 'Created On', formatDate(detail.createdOn)),
//                 _buildDetailRow(
//                     context, 'Updated On', formatDate(detail.updatedOn)),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Items:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 if (detail.purchaseItems != null &&
//                     detail.purchaseItems!.isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: detail.purchaseItems!.map((item) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4),
//                         child: ExpansionTile(
//                           leading: Container(
//                             width: 6,
//                             height: 6,
//                             decoration: const BoxDecoration(
//                               color: Colors.black,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           title: Text(
//                             item.product ?? 'N/A',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text(
//                             '${item.quantity} ${item.unit}',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(color: Colors.grey),
//                           ),
//                           children: [
//                             _buildDetailRow(context, 'Quantity',
//                                 'Rs ${item.quantity ?? '0'} /-'),
//                             _buildDetailRow(
//                                 context, 'Unit', item.unit ?? 'N/A'),
//                             _buildDetailRow(context, 'Selling Price per item',
//                                 'Rs ${item.sellingPrice ?? '0.00'}/-'),
//                             _buildDetailRow(context, 'Total',
//                                 'Rs ${item.total ?? 'N/A'}/-'),
//                             _buildDetailRow(context, 'Batch Number',
//                                 item.batchNumber ?? 'N/A'),
//                             _buildDetailRow(context, 'Expiry Date',
//                                 formatDate(item.expiryDate)),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   )
//                 else
//                   const Padding(
//                     padding: EdgeInsets.only(left: 16, top: 8),
//                     child: Text(
//                       'No items available',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDetailRow(BuildContext context, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 text: '$label - ',
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyMedium
//                     ?.copyWith(fontWeight: FontWeight.bold),
//                 children: [
//                   const TextSpan(text: ' '), // Adding space before value
//                   TextSpan(
//                     text: '$value ',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRowWithBullet(
//       BuildContext context, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Placeholder bullet with space below
//           Container(
//             width: 6,
//             height: 22, // Adjusted to your specified height
//             decoration: const BoxDecoration(
//               color: Colors.black,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(height: 4), // Space below the bullet
//           const SizedBox(width: 8), // Space between bullet and text
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 text: '$label - ',
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyMedium
//                     ?.copyWith(fontWeight: FontWeight.bold),
//                 children: [
//                   const TextSpan(text: ' '), // Adding space before value
//                   TextSpan(
//                     text: '$value ',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShimmerDialog() {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       contentPadding: const EdgeInsets.all(16),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: List.generate(8, (index) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//               child: Row(
//                 children: [
//                   Container(height: 14, width: 100, color: Colors.white),
//                   const SizedBox(width: 8),
//                   Expanded(
//                       child: Container(
//                           height: 14,
//                           width: double.infinity,
//                           color: Colors.white)),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_event.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_state.dart';
import 'package:shimmer/shimmer.dart'; // Ensure this package is added

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  String? _selectedDate;
  String? _selectedParty;
  final List<String> _parties = ['All']; // Default to 'All'

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final bloc = BlocProvider.of<PurchaseBloc>(context, listen: false);
    print('PurchaseBloc in didChangeDependencies: $bloc');
    if (bloc.state.purchases.isEmpty) {
      bloc.add(const FetchPurchases());
    }
  }

  @override
  void initState() {
    super.initState();
    // Initial setup or subscription if needed
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null
          ? DateTime.parse(_selectedDate!)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  List<PurchaseData> _filterPurchases(List<PurchaseData> purchases) {
    return purchases.where((purchase) {
      bool dateMatch = true;
      bool partyMatch = true;

      if (_selectedDate != null && purchase.createdOn != null) {
        final purchaseDate = purchase.createdOn as DateTime;
        final filterDate = DateTime.parse(_selectedDate!);
        dateMatch = purchaseDate.year == filterDate.year &&
            purchaseDate.month == filterDate.month &&
            purchaseDate.day == filterDate.day;
      }
      if (_selectedParty != null && _selectedParty != 'All') {
        partyMatch = purchase.party == _selectedParty;
      }

      return dateMatch && partyMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PurchaseBloc, PurchaseState>(
        listener: (context, state) {
          if (state.purchases.isNotEmpty && _parties.length == 1) {
            setState(() {
              final uniqueParties =
                  state.purchases.map((p) => p.party ?? 'N/A').toSet();
              _parties.addAll(uniqueParties);
            });
          }
        },
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
                        "Products Management",
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
                                            text:
                                                _selectedDate ?? 'yyyy-MM-dd'),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButton<String>(
                              hint: const Text('Select Party'),
                              value: _selectedParty,
                              items: _parties.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedParty = newValue;
                                });
                              },
                              isExpanded: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<PurchaseBloc, PurchaseState>(
                    builder: (context, state) {
                      print(
                          'BlocBuilder state: isLoading=${state.isLoading}, purchases.length=${state.purchases.length}, error=${state.errorMessage}');
                      if (state.isLoading && state.purchases.isEmpty) {
                        return _buildShimmerEffect(screenWidth, screenHeight);
                      }
                      if (state.errorMessage != null) {
                        return Center(child: Text(state.errorMessage!));
                      }
                      final filteredPurchases =
                          _filterPurchases(state.purchases);

                      if (filteredPurchases.isEmpty) {
                        return const Center(
                            child: Text('No purchases available'));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        itemCount: filteredPurchases.length,
                        itemBuilder: (context, index) {
                          final purchase = filteredPurchases[index];
                          return PurchaseCard(
                            purchase: purchase,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
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
}

class PurchaseCard extends StatelessWidget {
  final PurchaseData purchase;
  final double screenWidth;
  final double screenHeight;

  const PurchaseCard({
    super.key,
    required this.purchase,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Tapping purchase ID: ${purchase.id ?? 'null'}');
        if (purchase.id == null) {
          print('Purchase ID is null, cannot fetch details');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid purchase ID')),
          );
          return;
        }
        try {
          final bloc = BlocProvider.of<PurchaseBloc>(context, listen: false);
          print('Dispatching FetchPurchaseById for ID: ${purchase.id}');
          bloc.add(FetchPurchaseById(purchase.id!));
          print('Dialog will be shown when data is ready via BlocConsumer');
          showDialog(
            context: context,
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: PurchaseDetailDialog(purchaseId: purchase.id!),
            ),
          );
        } catch (e, stackTrace) {
          print('Exception in onTap: $e\nStackTrace: $stackTrace');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching details: $e')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voucher: ${purchase.voucherNumber ?? 'N/A'}',
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
                      'Invoice: ${purchase.invoiceNumber ?? 'N/A'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      'Total: NPR ${purchase.total ?? '0.00'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Type: ${purchase.billType ?? 'N/A'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      'Party: ${purchase.party ?? 'N/A'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PurchaseDetailDialog extends StatefulWidget {
  final int purchaseId;

  const PurchaseDetailDialog({super.key, required this.purchaseId});

  @override
  State<PurchaseDetailDialog> createState() => _PurchaseDetailDialogState();
}

class _PurchaseDetailDialogState extends State<PurchaseDetailDialog> {
  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<PurchaseBloc>(context, listen: false);
    if (bloc.state.purchaseDetail == null) {
      print('Initiating FetchPurchaseById for ID: ${widget.purchaseId}');
      bloc.add(FetchPurchaseById(widget.purchaseId));
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      try {
        dateTime = DateTime.parse(date); // e.g., "2001-01-12"
      } catch (e) {
        return 'N/A';
      }
    } else {
      return 'N/A';
    }
    final year = dateTime.year.toString().padLeft(4, '0'); // YYYY
    final month = dateTime.month.toString().padLeft(2, '0'); // MM
    final day = dateTime.day.toString().padLeft(2, '0'); // DD
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    if (hour == 0 && minute == '00') {
      return '$year-$month-$day';
    }
    return '$year-$month-$day ${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        print(
            'BlocConsumer listener: error=${state.errorMessage}, purchaseDetail=${state.purchaseDetail}');
        if (state.errorMessage != null) {
          print('Dialog error: ${state.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          if (state.errorMessage!.contains('Unauthorized')) {
            final dioClient = DioClient();
            dioClient.logout(context);
          }
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        print(
            'BlocConsumer builder: isLoading=${state.isLoading}, purchaseDetail=${state.purchaseDetail}, error=${state.errorMessage}');
        if (state.isLoading) {
          return _buildShimmerDialog();
        }
        if (state.errorMessage != null) {
          return AlertDialog(
            content: Text(state.errorMessage!),
            contentPadding: const EdgeInsets.all(16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
        final detail = state.purchaseDetail;
        if (detail == null || detail.id != widget.purchaseId) {
          return AlertDialog(
            content: const Text('No details available for this purchase'),
            contentPadding: const EdgeInsets.all(16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Purchase Details',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                    context, 'Purchase ID', '${detail.id ?? 'N/A'}'),
                _buildDetailRow(context, 'Voucher Number',
                    '${detail.voucherNumber ?? 'N/A'}'),
                _buildDetailRow(
                    context, 'Invoice Number', detail.invoiceNumber ?? 'N/A'),
                _buildDetailRow(context, 'Bill Type', detail.billType ?? 'N/A'),
                _buildDetailRow(context, 'Party', detail.party ?? 'N/A'),
                _buildDetailRow(
                    context, 'Created On', formatDate(detail.createdOn)),
                _buildDetailRow(
                    context, 'Updated On', formatDate(detail.updatedOn)),
                const SizedBox(height: 8),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (detail.purchaseItems != null &&
                    detail.purchaseItems!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: detail.purchaseItems!.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ExpansionTile(
                          leading: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            item.product ?? 'N/A',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.quantity} ${item.unit}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                          children: [
                            _buildDetailRow(context, 'Quantity',
                                'Rs ${item.quantity ?? '0'} /-'),
                            _buildDetailRow(
                                context, 'Unit', item.unit ?? 'N/A'),
                            _buildDetailRow(context, 'Selling Price per item',
                                'Rs ${item.sellingPrice ?? '0.00'}/-'),
                            _buildDetailRow(context, 'Total',
                                'Rs ${item.total ?? 'N/A'}/-'),
                            _buildDetailRow(context, 'Batch Number',
                                item.batchNumber ?? 'N/A'),
                            _buildDetailRow(context, 'Expiry Date',
                                formatDate(item.expiryDate)),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      'No items available',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label - ',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                children: [
                  const TextSpan(text: ' '), // Adding space before value
                  TextSpan(
                    text: '$value ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithBullet(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder bullet with space below
          Container(
            width: 6,
            height: 22, // Adjusted to your specified height
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4), // Space below the bullet
          const SizedBox(width: 8), // Space between bullet and text
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label - ',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                children: [
                  const TextSpan(text: ' '), // Adding space before value
                  TextSpan(
                    text: '$value ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(8, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                children: [
                  Container(height: 14, width: 100, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Container(
                          height: 14,
                          width: double.infinity,
                          color: Colors.white)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
