import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework/clean_framework_defaults.dart';
import 'package:clean_framework/clean_framework_tests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Presenter and Screen show the view model data', (tester) async {
    final testWidget = MaterialApp(
      home: BlocProvider<TestBloc>(
        create: (_) => TestBloc(),
        child: TestPresenter<TestBloc>(),
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.pump(Duration(milliseconds: 200));

    expect(find.byType(TestScreen), findsOneWidget);
    expect(find.text('foo'), findsOneWidget);
  });

  testWidgets(
      'Presenter and Screen show default data if service is unreachable',
      (tester) async {
    final testWidget = MaterialApp(
      home: BlocProvider<TestBlocWithService>(
        create: (_) => TestBlocWithService(),
        child: TestResponseHandlerWidget<TestBlocWithService>(
          onError: expectAsync1((errorType) {
            expect(errorType, PublishedErrorType.general);
          }),
          child: TestPresenter<TestBlocWithService>(),
        ),
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.pump(Duration(milliseconds: 200));

    expect(find.byType(TestScreen), findsOneWidget);
    expect(find.text('foo'), findsNothing);
  });
}

class TestPresenter<B extends TestBloc>
    extends Presenter<B, TestViewModel, TestScreen> {
  @override
  TestScreen buildScreen(
      BuildContext context, B bloc, TestViewModel viewModel) {
    return TestScreen(viewModel: viewModel);
  }

  @override
  Stream<TestViewModel> getViewModelStream(B bloc) {
    return bloc.viewModelPipe.receive;
  }
}

class TestScreen extends Screen {
  final TestViewModel viewModel;

  TestScreen({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Text(viewModel.greeting);
  }
}

class TestViewModel extends ViewModel {
  final greeting;

  TestViewModel({this.greeting = 'foo'});

  @override
  List<Object> get props => [greeting];
}

class TestBloc extends ErrorPublisherBloc {
  Pipe<TestViewModel> viewModelPipe = Pipe<TestViewModel>();

  @override
  void dispose() {
    viewModelPipe.dispose();
  }

  TestBloc() {
    viewModelPipe.whenListenedDo(() {
      viewModelPipe.send(TestViewModel());
    });
  }
}

class TestBlocWithService extends TestBloc {
  late JsonResponseBlocHandler<TestBloc, TestResponseModel> handler;
  late TestService _service;

  TestBusinessModel _businessModel = TestBusinessModel();

  @override
  Pipe<TestViewModel> viewModelPipe = Pipe<TestViewModel>();

  @override
  void dispose() {
    viewModelPipe.dispose();
  }

  TestBlocWithService() {
    handler = JsonResponseBlocHandler<TestBloc, TestResponseModel>(
      bloc: this,
      success: _serviceSuccess,
    );
    _service = TestService(handler);

    viewModelPipe.whenListenedDo(() async {
      await _service.request();
      viewModelPipe.send(_viewModel);
    });
  }

  void _serviceSuccess(TestResponseModel responseModel) {
    _businessModel.greeting = responseModel.greeting;
  }

  TestViewModel get _viewModel => TestViewModel(
        greeting: _businessModel.greeting,
      );
}

class TestBusinessModel extends BusinessModel {
  String greeting = '';
}

class TestService extends JsonService {
  TestService(handler)
      : super(
          handler: handler,
          method: RestMethod.get,
          path: 'fake',
          restApi: SimpleRestApi(),
        );

  @override
  TestResponseModel parseResponse(Map<String, dynamic> jsonResponse) {
    return TestResponseModel.fromJson(jsonResponse);
  }
}

class TestResponseModel extends JsonResponseModel {
  final greeting;

  @override
  List<Object> get props => [greeting];

  TestResponseModel.fromJson(Map<String, dynamic> json)
      : greeting = json['greeting'] ?? '';
}
