import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ogasso_employe/services/entities/produit.dart';

class AddProduitView extends StatefulWidget {
  final StreamController addStreamController;
  final List<Produit> produits;

  const AddProduitView({Key? key, required this.addStreamController, required this.produits})
      : super(key: key);

  @override
  _AddProduitViewState createState() => _AddProduitViewState();
}

class _AddProduitViewState extends State<AddProduitView> {
  TextEditingController searchProduitController = TextEditingController();
  TextEditingController _quantiteController = TextEditingController();
  Produit? _selectedProduit;
  bool _isFree = false;

  @override
  Widget build(BuildContext context) {
    print(widget.produits.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("Choisissez le produit"),
        ),
        Autocomplete<Produit>(
          fieldViewBuilder: (context, textEditingController, focus, function) {
            searchProduitController = textEditingController;
            return TextField(
              onEditingComplete: function,
              focusNode: focus,
              controller: textEditingController,
              decoration: InputDecoration(labelText: "Rechercher un produit"),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<Produit>.empty();
            }
            return widget.produits.where((Produit option) {
              return option.nom
                      .toString()
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()) ||
                  option.description
                      .toString()
                      .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (Produit p) {
            _selectedProduit = p;
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Text("Quel quantite ?"),
        ),
        TextField(
          controller: _quantiteController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Quantite"),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Text("Est ce gratuit ?"),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                  title: Text("Oui"),
                  value: true,
                  groupValue: _isFree,
                  onChanged: (value) {
                    setState(() {
                      _isFree = value ?? false;
                    });
                  }),
            ),
            Expanded(
              child: RadioListTile<bool>(
                  title: Text("Non"),
                  value: false,
                  groupValue: _isFree,
                  onChanged: (value) {
                    setState(() {
                      _isFree = value ?? false;
                    });
                  }),
            ),
          ],
        ),
        Flexible(
          child: ElevatedButton(
              onPressed: () {
                widget.addStreamController.add({
                  "produit": _selectedProduit,
                  "quantite": int.parse(_quantiteController.text),
                  "isFree": _isFree
                });
              },
              child: Text("Ajouter")),
        )
      ],
    );
  }
}
