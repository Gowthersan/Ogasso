import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/menu/menu_detail/menu_detail_cubit.dart';
import 'package:ogasso_employe/services/entities/menu.dart';
import 'package:ogasso_employe/services/repository/api_service.dart';
import 'package:ogasso_employe/shared/util/variable.dart';

class MenuDetailPage extends StatefulWidget {
  final MenuProduit initialMenuProduit;

  const MenuDetailPage({Key? key, required this.initialMenuProduit})
      : super(key: key);

  @override
  _MenuDetailPageState createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  final TextEditingController _quantiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantiteController.text = widget.initialMenuProduit.quantite.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.initialMenuProduit.produit.nom}"),
      ),
      body: BlocProvider<MenuDetailCubit>(
        create: (context) => MenuDetailCubit(MenuDetailLoading())
          ..loadMenu(widget.initialMenuProduit),
        child: BlocBuilder<MenuDetailCubit, MenuDetailState>(
          builder: (context, state) {
            if (state is MenuDetailInital) {
              _quantiteController.text = state.menuProduit.quantite.toString();
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            state.menuProduit.produit.photoURL == null
                                ? default_logo_url
                                : "http://${APIService.URL}/upload${state.menuProduit.produit.photoURL!.split("/upload")[1]}",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Detail",
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16.0, top: 8.0),
                                child: Text(
                                  "${state.menuProduit.produit.description}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Divider(),
                              Text(
                                "${state.menuProduit.produit.prix} FCFA",
                                textAlign: TextAlign.end,
                                style: TextStyle(color: Colors.orange),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text("Modifier la quantite"),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: TextField(
                                  controller: _quantiteController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: "Quantite",
                                      contentPadding: EdgeInsets.all(8.0),
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    BlocProvider.of<MenuDetailCubit>(context)
                                        .updateQuantite(
                                            menuProduit: state.menuProduit,
                                            qt: int.parse(
                                                _quantiteController.text));
                                  },
                                  child: Text("Enregistrer la modification"))
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
