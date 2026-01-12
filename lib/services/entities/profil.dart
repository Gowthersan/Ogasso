import 'package:ogasso_employe/services/entities/restaurant.dart';

import './account.dart';

class Profil {
  final String nom;
  final String prenom;
  final UserAccount account;
  final String id;
  final Restaurant restaurant;

  Profil({this.id = '', this.nom = '', this.prenom = '', required this.account, required this.restaurant});

  factory Profil.fromJson(Map<String, dynamic> json) {
    final accountData = json['account'];
    final restaurantData = json['restaurant'];

    if (accountData == null) {
      throw Exception('Profil invalide: compte utilisateur manquant');
    }
    if (restaurantData == null) {
      throw Exception('Profil invalide: restaurant non assigné');
    }

    return Profil(
      id: json['_id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      account: UserAccount.fromJson(accountData),
      restaurant: Restaurant.fromJson(restaurantData),
    );
  }
}