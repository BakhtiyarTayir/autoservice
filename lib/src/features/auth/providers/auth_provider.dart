import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/auth/models/token_model.dart';
import 'package:autoservice/src/features/auth/models/user_model.dart';
import 'package:autoservice/src/features/auth/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Состояние аутентификации
enum AuthStatus { unknown, authenticated, unauthenticated }

// Класс состояния аутентификации
class AuthState {
  final AuthStatus status;
  final User? user;
  final Token? token;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Token? token,
    String? errorMessage,
    bool clearToken = false, // Флаг для явного сброса токена
    bool clearUser = false, // Флаг для явного сброса пользователя
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      token: clearToken ? null : token ?? this.token,
      errorMessage: errorMessage, // Ошибку не копируем по умолчанию
    );
  }
}

// Провайдер сервиса аутентификации (для удобства)
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Провайдер для Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

// Ключ для хранения токена
const String _tokenStorageKey = 'auth_token';

// StateNotifier для управления состоянием аутентификации
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._authService, this._storage) : super(AuthState()) {
    _loadToken(); // Пытаемся загрузить токен при инициализации
  }

  // Попытка загрузить сохраненный токен
  Future<void> _loadToken() async {
    try {
      final savedToken = await _storage.read(key: _tokenStorageKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        // TODO: Возможно, стоит проверить валидность токена на сервере
        print('Token loaded from storage: $savedToken');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: Token(accessToken: savedToken),
          // TODO: Загрузить данные пользователя, если токен валиден
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('Failed to load token: $e');
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  // Метод для входа
  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.unknown); // Показываем индикатор загрузки
      final token = await _authService.login(username, password);
      await _storage.write(key: _tokenStorageKey, value: token.accessToken);
      print('Token saved to storage: ${token.accessToken}');
      // TODO: Загрузить данные пользователя после входа (если API не возвращает их сразу)
      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        // user: fetchedUser,
        errorMessage: null, // Сбрасываем ошибку при успехе
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Ошибка входа: ${e.toString()}',
        clearToken: true,
        clearUser: true,
      );
    }
  }

  // Метод для регистрации
  Future<void> register({
    required String username,
    required String password,
    String? phone,
    String? firstName,
  }) async {
    state = state.copyWith(status: AuthStatus.unknown, errorMessage: null);
    try {
      // 1. Call AuthService.register, which returns a User object
      //    and saves the token string to secure storage.
      final User registeredUser = await _authService.register(
        username: username,
        password: password,
        phone: phone,
        firstName: firstName,
      );

      // 2. Read the token string that AuthService saved.
      //    Ensure _tokenStorageKey in AuthNotifier matches 'auth_token'.
      final String? accessTokenString = await _storage.read(key: _tokenStorageKey);

      if (accessTokenString == null) {
        // This case should ideally not occur if AuthService.register succeeded
        // and saved the token.
        print('Error: Token not found in storage after registration.');
        // Set an error state or re-throw a more specific exception
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Ошибка регистрации: токен не был сохранен.',
          clearToken: true,
          clearUser: true,
        );
        return; // Exit if token is missing
      }

      // 3. Create a Token object
      final Token token = Token(accessToken: accessTokenString);

      // 4. Update AuthState
      // AuthService already saved the token string. If AuthNotifier also writes it
      // using the same key, it's redundant but harmless.
      // If AuthNotifier is the sole manager of _storage for token, this write is necessary.
      // await _storage.write(key: _tokenStorageKey, value: token.accessToken);
      // For now, we assume AuthService's write is sufficient for storage,
      // and AuthNotifier primarily needs the Token object for its state.

      print('User registered successfully: ${registeredUser.username}');
      print('Token retrieved for AuthState: ${token.accessToken}');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token, // Use the created Token object
        user: registeredUser, // Use the User object from registration
        errorMessage: null, // Clear any previous error message
      );
    } catch (e, stackTrace) {
      // Логируем ошибку для отладки
      print('Error during registration in AuthNotifier: $e');
      print(stackTrace);

      String displayErrorMessage = e.toString();
      if (displayErrorMessage.startsWith('Exception: ')) {
        displayErrorMessage = displayErrorMessage.substring('Exception: '.length);
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: displayErrorMessage, // Устанавливаем чистое сообщение об ошибке
        clearToken: true,
        clearUser: true,
      );
    }
  }

  // Метод для выхода
  Future<void> logout() async {
    if (state.token != null) {
      try {
        await _authService.logout(state.token!.accessToken);
      } catch (e) {
        // Обработка ошибки выхода на сервере (можно проигнорировать или залогировать)
        print('Ошибка при выходе на сервере: $e');
      }
    }
    try {
      await _storage.delete(key: _tokenStorageKey);
      print('Token deleted from storage');
    } catch (e) {
      print('Failed to delete token: $e');
    }
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearToken: true,
      errorMessage: null,
    );
  }
}

// Провайдер StateNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(authService, storage);
});

// Селекторы для удобного доступа к частям состояния
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token?.accessToken;
});

final authUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});