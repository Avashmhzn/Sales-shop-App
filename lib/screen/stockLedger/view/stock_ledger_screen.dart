// // lib/screen/stock_ledger/stock_ledger_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_category_response.dart';
// import '../bloc/stock_ledger_bloc.dart';
// import '../bloc/stock_ledger_event.dart';
// import '../bloc/stock_ledger_state.dart';

// class StockLedgerScreen extends StatelessWidget {
//   const StockLedgerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) =>
//           StockLedgerBloc(dioClient: DioClient())..add(FetchFilterOptions()),
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
//   DateTime start = DateTime.now().subtract(const Duration(days: 30));
//   DateTime end = DateTime.now();
//   ProductData? product;
//   CategoryData? category;
//   String rateField = 'Cost Price';
//   String rateType = 'cost'; // 'cost' or 'selling'

//   @override
//   void initState() {
//     super.initState();
//     // Auto load last 30 days like web
//     Future.delayed(Duration.zero, () {
//       filter();
//     });
//   }

//   void filter() {
//     final from = DateFormat('yyyy-MM-dd').format(start);
//     final to = DateFormat('yyyy-MM-dd').format(end);

//     context.read<StockLedgerBloc>().add(FetchStockLedgerReport(
//           startDate: from,
//           endDate: to,
//           productId: product?.id,
//           categoryId: category?.id,
//           rateType: rateType,
//         ));
//   }

//   void reset() {
//     setState(() {
//       product = null;
//       category = null;
//       start = DateTime.now().subtract(const Duration(days: 30));
//       end = DateTime.now();
//       rateField = 'Cost Price';
//       rateType = 'cost';
//     });
//     filter();
//   }

//   void _downloadPdf(Map<String, dynamic> rawJson) {
//     DioClient().downloadStockLedgerAsPdf(
//       rawJson,
//       DateFormat('dd/MM/yyyy').format(start),
//       DateFormat('dd/MM/yyyy').format(end),
//       rateType,
//     );
//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text('PDF Downloaded!')));
//   }

//   void _downloadExcel(Map<String, dynamic> rawJson) {
//     DioClient().downloadStockLedgerAsExcel(
//       rawJson,
//       DateFormat('dd/MM/yyyy').format(start),
//       DateFormat('dd/MM/yyyy').format(end),
//       rateType,
//     );
//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text('Excel Downloaded!')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Stock Ledger',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black54),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(children: [
//               Expanded(child: _productDropdown()),
//               const SizedBox(width: 12),
//               Expanded(child: _categoryDropdown()),
//               const SizedBox(width: 12),
//               Expanded(child: _rateDropdown()),
//             ]),
//             const SizedBox(height: 16),
//             Row(children: [
//               Expanded(child: _dateField(true)),
//               const SizedBox(width: 12),
//               Expanded(child: _dateField(false)),
//             ]),
//             const SizedBox(height: 16),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//               ElevatedButton.icon(
//                 onPressed: filter,
//                 icon: const Icon(Icons.filter_alt),
//                 label: const Text('Filter'),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green[700]),
//               ),
//               ElevatedButton.icon(
//                 onPressed: reset,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Reset'),
//                 style:
//                     ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.print),
//                 label: const Text('Print'),
//                 style:
//                     ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
//               ),
//             ]),
//             const SizedBox(height: 20),
//             BlocBuilder<StockLedgerBloc, StockLedgerState>(
//               builder: (_, state) {
//                 if (state is StockLedgerLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (state is StockLedgerFailure) {
//                   return Center(
//                     child: Column(
//                       children: [
//                         Text(state.message,
//                             style: const TextStyle(color: Colors.red)),
//                         ElevatedButton.icon(
//                             onPressed: filter,
//                             icon: const Icon(Icons.refresh),
//                             label: const Text('Retry')),
//                       ],
//                     ),
//                   );
//                 }
//                 if (state is StockLedgerSuccess) {
//                   final hasData = state.report.data?.isNotEmpty ?? false;
//                   return Column(
//                     children: [
//                       if (hasData) ...[
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton.icon(
//                                 onPressed: () => _downloadPdf(state.rawJson),
//                                 icon: const Icon(Icons.picture_as_pdf),
//                                 label: const Text('PDF'),
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red),
//                               ),
//                               const SizedBox(width: 12),
//                               ElevatedButton.icon(
//                                 onPressed: () => _downloadExcel(state.rawJson),
//                                 icon: const Icon(Icons.table_chart),
//                                 label: const Text('Excel'),
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green),
//                               ),
//                             ]),
//                         const SizedBox(height: 12),
//                         Text('Report loaded successfully! ($rateField)',
//                             style: const TextStyle(
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.bold)),
//                       ] else
//                         const Text('No data found.',
//                             style: TextStyle(color: Colors.orange)),
//                     ],
//                   );
//                 }
//                 return const Text('Tap Filter to load data');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _productDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
//         builder: (_, s) => s is FilterOptionsLoaded
//             ? DropdownButtonFormField<ProductData>(
//                 initialValue: product,
//                 hint: const Text('All Products'),
//                 decoration: const InputDecoration(
//                     labelText: 'Product', border: OutlineInputBorder()),
//                 items: [
//                   const DropdownMenuItem(
//                       value: null, child: Text('All Products')),
//                   ...s.products.map(
//                       (p) => DropdownMenuItem(value: p, child: Text(p.name)))
//                 ],
//                 onChanged: (v) => setState(() {
//                   product = v;
//                   if (v != null) category = null;
//                 }),
//               )
//             : const LinearProgressIndicator(),
//       );

