// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/model/sale_response.dart' as sale_response;
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_bloc.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_state.dart';
// import 'package:saleup_app/screen/dashboard/widget/dashboard_card.dart';

// // ------------------------- CHART PANEL -------------------------
// class ChartPanel extends StatefulWidget {
//   const ChartPanel({super.key});

//   @override
//   _ChartPanelState createState() => _ChartPanelState();
// }

// class _ChartPanelState extends State<ChartPanel> {
//   double getInterval(double maxY) {
//     if (maxY <= 0) return 1;
//     if (maxY <= 10) return 2;
//     if (maxY <= 50) return 10;
//     if (maxY <= 100) return 20;
//     if (maxY <= 1000) return 100;
//     if (maxY <= 10000) return 1000;
//     return maxY / 5;
//   }

//   // State to track visibility of bar chart items
//   final Map<String, bool> _barVisibility = {};
//   // State to track visibility of purchase vs returns pie chart items
//   final Map<String, bool> _purchaseVsReturnsVisibility = {};
//   // State to track visibility of return reasons pie chart items
//   final Map<String, bool> _returnReasonsVisibility = {};

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final state = context.watch<DashboardBloc>().state;
//     if (state.salesData != null && state.salesData!.data != null) {
//       for (var saleJson in state.salesData!.data) {
//         final sale =
//             sale_response.SaleData.fromJson(saleJson as Map<String, dynamic>);
//         for (var item in sale.items) {
//           final productId = item.product.toString();
//           _barVisibility[productId] = true; // Initialize all as visible
//         }
//       }
//     }
//     _purchaseVsReturnsVisibility.addAll({
//       'Purchases': true,
//       'Purchase Returns': true,
//       'Sales': true,
//       'Sales Returns': true,
//     });
//     _returnReasonsVisibility.addAll(context
//             .watch<DashboardBloc>()
//             .state
//             .returnReasons
//             ?.map((key, value) => MapEntry(key, true)) ??
//         {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<DashboardBloc, DashboardState>(
//       buildWhen: (previous, current) =>
//           previous.isLoading != current.isLoading ||
//           previous.errorMessage != current.errorMessage ||
//           previous.quantitySold != current.quantitySold ||
//           previous.totalPurchases != current.totalPurchases ||
//           previous.purchaseReturns != current.purchaseReturns ||
//           previous.totalSales != current.totalSales ||
//           previous.salesReturns != current.salesReturns ||
//           previous.salesData != current.salesData ||
//           previous.returnReasons != current.returnReasons,
//       builder: (context, state) {
//         if (state.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (state.errorMessage != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline,
//                     size: 48, color: Color(0xFF971313)),
//                 const SizedBox(height: 16),
//                 Text(
//                   state.errorMessage!,
//                   style:
//                       const TextStyle(color: Color(0xFF65636D), fontSize: 16),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF10750E)),
//                   onPressed: () => context
//                       .read<DashboardBloc>()
//                       .add(const FetchDashboardData()),
//                   child: const Text('Retry',
//                       style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Define colors
//         final List<Color> chartColors = [
//           const Color(0xFFF59422),
//           const Color(0xFFFBBF24),
//           const Color(0xFFFCD34D),
//           const Color(0xFFFDE047),
//         ];

//         // Product data from /sale/get_sales/ response in state
//         Map<String, double> productData = {};
//         if (state.salesData != null && state.salesData!.data != null) {
//           for (var saleJson in state.salesData!.data) {
//             final sale = sale_response.SaleData.fromJson(
//                 saleJson as Map<String, dynamic>);
//             for (var item in sale.items) {
//               final productId = item.product.toString();
//               productData[productId] = (productData[productId] ?? 0) +
//                   (item.quantity?.toDouble() ?? 0.0);
//             }
//           }
//         }

//         // Totals from state
//         final totalPurchases = state.totalPurchases ?? 0.0;
//         final purchaseReturns = state.purchaseReturns ?? 0.0;
//         final totalSales = state.totalSales ?? 0.0;
//         final salesReturns = state.salesReturns ?? 0.0;

//         // Dynamic return reasons from state
//         final returnReasons = state.returnReasons ?? {};
//         final pieChartTotal = returnReasons.values.isNotEmpty
//             ? returnReasons.values.reduce((a, b) => a + b)
//             : 0.0;
//         print('Pie Chart Total: $pieChartTotal, Sales Returns: $salesReturns');

//         // Data for Purchase vs Returns pie chart
//         final purchaseVsReturnsData = {
//           'Purchases': totalPurchases,
//           'Purchase Returns': purchaseReturns,
//           'Sales': totalSales,
//           'Sales Returns': salesReturns,
//         };

//         // Check if any purchaseVsReturnsData values are non-zero
//         final hasPurchaseData =
//             purchaseVsReturnsData.values.any((value) => value > 0);

//         // Calculate total for Purchase vs Returns with fallback
//         final purchaseVsReturnsTotal = hasPurchaseData
//             ? purchaseVsReturnsData.values
//                 .where((value) => value > 0)
//                 .reduce((a, b) => a + b)
//             : 0.0;

//         // Get screen size for clamping tooltip position
//         final screenSize = MediaQuery.of(context).size;

