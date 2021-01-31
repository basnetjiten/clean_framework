import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'router.dart';

class CFRouteInformationParser
    extends RouteInformationParser<CFRouteInformation> {
  @override
  Future<CFRouteInformation> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    return SynchronousFuture(
      CFRouteInformation.fromLocation(routeInformation.location),
    );
  }

  @override
  RouteInformation restoreRouteInformation(CFRouteInformation configuration) {
    return RouteInformation(
      location: configuration.location,
      state: configuration.arguments,
    );
  }
}
