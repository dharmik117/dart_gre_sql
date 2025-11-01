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
        return {'message': 'Login successful'};
      } else {
        return {'message': 'Invalid password'};
      }
    }
  }

  Future<Map<String, dynamic>> signUp(
      {required String email, required String password}) async {
    final connection = await _db;
    final hashedPassword = _hashPassword(password);

    final result = await connection.execute(
      Sql.named(
        '''
    Insert into auth (email,user_password) values (@email,@user_password) returning  email,user_password
    ''',
      ),
      parameters: {
        'email': email,
        'user_password': hashedPassword,
      },
    );

    if (result.isEmpty) {
      return {'message': 'Failed to create user'};
    } else {
      return result.first.toColumnMap();
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
