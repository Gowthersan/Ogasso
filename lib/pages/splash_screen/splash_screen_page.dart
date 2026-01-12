import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ogasso_employe/pages/home/home_page.dart';
import 'package:ogasso_employe/pages/login/login_page.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/push_notification_service.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  late Future<String> _tokenFuture;

  Future<String> loadToken() async {
    final AuthService authService = AuthService();
    final token = await authService.getToken();
    if (token != null) {
      Profil? profil;
      try {
        profil = await authService.getAuthProfil();
      } catch(err){
        print('Erreur getAuthProfil: $err');
        authService.removeToken();
        // Retourne l'erreur pour l'afficher si c'est un problème de profil
        if (err.toString().contains('Profil invalide')) {
          throw err;
        }
        return 'null';
      }
      final PushNotificationService? pushNotificationService =
          PushNotificationService.instance;
      final String? deviceToken = await pushNotificationService?.getDeviceToken();
      print(deviceToken);
      try {
        if (profil.account.id != null && deviceToken != null) {
          authService.updateAccount(
              token: token,
              data: {"device_token": deviceToken},
              id: profil.account.id!);
        }
      } catch(err){
        print(err);
        authService.removeToken();
        return 'null';
      }
    }
    return token ?? 'null';
  }

  @override
  void initState() {
    super.initState();
    _tokenFuture = loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ogasso"),
      ),
      body: FutureBuilder(
        future: _tokenFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            Widget pageWidget = LoginPage();
            if (snapshot.data != 'null') {
              pageWidget = HomePage();
            }
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => pageWidget));
            });
            return Container();
          } else if (snapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Erreur au demarrage",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      "Veuillez redemarrer l'application, si le probleme persiste vous pouvez contact le service technique: 077598300"),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "${snapshot.error}",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