//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // First Bar Chart: Product Sales Volume
//               Container(
//                 margin: const EdgeInsets.all(8.0),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFAF5F9),
//                   borderRadius: BorderRadius.circular(12.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Product Sales Volume',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF65636D),
//                       ),
//                     ),
//                     const Text(
//                       'Quantity of products sold',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF65636D),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     SizedBox(
//                       height: 300,
//                       child: BarChart(
//                         BarChartData(
//                           maxY: productData.isNotEmpty
//                               ? (productData.values
//                                           .reduce((a, b) => a > b ? a : b) *
//                                       1.1)
//                                   .clamp(0.0, 2.2)
//                               : 2.0,
//                           minY: 0,
//                           gridData: FlGridData(
//                             show: true,
//                             drawVerticalLine: false,
//                             horizontalInterval: 0.2,
//                             getDrawingHorizontalLine: (value) => FlLine(
//                               color: const Color(0xFF65636D).withOpacity(0.2),
//                               strokeWidth: 1,
//                             ),
//                           ),
//                           titlesData: FlTitlesData(
//                             rightTitles: AxisTitles(
//                               sideTitles: const SideTitles(showTitles: false),
//                               axisNameWidget: Container(
//                                 padding: const EdgeInsets.only(right: 8.0),
//                                 alignment: Alignment.centerRight,
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Container(
//                                       width: 12,
//                                       height: 12,
//                                       color: const Color(0xFFF4A261),
//                                     ),
//                                     const SizedBox(width: 4),
//                                     const Text(
//                                       'Quantity Sold',
//                                       style: TextStyle(
//                                         color: Color(0xFF65636D),
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             topTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false)),
//                             bottomTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 reservedSize: 40,
//                                 getTitlesWidget: (value, meta) {
//                                   final products = productData.keys.toList();
//                                   final index = value.toInt();
//                                   if (index < products.length) {
//                                     return Padding(
//                                       padding: const EdgeInsets.only(top: 8.0),
//                                       child: Text(
//                                         products[index],
//                                         style: const TextStyle(
//                                           color: Color(0xFF65636D),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 12,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     );
//                                   }
//                                   return const Text('');
//                                 },
//                               ),
//                             ),
//                             leftTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 interval: 0.2,
//                                 reservedSize: 40,
//                                 getTitlesWidget: (value, meta) {
//                                   return Text(
//                                     value.toStringAsFixed(1),
//                                     style: const TextStyle(
//                                       color: Color(0xFF65636D),
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           borderData: FlBorderData(show: false),
//                           barGroups: productData.entries.map((entry) {
//                             final index =
//                                 productData.keys.toList().indexOf(entry.key);
//                             return BarChartGroupData(
//                               x: index * 1,
//                               barRods: [
//                                 BarChartRodData(
//                                   toY: _barVisibility[entry.key] ?? true
//                                       ? entry.value
//                                       : 0,
//                                   color: const Color(0xFFF4A261),
//                                   width: 30,
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ],
//                             );
//                           }).toList(),
//                           barTouchData: BarTouchData(
//                             enabled: true,
//                             touchTooltipData: BarTouchTooltipData(
//                               getTooltipItem:
//                                   (group, groupIndex, rod, rodIndex) {
//                                 final value = rod.toY;
//                                 return BarTooltipItem(
//                                   '$value',
//                                   const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 );
//                               },
//                               tooltipPadding: const EdgeInsets.all(8),
//                               tooltipMargin: 8,
//                               getTooltipColor: (_) => Colors.grey[700]!,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Wrap(
//                       spacing: 12.0,
//                       runSpacing: 6.0,
//                       children: productData.entries.map((entry) {
//                         final index =
//                             productData.keys.toList().indexOf(entry.key);
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _barVisibility[entry.key] =
//                                   !(_barVisibility[entry.key] ?? true);
//                             });
//                           },
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 width: 16,
//                                 height: 16,
//                                 decoration: BoxDecoration(
//                                   color: _barVisibility[entry.key] ?? true
//                                       ? const Color(0xFFF4A261)
//                                       : Colors.grey,
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 entry.key,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Color(0xFF65636D),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),

//               // Second Pie Chart: Purchase vs Returns Overview
//               Container(
//                 margin: const EdgeInsets.all(8.0),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFAF5F9),
//                   borderRadius: BorderRadius.circular(12.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Purchase vs Returns Overview',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF65636D),
//                       ),
//                     ),
//                     const Text(
//                       'Comparison in Rs.',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF65636D),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     if (hasPurchaseData) ...[
//                       SizedBox(
//                         height: 300,
//                         child: PieChart(
//                           PieChartData(
//                             sectionsSpace: 0,
//                             centerSpaceRadius: 0,
//                             sections: purchaseVsReturnsData.entries
//                                 .toList()
//                                 .asMap()
//                                 .entries
//                                 .where((entry) => entry.value.value > 0)
//                                 .map((entry) {
//                               final index = entry.key;
//                               final value = entry.value.value;
//                               final percentage = purchaseVsReturnsTotal > 0
//                                   ? (value / purchaseVsReturnsTotal * 100)
//                                       .toStringAsFixed(1)
//                                   : '0.0';
//                               return PieChartSectionData(
//                                 color: _purchaseVsReturnsVisibility[
//                                             entry.value.key] ??
//                                         true
//                                     ? chartColors[index % chartColors.length]
//                                     : Colors.grey,
//                                 value: _purchaseVsReturnsVisibility[
//                                             entry.value.key] ??
//                                         true
//                                     ? value
//                                     : 0,
//                                 title: _purchaseVsReturnsVisibility[
//                                             entry.value.key] ??
//                                         true
//                                     ? '$percentage%'
//                                     : '',
//                                 radius: 120,
//                                 titleStyle: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF65636D),
//                                 ),
//                                 showTitle: _purchaseVsReturnsVisibility[
//                                         entry.value.key] ??
//                                     true,
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                     ] else ...[
//                       const SizedBox(
//                         height: 400,
//                         child: Center(
//                           child: Text(
//                             'No purchase or returns data available',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFF65636D),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                     Wrap(
//                       spacing: 12.0,
//                       runSpacing: 6.0,
//                       children: purchaseVsReturnsData.entries
//                           .toList()
//                           .asMap()
//                           .entries
//                           .map((entry) {
//                         final index = entry.key;
//                         final value = entry.value.value;
//                         final percentage = purchaseVsReturnsTotal > 0
//                             ? (value / purchaseVsReturnsTotal * 100)
//                                 .toStringAsFixed(1)
//                             : '0.0';
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _purchaseVsReturnsVisibility[entry.value.key] =
//                                   !(_purchaseVsReturnsVisibility[
//                                           entry.value.key] ??
//                                       true);
//                             });
//                           },
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 width: 16,
//                                 height: 16,
//                                 decoration: BoxDecoration(
//                                   color: _purchaseVsReturnsVisibility[
//                                               entry.value.key] ??
//                                           true
//                                       ? chartColors[index % chartColors.length]
//                                       : Colors.grey,
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 '${entry.value.key} ($percentage%)',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Color(0xFF65636D),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),

