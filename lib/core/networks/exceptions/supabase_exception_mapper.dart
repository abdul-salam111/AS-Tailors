import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_exceptions.dart';

/// Maps a raw error thrown by `supabase_flutter`/`postgrest`/`gotrue`/
/// `storage_client` onto this app's backend-agnostic [AppException]
/// hierarchy — the same one `DioHelper` throws for REST calls. Doing the
/// translation here, once, means [BaseRepository.execute] and everything
/// downstream of it (Failure mapping, AppFailureMapper, BLoC state) never
/// needs to know or care which backend a given feature talks to.
AppException mapSupabaseException(Object error) {
  if (error is AppException) return error;

  if (error is AuthException) {
    switch (error.statusCode) {
      case '400':
      case '401':
      case '422':
        return UnauthorizedException(error.message);
      case '403':
        return ForbiddenException(error.message);
      case '404':
        return NotFoundException(error.message);
      case '429':
        return TooManyRequestsException(error.message);
      default:
        return InternalServerErrorException(error.message);
    }
  }

  if (error is PostgrestException) {
    switch (error.code) {
      case '23505': // unique_violation
        return BadRequestException(error.message);
      case '42501': // insufficient_privilege — RLS denied the operation
        return ForbiddenException(error.message);
      case 'PGRST116': // .single()/.maybeSingle() found no matching row
        return NotFoundException(error.message);
      default:
        return InternalServerErrorException(error.message);
    }
  }

  if (error is StorageException) {
    switch (error.statusCode) {
      case '404':
        return NotFoundException(error.message);
      case '403':
        return ForbiddenException(error.message);
      case '409':
        return BadRequestException(error.message);
      default:
        return InternalServerErrorException(error.message);
    }
  }

  if (error is SocketException) {
    return const NoInternetException();
  }

  return InternalServerErrorException(error.toString());
}
