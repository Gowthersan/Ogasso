import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ogasso_employe/services/entities/produit.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';

import 'api_service.dart';

class ReservationService {
  Future<List<Reservation>> getAllReservation(
      {required String token, required String clientId}) async {
    final response = await http.get(
        APIService.uri("/api/reservation/search/by-client/${clientId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List.generate(
          body.length, (index) => Reservation.fromJson(body[index]));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<List<Reservation>> getAllReservationByRestaurant(
      {required String token, required String restaurantId}) async {
    final response = await http.get(
        APIService.uri("/api/reservation/search/by-restaurant/${restaurantId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List.generate(
          body.length, (index) => Reservation.fromJson(body[index]));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<List<ReservationProduit>> getReservationProduit(
      {required String token, required String reservationId}) async {
    final response = await http.get(
        APIService.uri(
            "/api/reservation/produit/search/by-reservation/${reservationId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List.generate(
          body.length, (index) => ReservationProduit.fromJson(body[index]));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> getPlatfavoris(
      {required String token, required String clientId}) async {
    final response = await http.get(
        APIService.uri("/api/reservation/produit/favoris/${clientId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return {
        "produit": body['produit'] != null ? Produit.fromJson(body['produit']) : null,
        "count": body['count']
      };
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<Reservation> createReservation(
      {required String token, required Map<String, dynamic> data}) async {
    final response = await http.post(APIService.uri("/api/reservation"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return Reservation.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<Reservation> getReservation({required String token, required String id}) async {
    final response = await http.get(APIService.uri("/api/reservation/${id}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Reservation.fromJson(body);
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<bool> confirmedReservation(
      {required String token, required String reservationId}) async {
    final response = await http.put(
        APIService.uri("/api/reservation/${reservationId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "isConfirmed": true,
        }));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<bool> updateReservation(
      {required String token, required String causeAnnulation, required String reservationId}) async {
    final response = await http.put(
        APIService.uri("/api/reservation/${reservationId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "dateAnnulation": DateTime.now().toIso8601String(),
          "causAnnulation": causeAnnulation,
          "isAnnuler": true,
          "status": "Annule"
        }));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<void> createReservationProduit(
      {required String token, required Map<String, dynamic> data}) async {
    final response = await http.post(APIService.uri("/api/reservation/produit"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return;
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<void> deleteReservationProduit(
      {required String token, required String reservationProduitId}) async {
    final response = await http.delete(
        APIService.uri("/api/reservation/produit/${reservationProduitId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      return;
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }
}
