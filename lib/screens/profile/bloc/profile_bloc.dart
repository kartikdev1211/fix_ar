import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await Future.delayed(const Duration(seconds: 2)); // simulate API

    final fakeData = {
      "name": "Kartik Kumar",
      "email": "kartik@fixar.app",
      "repairs": 24,
      "saved": 12,
      "time": "38h",
    };

    emit(state.copyWith(isLoading: false, data: fakeData));
  }
}
