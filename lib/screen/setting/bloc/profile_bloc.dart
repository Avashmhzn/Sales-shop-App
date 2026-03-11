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
    on<UpdateProfile>(_onUpdateProfile); // Fixed: must be inside constructor
  }

  // Helper: Dynamically get current domain from Dio baseUrl (no hardcoding)
  String _getCurrentDomain() {
    final baseUrl = dio.options.baseUrl.trim();
    if (baseUrl.isEmpty) {
      // Very rare fallback — should never happen if Dio is configured
      return 'localhost';
    }

    try {
      // Parse as URI and get host (IP or domain name)
      final uri = Uri.parse(baseUrl);
      final host = uri.host;

      // Clean up common cases (remove port if present)
      if (host.contains(':')) {
        return host.split(':').first;
      }

      return host; // e.g. "192.168.1.65", "localhost", "app.example.com"
    } catch (e) {
      // If parsing fails (invalid URL format), fallback safely
      return 'localhost';
    }
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final res = await dio.get('/profile/get_profile/');

      if (res.statusCode != 200) {
        emit(ProfileError('Failed to load profiles (HTTP ${res.statusCode})'));
        return;
      }

      final data = res.data;
      if (data is! Map<String, dynamic> || data['success'] != true) {
        emit(ProfileError(
          data is Map
              ? data['message']?.toString() ?? 'Failed'
              : 'Invalid response',
        ));
        return;
      }

      final rawList = data['data'] as List<dynamic>? ?? [];
      final profiles = rawList
          .whereType<Map<String, dynamic>>()
          .map((e) => Profile.fromJson(e))
          .toList();

      // Preserve existing managers if already loaded
      List<String> currentManagers = [];
      if (state is ProfileLoaded) {
        currentManagers = (state as ProfileLoaded).managers;
      }

      emit(ProfileLoaded(profiles: profiles, managers: currentManagers));
    } catch (e) {
      emit(ProfileError('Error loading profiles: $e'));
    }
  }

  Future<void> _onLoadManagers(
    LoadManagers event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ManagersLoading());
    try {
      final res = await dio.get('/auth/get_user/');

      if (res.statusCode != 200) {
        emit(ProfileError('Failed to load managers (HTTP ${res.statusCode})'));
        return;
      }

      final data = res.data;
      if (data is! Map<String, dynamic> || data['success'] != true) {
        emit(ProfileError(
          data is Map
              ? data['message']?.toString() ?? 'Failed'
              : 'Invalid response',
        ));
        return;
      }

      final rawList = data['data'] as List<dynamic>? ?? [];

      // Get current domain dynamically from Dio baseUrl
      final currentDomain = _getCurrentDomain();

      // Filter users: only those whose "domains" contains currentDomain
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

      // Preserve existing profiles if already loaded
      List<Profile> currentProfiles = [];
      if (state is ProfileLoaded) {
        currentProfiles = (state as ProfileLoaded).profiles;
      }

      emit(ProfileLoaded(profiles: currentProfiles, managers: managers));
    } catch (e) {
      emit(ProfileError('Error loading managers: $e'));
    }
  }

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

      if (res.data['success'] == true) {
        final created =
            Profile.fromJson(res.data['data'] as Map<String, dynamic>);
        emit(ProfileCreated(created));
        add(const LoadProfile()); // refresh profiles
      } else {
        emit(ProfileError(res.data['message'] ?? 'Failed to create profile'));
      }
    } catch (e) {
      emit(ProfileError('Error creating profile: $e'));
    }
  }

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

      if (res.data['success'] == true) {
        emit(ProfileDeleted());
        add(const LoadProfile()); // refresh profiles
      } else {
        emit(ProfileError(res.data['message'] ?? 'Failed to delete profile'));
      }
    } catch (e) {
      emit(ProfileError('Error deleting profile: $e'));
    }
  }

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

      if (res.data['success'] == true) {
        emit(ProfileUpdated());
        add(const LoadProfile()); // refresh list
      } else {
        emit(ProfileError(res.data['message'] ?? 'Failed to update profile'));
      }
    } catch (e) {
      emit(ProfileError('Error updating profile: $e'));
    }
  }
}
