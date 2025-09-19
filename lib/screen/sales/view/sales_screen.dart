// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/screen/sales/bloc/sale_bloc.dart';
// import 'package:saleup_app/screen/sales/bloc/sale_event.dart';
// import 'package:saleup_app/screen/sales/bloc/sale_state.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:saleup_app/model/sale_response.dart';

// class SaleScreen extends StatefulWidget {
//   const SaleScreen({super.key});

//   @override
//   State<SaleScreen> createState() => _SaleScreenState();
// }

// class _SaleScreenState extends State<SaleScreen> {
//   DateTime? _selectedDate;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!mounted) return;
//     final bloc = BlocProvider.of<SaleBloc>(context, listen: false);
//     print('SaleBloc in didChangeDependencies: $bloc');
//     if (bloc.state.sales.isEmpty) {
//       bloc.add(const FetchSales());
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

//   List<SaleData> _filterSales(List<SaleData> sales) {
//     return sales.where((sale) {
//       bool dateMatch = true;

//       if (_selectedDate != null) {
//         final saleDate = DateTime.parse(sale.date).toLocal();
//         dateMatch = saleDate.year == _selectedDate!.year &&
//             saleDate.month == _selectedDate!.month &&
//             saleDate.day == _selectedDate!.day;
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

//   void _showDetailsPopup(BuildContext context, SaleData sale) {
//     final DateTime dateTime = DateTime.parse(sale.date);
//     final String formattedDateTime =
//         DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);

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
//               'Sale Details',
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
//                 _buildDetailRow(Icons.receipt, 'Invoice Number',
//                     sale.invoiceNumber?.toString() ?? 'Unknown'),
//                 _buildDetailRow(
//                     Icons.calendar_today, 'Date', formattedDateTime),
//                 _buildDetailRow(Icons.payment, 'Bill Type', sale.billType),
//                 if (sale.chequeNumber != null)
//                   _buildDetailRow(
//                       Icons.check, 'Cheque Number', sale.chequeNumber!),
//                 if (sale.chequeDate != null)
//                   _buildDetailRow(
//                       Icons.date_range, 'Cheque Date', sale.chequeDate!),
//                 _buildDetailRow(Icons.money, 'Payment Mode', sale.paymentMode),
//                 _buildDetailRow(Icons.person, 'Customer', sale.customer),
//                 if (sale.description != null)
//                   _buildDetailRow(
//                       Icons.description, 'Description', sale.description!),
//                 _buildDetailRow(Icons.attach_money, 'Sub Total',
//                     '\$${sale.subTotal?.toStringAsFixed(2) ?? '0.00'}'),
//                 _buildDetailRow(Icons.currency_exchange, 'Vatable Amount',
//                     '\$${sale.vatableAmount?.toStringAsFixed(2) ?? '0.00'}'),
//                 _buildDetailRow(Icons.currency_exchange, 'VAT',
//                     '\$${sale.vat?.toStringAsFixed(2) ?? '0.00'}'),
//                 _buildDetailRow(Icons.discount, 'Discount',
//                     '\$${sale.discount?.toStringAsFixed(2) ?? '0.00'}'),
//                 _buildDetailRow(Icons.payments, 'Total',
//                     '\$${sale.total?.toStringAsFixed(2) ?? '0.00'}'),
//                 _buildDetailRow(Icons.attach_money, 'Tender Amount',
//                     '\$${sale.tenderAmount?.toStringAsFixed(2) ?? '0.00'}'),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Items',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 ...sale.items.map((item) => _buildItemRow(item)),
//               ],
//             ),
//           ),
//         ),
//         actions: [],
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

