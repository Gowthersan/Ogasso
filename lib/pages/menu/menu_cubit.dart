import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/entities/menu.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/menu_service.dart';

class MenuCubit extends Cubit<MenuState> {
  final MenuService _menuService = new MenuService();
  final AuthService _authService = new AuthService();

  MenuCubit(MenuState initialState) : super(initialState);

  loadMenu({required List<MenuUpdated> updated}) async {
    final String? token = await _authService.getToken();
    if (token == null || isClosed) return;
    final Profil profil = await _authService.getAuthProfil();
    if (isClosed) return;
    try {
      final List<MenuProduit> menuProduits = await _menuService.getTodayMenu(
          token: token, restaurantId: profil.restaurant.id);
      if (!isClosed) {
        emit(MenuInitial(menuProduits: menuProduits, updated: updated));
      }
    } catch (err) {
      print(err);
      if (!isClosed) {
        emit(MenuInitial(menuProduits: [], updated: updated));
      }
    }
  }

  addQuantite(
      {required final int count,
      required final MenuProduit menuProduit,
      required final List<MenuUpdated> updated}) async {
    if (isClosed) return;
    updated.add(MenuUpdated(
        menuProduit: menuProduit, newQuantite: menuProduit.quantite + count));
    await loadMenu(updated: updated);
    if (isClosed) return;
    final String? token = await _authService.getToken();
    if (token == null || isClosed) return;
    await _menuService.updateQuantite(
        token: token, menuProduit: menuProduit, operation: count);
    if (isClosed) return;
    updated.removeWhere((element) =>
        element.menuProduit.id.toString() == menuProduit.id.toString());
    await loadMenu(updated: updated);
  }
}

class MenuState {}

class MenuInitial extends MenuState {
  final List<MenuProduit> menuProduits;
  final List<MenuUpdated> updated;

  MenuInitial({required this.updated, required this.menuProduits});
}

class MenuLoading extends MenuState {}

class MenuUpdated {
  final MenuProduit menuProduit;
  final int newQuantite;

  MenuUpdated({required this.menuProduit, required this.newQuantite});
}
