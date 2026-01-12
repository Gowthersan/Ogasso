
import 'package:ogasso_employe/services/entities/account.dart';

class OpenChatLog {
  final String id;
  final UserAccount user;
  final DateTime date;
  final String reservation;

  OpenChatLog({this.id = '', required this.user, required this.date, this.reservation = ''});

  factory OpenChatLog.fromJson(Map<String, dynamic> json) => OpenChatLog(
      id: json["_id"] ?? '',
      user: UserAccount.fromJson(json["auteur"]),
      reservation: json["reservation"]["_id"] ?? '',
      date: DateTime.parse(json["date"]));
}
