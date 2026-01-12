import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:ogasso_employe/pages/reservation/reservation_detail/reservation_detail_page.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/push_notification_service.dart'
    as push;
import 'package:ogasso_employe/services/repository/reservation_service.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(NotificationState initialState) : super(initialState);

  openReservation(
      push.NotificationInfo notification, StreamController controller) async {
    try {
      emit(NotificationLoading());
      final ReservationService reservationService = ReservationService();
      final AuthService authService = AuthService();
      final String? token = await authService.getToken();
      if (token == null || notification.id == null) {
        final List<push.NotificationInfo> notificaitons =
            await push.PushNotificationService.instance?.getAllNotification() ?? [];
        emit(NotificationInitial(notifications: notificaitons));
        return;
      }
      final Reservation reservation = await reservationService.getReservation(
          token: token, id: notification.id!);
      List<ReservationProduit> reservationProduits = [];
      if (reservation.type == "Commande") {
        reservationProduits = await reservationService.getReservationProduit(
            token: token, reservationId: reservation.id);
      }
      Widget widget = ReservationDetailPage(
        reservation: reservation,
      );
      await push.PushNotificationService.instance
          ?.removeNotifcation(notification);
      emit(NextPage(widget, notification));
    } catch (err) {
      print(err);
      final List<push.NotificationInfo> notificaitons =
          await push.PushNotificationService.instance?.getAllNotification() ?? [];
      emit(NotificationInitial(notifications: notificaitons));
    }
  }
}

class NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationInitial extends NotificationState {
  final List<push.NotificationInfo> notifications;

  NotificationInitial({required this.notifications});
}

class NextPage extends NotificationState {
  final Widget widget;
  final push.NotificationInfo notificationInfo;

  NextPage(this.widget, this.notificationInfo);
}
