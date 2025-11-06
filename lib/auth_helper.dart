import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartgre_sql/db_helper.dart';
import 'package:postgres/postgres.dart';

class AuthHelper {
  Future<Connection> get _db async => await DatabaseHelper().connection;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    final connection = await _db;

    final hashedPassword = _hashPassword(password);

    final result = await connection.execute(Sql.named('''
      Select * from auth where email = @email
    '''), parameters: {
      'email': email,
    });

    if (result.isEmpty) {
      return {'message': 'User not found'};
    } else {
      final user = result.first.toColumnMap();

      if (user['user_password'] == hashedPassword) {
        return {
          'message': 'Login successful',
          'id': user['user_id'],
          'is_success': true,
        };
      } else {
        return {
          'message': 'Invalid password',
          'is_success': false,
        };
      }
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    final connection = await _db;

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return {'message': 'Invalid email format'};
    }

    if (password.length < 6) {
      // Example length check
      return {'message': 'Password must be at least 6 characters'};
    }

    final hashedPassword = _hashPassword(password);

    try {
      final emailCheck = await connection.execute(
          Sql.named(''''''
              '''
      SELECT email FROM auth WHERE email = @email
    '''),
          parameters: {'email': email});

      if (emailCheck.isNotEmpty) {
        return {'message': 'User already exists'};
      }

      final result = await connection.execute(
        Sql.named('''
        INSERT INTO auth (email, user_password)
        VALUES (@email, @user_password)
        RETURNING email, user_password
      '''),
        parameters: {
          'email': email,
          'user_password': hashedPassword,
        },
      );

      if (result.isEmpty) {
        return {'message': 'Failed to create user'};
      } else {
        return result.first.toColumnMap(); // Returns new user data
      }
    } catch (e) {
      return {'message': 'Error occurred: $e'};
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    final connection = await _db;
    final result = await connection.execute(
      Sql.named('''select * from auth'''),
    );
    if (result.isEmpty) {
      return [
        {'message': 'No data available'}
      ];
    } else {
      return result.map((element) => element.toColumnMap()).toList();
    }
  }
}
