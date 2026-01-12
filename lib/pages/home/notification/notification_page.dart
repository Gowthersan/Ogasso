import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/home/notification/notification_cubit.dart';
import 'package:ogasso_employe/services/repository/push_notification_service.dart'
    as push;
import 'package:ogasso_employe/shared/util/date.dart';

class NotificationPage extends StatefulWidget {
  final List<push.NotificationInfo> notifications;
  final StreamController homeController;

  const NotificationPage(
      {Key? key, required this.notifications, required this.homeController})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<void> onOpen(push.NotificationInfo notification) async {}

  Widget displayNotifications(
      {required List<push.NotificationInfo> notifications}) {
    if (notifications.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications,
            size: 100,
            color: Colors.grey[300],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Aucune notification",
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                BlocProvider.of<NotificationCubit>(context).openReservation(
                    notifications[index], widget.homeController);
              },
              subtitle: Text("${notifications[index].message}"),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "${formatHeure(notifications[index].date)}",
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
        ),
        body: BlocProvider(
          create: (context) => NotificationCubit(
              NotificationInitial(notifications: widget.notifications)),
          child: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationInitial) {
                return displayNotifications(
                    notifications: state.notifications.reversed.toList());
              }
              if (state is NextPage) {
                widget.homeController.add(state.notificationInfo);
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => state.widget));
                });
                return Container();
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ));
  }
}
