abstract class AdminBusEvent{

}

class GetBusesRequested extends AdminBusEvent{

}

class AddBusRequested extends AdminBusEvent {
  final String busNumber;
  final String route;
  final String departureTime;

  AddBusRequested({
    required this.busNumber,
    required this.route,
    required this.departureTime,
  });
}

class UpdateBusRequested extends AdminBusEvent {
  final String busId;
  final String busNumber;
  final String route;
  final String departureTime;

  UpdateBusRequested({
    required this.busId,
    required this.busNumber,
    required this.route,
    required this.departureTime,
  });
}



class DeleteBusRequested extends AdminBusEvent{
  final String busID;
  DeleteBusRequested({
    required this.busID,
  });
}