//               // Pie Chart: Return Reasons Breakdown
//               Container(
//                 margin: const EdgeInsets.all(8.0),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFAF5F9),
//                   borderRadius: BorderRadius.circular(12.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Return Reasons Breakdown',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF65636D),
//                       ),
//                     ),
//                     const Text(
//                       'Why items are returned',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF65636D),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     if (returnReasons.isNotEmpty) ...[
//                       SizedBox(
//                         height: 360,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               width: double.infinity,
//                               height: 200,
//                               child: PieChart(
//                                 PieChartData(
//                                   sectionsSpace: 0,
//                                   centerSpaceRadius: 0,
//                                   sections: returnReasons.entries.map((entry) {
//                                     final index = returnReasons.keys
//                                         .toList()
//                                         .indexOf(entry.key);
//                                     return PieChartSectionData(
//                                       color:
//                                           _returnReasonsVisibility[entry.key] ??
//                                                   true
//                                               ? chartColors[
//                                                   index % chartColors.length]
//                                               : Colors.grey,
//                                       value:
//                                           _returnReasonsVisibility[entry.key] ??
//                                                   true
//                                               ? 1
//                                               : 0,
//                                       title: '',
//                                       radius: 100,
//                                       showTitle: false,
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Reason',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF65636D),
//                               ),
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: returnReasons.entries.map((entry) {
//                                   final index = returnReasons.keys
//                                           .toList()
//                                           .indexOf(entry.key) %
//                                       chartColors.length;
//                                   return GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         _returnReasonsVisibility[entry.key] =
//                                             !(_returnReasonsVisibility[
//                                                     entry.key] ??
//                                                 true);
//                                       });
//                                     },
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 8.0),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Container(
//                                             width: 16,
//                                             height: 16,
//                                             decoration: BoxDecoration(
//                                               color: _returnReasonsVisibility[
//                                                           entry.key] ??
//                                                       true
//                                                   ? chartColors[index]
//                                                   : Colors.grey,
//                                               borderRadius:
//                                                   BorderRadius.circular(2),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 8),
//                                           Flexible(
//                                             child: Text(
//                                               entry.key,
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 color: Color(0xFF65636D),
//                                               ),
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ] else ...[
//                       const SizedBox(
//                         height: 300,
//                         child: Center(
//                           child: Text(
//                             'No return reasons data available',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFF65636D),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ------------------------- DASHBOARD SCREEN -------------------------
// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => DashboardBloc()..add(const FetchDashboardData()),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFAF5F9),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () => context.go('/chat'),
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           child: const Icon(Icons.chat, color: Colors.white),
//         ),
//         body: BlocListener<DashboardBloc, DashboardState>(
//           listener: (context, state) {
//             if (state.errorMessage != null) {
//               print('DashboardBloc Error: ${state.errorMessage}');
//             }
//           },
//           child: BlocBuilder<DashboardBloc, DashboardState>(
//             buildWhen: (previous, current) =>
//                 previous.isLoading != current.isLoading ||
//                 previous.errorMessage != current.errorMessage ||
//                 previous.totalPurchases != current.totalPurchases ||
//                 previous.totalVatCollected != current.totalVatCollected ||
//                 previous.purchaseReturns != current.purchaseReturns ||
//                 previous.totalSalesTransactions !=
//                     current.totalSalesTransactions ||
//                 previous.totalSales != current.totalSales ||
//                 previous.salesReturns != current.salesReturns,
//             builder: (context, state) {
//               if (state.isLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (state.errorMessage != null) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline,
//                           size: 48, color: Color(0xFF971313)),
//                       const SizedBox(height: 16),
//                       Text(
//                         state.errorMessage!,
//                         style: const TextStyle(
//                             color: Color(0xFF65636D), fontSize: 16),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF10750E)),
//                         onPressed: () => context
//                             .read<DashboardBloc>()
//                             .add(const FetchDashboardData()),
//                         child: const Text('Retry',
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Dashboard',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF65636D),
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             'Overview of your purchases, sales, and returns',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF9E9DA2),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Wrap(
//                         spacing: 1.0,
//                         runSpacing: 1.0,
//                         children: [
//                           DashboardCard(
//                             title: 'Total Purchases',
//                             value:
//                                 'Rs ${state.totalPurchases?.toStringAsFixed(2) ?? '0.00'}',
//                             icon: Icons.shopping_cart,
//                             cardColor: const Color(0xFFFFDAB7),
//                           ),
//                           DashboardCard(
//                             title: 'VAT Collected',
//                             value:
//                                 'Rs ${state.totalVatCollected?.toStringAsFixed(2) ?? '0.00'}',
//                             icon: Icons.money,
//                             cardColor: const Color(0xFFB3CAF6),
//                           ),
//                           DashboardCard(
//                             title: 'Purchase Returns',
//                             value:
//                                 'Rs ${state.purchaseReturns?.toStringAsFixed(2) ?? '0.00'}',
//                             icon: Icons.undo,
//                             cardColor: const Color(0xFFF9D8B7),
//                           ),
//                           DashboardCard(
//                             title: 'Total Sales',
//                             value:
//                                 'Rs ${state.totalSales?.toStringAsFixed(2) ?? '0.00'}',
//                             icon: Icons.trending_up,
//                             cardColor: const Color(0xFFB3CAF6),
//                           ),
//                           DashboardCard(
//                             title: 'Sales Returns',
//                             value:
//                                 'Rs ${state.salesReturns?.toStringAsFixed(2) ?? '0.00'}',
//                             icon: Icons.upload,
//                             cardColor: const Color(0xFFF9D8B7),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const ChartPanel(),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// //new code
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:saleup_app/core/services/day_closing_service.dart';
// import 'package:saleup_app/model/sale_response.dart' as sale_response;
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_bloc.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_state.dart';
// import 'package:saleup_app/screen/dashboard/widget/dashboard_card.dart';

// // ------------------------- CHART PANEL -------------------------
// class ChartPanel extends StatefulWidget {
//   const ChartPanel({super.key});

//   @override
//   _ChartPanelState createState() => _ChartPanelState();
// }

// class _ChartPanelState extends State<ChartPanel> {
//   double getInterval(double maxY) {
//     if (maxY <= 0) return 1;
//     if (maxY <= 10) return 2;
//     if (maxY <= 50) return 10;
//     if (maxY <= 100) return 20;
//     if (maxY <= 1000) return 100;
//     if (maxY <= 10000) return 1000;
//     return maxY / 5;
//   }

//   final Map<String, bool> _barVisibility = {};
//   final Map<String, bool> _purchaseVsReturnsVisibility = {};
//   final Map<String, bool> _returnReasonsVisibility = {};

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final state = context.watch<DashboardBloc>().state;
//     if (state.salesData != null && state.salesData!.data != null) {
//       for (var saleJson in state.salesData!.data) {
//         final sale =
//             sale_response.SaleData.fromJson(saleJson as Map<String, dynamic>);
//         for (var item in sale.items) {
//           final productId = item.product.toString();
//           _barVisibility[productId] = true;
//         }
//       }
//     }
//     _purchaseVsReturnsVisibility.addAll({
//       'Purchases': true,
//       'Purchase Returns': true,
//       'Sales': true,
//       'Sales Returns': true,
//     });
//     _returnReasonsVisibility.addAll(context
//             .watch<DashboardBloc>()
//             .state
//             .returnReasons
//             ?.map((key, value) => MapEntry(key, true)) ??
//         {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<DashboardBloc, DashboardState>(
//       buildWhen: (previous, current) =>
//           previous.isLoading != current.isLoading ||
//           previous.errorMessage != current.errorMessage ||
//           previous.quantitySold != current.quantitySold ||
//           previous.totalPurchases != current.totalPurchases ||
//           previous.purchaseReturns != current.purchaseReturns ||
//           previous.totalSales != current.totalSales ||
//           previous.salesReturns != current.salesReturns ||
//           previous.salesData != current.salesData ||
//           previous.returnReasons != current.returnReasons,
//       builder: (context, state) {
//         if (state.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (state.errorMessage != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline,
//                     size: 48, color: Color(0xFF971313)),
//                 const SizedBox(height: 16),
//                 Text(state.errorMessage!,
//                     style: const TextStyle(
//                         color: Color(0xFF65636D), fontSize: 16)),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF10750E)),
//                   onPressed: () => context
//                       .read<DashboardBloc>()
//                       .add(const FetchDashboardData()),
//                   child: const Text('Retry',
//                       style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           );
//         }

//         final List<Color> chartColors = [
//           const Color(0xFFF59422),
//           const Color(0xFFFBBF24),
//           const Color(0xFFFCD34D),
//           const Color(0xFFFDE047),
//         ];

//         Map<String, double> productData = {};
//         if (state.salesData != null && state.salesData!.data != null) {
//           for (var saleJson in state.salesData!.data) {
//             final sale = sale_response.SaleData.fromJson(
//                 saleJson as Map<String, dynamic>);
//             for (var item in sale.items) {
//               final productId = item.product.toString();
//               productData[productId] = (productData[productId] ?? 0) +
//                   (item.quantity?.toDouble() ?? 0.0);
//             }
//           }
//         }

//         final totalPurchases = state.totalPurchases ?? 0.0;
//         final purchaseReturns = state.purchaseReturns ?? 0.0;
//         final totalSales = state.totalSales ?? 0.0;
//         final salesReturns = state.salesReturns ?? 0.0;

//         final returnReasons = state.returnReasons ?? {};
//         final pieChartTotal = returnReasons.values.isNotEmpty
//             ? returnReasons.values.reduce((a, b) => a + b)
//             : 0.0;

//         final purchaseVsReturnsData = {
//           'Purchases': totalPurchases,
//           'Purchase Returns': purchaseReturns,
//           'Sales': totalSales,
//           'Sales Returns': salesReturns,
//         };

//         final hasPurchaseData =
//             purchaseVsReturnsData.values.any((value) => value > 0);
//         final purchaseVsReturnsTotal = hasPurchaseData
//             ? purchaseVsReturnsData.values
//                 .where((value) => value > 0)
//                 .reduce((a, b) => a + b)
//             : 0.0;

//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Bar Chart
//               Container(
//                 margin: const EdgeInsets.all(8.0),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFAF5F9),
//                   borderRadius: BorderRadius.circular(12.0),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3))
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Product Sales Volume',
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF65636D))),
//                     const Text('Quantity of products sold',
//                         style:
//                             TextStyle(fontSize: 14, color: Color(0xFF65636D))),
//                     const SizedBox(height: 20),
//                     SizedBox(
//                       height: 300,
//                       child: BarChart(
//                         BarChartData(
//                           maxY: productData.isNotEmpty
//                               ? (productData.values
//                                           .reduce((a, b) => a > b ? a : b) *
//                                       1.1)
//                                   .clamp(0.0, 2.2)
//                               : 2.0,
//                           minY: 0,
//                           gridData: FlGridData(
//                               show: true,
//                               drawVerticalLine: false,
//                               horizontalInterval: 0.2,
//                               getDrawingHorizontalLine: (value) => FlLine(
//                                   color:
//                                       const Color(0xFF65636D).withOpacity(0.2),
//                                   strokeWidth: 1)),
//                           titlesData: FlTitlesData(
//                             rightTitles: AxisTitles(
//                                 sideTitles: const SideTitles(showTitles: false),
//                                 axisNameWidget: Container(
//                                   padding: const EdgeInsets.only(right: 8.0),
//                                   alignment: Alignment.centerRight,
//                                   child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Container(
//                                             width: 12,
//                                             height: 12,
//                                             color: const Color(0xFFF4A261)),
//                                         const SizedBox(width: 4),
//                                         const Text('Quantity Sold',
//                                             style: TextStyle(
//                                                 color: Color(0xFF65636D),
//                                                 fontSize: 12)),
//                                       ]),
//                                 )),
//                             topTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false)),
//                             bottomTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                     showTitles: true,
//                                     reservedSize: 40,
//                                     getTitlesWidget: (value, meta) {
//                                       final products =
//                                           productData.keys.toList();
//                                       final index = value.toInt();
//                                       if (index < products.length) {
//                                         return Padding(
//                                             padding:
//                                                 const EdgeInsets.only(top: 8.0),
//                                             child: Text(products[index],
//                                                 style: const TextStyle(
//                                                     color: Color(0xFF65636D),
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 12),
//                                                 textAlign: TextAlign.center));
//                                       }
//                                       return const Text('');
//                                     })),
//                             leftTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                     showTitles: true,
//                                     interval: 0.2,
//                                     reservedSize: 40,
//                                     getTitlesWidget: (value, meta) {
//                                       return Text(value.toStringAsFixed(1),
//                                           style: const TextStyle(
//                                               color: Color(0xFF65636D),
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 12));
//                                     })),
//                           ),
//                           borderData: FlBorderData(show: false),
//                           barGroups: productData.entries.map((entry) {
//                             final index =
//                                 productData.keys.toList().indexOf(entry.key);
//                             return BarChartGroupData(
//                               x: index,
//                               barRods: [
//                                 BarChartRodData(
//                                     toY: _barVisibility[entry.key] ?? true
//                                         ? entry.value
//                                         : 0,
//                                     color: const Color(0xFFF4A261),
//                                     width: 30,
//                                     borderRadius: BorderRadius.circular(4))
//                               ],
//                             );
//                           }).toList(),
//                           barTouchData: BarTouchData(
//                             enabled: true,
//                             touchTooltipData: BarTouchTooltipData(
//                               getTooltipItem:
//                                   (group, groupIndex, rod, rodIndex) =>
//                                       BarTooltipItem(
//                                           '$rod.toY',
//                                           const TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 14)),
//                               tooltipPadding: const EdgeInsets.all(8),
//                               tooltipMargin: 8,
//                               getTooltipColor: (_) => Colors.grey[700]!,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Wrap(
//                       spacing: 12.0,
//                       runSpacing: 6.0,
//                       children: productData.entries.map((entry) {
//                         return GestureDetector(
//                           onTap: () => setState(() =>
//                               _barVisibility[entry.key] =
//                                   !(_barVisibility[entry.key] ?? true)),
//                           child: Row(mainAxisSize: MainAxisSize.min, children: [
//                             Container(
//                                 width: 16,
//                                 height: 16,
//                                 decoration: BoxDecoration(
//                                     color: _barVisibility[entry.key] ?? true
//                                         ? const Color(0xFFF4A261)
//                                         : Colors.grey,
//                                     borderRadius: BorderRadius.circular(2))),
//                             const SizedBox(width: 6),
//                             Text(entry.key,
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF65636D))),
//                           ]),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),

