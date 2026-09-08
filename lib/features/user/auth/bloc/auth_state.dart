import 'package:equatable/equatable.dart';

abstract class UserAuthState extends Equatable {
  const UserAuthState();

  @override
  List<Object?> get props => [];
}

class UserAuthInitial extends UserAuthState {}

class UserAuthLoading extends UserAuthState {}

class UserAuthSuccess extends UserAuthState {}

class UserAuthFailure extends UserAuthState {
  final String message;

  const UserAuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class UserAuthLogoutSuccess extends UserAuthState {}