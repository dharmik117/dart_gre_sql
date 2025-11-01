import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    final db = TodosHelper();
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final todo = data['text'] as String;
    final id = data['id'] as int;
    final is_liked = data['is_liked'] as bool;

    final insert = await db.updateTodo(text: todo, id: id,isLiked: is_liked);
    return Response.json(body: insert);
  }

  return Response(statusCode: 405);
}
