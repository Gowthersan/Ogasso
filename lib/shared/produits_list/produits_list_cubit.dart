import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/services/entities/client.dart';
import 'package:ogasso_employe/services/entities/menu.dart';
import 'package:ogasso_employe/services/entities/produit.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/menu_service.dart';
import 'package:ogasso_employe/services/repository/produit_service.dart';
import 'package:ogasso_employe/services/repository/reservation_service.dart';

class ProduitListCubit extends Cubit<ProduitListState> {
  final AuthService _authService = new AuthService();
  final ReservationService _reservationService = new ReservationService();
  final MenuService _menuService = new MenuService();
  final ProduitService _produitService = new ProduitService();

  ProduitListCubit(ProduitListState initialState) : super(initialState);

  load(Reservation reservation,
      {List<ReservationProduit>? initialReservationProduits}) async {
    try {
      emit(ProduitListLoading());
      final String? token = await _authService.getToken();
      if (token == null) {
        emit(ProduitListInitialState(reservationProduits: initialReservationProduits ?? [], produits: []));
        return;
      }
      final List<ReservationProduit> reservationProduits =
          await _reservationService.getReservationProduit(
              token: token, reservationId: reservation.id);
      final List<Produit> produits = await _produitService.getAllProduit(token: token);
      emit(ProduitListInitialState(reservationProduits: reservationProduits, produits: produits));
    } catch (err) {
      print(err);
      emit(ProduitListInitialState(
          reservationProduits: initialReservationProduits ?? [], produits: []));
    }
  }

  removeProduit(
      {required ReservationProduit reservationProduit,
      required List<ReservationProduit> reservationProduits}) async {
    try {
      emit(ProduitListLoading());
      final String? token = await _authService.getToken();
      if (token == null) {
        emit(ProduitListInitialState(reservationProduits: reservationProduits, produits: []));
        return;
      }
      await _reservationService.deleteReservationProduit(
          token: token, reservationProduitId: reservationProduit.id);
      await load(reservationProduit.reservation,
          initialReservationProduits: reservationProduits);
    } catch (err) {
      print(err);
      emit(ProduitListInitialState(reservationProduits: reservationProduits, produits: []));
    }
  }

  createReservationProduit(
      {Client? client,
      required int quantite,
      required bool isFree,
      required Produit produit,
      required List<ReservationProduit> reservationProduits,
      required Reservation reservation}) async {
    try {
      emit(ProduitListLoading());
      final String? token = await _authService.getToken();
      if (token == null) {
        emit(ProduitListInitialState(reservationProduits: reservationProduits, produits: []));
        return;
      }
      final Profil profil = await _authService.getAuthProfil();
      final List<MenuProduit> menuProduits = await _menuService.getTodayMenu(
          token: token, restaurantId: profil.restaurant.id);
      MenuProduit? menuProduit;
      try {
        menuProduit = menuProduits.firstWhere(
            (element) => element.produit.id == produit.id);
      } catch (e) {
        menuProduit = null;
      }
      if (menuProduit == null) {
        emit(ProduitListInitialState(reservationProduits: reservationProduits, produits: []));
        return;
      }
      await _reservationService.createReservationProduit(token: token, data: {
        "reservation": reservation.id,
        "quantite": quantite,
        "menuProduit": menuProduit.id,
        "isFree": isFree
      });
      await load(reservation, initialReservationProduits: reservationProduits);
    } catch (err) {
      print(err);
      emit(ProduitListInitialState(reservationProduits: reservationProduits, produits: []));
    }
  }
}

class ProduitListState {}

class ProduitListInitialState extends ProduitListState {
  final List<ReservationProduit> reservationProduits;
  final List<Produit> produits;

  ProduitListInitialState({required this.produits, required this.reservationProduits});
}

class ProduitListLoading extends ProduitListState {}
