import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/account_heads_response.dart';
import 'account_head_event.dart';
import 'account_head_state.dart';
import 'package:dio/dio.dart' as dio;

class AccountHeadBloc extends Bloc<AccountHeadEvent, AccountHeadState> {
  AccountHeadBloc() : super(const AccountHeadState()) {
    on<FetchAccountHeads>(_onFetchAccountHeads);
    on<SearchAccountHeads>(_onSearchAccountHeads);
    on<UpdateMainFilter>(_onUpdateMainFilter);
    on<UpdateSubFilter>(_onUpdateSubFilter);
    on<ClearFilters>(_onClearFilters);
    on<GoToPage>(_onGoToPage);
    on<UpdateFiltersApplied>(_onUpdateFiltersApplied);
  }

  Future<void> _onFetchAccountHeads(
      FetchAccountHeads event, Emitter<AccountHeadState> emit) async {
    print('Fetching account heads');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response =
          await DioClient().dio.get('/account-heads/get_account_heads/');
      print('API response: ${response.data}');
      final accountHeadsResponse = AccountHeadsResponse.fromJson(response.data);

      if (accountHeadsResponse.success == true) {
        final subFilters = <String, Set<String>>{};
        for (var head in accountHeadsResponse.data) {
          final parent = head.parent ?? '';
          final mainGroup = head.mainGroup ?? '';
          if (parent.isNotEmpty && mainGroup.isNotEmpty) {
            subFilters.putIfAbsent(parent, () => <String>{}).add(mainGroup);
          }
        }
        final allParents = {'All'}..addAll(accountHeadsResponse.data
            .map((head) => head.parent ?? '')
            .where((parent) => parent.isNotEmpty));
        final availableSubFilters = state.selectedMainFilter != 'All'
            ? accountHeadsResponse.data
                .where((head) =>
                    head.parent == state.selectedMainFilter &&
                    head.mainGroup != null &&
                    head.mainGroup!.isNotEmpty)
                .map((head) => head.mainGroup!)
                .toSet()
            : <String>{};

        print('Fetched account heads: ${accountHeadsResponse.data.length}');
        emit(state.copyWith(
          isLoading: false,
          accountHeads: accountHeadsResponse.data,
          totalItems:
              accountHeadsResponse.total ?? accountHeadsResponse.data.length,
          subFilters: subFilters,
          allParents: allParents,
          availableSubFilters: availableSubFilters,
          errorMessage: null,
          isFiltersCleared: state.isFiltersCleared,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage:
              accountHeadsResponse.message ?? 'Failed to fetch account heads',
        ));
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response!.statusCode} - ${e.response!.data}';
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      }
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } catch (e, stackTrace) {
      print(
          'Unexpected error in fetchAccountHeads: $e, stackTrace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: $e',
      ));
    }
  }

  void _onSearchAccountHeads(
      SearchAccountHeads event, Emitter<AccountHeadState> emit) {
    print('Search query updated: ${event.query}');
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
      isFiltersCleared: false,
    ));
  }

  void _onUpdateMainFilter(
      UpdateMainFilter event, Emitter<AccountHeadState> emit) {
    print('Main filter updated: ${event.parent}');
    final availableSubFilters = event.parent != 'All'
        ? state.accountHeads
            .where((head) =>
                head.parent == event.parent &&
                head.mainGroup != null &&
                head.mainGroup!.isNotEmpty)
            .map((head) => head.mainGroup!)
            .toSet()
        : <String>{};
    emit(state.copyWith(
      selectedMainFilter: event.parent ?? 'All',
      selectedSubFilter: null,
      currentPage: 1,
      availableSubFilters: availableSubFilters,
      isFiltersCleared: false,
    ));
  }

  void _onUpdateSubFilter(
      UpdateSubFilter event, Emitter<AccountHeadState> emit) {
    print('Sub filter updated: ${event.mainGroup ?? "All"}');
    emit(state.copyWith(
      selectedSubFilter: event.mainGroup,
      currentPage: 1,
      isFiltersCleared: event.mainGroup == null,
    ));
  }

  Future<void> _onClearFilters(
      ClearFilters event, Emitter<AccountHeadState> emit) async {
    print('ClearFilters event processed');
    emit(state.copyWith(
      isLoading: true,
      selectedMainFilter: 'All',
      selectedSubFilter: null,
      currentPage: 1,
      searchQuery: '',
      availableSubFilters: <String>{},
      isFiltersCleared: true,
      errorMessage: null,
    ));
    try {
      final response =
          await DioClient().dio.get('/account-heads/get_account_heads/');
      print('ClearFilters API response: ${response.data}');
      final accountHeadsResponse = AccountHeadsResponse.fromJson(response.data);

      if (accountHeadsResponse.success == true) {
        final subFilters = <String, Set<String>>{};
        for (var head in accountHeadsResponse.data) {
          final parent = head.parent ?? '';
          final mainGroup = head.mainGroup ?? '';
          if (parent.isNotEmpty && mainGroup.isNotEmpty) {
            subFilters.putIfAbsent(parent, () => <String>{}).add(mainGroup);
          }
        }
        final allParents = {'All'}..addAll(accountHeadsResponse.data
            .map((head) => head.parent ?? '')
            .where((parent) => parent.isNotEmpty));
        final availableSubFilters = <String>{};

        print(
            'ClearFilters fetched account heads: ${accountHeadsResponse.data.length}');
        emit(state.copyWith(
          isLoading: false,
          accountHeads: accountHeadsResponse.data,
          totalItems:
              accountHeadsResponse.total ?? accountHeadsResponse.data.length,
          subFilters: subFilters,
          allParents: allParents,
          availableSubFilters: availableSubFilters,
          errorMessage: null,
          isFiltersCleared: true,
          selectedMainFilter: 'All',
          selectedSubFilter: null,
          currentPage: 1,
          searchQuery: '',
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage:
              accountHeadsResponse.message ?? 'Failed to fetch account heads',
          isFiltersCleared: true,
        ));
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMessage =
            'Server error: ${e.response!.statusCode} - ${e.response!.data}';
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      }
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isFiltersCleared: true,
      ));
    } catch (e, stackTrace) {
      print('Unexpected error in clearFilters: $e, stackTrace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: $e',
        isFiltersCleared: true,
      ));
    }
  }

  void _onUpdateFiltersApplied(
      UpdateFiltersApplied event, Emitter<AccountHeadState> emit) {
    print('UpdateFiltersApplied event processed');
    if (state.selectedMainFilter != 'All' &&
        state.selectedSubFilter != null &&
        state.selectedSubFilter!.isNotEmpty) {
      emit(state.copyWith(isFiltersCleared: false, currentPage: 1));
    } else {
      emit(state.copyWith(isFiltersCleared: true, currentPage: 1));
    }
  }

  void _onGoToPage(GoToPage event, Emitter<AccountHeadState> emit) {
    print('Navigating to page: ${event.page}');
    final totalPages =
        (state.getFilteredData().length / state.itemsPerPage).ceil();
    final newPage = event.page.clamp(1, totalPages);
    emit(state.copyWith(currentPage: newPage));
  }
}
