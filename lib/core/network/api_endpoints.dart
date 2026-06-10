// import 'dart:developer' as developer;
// import 'package:flutter/foundation.dart' show kReleaseMode;
// import 'package:saleup_app/core/network/dio_client.dart';

// class Api {
//   // ─────────────────────────────────────────────────────────────
//   // TOGGLE: set true  → use production URLs (real server)
//   //         set false → use local dev server (192.168.x.x)
//   // ─────────────────────────────────────────────────────────────
//   static const bool forceProduction = true;

//   static bool get _useProduction => kReleaseMode || forceProduction;

//   // ─────────────────────────────────────────────────────────────
//   // FIXED domains — do NOT add subdomain, protocol, or /api here
//   // Subdomain is added dynamically in switchToPrivate()
//   // ─────────────────────────────────────────────────────────────
//   static const String _productionMainDomain = "salesshopnepal.com";
//   static const String _devBaseUrl = "http://192.168.1.65:8000/api";

//   // ─────────────────────────────────────────────────────────────
//   // PUBLIC base URL — used before login and company selection
//   // Production → https://salesshopnepal.com/api
//   // Dev        → http://192.168.1.65:8000/api
//   // ─────────────────────────────────────────────────────────────
//   static String get publicBaseUrl {
//     if (_useProduction) {
//       return "https://$_productionMainDomain/api";
//     } else {
//       return _devBaseUrl;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // PRIVATE base URL — updated after company/tenant selection
//   // ─────────────────────────────────────────────────────────────
//   static String privateBaseUrl = publicBaseUrl;

//   // Flag: true = company selected → use tenant subdomain URL
//   static bool _isPrivateMode = false;

//   // Currently active base URL (for logging & debugging)
//   static String get currentBaseUrl =>
//       _isPrivateMode ? privateBaseUrl : publicBaseUrl;

//   // ─────────────────────────────────────────────────────────────
//   // Switch to tenant/company subdomain after company selection
//   //
//   // DB stores SUBDOMAIN ONLY — examples:
//   //   "flutter"  → https://flutter.salesshopnepal.com/api
//   //   "demo"     → https://demo.salesshopnepal.com/api
//   //   "company1" → https://company1.salesshopnepal.com/api
//   // ─────────────────────────────────────────────────────────────
//   static void switchToPrivate(String? subdomain) {
//     _isPrivateMode = true;

//     if (subdomain != null && subdomain.trim().isNotEmpty) {
//       final cleanSubdomain = subdomain.trim().toLowerCase();

//       if (_useProduction) {
//         // https://flutter.salesshopnepal.com/api
//         privateBaseUrl = "https://$cleanSubdomain.$_productionMainDomain/api";
//       } else {
//         // Dev: local server handles all tenants
//         privateBaseUrl = _devBaseUrl;
//       }

//       developer.log(
//         'API → Switched to PRIVATE: $privateBaseUrl  (subdomain: $cleanSubdomain)',
//         name: 'Api',
//       );
//     } else {
//       // No subdomain → safe fallback
//       privateBaseUrl = publicBaseUrl;

//       developer.log(
//         'API → No subdomain → fallback to PUBLIC: $privateBaseUrl',
//         name: 'Api',
//       );
//     }

//     // Update Dio with new base URL
//     DioClient().updateBaseUrl(privateBaseUrl);
//   }

//   // ─────────────────────────────────────────────────────────────
//   // Reset to public mode — call on logout or company switch
//   // ─────────────────────────────────────────────────────────────
//   static void resetToPublic() {
//     _isPrivateMode = false;
//     privateBaseUrl = publicBaseUrl;

//     developer.log(
//       'API → Reset to PUBLIC: $publicBaseUrl',
//       name: 'Api',
//     );

//     DioClient().updateBaseUrl(publicBaseUrl);
//   }

//   // ─────────────────────────────────────────────────────────────
//   // Helpers
//   // ─────────────────────────────────────────────────────────────
//   static bool get isProduction => _useProduction;
//   static bool get isDevelopment => !_useProduction;
//   static bool get isPrivateMode => _isPrivateMode;

//   static void logEnvironment() {
//     developer.log(
//       '─────────────────────────────────────────\n'
//       'Environment : ${isDevelopment ? "DEVELOPMENT" : "PRODUCTION"}\n'
//       'Public URL  : $publicBaseUrl\n'
//       'Current URL : $currentBaseUrl\n'
//       'Private Mode: $_isPrivateMode\n'
//       '─────────────────────────────────────────',
//       name: 'Api',
//     );
//   }
// }

