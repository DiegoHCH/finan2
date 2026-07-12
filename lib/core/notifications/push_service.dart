import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Real push notifications (arrive even with the app closed), relayed
/// through a Cloudflare Worker since there's no Cloud Function to trigger
/// this on the Spark plan. The Worker itself calls the FCM HTTP v1 API - see
/// cloudflare/finan2-notifications/worker.js.
///
/// The shared secret the Worker checks must be supplied at build/run time
/// via `--dart-define-from-file=.secrets/dart-defines.json` (gitignored) -
/// it is never hardcoded here.
class PushService {
  PushService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    http.Client? httpClient,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _httpClient = httpClient ?? http.Client();

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  static const _workerUrl = 'https://finan2-notifications.katanalabs-6002.workers.dev';
  static const _workerSecret = String.fromEnvironment('FINAN2_PUSH_WORKER_SECRET');

  /// Web push requires a VAPID key (Firebase Console > Project Settings >
  /// Cloud Messaging > Web configuration > Web Push certificates) - unlike
  /// the worker secret, native platforms don't need this at all.
  static const _vapidKey = String.fromEnvironment('FINAN2_FCM_VAPID_KEY');

  /// Requests permission, grabs this device's FCM token and saves it under
  /// the household so the Worker can find it, then keeps it fresh.
  Future<void> registerToken(String householdId, String uid) async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging.getToken(
      vapidKey: kIsWeb && _vapidKey.isNotEmpty ? _vapidKey : null,
    );
    if (token != null) {
      await _saveToken(householdId, uid, token);
    }
    _messaging.onTokenRefresh.listen((newToken) => _saveToken(householdId, uid, newToken));
  }

  Future<void> _saveToken(String householdId, String uid, String token) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('fcmTokens')
        .doc(token)
        .set({
      'token': token,
      'uid': uid,
      'platform': kIsWeb
          ? 'web'
          : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android'),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Asks the Worker to push [title]/[body] to every device in [householdId]
  /// except [excludeUid]'s (the person who triggered it already sees it live
  /// in the app). Best-effort: never throws, a failed push shouldn't block
  /// anything else.
  Future<void> sendPush({
    required String householdId,
    required String excludeUid,
    required String title,
    required String body,
  }) async {
    if (_workerSecret.isEmpty) return;
    try {
      await _httpClient.post(
        Uri.parse(_workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'householdId': householdId,
          'excludeUid': excludeUid,
          'title': title,
          'body': body,
          'secret': _workerSecret,
        }),
      );
    } catch (_) {
      // Ignored - see doc comment.
    }
  }
}
