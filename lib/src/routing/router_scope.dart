part of 'router.dart';

typedef CFRouteGenerator<T> = CFRoutePage<T> Function<T>(
  String routeName, [
  Object arguments,
]);

class CFRouterScope extends InheritedWidget {
  final CFRouter _router;
  final String _initialRoute;

  CFRouterScope({
    Key key,
    @required String initialRoute,
    @required Widget Function(String routeName) generator,
    @required @required WidgetBuilder builder,
  })  : _router = CFRouter(
          initialRouteName: initialRoute,
          routeGenerator: <T>(String routeName, [Object arguments]) {
            return CFRoutePage<T>(
              child: generator(routeName),
              name: routeName,
              arguments: arguments,
            );
          },
        ),
        _initialRoute = initialRoute,
        super(child: Builder(builder: builder));

  static CFRouter of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CFRouterScope>()._router;
  }

  @override
  bool updateShouldNotify(CFRouterScope oldWidget) {
    if (oldWidget._initialRoute == _initialRoute) return false;
    return _router.updateInitialRoute(_initialRoute);
  }
}