//   Widget _buildItemRow(SaleItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: ExpansionTile(
//         leading: Icon(Icons.inventory, color: Colors.grey[600], size: 20),
//         title: Text(
//           'Product: ${item.productName} (ID: ${item.product?.toString() ?? 'Unknown'})',
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
//                   'Quantity: ${item.quantity?.toString() ?? '0'}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//                 Text(
//                   'Rate: \$${item.rate?.toStringAsFixed(2) ?? '0.00'}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//                 Text(
//                   'Total: \$${item.total?.toStringAsFixed(2) ?? '0.00'}',
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
//       body: BlocListener<SaleBloc, SaleState>(
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
//                         "Sales",
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
//                   child: BlocBuilder<SaleBloc, SaleState>(
//                     builder: (context, state) {
//                       print(
//                           'BlocBuilder state: isLoading=${state.isLoading}, sales.length=${state.sales.length}, error=${state.errorMessage}');
//                       if (state.isLoading && state.sales.isEmpty) {
//                         return _buildShimmerEffect(screenWidth, screenHeight);
//                       }
//                       if (state.errorMessage != null) {
//                         return Center(child: Text(state.errorMessage!));
//                       }
//                       final filteredSales = _filterSales(state.sales);

//                       print(
//                           'Filtered sales count: ${filteredSales.length}, _selectedDate: $_selectedDate');

//                       if (filteredSales.isEmpty) {
//                         return const Center(child: Text('No sales available'));
//                       }

//                       return ListView.builder(
//                         padding: EdgeInsets.all(screenWidth * 0.03),
//                         itemCount: filteredSales.length,
//                         itemBuilder: (context, index) {
//                           final sale = filteredSales[index];
//                           return SaleCard(
//                             sale: sale,
//                             screenWidth: screenWidth,
//                             screenHeight: screenHeight,
//                             onTap: () => _showDetailsPopup(context, sale),
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

// class SaleCard extends StatelessWidget {
//   final SaleData sale;
//   final double screenWidth;
//   final double screenHeight;
//   final VoidCallback onTap;

//   const SaleCard({
//     super.key,
//     required this.sale,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final dateStr = sale.date;
//     final date = DateTime.parse(dateStr);
//     final originalDate = DateTime.parse(dateStr.split('T')[0]);
//     final adjustedDate = DateTime(originalDate.year, originalDate.month,
//         originalDate.day, date.hour, date.minute);
//     final String formattedDateTime =
//         DateFormat("yyyy-MM-dd hh:mm a").format(adjustedDate);

