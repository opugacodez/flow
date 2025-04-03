class AuthService {
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock implementation
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock implementation
  }

  Future<void> recoverPassword({
    String? email,
    String? phone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock implementation
  }
}