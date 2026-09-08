import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_constants.dart';
import '../model/bus_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class AdminBusBloc extends Bloc<AdminBusEvent, AdminBusState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AdminBusBloc() : super(AdminBusInitial()) {
    on<GetBusesRequested>(_getBuses);
    on<AddBusRequested>(_addBus);
    on<UpdateBusRequested>(_updateBus);
    on<DeleteBusRequested>(_deleteBus);
  }

  Future<void> _getBuses(
      GetBusesRequested event,
      Emitter<AdminBusState> emit,
      ) async {
    emit(AdminBusLoading());

    try {
      final snapshot = await firestore
          .collection(AppConstants.busesCollection)
          .get();

      final buses = snapshot.docs.map((doc) {
        return BusModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();

      emit(AdminBusLoaded(buses));
    } catch (e) {
      emit(AdminBusFailure('Failed to load buses'));
    }
  }

  Future<void> _addBus(
      AddBusRequested event,
      Emitter<AdminBusState> emit,
      ) async {
    emit(AdminBusLoading());

    try {
      if (event.busNumber.isEmpty ||
          event.route.isEmpty ||
          event.departureTime.isEmpty) {
        emit(const AdminBusFailure('Please fill all fields'));
        return;
      }

      await firestore
          .collection(AppConstants.busesCollection)
          .add({
        'busNumber': event.busNumber,
        'route': event.route,
        'departureTime': event.departureTime,
      });

      emit(const AdminBusSuccess('Bus added successfully'));
    } catch (e) {
      emit(AdminBusFailure('Failed to add bus'));
    }
  }

  Future<void> _updateBus(
      UpdateBusRequested event,
      Emitter<AdminBusState> emit,
      ) async {
    emit(AdminBusLoading());

    try {
      await firestore
          .collection(AppConstants.busesCollection)
          .doc(event.busId)
          .update({
        'busNumber': event.busNumber,
        'route': event.route,
        'departureTime': event.departureTime,
      });

      emit(const AdminBusSuccess('Bus updated successfully'));
    } catch (e) {
      emit(AdminBusFailure('Failed to update bus'));
    }
  }

  Future<void> _deleteBus(
      DeleteBusRequested event,
      Emitter<AdminBusState> emit,
      ) async {
    emit(AdminBusLoading());

    try {
      await firestore
          .collection(AppConstants.busesCollection)
          .doc(event.busID)
          .delete();

      emit(const AdminBusSuccess('Bus deleted successfully'));
    } catch (e) {
      emit(AdminBusFailure('Failed to delete bus'));
    }
  }
}