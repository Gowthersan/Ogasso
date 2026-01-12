
import 'package:ogasso_employe/services/entities/account.dart';

class ChatMessage {
  final String id;
  final String content;
  final UserAccount auteur;
  final DateTime date;
  final String reservation;

  ChatMessage(
      {this.id = '', this.content = '', required this.auteur, required this.date, this.reservation = ''});

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
      id: json["_id"] ?? '',
      content: json["content"] ?? '',
      auteur: UserAccount.fromJson(json["auteur"]),
      reservation: json["reservation"]["_id"] ?? '',
      date: DateTime.parse(json["date"]));
}
