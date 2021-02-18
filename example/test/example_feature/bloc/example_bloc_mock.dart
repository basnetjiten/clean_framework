import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework_example/example_feature/bloc/example_bloc.dart';
import 'package:mockito/mockito.dart';

class ExampleBlocMock extends Fake implements ExampleBloc {
  @override
  Pipe<ExampleViewModel> exampleViewModelPipe = Pipe<ExampleViewModel>();

  ExampleBlocMock() {
    exampleViewModelPipe.whenListenedDo(() {
      exampleViewModelPipe.send(
        ExampleViewModel(
          lastLogin: DateTime.parse('2020-01-01'),
          loginCount: 5,
        ),
      );
    });
  }
}
