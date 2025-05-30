import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/auth/models/token_model.dart';
import 'package:autoservice/src/features/auth/models/user_model.dart';
import 'package:autoservice/src/features/auth/services/auth_service.dart';
import 'package:autoservice/src/features/auth/services/token_storage.dart'; // Импорт TokenStorage
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Больше не используется напрямую

// Состояние аутентификации
enum AuthStatus { unknown, authenticated, unauthenticated, loading }

// Класс состояния аутентификации
class AuthState {
  final AuthStatus status;
  final User? user;
  final TokenModel? token; // Используем TokenModel вместо Token
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
    TokenModel? token, // Используем TokenModel
    String? errorMessage,
    bool clearToken = false, 
    bool clearUser = false, 
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      token: clearToken ? null : token ?? this.token,
      errorMessage: errorMessage ?? (status == AuthStatus.authenticated ? null : this.errorMessage), // Сбрасываем ошибку при успехе или если не передана новая
    );
  }
}

// Провайдер для TokenStorage (уже есть в dio_provider.dart, но здесь тоже нужен для AuthNotifier)
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

// Провайдер сервиса аутентификации
final authServiceProvider = Provider<AuthService>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthService(tokenStorage); // Передаем TokenStorage в AuthService
});

// StateNotifier для управления состоянием аутентификации
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final TokenStorage _tokenStorage; // Используем TokenStorage напрямую

  AuthNotifier(this._authService, this._tokenStorage) : super(AuthState(status: AuthStatus.loading)) {
    _initializeAuthStatus(); 
  }

  // Инициализация состояния аутентификации
  Future<void> _initializeAuthStatus() async {
    try {
      final tokenString = await _tokenStorage.getToken();
      if (tokenString != null && tokenString.isNotEmpty) {
        print('AuthNotifier: Token found in storage: $tokenString');
        // Получаем partnerId из хранилища
        final partnerId = await _tokenStorage.getPartnerId();
        
        // Создаем базовый объект User с имеющимися данными
        // Примечание: полные данные пользователя доступны только при входе,
        // поэтому здесь мы создаем объект с минимальными данными
        User? loadedUser;
        if (partnerId != null) {
          // Создаем базовый объект User с данными, которые у нас есть
          // В реальном приложении можно хранить больше данных пользователя локально
          loadedUser = User(
            username: 'cached_user', // Используем временное имя пользователя
            partnerId: partnerId
          );
          print('AuthNotifier: Created user with cached data. Partner ID: $partnerId');
        } else {
          print('AuthNotifier: No partner ID found in storage. User might need to login again.');
          // Если нет partnerId, возможно, данные неполные или повреждены
          await _tokenStorage.deleteAll();
          state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true, clearToken: true);
          return;
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: TokenModel(accessToken: tokenString),
          user: loadedUser,
        );
      } else {
        print('AuthNotifier: No token found in storage.');
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('AuthNotifier: Failed to initialize auth status: $e');
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  // Метод для входа
  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null); 
      final user = await _authService.login(username, password);
      final tokenString = await _tokenStorage.getToken(); // Получаем токен, сохраненный AuthService

      if (tokenString == null) {
         throw Exception('Token was not saved after login.');
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: TokenModel(accessToken: tokenString),
        user: user,
        errorMessage: null, 
      );
    } catch (e) {
      print('AuthNotifier: Login failed: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
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
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final User registeredUser = await _authService.register(
        username: username,
        password: password,
        phone: phone,
        firstName: firstName,
      );
      final String? accessTokenString = await _tokenStorage.getToken();

      if (accessTokenString == null) {
        print('AuthNotifier: Error - Token not found in storage after registration.');
        throw Exception('Токен не был сохранен после регистрации.');
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: registeredUser,
        token: TokenModel(accessToken: accessTokenString),
        errorMessage: null,
      );
    } catch (e) {
      print('AuthNotifier: Registration failed: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        clearToken: true,
        clearUser: true,
      );
    }
  }

  // Метод для выхода
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.logout(); // AuthService теперь сам управляет TokenStorage
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearToken: true,
        errorMessage: null,
      );
      print('AuthNotifier: User logged out.');
    } catch (e) {
      print('AuthNotifier: Error during logout: $e');
      // Даже если произошла ошибка при вызове API выхода (например, нет сети),
      // все равно переводим в состояние unauthenticated локально.
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearToken: true,
        errorMessage: 'Ошибка при выходе: ${e.toString()}',
      );
    }
  }
}

// Провайдер состояния аутентификации
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthNotifier(authService, tokenStorage);
});

// Провайдер для получения текущего пользователя (если аутентифицирован)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.status == AuthStatus.authenticated ? authState.user : null;
});

// Провайдер для получения текущего токена (если аутентифицирован)
final currentTokenProvider = Provider<TokenModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.status == AuthStatus.authenticated ? authState.token : null;
});

// Провайдер для получения статуса аутентификации
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authStateProvider).status;
});

// Провайдер для получения только строки токена
final authTokenProvider = Provider<String>((ref) {
  final tokenModel = ref.watch(currentTokenProvider);
  return tokenModel?.accessToken ?? ''; // Возвращаем пустую строку, если токен не найден
});