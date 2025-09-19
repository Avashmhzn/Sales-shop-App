import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/screen/product/bloc/product_bloc.dart';
import 'package:saleup_app/screen/product/bloc/product_event.dart';
import 'package:saleup_app/screen/product/bloc/product_state.dart';
import 'package:saleup_app/screen/product/widget/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductBloc>().add(const FetchProducts());
      context.read<ProductBloc>().add(const FetchUnits());
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
      if (!mounted) return;
      context.read<ProductBloc>().add(SearchProducts(query));
    });
  }

  void showFilterBottomSheet(BuildContext context, ProductBloc productBloc) {
    _animationController.forward();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      transitionAnimationController: _animationController,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final units = productBloc.state.units.map((u) => u.name).toList();

        return SlideTransition(
          position: _slideAnimation,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: screenHeight * 0.8,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
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
                      const SizedBox(height: 16),
                      const Text(
                        'Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: productBloc.state.allCategories
                            .map((category) => FilterChip(
                                  label: Text(category),
                                  selected: productBloc
                                          .state.selectedCategoryFilter ==
                                      category,
                                  onSelected: (bool value) {
                                    if (value) {
                                      setState(() {
                                        productBloc.add(
                                            UpdateCategoryFilter(category));
                                      });
                                    }
                                  },
                                  selectedColor: Colors.brown[700],
                                  labelStyle: TextStyle(
                                    color: productBloc
                                                .state.selectedCategoryFilter ==
                                            category
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: ['All', ...units]
                            .map((unit) => FilterChip(
                                  label: Text(unit),
                                  selected:
                                      productBloc.state.selectedUnitFilter ==
                                          unit,
                                  onSelected: (bool value) {
                                    if (value) {
                                      setState(() {
                                        productBloc.add(UpdateUnitFilter(unit));
                                      });
                                    }
                                  },
                                  selectedColor: Colors.brown[700],
                                  labelStyle: TextStyle(
                                    color:
                                        productBloc.state.selectedUnitFilter ==
                                                unit
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sort Products',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                productBloc
                                    .add(const SortProducts('No Sorting'));
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  productBloc.state.sortBy == 'No Sorting'
                                      ? Colors.brown[700]
                                      : Colors.grey[700],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('No Sorting'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                productBloc.add(const SortProducts(
                                    'Stock Quantity: High to Low'));
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: productBloc.state.sortBy ==
                                      'Stock Quantity: High to Low'
                                  ? Colors.brown[700]
                                  : Colors.grey[700],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Stock Quantity: High to Low'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                productBloc.add(const SortProducts(
                                    'Stock Quantity: Low to High'));
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: productBloc.state.sortBy ==
                                      'Stock Quantity: Low to High'
                                  ? Colors.brown[700]
                                  : Colors.grey[700],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Stock Quantity: Low to High'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                productBloc
                                    .add(const SortProducts('Name: A to Z'));
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  productBloc.state.sortBy == 'Name: A to Z'
                                      ? Colors.brown[700]
                                      : Colors.grey[700],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Name: A to Z'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                productBloc
                                    .add(const SortProducts('Name: Z to A'));
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  productBloc.state.sortBy == 'Name: Z to A'
                                      ? Colors.brown[700]
                                      : Colors.grey[700],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Name: Z to A'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                productBloc.add(const ClearFilters());
                              });
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: const Text('Clear Filters'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              productBloc.add(const UpdateFiltersApplied());
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown[700],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      _animationController.reset();
    });
  }

  Widget _buildSkeletonLoader(double screenWidth, double screenHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        print(
            'State: isLoading=${state.isLoading}, currentPage=${state.currentPage}, itemsPerPage=${state.itemsPerPage}, products=${state.products.length}, filteredData=${state.getFilteredData().length}');
      },
      builder: (context, state) {
        final filteredData = state.getFilteredData();
        final itemsPerPage = state.itemsPerPage.toDouble();
        final totalPages = filteredData.isNotEmpty
            ? (filteredData.length / itemsPerPage).ceil()
            : 1;
        final validCurrentPage = (state.currentPage ?? 1).clamp(1, totalPages);
        if (validCurrentPage != (state.currentPage ?? 1)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<ProductBloc>().add(GoToPage(validCurrentPage));
          });
        }
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
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Products Management",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      labelText: 'Search Here',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
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
                                onPressed: () => showFilterBottomSheet(
                                    context, context.read<ProductBloc>()),
                                style: IconButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: screenWidth,
                      child: state.isLoading
                          ? _buildSkeletonLoader(screenWidth, screenHeight)
                          : paginatedData.isEmpty
                              ? const Center(child: Text("No products found"))
                              : ListView.builder(
                                  key: ValueKey(
                                      '${state.products.length}_$validCurrentPage${state.isFiltersCleared}_${state.searchQuery}_${state.selectedCategoryFilter}_${state.selectedUnitFilter}_${state.sortBy}'),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: paginatedData.length,
                                  itemBuilder: (context, index) {
                                    return ProductCard(
                                      product: paginatedData[index],
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                    );
                                  },
                                ),
                    ),
                    if (!state.isLoading && totalPages > 1)
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.first_page),
                                onPressed: validCurrentPage > 1
                                    ? () => context
                                        .read<ProductBloc>()
                                        .add(const GoToPage(1))
                                    : null),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: validCurrentPage > 1
                                    ? () => context
                                        .read<ProductBloc>()
                                        .add(GoToPage(validCurrentPage - 1))
                                    : null),
                            const SizedBox(width: 5),
                            Text('$validCurrentPage of $totalPages'),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: validCurrentPage < totalPages
                                    ? () => context
                                        .read<ProductBloc>()
                                        .add(GoToPage(validCurrentPage + 1))
                                    : null),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.last_page),
                                onPressed: validCurrentPage < totalPages
                                    ? () => context
                                        .read<ProductBloc>()
                                        .add(GoToPage(totalPages))
                                    : null),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
