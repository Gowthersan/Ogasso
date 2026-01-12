import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static LocalNotificationService? instance;
  
  static initializeLN() {
    instance = LocalNotificationService();
    instance!.initialize();
  }

  MethodChannel platform =
      MethodChannel('dexterx.dev/flutter_local_notifications_example');
      
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  void Function(NotificationResponse)? _onSelectNotification;

  LocalNotificationService() {
    _onSelectNotification = (NotificationResponse response) {
      print("${response.payload}");
    };
  }

  initialize() async {
    // Configuration Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ogasso');
    
    // Configuration iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Configuration combinée
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS, // AJOUT
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
    
    // Demander les permissions pour iOS
    await _requestIOSPermissions();
  }

  // Demande de permissions iOS
  Future<void> _requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  setOnSelectNotification(void Function(NotificationResponse) f) {
    _onSelectNotification = f;
  }

  displayingNotification({
    required String title,
    required String body,
    required String id,
  }) async {
    final randomId = Random().nextInt(100000); // ID unique
    
    // Configuration Android
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      id, // Utilisez l'ID passé en paramètre
      'Channel $id',
      channelDescription: 'Notification $id',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      fullScreenIntent: true,
      playSound: true,
      icon: 'ogasso',
    );
    
    // Configuration iOS - AJOUT IMPORTANT
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );
    
    // Configuration combinée
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails, // AJOUT
    );
    
    // Utilisez randomId au lieu de 0
    await flutterLocalNotificationsPlugin.show(
      randomId,
      title,
      body,
      platformChannelSpecifics,
      payload: id,
    );
  }
}