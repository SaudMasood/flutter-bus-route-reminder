abstract class UserAuthEvent {}

class UserLoginRequested extends UserAuthEvent {
  final String email;
  final String password;

  UserLoginRequested({
    required this.email,
    required this.password,
  });
}

class UserSignupRequested extends UserAuthEvent {
  final String name;
  final String email;
  final String password;

  UserSignupRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

class UserLogoutRequested extends UserAuthEvent {}