import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/screen/payment/bloc/payment_bloc.dart';
import 'package:saleup_app/screen/payment/bloc/payment_event.dart';
import 'package:saleup_app/screen/payment/bloc/payment_state.dart';

class PaymentDetailDialog extends StatelessWidget {
  final int paymentId;

  const PaymentDetailDialog({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    print('Building PaymentDetailDialog for paymentId: $paymentId');
    final state = context.read<PaymentBloc>().state;
    if (state.paymentDetail == null || state.paymentDetail!.id != paymentId) {
      print('Triggering FetchPaymentById for paymentId: $paymentId');
      context.read<PaymentBloc>().add(FetchPaymentById(paymentId));
    }

    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        print('PaymentDetailDialog state: isLoading=${state.isLoading}, '
            'paymentDetail=${state.paymentDetail != null ? "non-null" : "null"}, '
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
                  print('Retrying FetchPaymentById for paymentId: $paymentId');
                  context.read<PaymentBloc>().add(FetchPaymentById(paymentId));
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

        if (state.paymentDetail == null ||
            state.paymentDetail!.id != paymentId) {
          print('No payment details available or ID mismatch');
          return AlertDialog(
            title: const Text('No Data'),
            content: Text(
              'No payment details available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('Retrying FetchPaymentById for paymentId: $paymentId');
                  context.read<PaymentBloc>().add(FetchPaymentById(paymentId));
                },
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () {
                  print('Closing dialog due to null paymentDetail');
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        }

        final payment = state.paymentDetail!;
        final createdOnStr = payment.createdOn ?? '';
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
                'Payment Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  print('Closing PaymentDetailDialog');
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
                    payment.refNumber ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.person,
                    'Supplier',
                    payment.supplier ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.attach_money,
                    'Amount',
                    '\$${payment.amount.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.payment,
                    'Payment Mode',
                    payment.paymentMode ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.payment,
                    'Cheque Number',
                    payment.chequeNumber ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Cheque Date',
                    payment.chequeDate ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    Icons.notes,
                    'Narration',
                    payment.narration ?? 'N/A',
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
          actions: [
            TextButton(
              onPressed: () {
                print('Closing PaymentDetailDialog');
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
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
