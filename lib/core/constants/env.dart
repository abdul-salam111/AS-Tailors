import 'package:envied/envied.dart';

part 'env.g.dart';

/// Compile-time secrets, read from `.env` (gitignored — copy `.env.example`
/// to `.env` and fill in real values) and baked in obfuscated at build time
/// by `envied_generator`. See CLAUDE.md §2a for the full setup/rotation flow.
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'BASE_URL')
  static final String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'APP_TOKEN')
  static final String appToken = _Env.appToken;
}
