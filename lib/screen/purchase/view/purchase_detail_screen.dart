// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/core/network/dio_client.dart';
// import 'package:saleup_app/model/purchase_response.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
// import 'package:saleup_app/screen/purchase/bloc/purchase_event.dart';
// import 'package:saleup_app/screen/purchase/view/edit_purchase_screen.dart';

// class PurchaseDetailScreen extends StatefulWidget {
//   final PurchaseData purchase;

//   const PurchaseDetailScreen({super.key, required this.purchase});

//   @override
//   State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
// }

// class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
//   bool _isDeleting = false;

//   Future<void> _deletePurchase() async {
//     setState(() => _isDeleting = true);
//     try {
//       final dio = DioClient().dio;
//       final purchaseId = widget.purchase.id;

//       print('Deleting purchase ID: $purchaseId');

//       final res = await dio.delete(
//         '/purchase/delete_purchases/',
//         queryParameters: {
//           'purchase_id': purchaseId
//         }, // ← FIXED: use 'purchase_id'
//       );

//       print('DELETE status: ${res.statusCode}');
//       print('DELETE body: ${res.data}');

//       final resp = PurchaseResponse.fromJson(res.data);
//       if (!mounted) return;

//       if (resp.success) {
//         context.read<PurchaseBloc>().add(const FetchPurchases());
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Purchase deleted successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context, true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(resp.message ?? 'Delete failed'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;

//       String msg = 'Delete error';
//       if (e is DioException) {
//         msg =
//             'Network error: ${e.message} (HTTP ${e.response?.statusCode})\n${e.response?.data ?? ''}';
//       } else {
//         msg = 'Error: $e';
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(msg), backgroundColor: Colors.red),
//       );
//     } finally {
//       if (mounted) setState(() => _isDeleting = false);
//     }
//   }

//   void _confirmDelete() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Delete Purchase'),
//         content: const Text('Are you sure you want to delete this purchase?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deletePurchase();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53935),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _editPurchase() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditPurchaseScreen(purchase: widget.purchase),
//       ),
//     ).then((updated) {
//       if (updated == true) {
//         context.read<PurchaseBloc>().add(const FetchPurchases());
//         Navigator.pop(context, true);
//       }
//     });
//   }

//   String _fmtDate(DateTime? d) =>
//       d != null ? DateFormat('MM/dd/yyyy').format(d) : '-';

//   @override
//   Widget build(BuildContext context) {
//     final p = widget.purchase;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ── Header ──
//             Container(
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       width: 38,
//                       height: 38,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.08),
//                             blurRadius: 6,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(Icons.arrow_back_ios_new,
//                           size: 16, color: Colors.black87),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Purchase',
//                         style: TextStyle(
//                           color: Colors.black87,
//                           fontSize: 22,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Text(
//                         'Stock Inventory > Purchase > Detail',
//                         style: TextStyle(color: Colors.grey[500], fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // ── Detail Card ──
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.06),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Party name
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
//                         child: Text(
//                           p.party ?? 'Unknown Party',
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1A1A2E),
//                           ),
//                         ),
//                       ),

//                       const Divider(height: 1, color: Color(0xFFF0F0F0)),

//                       // Purchase detail rows
//                       Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           children: [
//                             _detailRow('ID', '${p.id ?? '-'}'),
//                             _detailRow('Voucher No', p.voucherNumber ?? '-'),
//                             _detailRow('Invoice No', p.invoiceNumber ?? '-'),
//                             _detailRow('Bill Type', p.billType ?? '-'),
//                             _detailRow('Party', p.party ?? '-'),
//                             _detailRow('Sub Total',
//                                 'NPR ${(p.subTotal ?? 0).toStringAsFixed(2)}'),
//                             _detailRow('VAT',
//                                 'NPR ${(p.vat ?? 0).toStringAsFixed(2)}'),
//                             _detailRow('Discount',
//                                 'NPR ${(p.discount ?? 0).toStringAsFixed(2)}'),
//                             _detailRow('Total Amount',
//                                 'NPR ${(p.total ?? 0).toStringAsFixed(2)}'),
//                           ],
//                         ),
//                       ),

//                       // ── Items Section ──
//                       // uses purchaseItems (correct field name from model)
//                       if (p.purchaseItems != null &&
//                           p.purchaseItems!.isNotEmpty) ...[
//                         const Divider(height: 1, color: Color(0xFFF0F0F0)),
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//                           child: Text(
//                             'Items',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                         ),
//                         ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//                           itemCount: p.purchaseItems!.length,
//                           separatorBuilder: (_, __) =>
//                               const Divider(color: Color(0xFFF0F0F0)),
//                           itemBuilder: (_, i) {
//                             final item = p.purchaseItems![i];
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     item.product ?? '-',
//                                     style: const TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Qty: ${item.quantity ?? 0}  •  Unit: ${item.unit ?? '-'}  •  Batch: ${item.batchNumber ?? '-'}',
//                                     style: TextStyle(
//                                         fontSize: 13, color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     'Expiry: ${_fmtDate(item.expiryDate)}  •  Complementary: ${item.isComplementary ? "Yes" : "No"}',
//                                     style: TextStyle(
//                                         fontSize: 13, color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     'Cost: NPR ${(item.costPrice ?? 0).toStringAsFixed(2)}  •  Total: NPR ${(item.total ?? 0).toStringAsFixed(2)}',
//                                     style: TextStyle(
//                                         fontSize: 13, color: Colors.grey[600]),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ],

