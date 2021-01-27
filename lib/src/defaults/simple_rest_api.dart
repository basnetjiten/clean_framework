import 'dart:async';
import 'dart:io';

import 'package:clean_framework/clean_framework.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class SimpleRestApi extends RestApi {
  final baseUrl;
  final bool _trustSelfSigned = true;

  HttpClient _httpClient;
  IOClient _ioClient;

  SimpleRestApi({this.baseUrl = 'http://127.0.0.1:8080/service/'}) {
    _httpClient = new HttpClient()
      //@TODO should we remove this? Not sure if its safe for release
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => _trustSelfSigned);
    _ioClient = new IOClient(_httpClient);
  }


  @override
  Future<RestResponse> requestBinary(
      {RestMethod method, String path, Map<String,
          dynamic> requestBody = const {}}) {

    return request(method: method, path: path, requestBody: requestBody);
  }

  @override
  Future<RestResponse> request(
      {RestMethod method,
      String path,
      Map<String, dynamic> requestBody = const {}}) async {
    assert(method != null && path != null && path.isNotEmpty);

    Response response;
    Uri uri = Uri.parse(baseUrl + path);

    try {
      switch (method) {
        case RestMethod.get:
          response = await _ioClient.get(uri);
          break;
        case RestMethod.post:
          response = await _ioClient.post(uri, body: requestBody);
          break;
        case RestMethod.put:
          response = await _ioClient.put(uri, body: requestBody);
          break;
        case RestMethod.delete:
          response = await _ioClient.delete(uri);
          break;
        case RestMethod.patch:
          response = await _ioClient.patch(uri, body: requestBody);
          break;
      }

      return RestResponse<String>(
        type: RestResponseType.success,
        uri: uri,
        content: response.body,
      );
    } on ClientException {
      return RestResponse<String>(
        type: getResponseTypeFromCode(response.statusCode),
        uri: uri,
        content: response.body,
      );
    } catch (e) {
      return RestResponse<String>(
        type: RestResponseType.unknown,
        uri: uri,
        content: '',
      );
    }
  }
}
