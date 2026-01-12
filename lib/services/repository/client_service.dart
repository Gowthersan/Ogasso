
import 'dart:convert';

import 'package:ogasso_employe/services/entities/client.dart';

import 'package:http/http.dart' as http;
import 'package:ogasso_employe/services/repository/api_service.dart';

class ClientService {

  Future<Client> getClient({required final String token, required final String clientId}) async {
    final response = await http.get(
      APIService.uri("/api/client/${clientId}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token}"
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Client.fromJson(data);
    } else {
      throw (new Exception("Error ${response.body}"));
    }
  }

}