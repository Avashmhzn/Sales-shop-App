// // lib/screen/reports/stock_ledger_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_category_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';
// import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_bloc.dart';
// import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_event.dart';
// import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_state.dart';
// import 'package:saleup_app/services/report_service.dart';

// class StockLedgerScreen extends StatelessWidget {
//   const StockLedgerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) =>
//           StockLedgerBloc(reportService: ReportService(dioClient: DioClient()))
//             ..add(InitializeStockLedger()),
//       child: const _StockLedgerView(),
//     );
//   }
// }

// class _StockLedgerView extends StatefulWidget {
//   const _StockLedgerView();
//   @override
//   State<_StockLedgerView> createState() => _StockLedgerViewState();
// }

// class _StockLedgerViewState extends State<_StockLedgerView> {
//   DateTime? startDate;
//   DateTime? endDate;
//   ProductData? selectedProduct;
//   CategoryData? selectedCategory;
//   String rateType = 'cost';
//   List<ProductData> _products = [];
//   List<CategoryData> _categories = [];

//   // ★ FIX: Cache the last successful state so the list doesn't disappear during export
//   StockLedgerSuccess? _lastSuccessState;

//   String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

//   // ★ UX FIX: Number formatters with commas for readability
//   String _fmtQty(double value) {
//     if (value == 0) return '-';
//     return value.toStringAsFixed(0).replaceAllMapped(
//         RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
//   }

//   String _fmtCurrency(double value) {
//     if (value == 0) return '-';
//     return 'Rs. ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
//   }

//   void _filter() {
//     if (startDate == null || endDate == null) return;
//     context.read<StockLedgerBloc>().add(FetchStockLedgerReport(
//           startDate: _fmt(startDate!),
//           endDate: _fmt(endDate!),
//           productId: selectedProduct?.id,
//           categoryId: selectedCategory?.id,
//           rateType: rateType,
//         ));
//     Navigator.pop(context); // Close filter sheet
//   }

//   void _export() {
//     if (startDate == null || endDate == null) return;
//     context.read<StockLedgerBloc>().add(ExportStockLedger(
//           startDate: _fmt(startDate!),
//           endDate: _fmt(endDate!),
//           productId: selectedProduct?.id,
//           categoryId: selectedCategory?.id,
//         ));
//   }

//   void _reset() {
//     setState(() {
//       selectedProduct = null;
//       selectedCategory = null;
//       rateType = 'cost';
//     });
//     _filter();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Stock Ledger'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0.5,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: () => _showFilterBottomSheet(context),
//             tooltip: 'Filters',
//           ),
//           IconButton(
//             icon: const Icon(Icons.download_rounded),
//             onPressed: _export,
//             tooltip: 'Export Report',
//           ),
//         ],
//       ),
//       body: BlocConsumer<StockLedgerBloc, StockLedgerState>(
//         listener: (context, state) {
//           if (state is StockLedgerExportSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text('Exported → ${state.filePath}'),
//                   backgroundColor: Colors.green),
//             );
//           }
//           if (state is StockLedgerFailure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text(state.message), backgroundColor: Colors.red),
//             );
//           }
//           if (state is StockLedgerSuccess && startDate == null) {
//             setState(() {
//               startDate = state.defaultStartDate;
//               endDate = state.defaultEndDate;
//               _products = state.products;
//               _categories = state.categories;
//             });
//           }
//         },
//         builder: (context, state) {
//           if (state is StockLedgerSuccess) {
//             _products = state.products;
//             _categories = state.categories;
//             _lastSuccessState = state; // ★ Cache data
//           }

//           // ★ FIX: Use Stack to overlay loading on top of data, preventing blank screen
//           return Stack(
//             children: [
//               Column(
//                 children: [
//                   _buildActiveFiltersBar(),
//                   Expanded(child: _buildBody(state)),
//                 ],
//               ),

