import 'dart:convert';


import 'package:http/http.dart' as http;
import 'package:ogasso_employe/services/entities/chat_message.dart';
import 'package:ogasso_employe/services/entities/open_chat_log.dart';
import 'package:ogasso_employe/services/repository/api_service.dart';

class ChatService {
  Future<List<ChatMessage>> getChatMessageByReservation(
      {required String token, required String reservationId}) async {
    final response = await http.get(
        APIService.uri("/api/chat/search/by-reservation/${reservationId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List.generate(
          body.length, (index) => ChatMessage.fromJson(body[index]));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<ChatMessage> createChatMessage(
      {required String token,
      required String content,
      required String userAccountId,
      required String reservationId}) async {
    final response = await http.post(APIService.uri("/api/chat"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "reservation": reservationId,
          "auteur": userAccountId,
          "content": content,
          "reservation": reservationId,
        }));
    if (response.statusCode == 200) {
      print(response.body);
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<List<OpenChatLog>> getOpenChatLogByReservaiton(
      {required String token, required String reservationId}) async {
    final response = await http.get(
        APIService.uri("/api/chat/open/search/by-reservation/${reservationId}"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List.generate(
          body.length, (index) => OpenChatLog.fromJson(body[index]));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }

  Future<OpenChatLog> createOpenChatLog(
      {required String token, required String userAccountId, required String reservationId}) async {
    final response = await http.post(APIService.uri("/api/chat/open"),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "reservation": reservationId,
          "user": userAccountId,
        }));
    if (response.statusCode == 200) {
      return OpenChatLog.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception("Error ${response.statusCode}");
    }
  }
}
