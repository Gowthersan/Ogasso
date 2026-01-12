import 'dart:convert';

import 'package:ogasso_employe/services/entities/menu.dart';
import 'package:http/http.dart' as http;
import 'package:ogasso_employe/services/repository/api_service.dart';

class MenuService {
  Future<List<MenuProduit>> getTodayMenu(
      {required final String token, required final String restaurantId}) async {
    final response = await http.get(
        APIService.uri("/api/menu/search/by-restaurant/${restaurantId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List.generate(
          body.length, (index) => MenuProduit.fromJson(body[index]));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<String> updateQuantite({required final String token, required final MenuProduit menuProduit, required final int operation }) async {
    int quantite = menuProduit.quantite + operation;
    if(quantite < 0) {
      return "Insufisant";
    }
    final response = await http.put(APIService.uri("/api/menu/${menuProduit.id}"), headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }, body: jsonEncode({
      "quantite": quantite
    }));
    if(response.statusCode == 200){
      return "Success";
    } else {
      return "Error";
    }
  }

  Future<String> updateDirectQuantite({required final String token, required final MenuProduit menuProduit, required final int quantite }) async {
    final response = await http.put(APIService.uri("/api/menu/${menuProduit.id}"), headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }, body: jsonEncode({
      "quantite": quantite
    }));
    if(response.statusCode == 200){
      return "Success";
    } else {
      return "Error";
    }
  }
}
