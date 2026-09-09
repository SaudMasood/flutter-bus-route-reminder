import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    context.read<HomeBloc>().add(
      GetBusesRequested(),
    );
  }

  Future<void> selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) {
      return;
    }

    final now = DateTime.now();

    DateTime reminderDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (reminderDateTime.isBefore(now)) {
      reminderDateTime = reminderDateTime.add(
        const Duration(days: 1),
      );
    }

    context.read<HomeBloc>().add(
      ReminderTimeSelected(
        reminderTime: reminderDateTime,
      ),
    );
  }

  String formatTime(DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Bus Route'),
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is ReminderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }

          if (state is HomeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is HomeFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is HomeLoaded) {
            if (state.buses.isEmpty) {
              return const Center(
                child: Text(
                  'No bus routes available',
                  style: TextStyle(
                    color: AppColors.grey,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Your Bus 🚌',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Choose a route for your journey.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Available Routes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bus List
                  ...state.buses.map(
                        (bus) {
                      final selected =
                          state.selectedBusId == bus.id;

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: RadioListTile<String>(
                          value: bus.id,
                          groupValue: state.selectedBusId,
                          onChanged: (value) {
                            if (value == null) return;

                            context.read<HomeBloc>().add(
                              BusSelected(
                                busId: value,
                              ),
                            );
                          },
                          activeColor: AppColors.primary,
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          secondary: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: AppColors.cream,
                            ),
                          ),
                          title: Text(
                            'Bus ${bus.busNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: Text(
                            '${bus.route}\n'
                                'Departure: ${bus.departureTime}',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  // Reminder
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.notifications_active_rounded,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Bus Reminder',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Set a reminder for your selected bus.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Time Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: selectTime,
                              icon: const Icon(
                                Icons.access_time_rounded,
                              ),
                              label: Text(
                                state.selectedReminderTime == null
                                    ? 'Select Time'
                                    : formatTime(
                                  state.selectedReminderTime!,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Set Reminder
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<HomeBloc>().add(
                                  SetReminderRequested(),
                                );
                              },
                              icon: const Icon(
                                Icons.notifications_active_rounded,
                              ),
                              label: const Text(
                                'Set Reminder',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                AppColors.primary,
                                foregroundColor:
                                AppColors.cream,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Loading buses...'),
          );
        },
      ),
    );
  }
}