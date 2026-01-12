import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ogasso_employe/services/entities/produit.dart';
import 'package:ogasso_employe/services/repository/api_service.dart';

class ProduitService {
  Future<List<Produit>> getAllProduit(
      {required final String token}) async {
    final response = await http.get(
        APIService.uri("/api/produit/"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List.generate(
          body.length, (index) => Produit.fromJson(body[index]));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }
}