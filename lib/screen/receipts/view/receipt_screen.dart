import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_bloc.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_event.dart';
import 'package:saleup_app/screen/receipts/bloc/receipt_state.dart';
import 'package:saleup_app/screen/receipts/widget/receipt_detail_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/model/receipt_response.dart';

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
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
      print('Search query updated: $_searchQuery');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final bloc = BlocProvider.of<ReceiptBloc>(context, listen: false);
    print('ReceiptBloc in didChangeDependencies: $bloc');
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
    print('Search cleared: _searchQuery is now $_searchQuery');
  }

  List<ReceiptData> _filterReceipts(List<ReceiptData> receipts) {
    return receipts.where((receipt) {
      if (_searchQuery.isNotEmpty) {
        return (receipt.refNumber ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  Widget _buildShimmerEffect(double screenWidth, double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.03),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 4),
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
          );
        },
      ),
    );
  }

  void _showDetailsPopup(BuildContext parentContext, ReceiptData receipt) {
    print('Initiating _showDetailsPopup for receiptId: ${receipt.id}');
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocListener<ReceiptBloc, ReceiptState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
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
                  Text(
                    "Receipts",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  labelText: 'Search Reference Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                              tooltip: 'Clear Search',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ReceiptBloc, ReceiptState>(
                builder: (context, state) {
                  print('BlocBuilder state: isLoading=${state.isLoading}, '
                      'receipts.length=${state.receipts.length}, '
                      'error=${state.errorMessage}');
                  if (state.isLoading && state.receipts.isEmpty) {
                    return _buildShimmerEffect(screenWidth, screenHeight);
                  }
                  if (state.errorMessage != null) {
                    return Center(child: Text(state.errorMessage!));
                  }
                  final filteredReceipts = _filterReceipts(state.receipts);
                  print('Filtered receipts count: ${filteredReceipts.length}, '
                      '_searchQuery: $_searchQuery');

                  if (filteredReceipts.isEmpty) {
                    return const Center(child: Text('No receipts available'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    itemCount: filteredReceipts.length,
                    itemBuilder: (context, index) {
                      final receipt = filteredReceipts[index];
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
    final createdOnStr = receipt.createdOn ?? '';
    String formattedDateTime = 'Unknown';
    if (createdOnStr.isNotEmpty) {
      try {
        final createdOn = DateTime.parse(createdOnStr);
        formattedDateTime =
            DateFormat('MMM dd, yyyy hh:mm a').format(createdOn);
        print('Card createdOnStr: $createdOnStr, createdOn: $createdOn, '
            'formatted: $formattedDateTime');
      } catch (e) {
        print('Error formatting createdOn date: $e');
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
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
                        const SizedBox(height: 6),
                        Text(
                          'Amount: \$${receipt.amount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
