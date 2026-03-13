// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/model/voucher_response.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_state.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';

// class VoucherDetailDialog extends StatelessWidget {
//   final int voucherId;

//   const VoucherDetailDialog({super.key, required this.voucherId});

//   @override
//   Widget build(BuildContext context) {
//     print('Building VoucherDetailDialog for voucherId: $voucherId');
//     // Trigger fetch if voucherDetail is null or doesn't match voucherId
//     final state = context.read<VoucherBloc>().state;
//     if (state.voucherDetail == null || state.voucherDetail!.id != voucherId) {
//       print('Triggering FetchVoucherById for voucherId: $voucherId');
//       context.read<VoucherBloc>().add(FetchVoucherById(voucherId));
//     }

//     return BlocBuilder<VoucherBloc, VoucherState>(
//       builder: (context, state) {
//         print('VoucherDetailDialog state: isLoading=${state.isLoading}, '
//             'voucherDetail=${state.voucherDetail != null ? "non-null" : "null"}, '
//             'errorMessage=${state.errorMessage}');

//         // Loading state
//         if (state.isLoading) {
//           return const AlertDialog(
//             content: SizedBox(
//               height: 100,
//               child: Center(child: CircularProgressIndicator()),
//             ),
//           );
//         }

//         // Error state
//         if (state.errorMessage != null) {
//           print('Error state: ${state.errorMessage}');
//           return AlertDialog(
//             title: const Text('Error'),
//             content: Text(
//               'Error: ${state.errorMessage}',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.black87,
//                   ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   print('Retrying FetchVoucherById for voucherId: $voucherId');
//                   context.read<VoucherBloc>().add(FetchVoucherById(voucherId));
//                 },
//                 child: const Text('Retry'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   print('Closing dialog due to error');
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Close'),
//               ),
//             ],
//           );
//         }

//         // No voucher details or ID mismatch
//         if (state.voucherDetail == null ||
//             state.voucherDetail!.id != voucherId) {
//           print('No voucher details available or ID mismatch');
//           return AlertDialog(
//             title: const Text('No Data'),
//             content: Text(
//               'No voucher details available',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.black87,
//                   ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   print('Retrying FetchVoucherById for voucherId: $voucherId');
//                   context.read<VoucherBloc>().add(FetchVoucherById(voucherId));
//                 },
//                 child: const Text('Retry'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   print('Closing dialog due to null voucherDetail');
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Close'),
//               ),
//             ],
//           );
//         }

//         // Success state
//         final voucher = state.voucherDetail!;
//         final voucherDateStr = voucher.voucherDate ?? '';
//         String formattedDateTime = 'Unknown';
//         if (voucherDateStr.isNotEmpty) {
//           try {
//             final voucherDate = DateTime.parse(voucherDateStr);
//             formattedDateTime =
//                 DateFormat('MMM dd, yyyy hh:mm a').format(voucherDate);
//             print('Formatted date: $voucherDateStr -> $formattedDateTime');
//           } catch (e) {
//             print('Error formatting date: $e');
//             formattedDateTime = 'Invalid Date';
//           }
//         }

//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           backgroundColor: Colors.white,
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Voucher Details',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, color: Colors.grey),
//                 onPressed: () {
//                   print('Closing VoucherDetailDialog');
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//           content: Container(
//             constraints: const BoxConstraints(maxHeight: 400),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildDetailRow(
//                     context,
//                     Icons.receipt,
//                     'Voucher Number',
//                     voucher.voucherNumber ?? 'N/A',
//                   ),
//                   _buildDetailRow(
//                     context,
//                     Icons.calendar_today,
//                     'Date',
//                     formattedDateTime,
//                   ),
//                   _buildDetailRow(
//                     context,
//                     Icons.category,
//                     'Type',
//                     voucher.type ?? 'N/A',
//                   ),
//                   _buildDetailRow(
//                     context,
//                     Icons.info,
//                     'Status',
//                     voucher.status ?? 'N/A',
//                   ),
//                   _buildDetailRow(
//                     context,
//                     Icons.attach_money,
//                     'Total Debit',
//                     '\$${voucher.totalDebit.toStringAsFixed(2)}',
//                   ),
//                   _buildDetailRow(
//                     context,
//                     Icons.attach_money,
//                     'Total Credit',
//                     '\$${voucher.totalCredit.toStringAsFixed(2)}',
//                   ),
//                   _buildDetailRow(
//                     context,
//                     Icons.notes,
//                     'Narration',
//                     voucher.narration ?? 'N/A',
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Voucher Items',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           color: Colors.black87,
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   if (voucher.voucherItems.isNotEmpty)
//                     ...voucher.voucherItems
//                         .map((item) => _buildItemRow(context, item))
//                   else
//                     Text(
//                       'No items available',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Colors.grey,
//                           ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDetailRow(
//       BuildContext context, IconData icon, String label, String value) {
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

