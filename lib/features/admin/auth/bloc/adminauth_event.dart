abstract class AdminAuthEvent {}

class AdminLoginRequested extends AdminAuthEvent {
  final String email;
  final String password;

  AdminLoginRequested({
    required this.email,
    required this.password,
  });
}

class AdminSignupRequested extends AdminAuthEvent {
  final String name;
  final String email;
  final String password;

  AdminSignupRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

class AdminLogoutRequested extends AdminAuthEvent {}