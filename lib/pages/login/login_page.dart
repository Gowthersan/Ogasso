import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/login/login_cubit.dart';
import 'package:ogasso_employe/pages/login/login_form.dart';
import 'package:ogasso_employe/pages/splash_screen/splash_screen_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(LoginFormState()),
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              if (state is LoginFormLoadingState) {
                return LoginForm(
                  loading: true,
                );
              }
              if (state is LoginResultState) {
                if (state.success) {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SplashScreenPage()));
                  });
                } else {
                  return LoginForm(loading: false, error: true);
                }
              }
              return LoginForm(
                loading: false,
              );
            },
          ),
        ));
  }
}
