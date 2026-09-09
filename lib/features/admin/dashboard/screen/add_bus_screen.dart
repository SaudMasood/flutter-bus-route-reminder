import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
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
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Add Bus Route'),
      ),
      body: BlocConsumer<AdminBusBloc, AdminBusState>(
        listener: (context, state) {
          if (state is AdminBusSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );

            busNumberController.clear();
            routeController.clear();
            departureTimeController.clear();
          }

          if (state is AdminBusFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AdminBusLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_bus_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Add New Bus',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      controller: busNumberController,
                      decoration: InputDecoration(
                        labelText: 'Bus Number',
                        prefixIcon: const Icon(
                          Icons.confirmation_number_outlined,
                        ),
                        filled: true,
                        fillColor: AppColors.cream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: routeController,
                      decoration: InputDecoration(
                        labelText: 'Route',
                        prefixIcon: const Icon(
                          Icons.route_outlined,
                        ),
                        filled: true,
                        fillColor: AppColors.cream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: departureTimeController,
                      decoration: InputDecoration(
                        labelText: 'Departure Time',
                        prefixIcon: const Icon(
                          Icons.access_time_rounded,
                        ),
                        filled: true,
                        fillColor: AppColors.cream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : addBus,
                        icon: const Icon(Icons.add),
                        label: loading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.cream,
                          ),
                        )
                            : const Text(
                          'Add Bus',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.cream,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}