//               // Pie Chart: Purchase vs Returns
//               Container(
//                 margin: const EdgeInsets.all(8.0),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                     color: const Color(0xFFFAF5F9),
//                     borderRadius: BorderRadius.circular(12.0),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.grey.withOpacity(0.3),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset: const Offset(0, 3))
//                     ]),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Purchase vs Returns Overview',
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF65636D))),
//                     const Text('Comparison in Rs.',
//                         style:
//                             TextStyle(fontSize: 14, color: Color(0xFF65636D))),
//                     const SizedBox(height: 20),
//                     if (hasPurchaseData) ...[
//                       SizedBox(
//                         height: 300,
//                         child: PieChart(PieChartData(
//                           sectionsSpace: 0,
//                           centerSpaceRadius: 0,
//                           sections: purchaseVsReturnsData.entries
//                               .toList()
//                               .asMap()
//                               .entries
//                               .where((e) => e.value.value > 0)
//                               .map((e) {
//                             final index = e.key;
//                             final value = e.value.value;
//                             final percentage = purchaseVsReturnsTotal > 0
//                                 ? (value / purchaseVsReturnsTotal * 100)
//                                     .toStringAsFixed(1)
//                                 : '0.0';
//                             return PieChartSectionData(
//                               color:
//                                   _purchaseVsReturnsVisibility[e.value.key] ??
//                                           true
//                                       ? chartColors[index % chartColors.length]
//                                       : Colors.grey,
//                               value:
//                                   _purchaseVsReturnsVisibility[e.value.key] ??
//                                           true
//                                       ? value
//                                       : 0,
//                               title:
//                                   _purchaseVsReturnsVisibility[e.value.key] ??
//                                           true
//                                       ? '$percentage%'
//                                       : '',
//                               radius: 120,
//                               titleStyle: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF65636D)),
//                               showTitle:
//                                   _purchaseVsReturnsVisibility[e.value.key] ??
//                                       true,
//                             );
//                           }).toList(),
//                         )),
//                       ),
//                     ] else ...[
//                       const SizedBox(
//                           height: 400,
//                           child: Center(
//                               child: Text(
//                                   'No purchase or returns data available',
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       color: Color(0xFF65636D))))),
//                     ],
//                     Wrap(
//                       spacing: 12.0,
//                       runSpacing: 6.0,
//                       children: purchaseVsReturnsData.entries
//                           .toList()
//                           .asMap()
//                           .entries
//                           .map((e) {
//                         final index = e.key;
//                         final value = e.value.value;
//                         final percentage = purchaseVsReturnsTotal > 0
//                             ? (value / purchaseVsReturnsTotal * 100)
//                                 .toStringAsFixed(1)
//                             : '0.0';
//                         return GestureDetector(
//                           onTap: () => setState(() =>
//                               _purchaseVsReturnsVisibility[e.value.key] =
//                                   !(_purchaseVsReturnsVisibility[e.value.key] ??
//                                       true)),
//                           child: Row(mainAxisSize: MainAxisSize.min, children: [
//                             Container(
//                                 width: 16,
//                                 height: 16,
//                                 decoration: BoxDecoration(
//                                     color: _purchaseVsReturnsVisibility[
//                                                 e.value.key] ??
//                                             true
//                                         ? chartColors[
//                                             index % chartColors.length]
//                                         : Colors.grey,
//                                     borderRadius: BorderRadius.circular(2))),
//                             const SizedBox(width: 6),
//                             Text('${e.value.key} ($percentage%)',
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF65636D))),
//                           ]),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),

