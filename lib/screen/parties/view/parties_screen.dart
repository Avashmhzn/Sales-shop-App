import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/screen/parties/bloc/party_bloc.dart';
import 'package:saleup_app/screen/parties/bloc/party_event.dart';
import 'package:saleup_app/screen/parties/bloc/party_state.dart';
import 'package:saleup_app/screen/parties/widget/party_card.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen>
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
    context.read<PartyBloc>().add(const FetchParties());
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
      context.read<PartyBloc>().add(SearchParties(query));
    });
  }

  void showFilterBottomSheet(BuildContext context, PartyBloc partyBloc) {
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
                        'Party Type',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: partyBloc.state.allTypes
                            .map((type) => FilterChip(
                                  label: Text(type),
                                  selected:
                                      partyBloc.state.selectedTypeFilter ==
                                          type,
                                  onSelected: (bool value) {
                                    if (value) {
                                      setState(() {
                                        partyBloc.add(UpdateTypeFilter(type));
                                      });
                                    }
                                  },
                                  selectedColor: Colors.brown[700],
                                  labelStyle: TextStyle(
                                    color: partyBloc.state.selectedTypeFilter ==
                                            type
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                partyBloc.add(const ClearFilters());
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
                              partyBloc.add(const UpdateFiltersApplied());
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

    return BlocConsumer<PartyBloc, PartyState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('State updated: '
            'isLoading=${state.isLoading}, '
            'partiesLength=${state.parties.length}, '
            'filteredDataLength=${state.getFilteredData().length}');
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
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
            print(
                'Correcting currentPage from ${state.currentPage} to $validCurrentPage');
            context.read<PartyBloc>().add(GoToPage(validCurrentPage));
          });
        }
        final paginatedData = filteredData.isNotEmpty
            ? filteredData.sublist(
                (validCurrentPage - 1) * state.itemsPerPage,
                ((validCurrentPage - 1) * state.itemsPerPage +
                        state.itemsPerPage)
                    .clamp(0, filteredData.length))
            : [];
        print('Building UI with: '
            'paginatedDataLength=${paginatedData.length}, '
            'totalPages=$totalPages, '
            'currentPage=${state.currentPage}, '
            'validCurrentPage=$validCurrentPage');

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Parties Management",
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
                                    context, context.read<PartyBloc>()),
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
                              ? const Center(child: Text("No parties found"))
                              : ListView.builder(
                                  key: ValueKey(
                                      '${state.parties.length}_${validCurrentPage}_${state.isFiltersCleared}_${state.searchQuery}_${state.selectedTypeFilter}'),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: paginatedData.length,
                                  itemBuilder: (context, index) {
                                    return PartyCard(
                                      party: paginatedData[index],
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
                                        .read<PartyBloc>()
                                        .add(const GoToPage(1))
                                    : null),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: validCurrentPage > 1
                                    ? () => context
                                        .read<PartyBloc>()
                                        .add(GoToPage(validCurrentPage - 1))
                                    : null),
                            const SizedBox(width: 5),
                            Text('$validCurrentPage of $totalPages'),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: validCurrentPage < totalPages
                                    ? () => context
                                        .read<PartyBloc>()
                                        .add(GoToPage(validCurrentPage + 1))
                                    : null),
                            const SizedBox(width: 5),
                            IconButton(
                                icon: const Icon(Icons.last_page),
                                onPressed: validCurrentPage < totalPages
                                    ? () => context
                                        .read<PartyBloc>()
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