//   Widget _categoryDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
//         builder: (_, s) => s is FilterOptionsLoaded
//             ? DropdownButtonFormField<CategoryData>(
//                 initialValue: category,
//                 hint: const Text('All Categories'),
//                 decoration: const InputDecoration(
//                     labelText: 'Category', border: OutlineInputBorder()),
//                 items: [
//                   const DropdownMenuItem(
//                       value: null, child: Text('All Categories')),
//                   ...s.categories.map(
//                       (c) => DropdownMenuItem(value: c, child: Text(c.name)))
//                 ],
//                 onChanged: (v) => setState(() {
//                   category = v;
//                   if (v != null) product = null;
//                 }),
//               )
//             : const SizedBox(),
//       );

//   Widget _rateDropdown() => DropdownButtonFormField<String>(
//         initialValue: rateField,
//         decoration: const InputDecoration(
//             labelText: 'Balance Rate Field', border: OutlineInputBorder()),
//         items: ['Cost Price', 'Selling Price']
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//         onChanged: (v) {
//           setState(() {
//             rateField = v!;
//             rateType = v == 'Cost Price' ? 'cost' : 'selling';
//           });
//         },
//       );

//   Widget _dateField(bool isStart) => InkWell(
//         onTap: () async {
//           final d = await showDatePicker(
//             context: context,
//             initialDate: isStart ? start : end,
//             firstDate: DateTime(2020),
//             lastDate: DateTime(2030),
//           );
//           if (d != null) setState(() => isStart ? start = d : end = d);
//         },
//         child: InputDecorator(
//           decoration: InputDecoration(
//             labelText: isStart ? 'Start Date' : 'End Date',
//             border: const OutlineInputBorder(),
//           ),
//           child: Text(DateFormat('MM/dd/yyyy').format(isStart ? start : end)),
//         ),
//       );
// }
// lib/screen/reports/stock_ledger_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_category_response.dart';
import 'package:saleup_app/model/stock_ledger_response.dart';
import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_bloc.dart';
import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_event.dart';
import 'package:saleup_app/screen/stockLedger/bloc/stock_ledger_state.dart';
import 'package:saleup_app/services/report_service.dart';

