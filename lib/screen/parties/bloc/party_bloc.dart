import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/party_response.dart';
import 'package:saleup_app/screen/parties/bloc/party_event.dart';
import 'package:saleup_app/screen/parties/bloc/party_state.dart';
import 'package:dio/dio.dart' as dio;

class PartyBloc extends Bloc<PartyEvent, PartyState> {
  PartyBloc() : super(const PartyState()) {
    on<FetchParties>(_onFetchParties);
    on<SearchParties>(_onSearchParties);
    on<UpdateTypeFilter>(_onUpdateTypeFilter);
    on<ClearFilters>(_onClearFilters);
    on<GoToPage>(_onGoToPage);
    on<UpdateFiltersApplied>(_onUpdateFiltersApplied);
  }

  Future<void> _onFetchParties(
      FetchParties event, Emitter<PartyState> emit) async {
    print('Fetching parties');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await DioClient().dio.get('/party/get_parties/');
      print('API response (raw): ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        print(
            'Error: API response is not a Map<String, dynamic>: ${response.data.runtimeType}');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
        ));
        return;
      }
      final partyResponse = PartyResponse.fromJson(response.data);
      print('Parsed PartyResponse: success=${partyResponse.success}, '
          'message=${partyResponse.message}, '
          'dataLength=${partyResponse.data.length}, '
          'data=${partyResponse.data.map((p) => 'id=${p.id}, name=${p.name}, opening_balance=${p.openingBalance}').toList()}');

      if (partyResponse.success == true) {
        emit(state.copyWith(
          isLoading: false,
          parties: partyResponse.data,
          totalItems: partyResponse.total ?? partyResponse.data.length,
          errorMessage: null,
          isFiltersCleared: state.isFiltersCleared,
        ));
      } else {
        print('API failed: message=${partyResponse.message}');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: partyResponse.message ?? 'Failed to fetch parties',
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
      print('Dio error: $errorMessage');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } catch (e, stackTrace) {
      print('Unexpected error in fetchParties: $e, stackTrace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse parties: $e',
      ));
    }
  }

  void _onSearchParties(SearchParties event, Emitter<PartyState> emit) {
    print('Search query updated: ${event.query}');
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
      isFiltersCleared: false,
    ));
  }

  void _onUpdateTypeFilter(UpdateTypeFilter event, Emitter<PartyState> emit) {
    print('Type filter updated: ${event.type}');
    emit(state.copyWith(
      selectedTypeFilter: event.type ?? 'All',
      currentPage: 1,
      isFiltersCleared: false,
    ));
  }

  Future<void> _onClearFilters(
      ClearFilters event, Emitter<PartyState> emit) async {
    print('ClearFilters event processed');
    emit(state.copyWith(
      isLoading: true,
      selectedTypeFilter: 'All',
      currentPage: 1,
      searchQuery: '',
      isFiltersCleared: true,
      errorMessage: null,
    ));
    try {
      final response = await DioClient().dio.get('/party/get_parties/');
      print('ClearFilters API response (raw): ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        print(
            'Error: ClearFilters API response is not a Map<String, dynamic>: ${response.data.runtimeType}');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API response format',
          isFiltersCleared: true,
        ));
        return;
      }
      final partyResponse = PartyResponse.fromJson(response.data);
      print(
          'ClearFilters Parsed PartyResponse: success=${partyResponse.success}, '
          'dataLength=${partyResponse.data.length}, '
          'data=${partyResponse.data.map((p) => 'id=${p.id}, name=${p.name}, opening_balance=${p.openingBalance}').toList()}');

      if (partyResponse.success == true) {
        emit(state.copyWith(
          isLoading: false,
          parties: partyResponse.data,
          totalItems: partyResponse.total ?? partyResponse.data.length,
          errorMessage: null,
          isFiltersCleared: true,
          selectedTypeFilter: 'All',
          currentPage: 1,
          searchQuery: '',
        ));
      } else {
        print('ClearFilters API failed: message=${partyResponse.message}');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: partyResponse.message ?? 'Failed to fetch parties',
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
      print('ClearFilters Dio error: $errorMessage');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isFiltersCleared: true,
      ));
    } catch (e, stackTrace) {
      print('Unexpected error in clearFilters: $e, stackTrace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse parties: $e',
        isFiltersCleared: true,
      ));
    }
  }

  void _onUpdateFiltersApplied(
      UpdateFiltersApplied event, Emitter<PartyState> emit) {
    print('UpdateFiltersApplied event processed');
    emit(state.copyWith(
      isFiltersCleared: state.selectedTypeFilter != 'All' ? false : true,
      currentPage: 1,
    ));
  }

  void _onGoToPage(GoToPage event, Emitter<PartyState> emit) {
    print('Navigating to page: ${event.page}');
    final totalPages =
        (state.getFilteredData().length / state.itemsPerPage).ceil();
    final newPage = event.page.clamp(1, totalPages);
    emit(state.copyWith(currentPage: newPage));
  }
}
