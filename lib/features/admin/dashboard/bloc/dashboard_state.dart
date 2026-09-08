import 'package:equatable/equatable.dart';

import '../model/bus_model.dart';


abstract class AdminBusState extends Equatable {
  const AdminBusState();

  @override
  List<Object?> get props => [];
}

class AdminBusInitial extends AdminBusState {}

class AdminBusLoading extends AdminBusState {}

class AdminBusLoaded extends AdminBusState {
  final List<BusModel> buses;

  const AdminBusLoaded(this.buses);

  @override
  List<Object?> get props => [buses];
}

class AdminBusSuccess extends AdminBusState {
  final String message;

  const AdminBusSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminBusFailure extends AdminBusState {
  final String message;

  const AdminBusFailure(this.message);

  @override
  List<Object?> get props => [message];
}