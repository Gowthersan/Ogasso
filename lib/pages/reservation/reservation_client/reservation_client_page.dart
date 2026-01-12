import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/reservation/reservation_client/reservation_client_cubit.dart';
import 'package:ogasso_employe/services/entities/account.dart';
import 'package:ogasso_employe/services/entities/client.dart';
import 'package:ogasso_employe/services/entities/produit.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/services/repository/api_service.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';
import 'package:ogasso_employe/shared/circle_image_widget.dart';
import 'package:ogasso_employe/shared/util/color.dart';
import 'package:ogasso_employe/shared/util/variable.dart';

class ReservationClientPage extends StatefulWidget {
  final Reservation reservation;

  const ReservationClientPage({Key? key, required this.reservation}) : super(key: key);

  @override
  _ReservationClientPageState createState() => _ReservationClientPageState();
}

class _ReservationClientPageState extends State<ReservationClientPage> {
  String getFormattedDate(DateTime date) {
    return "${date.day < 10 ? '0' : ''}${date.day}/${date.month < 10 ? '0' : ''}${date.month}/${date.year}";
  }

  Widget _profilForm(BuildContext context,
      {required Client client, Produit? produit, Reservation? reservation}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Center(
              child: CircleAvatar(
                radius: 32,
                foregroundColor: Colors.white,
                child: Text(
                  "${AuthService.getUserInitial(client)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                ),
                backgroundColor: Color(getColor(
                    UserAccount.AVATAR_COLOR[client.account?.initial_color ?? 0])),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${client.prenom} ${client.nom}",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 32.0),
              child: Text(
                  "Utilisateur de l'application Ogasso depuis ${client.account?.create_at != null ? getFormattedDate(client.account!.create_at!) : 'N/A'}, il habite a ${client.adresse} dans la ville de ${client.ville}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child: Text(
              "${client.account?.username ?? ''}",
              style: TextStyle(fontSize: 16.0, color: Colors.blue[900]),
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Center(
                child: Text(
              "${client.telephone}",
              style: TextStyle(fontSize: 14.0, color: Colors.grey[900]),
            )),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Plats favoris",
              style: TextStyle(color: Colors.grey, fontSize: 16.0),
            ),
          ),
          if (produit == null)
            Center(
              child: Text("Aucun"),
            )
          else
            Column(
              children: [
                CircleImageWidget(
                  width: 100,
                  heigth: 100,
                  url: produit.photoURL == null
                      ? default_logo_url
                      : "http://${APIService.URL}/upload${produit.photoURL!.split("/upload")[1]}",
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${produit.nom}",
                    style: TextStyle(fontSize: 16.0),
                  ),
                )
              ],
            ),
          Container(
            margin: EdgeInsets.all(16.0),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Commandes / Reservations",
              style: TextStyle(color: Colors.grey, fontSize: 16.0),
            ),
          ),
          if (reservation != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "La dernieres reservation en date a eu le lieu le ${getFormattedDate(reservation.date.toUtc())} via le code ${reservation.numero}",
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.black),
              ),
            ),
          Container(
            margin: EdgeInsets.all(16.0),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Connexion",
              style: TextStyle(color: Colors.grey, fontSize: 16.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Derniere connexion"),
                Text("${client.account?.lastConnexion != null ? getFormattedDate(client.account!.lastConnexion!) : 'N/A'}"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Derniere activite"),
                Text("${client.account?.lastActivity != null ? getFormattedDate(client.account!.lastActivity!) : 'N/A'}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReservationClientCubit>(
      create: (context) => ReservationClientCubit(ReservationClientLoading())
        ..load(widget.reservation.client),
      child: BlocBuilder<ReservationClientCubit, ReservationClientState>(
        builder: (context, state) {
          if (state is ReservationClientInitial) {
            if (state.client.account == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Il y'a eu un probleme de connexion, veuillez reessayer, Merci !",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return _profilForm(context,
                client: state.client,
                produit: state.produit,
                reservation: state.lastReservation);
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
