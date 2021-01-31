import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework/src/bloc/service_adapter.dart';
import 'package:clean_framework/src/model/entity.dart';

class RepositoryScope {
  Function(dynamic) subscription;
  RepositoryScope(this.subscription);
}

class Repository {
  Map<RepositoryScope, Entity> scopes = {};

  RepositoryScope create<E extends Entity>(
    E entity,
    Function(dynamic) subscription, {
    bool deleteIfExists = false,
  }) {
    try {
      final existingScope = scopes.keys.firstWhere(
        (element) => scopes[element].runtimeType == entity.runtimeType,
      );
      if (deleteIfExists) {
        scopes.remove(existingScope);
      } else {
        return existingScope..subscription = subscription;
      }
    } on StateError {
      //no-op
    }

    final scope = RepositoryScope(subscription);
    scopes[scope] = entity;
    return scope;
  }

  void update<E extends Entity>(RepositoryScope scope, E entity) {
    if (scopes[scope] == null) throw _entityNotFound;
    scopes[scope] = entity;
  }

  E get<E extends Entity>(RepositoryScope scope) {
    if (scopes[scope] == null) throw _entityNotFound;
    return scopes[scope] as E;
  }

  Future<void> runServiceAdapter(
    RepositoryScope scope,
    ServiceAdapter adapter,
  ) async {
    if (scopes[scope] == null) throw _entityNotFound;
    scopes[scope] = await adapter.query(scopes[scope]!);
    scope.subscription(scopes[scope]);
  }

  RepositoryScope? containsScope<E extends Entity>() {
    try {
      return scopes.keys.firstWhere(
        (element) => scopes[element].runtimeType == E,
      );
    } on StateError {
      return null;
    }
  }

  Never get _entityNotFound =>
      throw StateError('Entity not found for that scope.');
}
