import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ogasso_employe/services/repository/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  static const String KEY_NOTIFICATION = "key-notification";
  static PushNotificationService? instance;

  static initialize() {
    instance = new PushNotificationService();
  }

  StreamController<NotificationInfo> _streamController =
      new StreamController<NotificationInfo>();

  Stream<NotificationInfo> getStream() {
    return _streamController.stream;
  }

  _grantFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<String?> getDeviceToken() async {
    await _grantFCM();

    // Sur iOS, attendre que le token APNS soit disponible
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        // Attendre un peu et réessayer (le token APNS peut prendre du temps)
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }
      if (apnsToken == null) {
        print('APNS token not available');
        return null;
      }
    }

    return await FirebaseMessaging.instance.getToken();
  }

  onMessage() async {
    await _grantFCM();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      print('Message also contained a notification: ${message.notification}');
      if (message.notification != null) {
        String? id;
        if (message.data.isNotEmpty && message.data.containsKey("id")) {
          id = message.data["id"];
        }
        handleNotificaion(message, id);
      }
    });
  }

  handleNotificaion(RemoteMessage message, String? id) async {
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      NotificationType notificationType = NotificationType.NewMessage;
      if (message.notification?.title == "Reservation confirme") {
        notificationType = NotificationType.ConfirmReservation;
      } else if (message.notification?.title == "Reservation annule") {
        notificationType = NotificationType.AnnuleReservation;
      } else if (message.notification?.title == "Reservation") {
        notificationType = NotificationType.CreateReservation;
      } else if (message.notification?.title == "Paiement") {
        notificationType = NotificationType.PaiementResponse;
      }
      NotificationInfo notification = new NotificationInfo(
        type: notificationType.index,
        message: message.notification?.body,
        date: DateTime.now(),
        id: id,
      );
      await LocalNotificationService.instance?.displayingNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        id: id ?? '',
      );
      await persistNotification(notification);
      _streamController.add(notification);
    }
  }

  persistNotification(NotificationInfo notification) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final List<String> notificationList = sharedPreferences.getStringList(
      KEY_NOTIFICATION,
    ) ?? [];
    notification.index = notificationList.length;
    notificationList.add(jsonEncode(notification.toMap()));
    sharedPreferences.setStringList(KEY_NOTIFICATION, notificationList);
  }

  Future<List<NotificationInfo>> getAllNotification() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final List<String> notificationList = sharedPreferences.getStringList(
      KEY_NOTIFICATION,
    ) ?? [];
    return List.generate(
      notificationList.length,
      (index) => NotificationInfo.fromJson(jsonDecode(notificationList[index])),
    );
  }

  removeNotifcation(NotificationInfo notification) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final List<String> notificationList = sharedPreferences.getStringList(
      KEY_NOTIFICATION,
    ) ?? [];
    notificationList.removeWhere((element) {
      final n = NotificationInfo.fromJson(jsonDecode(element));
      return n.id == notification.id &&
          n.index == notification.index &&
          n.date == notification.date;
    });
    sharedPreferences.setStringList(KEY_NOTIFICATION, notificationList);
  }
}

enum NotificationType {
  NewMessage,
  ConfirmReservation,
  CreateReservation,
  AnnuleReservation,
  PaiementResponse,
}

class NotificationInfo {
  final int type;
  final String? message;
  final String? id;
  final DateTime date;
  int index;

  NotificationInfo({this.type = 0, this.index = 0, required this.date, this.message, this.id});

  factory NotificationInfo.fromJson(Map<String, dynamic> json) =>
      NotificationInfo(
        type: json["type"] ?? 0,
        message: json["message"],
        id: json["id"],
        index: json["index"] ?? 0,
        date: DateTime.fromMillisecondsSinceEpoch(json["date"]),
      );

  Map<String, dynamic> toMap() => {
    "type": type,
    "message": message,
    "id": id,
    "index": index,
    "date": date.millisecondsSinceEpoch,
  };
}
