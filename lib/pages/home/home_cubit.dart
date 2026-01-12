import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/entities/menu.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/menu_service.dart';
import 'package:ogasso_employe/services/repository/setting_service.dart';

class HomeCubit extends Cubit<HomeState> {
  final AuthService authService = new AuthService();
  final MenuService _menuService = new MenuService();
  final SettingService _settingService = new SettingService();

  HomeCubit(HomeState initialState) : super(initialState);

  load() async {
    emit(HomeLoading());
    try {
      final int seuilAlerte = await _settingService.getAlert();
      final int seuilWarning = await _settingService.getWarning();
      final String? token = await authService.getToken();
      if (token == null) {
        emit(HomeReloadApp());
        return;
      }
      final Profil profil = await authService.getAuthProfil();
      emit(HomeInitial(profil: profil));
      final List<MenuProduit> menuProduits = await _menuService.getTodayMenu(
          token: token, restaurantId: profil.restaurant.id);
      for (int i = 0; i < menuProduits.length; i++) {
        if (menuProduits[i].quantite <= seuilWarning) {
          emit(HomeInitial(profil: profil, warning: true));
        }
        if (menuProduits[i].quantite <= seuilAlerte) {
          emit(HomeInitial(profil: profil, alert: true));
          break;
        }
      }
    } catch (err) {
      await authService.removeToken();
      emit(HomeReloadApp());
    }
  }

  logout() async {
    emit(HomeLoading());
    await authService.removeToken();
    emit(HomeReloadApp());
  }
}

class HomeState {}

class HomeLoading extends HomeState {}

class HomeInitial extends HomeState {
  final Profil profil;
  final bool alert;
  final bool warning;

  HomeInitial({this.alert = false, this.warning = false, required this.profil});
}

class HomeReloadApp extends HomeState {}
