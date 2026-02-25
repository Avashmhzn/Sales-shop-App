// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/services/day_closing_service.dart';
// import 'package:saleup_app/model/sale_response.dart' as sale_response;
// import 'package:fl_chart/fl_chart.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_bloc.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_state.dart';
// import 'package:saleup_app/screen/dashboard/utilitis/dashboard_shimmer.dart';
// import 'package:saleup_app/screen/dashboard/widget/dashboard_card.dart';

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
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Container(
//                   height: 300,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Wrap(
//                   spacing: 12,
//                   runSpacing: 8,
//                   children: List.generate(
//                       6,
//                       (_) => Container(
//                             width: 100,
//                             height: 32,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           )),
//                 ),
//               ],
//             ),
//           );
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

//         final double rawMax = productData.isNotEmpty
//             ? productData.values.reduce((a, b) => a > b ? a : b)
//             : 0.0;
//         final double maxY = rawMax > 3.0 ? rawMax * 1.1 : 3.0;
//         const double interval = 0.5;

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

//         final hasRealData = (state.totalSales ?? 0) > 0 ||
//             (state.totalPurchases ?? 0) > 0 ||
//             (state.totalVatCollected ?? 0) > 0 ||
//             (state.purchaseReturns ?? 0) > 0 ||
//             (state.salesReturns ?? 0) > 0 ||
//             (state.returnReasons?.isNotEmpty ?? false);

//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (!hasRealData)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.orange.shade300),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.warning_amber_rounded,
//                                 color: Colors.orange.shade800),
//                             const SizedBox(width: 12),
//                             const Expanded(
//                               child: Text(
//                                 'No transactions found',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'The dashboard is showing zero values because:\n'
//                           '• No sales, purchases or returns recorded yet, or\n'
//                           '• The current fiscal year has no activity.\n\n'
//                           'Add some transactions to see actual numbers.',
//                           style: TextStyle(color: Colors.grey[800]),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
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
//                       child: Stack(
//                         children: [
//                           BarChart(
//                             BarChartData(
//                               alignment: BarChartAlignment.start,
//                               maxY: maxY,
//                               minY: 0,
//                               gridData: FlGridData(
//                                 show: true,
//                                 drawVerticalLine: false,
//                                 horizontalInterval: interval,
//                                 getDrawingHorizontalLine: (value) => FlLine(
//                                   color:
//                                       const Color(0xFF65636D).withOpacity(0.2),
//                                   strokeWidth: 1,
//                                 ),
//                               ),
//                               titlesData: FlTitlesData(
//                                 rightTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),
//                                 topTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),
//                                 bottomTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     reservedSize: 30,
//                                     getTitlesWidget: (value, meta) {
//                                       final products =
//                                           productData.keys.toList();
//                                       final index = value.toInt();
//                                       if (index < products.length) {
//                                         return Padding(
//                                           padding:
//                                               const EdgeInsets.only(top: 8.0),
//                                           child: Text(
//                                             products[index],
//                                             style: const TextStyle(
//                                                 color: Color(0xFF65636D),
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 12),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         );
//                                       }
//                                       return const SizedBox.shrink();
//                                     },
//                                   ),
//                                 ),
//                                 leftTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     interval: interval,
//                                     reservedSize: 40,
//                                     getTitlesWidget: (value, meta) {
//                                       return Text(
//                                         value.toStringAsFixed(1),
//                                         style: const TextStyle(
//                                             color: Color(0xFF65636D),
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 12),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               borderData: FlBorderData(show: false),
//                               barGroups: productData.entries.map((entry) {
//                                 final index = productData.keys
//                                     .toList()
//                                     .indexOf(entry.key);
//                                 return BarChartGroupData(
//                                   x: index,
//                                   barRods: [
//                                     BarChartRodData(
//                                       toY: _barVisibility[entry.key] ?? true
//                                           ? entry.value
//                                           : 0,
//                                       color: const Color(0xFFF4A261),
//                                       width: 60,
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                   ],
//                                 );
//                               }).toList(),
//                               barTouchData: BarTouchData(
//                                 enabled: true,
//                                 touchTooltipData: BarTouchTooltipData(
//                                   tooltipRoundedRadius: 8,
//                                   tooltipPadding: const EdgeInsets.all(8),
//                                   tooltipMargin: 8,
//                                   getTooltipItem:
//                                       (group, groupIndex, rod, rodIndex) {
//                                     final productId =
//                                         productData.keys.toList()[group.x];
//                                     final qty = rod.toY;
//                                     return BarTooltipItem(
//                                       '$productId\n${qty.toStringAsFixed(1)}',
//                                       const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const Positioned(
//                             right: 16,
//                             top: 150,
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SizedBox(
//                                     width: 16,
//                                     height: 16,
//                                     child:
//                                         ColoredBox(color: Color(0xFFF4A261))),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'Quantity Sold',
//                                   style: TextStyle(
//                                       color: Color(0xFF65636D),
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
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
//                               width: 16,
//                               height: 16,
//                               decoration: BoxDecoration(
//                                 color: _barVisibility[entry.key] ?? true
//                                     ? const Color(0xFFF4A261)
//                                     : Colors.grey,
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                             ),
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
//         const SnackBar(content: Text('Day already opened')),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => DashboardBloc()
//         ..add(const FetchFiscalYears())
//         ..add(const FetchDashboardData()),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         // floatingActionButton: FloatingActionButton(
//         //   onPressed: () => context.go('/chat'),
//         //   backgroundColor: Theme.of(context).colorScheme.primary,
//         //   child: const Icon(Icons.chat, color: Colors.white),
//         // ),
//         body: CustomScrollView(
//           slivers: [
//             // ── Header: date + Open Day button ──
//             SliverToBoxAdapter(
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(16, 145, 16, 8),
//                 color: Colors.white,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         BlocBuilder<DashboardBloc, DashboardState>(
//                           builder: (context, state) {
//                             return Text(
//                               'Fiscal year:- ${state.currentFiscalYear?.name ?? "Loading..."}',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black87,
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _isLoading ? null : _openToday,
//                       icon: Icon(
//                         _isTodayOpen ? Icons.check_circle : Icons.lock_open,
//                         size: 18,
//                       ),
//                       label: Text(
//                         _isTodayOpen ? 'Day Opened' : 'Open Day',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isTodayOpen
//                             ? const Color(0xFF10750E)
//                             : const Color(0xFF971313),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Dashboard title + FY dropdown on same row ──
//             SliverToBoxAdapter(
//               child: BlocBuilder<DashboardBloc, DashboardState>(
//                 builder: (context, state) {
//                   return Padding(
//                     padding: const EdgeInsets.fromLTRB(15, 0, 8, 4),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Dashboard',
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF65636D))),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Overview of your purchases, sales,\nand returns',
//                                 style: TextStyle(
//                                     fontSize: 12, color: Color(0xFF9E9DA2)),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (state.allFiscalYears != null &&
//                             state.allFiscalYears!.isNotEmpty)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFFF9800),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: state.currentFiscalYear?.name ?? 'FY',
//                                 icon: const Icon(Icons.arrow_drop_down,
//                                     color: Colors.white),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 dropdownColor: const Color(0xFFFF9800),
//                                 items: state.allFiscalYears!.map((fy) {
//                                   return DropdownMenuItem<String>(
//                                     value: fy.name,
//                                     child: Text(fy.name),
//                                   );
//                                 }).toList(),
//                                 onChanged: (newValue) {
//                                   if (newValue == null) return;
//                                   final selected = state.allFiscalYears!
//                                       .firstWhere((fy) => fy.name == newValue);
//                                   context
//                                       .read<DashboardBloc>()
//                                       .add(ChangeFiscalYear(selected.id));
//                                 },
//                               ),
//                             ),
//                           )
//                         else
//                           const Text('Loading FY...',
//                               style:
//                                   TextStyle(color: Colors.grey, fontSize: 14)),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // ── Cards + Charts ──
//             SliverToBoxAdapter(
//               child: BlocListener<DashboardBloc, DashboardState>(
//                 listener: (context, state) {
//                   if (state.errorMessage != null) {
//                     debugPrint('DashboardBloc Error: ${state.errorMessage}');
//                   }
//                   if (state.refreshDashboard == true) {
//                     context
//                         .read<DashboardBloc>()
//                         .add(const FetchDashboardData());
//                     context.read<DashboardBloc>().add(const ResetRefreshFlag());
//                   }
//                 },
//                 child: BlocBuilder<DashboardBloc, DashboardState>(
//                   buildWhen: (previous, current) =>
//                       previous.isLoading != current.isLoading ||
//                       previous.errorMessage != current.errorMessage ||
//                       previous.totalPurchases != current.totalPurchases ||
//                       previous.totalVatCollected != current.totalVatCollected ||
//                       previous.purchaseReturns != current.purchaseReturns ||
//                       previous.totalSalesTransactions !=
//                           current.totalSalesTransactions ||
//                       previous.totalSales != current.totalSales ||
//                       previous.salesReturns != current.salesReturns,
//                   builder: (context, state) {
//                     if (state.isLoading) {
//                       return const DashboardShimmer();
//                     }
//                     if (state.errorMessage != null) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.error_outline,
//                                 size: 48, color: Color(0xFF971313)),
//                             const SizedBox(height: 16),
//                             Text(state.errorMessage!,
//                                 style: const TextStyle(
//                                     color: Color(0xFF65636D), fontSize: 16)),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF10750E)),
//                               onPressed: () => context
//                                   .read<DashboardBloc>()
//                                   .add(const FetchDashboardData()),
//                               child: const Text('Retry',
//                                   style: TextStyle(color: Colors.white)),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     final hasRealData = (state.totalSales ?? 0) > 0 ||
//                         (state.totalPurchases ?? 0) > 0 ||
//                         (state.totalVatCollected ?? 0) > 0 ||
//                         (state.purchaseReturns ?? 0) > 0 ||
//                         (state.salesReturns ?? 0) > 0 ||
//                         (state.returnReasons?.isNotEmpty ?? false);

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (!hasRealData)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16.0, vertical: 8.0),
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border:
//                                     Border.all(color: Colors.orange.shade300),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Icon(Icons.info_outline,
//                                           color: Colors.orange.shade800),
//                                       const SizedBox(width: 12),
//                                       const Expanded(
//                                         child: Text(
//                                           'No transactions found yet',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'The dashboard shows zero values because:\n'
//                                     '• No sales, purchases or returns recorded yet, or\n'
//                                     '• The current fiscal year has no activity.\n\n'
//                                     'Add some transactions to see actual numbers.',
//                                     style: TextStyle(color: Colors.grey[800]),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 10.0),
//                           child: Wrap(
//                             spacing: 0,
//                             runSpacing: 0,
//                             children: [
//                               DashboardCard(
//                                   title: 'Total Purchases',
//                                   value:
//                                       'Rs. ${state.totalPurchases?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/shopping-cart 1.png',
//                                   cardColor: const Color(0xFFEBF0FF)),
//                               DashboardCard(
//                                   title: 'VAT Collected',
//                                   value:
//                                       'Rs. ${state.totalVatCollected?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/tax.png',
//                                   cardColor: const Color(0xFFFAF3FF)),
//                               DashboardCard(
//                                   title: 'Purchase Returns',
//                                   value:
//                                       'Rs. ${state.purchaseReturns?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/product-return.png',
//                                   cardColor: const Color(0xFFFFF7FD)),
//                               DashboardCard(
//                                   title: 'Total Sales',
//                                   value:
//                                       'Rs. ${state.totalSales?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/invoice.png',
//                                   cardColor: const Color(0xFFFFF9F7)),
//                               DashboardCard(
//                                   title: 'Sales Returns',
//                                   value:
//                                       'Rs. ${state.salesReturns?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/sales-return.png',
//                                   cardColor: const Color(0xFFEBF0FF)),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0, // match your card padding style
//                             vertical: 12.0, // space above/below the line
//                           ),
//                           child: Image.asset(
//                             'assets/images/Dashboard_Line.png',
//                             width: double.infinity, // stretches full width
//                             height: 2, // adjust based on your image's aspect
//                             fit: BoxFit
//                                 .fill, // or BoxFit.contain / cover depending on design
//                           ),
//                         ),
//                         const ChartPanel(),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/services/day_closing_service.dart';
// import 'package:saleup_app/model/sale_response.dart' as sale_response;
// import 'package:fl_chart/fl_chart.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_bloc.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
// import 'package:saleup_app/screen/dashboard/bloc/dashboard_state.dart';
// import 'package:saleup_app/screen/dashboard/utilitis/dashboard_shimmer.dart';
// import 'package:saleup_app/screen/dashboard/widget/dashboard_card.dart';

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
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Container(
//                   height: 300,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Wrap(
//                   spacing: 12,
//                   runSpacing: 8,
//                   children: List.generate(
//                       6,
//                       (_) => Container(
//                             width: 100,
//                             height: 32,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           )),
//                 ),
//               ],
//             ),
//           );
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

//         final double rawMax = productData.isNotEmpty
//             ? productData.values.reduce((a, b) => a > b ? a : b)
//             : 0.0;
//         final double maxY = rawMax > 3.0 ? rawMax * 1.1 : 3.0;
//         const double interval = 0.5;

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

//         final hasRealData = (state.totalSales ?? 0) > 0 ||
//             (state.totalPurchases ?? 0) > 0 ||
//             (state.totalVatCollected ?? 0) > 0 ||
//             (state.purchaseReturns ?? 0) > 0 ||
//             (state.salesReturns ?? 0) > 0 ||
//             (state.returnReasons?.isNotEmpty ?? false);

//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (!hasRealData)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.orange.shade300),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.warning_amber_rounded,
//                                 color: Colors.orange.shade800),
//                             const SizedBox(width: 12),
//                             const Expanded(
//                               child: Text(
//                                 'No transactions found',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'The dashboard is showing zero values because:\n'
//                           '• No sales, purchases or returns recorded yet, or\n'
//                           '• The current fiscal year has no activity.\n\n'
//                           'Add some transactions to see actual numbers.',
//                           style: TextStyle(color: Colors.grey[800]),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
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
//                       child: Stack(
//                         children: [
//                           BarChart(
//                             BarChartData(
//                               alignment: BarChartAlignment.start,
//                               maxY: maxY,
//                               minY: 0,
//                               gridData: FlGridData(
//                                 show: true,
//                                 drawVerticalLine: false,
//                                 horizontalInterval: interval,
//                                 getDrawingHorizontalLine: (value) => FlLine(
//                                   color:
//                                       const Color(0xFF65636D).withOpacity(0.2),
//                                   strokeWidth: 1,
//                                 ),
//                               ),
//                               titlesData: FlTitlesData(
//                                 rightTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),
//                                 topTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),
//                                 bottomTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     reservedSize: 30,
//                                     getTitlesWidget: (value, meta) {
//                                       final products =
//                                           productData.keys.toList();
//                                       final index = value.toInt();
//                                       if (index < products.length) {
//                                         return Padding(
//                                           padding:
//                                               const EdgeInsets.only(top: 8.0),
//                                           child: Text(
//                                             products[index],
//                                             style: const TextStyle(
//                                                 color: Color(0xFF65636D),
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 12),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         );
//                                       }
//                                       return const SizedBox.shrink();
//                                     },
//                                   ),
//                                 ),
//                                 leftTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     interval: interval,
//                                     reservedSize: 40,
//                                     getTitlesWidget: (value, meta) {
//                                       return Text(
//                                         value.toStringAsFixed(1),
//                                         style: const TextStyle(
//                                             color: Color(0xFF65636D),
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 12),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               borderData: FlBorderData(show: false),
//                               barGroups: productData.entries.map((entry) {
//                                 final index = productData.keys
//                                     .toList()
//                                     .indexOf(entry.key);
//                                 return BarChartGroupData(
//                                   x: index,
//                                   barRods: [
//                                     BarChartRodData(
//                                       toY: _barVisibility[entry.key] ?? true
//                                           ? entry.value
//                                           : 0,
//                                       color: const Color(0xFFF4A261),
//                                       width: 60,
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                   ],
//                                 );
//                               }).toList(),
//                               barTouchData: BarTouchData(
//                                 enabled: true,
//                                 touchTooltipData: BarTouchTooltipData(
//                                   tooltipRoundedRadius: 8,
//                                   tooltipPadding: const EdgeInsets.all(8),
//                                   tooltipMargin: 8,
//                                   getTooltipItem:
//                                       (group, groupIndex, rod, rodIndex) {
//                                     final productId =
//                                         productData.keys.toList()[group.x];
//                                     final qty = rod.toY;
//                                     return BarTooltipItem(
//                                       '$productId\n${qty.toStringAsFixed(1)}',
//                                       const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const Positioned(
//                             right: 16,
//                             top: 150,
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SizedBox(
//                                     width: 16,
//                                     height: 16,
//                                     child:
//                                         ColoredBox(color: Color(0xFFF4A261))),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'Quantity Sold',
//                                   style: TextStyle(
//                                       color: Color(0xFF65636D),
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
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
//                               width: 16,
//                               height: 16,
//                               decoration: BoxDecoration(
//                                 color: _barVisibility[entry.key] ?? true
//                                     ? const Color(0xFFF4A261)
//                                     : Colors.grey,
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                             ),
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

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   bool _isTodayOpen = false;
//   bool _isLoading = false;

