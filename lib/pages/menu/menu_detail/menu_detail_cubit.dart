import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/entities/menu.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/menu_service.dart';

class MenuDetailCubit extends Cubit<MenuDetailState> {
  final MenuService _menuService = MenuService();
  final AuthService _authService = AuthService();

  MenuDetailCubit(MenuDetailState initialState) : super(initialState);

  loadMenu(MenuProduit produit) async {
    final String? token = await _authService.getToken();
    if (token == null) return;
    final Profil profil = await _authService.getAuthProfil();
    try {
      final List<MenuProduit> menuProduits = await _menuService.getTodayMenu(
          token: token, restaurantId: profil.restaurant.id);
      MenuProduit? update;
      try {
        update = menuProduits.firstWhere(
            (element) => element.produit.id == produit.produit.id);
      } catch (e) {
        update = null;
      }
      if (update != null) {
        emit(MenuDetailInital(menuProduit: update));
      }
    } catch (err) {
      print(err);
    }
  }

  updateQuantite({required final int qt, required final MenuProduit menuProduit}) async {
    emit(MenuDetailLoading());
    final String? token = await _authService.getToken();
    if (token == null) return;
    await _menuService.updateDirectQuantite(
        token: token, menuProduit: menuProduit, quantite: qt);
    loadMenu(menuProduit);
  }
}

class MenuDetailState {}

class MenuDetailInital extends MenuDetailState {
  final MenuProduit menuProduit;

  MenuDetailInital({required this.menuProduit});
}

class MenuDetailLoading extends MenuDetailState {}
