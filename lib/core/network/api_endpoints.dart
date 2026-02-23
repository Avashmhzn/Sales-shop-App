// import 'dart:developer' as developer;

// import 'package:saleup_app/core/network/dio_client.dart';

// class Api {
//   // Public base URL – used before login and during company selection
//   static const String publicBaseUrl = "http://192.168.1.8:8000/api";

//   // Production (uncomment when ready)
//   // static const String publicBaseUrl = "https://salesshopnepal.com/api";

//   // Private base URL – updated dynamically after company selection
//   static String privateBaseUrl = "http://192.168.1.8:8000/api";

//   // Internal flag: true = after company selection → use private
//   static bool _isPrivateMode = false;

//   // Current active base URL (used mainly for logging & debugging)
//   static String get currentBaseUrl =>
//       _isPrivateMode ? privateBaseUrl : publicBaseUrl;

//   // Call this after selecting a company
//   static void switchToPrivate(String? selectedDomain) {
//     _isPrivateMode = true;

//     if (selectedDomain != null && selectedDomain.trim().isNotEmpty) {
//       // FIXED: Always include the port in development
//       privateBaseUrl = "http://$selectedDomain:8000/api";
//       developer.log(
//         'API → Switched to PRIVATE: $privateBaseUrl (domain: $selectedDomain)',
//         name: 'Api',
//       );
//     } else {
//       // Fallback also with port
//       privateBaseUrl = "http://192.168.1.8:8000/api";
//       developer.log(
//         'API → No domain provided → using default private: $privateBaseUrl',
//         name: 'Api',
//       );
//     }

//     // This line updates Dio — very important
//     DioClient().updateBaseUrl(privateBaseUrl);
//   }

//   // Call on logout or when going back to public mode
//   static void resetToPublic() {
//     _isPrivateMode = false;
//     privateBaseUrl = publicBaseUrl;
//     developer.log('API → Reset to PUBLIC: $publicBaseUrl', name: 'Api');

//     DioClient().updateBaseUrl(publicBaseUrl);
//   }
// }

//production and dev code
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;

import 'package:saleup_app/core/network/dio_client.dart';

class Api {
  // ─────────────────────────────────────────────────────────────
  // Public base URL – used before login and company selection
  // ─────────────────────────────────────────────────────────────
  static String get publicBaseUrl {
    if (kDebugMode) {
      // Development: your local laptop + Django dev server port
      return "http://192.168.1.64:8000/api";
    } else {
      // Production: change this to your real live domain
      // Option A: single domain style (simplest)
      return "https://salesshopnepal.com/api";

      // Option B: if you use API subdomain (recommended for multi-tenant)
      // return "https://api.salesshopnepal.com";
    }
  }

  // Private base URL – updated dynamically after company selection
  static String privateBaseUrl = publicBaseUrl;

  // Flag: true = after company selection → use tenant-specific domain
  static bool _isPrivateMode = false;

  // Current active base URL (for logging & debugging)
  static String get currentBaseUrl =>
      _isPrivateMode ? privateBaseUrl : publicBaseUrl;

  // ─────────────────────────────────────────────────────────────
  // Switch to tenant/company-specific (private) base URL
  // ─────────────────────────────────────────────────────────────
  static void switchToPrivate(String? selectedDomain) {
    _isPrivateMode = true;

    if (selectedDomain != null && selectedDomain.trim().isNotEmpty) {
      // Build URL intelligently based on environment
      const protocol = kDebugMode ? 'http' : 'https';
      const portPart = kDebugMode ? ':8000' : ''; // No port in production

      // Use the domain exactly as stored in DB
      // In production DB should contain: flutter.salesshopnepal.com, public.salesshopnepal.com, etc.
      privateBaseUrl = "$protocol://$selectedDomain$portPart/api";

      developer.log(
        'API → Switched to PRIVATE: $privateBaseUrl (original domain: $selectedDomain)',
        name: 'Api',
      );
    } else {
      // Fallback to public base (safe default)
      privateBaseUrl = publicBaseUrl;
      developer.log(
        'API → No domain provided → fallback to: $privateBaseUrl',
        name: 'Api',
      );
    }

    // Critical: update Dio with the new base URL
    DioClient().updateBaseUrl(privateBaseUrl);
  }

  // ─────────────────────────────────────────────────────────────
  // Reset to public mode (logout, etc.)
  // ─────────────────────────────────────────────────────────────
  static void resetToPublic() {
    _isPrivateMode = false;
    privateBaseUrl = publicBaseUrl;

    developer.log(
      'API → Reset to PUBLIC: $publicBaseUrl',
      name: 'Api',
    );

    DioClient().updateBaseUrl(publicBaseUrl);
  }

  // Optional helpers for debugging
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;

  static void logEnvironment() {
    developer.log(
      'Api initialized in ${isDevelopment ? "DEVELOPMENT" : "PRODUCTION"} mode',
      name: 'Api',
    );
  }
}
