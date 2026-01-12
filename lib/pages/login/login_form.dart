import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/login/login_cubit.dart';

class LoginForm extends StatefulWidget {
  final bool loading;
  final bool error;

  const LoginForm({Key? key, this.loading = false, this.error = false})
      : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  void onLoginButtonPressed() {
    String email = emailController.text;
    String password = passwordController.text;
    BlocProvider.of<LoginCubit>(context)
        .login(email: email, password: password);
  }

  Widget _loadingWidget() {
    return Container(
      decoration: BoxDecoration(color: Color.fromARGB(200, 0, 0, 0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Authentification en cours...",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              "Collaborateur Ogasso",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Vous êtes un employé de Ogasso? cette application permet de gérer la relation client. connectez vous dès maintenant.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Connectez-vous !",
                  style: TextStyle(color: Colors.brown, fontSize: 16.0),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Adresse email"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: "Mot de passe"),
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                  child: Text(
                    "Mot de passe oublie? contactez l'administrateur",
                    style: TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                      onPressed: onLoginButtonPressed,
                      child: Text("Se connecter")),
                ),
                if (widget.error == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Erreur d'authentification !",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [_formWidget(), if (widget.loading) _loadingWidget()],
    );
  }
}