//               // Return Reasons Pie Chart
//               Container(
//                 margin: const EdgeInsets.all(8.0),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                     color: const Color(0xFFFAF5F9),
//                     borderRadius: BorderRadius.circular(12.0),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.grey.withOpacity(0.3),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset: const Offset(0, 3))
//                     ]),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Return Reasons Breakdown',
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF65636D))),
//                     const Text('Why items are returned',
//                         style:
//                             TextStyle(fontSize: 14, color: Color(0xFF65636D))),
//                     const SizedBox(height: 20),
//                     if (returnReasons.isNotEmpty) ...[
//                       SizedBox(
//                         height: 360,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                                 width: double.infinity,
//                                 height: 200,
//                                 child: PieChart(PieChartData(
//                                   sectionsSpace: 0,
//                                   centerSpaceRadius: 0,
//                                   sections: returnReasons.entries.map((e) {
//                                     final index = returnReasons.keys
//                                         .toList()
//                                         .indexOf(e.key);
//                                     return PieChartSectionData(
//                                       color: _returnReasonsVisibility[e.key] ??
//                                               true
//                                           ? chartColors[
//                                               index % chartColors.length]
//                                           : Colors.grey,
//                                       value: _returnReasonsVisibility[e.key] ??
//                                               true
//                                           ? 1
//                                           : 0,
//                                       title: '',
//                                       radius: 100,
//                                       showTitle: false,
//                                     );
//                                   }).toList(),
//                                 ))),
//                             const SizedBox(height: 16),
//                             const Text('Reason',
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF65636D))),
//                             Expanded(
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: returnReasons.entries.map((e) {
//                                     final index = returnReasons.keys
//                                             .toList()
//                                             .indexOf(e.key) %
//                                         chartColors.length;
//                                     return GestureDetector(
//                                       onTap: () => setState(() =>
//                                           _returnReasonsVisibility[e.key] =
//                                               !(_returnReasonsVisibility[
//                                                       e.key] ??
//                                                   true)),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 8.0),
//                                         child: Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Container(
//                                                   width: 16,
//                                                   height: 16,
//                                                   decoration: BoxDecoration(
//                                                       color:
//                                                           _returnReasonsVisibility[
//                                                                       e.key] ??
//                                                                   true
//                                                               ? chartColors[
//                                                                   index]
//                                                               : Colors.grey,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               2))),
//                                               const SizedBox(width: 8),
//                                               Flexible(
//                                                   child: Text(e.key,
//                                                       style: const TextStyle(
//                                                           fontSize: 14,
//                                                           color: Color(
//                                                               0xFF65636D)),
//                                                       overflow: TextOverflow
//                                                           .ellipsis)),
//                                             ]),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ] else ...[
//                       const SizedBox(
//                           height: 300,
//                           child: Center(
//                               child: Text('No return reasons data available',
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       color: Color(0xFF65636D))))),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ------------------------- DASHBOARD SCREEN -------------------------
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   bool _isTodayOpen = false;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkDayStatus();
//   }

