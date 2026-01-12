import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/reservation/chat/messagerie_cubit.dart';
import 'package:ogasso_employe/services/entities/account.dart';
import 'package:ogasso_employe/services/entities/chat_message.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/shared/util/color.dart';

class MessagerieWidget extends StatefulWidget {
  final Reservation reservation;

  const MessagerieWidget({Key? key, required this.reservation})
      : super(key: key);

  @override
  _MessagerieWidgetState createState() => _MessagerieWidgetState();
}

class _MessagerieWidgetState extends State<MessagerieWidget> {
  TextEditingController _contentController = new TextEditingController();
  MessagerieCubit _messagerieCubit = MessagerieCubit(MessagerieLoading());
  bool loading = false;

  String formatHeure(DateTime date) {
    String dateOnly = "Ajourd'hui";
    DateTime now = DateTime.now();
    if (date.day != now.day &&
        date.month != now.month &&
        date.year != now.year) {
      dateOnly =
          "${date.day < 10 ? '0' : ''}${date.day}/${date.month < 10 ? '0' : ''}${date.month}/${date.year}";
    }
    final String timeOnly =
        "${date.hour < 10 ? '0' : ''}${date.hour}:${date.minute < 10 ? '0' : ''}${date.minute}";
    return "$dateOnly, $timeOnly";
  }

  Widget displayAllMessage({required List<ChatMessage> messages}) {
    return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${messages[index].auteur.firstname ?? ''} ${messages[index].auteur.lastname ?? ''}"),
                      Text(
                        "${formatHeure(messages[index].date)}",
                        style: TextStyle(fontSize: 12.0),
                      )
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "${messages[index].content}",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  leading: CircleAvatar(
                    child: Text(
                        "${(messages[index].auteur.lastname?.isNotEmpty ?? false) ? messages[index].auteur.lastname![0].toUpperCase() : 'O'}"),
                    backgroundColor: Color(getColor(UserAccount
                        .AVATAR_COLOR[messages[index].auteur.initial_color])),
                  ),
                ),
              ),
              Divider()
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BlocProvider<MessagerieCubit>(
            create: (context) =>
                _messagerieCubit..loadAllMessage(widget.reservation),
            child: BlocBuilder<MessagerieCubit, MessagerieState>(
              builder: (context, state) {
                if (state is MessagerieInitial) {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    setState(() {
                      loading = false;
                    });
                  });
                  return displayAllMessage(
                      messages: state.messages.reversed.toList());
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
        Divider(
          color: Colors.grey,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                    hintText: "Saisissez votre message ici...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(80),
                        borderSide: BorderSide.none)),
              ),
            ),
            if (loading)
              Center(
                child: CircularProgressIndicator(),
              )
            else
              IconButton(
                  icon: Icon(Icons.send_outlined),
                  onPressed: () {
                    _messagerieCubit.createMessage(
                        content: _contentController.text,
                        reservation: widget.reservation);
                    setState(() {
                      loading = true;
                      _contentController.text = "";
                    });
                  })
          ],
        ),
      ],
    );
  }
}
