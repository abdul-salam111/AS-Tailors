class SessionEntity {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;

  const SessionEntity({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
  });

  static const empty = SessionEntity(accessToken: '');

  bool get isValid => accessToken.isNotEmpty;
}
