import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/auth_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    final db = AuthHelper();
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final email = data['email'] as String;
    final password = data['password'] as String;

    final result = await db.signUp(email: email, password: password);
    return Response.json(body: result, statusCode: 200);
  }

  return Response(statusCode: 405);
}
