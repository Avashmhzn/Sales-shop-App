// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_category_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';
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

//   void filter() {
//     final from = DateFormat('yyyy-MM-dd').format(start);
//     final to = DateFormat('yyyy-MM-dd').format(end);

//     context.read<StockLedgerBloc>().add(FetchStockLedgerReport(
//           startDate: from,
//           endDate: to,
//           productId: product?.id,
//           categoryId: category?.id,
//         ));
//   }

//   void reset() {
//     setState(() {
//       product = null;
//       category = null;
//       start = DateTime.now().subtract(const Duration(days: 30));
//       end = DateTime.now();
//       rateField = 'Cost Price';
//     });
//   }

//   void _downloadPdf(Map<String, dynamic> rawJson) {
//     DioClient().downloadStockLedgerAsPdf(
//       rawJson,
//       DateFormat('dd/MM/yyyy').format(start),
//       DateFormat('dd/MM/yyyy').format(end),
//     );

//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text('PDF Saved!')));
//   }

//   void _downloadExcel(Map<String, dynamic> rawJson) {
//     DioClient().downloadStockLedgerAsExcel(
//       rawJson,
//       DateFormat('dd/MM/yyyy').format(start),
//       DateFormat('dd/MM/yyyy').format(end),
//     );

//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text('Excel Saved!')));
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
//             // ROW 1
//             Row(children: [
//               Expanded(child: _productDropdown()),
//               const SizedBox(width: 12),
//               Expanded(child: _categoryDropdown()),
//               const SizedBox(width: 12),
//               Expanded(child: _rateDropdown()),
//             ]),
//             const SizedBox(height: 16),

//             // ROW 2
//             Row(children: [
//               Expanded(child: _dateField(true)),
//               const SizedBox(width: 12),
//               Expanded(child: _dateField(false)),
//             ]),
//             const SizedBox(height: 16),

//             // ROW 3
//             Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//               ElevatedButton.icon(
//                 onPressed:
//                     (product != null || category != null) ? filter : null,
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

//             // DOWNLOAD BUTTONS + SUCCESS MESSAGE
//             BlocBuilder<StockLedgerBloc, StockLedgerState>(
//               builder: (_, state) {
//                 if (state is StockLedgerLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (state is StockLedgerFailure) {
//                   return Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(state.message,
//                             style: const TextStyle(color: Colors.red)),
//                         const SizedBox(height: 12),
//                         ElevatedButton.icon(
//                           onPressed: filter,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 if (state is StockLedgerSuccess) {
//                   final hasData = state.rawJson['data'] != null &&
//                       (state.rawJson['data'] as Map).isNotEmpty;

