import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:jazz/features/internet_connection_checker/presentation/bloc/internet_connection_checker_event.dart';
import 'package:jazz/features/internet_connection_checker/presentation/bloc/internet_connection_checker_state.dart';


class InternetConnectionBloc extends Bloc<InternetConnectionEvent, InternetConnectionState> {
  late StreamSubscription<InternetStatus> _subscription;
  final InternetConnection _internetConnection = InternetConnection();
  bool _lastConnectionStatus = true;

  InternetConnectionBloc() : super(InternetConnectionInitial()) {
    on<CheckInternetConnection>(_onCheckInternetConnection);
    on<InternetConnectionChanged>(_onInternetConnectionChanged);
    on<RetryInternetConnection>(_onRetryInternetConnection);

    // Initialize the stream subscription
    _subscription = _internetConnection.onStatusChange.listen((status) {
      bool isConnected = status == InternetStatus.connected;
      // Only emit if status changed to avoid duplicate events
      if (isConnected != _lastConnectionStatus) {
        _lastConnectionStatus = isConnected;
        add(InternetConnectionChanged(isConnected));
      }
    });

    // Initial check
    add(CheckInternetConnection());
  }

  Future<void> _onCheckInternetConnection(
      CheckInternetConnection event,
      Emitter<InternetConnectionState> emit,
      ) async {
    emit(InternetConnectionLoading());
    final bool hasInternet = await _internetConnection.hasInternetAccess;
    _lastConnectionStatus = hasInternet;
    if (hasInternet) {
      emit(InternetConnectionAvailable());
    } else {
      emit(InternetConnectionUnavailable());
    }
  }

  void _onInternetConnectionChanged(
      InternetConnectionChanged event,
      Emitter<InternetConnectionState> emit,
      ) {
    if (event.isConnected) {
      emit(InternetConnectionAvailable());
    } else {
      emit(InternetConnectionUnavailable());
    }
  }

  Future<void> _onRetryInternetConnection(
      RetryInternetConnection event,
      Emitter<InternetConnectionState> emit,
      ) async {
    emit(InternetConnectionLoading());
    await Future.delayed(const Duration(seconds: 2)); // Simulate checking
    final bool hasInternet = await _internetConnection.hasInternetAccess;
    _lastConnectionStatus = hasInternet;
    if (hasInternet) {
      emit(InternetConnectionAvailable());
    } else {
      emit(InternetConnectionUnavailable());
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
