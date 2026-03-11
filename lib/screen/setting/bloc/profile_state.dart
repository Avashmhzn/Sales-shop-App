import 'package:equatable/equatable.dart';
import '../model/profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ManagersLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final List<Profile> profiles;
  final List<String> managers;

  const ProfileLoaded({
    required this.profiles,
    required this.managers,
  });

  @override
  List<Object?> get props => [profiles, managers];
}

class ProfileCreating extends ProfileState {}

class ProfileCreated extends ProfileState {
  final Profile profile;

  const ProfileCreated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {}

class ProfileDeleting extends ProfileState {}

class ProfileDeleted extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
