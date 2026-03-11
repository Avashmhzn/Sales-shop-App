import 'package:equatable/equatable.dart';
import '../model/profile.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class LoadManagers extends ProfileEvent {
  const LoadManagers();
}

class CreateProfile extends ProfileEvent {
  final Profile profile;

  const CreateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DeleteProfile extends ProfileEvent {
  final int profileId;

  const DeleteProfile(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

class UpdateProfile extends ProfileEvent {
  final Profile profile;

  const UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}
