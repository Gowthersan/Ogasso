import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/home/actions/setting_page.dart';
import 'package:ogasso_employe/pages/home/notification/notification_page.dart';
import 'package:ogasso_employe/pages/menu/menu_page.dart';
import 'package:ogasso_employe/pages/reservation/reservation_page.dart';
import 'package:ogasso_employe/pages/splash_screen/splash_screen_page.dart';
import 'package:ogasso_employe/services/entities/account.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/repository/push_notification_service.dart'
    as push;
import 'package:ogasso_employe/shared/util/color.dart';

import 'home_cubit.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Profil? profil;
  HomeCubit homeCubit = HomeCubit(HomeLoading());
  List<push.NotificationInfo> notifications = [];
  final StreamController<push.NotificationInfo> notificationStream =
      StreamController<push.NotificationInfo>();

  Widget _menuItem(
      {required String title,
      required String subtitle,
      Widget? onTap,
      bool alert = false,
      bool warning = false}) {
    return ListTile(
      dense: true,
      title: Text("$title"),
      subtitle: Text("$subtitle"),
      onTap: () {
        if (onTap != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => onTap));
        } else {
          _showLogoutConfirmDialog();
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "!",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: alert
                      ? Colors.red
                      : warning
                          ? Colors.orange
                          : Colors.transparent),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _menu({bool alert = false, bool warning = false}) {
    return Column(
      children: [
        Divider(),
        _menuItem(
            alert: alert,
            warning: warning,
            title: "Menu",
            subtitle: "Gérer le menu de votre restaurant",
            onTap: MenuPage(
              profil: profil,
            )),
        Divider(),
        _menuItem(
            title: "Réservations & Commandes",
            subtitle: "Gérer les reservations et les commandes",
            onTap: ReservationPage()),
        Divider(),
        _menuItem(
            title: "Se déconnecter",
            subtitle: "Quitter l'application",
            onTap: null),
        Divider(),
      ],
    );
  }

  _showLogoutConfirmDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Se déconnecter"),
              content: Text("Voulez vous vraiment vous déconnecter?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Non")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      homeCubit.logout();
                    },
                    child: Text("Oui")),
              ],
            ));
  }

  String getCharacter(Profil profil) {
    if (profil.prenom.isNotEmpty) {
      return profil.prenom[0].toUpperCase();
    }
    if (profil.nom.isNotEmpty) {
      return profil.nom[0].toUpperCase();
    }
    return "O";
  }

  Widget _home(Profil profil) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32.0,
            child: Text(
              "${getCharacter(profil)}",
              style: TextStyle(fontSize: 32.0),
            ),
            backgroundColor: Color(getColor(
                UserAccount.AVATAR_COLOR[profil.account.initial_color])),
            foregroundColor: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${profil.nom} ${profil.prenom}",
              style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: Colors.black,
                  fontSize: 24.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Text(
              "${profil.restaurant.nom}",
              style: TextStyle(color: Colors.blue[700], fontSize: 14.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${profil.restaurant.adresse}",
              style: TextStyle(color: Colors.grey, fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      title: Text("Collaborateurs"),
      actions: [
        IconButton(
            icon: Badge(
                isLabelVisible: notifications.length > 0,
                label: Text("${notifications.length}"),
                child: Icon(Icons.notifications_none)),
            onPressed: () {
              //GoToNotificationPage
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationPage(
                            notifications: notifications,
                            homeController: notificationStream,
                          )));
            }),
        PopupMenuButton(
            onSelected: (v) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingPage()));
            },
            itemBuilder: (context) =>
                [PopupMenuItem(value: 1, child: Text("Paramètre"))])
      ],
    );
  }

  loadNotification() async {
    List<push.NotificationInfo> n =
        await push.PushNotificationService.instance?.getAllNotification() ?? [];
    setState(() {
      notifications = n;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotification();
    try {
      push.PushNotificationService.instance?.getStream().listen((event) async {
        await loadNotification();
      });
    } catch (err) {
      print(err);
    }
    notificationStream.stream.listen((event) async {
      await loadNotification();
    });
  }

  @override
  void dispose() {
    super.dispose();
    notificationStream.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SplashScreenPage()));
        },
        label: Text("Actualiser"),
        icon: Icon(Icons.refresh),
      ),
      appBar: _appBar(),
      body: BlocProvider<HomeCubit>(
        create: (context) => homeCubit..load(),
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial) {
              profil = state.profil;
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _home(state.profil),
                  _menu(alert: state.alert, warning: state.warning)
                ],
              );
            }
            if (state is HomeReloadApp) {
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SplashScreenPage()));
              });
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                _menu(),
              ],
            );
          },
        ),
      ),
    );
  }
}
