import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/menu/menu_cubit.dart';
import 'package:ogasso_employe/pages/menu/menu_detail/menu_detail_page.dart';
import 'package:ogasso_employe/services/entities/menu.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/repository/api_service.dart';
import 'package:ogasso_employe/shared/util/variable.dart';

class MenuPage extends StatefulWidget {
  final Profil? profil;

  const MenuPage({Key? key, this.profil}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<MenuUpdated> updated = [];

  MenuUpdated? isOnLoading(MenuProduit menuProduit) {
    try {
      return updated
          .firstWhere((element) => element.menuProduit.id == menuProduit.id);
    } catch (e) {
      return null;
    }
  }

  Widget _disponibiliteCursor(BuildContext context, MenuProduit menuProduit,
      List<MenuUpdated> updated) {
    final MenuUpdated? menuUpdated = isOnLoading(menuProduit);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            icon: Icon(
              Icons.remove_circle,
              color: Colors.blue,
            ),
            onPressed: () {
              BlocProvider.of<MenuCubit>(context).addQuantite(
                  count: -1, menuProduit: menuProduit, updated: updated);
            }),
        Text(
          "${menuUpdated != null ? menuUpdated.newQuantite : menuProduit.quantite}",
          style: TextStyle(
              color: menuUpdated != null ? Colors.grey[400] : Colors.orange),
        ),
        IconButton(
            icon: Icon(
              Icons.add_circle,
              color: Colors.blue,
            ),
            onPressed: () {
              BlocProvider.of<MenuCubit>(context).addQuantite(
                  count: 1, menuProduit: menuProduit, updated: updated);
            })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
      ),
      body: BlocProvider<MenuCubit>(
        create: (context) =>
            MenuCubit(MenuLoading())..loadMenu(updated: updated),
        child: BlocBuilder<MenuCubit, MenuState>(
          builder: (context, state) {
            if (state is MenuInitial) {
              return ListView.builder(
                  itemCount: state.menuProduits.length,
                  itemBuilder: (context, index) {
                    final MenuProduit menuProduit = state.menuProduits[index];
                    return ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MenuDetailPage(
                                      initialMenuProduit:
                                          state.menuProduits[index],
                                    )));
                      },
                      title: Text(menuProduit.produit.nom),
                      subtitle: Text("${menuProduit.produit.prix} FCFA"),
                      leading: Image.network(
                        menuProduit.produit.photoURL == null
                            ? default_logo_url
                            : "http://${APIService.URL}/upload${menuProduit.produit.photoURL!.split("/upload")[1]}",
                        width: 48,
                        height: 48,
                      ),
                      trailing: _disponibiliteCursor(
                          context, menuProduit, state.updated),
                    );
                  });
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
