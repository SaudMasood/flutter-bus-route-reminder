import 'package:equatable/equatable.dart';

import '../../../admin/dashboard/model/bus_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BusModel> buses;
  final String? selectedBusId;
  final DateTime? selectedReminderTime;

  const HomeLoaded({
    required this.buses,
    this.selectedBusId,
    this.selectedReminderTime,
  });

  HomeLoaded copyWith({
    List<BusModel>? buses,
    String? selectedBusId,
    DateTime? selectedReminderTime,
  }) {
    return HomeLoaded(
      buses: buses ?? this.buses,
      selectedBusId: selectedBusId ?? this.selectedBusId,
      selectedReminderTime:
      selectedReminderTime ?? this.selectedReminderTime,
    );
  }

  @override
  List<Object?> get props => [
    buses,
    selectedBusId,
    selectedReminderTime,
  ];
}

class ReminderSuccess extends HomeState {
  final String message;

  const ReminderSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}