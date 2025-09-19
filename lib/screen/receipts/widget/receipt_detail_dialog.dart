import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_state.dart';

class ReceiptDetailDialog extends StatelessWidget {
  final int receiptId;

  const ReceiptDetailDialog({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    print('Building ReceiptDetailDialog for receiptId: $receiptId');
    final state = context.read<ReceiptBloc>().state;
    if (state.receiptDetail == null || state.receiptDetail!.id != receiptId) {
      print('Triggering FetchReceiptById for receiptId: $receiptId');
      context.read<ReceiptBloc>().add(FetchReceiptById(receiptId));
    }

    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        print('ReceiptDetailDialog state: isLoading=${state.isLoading}, '
            'receiptDetail=${state.receiptDetail != null ? "non-null" : "null"}, '
            'errorMessage=${state.errorMessage}');

        if (state.isLoading) {
          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

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
                  print('Retrying FetchReceiptById for receiptId: $receiptId');
                  context.read<ReceiptBloc>().add(FetchReceiptById(receiptId));
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

        if (state.receiptDetail == null ||
            state.receiptDetail!.id != receiptId) {
          print('No receipt details available or ID mismatch');
          return AlertDialog(
            title: const Text('No Data'),
            content: Text(
              'No receipt details available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('Retrying FetchReceiptById for receiptId: $receiptId');
                  context.read<ReceiptBloc>().add(FetchReceiptById(receiptId));
                },
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () {
                  print('Closing dialog due to null receiptDetail');
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        }

        final receipt = state.receiptDetail!;
        final createdOnStr = receipt.createdOn ?? '';
        String formattedDateTime = 'Unknown';
        if (createdOnStr.isNotEmpty) {
          try {
            final createdOn = DateTime.parse(createdOnStr);
            formattedDateTime =
                DateFormat('MMM dd, yyyy hh:mm a').format(createdOn);
            print('Formatted date: $createdOnStr -> $formattedDateTime');
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
                'Receipt Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  print('Closing ReceiptDetailDialog');
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
                    'Reference Number',
                    receipt.refNumber ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.person,
                    'Customer',
                    receipt.customer ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.attach_money,
                    'Amount',
                    '\$${receipt.amount.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.account_balance,
                    'Deposited In',
                    receipt.depositedIn ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.payment,
                    'Cheque Number',
                    receipt.chequeNumber ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Cheque Date',
                    receipt.chequeDate ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.notes,
                    'Narration',
                    receipt.narration ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.date_range,
                    'Created On',
                    formattedDateTime,
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
}
