import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'router.dart';

class CFRouterDelegate extends RouterDelegate<CFRouteInformation>
    with PopNavigatorRouterDelegateMixin<CFRouteInformation>, ChangeNotifier {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  CFRouter _router;
  CFRouter get router => _router;

  CFRouterDelegate(
    BuildContext context, {
    GlobalKey<NavigatorState> navigatorKey,
  }) : navigatorKey = navigatorKey ?? GlobalObjectKey<NavigatorState>(context) {
    // ignore: invalid_use_of_protected_member
    _router = CFRouterScope.of(context)..updatePipe.listen(notifyListeners);
  }

  @override
  Future<void> setNewRoutePath(CFRouteInformation configuration) {
    _router.push(configuration.name, configuration.arguments);
    return SynchronousFuture(null);
  }

  @override
  CFRouteInformation get currentConfiguration => router.currentPage.information;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _router.pages,
      onPopPage: (route, result) {
        final success = route.didPop(result);
        if (success) _router.pop();
        return success;
      },
    );
  }
}