//               // ★ Show loading overlay ONLY when exporting
//               if (state is StockLedgerExporting)
//                 Container(
//                   color: Colors.black.withOpacity(0.3),
//                   child: Center(
//                     child: Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const CircularProgressIndicator(),
//                             const SizedBox(height: 12),
//                             Text('Generating Report...',
//                                 style: TextStyle(
//                                     color: Colors.grey[800],
//                                     fontWeight: FontWeight.w500)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════
//   //  ACTIVE FILTERS BAR (Shows what filters are applied)
//   // ═══════════════════════════════════════════════════════
//   Widget _buildActiveFiltersBar() {
//     return Container(
//       height: 40,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
//           const SizedBox(width: 8),
//           Text(
//             '${startDate != null ? DateFormat('dd MMM yyyy').format(startDate!) : '...'} - ${endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : '...'}',
//             style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[800],
//                 fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(width: 12),
//           if (selectedProduct != null)
//             _filterChip('${selectedProduct!.name} ×'),
//           if (selectedCategory != null)
//             _filterChip('${selectedCategory!.name} ×'),
//           if (rateType == 'selling') _filterChip('Selling Price ×'),
//         ],
//       ),
//     );
//   }

//   Widget _filterChip(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       margin: const EdgeInsets.only(right: 8),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(text,
//           style: TextStyle(
//               fontSize: 11,
//               color: Colors.blue[900],
//               fontWeight: FontWeight.w500)),
//     );
//   }

//   // ═══════════════════════════════════════════════════════
//   //  FILTER BOTTOM SHEET (Clean, uncramped layout)
//   // ═══════════════════════════════════════════════════════
//   void _showFilterBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return Padding(
//               padding: EdgeInsets.fromLTRB(
//                   16, 16, 16, MediaQuery.of(context).viewInsets.bottom),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                       child: Container(
//                           width: 40,
//                           height: 4,
//                           decoration: BoxDecoration(
//                               color: Colors.grey[300],
//                               borderRadius: BorderRadius.circular(4)))),
//                   const SizedBox(height: 20),
//                   const Text('Filter Report',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 20),
//                   // Dropdowns
//                   Row(
//                     children: [
//                       Expanded(
//                           child: _buildDropdown<ProductData>(
//                         hint: 'All Products',
//                         value: selectedProduct,
//                         items: _products,
//                         onChanged: (v) {
//                           setState(() {
//                             selectedProduct = v;
//                             if (v != null) selectedCategory = null;
//                           });
//                           setModalState(() {});
//                         },
//                       )),
//                       const SizedBox(width: 12),
//                       Expanded(
//                           child: _buildDropdown<CategoryData>(
//                         hint: 'All Categories',
//                         value: selectedCategory,
//                         items: _categories,
//                         onChanged: (v) {
//                           setState(() {
//                             selectedCategory = v;
//                             if (v != null) selectedProduct = null;
//                           });
//                           setModalState(() {});
//                         },
//                       )),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   // Dates
//                   Row(
//                     children: [
//                       Expanded(child: _buildDateField(isStart: true)),
//                       const SizedBox(width: 12),
//                       Expanded(child: _buildDateField(isStart: false)),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   // Rate Type Toggle
//                   const Text('Rate Type',
//                       style: TextStyle(fontSize: 12, color: Colors.grey)),
//                   const SizedBox(height: 8),
//                   Container(
//                     decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8)),
//                     child: Row(
//                       children: [
//                         Expanded(
//                             child: _rateButton('Cost Price', rateType == 'cost',
//                                 () {
//                           setState(() => rateType = 'cost');
//                           setModalState(() {});
//                         })),
//                         Expanded(
//                             child: _rateButton(
//                                 'Selling Price', rateType == 'selling', () {
//                           setState(() => rateType = 'selling');
//                           setModalState(() {});
//                         })),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   // Buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: _reset,
//                           icon: const Icon(Icons.refresh, size: 16),
//                           label: const Text('Reset'),
//                           style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.all(14),
//                               side: BorderSide(color: Colors.grey.shade300)),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: (startDate != null && endDate != null)
//                               ? _filter
//                               : null,
//                           icon: const Icon(Icons.check, size: 16),
//                           label: const Text('Apply Filter'),
//                           style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.all(14), elevation: 0),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _rateButton(String text, bool isActive, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
//           borderRadius: BorderRadius.circular(7),
//         ),
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//               color: isActive ? Colors.white : Colors.grey[700],
//               fontWeight: FontWeight.w600,
//               fontSize: 13),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown<T>(
//       {required String hint,
//       required T? value,
//       required List<T> items,
//       required ValueChanged<T?> onChanged}) {
//     return DropdownButtonFormField<T>(
//       initialValue: value,
//       hint: Text(hint, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
//       decoration: InputDecoration(
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       items: [
//         DropdownMenuItem<T>(value: null, child: Text(hint)),
//         ...items.map((item) => DropdownMenuItem<T>(
//             value: item,
//             child: Text((item as dynamic).name as String,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontSize: 13)))),
//       ],
//       onChanged: onChanged,
//     );
//   }

//   Widget _buildDateField({required bool isStart}) {
//     final date = isStart ? startDate : endDate;
//     return InkWell(
//       onTap: () async {
//         final d = await showDatePicker(
//             context: context,
//             initialDate: date ?? DateTime.now(),
//             firstDate: DateTime(2020),
//             lastDate: DateTime(2030));
//         if (d != null) setState(() => isStart ? startDate = d : endDate = d);
//       },
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: isStart ? 'Start Date' : 'End Date',
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         ),
//         child: Text(
//             date != null ? DateFormat('dd MMM, yyyy').format(date) : 'Select',
//             style: TextStyle(
//                 fontSize: 13,
//                 color: date != null ? Colors.black87 : Colors.grey[500])),
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════
//   //  BODY - Enhanced UI/UX (Accounting Standards)
//   // ═══════════════════════════════════════════════════════
//   Widget _buildBody(StockLedgerState state) {
//     // ★ FIX: If we are exporting, use cached state so screen isn't blank
//     final displayState =
//         (state is StockLedgerExporting || state is StockLedgerExportSuccess)
//             ? _lastSuccessState
//             : state;

