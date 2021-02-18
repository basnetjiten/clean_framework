import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework/src/tests/view_model_pipe_tester.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bloc with model pipe', () async {
    final bloc = SimpleBloc();

    final tester = ViewModelPipeTester.forPipe(bloc.countPipe);
    await tester.whenBeingListenedTo().thenExpectAnyModel();

    await tester
        .whenDoing(() => bloc.sendMultipleModelsEvent.launch())
        .thenExpectInOrder(
      [
        SimpleViewModel(1),
        SimpleViewModel(2),
      ],
    );

    await tester
        .whenDoing(() => bloc.resetEvent.launch())
        .thenExpectA(SimpleViewModel(0));

    await tester
        .whenDoing(() => bloc.sendMultipleModelsEvent.launch())
        .thenExpectInOrder([
      SimpleViewModel(1),
      SimpleViewModel(2),
    ]);

    bloc.dispose();
  });
}

class SimpleBloc extends Bloc {
  int count = 0;
  Pipe<SimpleViewModel> countPipe = Pipe<SimpleViewModel>();
  EventPipe sendMultipleModelsEvent = EventPipe();
  EventPipe resetEvent = EventPipe();

  @override
  void dispose() {
    countPipe.dispose();
    sendMultipleModelsEvent.dispose();
    resetEvent.dispose();
  }

  SimpleBloc() {
    countPipe.whenListenedDo(_sendAndIncreaseCounter);
    sendMultipleModelsEvent.listen(_sendModels);
    resetEvent.listen(_resetListener);
  }

  void _sendAndIncreaseCounter() {
    countPipe.send(SimpleViewModel(count));
    count++;
  }

  void _sendModels() async {
    _sendAndIncreaseCounter();
    Future.delayed(Duration(milliseconds: 500));
    _sendAndIncreaseCounter();
  }

  void _resetListener() {
    count = 0;
    _sendAndIncreaseCounter();
  }
}

class SimpleViewModel extends ViewModel {
  final int count;
  SimpleViewModel(this.count);
  @override
  List<Object> get props => [count];
}
