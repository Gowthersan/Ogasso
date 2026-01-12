
import 'package:ogasso_employe/services/entities/menu.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';

class ReservationProduit {
  final Reservation reservation;
  final MenuProduit menuProduit;
  final int quantite;
  final String id;
  final bool isFree;

  ReservationProduit({this.isFree = false, required this.reservation, required this.menuProduit, this.quantite = 0, this.id = ''});

  factory ReservationProduit.fromJson(Map<String, dynamic> json) => ReservationProduit(
      reservation: Reservation.fromJson(json["reservation"]),
      menuProduit: MenuProduit.fromJson(json["menuProduit"]),
      isFree: json['isFree'] ?? false,
      quantite: json["quantite"] ?? 0,
      id: json["_id"] ?? ''
  );
}