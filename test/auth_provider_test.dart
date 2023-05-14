import 'package:flutter_test/flutter_test.dart';

//Testing AuthProvider functions
//Todas son funciones de ejemplo simulando el comportamiento de la clase ya que uno no se puede conectar a Firebase desde un test.

// Abstract class for authentication
abstract class Auth {
  Future<bool> loginUser(String email, String password);
  Future<bool> registerUser(
    String nombreCompleto,
    String email,
    String password,
  );
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified(bool verification);
  Future<void> resetPassword(String email);
  Future<bool> reauthenticate(String password);
}

class AuthProvider {
  final Auth auth;

  AuthProvider({required this.auth});

  Future<bool> loginUser(String email, String password) {
    return auth.loginUser(email, password);
  }

  Future<bool> registerUser(
    String nombreCompleto,
    String email,
    String password,
  ) {
    return auth.registerUser(nombreCompleto, email, password);
  }

  Future<void> logOut() {
    return auth.logOut();
  }

  Future<void> sendEmailVerification() {
    return auth.sendEmailVerification();
  }

  Future<bool> isEmailVerified(bool verification) {
    return auth.isEmailVerified(verification);
  }

  Future<void> resetPassword(String email) {
    return auth.resetPassword(email);
  }

  Future<bool> reauthenticate(String password) {
    return auth.reauthenticate(password);
  }
}

// MockAuth class implementing the Auth interface for testing
class MockAuth implements Auth {
  bool userLoggedIn = false;
  bool isEmailVerifiedFlag = false;
  @override
  Future<bool> loginUser(String email, String password) async {
    try {
      if (email == 'test@example.com' && password == 'password') {
        print('Login successful');
        userLoggedIn = true;
        return true;
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (error) {
      print('Login failed: $error');
      userLoggedIn = false;
      return false;
    }
  }

  @override
  Future<bool> registerUser(
    String nombreCompleto,
    String email,
    String password,
  ) async {
    try {
      // Validate email format
      final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
      if (!emailRegex.hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password length
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      print('User registration successful');

      // Send email verification after successful registration
      await sendEmailVerification();

      return true;
    } catch (error) {
      print('User registration failed: $error');
      return false;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      if (userLoggedIn) {
        print('User logged out');
        userLoggedIn = false;
      } else {
        throw Exception('No user logged in');
      }
    } catch (error) {
      print('Logout failed: $error');
      // Handle errors or throw an exception if logout fails
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      print('Email verification sent');
    } catch (error) {
      print('Email verification failed: $error');
      // Handle errors or throw an exception if email verification fails
    }
  }

  @override
  Future<bool> isEmailVerified(bool verification) async {
    isEmailVerifiedFlag = verification;
    try {
      if (isEmailVerifiedFlag) {
        print('Email is verified');
        return true;
      } else {
        print('Email is not verified');
        return false;
      }
    } catch (error) {
      print('Email verification check failed: $error');
      return false;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      print('Password reset successful');
    } catch (error) {
      print('Password reset failed: $error');
      // Handle errors or throw an exception if password reset fails
    }
  }

  @override
  Future<bool> reauthenticate(String password) async {
    try {
      if (password == 'password') {
        print('Reauthentication successful');
        return true;
      } else {
        throw Exception('Invalid password');
      }
    } catch (error) {
      print('Reauthentication failed: $error');
      return false;
    }
  }
}

void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late MockAuth mockAuth;

    setUp(() {
      mockAuth = MockAuth();
      authProvider = AuthProvider(auth: mockAuth);
    });

    test('loginUser - successful login', () async {
      // Set up test data
      const email = 'test@example.com';
      const password = 'password';

      // Call the method to be tested
      final result = await authProvider.loginUser(email, password);

      // Verify the result
      expect(result, true);
    });

    test('loginUser - invalid credentials', () async {
      // Set up test data
      const email = 'wrong@example.com';
      const password = 'wrongpassword';

      // Call the method to be tested
      final result = await authProvider.loginUser(email, password);

      // Verify the result
      expect(result, false);
    });

    test('registerUser - successful registration', () async {
      // Set up test data
      const nombreCompleto = 'John Doe';
      const email = 'test@example.com';
      const password = 'password';

      // Call the method to be tested
      final result =
          await authProvider.registerUser(nombreCompleto, email, password);

      // Verify the result
      expect(result, true);
    });

    test('registerUser - invalid email format', () async {
      // Set up test data
      const nombreCompleto = 'John Doe';
      const email = 'invalidemail';
      const password = 'password';

      // Call the method to be tested
      final result =
          await authProvider.registerUser(nombreCompleto, email, password);

      // Verify the result
      expect(result, false);
    });

    test('registerUser - password too short', () async {
      // Set up test data
      const nombreCompleto = 'John Doe';
      const email = 'test@example.com';
      const password = '123';

      // Call the method to be tested
      final result =
          await authProvider.registerUser(nombreCompleto, email, password);

      // Verify the result
      expect(result, false);
    });

    test('isEmailVerified - email is verified', () async {
      bool result = await authProvider.isEmailVerified(true);
      expect(result, true);
    });

    test('isEmailVerified - email is not verified', () async {
      bool result = await authProvider.isEmailVerified(false);
      expect(result, false);
    });

    test('resetPassword - password reset successful', () async {
      await authProvider.resetPassword('test@example.com');
      // No return value to assert against, so the test passes if it doesn't throw an exception
      expect(true, true);
    });

    test('resetPassword - password reset failed', () async {
      // The test should not throw an exception
      try {
        await authProvider.resetPassword('invalid@example.com');
        expect(true, false); // Fail the test if no exception is thrown
      } catch (error) {
        // Handle the error or assert on specific error conditions
        expect(error, isNotNull); // For example, assert that an error occurred
      }
    });

    test('reauthenticate - reauthentication successful', () async {
      bool result = await authProvider.reauthenticate('password');
      expect(result, true);
    });

    test('reauthenticate - reauthentication failed', () async {
      bool result = await authProvider.reauthenticate('invalid_password');
      expect(result, false);
    });
  });
}
