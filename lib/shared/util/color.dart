

import 'package:flutter/material.dart';

int getColor(String hex) {
  String formattedHex =  "FF" + hex.toUpperCase().replaceAll("#", "");
  return int.parse(formattedHex, radix: 16);
}

Color getColorByStatus(String status, bool isConfirmed){
  if(status == "Encours" && isConfirmed == false){
    return Colors.grey;
  } else if(status == "Encours"){
    return Colors.yellow;
  }
  if(status == "Termine"){
    return Colors.green;
  }
  if(status == "Annule"){
    return Colors.red;
  }
  return Colors.blue;
}