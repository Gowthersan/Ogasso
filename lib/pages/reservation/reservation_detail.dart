import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/reservation/reservation_detail_cubit.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservationDetail extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetail({Key? key, required this.reservation})
      : super(key: key);

  @override
  _ReservationDetailState createState() => _ReservationDetailState();
}

class _ReservationDetailState extends State<ReservationDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservation detail"),
      ),
      body: BlocProvider<ReservationDetailCubit>(
        create: (context) => ReservationDetailCubit(ReservationDetailLoading(),
            reservation: widget.reservation)
          ..load(),
        child: BlocBuilder<ReservationDetailCubit, ReservationDetailState>(
          builder: (context, state) {
            if (state is ReservationDetailInitial) {
              int total = 0;
              state.reservationProduits.forEach((produit) {
                if (produit.menuProduit.produit.prix != null) {
                  total += produit.quantite * produit.menuProduit.produit.prix;
                }
              });
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text(
                        "${widget.reservation.client?.nom ?? ''} ${widget.reservation.client?.prenom ?? ''}"),
                    subtitle: Text("${widget.reservation.status}"),
                    trailing: Text(
                        "${widget.reservation.date.hour}:${widget.reservation.date.minute}"),
                  ),
                  if (widget.reservation.status == "Annule")
                    ListTile(
                      title: Text("${widget.reservation.causeAnnulation}"),
                      subtitle: widget.reservation.dateAnnulation == null
                          ? Icon(Icons.alarm)
                          : Text(
                              "${widget.reservation.dateAnnulation!.day}/${widget.reservation.dateAnnulation!.month}/${widget.reservation.dateAnnulation!.year} a ${widget.reservation.dateAnnulation!.hour}:${widget.reservation.dateAnnulation!.minute}"),
                    ),
                  Divider(),
                  Expanded(
                      child: ListView.builder(
                          itemCount: state.reservationProduits.length,
                          itemBuilder: (context, index) {
                            final produit = state.reservationProduits[index];
                            return ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: produit.menuProduit.produit.photoURL !=
                                          null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              "http://${APIService.URL}/upload${produit.menuProduit.produit.photoURL!.split("/upload")[1]}"))
                                      : null,
                                ),
                              ),
                              title: Text("${produit.menuProduit.produit.nom}"),
                              subtitle: Text("${produit.quantite}"),
                            );
                          })),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Montant: ${total} FCFA",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.green),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: QrImageView(
                        data: "${widget.reservation.id}",
                        size: 200.0,
                      ),
                    ),
                  )
                ],
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
