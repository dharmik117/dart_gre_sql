import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = TodosHelper();
  final body = await context.request.body();
  final data = jsonDecode(body) as Map<String, dynamic>;
  if (context.request.method == HttpMethod.post) {
    final todo = data['text'] as String;
    final id = data['user_id'] as int;
    final insert = await db.addTodo(text: todo, id: id);
    return Response.json(body: insert);
  }

  return Response(statusCode: 405);
}
