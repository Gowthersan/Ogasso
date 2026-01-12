import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ogasso_employe/pages/splash_screen/splash_screen_page.dart';
import 'package:ogasso_employe/services/repository/local_notification_service.dart';
import 'package:ogasso_employe/services/repository/push_notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  await LocalNotificationService.initializeLN();
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
  NotificationInfo notification = NotificationInfo(
      type: notificationType.index,
      message: message.notification?.body,
      date: DateTime.now(),
      id: message.data['id']);
  await LocalNotificationService.instance?.displayingNotification(
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
    id: message.data['id'] ?? '',
  );
  await PushNotificationService().persistNotification(notification);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  LocalNotificationService.initializeLN();
  PushNotificationService.instance?.onMessage();
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ogasso Collaborateur',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.brown,
      ),
      home: SplashScreenPage(),
    );
  }
}

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- ${bloc.runtimeType}');
  }
}
