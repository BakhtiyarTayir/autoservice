import 'package:dio/dio.dart';
import 'package:autoservice/src/features/auth/services/token_storage.dart';
import 'dart:math' as math;

class AuthInterceptor extends Interceptor {
  final Dio dio; // Dio instance to potentially make refresh token calls
  final TokenStorage tokenStorage;

  AuthInterceptor(this.dio, this.tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getToken();

    print('AuthInterceptor: Processing request to ${options.path}');
    print('AuthInterceptor: Current token: ${token != null ? token.substring(0, math.min(10, token.length)) + "..." : "null"}');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print('AuthInterceptor: Token added to headers for path: ${options.path}');
    } else {
      print('AuthInterceptor: No token found, request proceeds without Authorization header.');
      if (!options.path.contains('/auth/')) {
        // If this is not an auth endpoint and we have no token, this will likely fail
        print('WARNING: Making non-auth request without token: ${options.path}');
      }
    }
    
    // TODO: Implement token refresh logic if API supports it
    // This is a simplified version. A full implementation would handle token expiry
    // and attempt to refresh the token using a refresh token, then retry the original request.
    // Example of what refresh logic might look like (pseudo-code):
    // if (token_is_expired) {
    //   try {
    //     new_token = await refreshToken(); // This would be a call via dio to your refresh token endpoint
    //     await tokenStorage.saveToken(new_token);
    //     options.headers['Authorization'] = 'Bearer $new_token';
    //     return handler.resolve(await dio.request(options.path, options: options)); // Retry with new token
    //   } catch (e) {
    //     // If refresh fails, logout user or handle error
    //     return handler.reject(DioException(requestOptions: options, error: e));
    //   }
    // }

    return handler.next(options); // Continue with the request
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      print('AuthInterceptor: Received 401 Unauthorized for path: ${err.requestOptions.path}');
      print('AuthInterceptor: Response data: ${err.response?.data}');
      
      // Log detailed request information for debugging
      print('AuthInterceptor: Request headers: ${err.requestOptions.headers}');
      print('AuthInterceptor: Request method: ${err.requestOptions.method}');
      print('AuthInterceptor: Request data: ${err.requestOptions.data}');
      
      // If this is not an auth endpoint, the token might be invalid or expired
      if (!err.requestOptions.path.contains('/auth/')) {
        print('AuthInterceptor: Non-auth endpoint returned 401, token might be invalid');
      }
      
      // Return a more descriptive error message
      final error = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: 'Unauthorized: Authentication required or token expired',
        type: err.type,
      );
      
      return handler.next(error);
    }
    
    return handler.next(err); // Continue with the error
  }
}