import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../model/bus_model.dart';

class ManageBusScreen extends StatefulWidget {
  const ManageBusScreen({super.key});

  @override
  State<ManageBusScreen> createState() => _ManageBusScreenState();
}

class _ManageBusScreenState extends State<ManageBusScreen> {
  @override
  void initState() {
    super.initState();

    context.read<AdminBusBloc>().add(
      GetBusesRequested(),
    );
  }

  void updateBus(BusModel bus) {
    final busController =
    TextEditingController(text: bus.busNumber);

    final routeController =
    TextEditingController(text: bus.route);

    final timeController =
    TextEditingController(text: bus.departureTime);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Bus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: busController,
                decoration: const InputDecoration(
                  labelText: 'Bus Number',
                ),
              ),
              TextField(
                controller: routeController,
                decoration: const InputDecoration(
                  labelText: 'Route',
                ),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Departure Time',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AdminBusBloc>().add(
                  UpdateBusRequested(
                    busId: bus.id,
                    busNumber: busController.text.trim(),
                    route: routeController.text.trim(),
                    departureTime: timeController.text.trim(),
                  ),
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void deleteBus(String busId) {
    context.read<AdminBusBloc>().add(
      DeleteBusRequested(
        busID: busId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Buses'),
      ),
      body: BlocConsumer<AdminBusBloc, AdminBusState>(
        listener: (context, state) {
          if (state is AdminBusSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            context.read<AdminBusBloc>().add(
              GetBusesRequested(),
            );
          }

          if (state is AdminBusFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminBusLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AdminBusLoaded) {
            if (state.buses.isEmpty) {
              return const Center(
                child: Text('No buses found'),
              );
            }

            return ListView.builder(
              itemCount: state.buses.length,
              itemBuilder: (context, index) {
                final bus = state.buses[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.directions_bus,
                    ),
                    title: Text(bus.busNumber),
                    subtitle: Text(
                      '${bus.route}\n${bus.departureTime}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            updateBus(bus);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            deleteBus(bus.id);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is AdminBusFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          return const Center(
            child: Text('No data'),
          );
        },
      ),
    );
  }
}