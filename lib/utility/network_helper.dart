import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Network State

abstract class NetworkState {}

class NetworkInitial extends NetworkState {}

class NetworkSuccess extends NetworkState {}

class NetworkFailure extends NetworkState {}

// Network events

abstract class NetworkEvent {}

class NetworkObserve extends NetworkEvent {}

class NetworkNotify extends NetworkEvent {
  final bool isConnected;

  NetworkNotify(this.isConnected);
}

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final _connectivity = Connectivity();
  NetworkBloc() : super(NetworkInitial()) {
    on<NetworkObserve>(_observe);
    on<NetworkNotify>(_notifyStatus);
  }

  void _observe(event, emit) {
    _connectivity.checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        add(NetworkNotify(false));
      } else {
        add(NetworkNotify(true));
      }
    });
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        add(NetworkNotify(false));
      } else {
        add(NetworkNotify(true));
      }
    });
  }

  void _notifyStatus(NetworkNotify event, Emitter<NetworkState> emit) {
    event.isConnected ? emit(NetworkSuccess()) : emit(NetworkFailure());
  }
}
