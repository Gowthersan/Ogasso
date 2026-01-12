import 'package:ogasso_employe/services/entities/restaurant.dart';

import 'client.dart';
import 'menu.dart';

class Reservation {
  final Client? client;
  final Restaurant? restaurant;
  final DateTime date;
  final String status;
  final String id;
  final String numero;
  final String creneau;
  final bool isConfirmed;
  final int placeCount;
  final String type;
  final String? causeAnnulation;
  final DateTime? dateAnnulation;
  final bool isAnnule;
  final String? evaluation;
  final int? paiement_amount;
  final String? paiement_method;
  final String? paiement_reference;
  final DateTime? paiement_date;
  final String? paiement_status;
  final String? receptionMode;
  final String? livraisonQuartier;
  final String? livraisonRepere;
  final String? livraisonContact;
  final String? livraisonPersonne;

  Reservation(
      {this.livraisonQuartier,
      this.livraisonRepere,
      this.livraisonContact,
      this.livraisonPersonne,
      this.receptionMode,
      this.paiement_amount,
      this.paiement_method,
      this.paiement_reference,
      this.paiement_date,
      this.paiement_status,
      this.evaluation,
      this.causeAnnulation,
      this.isAnnule = false,
      this.dateAnnulation,
      this.numero = '',
      this.creneau = '',
      this.isConfirmed = false,
      this.placeCount = 0,
      this.type = '',
      this.id = '',
      this.client,
      this.restaurant,
      required this.date,
      this.status = ''});

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
        livraisonContact: json["livraisonContact"],
        livraisonPersonne: json["livraisonPersonne"],
        livraisonQuartier: json["livraisonQuartier"],
        livraisonRepere: json["livraisonRepere"],
        client: json["client"] == null ? null : Client.fromJson(json["client"]),
        restaurant: json["restaurant"] != null
            ? Restaurant.fromJson(json["restaurant"])
            : null,
        date: json['date'] != null
            ? DateTime.parse(json["date"])
            : DateTime.parse(json["create_at"]),
        status: json["status"] ?? '',
        numero: json["numero"] ?? '',
        creneau: json["creneau"] ?? '',
        isConfirmed: json["isConfirmed"] ?? false,
        placeCount: json["placeCount"] ?? 0,
        type: json["type"] ?? '',
        dateAnnulation: json["dateAnnulation"] != null
            ? DateTime.parse(json["dateAnnulation"])
            : null,
        causeAnnulation: json["causAnnulation"],
        isAnnule: json["isAnnule"] ?? false,
        evaluation: json["evaluation"],
        receptionMode: json["receptionMode"],
        paiement_amount: json["paiement_amount"],
        paiement_date: json["paiement_date"] != null
            ? DateTime.parse(json["paiement_date"])
            : null,
        paiement_method: json["paiement_method"],
        paiement_reference: json["paiement_reference"],
        paiement_status: json["paiement_status"],
        id: json["_id"] ?? '');
  }
}

class ReservationProduit {
  final Reservation reservation;
  final int quantite;
  final MenuProduit menuProduit;
  final DateTime date;
  final String id;
  final bool isFree;

  ReservationProduit(
      {this.isFree = false,
      required this.reservation,
      this.quantite = 0,
      required this.menuProduit,
      required this.date,
      this.id = ''});

  factory ReservationProduit.fromJson(Map<String, dynamic> json) =>
      ReservationProduit(
          reservation: Reservation.fromJson(json["reservation"]),
          menuProduit: MenuProduit.fromJson(json["menuProduit"]),
          date: DateTime.parse(json["date"]),
          quantite: json["quantite"] ?? 0,
          isFree: json['isFree'] ?? false,
          id: json["_id"] ?? '');
}
