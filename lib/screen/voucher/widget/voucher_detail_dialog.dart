// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:saleup_app/model/voucher_response.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_bloc.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_event.dart';
// import 'package:saleup_app/screen/voucher/bloc/voucher_state.dart';

// class VoucherDetailDialog extends StatelessWidget {
//   final int voucherId;

//   const VoucherDetailDialog({super.key, required this.voucherId});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//       backgroundColor: Colors.white,
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Voucher Details',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.grey),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       content: Container(
//         constraints: const BoxConstraints(maxHeight: 400),
//         child: BlocBuilder<VoucherBloc, VoucherState>(
//           builder: (context, state) {
//             if (state.isLoading) {
//               return const SizedBox(
//                 height: 200,
//                 child: Center(child: CircularProgressIndicator()),
//               );
//             }
//             if (state.errorMessage != null) {
//               return SizedBox(
//                 height: 200,
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         state.errorMessage!,
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                               color: Colors.red,
//                               fontSize: 16,
//                             ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           context
//                               .read<VoucherBloc>()
//                               .add(FetchVoucherById(voucherId));
//                         },
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//             if (state.voucherDetail == null) {
//               return const SizedBox(
//                 height: 200,
//                 child: Center(
//                   child: Text(
//                     'No voucher details available',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               );
//             }
//             final voucher = state.voucherDetail!;
//             final voucherDateStr = voucher.voucherDate ?? '';
//             String formattedDateTime = 'Unknown';
//             if (voucherDateStr.isNotEmpty) {
//               try {
//                 final voucherDate = DateTime.parse(voucherDateStr);
//                 formattedDateTime =
//                     DateFormat('MMM dd, yyyy hh:mm a').format(voucherDate);
//               } catch (e) {
//                 formattedDateTime = 'Invalid Date';
//               }
//             }

//             final totalDebit =
//                 double.tryParse(voucher.totalDebit ?? '0.0') ?? 0.0;
//             final totalCredit =
//                 double.tryParse(voucher.totalCredit ?? '0.0') ?? 0.0;

