import 'package:flutter/widgets.dart';

import 'router.dart';

/// Extension methods to Clean Framework Routing.
extension CFRouterExtension on BuildContext {
  /// The [CFRouter] in the current context.
  ///
  /// Alternatively, [CFRouterScope.of(context)] can used.
  CFRouter get router => CFRouterScope.of(this);

  /// The arguments passed to this route.
  T routeArguments<T>({bool nullOk = false}) {
    final modalRoute = ModalRoute.of(this);
    assert(modalRoute != null, 'Route is not ready to extract arguments.');
    final args = modalRoute.settings.arguments as T;
    assert(nullOk || args != null);
    return args;
  }
}
