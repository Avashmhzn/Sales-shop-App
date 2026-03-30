// import 'package:dio/dio.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../model/profile.dart';
// import 'profile_event.dart';
// import 'profile_state.dart';

// class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
//   final Dio dio;

//   ProfileBloc({required this.dio}) : super(ProfileInitial()) {
//     on<LoadProfile>(_onLoadProfile);
//     on<LoadManagers>(_onLoadManagers);
//     on<CreateProfile>(_onCreateProfile);
//     on<DeleteProfile>(_onDeleteProfile);
//     on<UpdateProfile>(_onUpdateProfile);
//   }

//   String _getCurrentDomain() {
//     final baseUrl = dio.options.baseUrl.trim();
//     if (baseUrl.isEmpty) return 'localhost';
//     try {
//       final uri = Uri.parse(baseUrl);
//       final host = uri.host;
//       if (host.contains(':')) return host.split(':').first;
//       return host;
//     } catch (e) {
//       return 'localhost';
//     }
//   }

//   Future<void> _onLoadProfile(
//     LoadProfile event,
//     Emitter<ProfileState> emit,
//   ) async {
//     emit(ProfileLoading());
//     try {
//       final res = await dio.get('/profile/get_profile/');

//       if (res.statusCode != 200) {
//         // emit(ProfileError('Failed to load profiles (HTTP ${res.statusCode})'));
//         emit(const ProfileError('No profiles found for this manager.'));
//         return;
//       }

//       final data = res.data;
//       if (data is! Map<String, dynamic>) {
//         emit(const ProfileError('Invalid response format'));
//         return;
//       }

//       // ✅ Show actual API message when success is false
//       if (data['success'] != true) {
//         final msg = data['message']?.toString() ?? 'Failed to load profiles';
//         emit(ProfileError(msg));
//         return;
//       }

//       final rawList = data['data'] as List<dynamic>? ?? [];
//       final profiles = rawList
//           .whereType<Map<String, dynamic>>()
//           .map((e) => Profile.fromJson(e))
//           .toList();

//       List<String> currentManagers = [];
//       if (state is ProfileLoaded) {
//         currentManagers = (state as ProfileLoaded).managers;
//       }

//       emit(ProfileLoaded(profiles: profiles, managers: currentManagers));
//     } catch (e) {
//       emit(ProfileError('Error loading profiles: $e'));
//     }
//   }

//   Future<void> _onLoadManagers(
//     LoadManagers event,
//     Emitter<ProfileState> emit,
//   ) async {
//     emit(ManagersLoading());
//     try {
//       final res = await dio.get('/auth/get_user/');

//       if (res.statusCode != 200) {
//         emit(ProfileError('Failed to load managers (HTTP ${res.statusCode})'));
//         return;
//       }

//       final data = res.data;
//       if (data is! Map<String, dynamic>) {
//         emit(const ProfileError('Invalid response format'));
//         return;
//       }

//       // ✅ Show actual API message when success is false
//       if (data['success'] != true) {
//         final msg = data['message']?.toString() ?? 'Failed to load managers';
//         emit(ProfileError(msg));
//         return;
//       }

//       final rawList = data['data'] as List<dynamic>? ?? [];
//       final currentDomain = _getCurrentDomain();

//       final managers = rawList
//           .whereType<Map<String, dynamic>>()
//           .where((user) {
//             final domains = user['domains'] as List<dynamic>? ?? [];
//             return domains
//                 .any((d) => d.toString().trim() == currentDomain.trim());
//           })
//           .map((user) => user['username']?.toString().trim() ?? '')
//           .where((name) => name.isNotEmpty)
//           .toList();

//       List<Profile> currentProfiles = [];
//       if (state is ProfileLoaded) {
//         currentProfiles = (state as ProfileLoaded).profiles;
//       }

//       emit(ProfileLoaded(profiles: currentProfiles, managers: managers));
//     } catch (e) {
//       emit(ProfileError('Error loading managers: $e'));
//     }
//   }

//   Future<void> _onCreateProfile(
//     CreateProfile event,
//     Emitter<ProfileState> emit,
//   ) async {
//     emit(ProfileCreating());
//     try {
//       final res = await dio.post(
//         '/profile/create_profile/',
//         data: event.profile.toJson(),
//       );

//       final data = res.data;

//       // ✅ Show actual API message on failure
//       if (data['success'] != true) {
//         final msg = data['message']?.toString() ?? 'Failed to create profile';
//         emit(ProfileError(msg));
//         return;
//       }

//       final created = Profile.fromJson(data['data'] as Map<String, dynamic>);
//       emit(ProfileCreated(created));
//       add(const LoadProfile());
//     } catch (e) {
//       emit(ProfileError('Error creating profile: $e'));
//     }
//   }

//   Future<void> _onDeleteProfile(
//     DeleteProfile event,
//     Emitter<ProfileState> emit,
//   ) async {
//     emit(ProfileDeleting());
//     try {
//       final res = await dio.delete(
//         '/profile/delete_profile/',
//         queryParameters: {'profile_id': event.profileId},
//       );

//       final data = res.data;

//       // ✅ Show actual API message on failure
//       if (data['success'] != true) {
//         final msg = data['message']?.toString() ?? 'Failed to delete profile';
//         emit(ProfileError(msg));
//         return;
//       }