//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildDetailRow(Icons.receipt, 'Voucher Number',
//                       voucher.voucherNumber ?? 'N/A'),
//                   _buildDetailRow(
//                       Icons.category, 'Type', voucher.type ?? 'N/A'),
//                   _buildDetailRow(
//                       Icons.calendar_today, 'Date', formattedDateTime),
//                   _buildDetailRow(
//                       Icons.info, 'Status', voucher.status ?? 'N/A'),
//                   _buildDetailRow(Icons.attach_money, 'Total Debit',
//                       '\$${totalDebit.toStringAsFixed(2)}'),
//                   _buildDetailRow(Icons.attach_money, 'Total Credit',
//                       '\$${totalCredit.toStringAsFixed(2)}'),
//                   _buildDetailRow(
//                       Icons.notes, 'Narration', voucher.narration ?? 'N/A'),
//                   _buildDetailRow(
//                       Icons.person, 'Signature', voucher.signature ?? 'N/A'),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Items',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           color: Colors.black87,
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   if (voucher.voucherItems.isEmpty)
//                     Text(
//                       'No items available',
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: Colors.grey[700],
//                           ),
//                     )
//                   else
//                     ...voucher.voucherItems.map((item) => _buildItemRow(item)),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//       actions: [],
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
//               style: const TextStyle(
//                 color: Colors.black87,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemRow(VoucherItem item) {
//     final debit = double.tryParse(item.debit ?? '0.0') ?? 0.0;
//     final credit = double.tryParse(item.credit ?? '0.0') ?? 0.0;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: ExpansionTile(
//         leading: Icon(Icons.inventory, color: Colors.grey[600], size: 20),
//         title: Text(
//           'Account: ${item.account ?? 'N/A'}',
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 14,
//           ),
//         ),
//         children: [
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Debit: \$${debit.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontSize: 12,
//                   ),
//                 ),
//                 Text(
//                   'Credit: \$${credit.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontSize: 12,
//                   ),
//                 ),
//                 Text(
//                   'Tax Line: ${item.isTaxLine ?? false ? 'Yes' : 'No'}',
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontSize: 12,
//                   ),
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
    print('Building VoucherDetailDialog for voucherId: $voucherId');
    // Trigger fetch if voucherDetail is null or doesn't match voucherId
    final state = context.read<VoucherBloc>().state;
    if (state.voucherDetail == null || state.voucherDetail!.id != voucherId) {
      print('Triggering FetchVoucherById for voucherId: $voucherId');
      context.read<VoucherBloc>().add(FetchVoucherById(voucherId));
    }

    return BlocBuilder<VoucherBloc, VoucherState>(
      builder: (context, state) {
        print('VoucherDetailDialog state: isLoading=${state.isLoading}, '
            'voucherDetail=${state.voucherDetail != null ? "non-null" : "null"}, '
            'errorMessage=${state.errorMessage}');

        // Loading state
        if (state.isLoading) {
          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Error state
        if (state.errorMessage != null) {
          print('Error state: ${state.errorMessage}');
          return AlertDialog(
            title: const Text('Error'),
            content: Text(
              'Error: ${state.errorMessage}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('Retrying FetchVoucherById for voucherId: $voucherId');
                  context.read<VoucherBloc>().add(FetchVoucherById(voucherId));
                },
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () {
                  print('Closing dialog due to error');
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        }

        // No voucher details or ID mismatch
        if (state.voucherDetail == null ||
            state.voucherDetail!.id != voucherId) {
          print('No voucher details available or ID mismatch');
          return AlertDialog(
            title: const Text('No Data'),
            content: Text(
              'No voucher details available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('Retrying FetchVoucherById for voucherId: $voucherId');
                  context.read<VoucherBloc>().add(FetchVoucherById(voucherId));
                },
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () {
                  print('Closing dialog due to null voucherDetail');
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        }

        // Success state
        final voucher = state.voucherDetail!;
        final voucherDateStr = voucher.voucherDate ?? '';
        String formattedDateTime = 'Unknown';
        if (voucherDateStr.isNotEmpty) {
          try {
            final voucherDate = DateTime.parse(voucherDateStr);
            formattedDateTime =
                DateFormat('MMM dd, yyyy hh:mm a').format(voucherDate);
            print('Formatted date: $voucherDateStr -> $formattedDateTime');
          } catch (e) {
            print('Error formatting date: $e');
            formattedDateTime = 'Invalid Date';
          }
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Voucher Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  print('Closing VoucherDetailDialog');
                  Navigator.pop(context);
                },
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
                  _buildDetailRow(
                    context,
                    Icons.receipt,
                    'Voucher Number',
                    voucher.voucherNumber ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Date',
                    formattedDateTime,
                  ),
                  _buildDetailRow(
                    context,
                    Icons.category,
                    'Type',
                    voucher.type ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.info,
                    'Status',
                    voucher.status ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.attach_money,
                    'Total Debit',
                    '\$${voucher.totalDebit.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.attach_money,
                    'Total Credit',
                    '\$${voucher.totalCredit.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.notes,
                    'Narration',
                    voucher.narration ?? 'N/A',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Voucher Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (voucher.voucherItems.isNotEmpty)
                    ...voucher.voucherItems
                        .map((item) => _buildItemRow(context, item))
                  else
                    Text(
                      'No items available',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
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

  Widget _buildItemRow(BuildContext context, VoucherItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ExpansionTile(
        leading: Icon(Icons.inventory, color: Colors.grey[600], size: 20),
        title: Text(
          'Account: ${item.account ?? 'N/A'}',
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
                  'Debit: \$${item.debit.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  'Credit: \$${item.credit.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  'Tax Line: ${item.isTaxLine ?? false ? 'Yes' : 'No'}',
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
}
