import 'package:flutter/material.dart';
import 'package:ogasso_employe/pages/reservation/chat/messagerie_widget.dart';
import 'package:ogasso_employe/pages/reservation/reservation_client/reservation_client_page.dart';
import 'package:ogasso_employe/pages/reservation/reservation_detail_general/reservation_detail_general_page.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';

class ReservationDetailPage extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetailPage({Key? key, required this.reservation}) : super(key: key);

  @override
  _ReservationDetailPageState createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.shopping_bag_outlined),
                  text: widget.reservation.type.toUpperCase(),
                ),
                Tab(
                  icon: Icon(Icons.messenger_outline_sharp),
                  text: "Messagerie".toUpperCase(),
                ),
                Tab(
                  icon: Icon(Icons.person),
                  text: "Client".toUpperCase(),
                ),
              ],
            ),
            title: Text(widget.reservation.numero)),
        body: TabBarView(
          children: [
            ReservationDetailGeneralPage(
              reservation: widget.reservation,
            ),
            MessagerieWidget(reservation: widget.reservation,),
            ReservationClientPage(reservation: widget.reservation)
          ],
        ),
      ),
    );
  }
}