//                       const Divider(height: 1, color: Color(0xFFF0F0F0)),

//                       // ── Action Buttons ──
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             ElevatedButton.icon(
//                               onPressed: _editPurchase,
//                               icon: Image.asset(
//                                 'assets/images/edit.png',
//                                 width: 16,
//                                 height: 16,
//                                 color: Colors.white,
//                               ),
//                               label: const Text('Edit',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white)),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF4CAF50),
//                                 elevation: 0,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             ElevatedButton.icon(
//                               onPressed: _isDeleting ? null : _confirmDelete,
//                               icon: _isDeleting
//                                   ? const SizedBox(
//                                       width: 16,
//                                       height: 16,
//                                       child: CircularProgressIndicator(
//                                           color: Colors.white, strokeWidth: 2),
//                                     )
//                                   : Image.asset(
//                                       'assets/images/delete.png',
//                                       width: 16,
//                                       height: 16,
//                                       color: Colors.white,
//                                     ),
//                               label: const Text('Delete',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white)),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFE53935),
//                                 elevation: 0,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 130,
//             child: Text(
//               '$label :',
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF333333),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/purchase_response.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_bloc.dart';
import 'package:saleup_app/screen/purchase/bloc/purchase_event.dart';
import 'package:saleup_app/screen/purchase/view/edit_purchase_screen.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final PurchaseData purchase;

  const PurchaseDetailScreen({super.key, required this.purchase});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  bool _isDeleting = false;

  Future<void> _deletePurchase() async {
    setState(() => _isDeleting = true);

    try {
      final dio = DioClient().dio;
      final purchaseId = widget.purchase.id;

      final res = await dio.delete(
        '/purchase/delete_purchases/',
        queryParameters: {'purchase_id': purchaseId},
      );

      final resp = PurchaseResponse.fromJson(res.data);

      if (resp.success) {
        if (!mounted) return;
        context.read<PurchaseBloc>().add(const FetchPurchases());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        if (context.canPop()) {
          context.pop(true);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.message ?? 'Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String msg = 'Delete error';
      if (e is DioException) {
        msg =
            'Network error: ${e.message} (HTTP ${e.response?.statusCode})\n${e.response?.data ?? ''}';
      } else {
        msg = 'Error: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Delete Purchase'),
          content: const Text('Are you sure you want to delete this purchase?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _isDeleting
                  ? null
                  : () async {
                      Navigator.pop(dialogContext);
                      await _deletePurchase();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _editPurchase() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PurchaseBloc>(),
          child: EditPurchaseScreen(purchase: widget.purchase),
        ),
      ),
    ).then((updated) {
      if (updated == true && mounted) {
        context.read<PurchaseBloc>().add(const FetchPurchases());
        if (context.canPop()) context.pop(true);
      }
    });
  }

  String _fmtDate(DateTime? d) =>
      d != null ? DateFormat('MM/dd/yyyy').format(d) : '-';

  @override
  Widget build(BuildContext context) {
    final p = widget.purchase;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 16, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Purchase',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Stock Inventory > Purchase > Detail',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Text(
                          p.party ?? 'Unknown Party',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _detailRow('ID', '${p.id ?? '-'}'),
                            _detailRow('Voucher No', p.voucherNumber ?? '-'),
                            _detailRow('Invoice No', p.invoiceNumber ?? '-'),
                            _detailRow('Bill Type', p.billType ?? '-'),
                            _detailRow('Party', p.party ?? '-'),
                            _detailRow('Sub Total',
                                'NPR ${(p.subTotal ?? 0).toStringAsFixed(2)}'),
                            _detailRow('VAT',
                                'NPR ${(p.vat ?? 0).toStringAsFixed(2)}'),
                            _detailRow('Discount',
                                'NPR ${(p.discount ?? 0).toStringAsFixed(2)}'),
                            _detailRow('Total Amount',
                                'NPR ${(p.total ?? 0).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      if (p.purchaseItems != null &&
                          p.purchaseItems!.isNotEmpty) ...[
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          itemCount: p.purchaseItems!.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: Color(0xFFF0F0F0)),
                          itemBuilder: (_, i) {
                            final item = p.purchaseItems![i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product ?? '-',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity ?? 0}  •  Unit: ${item.unit ?? '-'}  •  Batch: ${item.batchNumber ?? '-'}',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Expiry: ${_fmtDate(item.expiryDate)}  •  Complementary: ${item.isComplementary ? "Yes" : "No"}',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Cost: NPR ${(item.costPrice ?? 0).toStringAsFixed(2)}  •  Total: NPR ${(item.total ?? 0).toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _editPurchase,
                              icon: Image.asset(
                                'assets/images/edit.png',
                                width: 16,
                                height: 16,
                                color: Colors.white,
                              ),
                              label: const Text('Edit',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _isDeleting ? null : _confirmDelete,
                              icon: _isDeleting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Image.asset(
                                      'assets/images/delete.png',
                                      width: 16,
                                      height: 16,
                                      color: Colors.white,
                                    ),
                              label: const Text('Delete',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