//   // Service instance
//   final DayClosingService _dayService = DayClosingService();

//   @override
//   void initState() {
//     super.initState();
//     _checkDayStatus();
//   }

//   Future<void> _checkDayStatus() async {
//     final isOpen = await _dayService.isTodayOpen();
//     if (mounted) {
//       setState(() => _isTodayOpen = isOpen);
//     }
//   }

//   Future<void> _openToday() async {
//     if (_isLoading || _isTodayOpen) return;
//     setState(() => _isLoading = true);

//     final success = await _dayService.openToday();

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

//   // NEW: Close Day function with confirmation
//   Future<void> _closeToday() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Close Day?'),
//         content: const Text(
//           'Are you sure you want to close the day?\n'
//           'No more transactions will be allowed until tomorrow.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Close Day', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     setState(() => _isLoading = true);

//     // TODO: Call your real close API here
//     // For now it's a placeholder — replace with actual call
//     final success = await _dayService.closeToday(); // You need to implement this

//     if (success && mounted) {
//       setState(() => _isTodayOpen = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Day closed successfully!')),
//       );
//       context.read<DashboardBloc>().add(const FetchDashboardData());
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to close day')),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => DashboardBloc()
//         ..add(const FetchFiscalYears())
//         ..add(const FetchDashboardData()),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: CustomScrollView(
//           slivers: [
//             // ── Header: date + Dynamic Open/Close button ──
//             SliverToBoxAdapter(
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(16, 145, 16, 8),
//                 color: Colors.white,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         BlocBuilder<DashboardBloc, DashboardState>(
//                           builder: (context, state) {
//                             return Text(
//                               'Fiscal year:- ${state.currentFiscalYear?.name ?? "Loading..."}',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black87,
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                     if (_isLoading)
//                       const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     else if (_isTodayOpen)
//                       // When open → show Close Day button
//                       ElevatedButton.icon(
//                         onPressed: _closeToday,
//                         icon: const Icon(Icons.lock_clock, size: 18),
//                         label: const Text('Close Day',
//                             style: TextStyle(fontSize: 14)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF971313),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                         ),
//                       )
//                     else
//                       // When closed → show Open Day button
//                       ElevatedButton.icon(
//                         onPressed: _openToday,
//                         icon: const Icon(Icons.lock_open, size: 18),
//                         label: const Text('Open Day',
//                             style: TextStyle(fontSize: 14)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF10750E),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Dashboard title + FY dropdown on same row ──
//             SliverToBoxAdapter(
//               child: BlocBuilder<DashboardBloc, DashboardState>(
//                 builder: (context, state) {
//                   return Padding(
//                     padding: const EdgeInsets.fromLTRB(15, 0, 8, 4),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Dashboard',
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF65636D))),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Overview of your purchases, sales,\nand returns',
//                                 style: TextStyle(
//                                     fontSize: 12, color: Color(0xFF9E9DA2)),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (state.allFiscalYears != null &&
//                             state.allFiscalYears!.isNotEmpty)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFFF9800),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: state.currentFiscalYear?.name ?? 'FY',
//                                 icon: const Icon(Icons.arrow_drop_down,
//                                     color: Colors.white),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 dropdownColor: const Color(0xFFFF9800),
//                                 items: state.allFiscalYears!.map((fy) {
//                                   return DropdownMenuItem<String>(
//                                     value: fy.name,
//                                     child: Text(fy.name),
//                                   );
//                                 }).toList(),
//                                 onChanged: (newValue) {
//                                   if (newValue == null) return;
//                                   final selected = state.allFiscalYears!
//                                       .firstWhere((fy) => fy.name == newValue);
//                                   context
//                                       .read<DashboardBloc>()
//                                       .add(ChangeFiscalYear(selected.id));
//                                 },
//                               ),
//                             ),
//                           )
//                         else
//                           const Text('Loading FY...',
//                               style:
//                                   TextStyle(color: Colors.grey, fontSize: 14)),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // ── Cards + Charts ──
//             SliverToBoxAdapter(
//               child: BlocListener<DashboardBloc, DashboardState>(
//                 listener: (context, state) {
//                   if (state.errorMessage != null) {
//                     debugPrint('DashboardBloc Error: ${state.errorMessage}');
//                   }
//                   if (state.refreshDashboard == true) {
//                     context
//                         .read<DashboardBloc>()
//                         .add(const FetchDashboardData());
//                     context.read<DashboardBloc>().add(const ResetRefreshFlag());
//                   }
//                 },
//                 child: BlocBuilder<DashboardBloc, DashboardState>(
//                   buildWhen: (previous, current) =>
//                       previous.isLoading != current.isLoading ||
//                       previous.errorMessage != current.errorMessage ||
//                       previous.totalPurchases != current.totalPurchases ||
//                       previous.totalVatCollected != current.totalVatCollected ||
//                       previous.purchaseReturns != current.purchaseReturns ||
//                       previous.totalSalesTransactions !=
//                           current.totalSalesTransactions ||
//                       previous.totalSales != current.totalSales ||
//                       previous.salesReturns != current.salesReturns,
//                   builder: (context, state) {
//                     if (state.isLoading) {
//                       return const DashboardShimmer();
//                     }
//                     if (state.errorMessage != null) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.error_outline,
//                                 size: 48, color: Color(0xFF971313)),
//                             const SizedBox(height: 16),
//                             Text(state.errorMessage!,
//                                 style: const TextStyle(
//                                     color: Color(0xFF65636D), fontSize: 16)),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF10750E)),
//                               onPressed: () => context
//                                   .read<DashboardBloc>()
//                                   .add(const FetchDashboardData()),
//                               child: const Text('Retry',
//                                   style: TextStyle(color: Colors.white)),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     final hasRealData = (state.totalSales ?? 0) > 0 ||
//                         (state.totalPurchases ?? 0) > 0 ||
//                         (state.totalVatCollected ?? 0) > 0 ||
//                         (state.purchaseReturns ?? 0) > 0 ||
//                         (state.salesReturns ?? 0) > 0 ||
//                         (state.returnReasons?.isNotEmpty ?? false);

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (!hasRealData)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16.0, vertical: 8.0),
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border:
//                                     Border.all(color: Colors.orange.shade300),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Icon(Icons.info_outline,
//                                           color: Colors.orange.shade800),
//                                       const SizedBox(width: 12),
//                                       const Expanded(
//                                         child: Text(
//                                           'No transactions found yet',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'The dashboard shows zero values because:\n'
//                                     '• No sales, purchases or returns recorded yet, or\n'
//                                     '• The current fiscal year has no activity.\n\n'
//                                     'Add some transactions to see actual numbers.',
//                                     style: TextStyle(color: Colors.grey[800]),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 10.0),
//                           child: Wrap(
//                             spacing: 0,
//                             runSpacing: 0,
//                             children: [
//                               DashboardCard(
//                                   title: 'Total Purchases',
//                                   value:
//                                       'Rs. ${state.totalPurchases?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/shopping-cart 1.png',
//                                   cardColor: const Color(0xFFEBF0FF)),
//                               DashboardCard(
//                                   title: 'VAT Collected',
//                                   value:
//                                       'Rs. ${state.totalVatCollected?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/tax.png',
//                                   cardColor: const Color(0xFFFAF3FF)),
//                               DashboardCard(
//                                   title: 'Purchase Returns',
//                                   value:
//                                       'Rs. ${state.purchaseReturns?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/product-return.png',
//                                   cardColor: const Color(0xFFFFF7FD)),
//                               DashboardCard(
//                                   title: 'Total Sales',
//                                   value:
//                                       'Rs. ${state.totalSales?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/invoice.png',
//                                   cardColor: const Color(0xFFFFF9F7)),
//                               DashboardCard(
//                                   title: 'Sales Returns',
//                                   value:
//                                       'Rs. ${state.salesReturns?.toStringAsFixed(2) ?? '0.00'}',
//                                   iconPath: 'assets/images/sales-return.png',
//                                   cardColor: const Color(0xFFEBF0FF)),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0,
//                             vertical: 12.0,
//                           ),
//                           child: Image.asset(
//                             'assets/images/Dashboard_Line.png',
//                             width: double.infinity,
//                             height: 2,
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                         const ChartPanel(),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/screen/dashboard/dashboard_screen.dart (full file with updated header date logic)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/services/day_closing_service.dart';
import 'package:saleup_app/model/sale_response.dart' as sale_response;
import 'package:fl_chart/fl_chart.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_bloc.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_event.dart';
import 'package:saleup_app/screen/dashboard/bloc/dashboard_state.dart';
import 'package:saleup_app/screen/dashboard/utilitis/dashboard_shimmer.dart';
import 'package:saleup_app/screen/dashboard/widget/dashboard_card.dart';

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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: List.generate(
                      6,
                      (_) => Container(
                            width: 100,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          )),
                ),
              ],
            ),
          );
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

        final double rawMax = productData.isNotEmpty
            ? productData.values.reduce((a, b) => a > b ? a : b)
            : 0.0;
        final double maxY = rawMax > 3.0 ? rawMax * 1.1 : 3.0;
        const double interval = 0.5;

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

        final hasRealData = (state.totalSales ?? 0) > 0 ||
            (state.totalPurchases ?? 0) > 0 ||
            (state.totalVatCollected ?? 0) > 0 ||
            (state.purchaseReturns ?? 0) > 0 ||
            (state.salesReturns ?? 0) > 0 ||
            (state.returnReasons?.isNotEmpty ?? false);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hasRealData)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange.shade800),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'No transactions found',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The dashboard is showing zero values because:\n'
                          '• No sales, purchases or returns recorded yet, or\n'
                          '• The current fiscal year has no activity.\n\n'
                          'Add some transactions to see actual numbers.',
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                ),
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
                      child: Stack(
                        children: [
                          BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.start,
                              maxY: maxY,
                              minY: 0,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: interval,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color:
                                      const Color(0xFF65636D).withOpacity(0.2),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      final products =
                                          productData.keys.toList();
                                      final index = value.toInt();
                                      if (index < products.length) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            products[index],
                                            style: const TextStyle(
                                                color: Color(0xFF65636D),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: interval,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toStringAsFixed(1),
                                        style: const TextStyle(
                                            color: Color(0xFF65636D),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: productData.entries.map((entry) {
                                final index = productData.keys
                                    .toList()
                                    .indexOf(entry.key);
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _barVisibility[entry.key] ?? true
                                          ? entry.value
                                          : 0,
                                      color: const Color(0xFFF4A261),
                                      width: 60,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipRoundedRadius: 8,
                                  tooltipPadding: const EdgeInsets.all(8),
                                  tooltipMargin: 8,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    final productId =
                                        productData.keys.toList()[group.x];
                                    final qty = rod.toY;
                                    return BarTooltipItem(
                                      '$productId\n${qty.toStringAsFixed(1)}',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 16,
                            top: 150,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    width: 16,
                                    height: 16,
                                    child:
                                        ColoredBox(color: Color(0xFFF4A261))),
                                SizedBox(width: 8),
                                Text(
                                  'Quantity Sold',
                                  style: TextStyle(
                                      color: Color(0xFF65636D),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isTodayOpen = false;
  bool _isLoading = false;

  Map<String, dynamic> _dayStatus = {
    'status': 'loading',
    'isOpen': false,
    'openDate': null,
    'currentServerDate': null,
  };

  final DayClosingService _dayService = DayClosingService();

  @override
  void initState() {
    super.initState();
    _checkDayStatus();
  }

  Future<void> _checkDayStatus() async {
    final status = await _dayService.checkDayStatus();
    if (mounted) {
      setState(() {
        _dayStatus = status;
        _isTodayOpen = status['isOpen'] == true;
      });
    }
  }

  Future<void> _openToday() async {
    if (_isLoading || _isTodayOpen) return;

    if (_dayStatus['status'] == 'previous_open') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_dayStatus['message'] ?? 'Close previous day first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _dayService.openToday();

    if (success && mounted) {
      setState(() => _isTodayOpen = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day opened successfully!')),
      );
      await _checkDayStatus();
      context.read<DashboardBloc>().add(const FetchDashboardData());
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open day')),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _closeDay() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Day?'),
        content: Text(
          _dayStatus['status'] == 'previous_open'
              ? 'Previous day (${_dayStatus['openDate'] ?? 'unknown'}) is still open.\nClose it to continue?'
              : 'Close current day?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close Day', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final success = await _dayService.closeToday();

    if (success && mounted) {
      setState(() => _isTodayOpen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day closed successfully!')),
      );

      // Small delay to let backend update + refresh
      await Future.delayed(const Duration(milliseconds: 800));
      await _checkDayStatus();
      context.read<DashboardBloc>().add(const FetchDashboardData());
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to close day')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()
        ..add(const FetchFiscalYears())
        ..add(const FetchDashboardData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 145, 16, 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final status =
                                _dayStatus['status'] as String? ?? 'loading';
                            final openDateStr =
                                _dayStatus['openDate'] as String?;
                            final serverDateStr =
                                _dayStatus['currentServerDate'] as String?;

                            String displayedDate = 'Checking...';
                            Color dateColor = Colors.black87;
                            String? subText;

                            // Prefer server current date
                            final dateToShow = serverDateStr ?? openDateStr;

                            if (dateToShow != null && dateToShow.isNotEmpty) {
                              try {
                                final dt = DateTime.parse(dateToShow);
                                displayedDate =
                                    DateFormat('EEE, d MMM yyyy').format(dt);
                              } catch (e) {
                                displayedDate = dateToShow;
                              }
                            }

                            // Special labels
                            if (status == 'previous_open') {
                              dateColor = Colors.red;
                              subText = 'Previous day still open';
                            } else if (status == 'no_open_day') {
                              subText = 'Day closed – ready to open';
                            } else if (status == 'loading') {
                              dateColor = Colors.grey[600]!;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayedDate,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: dateColor,
                                  ),
                                ),
                                if (subText != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: dateColor == Colors.red
                                          ? Colors.red[700]
                                          : Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        BlocBuilder<DashboardBloc, DashboardState>(
                          builder: (context, state) {
                            return Text(
                              'Fiscal year:- ${state.currentFiscalYear?.name ?? "Loading..."}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_dayStatus['status'] == 'previous_open' ||
                        _isTodayOpen)
                      ElevatedButton.icon(
                        onPressed: _closeDay,
                        icon: const Icon(Icons.lock_clock, size: 18),
                        label: Text(
                          _dayStatus['status'] == 'previous_open'
                              ? 'Close Previous Day'
                              : 'Close Day',
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF971313),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _openToday,
                        icon: const Icon(Icons.lock_open, size: 18),
                        label: const Text('Open Day',
                            style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10750E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // The rest of your dashboard remains unchanged
            SliverToBoxAdapter(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 8, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dashboard',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF65636D))),
                              SizedBox(height: 4),
                              Text(
                                'Overview of your purchases, sales,\nand returns',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF9E9DA2)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (state.allFiscalYears != null &&
                            state.allFiscalYears!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.currentFiscalYear?.name ?? 'FY',
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                dropdownColor: const Color(0xFFFF9800),
                                items: state.allFiscalYears!.map((fy) {
                                  return DropdownMenuItem<String>(
                                    value: fy.name,
                                    child: Text(fy.name),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue == null) return;
                                  final selected = state.allFiscalYears!
                                      .firstWhere((fy) => fy.name == newValue);
                                  context
                                      .read<DashboardBloc>()
                                      .add(ChangeFiscalYear(selected.id));
                                },
                              ),
                            ),
                          )
                        else
                          const Text('Loading FY...',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),

            SliverToBoxAdapter(
              child: BlocListener<DashboardBloc, DashboardState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    debugPrint('DashboardBloc Error: ${state.errorMessage}');
                  }
                  if (state.refreshDashboard == true) {
                    context
                        .read<DashboardBloc>()
                        .add(const FetchDashboardData());
                    context.read<DashboardBloc>().add(const ResetRefreshFlag());
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
                      return const DashboardShimmer();
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

                    final hasRealData = (state.totalSales ?? 0) > 0 ||
                        (state.totalPurchases ?? 0) > 0 ||
                        (state.totalVatCollected ?? 0) > 0 ||
                        (state.purchaseReturns ?? 0) > 0 ||
                        (state.salesReturns ?? 0) > 0 ||
                        (state.returnReasons?.isNotEmpty ?? false);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!hasRealData)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.orange.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.orange.shade800),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'No transactions found yet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'The dashboard shows zero values because:\n'
                                    '• No sales, purchases or returns recorded yet, or\n'
                                    '• The current fiscal year has no activity.\n\n'
                                    'Add some transactions to see actual numbers.',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Wrap(
                            spacing: 0,
                            runSpacing: 0,
                            children: [
                              DashboardCard(
                                  title: 'Total Purchases',
                                  value:
                                      'Rs. ${state.totalPurchases?.toStringAsFixed(2) ?? '0.00'}',
                                  iconPath: 'assets/images/shopping-cart 1.png',
                                  cardColor: const Color(0xFFEBF0FF)),
                              DashboardCard(
                                  title: 'VAT Collected',
                                  value:
                                      'Rs. ${state.totalVatCollected?.toStringAsFixed(2) ?? '0.00'}',
                                  iconPath: 'assets/images/tax.png',
                                  cardColor: const Color(0xFFFAF3FF)),
                              DashboardCard(
                                  title: 'Purchase Returns',
                                  value:
                                      'Rs. ${state.purchaseReturns?.toStringAsFixed(2) ?? '0.00'}',
                                  iconPath: 'assets/images/product-return.png',
                                  cardColor: const Color(0xFFFFF7FD)),
                              DashboardCard(
                                  title: 'Total Sales',
                                  value:
                                      'Rs. ${state.totalSales?.toStringAsFixed(2) ?? '0.00'}',
                                  iconPath: 'assets/images/invoice.png',
                                  cardColor: const Color(0xFFFFF9F7)),
                              DashboardCard(
                                  title: 'Sales Returns',
                                  value:
                                      'Rs. ${state.salesReturns?.toStringAsFixed(2) ?? '0.00'}',
                                  iconPath: 'assets/images/sales-return.png',
                                  cardColor: const Color(0xFFEBF0FF)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Image.asset(
                            'assets/images/Dashboard_Line.png',
                            width: double.infinity,
                            height: 2,
                            fit: BoxFit.fill,
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
