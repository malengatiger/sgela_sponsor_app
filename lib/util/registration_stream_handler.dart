import 'dart:async';

class RegistrationStreamHandler {

  final StreamController<bool> _streamController = StreamController.broadcast();
  Stream<bool> get registrationStream => _streamController.stream;

  void setCompleted() {
    _streamController.sink.add(true);
  }
  void setStart() {
    _streamController.sink.add(false);
  }
}
