abstract class InternetConnectionEvent {}

class CheckInternetConnection extends InternetConnectionEvent {}

class InternetConnectionChanged extends InternetConnectionEvent {
  final bool isConnected;

  InternetConnectionChanged(this.isConnected);
}

class RetryInternetConnection extends InternetConnectionEvent {}
