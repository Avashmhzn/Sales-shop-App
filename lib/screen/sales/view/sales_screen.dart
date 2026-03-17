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
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:saleup_app/screen/sales/bloc/sale_bloc.dart';
import 'package:saleup_app/screen/sales/bloc/sale_event.dart';
import 'package:saleup_app/screen/sales/bloc/sale_state.dart';
import 'package:saleup_app/model/sale_response.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/utility/datepiker.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  DateTime? _tempStart;
  DateTime? _tempEnd;
  DateTime? _appliedStart;
  DateTime? _appliedEnd;
  String? _selectedParty;
  String? _appliedParty;
  List<String> _parties = [];

  final TextEditingController _searchCtrl = TextEditingController();

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    context.read<SaleBloc>().add(const FetchSales());
    _loadParties();
  }

  Future<void> _loadParties() async {
    // TODO: Replace with real API call if you have customer/party list endpoint
    // For now using dummy — but you can fetch from '/party/get_parties/' like in purchase
    setState(() {
      _parties = ['Ritik', 'Suresh', 'Customer A', 'Customer B'];
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime? d) =>
      d != null ? DateFormat('MM/dd/yy').format(d) : '';

  Future<void> _selectDate(bool isStart) async {
    await showDialog(
      context: context,
      builder: (_) => NepaliDatePickerDialog(
        initialDate: NepaliDateTime.now(),
        firstDate: NepaliDateTime(2075),
        lastDate: NepaliDateTime(2090),
        onDateSelected: (picked) {
          setState(() {
            if (isStart) {
              _tempStart = picked.toDateTime();
            } else {
              _tempEnd = picked.toDateTime();
            }
          });
          if (context.canPop()) context.pop();
        },
      ),
    );
  }

  void _apply() {
    setState(() {
      _appliedStart = _tempStart;
      _appliedEnd = _tempEnd;
      _appliedParty = _selectedParty;
    });
  }

  void _reset() {
    setState(() {
      _tempStart = null;
      _tempEnd = null;
      _appliedStart = null;
      _appliedEnd = null;
      _selectedParty = null;
      _appliedParty = null;
      _searchCtrl.clear();
    });
  }

  List<SaleData> _filtered(List<SaleData> list) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return list.where((s) {
      bool dateMatch = true;
      if (_appliedStart != null && s.date != null) {
        dateMatch = !DateTime.parse(s.date!).isBefore(_appliedStart!);
      }
      if (_appliedEnd != null && s.date != null) {
        dateMatch = dateMatch && !DateTime.parse(s.date!).isAfter(_appliedEnd!);
      }
      bool partyMatch = _appliedParty == null ||
          (s.customer?.toLowerCase() == _appliedParty!.toLowerCase());
      bool searchMatch = q.isEmpty ||
          (s.customer?.toLowerCase().contains(q) ?? false) ||
          (s.invoiceNumber?.toString().toLowerCase().contains(q) ?? false);
      return dateMatch && partyMatch && searchMatch;
    }).toList();
  }

  Future<void> _confirmDelete(SaleData s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this sale?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    // TODO: Call your delete API here
    // Example:
    // await DioClient().dio.delete('/sale/delete_sale/?sale_id=${s.id}');

    // Refresh list
    context.read<SaleBloc>().add(const FetchSales());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sale deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _isDeleting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header (same as Purchase)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                color: Colors.transparent,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Image.asset(
                        'assets/images/back_button_logo.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sales',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              Image.asset(
                'assets/images/Line.png',
                width: double.infinity,
                height: 1,
                fit: BoxFit.cover,
              ),

              // Search + New Sales (same as Purchase)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Image.asset('assets/images/search.png',
                                  width: 22, height: 22),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 12),
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Add Sales screen
                        context.go(
                            '/add-sales'); // ← adjust if your route name is different
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59422),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('New Sales'),
                    ),
                  ],
                ),
              ),

              // Filter Section (copied exactly from Purchase)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 380;
                    final buttonWidth = isNarrow ? 68.0 : 80.0;
                    final buttonHeight = isNarrow ? 36.0 : 40.0;
                    final textSize = isNarrow ? 13.0 : 14.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 6),
                                child: Text('Start Date',
                                    style: TextStyle(
                                        fontSize: textSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800])),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 6),
                                child: Text('End Date',
                                    style: TextStyle(
                                        fontSize: textSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800])),
                              ),
                            ),
                            SizedBox(width: buttonWidth * 2 + 16),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 5,
                                child: _dateField('Start', _tempStart, true)),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 5,
                                child: _dateField('End', _tempEnd, false)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: _apply,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5A623),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Filter',
                                      style: TextStyle(
                                          fontSize: textSize,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: _reset,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9E9E9E),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Reset',
                                      style: TextStyle(
                                          fontSize: textSize,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Text('Party',
                              style: TextStyle(
                                  fontSize: textSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800])),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFF7043)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedParty,
                              isExpanded: true,
                              hint: Text('All Parties',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: textSize)),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFFFF7043), size: 20),
                              style: TextStyle(
                                  fontSize: textSize, color: Colors.black87),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('All Parties',
                                      style: TextStyle(fontSize: textSize)),
                                ),
                                ..._parties.map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p,
                                          style: TextStyle(fontSize: textSize),
                                          overflow: TextOverflow.ellipsis),
                                    )),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedParty = v),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Sales List - same card style as your Purchase screen
              BlocBuilder<SaleBloc, SaleState>(
                builder: (context, state) {
                  if (state.isLoading && state.sales.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                          child: Text(state.errorMessage!,
                              style: const TextStyle(color: Colors.red))),
                    );
                  }
                  final filtered = _filtered(state.sales);
                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No sales found')),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) => _saleCard(filtered[i]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(String hint, DateTime? date, bool isStart) {
    final text = date != null ? _fmtDate(date) : hint;
    return GestureDetector(
      onTap: () => _selectDate(isStart),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF7043)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: date != null ? Colors.black : Colors.grey[700],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 1),
            const Icon(Icons.calendar_today_outlined,
                size: 14, color: Color(0xFFFF7043)),
          ],
        ),
      ),
    );
  }

  Widget _saleCard(SaleData s) {
    final desc = [
      s.invoiceNumber?.toString() ?? '',
      s.billType ?? '',
      s.paymentMode ?? '',
    ].where((str) => str.isNotEmpty).join(' • ');

    return GestureDetector(
      onTap: () {
        // Optional: open detail popup or screen
        // Example: _showDetailsPopup(context, s);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.customer ?? 'Unknown Party',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc.isNotEmpty ? desc : 'No details available',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Edit button (same as Purchase)
                    _circleIcon(
                      'assets/images/edit.png',
                      const Color(0xFF4CAF50),
                      () {
                        // TODO: Navigate to edit sale screen
                        // Example: context.go('/sales/edit/${s.id}');
                      },
                      'Edit',
                    ),
                    const SizedBox(width: 12),
                    // Delete button (same as Purchase)
                    _circleIcon(
                      'assets/images/delete.png',
                      const Color(0xFFE53935),
                      () => _confirmDelete(s),
                      'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Amount',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              'NPR ${(s.total ?? 0).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(
      String asset, Color bgColor, VoidCallback onTap, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Image.asset(asset, width: 13, height: 13),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: bgColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
