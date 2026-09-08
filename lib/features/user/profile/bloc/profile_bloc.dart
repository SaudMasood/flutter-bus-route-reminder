import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/app_constants.dart';
import '../model/model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ProfileBloc() : super(ProfileInitial()) {
    on<GetProfileRequested>(_getProfile);
    on<ProfileLogoutRequested>(_logout);
  }

  Future<void> _getProfile(
      GetProfileRequested event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    try {
      final user = auth.currentUser;

      if (user == null) {
        emit(
          const ProfileFailure(
            'User is not logged in',
          ),
        );
        return;
      }

      final document = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!document.exists) {
        emit(
          const ProfileFailure(
            'Profile not found',
          ),
        );
        return;
      }

      final profile = ProfileModel.fromFirestore(
        document.id,
        document.data()!,
      );

      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(
        const ProfileFailure(
          'Failed to load profile',
        ),
      );
    }
  }

  Future<void> _logout(
      ProfileLogoutRequested event,
      Emitter<ProfileState> emit,
      ) async {
    try {
      await auth.signOut();

      emit(ProfileLogoutSuccess());
    } catch (e) {
      emit(
        const ProfileFailure(
          'Logout failed',
        ),
      );
    }
  }
}