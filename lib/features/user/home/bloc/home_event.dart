abstract class HomeEvent {}

class GetBusesRequested extends HomeEvent {}

class BusSelected extends HomeEvent {
  final String busId;

  BusSelected({
    required this.busId,
  });
}

class ReminderTimeSelected extends HomeEvent {
  final DateTime reminderTime;

  ReminderTimeSelected({
    required this.reminderTime,
  });
}

class SetReminderRequested extends HomeEvent {}