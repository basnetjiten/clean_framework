import 'package:flutter/widgets.dart';

import 'router.dart';

extension CFRouterExtension on BuildContext {
  CFRouter get router => CFRouterScope.of(this);

  T routeArguments<T>({bool nullOk = false}) {
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments as T;
      assert(nullOk || args != null);
      return args;
    }
    throw Exception('Route is not ready to extract arguments.');
  }
}