//     if (state is StockLedgerLoading && _lastSuccessState == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (displayState is StockLedgerFailure) {
//       return Center(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//         const Icon(Icons.error_outline, size: 40, color: Colors.red),
//         const SizedBox(height: 12),
//         Text(displayState.message, style: const TextStyle(color: Colors.red)),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//             onPressed: _filter,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Retry')),
//       ]));
//     }
//     if (displayState is StockLedgerSuccess) {
//       final accounts = displayState.report.data ?? [];
//       if (accounts.isEmpty) {
//         return Center(
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
//           const SizedBox(height: 12),
//           Text('No records found', style: TextStyle(color: Colors.grey[500])),
//         ]));
//       }

//       return ListView.separated(
//         itemCount: accounts.length,
//         separatorBuilder: (_, __) => Divider(
//             height: 1, color: Colors.grey[200], indent: 16, endIndent: 16),
//         itemBuilder: (context, index) {
//           final account = accounts[index];
//           final entry = account.ledger?.firstOrNull;
//           final isNegativeClosing = (entry?.closing ?? 0) < 0;

//           return Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Row 1: Product Name & Closing Qty
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         account.productName ?? '',
//                         style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 15,
//                             color: Colors.black87),
//                       ),
//                     ),
//                     // const SizedBox(width: 16),
//                     // Container(
//                     //   padding: const EdgeInsets.symmetric(
//                     //       horizontal: 10, vertical: 4),
//                     //   decoration: BoxDecoration(
//                     //     color: isNegativeClosing
//                     //         ? Colors.red.withOpacity(0.1)
//                     //         : Colors.blue.withOpacity(0.1),
//                     //     borderRadius: BorderRadius.circular(6),
//                     //   ),
//                     //   child: Column(
//                     //     crossAxisAlignment: CrossAxisAlignment.end,
//                     //     children: [
//                     //       Text(
//                     //         _fmtQty(
//                     //             entry?.closing ?? 0), // ★ Formatted with commas
//                     //         style: TextStyle(
//                     //           fontWeight: FontWeight.w800,
//                     //           fontSize: 15,
//                     //           color: isNegativeClosing
//                     //               ? Colors.red
//                     //               : Colors.blue[700],
//                     //         ),
//                     //       ),
//                     //       Text('Closing',
//                     //           style: TextStyle(
//                     //               fontSize: 9,
//                     //               color: isNegativeClosing
//                     //                   ? Colors.red
//                     //                   : Colors.blue[700],
//                     //               fontWeight: FontWeight.w600)),
//                     //     ],
//                     //   ),
//                     // ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Row 2: Summary Grid (Right Aligned for Accounting)
//                 Row(
//                   children: [
//                     _summaryBlock('OPENING', _fmtQty(entry?.opening ?? 0),
//                         _fmtCurrency(entry?.openingValue ?? 0)),
//                     _summaryBlock('PURCHASE', _fmtQty(entry?.purchase ?? 0),
//                         _fmtCurrency(entry?.purchaseValue ?? 0),
//                         color: Colors.green),
//                     _summaryBlock('SALES', _fmtQty(entry?.sales ?? 0),
//                         _fmtCurrency(entry?.salesValue ?? 0),
//                         color: Colors.orange),
//                     _summaryBlock(
//                       'RETURNS',
//                       _fmtQty(entry?.salesReturnQty ?? 0),
//                       _fmtCurrency(entry?.salesReturnValue ?? 0),
//                       color: Colors.red[300],
//                     ),
//                     _summaryBlock(
//                       'CLOSING',
//                       _fmtQty(entry?.closing ?? 0),
//                       _fmtCurrency(entry?.closingValue ?? 0),
//                       color: Colors.red[300],
//                     ),
//                   ],
//                 ),
//                 // const SizedBox(height: 10),

