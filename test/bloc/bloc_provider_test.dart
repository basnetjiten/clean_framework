import 'package:clean_framework/clean_framework.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class TestBloc extends Bloc with EquatableMixin {
  final int blocId;

  TestBloc(this.blocId);

  @override
  void dispose() {}

  @override
  List<Object> get props => [blocId];
}

void main() {
  testWidgets(
      'new bloc won\'t be created if bloc of same type is found in ancestor',
      (tester) async {
    late BuildContext _context;
    final widget = BlocProvider<TestBloc>(
      create: (_) => TestBloc(2),
      child: BlocProvider<TestBloc>(
        create: (_) => TestBloc(1),
        child: Builder(
          builder: (context) {
            _context = context;
            return Container();
          },
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pump(Duration.zero);

    expect(BlocProvider.of<TestBloc>(_context).blocId, 2);
  });

  testWidgets(
      'new bloc will be created if bloc of same type is not found in ancestor',
      (tester) async {
    late BuildContext _context;
    final widget = BlocProvider<TestBloc>(
      create: (_) => TestBloc(1),
      child: Builder(
        builder: (context) {
          _context = context;
          return Container();
        },
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pump(Duration.zero);

    expect(BlocProvider.of<TestBloc>(_context).blocId, 1);
  });

  testWidgets('bloc provider test with extension', (tester) async {
    late BuildContext _context;
    final widget = Provider<TestBloc>(
      create: (_) => TestBloc(2),
      child: BlocProvider(
        create: (_) => TestBloc(1),
        child: Builder(
          builder: (context) {
            _context = context;
            return Container();
          },
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pump(Duration.zero);

    expect(_context.bloc<TestBloc>().blocId, 2);
  });

  // Only for comparing with behaviour of bloc provider
  testWidgets('provider test', (tester) async {
    late BuildContext _context;
    final widget = Provider<TestBloc>(
      create: (_) => TestBloc(2),
      child: Provider(
        create: (_) => TestBloc(1),
        child: Builder(
          builder: (context) {
            _context = context;
            return Container();
          },
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pump(Duration.zero);

    expect(Provider.of<TestBloc>(_context, listen: false).blocId, 1);
  });
}
