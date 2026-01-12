
import 'package:ogasso_employe/services/entities/produit.dart';
import 'package:ogasso_employe/services/entities/restaurant.dart';

class MenuProduit {
  final Produit produit;
  final Restaurant restaurant;
  final int quantite;
  final DateTime date;
  final String id;

  MenuProduit({ required this.produit, required this.restaurant, this.quantite = 0, required this.date, this.id = '' });

  factory MenuProduit.fromJson(Map<String, dynamic> json) => MenuProduit(
    produit: Produit.fromJson(json["produit"]),
    restaurant: Restaurant.fromJson(json["restaurant"]),
    date: DateTime.parse(json["date"]),
    quantite: json["quantite"] ?? 0,
    id: json["_id"] ?? ''
  );
}