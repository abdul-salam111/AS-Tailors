// ignore_for_file: unintended_html_in_doc_comment

/* -------------------------------------------------------------------------- */
/*                             Base Repository                                 */
/* -------------------------------------------------------------------------- */

import 'package:fpdart/fpdart.dart' hide State;
import '../failures/failure.dart';
import '../../../networks/exceptions/app_exceptions.dart';

abstract class BaseRepository {
  /// Execute repository call with automatic error handling.
  /// Maps infrastructure [AppException] subtypes to domain [Failure] subtypes,
  /// keeping the domain layer free of infrastructure concerns.
  Future<Either<Failure, T>> execute<T>({required Future<T> Function() call}) async {
    try {
      return Right(await call());
    } on UserCancelledException catch (e) {
      return Left(UserCancelledFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NoInternetException catch (e) {
      return Left(NetworkFailure(e.message));
    } on RequestTimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message));
    } on InvalidInputException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on TooManyRequestsException catch (e) {
      return Left(RateLimitFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
