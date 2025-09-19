import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/user_data_response.dart';

import 'package:saleup_app/services/auth_service.dart';
import 'dart:developer';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  _PersonalDetailsScreenState createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocalUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final userId = await authService.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final firstName = await authService.getFirstName();
      final lastName = await authService.getLastName();
      final email = await authService.getEmail();
      final username = await authService.getUsername();

      setState(() {
        _firstNameController.text = firstName ?? '';
        _lastNameController.text = lastName ?? '';
        _emailController.text = email ?? '';
        _usernameController.text = username ?? '';
      });

      if (firstName == null ||
          lastName == null ||
          email == null ||
          username == null) {
        await _fetchUserDataFromApi(userId.toString());
      }
    } catch (e) {
      log('Error loading local user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserDataFromApi(String userIdStr) async {
    try {
      final response =
          await DioClient().dio.put('/auth/update_user/?id=$userIdStr');
      final userDataResponse = UserDataResponse.fromJson(response.data);
      log('Fetch API Response: ${userDataResponse.toJson()}');
      if (response.statusCode == 200 && userDataResponse.success == true) {
        final data = userDataResponse.data;
        if (data != null) {
          final userId = int.tryParse(userIdStr) ?? 0;
          await AuthService().saveTokens(
            accessToken: await AuthService().getAccessToken() ?? '',
            refreshToken: await AuthService().getRefreshToken() ?? '',
            userId: userId,
            email: data.email ?? '',
            username: data.username ?? '',
            firstName: data.first_name ?? '',
            lastName: data.last_name ?? '',
          );
          if (mounted) {
            setState(() {
              _firstNameController.text = data.first_name ?? '';
              _lastNameController.text = data.last_name ?? '';
              _emailController.text = data.email ?? '';
              _usernameController.text = data.username ?? '';
            });
          }
        } else {
          log('Unexpected data format in fetch response: $data');
          throw Exception('Invalid data format in response');
        }
      } else {
        log('Failed to fetch user data from API: ${userDataResponse.toJson()}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to fetch user data: ${userDataResponse.message ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      log('Error fetching user data from API: $e, Stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final userId = await authService.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final dioClient = DioClient();
      if (!await dioClient.isTokenValid()) {
        final refreshed = await dioClient.refreshToken();
        if (!refreshed) {
          throw Exception('Failed to refresh token. Please log in again.');
        }
      }

      await authService.updateUserData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      final response = await dioClient.dio.put(
        '/auth/update_user/?id=${userId.toString()}',
        data: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
        },
      );

      final userDataResponse = UserDataResponse.fromJson(response.data);
      log('Update API Response: ${response.statusCode} - ${userDataResponse.toJson()}');

      if (response.statusCode == 200 && userDataResponse.success == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          setState(() {
            _isEditing = false;
          });
        }
      } else if (response.data is String &&
          response.data.contains('<!DOCTYPE html')) {
        throw Exception('Server returned an error page. Check the endpoint.');
      } else {
        throw Exception(userDataResponse.message ?? 'Failed to update profile');
      }
    } catch (e) {
      log('Error updating profile: $e, Stack trace: ${StackTrace.current}');
      String errorMessage = 'Error updating profile';
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please log in again.';
          await AuthService().clearTokens();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          }
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Permission denied. Contact support.';
        } else if (e.response?.statusCode == 404) {
          errorMessage =
              'Endpoint not found. Response: ${e.response?.data?.toString().substring(0, 100)}...';
        } else if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data is Map<String, dynamic>
              ? UserDataResponse.fromJson(e.response!.data).message ??
                  'Invalid request.'
              : 'Invalid request.';
        } else {
          errorMessage = e.response?.data is Map<String, dynamic>
              ? UserDataResponse.fromJson(e.response!.data).message ??
                  'Unknown error occurred.'
              : 'Unknown error occurred.';
        }
      } else if (e.toString().contains('not a subtype')) {
        errorMessage =
            'Internal data error: Response data format mismatch. Error: $e';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Personal Details',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit_outlined,
                color: Colors.black),
            onPressed: () {
              if (_isEditing) {
                _updateUserData();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTextField('First Name', _firstNameController,
                          enabled: _isEditing, validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      }),
                      const SizedBox(height: 20),
                      _buildTextField('Last Name', _lastNameController,
                          enabled: _isEditing, validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      }),
                      const SizedBox(height: 20),
                      _buildTextField('Email', _emailController,
                          enabled: false),
                      const SizedBox(height: 20),
                      _buildTextField('Username', _usernameController,
                          enabled: false),
                      const SizedBox(height: 30),
                      if (_isEditing)
                        ElevatedButton(
                          onPressed: _isLoading ? null : _updateUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('SAVE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            hintStyle: TextStyle(color: Colors.black, fontSize: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