//   Widget _buildItemRow(BuildContext context, VoucherItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: ExpansionTile(
//         leading: Icon(Icons.inventory, color: Colors.grey[600], size: 20),
//         title: Text(
//           'Account: ${item.account ?? 'N/A'}',
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
//                   'Debit: \$${item.debit.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//                 Text(
//                   'Credit: \$${item.credit.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[700],
//                       ),
//                 ),
//                 Text(
//                   'Tax Line: ${item.isTaxLine ?? false ? 'Yes' : 'No'}',
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
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/model/voucher_response.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_state.dart';
import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';

class VoucherDetailDialog extends StatelessWidget {
  final int voucherId;

  const VoucherDetailDialog({super.key, required this.voucherId});

  @override
  Widget build(BuildContext context) {
    final state = context.read<VoucherBloc>().state;
    if (state.voucherDetail == null || state.voucherDetail!.id != voucherId) {
      context.read<VoucherBloc>().add(FetchVoucherById(voucherId));
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: BlocBuilder<VoucherBloc, VoucherState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null) {
            return _ErrorContent(
              message: state.errorMessage!,
              onRetry: () =>
                  context.read<VoucherBloc>().add(FetchVoucherById(voucherId)),
              onClose: () => Navigator.pop(context),
            );
          }

          if (state.voucherDetail == null ||
              state.voucherDetail!.id != voucherId) {
            return _ErrorContent(
              message: 'No voucher details available.',
              onRetry: () =>
                  context.read<VoucherBloc>().add(FetchVoucherById(voucherId)),
              onClose: () => Navigator.pop(context),
            );
          }

          return _VoucherDetailContent(
            voucher: state.voucherDetail!,
            onClose: () => Navigator.pop(context),
          );
        },
      ),
    );
  }
}

// ── Detail Content ───────────────────────────────────────────────
class _VoucherDetailContent extends StatelessWidget {
  final VoucherData voucher;
  final VoidCallback onClose;

  const _VoucherDetailContent({required this.voucher, required this.onClose});

  String _fmtDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('M/d/yyyy, h:mm:ss a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Two-column rows matching API fields exactly
    final rows = [
      _RowData(
        left: _Field('Voucher ID', '${voucher.id}'),
        right: _Field('Voucher Number', voucher.voucherNumber ?? '-'),
      ),
      _RowData(
        left: _Field('Type', voucher.type ?? '-'),
        right: _Field('Date', _fmtDate(voucher.voucherDate)),
      ),
      _RowData(
        left: _Field('Total Debit', voucher.totalDebit.toStringAsFixed(2)),
        right: _Field('Total Credit', voucher.totalCredit.toStringAsFixed(2)),
      ),
      _RowData(
        left: _Field('Narration', voucher.narration ?? '-'),
        right: _Field('Signature', voucher.signature ?? '-'),
      ),
      _RowData(
        left: _Field('Status', voucher.status ?? '-'),
        right: _Field('Created By', voucher.createdBy ?? '-'),
      ),
      _RowData(
        // uses createdOn / updatedOn from VoucherData model
        left: _Field('Created On', _fmtDateTime(voucher.createdOn)),
        right: _Field('Updated On', _fmtDateTime(voucher.updatedOn)),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Title bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
          child: Row(
            children: [
              const Text(
                'Voucher Details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon:
                    const Icon(Icons.close, size: 20, color: Color(0xFF888888)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),

        // ── Grid rows ──
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...rows.map(
                  (row) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _FieldWidget(row.left)),
                            const SizedBox(width: 16),
                            Expanded(child: _FieldWidget(row.right)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ],
                  ),
                ),

                // ── Voucher Items section ──
                if (voucher.voucherItems.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Voucher Items',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ...voucher.voucherItems.map(
                    (item) => _VoucherItemRow(item: item),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Voucher Item expandable row ──────────────────────────────────
class _VoucherItemRow extends StatelessWidget {
  final VoucherItem item;
  const _VoucherItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      leading:
          Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey[500]),
      title: Text(
        item.account ?? 'N/A',
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333)),
      ),
      children: [
        Row(
          children: [
            Expanded(
                child: _FieldWidget(
                    _Field('Debit', item.debit.toStringAsFixed(2)))),
            const SizedBox(width: 16),
            Expanded(
                child: _FieldWidget(
                    _Field('Credit', item.credit.toStringAsFixed(2)))),
          ],
        ),
        const SizedBox(height: 6),
        _FieldWidget(_Field('Tax Line', item.isTaxLine == true ? 'Yes' : 'No')),
      ],
    );
  }
}

// ── Shared helpers ───────────────────────────────────────────────
class _Field {
  final String label;
  final String value;
  const _Field(this.label, this.value);
}

class _RowData {
  final _Field left;
  final _Field right;
  const _RowData({required this.left, required this.right});
}

class _FieldWidget extends StatelessWidget {
  final _Field field;
  const _FieldWidget(this.field);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${field.label}:',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          field.value,
          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
        ),
      ],
    );
  }
}

// ── Error / No-data content ──────────────────────────────────────
class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ErrorContent(
      {required this.message, required this.onRetry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style: const TextStyle(color: Color(0xFF444444), fontSize: 14)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry',
                    style: TextStyle(color: Color(0xFFE8891A))),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onClose,
                child: const Text('Close',
                    style: TextStyle(color: Color(0xFF888888))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
