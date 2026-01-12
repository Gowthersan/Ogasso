import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/reservation_service.dart';

class ReservationDetailCubit extends Cubit<ReservationDetailState> {
  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();
  Reservation reservation;

  ReservationDetailCubit(ReservationDetailState initialState,
      {required this.reservation})
      : super(initialState);

  load() async {
    emit(ReservationDetailLoading());
    try {
      final String? token = await _authService.getToken();
      if (token == null) {
        emit(ReservationDetailInitial(reservationProduits: []));
        return;
      }
      if (reservation.type == "Commande") {
        final List<ReservationProduit> reservationProduits =
            await _reservationService.getReservationProduit(
                token: token, reservationId: reservation.id);
        emit(
            ReservationDetailInitial(reservationProduits: reservationProduits));
      } else {
        emit(ReservationDetailInitial(reservationProduits: []));
      }
    } catch (err) {
      print(err);
      emit(ReservationDetailInitial(reservationProduits: []));
    }
  }

  confirmReservation() async {
    emit(ReservationDetailLoading());
    try {
      final String? token = await _authService.getToken();
      if (token == null) {
        emit(ReservationDetailUpdateResult(false));
        return;
      }
      await _reservationService.confirmedReservation(
          token: token, reservationId: reservation.id);
      emit(ReservationDetailUpdateResult(true));
    } catch (err) {
      print(err);
      emit(ReservationDetailUpdateResult(false));
    }
  }
}

class ReservationDetailState {}

class ReservationDetailLoading extends ReservationDetailState {}

class ReservationDetailInitial extends ReservationDetailState {
  final List<ReservationProduit> reservationProduits;

  ReservationDetailInitial({required this.reservationProduits});
}

class ReservationDetailUpdateResult extends ReservationDetailState {
  final bool success;

  ReservationDetailUpdateResult(this.success);
}
