class Produit {

  final String? photoURL;
  final String nom;
  final String description;
  final int prix;
  final String id;

  Produit({ this.id = '', this.photoURL, this.nom = '', this.description = '', this.prix = 0 });

  factory Produit.fromJson(Map<String, dynamic> json) => Produit(
      photoURL: json["photoURL"],
      nom: json["nom"] ?? '',
      description: json["description"] ?? '',
      prix: json["prix"] ?? 0,
      id: json["_id"] ?? ''
  );

  @override
  String toString(){
    return nom;
  }
}