//                 // // Row 3: Avg Rate
//                 // Container(
//                 //   padding: const EdgeInsets.only(top: 8),
//                 //   decoration: BoxDecoration(
//                 //       border:
//                 //           Border(top: BorderSide(color: Colors.grey[100]!))),
//                 //   child: Row(
//                 //     mainAxisAlignment: MainAxisAlignment.end,
//                 //     children: [
//                 //       Text('Avg Rate: ',
//                 //           style:
//                 //               TextStyle(fontSize: 11, color: Colors.grey[500])),
//                 //       Text(
//                 //         _fmtCurrency(rateType == 'cost'
//                 //             ? (entry?.costPrice ?? 0)
//                 //             : (entry?.sellingPrice ?? 0)),
//                 //         style: TextStyle(
//                 //             fontSize: 11,
//                 //             color: Colors.grey[700],
//                 //             fontWeight: FontWeight.w600),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // )
//               ],
//             ),
//           );
//         },
//       );
//     }
//     return const SizedBox();
//   }

//   // ★ UX ENHANCEMENT: Right-aligned data blocks, grayed out zeros for clean reading
//   Widget _summaryBlock(String title, String qty, String value, {Color? color}) {
//     final isZero = qty == '-';

//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end, // ★ Right aligned
//         children: [
//           Text(title,
//               style: TextStyle(
//                   fontSize: 9,
//                   color: Colors.grey[500],
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 0.5)),
//           const SizedBox(height: 4),
//           Text(qty,
//               style: TextStyle(
//                   fontSize: 13,
//                   color: isZero
//                       ? Colors.grey[300]
//                       : (color ?? Colors.black87), // ★ Gray out 0s
//                   fontWeight: FontWeight.w600)),
//           Text(value,
//               style: TextStyle(
//                   fontSize: 10,
//                   color: isZero
//                       ? Colors.grey[300]
//                       : Colors.grey[600])), // ★ Gray out 0s
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_category_response.dart';
import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_bloc.dart';
import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_event.dart';
import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_state.dart';
import 'package:saleup_app/services/report_service.dart';

class StockLedgerScreen extends StatelessWidget {
  const StockLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StockLedgerBloc(reportService: ReportService(dioClient: DioClient()))
            ..add(InitializeStockLedger()),
      child: const _StockLedgerView(),
    );
  }
}

class _StockLedgerView extends StatefulWidget {
  const _StockLedgerView();
  @override
  State<_StockLedgerView> createState() => _StockLedgerViewState();
}

class _StockLedgerViewState extends State<_StockLedgerView> {
  DateTime? startDate;
  DateTime? endDate;
  ProductData? selectedProduct;
  CategoryData? selectedCategory;
  String rateType = 'cost';
  List<ProductData> _products = [];
  List<CategoryData> _categories = [];

