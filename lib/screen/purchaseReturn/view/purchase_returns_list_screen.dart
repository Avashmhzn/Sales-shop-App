import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/screen/purchaseReturn/bloc/purchase_return_bloc.dart';
import 'add_purchase_return_screen.dart';

class PurchaseReturnsListScreen extends StatelessWidget {
  const PurchaseReturnsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Returns')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPurchaseReturnScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
        builder: (context, state) {
          if (state is PurchaseReturnsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PurchaseReturnError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is PurchaseReturnsLoaded) {
            if (state.returns.isEmpty) {
              return const Center(child: Text('No purchase returns found'));
            }

            return ListView.builder(
              itemCount: state.returns.length,
              itemBuilder: (context, index) {
                final ret = state.returns[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('${ret.invoiceNumber} – ${ret.partyName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reason: ${ret.reason}'),
                        Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(ret.returnDate)}'),
                      ],
                    ),
                    trailing: Text(
                      'Rs. ${ret.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () {
                      // You can open details dialog here later
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