//     print(
//         'Card dateStr: $dateStr, date: $date, adjusted: $adjustedDate, formatted: $formattedDateTime');

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
//                         'ID: ${sale.id?.toString() ?? 'Unknown'}',
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
//                             'Invoice: ${sale.invoiceNumber?.toString() ?? 'Unknown'}',
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
//                         'Customer: ${sale.customer}',
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
import 'package:saleup_app/screen/sales/bloc/sale_bloc.dart';
import 'package:saleup_app/screen/sales/bloc/sale_event.dart';
import 'package:saleup_app/screen/sales/bloc/sale_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/model/sale_response.dart';
import 'package:flutter/foundation.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final bloc = BlocProvider.of<SaleBloc>(context, listen: false);
    if (kDebugMode) {
      print('SaleBloc in didChangeDependencies: $bloc');
    }
    if (bloc.state.sales.isEmpty) {
      bloc.add(const FetchSales());
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
    }
  }

  List<SaleData> _filterSales(List<SaleData> sales) {
    return sales.where((sale) {
      bool dateMatch = true;

      if (_selectedDate != null && sale.date != null) {
        final saleDate = DateTime.parse(sale.date!).toLocal();
        dateMatch = saleDate.year == _selectedDate!.year &&
            saleDate.month == _selectedDate!.month &&
            saleDate.day == _selectedDate!.day;
      }

      return dateMatch;
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

  void _showDetailsPopup(BuildContext context, SaleData sale) {
    final dateStr = sale.date ?? '';
    final String formattedDateTime = dateStr.isNotEmpty
        ? DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(dateStr))
        : 'Unknown Date';

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
              'Sale Details',
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
                _buildDetailRow(Icons.receipt, 'Invoice Number',
                    sale.invoiceNumber?.toString() ?? 'Unknown'),
                _buildDetailRow(
                    Icons.calendar_today, 'Date', formattedDateTime),
                _buildDetailRow(
                    Icons.payment, 'Bill Type', sale.billType ?? 'Unknown'),
                if (sale.chequeNumber != null)
                  _buildDetailRow(
                      Icons.check, 'Cheque Number', sale.chequeNumber!),
                if (sale.chequeDate != null)
                  _buildDetailRow(
                      Icons.date_range, 'Cheque Date', sale.chequeDate!),
                _buildDetailRow(
                    Icons.money, 'Payment Mode', sale.paymentMode ?? 'Unknown'),
                _buildDetailRow(
                    Icons.person, 'Customer', sale.customer ?? 'Unknown'),
                if (sale.description != null)
                  _buildDetailRow(
                      Icons.description, 'Description', sale.description!),
                _buildDetailRow(Icons.attach_money, 'Sub Total',
                    '\$${sale.subTotal?.toStringAsFixed(2) ?? '0.00'}'),
                _buildDetailRow(Icons.currency_exchange, 'Vatable Amount',
                    '\$${sale.vatableAmount?.toStringAsFixed(2) ?? '0.00'}'),
                _buildDetailRow(Icons.currency_exchange, 'VAT',
                    '\$${sale.vat?.toStringAsFixed(2) ?? '0.00'}'),
                _buildDetailRow(Icons.discount, 'Discount',
                    '\$${sale.discount?.toStringAsFixed(2) ?? '0.00'}'),
                _buildDetailRow(Icons.payments, 'Total',
                    '\$${sale.total?.toStringAsFixed(2) ?? '0.00'}'),
                _buildDetailRow(Icons.attach_money, 'Tender Amount',
                    '\$${sale.tenderAmount?.toStringAsFixed(2) ?? '0.00'}'),
                const SizedBox(height: 10),
                Text(
                  'Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ...sale.items.map((item) => _buildItemRow(item)),
              ],
            ),
          ),
        ),
        actions: const [],
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

  Widget _buildItemRow(SaleItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        leading: Icon(Icons.inventory, color: Colors.grey[600], size: 20),
        title: Text(
          'Product: ${item.productName ?? 'Unknown'} (ID: ${item.product?.toString() ?? 'Unknown'})',
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
                  'Quantity: ${item.quantity?.toString() ?? '0'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  'Rate: \$${item.rate?.toStringAsFixed(2) ?? '0.00'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  'Total: \$${item.total?.toStringAsFixed(2) ?? '0.00'}',
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
      body: BlocListener<SaleBloc, SaleState>(
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
                        "Sales",
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
                  child: BlocBuilder<SaleBloc, SaleState>(
                    builder: (context, state) {
                      if (kDebugMode) {
                        print(
                            'BlocBuilder state: isLoading=${state.isLoading}, sales.length=${state.sales.length}, error=${state.errorMessage}');
                      }
                      if (state.isLoading && state.sales.isEmpty) {
                        return _buildShimmerEffect(screenWidth, screenHeight);
                      }
                      if (state.errorMessage != null) {
                        return Center(child: Text(state.errorMessage!));
                      }
                      final filteredSales = _filterSales(state.sales);

                      if (kDebugMode) {
                        print(
                            'Filtered sales count: ${filteredSales.length}, _selectedDate: $_selectedDate');
                      }

                      if (filteredSales.isEmpty) {
                        return const Center(child: Text('No sales available'));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        itemCount: filteredSales.length,
                        itemBuilder: (context, index) {
                          final sale = filteredSales[index];
                          return SaleCard(
                            sale: sale,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onTap: () => _showDetailsPopup(context, sale),
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

class SaleCard extends StatelessWidget {
  final SaleData sale;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const SaleCard({
    super.key,
    required this.sale,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = sale.date ?? '';
    final formattedDateTime = dateStr.isNotEmpty
        ? DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.parse(dateStr))
        : 'Unknown Date';

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
                        'ID: ${sale.id?.toString() ?? 'Unknown'}',
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
                            'Invoice: ${sale.invoiceNumber?.toString() ?? 'Unknown'}',
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
                        'Customer: ${sale.customer ?? 'Unknown'}',
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
