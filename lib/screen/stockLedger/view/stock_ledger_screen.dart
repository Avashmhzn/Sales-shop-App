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

//   void _downloadPdf(StockLedgerReport report) {
//     DioClient().downloadStockLedgerAsPdf(
//       report,
//       DateFormat('dd/MM/yyyy').format(start),
//       DateFormat('dd/MM/yyyy').format(end),
//     );
//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text('PDF Saved!')));
//   }

//   void _downloadExcel(StockLedgerReport report) {
//     DioClient().downloadStockLedgerAsExcel(
//       report,
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

//             // DOWNLOAD BUTTONS
//             BlocBuilder<StockLedgerBloc, StockLedgerState>(
//               builder: (_, state) {
//                 if (state is StockLedgerSuccess) {
//                   final hasData = state.report.data?.isNotEmpty == true;
//                   return Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed:
//                               hasData ? () => _downloadPdf(state.report) : null,
//                           icon: const Icon(Icons.picture_as_pdf),
//                           label: const Text('PDF'),
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red),
//                         ),
//                         const SizedBox(width: 12),
//                         ElevatedButton.icon(
//                           onPressed: hasData
//                               ? () => _downloadExcel(state.report)
//                               : null,
//                           icon: const Icon(Icons.table_chart),
//                           label: const Text('Excel'),
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green),
//                         ),
//                       ]);
//                 }
//                 return const SizedBox();
//               },
//             ),
//             const SizedBox(height: 20),

//             // TABLE TITLE
//             const Text('Stock Ledger Data',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),

