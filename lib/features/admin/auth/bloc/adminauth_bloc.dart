
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'adminauth_event.dart';
import 'adminauth_state.dart';

class AdminAuthBloc extends Bloc<AdminAuthEvent, AdminAuthState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AdminAuthBloc() : super(AdminAuthInitial()) {
    on<AdminLoginRequested>(_login);
    on<AdminSignupRequested>(_signup);
    on<AdminLogoutRequested>(_logout);
  }

  Future<void> _signup(
      AdminSignupRequested event,
      Emitter<AdminAuthState> emit,
      ) async {
    emit(AdminAuthLoading());

    try {
      if (event.name.isEmpty ||
          event.email.isEmpty ||
          event.password.isEmpty) {
        emit(const AdminAuthFailure('Please fill all fields'));
        return;
      }

      // Create Firebase account
      UserCredential result =
      await auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Save admin information in Firestore
      await firestore.collection('users').doc(result.user!.uid).set({
        'name': event.name,
        'email': event.email,
        'role': 'admin',
      });

      emit(AdminAuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AdminAuthFailure(e.message ?? 'Signup failed'));
    }
  }

  Future<void> _login(
      AdminLoginRequested event,
      Emitter<AdminAuthState> emit,
      ) async {
    emit(AdminAuthLoading());

    try {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AdminAuthFailure('Enter email and password'));
        return;
      }

      UserCredential result =
      await auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Get admin data from Firestore
      DocumentSnapshot user =
      await firestore.collection('users').doc(result.user!.uid).get();

      if (user['role'] == 'admin') {
        emit(AdminAuthSuccess());
      } else {
        await auth.signOut();
        emit(const AdminAuthFailure('You are not an admin'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AdminAuthFailure(e.message ?? 'Login failed'));
    }
  }

  Future<void> _logout(
      AdminLogoutRequested event,
      Emitter<AdminAuthState> emit,
      ) async {
    await auth.signOut();

    emit(AdminAuthLogoutSuccess());
  }
}