import '../../../core/services/session_entity.dart';
import '../../../core/services/session_resolver.dart';
import '../domain/repositories/auth_repository.dart';

/// Implements core's [ISessionResolver] port using the `auth` feature's own
/// repository — the Data-layer adapter half of the dependency inversion
/// described on [ISessionResolver]. Registered in `register_auth.dart`.
class SessionResolverImpl implements ISessionResolver {
  final IAuthRepository _authRepository;

  SessionResolverImpl({required IAuthRepository authRepository}) : _authRepository = authRepository;

  @override
  Future<SessionEntity?> resolve() async {
    final result = await _authRepository.getCurrentSession();
    return result.fold(
      (failure) => null,
      (auth) => auth == null
          ? null
          : SessionEntity(
              userId: auth.userId,
              email: auth.email,
              fullName: auth.fullName,
              shopId: auth.shopId,
              role: auth.role,
            ),
    );
  }
}