//             // TABLE
//             SizedBox(
//               height: 400,
//               child: BlocBuilder<StockLedgerBloc, StockLedgerState>(
//                 builder: (_, state) {
//                   if (state is StockLedgerLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (state is StockLedgerFailure) {
//                     return Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(state.message,
//                               style: const TextStyle(color: Colors.red)),
//                           const SizedBox(height: 12),
//                           ElevatedButton.icon(
//                             onPressed: filter,
//                             icon: const Icon(Icons.refresh),
//                             label: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                   if (state is StockLedgerSuccess &&
//                       state.report.data?.isNotEmpty == true) {
//                     final entries = state.report.data!.first.ledger!;
//                     final name = product?.name ?? category?.name ?? 'All';
//                     return SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         columns: const [
//                           DataColumn(label: Text('Date')),
//                           DataColumn(label: Text('Product')),
//                           DataColumn(label: Text('Open')),
//                           DataColumn(label: Text('In')),
//                           DataColumn(label: Text('Out')),
//                           DataColumn(label: Text('Close')),
//                           DataColumn(label: Text('Rate')),
//                         ],
//                         rows: entries
//                             .map((e) => DataRow(cells: [
//                                   DataCell(
//                                       Text(e.date?.split('T').first ?? '')),
//                                   DataCell(Text(name)),
//                                   DataCell(Text(
//                                       e.opening?.toStringAsFixed(2) ?? '0.00')),
//                                   DataCell(Text(
//                                       e.purchase?.toStringAsFixed(2) ??
//                                           '0.00')),
//                                   DataCell(Text(
//                                       e.sales?.toStringAsFixed(2) ?? '0.00')),
//                                   DataCell(Text(
//                                       e.closing?.toStringAsFixed(2) ?? '0.00')),
//                                   DataCell(Text(rateField == 'Cost Price'
//                                       ? e.costPrice?.toStringAsFixed(2) ??
//                                           '0.00'
//                                       : e.sellingPrice?.toStringAsFixed(2) ??
//                                           '0.00')),
//                                 ]))
//                             .toList(),
//                       ),
//                     );
//                   }
//                   return const Center(child: Text('Tap Filter to load data'));
//                 },
//               ),
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/product_category_response.dart';
import 'package:saleup_app/model/stock_ledger_response.dart';
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

  void filter() {
    final from = DateFormat('yyyy-MM-dd').format(start);
    final to = DateFormat('yyyy-MM-dd').format(end);

    context.read<StockLedgerBloc>().add(FetchStockLedgerReport(
          startDate: from,
          endDate: to,
          productId: product?.id,
          categoryId: category?.id,
        ));
  }

  void reset() {
    setState(() {
      product = null;
      category = null;
      start = DateTime.now().subtract(const Duration(days: 30));
      end = DateTime.now();
      rateField = 'Cost Price';
    });
  }

  void _downloadPdf(StockLedgerReport report) {
    DioClient().downloadStockLedgerAsPdf(
      report,
      DateFormat('dd/MM/yyyy').format(start),
      DateFormat('dd/MM/yyyy').format(end),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('PDF Saved!')));
  }

  void _downloadExcel(StockLedgerReport report) {
    DioClient().downloadStockLedgerAsExcel(
      report,
      DateFormat('dd/MM/yyyy').format(start),
      DateFormat('dd/MM/yyyy').format(end),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Excel Saved!')));
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
            // ROW 1
            Row(children: [
              Expanded(child: _productDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _categoryDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _rateDropdown()),
            ]),
            const SizedBox(height: 16),

            // ROW 2
            Row(children: [
              Expanded(child: _dateField(true)),
              const SizedBox(width: 12),
              Expanded(child: _dateField(false)),
            ]),
            const SizedBox(height: 16),

            // ROW 3
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton.icon(
                onPressed:
                    (product != null || category != null) ? filter : null,
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

            // DOWNLOAD BUTTONS
            BlocBuilder<StockLedgerBloc, StockLedgerState>(
              builder: (_, state) {
                if (state is StockLedgerSuccess) {
                  final hasData = state.report.data?.isNotEmpty == true;
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              hasData ? () => _downloadPdf(state.report) : null,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: hasData
                              ? () => _downloadExcel(state.report)
                              : null,
                          icon: const Icon(Icons.table_chart),
                          label: const Text('Excel'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
                      ]);
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 20),

            // TABLE TITLE
            const Text('Stock Ledger Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // TABLE
            SizedBox(
              height: 400,
              child: BlocBuilder<StockLedgerBloc, StockLedgerState>(
                builder: (_, state) {
                  if (state is StockLedgerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is StockLedgerFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: filter,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is StockLedgerSuccess &&
                      state.report.data?.isNotEmpty == true) {
                    final entries = state.report.data!.first.ledger!;
                    final name = product?.name ?? category?.name ?? 'All';
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Product')),
                          DataColumn(label: Text('Open')),
                          DataColumn(label: Text('In')),
                          DataColumn(label: Text('Out')),
                          DataColumn(label: Text('Close')),
                          DataColumn(label: Text('Rate')),
                        ],
                        rows: entries
                            .map((e) => DataRow(cells: [
                                  DataCell(
                                      Text(e.date?.split('T').first ?? '')),
                                  DataCell(Text(name)),
                                  DataCell(Text(
                                      e.opening?.toStringAsFixed(2) ?? '0.00')),
                                  DataCell(Text(
                                      e.purchase?.toStringAsFixed(2) ??
                                          '0.00')),
                                  DataCell(Text(
                                      e.sales?.toStringAsFixed(2) ?? '0.00')),
                                  DataCell(Text(
                                      e.closing?.toStringAsFixed(2) ?? '0.00')),
                                  DataCell(Text(rateField == 'Cost Price'
                                      ? e.costPrice?.toStringAsFixed(2) ??
                                          '0.00'
                                      : e.sellingPrice?.toStringAsFixed(2) ??
                                          '0.00')),
                                ]))
                            .toList(),
                      ),
                    );
                  }
                  return const Center(child: Text('Tap Filter to load data'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DROPDOWNS & DATE PICKERS
  Widget _productDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
        builder: (_, s) => s is FilterOptionsLoaded
            ? DropdownButtonFormField<ProductData>(
                initialValue: product,
                hint: const Text('Select Product'),
                decoration: const InputDecoration(
                    labelText: 'Product', border: OutlineInputBorder()),
                items: s.products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (v) => setState(() {
                  product = v;
                  category = null;
                }),
              )
            : const LinearProgressIndicator(),
      );

  Widget _categoryDropdown() => BlocBuilder<StockLedgerBloc, StockLedgerState>(
        builder: (_, s) => s is FilterOptionsLoaded
            ? DropdownButtonFormField<CategoryData>(
                initialValue: category,
                hint: const Text('None'),
                decoration: const InputDecoration(
                    labelText: 'Category', border: OutlineInputBorder()),
                items: s.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() {
                  category = v;
                  product = null;
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
        onChanged: (v) => setState(() => rateField = v!),
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
            hintText: 'mm/dd/yyyy',
            border: const OutlineInputBorder(),
          ),
          child: Text(DateFormat('MM/dd/yyyy').format(isStart ? start : end)),
        ),
      );
}
