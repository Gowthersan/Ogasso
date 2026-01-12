import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/services/entities/produit.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/api_service.dart';
import 'package:ogasso_employe/shared/circle_image_widget.dart';
import 'package:ogasso_employe/shared/produits_list/add_produit.dart';
import 'package:ogasso_employe/shared/produits_list/produits_list_cubit.dart';
import 'package:ogasso_employe/shared/util/variable.dart';

class ProduitList extends StatefulWidget {
  final List<ReservationProduit> produits;
  final Reservation reservation;
  final StreamController<List<ReservationProduit>> updatePriceStreamController;

  const ProduitList(
      {Key? key,
      required this.produits,
      required this.reservation,
      required this.updatePriceStreamController})
      : super(key: key);

  @override
  _ProduitListState createState() => _ProduitListState();
}

class _ProduitListState extends State<ProduitList> {
  ProduitListCubit _cubit = ProduitListCubit(ProduitListLoading());
  List<Produit> produits = [];
  final StreamController addStreamController = StreamController();

  showDeleteProduitConfirmDialog(
      ReservationProduit reservationProduit, List<ReservationProduit> list) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                  "Suppression ${reservationProduit.menuProduit.produit.nom}"),
              content: Text(
                  "Voulez vous vraiment  ${reservationProduit.menuProduit.produit.nom} du panier ?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _cubit.removeProduit(
                          reservationProduit: reservationProduit,
                          reservationProduits: list);
                    },
                    child: Text("Oui")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Non"))
              ],
            ));
  }

  showAddProduitDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Ajouter un produit"),
              content: AddProduitView(
                produits: produits,
                addStreamController: addStreamController,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Annuler"))
              ],
            ));
  }

  Widget _initialView(List<ReservationProduit> produits) {
    return ListView.builder(
        itemCount: produits.length + 1,
        itemBuilder: (context, index) {
          if (index == produits.length) {
            return Container();
          }
          final Produit produit = produits[index].menuProduit.produit;
          final int MAX_LETTER = 50;
          final int max = produit.description.length >= MAX_LETTER
              ? MAX_LETTER
              : produit.description.length;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleImageWidget(
                url: produit.photoURL == null
                    ? default_logo_url
                    : "http://${APIService.URL}/upload${produit.photoURL!.split("/upload")[1]}",
                width: 48,
                heigth: 48,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${produit.nom}",
                  ),
                  Text(
                    "${produits[index].quantite} x ${produit.prix} XAF",
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${produit.description.substring(0, max)} ${max == 50 ? '...' : ''}",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    addStreamController.stream.listen((event) {
      Navigator.pop(context);
      _cubit.createReservationProduit(
          client: widget.reservation.client,
          quantite: event['quantite'],
          isFree: event['isFree'],
          produit: event['produit'],
          reservation: widget.reservation,
          reservationProduits: widget.produits);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProduitListCubit>(
      create: (context) => _cubit
        ..load(widget.reservation, initialReservationProduits: widget.produits),
      child: BlocBuilder<ProduitListCubit, ProduitListState>(
        builder: (context, state) {
          if (state is ProduitListInitialState) {
            widget.updatePriceStreamController.add(state.reservationProduits);
            produits = state.produits;
            return _initialView(state.reservationProduits);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
