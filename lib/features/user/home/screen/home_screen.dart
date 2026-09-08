import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    final reminderDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    context.read<HomeBloc>().add(
      ReminderTimeSelected(
        reminderTime: reminderDateTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Routes'),
        centerTitle: true,
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
              child: CircularProgressIndicator(),
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
                child: Text('No bus routes available'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Available Bus Routes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ...state.buses.map(
                      (bus) {
                    return Card(
                      child: RadioListTile<String>(
                        value: bus.id,
                        groupValue: state.selectedBusId,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          context.read<HomeBloc>().add(
                            BusSelected(
                              busId: value,
                            ),
                          );
                        },
                        secondary: const Icon(
                          Icons.directions_bus,
                        ),
                        title: Text(
                          'Bus ${bus.busNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
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

                const SizedBox(height: 25),

                const Text(
                  'Set Reminder',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                OutlinedButton.icon(
                  onPressed: selectTime,
                  icon: const Icon(
                    Icons.access_time,
                  ),
                  label: Text(
                    state.selectedReminderTime == null
                        ? 'Select Reminder Time'
                        : 'Reminder: ${TimeOfDay.fromDateTime(
                      state.selectedReminderTime!,
                    ).format(context)}',
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(
                        SetReminderRequested(),
                      );
                    },
                    child: const Text(
                      'Set Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
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