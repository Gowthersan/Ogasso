class Restaurant {
  final String nom;
  final String id;
  final String adresse;

  Restaurant({this.nom = '', this.id = '', this.adresse = ''});

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['_id'] ?? '',
    nom: json['nom'] ?? '',
    adresse: json['adresse'] ?? '',
  );
}