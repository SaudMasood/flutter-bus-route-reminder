import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../admin/dashboard/model/bus_model.dart';

import '../model/model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  HomeBloc() : super(HomeInitial()) {
    on<GetBusesRequested>(_getBuses);
    on<BusSelected>(_selectBus);
    on<ReminderTimeSelected>(_selectReminderTime);
    on<SetReminderRequested>(_setReminder);
  }

  // Get buses
  Future<void> _getBuses(
      GetBusesRequested event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());

    try {
      final snapshot = await firestore
          .collection('buses')
          .get();

      final buses = snapshot.docs.map((doc) {
        return BusModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();

      emit(
        HomeLoaded(
          buses: buses,
        ),
      );
    } catch (e) {
      emit(
        const HomeFailure(
          'Failed to load bus routes',
        ),
      );
    }
  }

  // Select bus
  void _selectBus(
      BusSelected event,
      Emitter<HomeState> emit,
      ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      emit(
        currentState.copyWith(
          selectedBusId: event.busId,
        ),
      );
    }
  }

  // Select reminder time
  void _selectReminderTime(
      ReminderTimeSelected event,
      Emitter<HomeState> emit,
      ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      emit(
        currentState.copyWith(
          selectedReminderTime: event.reminderTime,
        ),
      );
    }
  }

  // Save reminder
  Future<void> _setReminder(
      SetReminderRequested event,
      Emitter<HomeState> emit,
      ) async {
    if (state is! HomeLoaded) {
      return;
    }

    final currentState = state as HomeLoaded;

    // Check bus
    if (currentState.selectedBusId == null) {
      emit(
        const HomeFailure(
          'Please select a bus',
        ),
      );
      return;
    }

    // Check reminder time
    if (currentState.selectedReminderTime == null) {
      emit(
        const HomeFailure(
          'Please select reminder time',
        ),
      );
      return;
    }

    // Check login
    final user = auth.currentUser;

    if (user == null) {
      emit(
        const HomeFailure(
          'Please login first',
        ),
      );
      return;
    }

    try {
      final reminder = ReminderModel(
        id: '',
        userId: user.uid,
        busId: currentState.selectedBusId!,
        reminderTime: currentState.selectedReminderTime!,
      );

      await firestore
          .collection('reminders')
          .add(
        reminder.toFirestore(),
      );

      emit(
        const ReminderSuccess(
          'Reminder set successfully',
        ),
      );

      // Clear selected values
      emit(
        HomeLoaded(
          buses: currentState.buses,
        ),
      );
    } catch (e) {
      emit(
        const HomeFailure(
          'Failed to set reminder',
        ),
      );
    }
  }
}