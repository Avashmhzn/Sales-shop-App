import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/screen/units/bloc/unit_bloc.dart';
import 'package:saleup_app/screen/units/bloc/unit_event.dart';
import 'package:saleup_app/screen/units/bloc/unit_state.dart';
import 'package:saleup_app/screen/units/widget/unit_card.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<UnitBloc>().add(const FetchUnits());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<UnitBloc>().add(SearchUnits(query));
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

    return BlocConsumer<UnitBloc, UnitState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final filteredData = state.getFilteredData();
        final totalPages = filteredData.isNotEmpty
            ? (filteredData.length / state.itemsPerPage).ceil()
            : 1;
        final validCurrentPage = state.currentPage.clamp(1, totalPages);
        if (validCurrentPage != state.currentPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UnitBloc>().add(GoToPage(validCurrentPage));
          });
        }
        final paginatedData = filteredData.isNotEmpty
            ? filteredData.sublist(
                (validCurrentPage - 1) * state.itemsPerPage,
                ((validCurrentPage - 1) * state.itemsPerPage +
                        state.itemsPerPage)
                    .clamp(0, filteredData.length))
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
                      "Units Management",
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
                              ? const Center(child: Text("No units found"))
                              : ListView.builder(
                                  key: ValueKey(
                                      '${state.units.length}_${validCurrentPage}_${state.searchQuery}'),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: paginatedData.length,
                                  itemBuilder: (context, index) {
                                    return UnitCard(
                                      unit: paginatedData[index],
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
                                        .read<UnitBloc>()
                                        .add(const GoToPage(1))
                                    : null),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: validCurrentPage > 1
                                    ? () => context
                                        .read<UnitBloc>()
                                        .add(GoToPage(validCurrentPage - 1))
                                    : null),
                            const SizedBox(width: 5),
                            Text('$validCurrentPage of $totalPages'),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: validCurrentPage < totalPages
                                    ? () => context
                                        .read<UnitBloc>()
                                        .add(GoToPage(validCurrentPage + 1))
                                    : null),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.last_page),
                                onPressed: validCurrentPage < totalPages
                                    ? () => context
                                        .read<UnitBloc>()
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
