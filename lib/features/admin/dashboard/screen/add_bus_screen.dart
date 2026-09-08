import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';


class AddBusScreen extends StatefulWidget {
  const AddBusScreen({super.key});

  @override
  State<AddBusScreen> createState() => _AddBusScreenState();
}

class _AddBusScreenState extends State<AddBusScreen> {
  final busNumberController = TextEditingController();
  final routeController = TextEditingController();
  final departureTimeController = TextEditingController();

  @override
  void dispose() {
    busNumberController.dispose();
    routeController.dispose();
    departureTimeController.dispose();
    super.dispose();
  }

  void addBus() {
    context.read<AdminBusBloc>().add(
      AddBusRequested(
        busNumber: busNumberController.text.trim(),
        route: routeController.text.trim(),
        departureTime: departureTimeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocConsumer<AdminBusBloc, AdminBusState>(
          listener: (context, state) {
            if (state is AdminBusSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );

              busNumberController.clear();
              routeController.clear();
              departureTimeController.clear();
            }

            if (state is AdminBusFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                TextField(
                  controller: busNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Bus Number',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: routeController,
                  decoration: const InputDecoration(
                    labelText: 'Route',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: departureTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Departure Time',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: state is AdminBusLoading ? null : addBus,
                  child: state is AdminBusLoading
                      ? const CircularProgressIndicator()
                      : const Text('Add Bus'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}