//                   return Column(
//                     children: [
//                       if (hasData) ...[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             ElevatedButton.icon(
//                               onPressed: () => _downloadPdf(state.rawJson),
//                               icon: const Icon(Icons.picture_as_pdf),
//                               label: const Text('PDF'),
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red),
//                             ),
//                             const SizedBox(width: 12),
//                             ElevatedButton.icon(
//                               onPressed: () => _downloadExcel(state.rawJson),
//                               icon: const Icon(Icons.table_chart),
//                               label: const Text('Excel'),
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.green),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         const Text(
//                           'Report generated successfully!',
//                           style: TextStyle(
//                               color: Colors.green, fontWeight: FontWeight.bold),
//                         ),
//                       ] else
//                         const Text(
//                           'No data found for the selected filters.',
//                           style: TextStyle(color: Colors.orange),
//                         ),
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

//   // DROPDOWNS & DATE PICKERS
//   Widget _productDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
//         builder: (_, s) => s is FilterOptionsLoaded
//             ? DropdownButtonFormField<ProductData>(
//                 value: product,
//                 hint: const Text('Select Product'),
//                 decoration: const InputDecoration(
//                     labelText: 'Product', border: OutlineInputBorder()),
//                 items: s.products
//                     .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
//                     .toList(),
//                 onChanged: (v) => setState(() {
//                   product = v;
//                   category = null;
//                 }),
//               )
//             : const LinearProgressIndicator(),
//       );

//   Widget _categoryDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
//         builder: (_, s) => s is FilterOptionsLoaded
//             ? DropdownButtonFormField<CategoryData>(
//                 value: category,
//                 hint: const Text('None'),
//                 decoration: const InputDecoration(
//                     labelText: 'Category', border: OutlineInputBorder()),
//                 items: s.categories
//                     .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
//                     .toList(),
//                 onChanged: (v) => setState(() {
//                   category = v;
//                   product = null;
//                 }),
//               )
//             : const SizedBox(),
//       );

//   Widget _rateDropdown() => DropdownButtonFormField<String>(
//         value: rateField,
//         decoration: const InputDecoration(
//             labelText: 'Balance Rate Field', border: OutlineInputBorder()),
//         items: ['Cost Price', 'Selling Price']
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//         onChanged: (v) => setState(() => rateField = v!),
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
//             hintText: 'mm/dd/yyyy',
//             border: const OutlineInputBorder(),
//           ),
//           child: Text(DateFormat('MM/dd/yyyy').format(isStart ? start : end)),
//         ),
//       );
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/product_category_response.dart';
// import 'package:saleup_app/model/stock_ledger_response.dart';
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
//   String rateField = 'Cost Price'; // UI Label
//   String rateType = 'cost'; // Internal: 'cost' or 'selling'

//   void filter() {
//     final from = DateFormat('yyyy-MM-dd').format(start);
//     final to = DateFormat('yyyy-MM-dd').format(end);

//     context.read<StockLedgerBloc>().add(FetchStockLedgerReport(
//           startDate: from,
//           endDate: to,
//           productId: product?.id,
//           categoryId: category?.id,
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
//   }

//   void _downloadPdf(Map<String, dynamic> rawJson) {
//     DioClient().downloadStockLedgerAsPdf(
//       rawJson,
//       DateFormat('dd/MM/yyyy').format(start),
//       DateFormat('dd/MM/yyyy').format(end),
//       rateType, // FIXED: Added missing argument
//     );

//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text('PDF Saved!')));
//   }

//   void _downloadExcel(Map<String, dynamic> rawJson) {
//     DioClient().downloadStockLedgerAsExcel(
//       rawJson,
//       DateFormat('dd/MM/yyyy').format(start),
//       DateFormat('dd/MM/yyyy').format(end),
//       rateType, // FIXED: Added missing argument
//     );

//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text('Excel Saved!')));
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
//             // ROW 1
//             Row(children: [
//               Expanded(child: _productDropdown()),
//               const SizedBox(width: 12),
//               Expanded(child: _categoryDropdown()),
//               const SizedBox(width: 12),
//               Expanded(child: _rateDropdown()),
//             ]),
//             const SizedBox(height: 16),

//             // ROW 2
//             Row(children: [
//               Expanded(child: _dateField(true)),
//               const SizedBox(width: 12),
//               Expanded(child: _dateField(false)),
//             ]),
//             const SizedBox(height: 16),

//             // ROW 3
//             Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//               ElevatedButton.icon(
//                 onPressed:
//                     (product != null || category != null) ? filter : null,
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

//             // DOWNLOAD BUTTONS + SUCCESS MESSAGE
//             BlocBuilder<StockLedgerBloc, StockLedgerState>(
//               builder: (_, state) {
//                 if (state is StockLedgerLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (state is StockLedgerFailure) {
//                   return Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(state.message,
//                             style: const TextStyle(color: Colors.red)),
//                         const SizedBox(height: 12),
//                         ElevatedButton.icon(
//                           onPressed: filter,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 if (state is StockLedgerSuccess) {
//                   final hasData = state.rawJson['data'] != null &&
//                       (state.rawJson['data'] as Map).isNotEmpty;

//                   return Column(
//                     children: [
//                       if (hasData) ...[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             ElevatedButton.icon(
//                               onPressed: () => _downloadPdf(state.rawJson),
//                               icon: const Icon(Icons.picture_as_pdf),
//                               label: const Text('PDF'),
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red),
//                             ),
//                             const SizedBox(width: 12),
//                             ElevatedButton.icon(
//                               onPressed: () => _downloadExcel(state.rawJson),
//                               icon: const Icon(Icons.table_chart),
//                               label: const Text('Excel'),
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.green),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           'Report generated successfully! ($rateField)',
//                           style: const TextStyle(
//                               color: Colors.green, fontWeight: FontWeight.bold),
//                         ),
//                       ] else
//                         const Text(
//                           'No data found for the selected filters.',
//                           style: TextStyle(color: Colors.orange),
//                         ),
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

//   // DROPDOWNS & DATE PICKERS
//   Widget _productDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
//         builder: (_, s) => s is FilterOptionsLoaded
//             ? DropdownButtonFormField<ProductData>(
//                 initialValue: product,
//                 hint: const Text('Select Product'),
//                 decoration: const InputDecoration(
//                     labelText: 'Product', border: OutlineInputBorder()),
//                 items: s.products
//                     .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
//                     .toList(),
//                 onChanged: (v) => setState(() {
//                   product = v;
//                   category = null;
//                 }),
//               )
//             : const LinearProgressIndicator(),
//       );

//   Widget _categoryDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
//         builder: (_, s) => s is FilterOptionsLoaded
//             ? DropdownButtonFormField<CategoryData>(
//                 initialValue: category,
//                 hint: const Text('None'),
//                 decoration: const InputDecoration(
//                     labelText: 'Category', border: OutlineInputBorder()),
//                 items: s.categories
//                     .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
//                     .toList(),
//                 onChanged: (v) => setState(() {
//                   category = v;
//                   product = null;
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
//             rateType = v == 'Cost Price' ? 'cost' : 'selling'; // Sync
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
//             hintText: 'mm/dd/yyyy',
//             border: const OutlineInputBorder(),
//           ),
//           child: Text(DateFormat('MM/dd/yyyy').format(isStart ? start : end)),
//         ),
//       );
// }
// lib/screen/stock_ledger/stock_ledger_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_category_response.dart';
import '../bloc/stock_ledger_bloc.dart';
import '../bloc/stock_ledger_event.dart';
import '../bloc/stock_ledger_state.dart';

