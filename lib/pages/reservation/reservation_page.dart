import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogasso_employe/pages/reservation/reservation_calendar_detail/reservation_calendar_detail_page.dart';
import 'package:ogasso_employe/pages/reservation/reservation_cubit.dart';
import 'package:ogasso_employe/services/entities/reservation.dart';
import 'package:ogasso_employe/shared/util/date.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final ReservationCubit _reservationCubit = ReservationCubit(
    ReservationLoading(),
  );

  Widget getCalendar({
    required List<Reservation> reservationType,
    required List<Reservation> commandeType,
  }) {
    final List<Reservation> selectedDayReservation = [];
    final List<Reservation> selectedDayCommande = [];
    for (int i = 0; i < reservationType.length; i++) {
      if (DateUtils.isSameDay(reservationType[i].date, _selectedDay)) {
        selectedDayReservation.add(reservationType[i]);
      }
    }
    for (int i = 0; i < commandeType.length; i++) {
      if (DateUtils.isSameDay(commandeType[i].date, _selectedDay)) {
        selectedDayCommande.add(commandeType[i]);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableCalendar(
          firstDay: DateUtils.addDaysToDate(DateTime.now(), -2),
          lastDay: DateUtils.addDaysToDate(DateTime.now(), 366),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: (day) {
            final List<String> array = [];
            try {
              final Reservation reservation = reservationType.firstWhere(
                (element) => DateUtils.isSameDay(day, element.date),
              );
              array.add(reservation.type);
            } catch (e) {
              // No reservation found
            }
            try {
              final Reservation commande = commandeType.firstWhere(
                (element) => DateUtils.isSameDay(day, element.date),
              );
              array.add(commande.type);
            } catch (e) {
              // No commande found
            }
            return array;
          },
          selectedDayPredicate: (day) {
            // Use `selectedDayPredicate` to determine which day is currently selected.
            // If this returns true, then `day` will be marked as selected.

            // Using `isSameDay` is recommended to disregard
            // the time-part of compared DateTime objects.
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              // Call `setState()` when updating the selected day
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              // Call `setState()` when updating calendar format
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            // No need to call `setState()` here
            _focusedDay = focusedDay;
          },
        ),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  "${formatHeure(_selectedDay).split(",")[0]}",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  title: Text("Reservation"),
                  trailing: Text("${selectedDayReservation.length}"),
                ),
              ),
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  title: Text("Commande"),
                  trailing: Text("${selectedDayCommande.length}"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationCalendarDetailPage(
                          commandeType: selectedDayCommande,
                          reservationType: selectedDayReservation,
                          date: _selectedDay,
                        ),
                      ),
                    );
                  },
                  child: Text("Voir le detail"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservations"),
        actions: [
          IconButton(
            onPressed: () {
              _reservationCubit..load();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocProvider<ReservationCubit>(
        create: (context) => _reservationCubit..load(),
        child: BlocBuilder<ReservationCubit, ReservationState>(
          builder: (context, state) {
            if (state is ReservationInitial) {
              return getCalendar(
                reservationType: state.getReservations(),
                commandeType: state.getCommandes(),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