//       emit(ProfileDeleted());
//       add(const LoadProfile());
//     } catch (e) {
//       emit(ProfileError('Error deleting profile: $e'));
//     }
//   }

//   Future<void> _onUpdateProfile(
//     UpdateProfile event,
//     Emitter<ProfileState> emit,
//   ) async {
//     emit(ProfileUpdating());
//     try {
//       final res = await dio.put(
//         '/profile/update_profile/',
//         queryParameters: {'profile_id': event.profile.id},
//         data: event.profile.toJson(),
//       );

//       final data = res.data;

//       // ✅ Show actual API message on failure
//       if (data['success'] != true) {
//         final msg = data['message']?.toString() ?? 'Failed to update profile';
//         emit(ProfileError(msg));
//         return;
//       }

//       emit(ProfileUpdated());
//       add(const LoadProfile());
//     } catch (e) {
//       emit(ProfileError('Error updating profile: $e'));
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Dio dio;

  ProfileBloc({required this.dio}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadManagers>(_onLoadManagers);
    on<CreateProfile>(_onCreateProfile);
    on<DeleteProfile>(_onDeleteProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  String _getCurrentDomain() {
    final baseUrl = dio.options.baseUrl.trim();
    if (baseUrl.isEmpty) return 'localhost';
    try {
      final uri = Uri.parse(baseUrl);
      final host = uri.host;
      return host.contains(':') ? host.split(':').first : host;
    } catch (e) {
      return 'localhost';
    }
  }

  // ==================== FIXED: Load Profile ====================
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final res = await dio.get('/profile/get_profile/');

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        emit(const ProfileError('Invalid response format'));
        return;
      }

      if (data['success'] != true) {
        final msg = data['message']?.toString() ?? 'Failed to load profile';
        emit(ProfileError(msg));
        return;
      }

      final profileData = data['data'];

      // Handle both cases: single object or list (future-proof)
      Profile? profile;
      if (profileData is Map<String, dynamic>) {
        profile = Profile.fromJson(profileData);
      } else if (profileData is List && profileData.isNotEmpty) {
        profile = Profile.fromJson(profileData.first as Map<String, dynamic>);
      }

      List<String> currentManagers = [];
      if (state is ProfileLoaded) {
        currentManagers = (state as ProfileLoaded).managers;
      }

      emit(ProfileLoaded(
        profiles: profile != null ? [profile] : [],
        managers: currentManagers,
      ));
    } catch (e) {
      emit(ProfileError('Error loading profile: $e'));
    }
  }

  // ==================== Load Managers (unchanged) ====================
  Future<void> _onLoadManagers(
    LoadManagers event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ManagersLoading());
    try {
      final res = await dio.get('/auth/get_user/');

      final data = res.data;
      if (data is! Map<String, dynamic> || data['success'] != true) {
        emit(ProfileError(
            data?['message']?.toString() ?? 'Failed to load managers'));
        return;
      }

      final rawList = data['data'] as List<dynamic>? ?? [];
      final currentDomain = _getCurrentDomain();

      final managers = rawList
          .whereType<Map<String, dynamic>>()
          .where((user) {
            final domains = user['domains'] as List<dynamic>? ?? [];
            return domains
                .any((d) => d.toString().trim() == currentDomain.trim());
          })
          .map((user) => user['username']?.toString().trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      List<Profile> currentProfiles = [];
      if (state is ProfileLoaded) {
        currentProfiles = (state as ProfileLoaded).profiles;
      }

      emit(ProfileLoaded(profiles: currentProfiles, managers: managers));
    } catch (e) {
      emit(ProfileError('Error loading managers: $e'));
    }
  }

  // ==================== Create Profile ====================///
  Future<void> _onCreateProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileCreating());
    try {
      final res = await dio.post(
        '/profile/create_profile/',
        data: event.profile.toJson(),
      );

      final data = res.data;
      if (data['success'] != true) {
        final msg = data['message']?.toString() ?? 'Failed to create profile';
        emit(ProfileError(msg));
        return;
      }

      final created = Profile.fromJson(data['data'] as Map<String, dynamic>);
      emit(ProfileCreated(created));
      add(const LoadProfile()); // refresh
    } catch (e) {
      emit(ProfileError('Error creating profile: $e'));
    }
  }

  // ==================== Update Profile ====================
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    try {
      final res = await dio.put(
        '/profile/update_profile/',
        queryParameters: {'profile_id': event.profile.id},
        data: event.profile.toJson(),
      );

      final data = res.data;
      if (data['success'] != true) {
        final msg = data['message']?.toString() ?? 'Failed to update profile';
        emit(ProfileError(msg));
        return;
      }

      emit(ProfileUpdated());
      add(const LoadProfile());
    } catch (e) {
      emit(ProfileError('Error updating profile: $e'));
    }
  }

  // ==================== Delete Profile ====================
  Future<void> _onDeleteProfile(
    DeleteProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileDeleting());
    try {
      final res = await dio.delete(
        '/profile/delete_profile/',
        queryParameters: {'profile_id': event.profileId},
      );

      final data = res.data;
      if (data['success'] != true) {
        final msg = data['message']?.toString() ?? 'Failed to delete profile';
        emit(ProfileError(msg));
        return;
      }

      emit(ProfileDeleted());
      add(const LoadProfile());
    } catch (e) {
      emit(ProfileError('Error deleting profile: $e'));
    }
  }
}