//api end points.dart
//new api end point
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:saleup_app/core/network/dio_client.dart';

class Api {
  // ─────────────────────────────────────────────────────────────
  // TOGGLE: true  → production URLs
  //         false → local dev server
  // ─────────────────────────────────────────────────────────────
  // static const bool forceProduction = true;
  static const bool forceProduction = bool.fromEnvironment(
    'FORCE_PRODUCTION',
    defaultValue: true,
  );

  static bool get _useProduction => kReleaseMode || forceProduction;

  // ─────────────────────────────────────────────────────────────
  // Base domain — no protocol, no subdomain, no /api
  // ─────────────────────────────────────────────────────────────
  static const String _productionMainDomain = "salesshopnepal.com";
  static const String _devBaseUrl = "http://192.168.1.73:8000/api";

  // ─────────────────────────────────────────────────────────────
  // PUBLIC base URL — used before login and company selection
  //   Production → https://salesshopnepal.com/api
  //   Dev        → http://192.168.1.73:8000/api
  // ─────────────────────────────────────────────────────────────
  static String get publicBaseUrl {
    if (_useProduction) {
      return "https://$_productionMainDomain/api";
    } else {
      return _devBaseUrl;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PRIVATE base URL — set after company selection
  // ─────────────────────────────────────────────────────────────
  static String privateBaseUrl = publicBaseUrl;
  static bool _isPrivateMode = false;

  static String get currentBaseUrl =>
      _isPrivateMode ? privateBaseUrl : publicBaseUrl;

  // ─────────────────────────────────────────────────────────────
  // Switch to tenant subdomain after company selection
  //
  // Handles BOTH cases automatically:
  //   DB stores "flutter"                    → https://flutter.salesshopnepal.com/api
  //   DB stores "flutter.salesshopnepal.com" → https://flutter.salesshopnepal.com/api
  // ─────────────────────────────────────────────────────────────
  static void switchToPrivate(String? subdomain) {
    _isPrivateMode = true;

    if (subdomain != null && subdomain.trim().isNotEmpty) {
      final clean = subdomain.trim().toLowerCase();

      if (_useProduction) {
        String finalUrl;

        if (clean.contains(_productionMainDomain)) {
          // DB stored full domain like "flutter.salesshopnepal.com"
          // Strip any accidental https:// or /api prefix/suffix
          final domainOnly = clean
              .replaceAll('https://', '')
              .replaceAll('http://', '')
              .replaceAll('/api', '')
              .trim();
          finalUrl = "https://$domainOnly/api";
        } else {
          // DB stored subdomain only like "flutter"
          finalUrl = "https://$clean.$_productionMainDomain/api";
        }

        privateBaseUrl = finalUrl;
      } else {
        // Dev: single local server handles all tenants
        privateBaseUrl = _devBaseUrl;
      }

      developer.log(
        'API → Switched to PRIVATE: $privateBaseUrl  (input: $clean)',
        name: 'Api',
      );
    } else {
      privateBaseUrl = publicBaseUrl;
      developer.log(
        'API → No subdomain provided → fallback to PUBLIC: $privateBaseUrl',
        name: 'Api',
      );
    }

    DioClient().updateBaseUrl(privateBaseUrl);
  }

  // ─────────────────────────────────────────────────────────────
  // Reset to public — call on logout
  // ─────────────────────────────────────────────────────────────
  static void resetToPublic() {
    _isPrivateMode = false;
    privateBaseUrl = publicBaseUrl;
    developer.log('API → Reset to PUBLIC: $publicBaseUrl', name: 'Api');
    DioClient().updateBaseUrl(publicBaseUrl);
  }

  static bool get isProduction => _useProduction;
  static bool get isDevelopment => !_useProduction;
  static bool get isPrivateMode => _isPrivateMode;

  static void logEnvironment() {
    developer.log(
      '─────────────────────────────────────────\n'
      'Environment : ${isDevelopment ? "DEVELOPMENT" : "PRODUCTION"}\n'
      'Public URL  : $publicBaseUrl\n'
      'Current URL : $currentBaseUrl\n'
      'Private Mode: $_isPrivateMode\n'
      '─────────────────────────────────────────',
      name: 'Api',
    );
  }
}
