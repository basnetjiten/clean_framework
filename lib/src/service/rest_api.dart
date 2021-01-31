import 'package:clean_framework/clean_framework.dart';
import 'package:flutter/widgets.dart';

enum RestMethod { get, post, put, delete, patch }

enum RestContentType { json, html, binary, text, unknown }

abstract class RestApi<T extends RestResponse> extends ExternalDependency {
  /// The Uri for the request is built inside ResApi, to give flexibility on
  /// how it is used. The path parameter corresponds to the Uri path, which
  /// doesn't hold the host, port and scheme.
  Future<T> request({
    @required RestMethod method,
    @required String path,
    Map<String, dynamic> requestBody = const {},
  });

  Future<T> requestBinary({
    @required RestMethod method,
    @required String path,
    Map<String, dynamic> requestBody = const {},
  });

  RestResponseType getResponseTypeFromCode(int code) =>
      _responseCodeToRestResponseTypeMap[code] ?? RestResponseType.unknown;
}

class RestResponse<T> {
  final RestResponseType type;
  final T content;
  final Uri uri;
  final RestContentType contentType;
  RestResponse(
      {this.type = RestResponseType.unknown,
      this.content,
      this.uri,
      this.contentType = RestContentType.unknown})
      : assert(content != null),
        assert(uri != null);
}

final restContentTypeMap = {
  'application/json; charset=utf-8': RestContentType.json,
  'text/html; charset=utf-8': RestContentType.html,
  'text/plain; charset=utf-8': RestContentType.text,
  'application/octet-stream': RestContentType.binary,
  'application/pdf': RestContentType.binary
};

enum RestResponseType {
  // Success
  success,

  // Errors
  timeOut,
  badRequest,
  notFound,
  conflict,
  internalServerError,
  unauthorized,
  unknown
}

final _responseCodeToRestResponseTypeMap = {
  200: RestResponseType.success,
  201: RestResponseType.success,
  400: RestResponseType.badRequest,
  401: RestResponseType.unauthorized,
  403: RestResponseType.unauthorized,
  404: RestResponseType.notFound,
  409: RestResponseType.conflict,
  500: RestResponseType.internalServerError,
};
