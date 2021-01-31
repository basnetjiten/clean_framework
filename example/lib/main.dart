import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework_example/example_feature/ui/example_feature_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'example_locator.dart';

void main() {
  logger().setLogLevel(LogLevel.verbose);

  runApp(_ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExampleFeatureWidget(),
    );
  }
}

/// 8-Jul Changes
/// New class JsonResponseBlocCallbackHandler
/// Bloc to own Entity creation and share the reference to usecases those that needs it.
/// Within usecase updates on the Entity should happen on the instance created by Bloc.
/// Fix testcases
