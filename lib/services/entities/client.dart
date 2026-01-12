import 'account.dart';

class Client {
  final String nom;
  final String prenom;
  final UserAccount? account;
  final String id;
  final String? photoURL;
  final String adresse;
  final String ville;
  final String? telephone;

  Client(
      {this.adresse = '',
      this.ville = '',
      this.photoURL,
      this.id = '',
      this.nom = '',
      this.prenom = '',
      this.telephone,
      this.account});

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json['_id'] ?? '',
        nom: json['nom'] ?? '',
        adresse: json['adresse'] ?? '',
        ville: json['ville'] ?? '',
        prenom: json['prenom'] ?? '',
        telephone: json['telephone'],
        photoURL: json['photoURL'],
        account: json['account'] is String || json['account'] == null
            ? null
            : UserAccount.fromJson(json['account']),
      );
}