//   Future<void> _checkDayStatus() async {
//     final service = DayClosingService();
//     final isOpen = await service.isTodayOpen();
//     if (mounted) {
//       setState(() => _isTodayOpen = isOpen);
//     }
//   }

//   Future<void> _openToday() async {
//     if (_isLoading || _isTodayOpen) return;
//     setState(() => _isLoading = true);

//     final service = DayClosingService();
//     final success = await service.openToday();

//     if (success && mounted) {
//       setState(() => _isTodayOpen = true);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Day opened successfully!')),
//       );
//       context.read<DashboardBloc>().add(const FetchDashboardData());
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to open day')),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => DashboardBloc()..add(const FetchDashboardData()),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         floatingActionButton: FloatingActionButton(
//           onPressed: () => context.go('/chat'),
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           child: const Icon(Icons.chat, color: Colors.white),
//         ),
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: ElevatedButton.icon(
//                 onPressed: _isLoading ? null : _openToday,
//                 icon: Icon(
//                   _isTodayOpen ? Icons.check_circle : Icons.lock_open,
//                   size: 18,
//                 ),
//                 label: Text(
//                   _isTodayOpen ? 'Day Opened' : 'Open Day',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isTodayOpen
//                       ? const Color(0xFF10750E)
//                       : const Color(0xFF971313),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: BlocListener<DashboardBloc, DashboardState>(
//           listener: (context, state) {
//             if (state.errorMessage != null) {
//               debugPrint('DashboardBloc Error: ${state.errorMessage}');
//             }
//           },
//           child: BlocBuilder<DashboardBloc, DashboardState>(
//             buildWhen: (previous, current) =>
//                 previous.isLoading != current.isLoading ||
//                 previous.errorMessage != current.errorMessage ||
//                 previous.totalPurchases != current.totalPurchases ||
//                 previous.totalVatCollected != current.totalVatCollected ||
//                 previous.purchaseReturns != current.purchaseReturns ||
//                 previous.totalSalesTransactions !=
//                     current.totalSalesTransactions ||
//                 previous.totalSales != current.totalSales ||
//                 previous.salesReturns != current.salesReturns,
//             builder: (context, state) {
//               if (state.isLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (state.errorMessage != null) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline,
//                           size: 48, color: Color(0xFF971313)),
//                       const SizedBox(height: 16),
//                       Text(state.errorMessage!,
//                           style: const TextStyle(
//                               color: Color(0xFF65636D), fontSize: 16)),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF10750E)),
//                         onPressed: () => context
//                             .read<DashboardBloc>()
//                             .add(const FetchDashboardData()),
//                         child: const Text('Retry',
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Dashboard',
//                               style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF65636D))),
//                           SizedBox(height: 4),
//                           Text('Overview of your purchases, sales, and returns',
//                               style: TextStyle(
//                                   fontSize: 14, color: Color(0xFF9E9DA2))),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Wrap(
//                         spacing: 1.0,
//                         runSpacing: 1.0,
//                         children: [
//                           DashboardCard(
//                               title: 'Total Purchases',
//                               value:
//                                   'Rs ${state.totalPurchases?.toStringAsFixed(2) ?? '0.00'}',
//                               icon: Icons.shopping_cart,
//                               cardColor: const Color(0xFFFFDAB7)),
//                           DashboardCard(
//                               title: 'VAT Collected',
//                               value:
//                                   'Rs ${state.totalVatCollected?.toStringAsFixed(2) ?? '0.00'}',
//                               icon: Icons.money,
//                               cardColor: const Color(0xFFB3CAF6)),
//                           DashboardCard(
//                               title: 'Purchase Returns',
//                               value:
//                                   'Rs ${state.purchaseReturns?.toStringAsFixed(2) ?? '0.00'}',
//                               icon: Icons.undo,
//                               cardColor: const Color(0xFFF9D8B7)),
//                           DashboardCard(
//                               title: 'Total Sales',
//                               value:
//                                   'Rs ${state.totalSales?.toStringAsFixed(2) ?? '0.00'}',
//                               icon: Icons.trending_up,
//                               cardColor: const Color(0xFFB3CAF6)),
//                           DashboardCard(
//                               title: 'Sales Returns',
//                               value:
//                                   'Rs ${state.salesReturns?.toStringAsFixed(2) ?? '0.00'}',
//                               icon: Icons.upload,
//                               cardColor: const Color(0xFFF9D8B7)),
//                         ],
//                       ),
//                     ),
//                     const ChartPanel(),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saleup_app/core/services/day_closing_service.dart';
import 'package:saleup_app/model/sale_response.dart' as sale_response;
import 'package:saleup_app/screen/dashboard/bloc/dashboard_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_state.dart';
import 'package:saleup_app/screen/dashboard/widget/dashboard_card.dart';

// ------------------------- CHART PANEL -------------------------
class ChartPanel extends StatefulWidget {
  const ChartPanel({super.key});

  @override
  _ChartPanelState createState() => _ChartPanelState();
}

class _ChartPanelState extends State<ChartPanel> {
  double getInterval(double maxY) {
    if (maxY <= 0) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 1000) return 100;
    if (maxY <= 10000) return 1000;
    return maxY / 5;
  }

  final Map<String, bool> _barVisibility = {};
  final Map<String, bool> _purchaseVsReturnsVisibility = {};
  final Map<String, bool> _returnReasonsVisibility = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<DashboardBloc>().state;
    if (state.salesData != null && state.salesData!.data != null) {
      for (var saleJson in state.salesData!.data) {
        final sale =
            sale_response.SaleData.fromJson(saleJson as Map<String, dynamic>);
        for (var item in sale.items) {
          final productId = item.product.toString();
          _barVisibility[productId] = true;
        }
      }
    }
    _purchaseVsReturnsVisibility.addAll({
      'Purchases': true,
      'Purchase Returns': true,
      'Sales': true,
      'Sales Returns': true,
    });
    _returnReasonsVisibility.addAll(context
            .watch<DashboardBloc>()
            .state
            .returnReasons
            ?.map((key, value) => MapEntry(key, true)) ??
        {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.errorMessage != current.errorMessage ||
          previous.quantitySold != current.quantitySold ||
          previous.totalPurchases != current.totalPurchases ||
          previous.purchaseReturns != current.purchaseReturns ||
          previous.totalSales != current.totalSales ||
          previous.salesReturns != current.salesReturns ||
          previous.salesData != current.salesData ||
          previous.returnReasons != current.returnReasons,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Color(0xFF971313)),
                const SizedBox(height: 16),
                Text(state.errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFF65636D), fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10750E)),
                  onPressed: () => context
                      .read<DashboardBloc>()
                      .add(const FetchDashboardData()),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final List<Color> chartColors = [
          const Color(0xFFF59422),
          const Color(0xFFFBBF24),
          const Color(0xFFFCD34D),
          const Color(0xFFFDE047),
        ];

        Map<String, double> productData = {};
        if (state.salesData != null && state.salesData!.data != null) {
          for (var saleJson in state.salesData!.data) {
            final sale = sale_response.SaleData.fromJson(
                saleJson as Map<String, dynamic>);
            for (var item in sale.items) {
              final productId = item.product.toString();
              productData[productId] = (productData[productId] ?? 0) +
                  (item.quantity?.toDouble() ?? 0.0);
            }
          }
        }

        final totalPurchases = state.totalPurchases ?? 0.0;
        final purchaseReturns = state.purchaseReturns ?? 0.0;
        final totalSales = state.totalSales ?? 0.0;
        final salesReturns = state.salesReturns ?? 0.0;

        final returnReasons = state.returnReasons ?? {};
        final pieChartTotal = returnReasons.values.isNotEmpty
            ? returnReasons.values.reduce((a, b) => a + b)
            : 0.0;

        final purchaseVsReturnsData = {
          'Purchases': totalPurchases,
          'Purchase Returns': purchaseReturns,
          'Sales': totalSales,
          'Sales Returns': salesReturns,
        };

        final hasPurchaseData =
            purchaseVsReturnsData.values.any((value) => value > 0);
        final purchaseVsReturnsTotal = hasPurchaseData
            ? purchaseVsReturnsData.values
                .where((value) => value > 0)
                .reduce((a, b) => a + b)
            : 0.0;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bar Chart
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5F9),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Sales Volume',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF65636D))),
                    const Text('Quantity of products sold',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF65636D))),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          maxY: productData.isNotEmpty
                              ? (productData.values
                                          .reduce((a, b) => a > b ? a : b) *
                                      1.1)
                                  .clamp(0.0, 2.2)
                              : 2.0,
                          minY: 0,
                          gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 0.2,
                              getDrawingHorizontalLine: (value) => FlLine(
                                  color:
                                      const Color(0xFF65636D).withOpacity(0.2),
                                  strokeWidth: 1)),
                          titlesData: FlTitlesData(
                            rightTitles: AxisTitles(
                                sideTitles: const SideTitles(showTitles: false),
                                axisNameWidget: Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                            width: 12,
                                            height: 12,
                                            color: const Color(0xFFF4A261)),
                                        const SizedBox(width: 4),
                                        const Text('Quantity Sold',
                                            style: TextStyle(
                                                color: Color(0xFF65636D),
                                                fontSize: 12)),
                                      ]),
                                )),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      final products =
                                          productData.keys.toList();
                                      final index = value.toInt();
                                      if (index < products.length) {
                                        return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(products[index],
                                                style: const TextStyle(
                                                    color: Color(0xFF65636D),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                                textAlign: TextAlign.center));
                                      }
                                      return const Text('');
                                    })),
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 0.2,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(value.toStringAsFixed(1),
                                          style: const TextStyle(
                                              color: Color(0xFF65636D),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12));
                                    })),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: productData.entries.map((entry) {
                            final index =
                                productData.keys.toList().indexOf(entry.key);
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                    toY: _barVisibility[entry.key] ?? true
                                        ? entry.value
                                        : 0,
                                    color: const Color(0xFFF4A261),
                                    width: 30,
                                    borderRadius: BorderRadius.circular(4))
                              ],
                            );
                          }).toList(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) =>
                                      BarTooltipItem(
                                          '${rod.toY}',
                                          const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipMargin: 8,
                              getTooltipColor: (_) => Colors.grey[700]!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 6.0,
                      children: productData.entries.map((entry) {
                        return GestureDetector(
                          onTap: () => setState(() =>
                              _barVisibility[entry.key] =
                                  !(_barVisibility[entry.key] ?? true)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: _barVisibility[entry.key] ?? true
                                        ? const Color(0xFFF4A261)
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 6),
                            Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF65636D))),
                          ]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // Pie Chart: Purchase vs Returns
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: const Color(0xFFFAF5F9),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Purchase vs Returns Overview',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF65636D))),
                    const Text('Comparison in Rs.',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF65636D))),
                    const SizedBox(height: 20),
                    if (hasPurchaseData) ...[
                      SizedBox(
                        height: 300,
                        child: PieChart(PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 0,
                          sections: purchaseVsReturnsData.entries
                              .toList()
                              .asMap()
                              .entries
                              .where((e) => e.value.value > 0)
                              .map((e) {
                            final index = e.key;
                            final value = e.value.value;
                            final percentage = purchaseVsReturnsTotal > 0
                                ? (value / purchaseVsReturnsTotal * 100)
                                    .toStringAsFixed(1)
                                : '0.0';
                            return PieChartSectionData(
                              color:
                                  _purchaseVsReturnsVisibility[e.value.key] ??
                                          true
                                      ? chartColors[index % chartColors.length]
                                      : Colors.grey,
                              value:
                                  _purchaseVsReturnsVisibility[e.value.key] ??
                                          true
                                      ? value
                                      : 0,
                              title:
                                  _purchaseVsReturnsVisibility[e.value.key] ??
                                          true
                                      ? '$percentage%'
                                      : '',
                              radius: 120,
                              titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF65636D)),
                              showTitle:
                                  _purchaseVsReturnsVisibility[e.value.key] ??
                                      true,
                            );
                          }).toList(),
                        )),
                      ),
                    ] else ...[
                      const SizedBox(
                          height: 400,
                          child: Center(
                              child: Text(
                                  'No purchase or returns data available',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF65636D))))),
                    ],
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 6.0,
                      children: purchaseVsReturnsData.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((e) {
                        final index = e.key;
                        final value = e.value.value;
                        final percentage = purchaseVsReturnsTotal > 0
                            ? (value / purchaseVsReturnsTotal * 100)
                                .toStringAsFixed(1)
                            : '0.0';
                        return GestureDetector(
                          onTap: () => setState(() =>
                              _purchaseVsReturnsVisibility[e.value.key] =
                                  !(_purchaseVsReturnsVisibility[e.value.key] ??
                                      true)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: _purchaseVsReturnsVisibility[
                                                e.value.key] ??
                                            true
                                        ? chartColors[
                                            index % chartColors.length]
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 6),
                            Text('${e.value.key} ($percentage%)',
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF65636D))),
                          ]),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Return Reasons Pie Chart
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: const Color(0xFFFAF5F9),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Return Reasons Breakdown',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF65636D))),
                    const Text('Why items are returned',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF65636D))),
                    const SizedBox(height: 20),
                    if (returnReasons.isNotEmpty) ...[
                      SizedBox(
                        height: 360,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: double.infinity,
                                height: 200,
                                child: PieChart(PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 0,
                                  sections: returnReasons.entries.map((e) {
                                    final index = returnReasons.keys
                                        .toList()
                                        .indexOf(e.key);
                                    return PieChartSectionData(
                                      color: _returnReasonsVisibility[e.key] ??
                                              true
                                          ? chartColors[
                                              index % chartColors.length]
                                          : Colors.grey,
                                      value: _returnReasonsVisibility[e.key] ??
                                              true
                                          ? 1
                                          : 0,
                                      title: '',
                                      radius: 100,
                                      showTitle: false,
                                    );
                                  }).toList(),
                                ))),
                            const SizedBox(height: 16),
                            const Text('Reason',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF65636D))),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: returnReasons.entries.map((e) {
                                    final index = returnReasons.keys
                                            .toList()
                                            .indexOf(e.key) %
                                        chartColors.length;
                                    return GestureDetector(
                                      onTap: () => setState(() =>
                                          _returnReasonsVisibility[e.key] =
                                              !(_returnReasonsVisibility[
                                                      e.key] ??
                                                  true)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                  width: 16,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          _returnReasonsVisibility[
                                                                      e.key] ??
                                                                  true
                                                              ? chartColors[
                                                                  index]
                                                              : Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2))),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                  child: Text(e.key,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xFF65636D)),
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                            ]),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(
                          height: 300,
                          child: Center(
                              child: Text('No return reasons data available',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF65636D))))),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------- DASHBOARD SCREEN -------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isTodayOpen = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkDayStatus();
  }

  Future<void> _checkDayStatus() async {
    final service = DayClosingService();
    final isOpen = await service.isTodayOpen();
    if (mounted) {
      setState(() => _isTodayOpen = isOpen);
    }
  }

  Future<void> _openToday() async {
    if (_isLoading || _isTodayOpen) return;
    setState(() => _isLoading = true);

    final service = DayClosingService();
    final success = await service.openToday();

    if (success && mounted) {
      setState(() => _isTodayOpen = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day opened successfully!')),
      );
      context.read<DashboardBloc>().add(const FetchDashboardData());
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day already opened')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(const FetchDashboardData()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/chat'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.chat, color: Colors.white),
        ),
        body: CustomScrollView(
          slivers: [
            // HIDE ON SCROLL DOWN, SHOW ON SCROLL UP
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true, // REQUIRED for snap
              pinned: false,
              snap: true, // Now works
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _openToday,
                    icon: Icon(
                      _isTodayOpen ? Icons.check_circle : Icons.lock_open,
                      size: 18,
                    ),
                    label: Text(
                      _isTodayOpen ? 'Day Opened' : 'Open Day',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTodayOpen
                          ? const Color(0xFF10750E)
                          : const Color(0xFF971313),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // MAIN CONTENT
            SliverToBoxAdapter(
              child: BlocListener<DashboardBloc, DashboardState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    debugPrint('DashboardBloc Error: ${state.errorMessage}');
                  }
                },
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  buildWhen: (previous, current) =>
                      previous.isLoading != current.isLoading ||
                      previous.errorMessage != current.errorMessage ||
                      previous.totalPurchases != current.totalPurchases ||
                      previous.totalVatCollected != current.totalVatCollected ||
                      previous.purchaseReturns != current.purchaseReturns ||
                      previous.totalSalesTransactions !=
                          current.totalSalesTransactions ||
                      previous.totalSales != current.totalSales ||
                      previous.salesReturns != current.salesReturns,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Color(0xFF971313)),
                            const SizedBox(height: 16),
                            Text(state.errorMessage!,
                                style: const TextStyle(
                                    color: Color(0xFF65636D), fontSize: 16)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10750E)),
                              onPressed: () => context
                                  .read<DashboardBloc>()
                                  .add(const FetchDashboardData()),
                              child: const Text('Retry',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dashboard',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF65636D))),
                              SizedBox(height: 4),
                              Text(
                                  'Overview of your purchases, sales, and returns',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF9E9DA2))),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Wrap(
                            spacing: 1.0,
                            runSpacing: 1.0,
                            children: [
                              DashboardCard(
                                  title: 'Total Purchases',
                                  value:
                                      'Rs ${state.totalPurchases?.toStringAsFixed(2) ?? '0.00'}',
                                  icon: Icons.shopping_cart,
                                  cardColor: const Color(0xFFFFDAB7)),
                              DashboardCard(
                                  title: 'VAT Collected',
                                  value:
                                      'Rs ${state.totalVatCollected?.toStringAsFixed(2) ?? '0.00'}',
                                  icon: Icons.money,
                                  cardColor: const Color(0xFFB3CAF6)),
                              DashboardCard(
                                  title: 'Purchase Returns',
                                  value:
                                      'Rs ${state.purchaseReturns?.toStringAsFixed(2) ?? '0.00'}',
                                  icon: Icons.undo,
                                  cardColor: const Color(0xFFF9D8B7)),
                              DashboardCard(
                                  title: 'Total Sales',
                                  value:
                                      'Rs ${state.totalSales?.toStringAsFixed(2) ?? '0.00'}',
                                  icon: Icons.trending_up,
                                  cardColor: const Color(0xFFB3CAF6)),
                              DashboardCard(
                                  title: 'Sales Returns',
                                  value:
                                      'Rs ${state.salesReturns?.toStringAsFixed(2) ?? '0.00'}',
                                  icon: Icons.upload,
                                  cardColor: const Color(0xFFF9D8B7)),
                            ],
                          ),
                        ),
                        const ChartPanel(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
