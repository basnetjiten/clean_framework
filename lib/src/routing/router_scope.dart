part of 'router.dart';

/// The [routeName] to widget generator for [CFRouter].
typedef CFRouteGenerator = Widget Function(String routeName);

/// An inherited widget which is responsible for providing access to
/// [CFRouter] instance to its descendants.
class CFRouterScope extends InheritedWidget {
  final CFRouter _router;
  final String _initialRoute;

  /// Create a CFRouter Scope.
  CFRouterScope({
    Key key,
    @required String initialRoute,
    @required CFRouteGenerator routeGenerator,
    @required @required WidgetBuilder builder,
  })  : _router = CFRouter(
          initialRouteName: initialRoute,
          routePageGenerator: <T>(String routeName, [Object arguments]) {
            return CFRoutePage<T>(
              child: routeGenerator(routeName),
              name: routeName,
              arguments: arguments,
            );
          },
        ),
        _initialRoute = initialRoute,
        super(child: Builder(builder: builder));

  /// Returns the [CFRouter] found in the [context].
  ///
  /// Alternatively, [context.router] can be used.
  static CFRouter of(BuildContext context) {
    final _routerScope =
        context.dependOnInheritedWidgetOfExactType<CFRouterScope>();
    assert(
      _routerScope != null,
      'No CFRouterScope ancestor found.\n'
      'CFRouterScope must be at the root of your widget tree in order to access CFRouter, '
      'either using CFRouterScope.of(context) or context.router',
    );
    return _routerScope._router;
  }

  @override
  bool updateShouldNotify(CFRouterScope oldWidget) {
    if (oldWidget._initialRoute == _initialRoute) return false;
    return _router.updateInitialRoute(_initialRoute);
  }
}
