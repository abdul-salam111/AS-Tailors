import '../../networks/exceptions/app_exceptions.dart';
import '../../networks/network_manager/dio_helper.dart';

abstract class BaseRemoteDatasource {
  final DioHelper dioHelper;

  const BaseRemoteDatasource({required this.dioHelper});

  /// POST — single object response.
  /// Pass [useAppToken] for endpoints that require the static app token.
  Future<T> post<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(dynamic response) parser,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.postApi(
        url: url,
        requestBody: body,
        useAppToken: useAppToken,
      );
      return parser(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// POST — list response.
  Future<List<T>> postList<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(dynamic json) parser,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.postApi(
        url: url,
        requestBody: body,
        useAppToken: useAppToken,
      );
      return (response as List<dynamic>).map<T>((final json) => parser(json)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// GET — single object response.
  Future<T> get<T>({
    required String url,
    required T Function(dynamic response) parser,
    Map<String, dynamic>? queryParams,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.getApi(
        url: url,
        queryParameters: queryParams,
        useAppToken: useAppToken,
      );
      return parser(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// GET — list response.
  Future<List<T>> getList<T>({
    required String url,
    required T Function(dynamic json) parser,
    Map<String, dynamic>? queryParams,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.getApi(
        url: url,
        queryParameters: queryParams,
        useAppToken: useAppToken,
      );
      return (response as List<dynamic>).map<T>((final json) => parser(json)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// PUT — single object response.
  Future<T> put<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(dynamic response) parser,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.putApi(
        url: url,
        requestBody: body,
        useAppToken: useAppToken,
      );
      return parser(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// PUT — list response.
  Future<List<T>> putList<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(dynamic json) parser,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.putApi(
        url: url,
        requestBody: body,
        useAppToken: useAppToken,
      );
      return (response as List<dynamic>).map<T>((final json) => parser(json)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// PATCH — single object response.
  Future<T> patch<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(dynamic response) parser,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.patchApi(
        url: url,
        requestBody: body,
        useAppToken: useAppToken,
      );
      return parser(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// DELETE — single object response.
  Future<T> delete<T>({
    required String url,
    required T Function(dynamic response) parser,
    Map<String, dynamic>? queryParams,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.deleteApi(
        url: url,
        queryParameters: queryParams,
        useAppToken: useAppToken,
      );
      return parser(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// DELETE — list response.
  Future<List<T>> deleteList<T>({
    required String url,
    required T Function(dynamic json) parser,
    Map<String, dynamic>? queryParams,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dioHelper.deleteApi(
        url: url,
        queryParameters: queryParams,
        useAppToken: useAppToken,
      );
      return (response as List<dynamic>).map<T>((final json) => parser(json)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  /// Multipart file upload.
  Future<dynamic> uploadFile({
    required String url,
    required String fieldName,
    required String filePath,
    Map<String, dynamic>? additionalFields,
    bool useAppToken = false,
    void Function(int, int)? onSendProgress,
  }) {
    return dioHelper.uploadSingleFile(
      url: url,
      fieldName: fieldName,
      filePath: filePath,
      additionalFields: additionalFields,
      useAppToken: useAppToken,
      onSendProgress: onSendProgress,
    );
  }

  /// Multi-file upload.
  Future<dynamic> uploadMultipleFiles({
    required String url,
    required String fieldName,
    required List<String> filePaths,
    Map<String, dynamic>? additionalFields,
    bool useAppToken = false,
    void Function(int, int)? onSendProgress,
  }) {
    return dioHelper.uploadMultipleFiles(
      url: url,
      fieldName: fieldName,
      filePaths: filePaths,
      additionalFields: additionalFields,
      useAppToken: useAppToken,
      onSendProgress: onSendProgress,
    );
  }
}
