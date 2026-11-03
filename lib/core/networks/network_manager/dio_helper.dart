import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../exceptions/app_exceptions.dart';

class DioHelper {
  final Dio dio;

  DioHelper({required this.dio});

  /// Base options applied to every request.
  /// Pass [useAppToken] to opt out of the [AuthInterceptor] token injection —
  /// use this for public endpoints (login, register, forgot-password, etc.).
  Options _buildOptions({bool useAppToken = false}) => Options(
        receiveDataWhenStatusError: true,
        contentType: 'application/json',
        responseType: ResponseType.json,
        extra: useAppToken ? {'useAppToken': true} : {},
      );

  Future<dynamic> getApi({
    required String url,
    Object? requestBody,
    Map<String, dynamic>? queryParameters,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dio.get<dynamic>(
        url,
        options: _buildOptions(useAppToken: useAppToken),
        data: requestBody,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (error) {
      throw _handleDioError(error);
    } catch (error) {
      throw FetchDataException(error.toString());
    }
  }

  Future<dynamic> postApi({
    required String url,
    Object? requestBody,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        url,
        data: requestBody,
        options: _buildOptions(useAppToken: useAppToken),
      );
      return response.data;
    } on DioException catch (error) {
      throw _handleDioError(error);
    } catch (error) {
      throw FetchDataException(error.toString());
    }
  }

  Future<dynamic> putApi({
    required String url,
    Object? requestBody,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dio.put<dynamic>(
        url,
        options: _buildOptions(useAppToken: useAppToken),
        data: requestBody,
      );
      return response.data;
    } on DioException catch (error) {
      throw _handleDioError(error);
    } catch (error) {
      throw FetchDataException(error.toString());
    }
  }

  Future<dynamic> patchApi({
    required String url,
    Object? requestBody,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dio.patch<dynamic>(
        url,
        options: _buildOptions(useAppToken: useAppToken),
        data: requestBody,
      );
      return response.data;
    } on DioException catch (error) {
      throw _handleDioError(error);
    } catch (error) {
      throw FetchDataException(error.toString());
    }
  }

  Future<dynamic> deleteApi({
    required String url,
    Object? requestBody,
    Map<String, dynamic>? queryParameters,
    bool useAppToken = false,
  }) async {
    try {
      final response = await dio.delete<dynamic>(
        url,
        options: _buildOptions(useAppToken: useAppToken),
        data: requestBody,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (error) {
      throw _handleDioError(error);
    } catch (error) {
      throw FetchDataException(error.toString());
    }
  }

  Future<dynamic> sendMultipartRequest({
    required String url,
    Map<String, dynamic>? fields,
    List<FileUploadModel>? files,
    bool useAppToken = false,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();

      if (fields != null) {
        fields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      if (files != null && files.isNotEmpty) {
        for (final fileModel in files) {
          final file = File(fileModel.filePath);
          // ignore: avoid_slow_async_io
          if (!await file.exists()) {
            throw Exception('File not found: ${fileModel.filePath}');
          }
          final fileName = fileModel.fileName ?? file.path.split('/').last;
          formData.files.add(
            MapEntry(
              fileModel.fieldName,
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
                contentType: fileModel.contentType,
              ),
            ),
          );
        }
      }

      // ignore: avoid_slow_async_io
      final response = await dio.post<dynamic>(
        url,
        data: formData,
        options: Options(extra: useAppToken ? {'useAppToken': true} : {}),
        onSendProgress: onSendProgress,
      );
      return response.data;
    } on DioException catch (error) {
      throw _handleDioError(error);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> uploadSingleFile({
    required String url,
    required String fieldName,
    required String filePath,
    Map<String, dynamic>? additionalFields,
    bool useAppToken = false,
    ProgressCallback? onSendProgress,
  }) {
    return sendMultipartRequest(
      url: url,
      fields: additionalFields,
      files: [FileUploadModel(fieldName: fieldName, filePath: filePath)],
      useAppToken: useAppToken,
      onSendProgress: onSendProgress,
    );
  }

  Future<dynamic> uploadMultipleFiles({
    required String url,
    required String fieldName,
    required List<String> filePaths,
    Map<String, dynamic>? additionalFields,
    bool useAppToken = false,
    ProgressCallback? onSendProgress,
  }) {
    return sendMultipartRequest(
      url: url,
      fields: additionalFields,
      files: filePaths
          .map((path) => FileUploadModel(fieldName: fieldName, filePath: path))
          .toList(),
      useAppToken: useAppToken,
      onSendProgress: onSendProgress,
    );
  }

  AppException _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode != null) {
      final errorMessage = _extractErrorMessage(error.response);

      switch (statusCode) {
        case 400:
          return BadRequestException(errorMessage ?? 'Bad request');
        case 401:
          return UnauthorizedException(errorMessage ?? 'Unauthorized access');
        case 403:
          return ForbiddenException(errorMessage ?? 'Access forbidden');
        case 404:
          return NotFoundException(errorMessage ?? 'Resource not found');
        case 405:
          return MethodNotAllowedException(errorMessage ?? 'Method not allowed');
        case 408:
          return RequestTimeoutException(errorMessage ?? 'Request timeout');
        case 422:
          return InvalidInputException(errorMessage ?? 'Invalid input data');
        case 429:
          return TooManyRequestsException(errorMessage ?? 'Too many requests');
        case 500:
          return InternalServerErrorException(
              errorMessage ?? 'Internal server error');
        case 502:
          return ServiceUnavailableException(errorMessage ?? 'Bad gateway');
        case 503:
          return ServiceUnavailableException(
              errorMessage ?? 'Service unavailable');
        case 504:
          return RequestTimeoutException(errorMessage ?? 'Gateway timeout');
        default:
          if (statusCode >= 400 && statusCode < 500) {
            return BadRequestException(
                errorMessage ?? 'Client error: $statusCode');
          }
          return InternalServerErrorException(
              errorMessage ?? 'Server error: $statusCode');
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RequestTimeoutException(error.message ?? 'Request timeout');
      case DioExceptionType.badResponse:
        return FetchDataException(error.message ?? 'Bad response from server');
      case DioExceptionType.cancel:
        return const FetchDataException('Request cancelled');
      case DioExceptionType.connectionError:
        return NoInternetException(error.message ?? 'No internet connection');
      case DioExceptionType.badCertificate:
        return BadRequestException(error.message ?? 'SSL certificate error');
      case DioExceptionType.unknown:
        return FetchDataException(error.message ?? 'Unknown error occurred');
    }
  }

  String? _extractErrorMessage(Response<dynamic>? response) {
    if (response?.data == null) return null;
    try {
      final data = response!.data;
      if (data is Map) {
        return data['message'] as String? ??
            data['error'] as String? ??
            data['msg'] as String? ??
            data['detail'] as String? ??
            data['errorMessage'] as String?;
      } else if (data is String) {
        return data;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

class FileUploadModel {
  final String fieldName;
  final String filePath;
  final String? fileName;
  final MediaType? contentType;

  FileUploadModel({
    required this.fieldName,
    required this.filePath,
    this.fileName,
    this.contentType,
  });
}
