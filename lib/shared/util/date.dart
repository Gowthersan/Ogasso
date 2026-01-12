
String formatHeure(DateTime dateParam) {
  final DateTime date = dateParam.toLocal();
  String dateOnly = "Ajourd'hui";
  DateTime now = DateTime.now().toLocal();
  if (date.day != now.day ||
      date.month != now.month ||
      date.year != now.year) {
    dateOnly =
    "${date.day < 10 ? '0' : ''}${date.day}/${date.month < 10 ? '0' : ''}${date.month}/${date.year}";
  }
  final String timeOnly =
      "${date.hour < 10 ? '0' : ''}${date.hour}:${date.minute < 10 ? '0' : ''}${date.minute}";
  return "$dateOnly, $timeOnly";
}