import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added import
import 'package:saleup_app/core/network/dio_client.dart';
import 'package:saleup_app/model/forgot_password_response.dart';
import 'package:saleup_app/model/reset_password_response.dart';
import 'package:saleup_app/model/user_data_response.dart';
import 'package:saleup_app/model/verify_otp_response.dart';
import 'package:saleup_app/services/auth_service.dart';
import 'package:saleup_app/auth/view/forgetpasword/view/forget_pasword.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

class UserServices extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final DioClient _dioClient = DioClient();
  final AuthService _authService = AuthService();

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchUserData(BuildContext context, int userId) async {
    if (!context.mounted) {
      log('Context not mounted in fetchUserData');
      return;
    }
    try {
      final token = await AuthService().getAccessToken();
      if (token == null) {
        throw Exception('No token available');
      }

      log('Authorization header set for /auth/update_user/?id=$userId with token: $token');
      final response = await DioClient().dio.patch(
            '/auth/update_user/?id=$userId',
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ),
          );

      final userDataResponse = UserDataResponse.fromJson(response.data);

      if (userDataResponse.success == true) {
        // Handle successful response
        await AuthService().updateUserData(
          firstName: userDataResponse.data?.first_name,
          lastName: userDataResponse.data?.last_name,
          phone: userDataResponse.data?.phone,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  userDataResponse.message?.toString() ?? 'User data updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorMessage = userDataResponse.message?.toString() ??
            userDataResponse.detail?.toString() ??
            'Failed to update user data';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch user data from API';
      if (e.response != null) {
        final responseData = UserDataResponse.fromJson(e.response!.data);
        log('Server error response: ${responseData.toJson()}, status: ${e.response!.statusCode}');
        errorMessage = responseData.detail?.toString() ??
            responseData.message?.toString() ??
            'Server error occurred';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      } else {
        log('DioException: ${e.message}, type: ${e.type}');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      log('Unexpected error in fetchUserData: $e', stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> forgetPassword(BuildContext context, String email) async {
    if (!context.mounted) {
      log('Context not mounted in forgetPassword');
      return;
    }
    setLoading(true);
    try {
      log('Sending forgot password request for email: $email');
      final response = await _dioClient.dio.post(
        '/auth/forgot_password/',
        data: {'email': email},
      );

      final forgotPasswordResponse =
          ForgotPasswordResponse.fromJson(response.data);

      log('Response data: ${forgotPasswordResponse.toJson()}');
      if (forgotPasswordResponse.success == true) {
        if (!context.mounted) {
          log('Context not mounted after successful response');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(forgotPasswordResponse.message?.toString() ??
                'OTP sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
      } else {
        final errorMessage = forgotPasswordResponse.message?.toString() ??
            forgotPasswordResponse.detail?.toString() ??
            'Failed to send OTP';
        if (!context.mounted) {
          log('Context not mounted after failed response');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage == 'Failed to send OTP.'
                  ? 'Failed to send OTP. Please verify your email or contact support.'
                  : errorMessage,
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Contact Support',
              onPressed: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'devilmhzn@gmail.com',
                  query:
                      'subject=Forgot Password OTP Issue&body=Failed to send OTP for $email',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Could not open email client')),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.response != null) {
        final responseData = ForgotPasswordResponse.fromJson(e.response!.data);
        log('Server error response: ${responseData.toJson()}, status: ${e.response!.statusCode}');
        errorMessage = responseData.message?.toString() ??
            responseData.detail?.toString() ??
            'Server error occurred';
        if (errorMessage == 'Failed to send OTP.') {
          errorMessage =
              'Failed to send OTP. Please verify your email or contact support.';
        } else if (e.response!.statusCode == 403) {
          errorMessage = 'Permission denied. Please contact support.';
        }
            } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      } else {
        log('DioException: ${e.message}, type: ${e.type}');
      }
      if (!context.mounted) {
        log('Context not mounted in DioException catch');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Contact Support',
            onPressed: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'devilmhzn@gmail.com',
                query:
                    'subject=Forgot Password OTP Issue&body=Failed to send OTP for $email',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not open email client')),
                  );
                }
              }
            },
          ),
        ),
      );
    } catch (e, stackTrace) {
      log('Unexpected error in forgetPassword: $e', stackTrace: stackTrace);
      if (!context.mounted) {
        log('Context not mounted in catch block');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => forgetPassword(context, email),
          ),
        ),
      );
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }

  Future<void> verifyOtp(BuildContext context, String email, String otp) async {
    if (!context.mounted) {
      log('Context not mounted in verifyOtp');
      return;
    }
    setLoading(true);
    try {
      log('Verifying OTP for email: $email, OTP: $otp');
      final response = await _dioClient.dio.post(
        '/auth/verify_forgot_password_otp/',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final verifyOtpResponse = VerifyOtpResponse.fromJson(response.data);

      log('Response data: ${verifyOtpResponse.toJson()}');
      if (verifyOtpResponse.success == true) {
        await _authService.saveTokens(
          accessToken: verifyOtpResponse.data ?? '',
          refreshToken: '',
          userId: 0,
          email: email,
        );
        if (!context.mounted) {
          log('Context not mounted after successful OTP verification');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyOtpResponse.message?.toString() ??
                'OTP verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      } else {
        final errorMessage = verifyOtpResponse.message?.toString() ??
            verifyOtpResponse.detail?.toString() ??
            'Failed to verify OTP';
        if (!context.mounted) {
          log('Context not mounted after failed OTP verification');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => verifyOtp(context, email, otp),
            ),
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.response != null) {
        final responseData = VerifyOtpResponse.fromJson(e.response!.data);
        log('Server error response: ${responseData.toJson()}, status: ${e.response!.statusCode}');
        errorMessage = responseData.message?.toString() ??
            responseData.detail?.toString() ??
            'Server error occurred';
            } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      } else {
        log('DioException: ${e.message}, type: ${e.type}');
      }
      if (!context.mounted) {
        log('Context not mounted in DioException catch');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => verifyOtp(context, email, otp),
          ),
        ),
      );
    } catch (e, stackTrace) {
      log('Unexpected error in verifyOtp: $e', stackTrace: stackTrace);
      if (!context.mounted) {
        log('Context not mounted in catch block');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => verifyOtp(context, email, otp),
          ),
        ),
      );
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }

  Future<void> resetPassword(BuildContext context, String email,
      String newPassword, String confirmPassword) async {
    if (!context.mounted) {
      log('Context not mounted in resetPassword');
      return;
    }
    setLoading(true);
    try {
      log('Resetting password for email: $email');
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('No token available for password reset');
      }

      final response = await _dioClient.dio.post(
        '/auth/reset_password/',
        data: {
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      final resetPasswordResponse =
          ResetPasswordResponse.fromJson(response.data);

      log('Response data: ${resetPasswordResponse.toJson()}');
      if (resetPasswordResponse.success == true) {
        await _authService.clearTokens();
        if (!context.mounted) {
          log('Context not mounted after successful password reset');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resetPasswordResponse.message?.toString() ??
                'Password reset successful'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login'); // Changed from Navigator.pushNamedAndRemoveUntil
      } else {
        final errorMessage = resetPasswordResponse.message?.toString() ??
            resetPasswordResponse.detail?.toString() ??
            'Error resetting password';
        if (!context.mounted) {
          log('Context not mounted after failed password reset');
          return;
        }
        if (errorMessage == 'Token has expired. Please request a new OTP.') {
          await _authService.clearTokens(); // Clear the expired token
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Request New OTP',
                onPressed: () {
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () =>
                    resetPassword(context, email, newPassword, confirmPassword),
              ),
            ),
          );
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.response != null) {
        final responseData = ResetPasswordResponse.fromJson(e.response!.data);
        log('Server error response: ${responseData.toJson()}, status: ${e.response!.statusCode}');
        errorMessage = responseData.message?.toString() ??
            responseData.detail?.toString() ??
            'Server error occurred';
            } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      } else {
        log('DioException: ${e.message}, type: ${e.type}');
      }
      if (!context.mounted) {
        log('Context not mounted in DioException catch');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () =>
                resetPassword(context, email, newPassword, confirmPassword),
          ),
        ),
      );
    } catch (e, stackTrace) {
      log('Unexpected error in resetPassword: $e', stackTrace: stackTrace);
      if (!context.mounted) {
        log('Context not mounted in catch block');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () =>
                resetPassword(context, email, newPassword, confirmPassword),
          ),
        ),
      );
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }
}
