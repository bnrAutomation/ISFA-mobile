import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_broadcast_receiver/flutter_broadcast_receiver.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/tabber_module/models/remote_notification.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_auth_helper.dart';
import 'package:i_densfa/utility/device_auth_session.dart';

Map<String, String> _authorizedRequestHeaders({
  Map<String, String>? extra,
}) {
  final token = AppStorage().authToken ?? '';
  return {
    if (token.isNotEmpty) HttpHeaders.authorizationHeader: 'Bearer $token',
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.contentTypeHeader: 'application/json',
    ...DeviceAuthSession.apiHeaders(),
    ...?extra,
  };
}

class _SessionExpireGuard {
  static bool fired = false;
}

class _DeviceAuthGuard {
  static bool fired = false;
}

/// Reset guards after a fresh login (call from login success flows if needed).
void resetHttpAuthGuards() {
  _SessionExpireGuard.fired = false;
  _DeviceAuthGuard.fired = false;
}

String getErrorMessage(Response response, {bool suppressSessionPopup = false}) {
  try {
    if (response.statusCode == 401) {
      if (!suppressSessionPopup && !_SessionExpireGuard.fired) {
        _SessionExpireGuard.fired = true;
        BroadcastReceiver().publish<String>(AppConstant.sectionExpire,
            arguments: AppRemoteNotification(
                    title: "Session Expired.",
                    body: "Session Expired. Please Login again.")
                .toRawJson());
      }
      return "Session Expired. Please Login again.";
    }
    if (response.statusCode == 500) {
      return "Something went wrong. Please try again..";
    }
    if (response.statusCode == 403) {
      final deviceError = tryParseDeviceAuthException(response);
      if (deviceError != null) {
        if (!suppressSessionPopup && !_DeviceAuthGuard.fired) {
          _DeviceAuthGuard.fired = true;
          DeviceAuthSession.clear();
          AppStorage().logout();
          BroadcastReceiver().publish<String>(
            AppConstant.sectionExpire,
            arguments: AppRemoteNotification(
              title: 'Login Failed',
              body: deviceError.message,
            ).toRawJson(),
          );
        }
        return deviceError.message;
      }
    }
    final body = jsonDecode(response.body);
    final String mess = body['message'] ?? body["error"];
    return mess;
  } catch (e) {
    return "Something went wrong";
  }
}

String getErrorMessageSteam(StreamedResponse response, String body,
    {bool suppressSessionPopup = false}) {
  try {
    if (response.statusCode == 401) {
      if (!suppressSessionPopup && !_SessionExpireGuard.fired) {
        _SessionExpireGuard.fired = true;
        BroadcastReceiver().publish<String>(AppConstant.sectionExpire,
            arguments: AppRemoteNotification(
                    title: "Session Expired.",
                    body: "Session Expired. Please Login again.")
                .toRawJson());
      }
      return "Session Expired. Please Login again.";
    }
    if (response.statusCode == 500) {
      return "Something went wrong. Please try again..";
    }
    final bod = jsonDecode(body);
    final String mess = bod['message'] ?? bod["error"]??"";
    return mess;
  } catch (e) {
    return "Something went wrong";
  }
}

class CustomHttpBaseClient extends BaseClient {
  static CustomHttpBaseClient? _instance;
  static CustomHttpBaseClient get instance {
    _instance ??= CustomHttpBaseClient._internal();
    return _instance!;
  }
  
  CustomHttpBaseClient._internal();
  
  final Client _client = Client();
  final Map<String, Response> _cache = {};
  final Duration _cacheTimeout = const Duration(minutes: 5);
  
