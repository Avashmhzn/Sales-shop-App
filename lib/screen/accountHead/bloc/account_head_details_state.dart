import 'package:equatable/equatable.dart';
import 'package:saleup_app/model/account_head_details_response.dart';

class AccountHeadDetailsState extends Equatable {
  final bool isLoading;
  final AccountHeadDetailData? accountHeadDetails;
  final String? errorMessage;

  const AccountHeadDetailsState({
    this.isLoading = false,
    this.accountHeadDetails,
    this.errorMessage,
  });

  AccountHeadDetailsState copyWith({
    bool? isLoading,
    AccountHeadDetailData? accountHeadDetails,
    String? errorMessage,
  }) {
    return AccountHeadDetailsState(
      isLoading: isLoading ?? this.isLoading,
      accountHeadDetails: accountHeadDetails ?? this.accountHeadDetails,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, accountHeadDetails, errorMessage];
}
