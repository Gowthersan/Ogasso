import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/home/home_page.dart';
import 'package:ogasso_employe/pages/reservation/reservation_detail_cubit.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/shared/produits_list/produits_list_screen.dart';
import 'package:ogasso_employe/shared/util/date.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservationDetailGeneralPage extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetailGeneralPage({Key? key, required this.reservation})
      : super(key: key);

  @override
  _ReservationDetailGeneralPageState createState() =>
      _ReservationDetailGeneralPageState();
}

class _ReservationDetailGeneralPageState
    extends State<ReservationDetailGeneralPage> {
  late ReservationDetailCubit _cubit;

  int totalCost = 0;

  final StreamController<List<ReservationProduit>> _priceStreamController =
      new StreamController<List<ReservationProduit>>();

  void showLivraisonDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Informations de livraison"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("Quartier"),
                    subtitle: Text("${widget.reservation.livraisonQuartier}"),
                  ),
                  ListTile(
                    title: Text("Point de repère"),
                    subtitle: Text("${widget.reservation.livraisonRepere}"),
                  ),
                  ListTile(
                    title: Text("Personne à contacter"),
                    subtitle: Text("${widget.reservation.livraisonPersonne}"),
                  ),
                  ListTile(
                    title: Text("Téléphone personne à contacter"),
                    subtitle: Text("${widget.reservation.livraisonContact}"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Fermer"))
              ],
            ));
  }

  String getTimeSummury(DateTime date, String creneau) {
    return "Le ${date.day < 10 ? '0' : ''}${date.day}/${date.month < 10 ? '0' : ''}${date.month}/${date.year} entre ${creneau.split("-")[0]} et ${creneau.split("-")[1]}";
  }

  int getTotal(List<ReservationProduit> produits) {
    int total = 0;
    for (int i = 0; i < produits.length; i++) {
      if (produits[i].isFree == false) {
        total += produits[i].quantite * produits[i].menuProduit.produit.prix;
      }
    }
    return total;
  }

  Widget getDetail({required Reservation reservation}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reservation.status == "Annule")
          ListTile(
            title: Text("${reservation.causeAnnulation}"),
            trailing: reservation.dateAnnulation == null
                ? Icon(Icons.alarm)
                : Text(
                    "${reservation.dateAnnulation!.day}/${reservation.dateAnnulation!.month}/${reservation.dateAnnulation!.year} a ${reservation.dateAnnulation!.hour}:${reservation.dateAnnulation!.minute}"),
          )
        else if (reservation.status == "Termine")
          ListTile(
            title: Text("${reservation.evaluation}"),
            trailing: Text("Evaluation"),
          ),
        Divider(),
      ],
    );
  }

  Color getColorByStatus(String status) {
    if (status == "Encours") {
      return Colors.yellow;
    }
    if (status == "Termine") {
      return Colors.green;
    }
    if (status == "Annule") {
      return Colors.red;
    }
    return Colors.blue;
  }

  Widget getInitialPage(
      {required List<ReservationProduit> produits, required Reservation reservation}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reservation.isConfirmed == false && reservation.status == 'Encours')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "En attente de confirmation",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${reservation.restaurant?.nom ?? ''}",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 32.0),
                    child: Text(
                      "${getTimeSummury(reservation.date, widget.reservation.creneau)}",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  //TODO receptionMode
                  InkWell(
                    onTap: () {
                      if (widget.reservation.receptionMode == "Livraison") {
                        showLivraisonDialog();
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: Colors.brown),
                      child: Text(
                        "${reservation.receptionMode}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    ),
                  ),
                ],
              )),
              Expanded(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: QrImageView(
                        data: "${reservation.id}",
                        size: 100.0,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: getColorByStatus(reservation.status)),
                      child: Text(
                        "${reservation.status}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
        if (reservation.isConfirmed == false)
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _cubit.confirmReservation();
                  },
                  child: Text("Confirmer"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                ),
              )),
            ],
          ),
        Divider(),
        if (reservation.type == "Commande")
          Flexible(
            flex: 2,
            child: ProduitList(
              reservation: reservation,
              produits: produits,
              updatePriceStreamController: _priceStreamController,
            ),
          ),
        if (reservation.type == "Commande")
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("Solde à payer")),
                    Expanded(
                        child: Text(
                      "${totalCost} FCFA",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                          icon: Icon(
                            Icons.refresh_outlined,
                            color: Colors.blue[700],
                          ),
                          onPressed: () {
                            _cubit.load();
                          }),
                    )
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        if (reservation.type != "Commande")
          ListTile(
            title: Text("Place${widget.reservation.placeCount > 1 ? 's' : ''}"),
            leading: CircleAvatar(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                radius: 16.0,
                child: Text(
                  "${reservation.placeCount}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          ),
        Expanded(child: getDetail(reservation: reservation)),
        if (reservation.paiement_status == "Success" && reservation.paiement_date != null)
          Container(
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0, bottom: 8.0, top: 8.0),
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    "https://singpay.ga/images/icon.png",
                    width: 24,
                  ),
                ),
                Expanded(
                  child: Text(
                      "Paiement de ${reservation.paiement_amount} XAF effectue  ${formatHeure(reservation.paiement_date!)} via ${reservation.paiement_method}, reference: ${reservation.paiement_reference}",
                      style:
                          TextStyle(color: Colors.grey[700], fontSize: 12.0)),
                ),
              ],
            ),
          )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit = ReservationDetailCubit(ReservationDetailLoading(),
        reservation: widget.reservation);
    _priceStreamController.stream.listen((event) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        totalCost = getTotal(event);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReservationDetailCubit>(
      create: (context) => _cubit..load(),
      child: BlocBuilder<ReservationDetailCubit, ReservationDetailState>(
        builder: (context, state) {
          if (state is ReservationDetailInitial) {
            totalCost = getTotal(state.reservationProduits);
            return getInitialPage(
                produits: state.reservationProduits,
                reservation: _cubit.reservation);
          }
          if (state is ReservationDetailUpdateResult) {
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            });
            return Container();
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
