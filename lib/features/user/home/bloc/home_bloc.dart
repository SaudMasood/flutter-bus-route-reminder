import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification services/notification_service.dart';
import '../../../admin/dashboard/model/bus_model.dart';

import '../model/model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  HomeBloc() : super(HomeInitial()) {
    on<GetBusesRequested>(_getBuses);
    on<BusSelected>(_selectBus);
    on<ReminderTimeSelected>(_selectReminderTime);
    on<SetReminderRequested>(_setReminder);
  }

  // =========================
  // GET BUSES
  // =========================

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
      print('Get buses error: $e');

      emit(
        const HomeFailure(
          'Failed to load bus routes',
        ),
      );
    }
  }

  // =========================
  // SELECT BUS
  // =========================

  void _selectBus(
      BusSelected event,
      Emitter<HomeState> emit,
      ) {
    if (state is HomeLoaded) {
      final currentState =
      state as HomeLoaded;

      emit(
        currentState.copyWith(
          selectedBusId: event.busId,
        ),
      );
    }
  }

  // =========================
  // SELECT TIME
  // =========================

  void _selectReminderTime(
      ReminderTimeSelected event,
      Emitter<HomeState> emit,
      ) {
    if (state is HomeLoaded) {
      final currentState =
      state as HomeLoaded;

      emit(
        currentState.copyWith(
          selectedReminderTime:
          event.reminderTime,
        ),
      );
    }
  }

  // =========================
  // SET REMINDER
  // =========================

  Future<void> _setReminder(
      SetReminderRequested event,
      Emitter<HomeState> emit,
      ) async {
    if (state is! HomeLoaded) {
      return;
    }

    final currentState =
    state as HomeLoaded;

    // Bus check
    if (currentState.selectedBusId == null) {
      emit(
        const HomeFailure(
          'Please select a bus',
        ),
      );
      return;
    }

    // Time check
    if (currentState.selectedReminderTime == null) {
      emit(
        const HomeFailure(
          'Please select reminder time',
        ),
      );
      return;
    }

    // Login check
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
      // Find selected bus
      final selectedBus =
      currentState.buses.firstWhere(
            (bus) =>
        bus.id ==
            currentState.selectedBusId,
      );

      // Notification ID
      final notificationId =
      DateTime.now()
          .millisecondsSinceEpoch
          .remainder(2147483647);

      // Schedule local notification
      await NotificationService.scheduleReminder(
        id: notificationId,
        reminderTime:
        currentState.selectedReminderTime!,
        busNumber: selectedBus.busNumber,
        route: selectedBus.route,
      );

      // Save reminder to Firestore
      final reminder = ReminderModel(
        id: '',
        userId: user.uid,
        busId: currentState.selectedBusId!,
        reminderTime:
        currentState.selectedReminderTime!,
      );

      await firestore
          .collection('reminders')
          .add(
        reminder.toFirestore(),
      );

      print('REMINDER SAVED TO FIRESTORE');

      emit(
        const ReminderSuccess(
          'Reminder set successfully',
        ),
      );

      // Keep buses after success
      emit(
        HomeLoaded(
          buses: currentState.buses,
        ),
      );
    } catch (e, stackTrace) {
      print('==============================');
      print('REMINDER ERROR: $e');
      print('STACK TRACE: $stackTrace');
      print('==============================');

      emit(
        HomeFailure(
          'Reminder failed: $e',
        ),
      );
    }
  }
}