part of 'router.dart';

typedef CFRouteGenerator = Widget Function(String routeName);

class CFRouterScope extends InheritedWidget {
  final CFRouter _router;
  final String _initialRoute;

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

  static CFRouter of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CFRouterScope>()._router;
  }

  @override
  bool updateShouldNotify(CFRouterScope oldWidget) {
    if (oldWidget._initialRoute == _initialRoute) return false;
    return _router.updateInitialRoute(_initialRoute);
  }
}
