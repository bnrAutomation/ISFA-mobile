import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/device_registration_module/device_registration_repository.dart';

part 'device_registration_event.dart';
part 'device_registration_state.dart';

class DeviceRegistrationBloc
    extends Bloc<DeviceRegistrationEvent, DeviceRegistrationState> {
  final DeviceRegistrationRepository repo;

  DeviceRegistrationBloc(this.repo) : super(DeviceRegistrationInitial()) {
    on<DeviceRegistrationSubmitEvent>((event, emit) async {
      if (event.username.trim().isEmpty) {
        emit(DeviceRegistrationError('Username is required'));
        return;
      }
      if (event.password.trim().isEmpty) {
        emit(DeviceRegistrationError('Password is required for verification'));
        return;
      }
      if (event.reason.trim().length < 10) {
        emit(DeviceRegistrationError(
            'Please provide a reason (at least 10 characters)'));
        return;
      }
      try {
        emit(DeviceRegistrationLoading());
        final result = await repo.submitRegistrationRequest(
          username: event.username,
          password: event.password,
          reason: event.reason,
        );
        emit(DeviceRegistrationSuccess(
          requestId: result.requestId,
          message: result.message.isNotEmpty
              ? result.message
              : 'Your device registration request has been submitted. '
                  'An administrator will review it. You will be notified once approved.',
        ));
      } catch (err) {
        if (err is ClientException || err is SocketException) {
          emit(DeviceRegistrationError(
              'Network issue. Please check your connection and try again.'));
        } else {
          emit(DeviceRegistrationError(err.toString()));
        }
      }
    });

    on<DeviceRegistrationCheckStatusEvent>((event, emit) async {
      if (event.username.trim().isEmpty) {
        emit(DeviceRegistrationError('Username is required'));
        return;
      }
      try {
        emit(DeviceRegistrationLoading());
        final result =
            await repo.fetchRequestStatus(username: event.username);
        emit(DeviceRegistrationStatusLoaded(
          status: result.status,
          message: result.message,
        ));
      } catch (err) {
        if (err is ClientException || err is SocketException) {
          emit(DeviceRegistrationError(
              'Network issue. Please check your connection and try again.'));
        } else {
          emit(DeviceRegistrationError(err.toString()));
        }
      }
    });
  }
}
