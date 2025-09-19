import 'package:equatable/equatable.dart';

abstract class AccountHeadDetailsEvent extends Equatable {
  const AccountHeadDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchAccountHeadDetails extends AccountHeadDetailsEvent {
  final int accountHeadId;

  const FetchAccountHeadDetails(this.accountHeadId);

  @override
  List<Object?> get props => [accountHeadId];
}
