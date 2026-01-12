import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/entities/chat_message.dart';
import 'package:ogasso_employe/services/entities/open_chat_log.dart';
import 'package:ogasso_employe/services/entities/profil.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/services/repository/chat_service.dart';

class MessagerieCubit extends Cubit<MessagerieState> {
  final AuthService _authService = new AuthService();
  final ChatService _chatService = new ChatService();

  MessagerieCubit(initialState) : super(initialState);

  loadAllMessage(Reservation reservation) async {
    try {
      final String? token = await _authService.getToken();
      if (token == null) {
        emit(MessagerieInitial(messages: []));
        return;
      }
      final List<ChatMessage> messages =
          await _chatService.getChatMessageByReservation(
              reservationId: reservation.id, token: token);
      print(messages);
      emit(MessagerieInitial(messages: messages));
    } catch (err) {
      print(err);
      emit(MessagerieInitial(messages: []));
    }
  }

  createMessage({required String content, required Reservation reservation}) async {
    try {
      final String? token = await _authService.getToken();
      if (token == null) return;
      final Profil client = await _authService.getAuthProfil();
      if (client.account.id == null) return;
      final ChatMessage message = await _chatService.createChatMessage(
          token: token,
          content: content,
          userAccountId: client.account.id!,
          reservationId: reservation.id);
      await loadAllMessage(reservation);
    } catch (err) {
      print(err);
    }
  }
}

class MessagerieState {}

class MessagerieInitial extends MessagerieState {
  final List<ChatMessage> messages;
  final List<OpenChatLog>? openChatLogs;

  MessagerieInitial({this.openChatLogs, required this.messages});
}

class MessagerieLoading extends MessagerieState {
  final List<ChatMessage>? messages;
  final List<OpenChatLog>? openChatLogs;

  MessagerieLoading({this.openChatLogs, this.messages});
}
