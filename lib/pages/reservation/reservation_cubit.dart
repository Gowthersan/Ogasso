import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/reservation_service.dart';

class ReservationCubit extends Cubit<ReservationState> {
  final AuthService _authService = new AuthService();
  final ReservationService _reservationService = new ReservationService();

  ReservationCubit(ReservationState initialState) : super(initialState);

  load() async {
    emit(ReservationLoading());
    try {
      final String? token = await _authService.getToken();
      if (token == null) {
        emit(ReservationInitial(reservations: [], toDayReservation: []));
        return;
      }
      final Profil profil = await _authService.getAuthProfil();
      final List<Reservation> reservations =
          await _reservationService.getAllReservationByRestaurant(
              token: token, restaurantId: profil.restaurant.id);
      final List<Reservation> todayReservation = [];
      for (int i = 0; i < reservations.length; i++) {
        final today = DateTime.now();
        final reservation = reservations[i];
        if (today.day == reservation.date.day &&
            today.month == reservation.date.month &&
            today.year == reservation.date.year) {
          todayReservation.add(reservations[i]);
        }
      }
      emit(ReservationInitial(
          toDayReservation: todayReservation, reservations: reservations));
    } catch (err) {
      print(err);
      emit(ReservationInitial(reservations: [], toDayReservation: []));
    }
  }
}

class ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationInitial extends ReservationState {
  final List<Reservation> reservations;
  final List<Reservation> toDayReservation;
  List<Reservation> _reservationType = [];
  List<Reservation> _commandeType = [];

  ReservationInitial({required this.toDayReservation, required this.reservations}) {
    for (int i = 0; i < this.reservations.length; i++) {
      if (this.reservations[i].type == "Reservation") {
        _reservationType.add(reservations[i]);
      } else {
        _commandeType.add(reservations[i]);
      }
    }
  }

  getReservations(){
    return _reservationType;
  }

  getCommandes(){
    return _commandeType;
  }
}
