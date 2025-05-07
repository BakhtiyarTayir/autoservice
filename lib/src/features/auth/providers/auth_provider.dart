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
    try {
      final user = await _authService.register(
        username: username,
        password: password,
        phone: phone,
        firstName: firstName,
      );
      // TODO: Возможно, после регистрации нужно автоматически выполнить вход
      // await login(username, password);
      // Или просто обновить состояние, если регистрация не подразумевает авто-вход
      state = state.copyWith(
          // status: AuthStatus.unauthenticated, // Пользователь зарегистрирован, но не вошел
          // user: user, // Можно сохранить данные пользователя
          errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Ошибка регистрации: ${e.toString()}',
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