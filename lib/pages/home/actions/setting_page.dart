import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/home/actions/setting_cubit.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _alertController = new TextEditingController();
  final TextEditingController _warningController = new TextEditingController();
  bool hasChanged = false;

  Widget _main({final bool loading = false}) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètre"),
        actions: [
          IconButton(
              onPressed: () {
                _settingCubit.save(
                    alert: int.parse(_alertController.text),
                    warning: int.parse(_warningController.text));
                Navigator.pop(context);
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (loading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Paramètre de menu",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _alertController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Seuil d'alerte",
                    helperText:
                        "Quel est la quantité minimale que doit avoir un produit dans le stock?"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _warningController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Seuil d'avertissement",
                    helperText:
                        "Quel est la quantite minimale idéal pour un produit dans le stock Ogasso?"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SettingCubit _settingCubit = new SettingCubit(SettingLoading());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingCubit>(
      create: (context) => _settingCubit..load(),
      child: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          if (state is SettingInitial) {
            _alertController.text = state.alert.toString();
            _warningController.text = state.warning.toString();
            return _main();
          }
          return _main(loading: true);
        },
      ),
    );
  }
}
