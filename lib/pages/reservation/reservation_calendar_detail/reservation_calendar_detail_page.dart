import 'package:flutter/material.dart';
import 'package:ogasso_employe/pages/reservation/reservation_detail/reservation_detail_page.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';

class ReservationCalendarDetailPage extends StatefulWidget {
  final List<Reservation> reservationType;
  final List<Reservation> commandeType;
  final DateTime date;

  const ReservationCalendarDetailPage(
      {Key? key, required this.reservationType, required this.commandeType, required this.date})
      : super(key: key);

  @override
  _ReservationCalendarDetailPageState createState() =>
      _ReservationCalendarDetailPageState();
}

class _ReservationCalendarDetailPageState
    extends State<ReservationCalendarDetailPage> {
  Widget getReservationList(List<Reservation> list) {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReservationDetailPage(
                            reservation: list[index],
                          )));
            },
            title: Text("${list[index].numero}"),
            subtitle: Text("${list[index].status}"),
            trailing: Text("${list[index].creneau}"),
            leading: CircleAvatar(
              child: Container(),
              radius: 8.0,
              backgroundColor:
                  list[index].isConfirmed ? Colors.green : Colors.red,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.shopping_bag_outlined),
                text: "Commande".toUpperCase(),
              ),
              Tab(
                icon: Icon(Icons.restaurant_menu),
                text: "Reservation".toUpperCase(),
              ),
            ],
          ),
          title: Text(
              "Reservation ${widget.date.day}/${widget.date.month}/${widget.date.year}"),
        ),
        body: TabBarView(
          children: [
            getReservationList(widget.commandeType),
            getReservationList(widget.reservationType)
          ],
        ),
      ),
    );
  }
}
