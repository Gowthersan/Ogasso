
import 'package:ogasso_employe/services/entities/reservation.dart';

class ReservationFull {
  final Reservation reservation;
  final List<ReservationProduit> produits;

  ReservationFull({required this.reservation, required this.produits});

}