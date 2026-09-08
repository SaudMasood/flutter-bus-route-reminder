import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/services/notification services/notification_service.dart';

import '../model/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class UserAuthBloc extends Bloc<UserAuthEvent, UserAuthState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  UserAuthBloc() : super(UserAuthInitial()) {
    on<UserSignupRequested>(_signup);
    on<UserLoginRequested>(_login);
    on<UserLogoutRequested>(_logout);
  }

  // ==================== SIGNUP ====================

  Future<void> _signup(
      UserSignupRequested event,
      Emitter<UserAuthState> emit,
      ) async {
    if (event.name.trim().isEmpty ||
        event.email.trim().isEmpty ||
        event.password.isEmpty) {
      emit(
        const UserAuthFailure(
          'Please fill all fields',
        ),
      );
      return;
    }

    if (event.password.length < 6) {
      emit(
        const UserAuthFailure(
          'Password must be at least 6 characters',
        ),
      );
      return;
    }

    emit(UserAuthLoading());

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      final user = credential.user!;

      final userModel = UserModel(
        id: user.uid,
        name: event.name.trim(),
        email: event.email.trim(),
        role: AppConstants.userRole,
      );

      // Save user in Firestore
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(
        userModel.toFirestore(),
      );

      // Save FCM token
      await NotificationService.saveUserToken();

      emit(UserAuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(
        UserAuthFailure(
          e.message ?? 'Signup failed',
        ),
      );
    } catch (e) {
      emit(
        const UserAuthFailure(
          'Something went wrong',
        ),
      );
    }
  }

  // ==================== LOGIN ====================

  Future<void> _login(
      UserLoginRequested event,
      Emitter<UserAuthState> emit,
      ) async {
    if (event.email.trim().isEmpty ||
        event.password.isEmpty) {
      emit(
        const UserAuthFailure(
          'Please enter email and password',
        ),
      );
      return;
    }

    emit(UserAuthLoading());

    try {
      // Firebase Login
      final credential = await auth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      final user = credential.user!;

      // Get user from Firestore
      final document = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!document.exists) {
        await auth.signOut();

        emit(
          const UserAuthFailure(
            'User profile not found',
          ),
        );

        return;
      }

      final userModel = UserModel.fromFirestore(
        user.uid,
        document.data()!,
      );

      // Check user role
      if (userModel.role != AppConstants.userRole) {
        await auth.signOut();

        emit(
          const UserAuthFailure(
            'This account is not a user account',
          ),
        );

        return;
      }

      // Save FCM token
      await NotificationService.saveUserToken();

      emit(UserAuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(
        UserAuthFailure(
          e.message ?? 'Login failed',
        ),
      );
    } catch (e) {
      emit(
        const UserAuthFailure(
          'Something went wrong',
        ),
      );
    }
  }



  Future<void> _logout(
      UserLogoutRequested event,
      Emitter<UserAuthState> emit,
      ) async {
    try {
      await auth.signOut();

      emit(UserAuthLogoutSuccess());
    } catch (e) {
      emit(
        const UserAuthFailure(
          'Logout failed',
        ),
      );
    }
  }
}