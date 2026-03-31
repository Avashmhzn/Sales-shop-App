import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/model/receipt_response.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_state.dart';
import 'package:saleup_app/screen/receipts/view/add_receipt_screen.dart';
import 'package:saleup_app/screen/receipts/widget/receipt_detail_dialog.dart';
import 'package:shimmer/shimmer.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasFetchedReceipts = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final bloc = BlocProvider.of<ReceiptBloc>(context, listen: false);
    if (!_hasFetchedReceipts && bloc.state.receipts.isEmpty) {
      bloc.add(const FetchReceipts());
      _hasFetchedReceipts = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  List<ReceiptData> _filterReceipts(List<ReceiptData> receipts) {
    if (_searchQuery.isEmpty) return receipts;
    return receipts
        .where((r) => (r.refNumber ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildShimmerEffect(double screenWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.03),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 16,
                      width: screenWidth * 0.4,
                      color: Colors.white),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height: 14,
                          width: screenWidth * 0.3,
                          color: Colors.white),
                      Container(
                          height: 14,
                          width: screenWidth * 0.2,
                          color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsPopup(BuildContext parentContext, ReceiptData receipt) {
    final bloc = BlocProvider.of<ReceiptBloc>(parentContext, listen: false);
    if (bloc.state.receiptDetail?.id != receipt.id) {
      bloc.add(FetchReceiptById(receipt.id));
    }
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<ReceiptBloc>(parentContext),
        child: ReceiptDetailDialog(receiptId: receipt.id),
      ),
    );
  }

  void _navigateToAddReceipt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<ReceiptBloc>(context),
          child: const AddReceiptScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: BlocListener<ReceiptBloc, ReceiptState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + New Receipt button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Receipts',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddReceipt(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('New Receipt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5A623),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Search',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Receipt list
              Expanded(
                child: BlocBuilder<ReceiptBloc, ReceiptState>(
                  builder: (context, state) {
                    if (state.isLoading && state.receipts.isEmpty) {
                      return _buildShimmerEffect(screenWidth);
                    }
                    if (state.errorMessage != null && state.receipts.isEmpty) {
                      return Center(child: Text(state.errorMessage!));
                    }

                    final filtered = _filterReceipts(state.receipts);
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No receipts available'));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final receipt = filtered[index];
                        return ReceiptCard(
                          key: ValueKey(receipt.id),
                          receipt: receipt,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          onTap: () => _showDetailsPopup(context, receipt),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptCard extends StatelessWidget {
  final ReceiptData receipt;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDateTime = 'Unknown';
    final createdOnStr = receipt.createdOn ?? '';
    if (createdOnStr.isNotEmpty) {
      try {
        formattedDateTime = DateFormat('MMM dd, yyyy hh:mm a')
            .format(DateTime.parse(createdOnStr));
      } catch (_) {
        formattedDateTime = 'Invalid Date';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt: ${receipt.refNumber ?? 'N/A'}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer: ${receipt.customer ?? 'N/A'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      'Date: $formattedDateTime',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: Rs.${receipt.amount.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