class StockLedgerScreen extends StatelessWidget {
  const StockLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StockLedgerBloc(dioClient: DioClient())..add(FetchFilterOptions()),
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
  DateTime start = DateTime.now().subtract(const Duration(days: 30));
  DateTime end = DateTime.now();
  ProductData? product;
  CategoryData? category;
  String rateField = 'Cost Price';
  String rateType = 'cost'; // 'cost' or 'selling'

  @override
  void initState() {
    super.initState();
    // Auto load last 30 days like web
    Future.delayed(Duration.zero, () {
      filter();
    });
  }

  void filter() {
    final from = DateFormat('yyyy-MM-dd').format(start);
    final to = DateFormat('yyyy-MM-dd').format(end);

    context.read<StockLedgerBloc>().add(FetchStockLedgerReport(
          startDate: from,
          endDate: to,
          productId: product?.id,
          categoryId: category?.id,
          rateType: rateType,
        ));
  }

  void reset() {
    setState(() {
      product = null;
      category = null;
      start = DateTime.now().subtract(const Duration(days: 30));
      end = DateTime.now();
      rateField = 'Cost Price';
      rateType = 'cost';
    });
    filter();
  }

  void _downloadPdf(Map<String, dynamic> rawJson) {
    DioClient().downloadStockLedgerAsPdf(
      rawJson,
      DateFormat('dd/MM/yyyy').format(start),
      DateFormat('dd/MM/yyyy').format(end),
      rateType,
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('PDF Downloaded!')));
  }

  void _downloadExcel(Map<String, dynamic> rawJson) {
    DioClient().downloadStockLedgerAsExcel(
      rawJson,
      DateFormat('dd/MM/yyyy').format(start),
      DateFormat('dd/MM/yyyy').format(end),
      rateType,
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Excel Downloaded!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Ledger',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _productDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _categoryDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _rateDropdown()),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _dateField(true)),
              const SizedBox(width: 12),
              Expanded(child: _dateField(false)),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton.icon(
                onPressed: filter,
                icon: const Icon(Icons.filter_alt),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700]),
              ),
              ElevatedButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print),
                label: const Text('Print'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
              ),
            ]),
            const SizedBox(height: 20),
            BlocBuilder<StockLedgerBloc, StockLedgerState>(
              builder: (_, state) {
                if (state is StockLedgerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is StockLedgerFailure) {
                  return Center(
                    child: Column(
                      children: [
                        Text(state.message,
                            style: const TextStyle(color: Colors.red)),
                        ElevatedButton.icon(
                            onPressed: filter,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry')),
                      ],
                    ),
                  );
                }
                if (state is StockLedgerSuccess) {
                  final hasData = state.report.data?.isNotEmpty ?? false;
                  return Column(
                    children: [
                      if (hasData) ...[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _downloadPdf(state.rawJson),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('PDF'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => _downloadExcel(state.rawJson),
                                icon: const Icon(Icons.table_chart),
                                label: const Text('Excel'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                              ),
                            ]),
                        const SizedBox(height: 12),
                        Text('Report loaded successfully! ($rateField)',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ] else
                        const Text('No data found.',
                            style: TextStyle(color: Colors.orange)),
                    ],
                  );
                }
                return const Text('Tap Filter to load data');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _productDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
        builder: (_, s) => s is FilterOptionsLoaded
            ? DropdownButtonFormField<ProductData>(
                initialValue: product,
                hint: const Text('All Products'),
                decoration: const InputDecoration(
                    labelText: 'Product', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Products')),
                  ...s.products.map(
                      (p) => DropdownMenuItem(value: p, child: Text(p.name)))
                ],
                onChanged: (v) => setState(() {
                  product = v;
                  if (v != null) category = null;
                }),
              )
            : const LinearProgressIndicator(),
      );

  Widget _categoryDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
        builder: (_, s) => s is FilterOptionsLoaded
            ? DropdownButtonFormField<CategoryData>(
                initialValue: category,
                hint: const Text('All Categories'),
                decoration: const InputDecoration(
                    labelText: 'Category', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Categories')),
                  ...s.categories.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c.name)))
                ],
                onChanged: (v) => setState(() {
                  category = v;
                  if (v != null) product = null;
                }),
              )
            : const SizedBox(),
      );

  Widget _rateDropdown() => DropdownButtonFormField<String>(
        initialValue: rateField,
        decoration: const InputDecoration(
            labelText: 'Balance Rate Field', border: OutlineInputBorder()),
        items: ['Cost Price', 'Selling Price']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          setState(() {
            rateField = v!;
            rateType = v == 'Cost Price' ? 'cost' : 'selling';
          });
        },
      );

  Widget _dateField(bool isStart) => InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: isStart ? start : end,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (d != null) setState(() => isStart ? start = d : end = d);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: isStart ? 'Start Date' : 'End Date',
            border: const OutlineInputBorder(),
          ),
          child: Text(DateFormat('MM/dd/yyyy').format(isStart ? start : end)),
        ),
      );
}
