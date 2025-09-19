import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_bloc.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_event.dart';
import 'package:saleup_app/screen/expiry/bloc/expiry_state.dart';
import 'package:saleup_app/model/expiry_response.dart';

class ExpiryScreen extends StatefulWidget {
  const ExpiryScreen({super.key});

  @override
  State<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ExpiryBloc>().add(const FetchExpiry());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ExpiryBloc>().add(SearchExpiry(query));
      }
    });
  }

  void showFilterBottomSheet(BuildContext context) {
    _animationController.forward();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      transitionAnimationController: _animationController,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return BlocProvider.value(
          value: context.read<ExpiryBloc>(),
          child: BlocBuilder<ExpiryBloc, ExpiryState>(
            builder: (sheetContext, state) {
              // Safeguard against null or empty expiryData
              final expiryData = state.expiryData;
              final uniqueProducts = expiryData
                  .map((e) => e.product)
                  .where((p) => p != null && p.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

              return Container(
                height: 650,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Expiry Date',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6.0,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              context.read<ExpiryBloc>().add(const SortExpiry(
                                  'Expiry Date', 'High to Low'));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                state.tempSortCriteria['Expiry Date'] ==
                                        'High to Low'
                                    ? Colors.brown[700]
                                    : Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          child: const Text('High to Low'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              context.read<ExpiryBloc>().add(const SortExpiry(
                                  'Expiry Date', 'Low to High'));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                state.tempSortCriteria['Expiry Date'] ==
                                        'Low to High'
                                    ? Colors.brown[700]
                                    : Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          child: const Text('Low to High'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6.0,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              context.read<ExpiryBloc>().add(
                                  const SortExpiry('Quantity', 'High to Low'));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                state.tempSortCriteria['Quantity'] ==
                                        'High to Low'
                                    ? Colors.brown[700]
                                    : Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          child: const Text('High to Low'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              context.read<ExpiryBloc>().add(
                                  const SortExpiry('Quantity', 'Low to High'));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                state.tempSortCriteria['Quantity'] ==
                                        'Low to High'
                                    ? Colors.brown[700]
                                    : Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          child: const Text('Low to High'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Selling Price',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6.0,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              context.read<ExpiryBloc>().add(const SortExpiry(
                                  'Selling Price', 'High to Low'));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                state.tempSortCriteria['Selling Price'] ==
                                        'High to Low'
                                    ? Colors.brown[700]
                                    : Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          child: const Text('High to Low'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (mounted) {
                              context.read<ExpiryBloc>().add(const SortExpiry(
                                  'Selling Price', 'Low to High'));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                state.tempSortCriteria['Selling Price'] ==
                                        'Low to High'
                                    ? Colors.brown[700]
                                    : Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          child: const Text('Low to High'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6.0,
                      children: [
                        for (var product in [null, ...uniqueProducts])
                          ElevatedButton(
                            onPressed: () {
                              if (mounted) {
                                context
                                    .read<ExpiryBloc>()
                                    .add(SortExpiry('Product', product ?? ''));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  state.tempSortCriteria['Product'] == product
                                      ? Colors.brown[700]
                                      : Colors.grey[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            ),
                            child: Text(product ?? 'All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (mounted) {
                          context.read<ExpiryBloc>().add(const ApplyFilters());
                          Navigator.pop(sheetContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () {
                        if (mounted) {
                          context.read<ExpiryBloc>().add(const SortExpiry(
                              'Expiry Date', '',
                              remove: true));
                          context.read<ExpiryBloc>().add(
                              const SortExpiry('Quantity', '', remove: true));
                          context.read<ExpiryBloc>().add(const SortExpiry(
                              'Selling Price', '',
                              remove: true));
                          context.read<ExpiryBloc>().add(
                              const SortExpiry('Product', '', remove: true));
                          context.read<ExpiryBloc>().add(const ApplyFilters());
                          Navigator.pop(sheetContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                      ),
                      child: const Text('Clear All Filters'),
                    ),
                    if (state.tempSortCriteria.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          'Selected: ${state.tempSortCriteria.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                          style: const TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        _animationController.reset();
      }
    });
  }

  Widget _buildSkeletonLoader(double screenWidth, double screenHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocConsumer<ExpiryBloc, ExpiryState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final filteredData = state.getFilteredData();
          final itemsPerPage = state.itemsPerPage.toDouble();
          final totalPages = filteredData.isNotEmpty
              ? (filteredData.length / itemsPerPage).ceil()
              : 1;
          final validCurrentPage = (state.currentPage).clamp(1, totalPages);
          final startIndex = ((validCurrentPage - 1) * state.itemsPerPage)
              .clamp(0, filteredData.length);
          final endIndex =
              (startIndex + state.itemsPerPage).clamp(0, filteredData.length);
          final paginatedData = filteredData.isNotEmpty
              ? filteredData.sublist(startIndex, endIndex)
              : [];

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screenHeight),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Expiry Management",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      labelText: 'Search by Product or Batch',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                    ),
                                    onChanged: _onSearchChanged,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              IconButton(
                                icon: Image.asset(
                                  'assets/icons/filter.png',
                                  width: 24,
                                  height: 24,
                                  color: Colors.grey,
                                ),
                                onPressed: () => showFilterBottomSheet(context),
                                style: IconButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: state.isLoading
                              ? _buildSkeletonLoader(screenWidth, screenHeight)
                              : paginatedData.isEmpty
                                  ? const Center(
                                      child: Text("No expiry data found"))
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: paginatedData.length,
                                      itemBuilder: (context, index) {
                                        final expiry = paginatedData[index];
                                        print('Rendering Expiry: $expiry');
                                        return ExpiryCard(
                                          expiry: expiry,
                                          screenWidth: screenWidth,
                                          screenHeight: screenHeight,
                                        );
                                      },
                                    ),
                        ),
                        if (!state.isLoading && totalPages > 1)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.first_page),
                                    onPressed: validCurrentPage > 1
                                        ? () => context
                                            .read<ExpiryBloc>()
                                            .add(const GoToPage(1))
                                        : null),
                                const SizedBox(width: 5),
                                IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: validCurrentPage > 1
                                        ? () => context
                                            .read<ExpiryBloc>()
                                            .add(GoToPage(validCurrentPage - 1))
                                        : null),
                                const SizedBox(width: 5),
                                Text('$validCurrentPage of $totalPages'),
                                const SizedBox(width: 5),
                                IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: validCurrentPage < totalPages
                                        ? () => context
                                            .read<ExpiryBloc>()
                                            .add(GoToPage(validCurrentPage + 1))
                                        : null),
                                const SizedBox(width: 5),
                                IconButton(
                                    icon: const Icon(Icons.last_page),
                                    onPressed: validCurrentPage < totalPages
                                        ? () => context
                                            .read<ExpiryBloc>()
                                            .add(GoToPage(totalPages))
                                        : null),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ExpiryCard extends StatelessWidget {
  final ExpiryData expiry;
  final double screenWidth;
  final double screenHeight;

  const ExpiryCard({
    super.key,
    required this.expiry,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    print('Building ExpiryCard with batchNumber: ${expiry.batchNumber}');
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.1,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: screenWidth * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Product: ${expiry.product ?? 'N/A'}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(context, 'ID', '${expiry.id ?? 'N/A'}'),
                  _buildDetailRow(context, 'Batch Number',
                      expiry.batchNumber ?? 'N/A'),
                  _buildDetailRow(context, 'Expiry Date',
                      expiry.expiryDate?.toIso8601String().split('T')[0] ?? 'N/A'),
                  _buildDetailRow(context, 'Selling Price',
                      'NPR ${expiry.sellingPrice?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildDetailRow(
                      context, 'Quantity', '${expiry.quantity ?? 0}'),
                  _buildDetailRow(context, 'Cost Price',
                      'NPR ${expiry.costPrice?.toStringAsFixed(2) ?? '0.00'}'),
                ],
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        expiry.product ?? 'N/A',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'ID: ${expiry.id ?? 'N/A'}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expiry.batchNumber ?? 'N/A',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      expiry.expiryDate?.toIso8601String().split('T')[0] ?? 'N/A',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NPR ${expiry.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      '${expiry.quantity ?? 0}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