 String get auth => AppStorage().authToken ?? "";
 String get fcm => AppStorage().fcmToken ?? "";
  
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    try {
      // Add headers
      if (auth.isNotEmpty) {
        request.headers.addAll(_authorizedRequestHeaders());
      } else {
        if (kDebugMode) {
          debugPrint('👁️ Missing Header..... !');
        }
        throw "Something went wrong";
      }

      if (kDebugMode) {
        debugPrint('👁️ ${request.method} => ${request.url.toString()}');
        debugPrint('👁️ Token => $auth');
      }
     // debugPrint('👁️ FCM Token => $fcm');
      
      final response = await _client.send(request);
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('👁️ Network error: $e');
      }
      throw "Something went wrong";
    }
  }
  
  /// Get method with caching support
  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    final cacheKey = url.toString();
    final shouldUseCache = _shouldCache(url);

    if (shouldUseCache) {
      final cachedResponse = _cache[cacheKey];
      if (cachedResponse != null) {
        if (kDebugMode) {
          debugPrint('👁️ Cache hit for: $url');
        }
        return cachedResponse;
      }
    }
    
    final mergedHeaders = _authorizedRequestHeaders(extra: headers);

    if (kDebugMode) {
      debugPrint('👁️ GET => $url');
      debugPrint('👁️ Token => $auth');
    }

    final response = await _client.get(url, headers: mergedHeaders);
    
    // Cache successful responses only when allowed
    if (shouldUseCache && response.statusCode == 200) {
      _cache[cacheKey] = response;
      
      // Remove cache after timeout
      Future.delayed(_cacheTimeout, () {
        _cache.remove(cacheKey);
      });
    }
    
    return response;
  }
  
  /// Post method
  @override
  Future<Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = _authorizedRequestHeaders(extra: headers);

    if (kDebugMode) {
      debugPrint('👁️ POST => $url');
      debugPrint('👁️ Token => ${AppStorage().authToken ?? ""}');
    }

    return await _client.post(url, headers: mergedHeaders, body: body, encoding: encoding);
  }
  
  /// Put method
  @override
  Future<Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = _authorizedRequestHeaders(extra: headers);

    if (kDebugMode) {
      debugPrint('👁️ PUT => $url');
      debugPrint('👁️ Token => ${AppStorage().authToken ?? ""}');
    }

    return await _client.put(url, headers: mergedHeaders, body: body, encoding: encoding);
  }
  
  /// Delete method
  @override
  Future<Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = _authorizedRequestHeaders(extra: headers);

    if (kDebugMode) {
      debugPrint('👁️ DELETE => $url');
      debugPrint('👁️ Token => ${AppStorage().authToken ?? ""}');
    }

    return await _client.delete(url, headers: mergedHeaders, body: body, encoding: encoding);
  }
  
  /// Clear cache manually if needed
  void clearCache() {
    _cache.clear();
  }

  /// Decide which GET requests should be cached
  bool _shouldCache(Uri url) {
    final path = url.path;

    // Do NOT cache highly dynamic campaign-related endpoints
    if (
      path.contains("/iSFA/mechanic")||
      path.contains("/iSFA/recruiter")||
      path.contains("iSFA/client/modules")||
      path.contains("/leave/user/")||
      path.contains("/attendance")||
      path.contains("/authentication-service/iam/api/v1/user/detail")||
      path.contains("/authentication-service/iam/api/v1/authenticate")||
      path.contains('/campaign-service/iSFA/api/v1/campaign/client') ||
      path.contains('/campaign-service/iSFA/api/v1/client/campaign/campaign-response') ||
      path.contains('/iSFA/api/campaign/exists')) {
      return false;
    }

    // Do NOT cache these endpoints (always fetch fresh data)
    if (
        path.contains("api/v1/analytics")||
        path.contains("getEmpLeaveBalanceDetails")||
        path.contains("getEmpLeaveDetails")||
        path.contains("auth")||
        path.contains('getPromoterDetail') ||
        path.contains('getInventory') ||
        path.contains('getCategoryList') ||
         path.contains("/attendance")||
        path.contains('productNames') ||
        path.contains("api/check")||
        path.contains('MarkIn') ||
        path.contains('MarkOut') ||
        path.contains('StartDuty') ||
        path.contains('EndDuty')) {
      return false;
    }

    // Default: cache other GET requests
    return true;
  }
  
  /// Close the underlying client
  @override
  void close() {
    _client.close();
    _cache.clear();
  }
}

void printLongString(String text) {
  if (!kDebugMode) return;
  final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern
      .allMatches(text)
      .forEach((RegExpMatch match) => debugPrint(match.group(0)));
}
