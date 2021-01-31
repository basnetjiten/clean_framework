import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../bloc/pipes.dart';

part 'route_page.dart';
part 'router_scope.dart';

class CFRouter {
  @visibleForTesting
  final EventPipe updatePipe = EventPipe();
  final CFRouteGenerator generator;

  CFRouter({
    @required String initialRoute,
    @required this.generator,
  }) : _pages = [generator(initialRoute)];

  List<CFRoutePage> _pages;
  List<CFRoutePage> get pages => _pages;

  CFRoutePage get currentPage {
    assert(_pages.isNotEmpty, 'There is no current route.');
    return _pages.last;
  }

  CFRoutePage get previousPage {
    // Returns null if there's no previous route.
    final _previousPageIndex = _pages.length - 2;
    if (_previousPageIndex.isNegative) return null;
    return _pages[_previousPageIndex];
  }

  Future<T> push<T>(String routeName, [Object arguments]) {
    final routePage = generator<T>(routeName, arguments);
    _pages
      ..removeWhere((page) => page.name == routeName)
      ..add(routePage);
    _notifyUpdate();
    return routePage._completer.future;
  }

  Future<T> replaceWith<T>(String routeName, {Object arguments}) {
    final routePage = generator<T>(routeName, arguments);
    _pages
      ..removeWhere((page) => page.name == routeName)
      ..removeLast()
      ..add(routePage);
    _notifyUpdate();
    return routePage._completer.future;
  }

  bool pop<T>([T value]) {
    if (_pages.length < 2) return false;
    final _lastRoutePage = _pages.last;
    _pages.removeLast();
    _notifyUpdate();
    _lastRoutePage._completer.complete(value);
    return true;
  }

  bool popUntil(String route) {
    if (_pages.length < 2) return false;
    if (_pages.every((page) => page.name != route)) {
      throw StateError('No route found = $route');
    }
    while (_pages.last.name != route) {
      _pages.removeLast();
    }
    _notifyUpdate();
    return true;
  }

  void update(List<CFRouteInformation> routeInfoList) {
    assert(
        routeInfoList.isNotEmpty, 'There should be at least one initial route');
    _pages = routeInfoList.map((r) => generator(r.name, r.arguments)).toList();
    _notifyUpdate();
  }

  bool updateInitialRoute(String initialRoute) {
    _pages = [generator(initialRoute)];
    return _notifyUpdate();
  }

  bool _notifyUpdate() {
    _pages = List.from(_pages);
    return updatePipe.launch();
  }
}
