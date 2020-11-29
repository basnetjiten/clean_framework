import 'dart:async';
import 'dart:ui';

class Pipe<T> {
  StreamController<T> _controller;
  bool _hasListeners = false;
  final bool canSendDuplicateData;
  T initialData;
  T _lastData;

  Stream<T> get receive => _controller.stream;
  bool get hasListeners => _hasListeners;

  Pipe._(
      {StreamController controller,
      this.initialData,
      this.canSendDuplicateData = false}) {
    _controller = controller ?? StreamController<T>.broadcast();
    _controller.onListen = () {
      _hasListeners = true;
    };
  }

  factory Pipe({T initialData, bool canSendDuplicateData = false}) {
    return Pipe._(
        initialData: initialData, canSendDuplicateData: canSendDuplicateData);
  }

  factory Pipe.single({T initialData, bool canSendDuplicateData = false}) {
    return Pipe._(
        controller: StreamController<T>(),
        initialData: initialData,
        canSendDuplicateData: canSendDuplicateData);
  }

  void whenListenedDo(VoidCallback onListen) {
    _controller.onListen = () {
      _hasListeners = true;
      if (onListen != null) onListen();
    };
  }

  void dispose() {
    _controller.close();
  }

  bool send(T data) {
    if (_controller.isClosed ||
        (canSendDuplicateData == false && _lastData == data)) return false;
    _lastData = data;
    _controller.sink.add(data);
    return true;
  }

  bool throwError(Error error) {
    if (_controller.isClosed) return false;
    _controller.sink.addError(error);
    return true;
  }
}

class EventPipe extends Pipe<void> {
  EventPipe({VoidCallback onListen})
      : super._(initialData: null, canSendDuplicateData: true);
  //EventPipe.single({VoidCallback onListen}) : super.single(initialData: null);

  @override
  get receive => null;

  @override
  bool send(_) {
    if (_controller.isClosed) return false;
    _controller.sink.add(null);
    return true;
  }

  bool launch() => send(null);

  StreamSubscription<void> listen(void onData(), {Function onError}) {
    return _controller.stream.listen((_) => onData(), onError: onError);
  }
}
