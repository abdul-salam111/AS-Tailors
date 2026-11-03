import 'package:flutter_template/core/constants/const_exports.dart';

class AppException implements Exception {
  final String message;
  const AppException([this.message = AppConstants.unexpectedError]);

  @override
  String toString() => message;
}

class NoInternetException extends AppException {
  const NoInternetException([super.message = AppConstants.noInternetConnection]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = AppConstants.unauthorizedRequest]);
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException([super.message = AppConstants.requestTimedOut]);
}

class FetchDataException extends AppException {
  const FetchDataException([super.message = AppConstants.errorFetchingData]);
}

class BadRequestException extends AppException {
  const BadRequestException([super.message = AppConstants.invalidRequest]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = AppConstants.resourceNotFound]);
}

class InternalServerErrorException extends AppException {
  const InternalServerErrorException([super.message = AppConstants.internalServerError]);
}

class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException([super.message = AppConstants.serviceUnavailable]);
}

class InvalidInputException extends AppException {
  const InvalidInputException([super.message = AppConstants.invalidInput]);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = AppConstants.accessForbidden]);
}

class TooManyRequestsException extends AppException {
  const TooManyRequestsException([super.message = AppConstants.tooManyRequests]);
}

class MethodNotAllowedException extends AppException {
  const MethodNotAllowedException([super.message = AppConstants.methodNotAllowed]);
}
