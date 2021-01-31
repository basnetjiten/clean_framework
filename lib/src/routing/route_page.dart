part of 'router.dart';

class CFRoutePage<T> extends MaterialPage {
  final _completer = Completer<T>();

  CFRoutePage({
    @required Widget child,
    @required String name,
    Object arguments,
  }) : super(
          child: child,
          name: name,
          arguments: arguments,
          key: ValueKey<String>(name),
        );

  CFRouteInformation get information =>
      CFRouteInformation(name: name, arguments: arguments);

  @override
  String toString() => 'CFRoutePage<$T>(name: $name, args: $arguments)';
}

class CFRouteInformation {
  final String name;
  final Object arguments;

  CFRouteInformation({@required this.name, this.arguments});

  factory CFRouteInformation.fromLocation(String location) {
    final uri = Uri.parse(location);
    return CFRouteInformation(name: uri.path, arguments: uri.queryParameters);
  }

  String get location {
    if (arguments is Map<String, dynamic>) {
      if ((arguments as Map).isEmpty) return name;
      return Uri(path: name, queryParameters: arguments).toString();
    }
    return name;
  }
}
