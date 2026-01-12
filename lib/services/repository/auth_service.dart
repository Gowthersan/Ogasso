import 'dart:convert';

import 'package:ogasso_employe/services/entities/client.dart';
import 'package:ogasso_employe/services/repository/api_service.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String TOKEN_KEY = "token_key";
  static String getUserInitial(Client client){
    if(client.prenom.isNotEmpty){
      return client.prenom[0];
    }
    if(client.nom.isNotEmpty){
      return client.nom[0];
    }
    return "O";
  }

  Future<String> login({required final String email, required final String password}) async {
    Map<String, String> params = {
      'username': email,
      'password': password,
      'grant_type': 'password',
      'client_id': 'null',
      'client_secret': 'null'
    };
    final response = await http.post(
        APIService.uri("/api/account/login"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        encoding: Encoding.getByName('utf-8'),
        body: params);
    if (response.statusCode == 200) {
      final Map<String, dynamic> token = jsonDecode(response.body);
      return token["access_token"];
    } else {
      throw (new Exception("Authentification fail ${response.body}"));
    }
  }

  Future<String> updateAccount(
      {required final String token, required Map<String, dynamic> data, required String id}) async {
    final response = await http.put(APIService.uri("/api/account/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw (new Exception("Update client fail ${response.body}"));
    }
  }

  Future<Profil> getAuthProfil() async {
    final String? token = await getToken();
    if (token == null) {
      throw Exception("No token found");
    }
    final response = await http.get(
        APIService.uri("/api/profil/search/by-account"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Profil.fromJson(data);
    } else {
      throw (new Exception("Error ${response.body}"));
    }
  }

  Future<String?> getToken() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getString(TOKEN_KEY);
  }

  Future<void> persistToken({required final String token}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString(TOKEN_KEY, token);
  }

  Future<void> removeToken() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.remove(TOKEN_KEY);
  }
}
