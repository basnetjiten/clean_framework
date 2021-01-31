import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework_example/routes.dart';
import 'package:flutter/material.dart';

import 'example_locator.dart';

void main() {
  logger().setLogLevel(LogLevel.verbose);

  runApp(_ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CFRouterScope(
      initialRoute: Routes.example,
      routeGenerator: Routes.generate,
      builder: (context) {
        return MaterialApp.router(
          routeInformationParser: CFRouteInformationParser(),
          routerDelegate: CFRouterDelegate(context),
        );
      },
    );
  }
}

/// 8-Jul Changes
/// New class JsonResponseBlocCallbackHandler
/// Bloc to own Entity creation and share the reference to usecases those that needs it.
/// Within usecase updates on the Entity should happen on the instance created by Bloc.
/// Fix testcases
