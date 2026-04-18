class AuthState {
  final bool isLogin;
  final bool isLoading;
  final bool isSuccess; // ✅ ADD THIS
  final String? error;

  AuthState({
    required this.isLogin,
    required this.isLoading,
    required this.isSuccess,
    this.error,
  });

  factory AuthState.initial() => AuthState(
    isLogin: true,
    isLoading: false,
    isSuccess: false,
  );

  AuthState copyWith({
    bool? isLogin,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return AuthState(
      isLogin: isLogin ?? this.isLogin,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      error: error,
    );
  }
}