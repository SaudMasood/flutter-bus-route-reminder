class BusModel {
  final String id;
  final String busNumber;
  final String route;
  final String departureTime;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.route,
    required this.departureTime,
  });

  factory BusModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return BusModel(
      id: id,
      busNumber: data['busNumber'] ?? '',
      route: data['route'] ?? '',
      departureTime: data['departureTime'] ?? '',
    );
  }
}