import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/entities/client.dart';
import 'package:ogasso_employe/services/entities/produit.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/client_service.dart';
import 'package:ogasso_employe/services/repository/reservation_service.dart';

class ReservationClientCubit extends Cubit<ReservationClientState> {
  final AuthService _authService = new AuthService();
  final ReservationService _reservationService = new ReservationService();
  final ClientService _clientService = new ClientService();

  ReservationClientCubit(ReservationClientState initialState)
      : super(initialState);

  load(Client? client) async {
    if (client == null) {
      emit(ReservationClientLoading());
      return;
    }
    try {
      emit(ReservationClientLoading());
      final String? token = await _authService.getToken();
      if (token == null) return;
      final Client clientFound =
          await _clientService.getClient(token: token, clientId: client.id);
      print(clientFound.account?.username);
      final List<Reservation> reservations = await _reservationService
          .getAllReservation(token: token, clientId: client.id);
      print("${reservations.length}");
      final Map<String, dynamic> favoris = await _reservationService
          .getPlatfavoris(token: token, clientId: client.id);
      final Produit? produit = favoris['produit'];
      final int produitCount = favoris['count'];
      emit(ReservationClientInitial(
          client: clientFound,
          produit: produit,
          produitCount: produitCount,
          lastReservation: reservations.last));
    } catch (err) {
      print(err);
      emit(ReservationClientInitial(client: client));
    }
  }
}

class ReservationClientState {}

class ReservationClientInitial extends ReservationClientState {
  final Client client;
  final Produit? produit;
  final int? produitCount;
  final Reservation? lastReservation;

  ReservationClientInitial(
      {this.produit, this.produitCount, this.lastReservation, required this.client});
}

class ReservationClientLoading extends ReservationClientState {}
