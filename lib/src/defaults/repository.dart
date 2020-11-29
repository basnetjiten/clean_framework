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
      E entity, Function(dynamic) subscription,
      {bool deleteIfExists = false}) {
    final existingScope = scopes.keys.firstWhere(
        (element) => scopes[element].runtimeType == entity.runtimeType,
        orElse: () => null);

    if (existingScope != null && !deleteIfExists) {
      existingScope.subscription = subscription;
      return existingScope;
    } else if (existingScope != null && deleteIfExists) {
      scopes.remove(existingScope);
    }

    RepositoryScope scope = RepositoryScope(subscription);
    scopes[scope] = entity;
    return scope;
  }

  void update<E extends Entity>(RepositoryScope scope, E entity) {
    if (scopes[scope] == null)
      throw StateError('Entity not found for that scope.');
    scopes[scope] = entity;
  }

  E get<E extends Entity>(RepositoryScope scope) {
    if (scopes[scope] == null)
      throw StateError('Entity not found for that scope.');
    return scopes[scope];
  }

  Future<void> runServiceAdapter(
      RepositoryScope scope, ServiceAdapter adapter) async {
    scopes[scope] = await adapter.query(scopes[scope]);
    scope.subscription(scopes[scope]);
  }

  RepositoryScope containsScope<E extends Entity>() {
    final existingScope = scopes.keys.firstWhere(
        (element) => scopes[element].runtimeType == E,
        orElse: () => null);
    return (existingScope);
  }
}
