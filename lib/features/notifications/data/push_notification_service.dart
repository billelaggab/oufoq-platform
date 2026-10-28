import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/config/app_constants.dart';

/// خدمة إشعارات الأخبار العاجلة (FCM + الإشعارات المحلية).
///
/// تتعامل بهدوء مع غياب ملف google-services.json أثناء التطوير
/// دون إسقاط التطبيق.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// لا يُلمس قبل `Firebase.initializeApp()` وإلا رمى `no-app`.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  bool _available = false;
  bool _initialized = false;

  /// يُستدعى عند النقر على إشعار يحمل post_id.
  void Function(int postId)? onArticleTapped;

  Future<void> initialize({
    required String channelName,
    required String channelDescription,
  }) async {
    if (_initialized) {
      return;
    }
    try {
      await Firebase.initializeApp();
      _available = true;
      _initialized = true;
    } on Object catch (error) {
      // غياب google-services.json أو أي فشل تهيئة => وضع آمن صامت،
      // مع السماح بمحاولة لاحقة إن توفر الإعداد.
      debugPrint('FCM unavailable (safe fallback): $error');
      _available = false;
      return;
    }

    try {
      await _createChannel(channelName, channelDescription);
      await _configureLocalNotifications();
      await _configureMessageHandlers();
    } on Object catch (error) {
      debugPrint('Push notification setup error: $error');
    }
  }

  Future<void> requestPermissionAndSubscribe(String languageCode) async {
    if (!_available) {
      return;
    }
    try {
      final NotificationSettings settings =
          await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await subscribeToLanguage(languageCode);
      }
    } on Object catch (error) {
      debugPrint('Notification permission error: $error');
    }
  }

  Future<void> subscribeToLanguage(String languageCode) async {
    if (!_available) {
      return;
    }
    try {
      await _messaging.subscribeToTopic('breaking_$languageCode');
    } on Object catch (error) {
      debugPrint('Topic subscribe error: $error');
    }
  }

  Future<void> unsubscribeFromLanguage(String languageCode) async {
    if (!_available) {
      return;
    }
    try {
      await _messaging.unsubscribeFromTopic('breaking_$languageCode');
    } on Object catch (error) {
      debugPrint('Topic unsubscribe error: $error');
    }
  }

  /// تبديل الاشتراك عند تغيير اللغة مستقبلاً.
  Future<void> syncLanguageTopic({
    required String oldLanguageCode,
    required String newLanguageCode,
  }) async {
    await unsubscribeFromLanguage(oldLanguageCode);
    await subscribeToLanguage(newLanguageCode);
  }

  Future<void> setNotificationsEnabled({
    required bool enabled,
    required String languageCode,
  }) async {
    if (!_available) {
      return;
    }
    if (enabled) {
      await requestPermissionAndSubscribe(languageCode);
    } else {
      await unsubscribeFromLanguage(languageCode);
    }
  }

  Future<void> _createChannel(String name, String description) async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        AppConstants.breakingChannelId,
        name,
        description: description,
        importance: Importance.high,
      ),
    );
  }

  Future<void> _configureLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final int? postId = int.tryParse(response.payload ?? '');
    if (postId != null) {
      onArticleTapped?.call(postId);
    }
  }

  Future<void> _configureMessageHandlers() async {
    // التطبيق في الواجهة: إشعار محلي فوري.
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // التطبيق في الخلفية ثم نُقر للفتح.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundTap);

    // التطبيق مغلق تماماً عند النقر.
    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleBackgroundTap(initial);
    }
  }

  void _handleBackgroundTap(RemoteMessage message) {
    final dynamic rawId = message.data['post_id'];
    final int? postId = int.tryParse('$rawId');
    if (postId != null) {
      onArticleTapped?.call(postId);
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final String title = message.notification?.title ?? '';
    final String body = message.notification?.body ?? '';
    final String? payload = message.data['post_id']?.toString();
    try {
      await _localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.breakingChannelId,
            '',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: payload,
      );
    } on Object catch (error) {
      debugPrint('Local notification error: $error');
    }
  }
}