class StockLedgerScreen extends StatelessWidget {
  const StockLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockLedgerBloc(
        reportService: ReportService(dioClient: DioClient()),
      )..add(InitializeStockLedger()),
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

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  void _filter() {
    if (startDate == null || endDate == null) return;
    context.read<StockLedgerBloc>().add(FetchStockLedgerReport(
          startDate: _fmt(startDate!),
          endDate: _fmt(endDate!),
          productId: selectedProduct?.id,
          categoryId: selectedCategory?.id,
          rateType: rateType,
        ));
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
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        title: const Text('Stock Ledger',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E), // Deep Blue
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
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
            setState(() {
              startDate = state.defaultStartDate;
              endDate = state.defaultEndDate;
              _products = state.products;
              _categories = state.categories;
            });
          }
        },
        builder: (context, state) {
          if (state is StockLedgerSuccess) {
            _products = state.products;
            _categories = state.categories;
          }

          return Column(
            children: [
              _buildCompactFilters(state),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  COMPACT HORIZONTAL FILTERS
  // ═══════════════════════════════════════════════════════
  Widget _buildCompactFilters(StockLedgerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: Colors.white,
      child: Column(
        children: [
          // Row 1: Dates & Dropdowns
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _compactDateChip(
                    Icons.calendar_today,
                    startDate != null
                        ? DateFormat('dd MMM yy').format(startDate!)
                        : 'Start',
                    true),
                const SizedBox(width: 8),
                _compactDateChip(
                    Icons.calendar_today,
                    endDate != null
                        ? DateFormat('dd MMM yy').format(endDate!)
                        : 'End',
                    false),
                const SizedBox(width: 8),
                _compactFilterChip(
                    Icons.category,
                    selectedCategory?.name ?? 'Category',
                    () => _showFilterBottomSheet()),
                const SizedBox(width: 8),
                _compactFilterChip(
                    Icons.inventory_2,
                    selectedProduct?.name ?? 'Product',
                    () => _showFilterBottomSheet()),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Row 2: Action Buttons
          Row(
            children: [
              ChoiceChip(
                label: const Text('Cost'),
                selected: rateType == 'cost',
                onSelected: (v) => setState(() => rateType = 'cost'),
                selectedColor: const Color(0xFF1A237E).withOpacity(0.1),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Selling'),
                selected: rateType == 'selling',
                onSelected: (v) => setState(() => rateType = 'selling'),
                selectedColor: const Color(0xFF1A237E).withOpacity(0.1),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed:
                    (startDate != null && endDate != null) ? _filter : null,
                icon: const Icon(Icons.filter_alt, size: 16),
                label: const Text('Apply'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _compactDateChip(IconData icon, String text, bool isStart) {
    return ActionChip(
      avatar: Icon(icon, size: 14, color: const Color(0xFF1A237E)),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      onPressed: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) setState(() => isStart ? startDate = d : endDate = d);
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _compactFilterChip(IconData icon, String text, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 14, color: const Color(0xFF1A237E)),
      label: Text(text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300)),
    );
  }

  // Bottom sheet for better Product/Category selection
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CategoryData>(
                    value: selectedCategory,
                    hint: const Text('All Categories'),
                    decoration: const InputDecoration(
                        labelText: 'Category', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Categories')),
                      ..._categories.map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.name)))
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedCategory = v;
                        if (v != null) selectedProduct = null;
                      });
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ProductData>(
                    value: selectedProduct,
                    hint: const Text('All Products'),
                    decoration: const InputDecoration(
                        labelText: 'Product', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Products')),
                      ..._products.map((p) =>
                          DropdownMenuItem(value: p, child: Text(p.name)))
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedProduct = v;
                        if (v != null) selectedCategory = null;
                      });
                      setModalState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════
  //  BODY & PREMIUM TABLE
  // ═══════════════════════════════════════════════════════
  Widget _buildBody(StockLedgerState state) {
    if (state is StockLedgerLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A237E)));
    }
    if (state is StockLedgerFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                  onPressed: _filter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (state is StockLedgerSuccess) {
      final accounts = state.report.data ?? [];
      if (accounts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('No records found',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }

      // ★ THE FIX: Expanded Table with proper scroll physics
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            final entry = account.ledger?.firstOrNull;
            final isEven = index % 2 == 0;
            final isNegativeClosing = (entry?.closing ?? 0) < 0;

            return Container(
              color: isEven ? Colors.white : const Color(0xFFF1F3F5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name Header
                  Text(account.productName ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  // Data Grid
                  Row(
                    children: [
                      _dataCell(
                          'Opening', (entry?.opening ?? 0).toStringAsFixed(0)),
                      _dataCell(
                          'Purchase', (entry?.purchase ?? 0).toStringAsFixed(0),
                          color: Colors.green),
                      _dataCell('Sales', (entry?.sales ?? 0).toStringAsFixed(0),
                          color: Colors.orange),
                      _dataCell(
                          'Closing', (entry?.closing ?? 0).toStringAsFixed(0),
                          color:
                              isNegativeClosing ? Colors.red : Colors.black87,
                          bold: true),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return const SizedBox();
  }

  // Mobile-friendly data cell
  Widget _dataCell(String label, String value,
      {Color? color, bool bold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: color ?? Colors.black87,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}
