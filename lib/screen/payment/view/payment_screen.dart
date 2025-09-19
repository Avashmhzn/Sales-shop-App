import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleup_app/model/payment_response.dart';
import 'package:saleup_app/screen/payment/bloc/payment_bloc.dart';
import 'package:saleup_app/screen/payment/bloc/payment_event.dart';
import 'package:saleup_app/screen/payment/bloc/payment_state.dart';
import 'package:saleup_app/screen/payment/widget/payment_detail_dialog.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasFetchedPayments = false;

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
    final bloc = BlocProvider.of<PaymentBloc>(context, listen: false);
    print('PaymentBloc in didChangeDependencies: $bloc');
    if (!_hasFetchedPayments && bloc.state.payments.isEmpty) {
      bloc.add(const FetchPayments());
      _hasFetchedPayments = true;
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

  List<PaymentData> _filterPayments(List<PaymentData> payments) {
    return payments.where((payment) {
      if (_searchQuery.isNotEmpty) {
        return (payment.refNumber ?? '')
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

  void _showDetailsPopup(BuildContext parentContext, PaymentData payment) {
    print('Initiating _showDetailsPopup for paymentId: ${payment.id}');
    final bloc = BlocProvider.of<PaymentBloc>(parentContext, listen: false);
    if (bloc.state.paymentDetail?.id != payment.id) {
      bloc.add(FetchPaymentById(payment.id));
    }
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<PaymentBloc>(parentContext),
        child: PaymentDetailDialog(paymentId: payment.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocListener<PaymentBloc, PaymentState>(
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
                    "Payments",
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
              child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  print('BlocBuilder state: isLoading=${state.isLoading}, '
                      'payments.length=${state.payments.length}, '
                      'error=${state.errorMessage}');
                  if (state.isLoading && state.payments.isEmpty) {
                    return _buildShimmerEffect(screenWidth, screenHeight);
                  }
                  if (state.errorMessage != null) {
                    return Center(child: Text(state.errorMessage!));
                  }
                  final filteredPayments = _filterPayments(state.payments);
                  print('Filtered payments count: ${filteredPayments.length}, '
                      '_searchQuery: $_searchQuery');

                  if (filteredPayments.isEmpty) {
                    return const Center(child: Text('No payments available'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return PaymentCard(
                        key: ValueKey(payment.id),
                        payment: payment,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onTap: () => _showDetailsPopup(context, payment),
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

class PaymentCard extends StatelessWidget {
  final PaymentData payment;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final createdOnStr = payment.createdOn ?? '';
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
                          'Payment: ${payment.refNumber ?? 'N/A'}',
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
                              'Supplier: ${payment.supplier ?? 'N/A'}',
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
                          'Amount: \$${payment.amount.toStringAsFixed(2)}',
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