  // ★ FIX: Cache the last successful state so the list doesn't disappear during export
  StockLedgerSuccess? _lastSuccessState;

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  // ★ UX FIX: Number formatters with commas for readability
  String _fmtQty(double value) {
    if (value == 0) return '-';
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  String _fmtCurrency(double value) {
    if (value == 0) return '-';
    return 'Rs. ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  void _filter() {
    if (startDate == null || endDate == null) return;
    context.read<StockLedgerBloc>().add(FetchStockLedgerReport(
          startDate: _fmt(startDate!),
          endDate: _fmt(endDate!),
          productId: selectedProduct?.id,
          categoryId: selectedCategory?.id,
          rateType: rateType,
        ));
    Navigator.pop(context); // Close filter sheet
  }

  void _export() {
    if (startDate == null || endDate == null) return;
    context.read<StockLedgerBloc>().add(ExportStockLedger(
          startDate: _fmt(startDate!),
          endDate: _fmt(endDate!),
          productId: selectedProduct?.id,
          categoryId: selectedCategory?.id,
        ));
  }

  void _reset() {
    setState(() {
      selectedProduct = null;
      selectedCategory = null;
      rateType = 'cost';
    });
    _filter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Stock Ledger'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _export,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: BlocConsumer<StockLedgerBloc, StockLedgerState>(
        listener: (context, state) {
          if (state is StockLedgerExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Exported → ${state.filePath}'),
                  backgroundColor: Colors.green),
            );
          }
          if (state is StockLedgerFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is StockLedgerSuccess && startDate == null) {
            // ★ Start Date = Fiscal Year start, End Date = Day close date
            setState(
              () {
                startDate = state.defaultStartDate;
                endDate = state.defaultEndDate;
                _products = state.products;
                _categories = state.categories;
              },
            );

            context.read<StockLedgerBloc>().add(
                  FetchStockLedgerReport(
                    startDate: _fmt(startDate!),
                    endDate: _fmt(endDate!),
                    productId: selectedProduct?.id,
                    categoryId: selectedCategory?.id,
                    rateType: rateType,
                  ),
                );
          }
        },
        builder: (context, state) {
          if (state is StockLedgerSuccess) {
            _products = state.products;
            _categories = state.categories;
            _lastSuccessState = state; // ★ Cache data
          }

          // ★ FIX: Use Stack to overlay loading on top of data, preventing blank screen
          return Stack(
            children: [
              Column(
                children: [
                  _buildActiveFiltersBar(),
                  Expanded(child: _buildBody(state)),
                ],
              ),

              // ★ Show loading overlay ONLY when exporting
              if (state is StockLedgerExporting)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text('Generating Report...',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ACTIVE FILTERS BAR (Shows what filters are applied)
  // ═══════════════════════════════════════════════════════
  Widget _buildActiveFiltersBar() {
    final chips = <Widget>[
      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Text(
        '${startDate != null ? DateFormat('dd MMM yyyy').format(startDate!) : '...'} - ${endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : '...'}',
        style: TextStyle(
            fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w500),
      ),
      const SizedBox(width: 12),
      if (selectedProduct != null) _filterChip('${selectedProduct!.name} ×'),
      if (selectedCategory != null) _filterChip('${selectedCategory!.name} ×'),
      if (rateType == 'selling') _filterChip('Selling Price ×'),
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      // ★ FIX: Use SingleChildScrollView to prevent horizontal overflow
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips,
        ),
      ),
    );
  }

  Widget _filterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: Colors.blue[900],
              fontWeight: FontWeight.w500)),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  FILTER BOTTOM SHEET (Clean, uncramped layout)
  // ═══════════════════════════════════════════════════════
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  // ★ FIX: Properly handle keyboard inset without overflowing
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                // ★ FIX: Constrain max height to 85% of screen
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  // ★ FIX: Make content scrollable to prevent vertical overflow
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4)))),
                        const SizedBox(height: 20),
                        const Text('Filter Report',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        // Dropdowns
                        Row(
                          children: [
                            Expanded(
                                child: _buildDropdown<ProductData>(
                              hint: 'All Products',
                              value: selectedProduct,
                              items: _products,
                              onChanged: (v) {
                                setState(() {
                                  selectedProduct = v;
                                  if (v != null) selectedCategory = null;
                                });
                                setModalState(() {});
                              },
                            )),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildDropdown<CategoryData>(
                              hint: 'All Categories',
                              value: selectedCategory,
                              items: _categories,
                              onChanged: (v) {
                                setState(() {
                                  selectedCategory = v;
                                  if (v != null) selectedProduct = null;
                                });
                                setModalState(() {});
                              },
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Dates
                        Row(
                          children: [
                            Expanded(child: _buildDateField(isStart: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDateField(isStart: false)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Rate Type Toggle
                        const Text('Rate Type',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _rateButton(
                                      'Cost Price', rateType == 'cost', () {
                                setState(() => rateType = 'cost');
                                setModalState(() {});
                              })),
                              Expanded(
                                  child: _rateButton(
                                      'Selling Price', rateType == 'selling',
                                      () {
                                setState(() => rateType = 'selling');
                                setModalState(() {});
                              })),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _reset,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reset'),
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(14),
                                    side: BorderSide(
                                        color: Colors.grey.shade300)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    (startDate != null && endDate != null)
                                        ? _filter
                                        : null,
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Apply Filter'),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(14),
                                    elevation: 0),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _rateButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: Text(hint,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
          overflow: TextOverflow.ellipsis),
      isExpanded: true, // ★ FIX: Allow dropdown to use full width
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: [
        DropdownMenuItem<T>(value: null, child: Text(hint)),
        ...items.map((item) => DropdownMenuItem<T>(
              value: item,
              // ★ FIX: Prevent long names from overflowing
              child: Text(
                (item as dynamic).name as String,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontSize: 13),
              ),
            )),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({required bool isStart}) {
    final date = isStart ? startDate : endDate;

    // ★ Restrict manual date selection strictly within the Fiscal Year bounds
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2030);

    if (_lastSuccessState != null) {
      firstDate = _lastSuccessState!.defaultStartDate;
      lastDate = _lastSuccessState!.defaultEndDate;
    }

    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
            context: context,
            initialDate: date ?? (isStart ? firstDate : lastDate),
            firstDate: firstDate, // ★ Cannot pick before FY start
            lastDate: lastDate); // ★ Cannot pick after FY end
        if (d != null) setState(() => isStart ? startDate = d : endDate = d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isStart ? 'Start Date' : 'End Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        child: Text(
            date != null ? DateFormat('dd MMM, yyyy').format(date) : 'Select',
            style: TextStyle(
                fontSize: 13,
                color: date != null ? Colors.black87 : Colors.grey[500])),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  BODY - Enhanced UI/UX (Accounting Standards)
  // ═══════════════════════════════════════════════════════
  Widget _buildBody(StockLedgerState state) {
    // ★ FIX: If we are exporting, use cached state so screen isn't blank
    final displayState =
        (state is StockLedgerExporting || state is StockLedgerExportSuccess)
            ? _lastSuccessState
            : state;

    if (state is StockLedgerLoading && _lastSuccessState == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (displayState is StockLedgerFailure) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 40, color: Colors.red),
        const SizedBox(height: 12),
        Text(displayState.message, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
            onPressed: _filter,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry')),
      ]));
    }
    if (displayState is StockLedgerSuccess) {
      final accounts = displayState.report.data ?? [];
      if (accounts.isEmpty) {
        return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No records found', style: TextStyle(color: Colors.grey[500])),
        ]));
      }

      return ListView.separated(
        itemCount: accounts.length,
        separatorBuilder: (_, __) => Divider(
            height: 1, color: Colors.grey[200], indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final account = accounts[index];
          final entry = account.ledger?.firstOrNull;
          final isNegativeClosing = (entry?.closing ?? 0) < 0;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Product Name & Closing Qty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        account.productName ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: Summary Grid (Right Aligned for Accounting)
                Row(
                  children: [
                    _summaryBlock('OPENING', _fmtQty(entry?.opening ?? 0),
                        _fmtCurrency(entry?.openingValue ?? 0)),
                    _summaryBlock('PURCHASE', _fmtQty(entry?.purchase ?? 0),
                        _fmtCurrency(entry?.purchaseValue ?? 0),
                        color: Colors.green),
                    _summaryBlock('SALES', _fmtQty(entry?.sales ?? 0),
                        _fmtCurrency(entry?.salesValue ?? 0),
                        color: Colors.orange),
                    _summaryBlock(
                      'RETURNS',
                      _fmtQty(entry?.salesReturnQty ?? 0),
                      _fmtCurrency(entry?.salesReturnValue ?? 0),
                      color: Colors.red[300],
                    ),
                    _summaryBlock(
                      'CLOSING',
                      _fmtQty(entry?.closing ?? 0),
                      _fmtCurrency(entry?.closingValue ?? 0),
                      color: isNegativeClosing ? Colors.red : Colors.blue[700],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  // ★ UX ENHANCEMENT: Right-aligned data blocks, grayed out zeros for clean reading
  Widget _summaryBlock(String title, String qty, String value, {Color? color}) {
    final isZero = qty == '-';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // ★ Right aligned
          children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            // ★ FIX: FittedBox prevents qty overflow
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(qty,
                  style: TextStyle(
                      fontSize: 13,
                      color:
                          isZero ? Colors.grey[300] : (color ?? Colors.black87),
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 10,
                      color: isZero ? Colors.grey[300] : Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }
}
