import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework/clean_framework_defaults.dart';
import 'package:clean_framework/clean_framework_tests.dart';
import 'package:test/test.dart';

import '../test_config.dart';

void main() {
  testConfig();

  test('EitherService GET success with empty response', () async {
    final restApiMock = RestApiMock<String>(
      responseType: RestResponseType.success,
      content: '',
    );
    final service =
        TestServiceWithEmptyResponse(RestMethod.get, 'test', restApiMock);

    // Sending null in the request is just a test to demonstrate that it is
    // supported, we had a bug where an exception happened if this was null,
    // which was a problem with the implementation of the ResApi. In order
    // to not be sensitive to errors like that, it is better to also check
    // inside the request method if a null is sent.
    final response = await service.request(requestModel: null);
    expect(response.isRight, isTrue);
    response.fold((_) {}, (model) {
      expect(model, isA<EmptyJsonResponseModel>());
    });
  });

  test('EitherService GET success with custom response', () async {
    final restApiMock = RestApiMock<String>(
      responseType: RestResponseType.success,
      content: '{"field": 123}',
    );
    final service =
        TestServiceWithCustomResponse(RestMethod.get, 'test', restApiMock);

    final response = await service.request();
    expect(response.isRight, isTrue);
    response.fold((_) {}, (model) {
      expect(
          model, TestJsonResponseModel(field: 123, optionalField: 'default'));
    });
  });

  test('EitherService GET custom failure', () async {
    final restApiMock = RestApiMock<String>(
      responseType: RestResponseType.conflict,
      content: '{"error": "custom"}',
    );
    final service = TestServiceWithCustomResponseAndCustomError(
        RestMethod.get, 'test', restApiMock);

    final response = await service.request();
    expect(response.isLeft, isTrue);
    response.fold((error) {
      expect(error, CustomServiceFailure());
    }, (_) {});
  });
}

class TestServiceWithEmptyResponse
    extends EitherService<JsonRequestModel, EmptyJsonResponseModel> {
  TestServiceWithEmptyResponse(RestMethod method, String path, RestApi restApi)
      : super(method: method, path: path, restApi: restApi);

  @override
  EmptyJsonResponseModel parseResponse(Map<String, dynamic> jsonResponse) {
    return EmptyJsonResponseModel();
  }
}

class TestServiceWithCustomResponse
    extends EitherService<JsonRequestModel, TestJsonResponseModel> {
  TestServiceWithCustomResponse(RestMethod method, String path, RestApi restApi)
      : super(method: method, path: path, restApi: restApi);

  @override
  TestJsonResponseModel parseResponse(Map<String, dynamic> jsonResponse) {
    return TestJsonResponseModel.fromJson(jsonResponse);
  }
}

class TestServiceWithCustomResponseAndCustomError
    extends EitherService<JsonRequestModel, TestJsonResponseModel> {
  TestServiceWithCustomResponseAndCustomError(
      RestMethod method, String path, RestApi restApi)
      : super(method: method, path: path, restApi: restApi);

  @override
  TestJsonResponseModel parseResponse(Map<String, dynamic> jsonResponse) {
    return TestJsonResponseModel.fromJson(jsonResponse);
  }

  @override
  ServiceFailure onError(
      RestResponseType responseType, Map<String, dynamic> jsonResponse) {
    if (responseType == RestResponseType.conflict)
      return CustomServiceFailure();
    return GeneralServiceFailure();
  }
}

class CustomServiceFailure extends ServiceFailure {}

class TestJsonResponseModel extends JsonResponseModel {
  final int field;
  final String optionalField;

  TestJsonResponseModel({required this.field, required this.optionalField});

  @override
  List<Object> get props => [field, optionalField];

  @override
  TestJsonResponseModel.fromJson(json)
      : field = json['field'] ?? 0,
        optionalField = json['optional_field'] ?? 'default';
}
